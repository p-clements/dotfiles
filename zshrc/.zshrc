#########################################################
#  ~/.zshrc — WSL-Ubuntu, Starship prompt                #
#########################################################

#### 1. basic shell hygiene ################################
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS

export EDITOR='nvim'

#### 2. Homebrew (Linuxbrew) ################################
# Put this early so brew-installed tools are on PATH for everything below.
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

#### 3. PATHs ################################################
# Keep PATH edits together and early.
# Note: append here so pyenv can still take precedence via shims.
export PATH="$PATH:/opt/mssql-tools18/bin"
export PATH="$HOME/.local/bin:$PATH"

#### 4. pyenv ################################################
# Ensure pyenv works in zsh (and python is found via shims).
export PYENV_ROOT="$HOME/.pyenv"
if [[ -x "$PYENV_ROOT/bin/pyenv" ]]; then
  # Let Starship handle venv display instead of pyenv-virtualenv.
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - zsh)"
  # Only if you actually use pyenv-virtualenv:
  eval "$(pyenv virtualenv-init - zsh)"
fi

# Upgrade every outdated pip package in the current environment.
pip-upgrade-all() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required (brew install jq or sudo apt install jq)"
    return 1
  fi

  local py
  py="$(command -v python || command -v python3)" || {
    echo "Python not found (pyenv not initialised or no python installed)."
    return 1
  }

  "$py" -m pip list --outdated --format=json \
    | jq -r '.[].name' \
    | xargs -n1 "$py" -m pip install --upgrade
}

#### 5. completions #########################################
if [[ -n "$HOMEBREW_PREFIX" && -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi

# WSL: Docker Desktop can leave a broken symlink when its mount isn't present.
if [[ -L /usr/share/zsh/vendor-completions/_docker && ! -e /usr/share/zsh/vendor-completions/_docker ]]; then
  fpath=(${fpath:#/usr/share/zsh/vendor-completions})
fi

fpath+=~/.zsh/completions
autoload -Uz compinit && compinit

#### 6. fzf ##################################
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

#### 7. plugins (stand-alone) ###############################
if [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

#### 8. aliases & local tooling #############################
alias gs='git status -sb'

# Pull all git repos under a root (default: ~/repos), excluding any repo named dotfiles.
gpullall() {
  local root="${1:-$HOME/repos}"
  if [[ ! -d "$root" ]]; then
    echo "Directory not found: $root"
    return 1
  fi

  find "$root" -type d -name .git -prune | while IFS= read -r gitdir; do
    local repo="${gitdir%/.git}"
    [[ "$(basename "$repo")" == "dotfiles" ]] && continue
    echo "== ${repo#$root/} =="
    (cd "$repo" && git pull --ff-only)
  done
}

if command -v eza >/dev/null 2>&1; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
  alias ll='eza -al --group-directories-first --git'
fi

if [[ -x "$HOME/.local/bin/dbt" ]]; then
  alias dbtf="$HOME/.local/bin/dbt"
fi

#### 9. dbt Fusion extension ###############################
# Ensure dbt binary dir is on PATH (added by dbt Fusion extension).
if [[ ":$PATH:" != *":/home/pclements/.local/bin:"* ]]; then
  export PATH=/home/pclements/.local/bin:"$PATH"
fi

#### 10. OpenAI config #####################################
# Keep secrets in ~/.zshrc.local so this file is safe to commit.
export OPENAI_BASE_URL="https://litellm-user.prd.mercuria.systems"

# Optional local overrides (not checked in).
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi

#### 11. prompt — starship ###################################
# Keep prompt init last so it reflects final PATH/env.
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
