#########################################################
#  ~/.zshrc — cross-platform (macOS + WSL/Ubuntu)        #
#########################################################

#### 1. shell hygiene #######################################
HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS

export EDITOR='nvim'

#### 2. Homebrew ############################################
# Put this early so brew-installed tools are on PATH for everything below.
# Linuxbrew path for WSL; macOS sets HOMEBREW_PREFIX via /opt/homebrew.
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

#### 3. PATH ################################################
# Keep PATH edits together and early.
export PATH="$PATH:/opt/mssql-tools18/bin"
export PATH="$HOME/.local/bin:$PATH"

#### 4. pyenv ###############################################
# Ensure pyenv works in zsh (and python is found via shims).
export PYENV_ROOT="$HOME/.pyenv"
if [[ -x "$PYENV_ROOT/bin/pyenv" ]]; then
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1  # let Starship handle venv display
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - zsh)"
  eval "$(pyenv virtualenv-init - zsh)"
fi

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

# Cortex CLI completion (disable via /settings in cortex)
[[ -s ~/.zsh/completions/cortex.zsh ]] && source ~/.zsh/completions/cortex.zsh

#### 6. fzf #################################################
[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

#### 7. plugins #############################################
# zsh-autosuggestions
if [[ -r "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# zsh-syntax-highlighting (must load last among plugins)
if [[ -r "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

#### 8. aliases & functions #################################
alias gs='git status -sb'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
  alias ll='eza -al --group-directories-first --git'
fi

# Pull all git repos under a root dir, excluding dotfiles.
# Pass a path or set REPOS_ROOT; defaults to common locations.
gpullall() {
  local script="$HOME/.zsh/scripts/gpullall"
  if [[ ! -x "$script" ]]; then
    echo "Missing executable: $script"
    return 1
  fi
  "$script" "$@"
}

# Upgrade every outdated pip package in the current environment.
pip-upgrade-all() {
  local script="$HOME/.zsh/scripts/pip-upgrade-all"
  if [[ ! -x "$script" ]]; then
    echo "Missing executable: $script"
    return 1
  fi
  "$script" "$@"
}

#### 9. local overrides #####################################
# Machine-specific config (not committed): LiteLLM endpoints,
# API keys, work proxies, etc. Lives in ~/.zshrc.local.
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi

#### 10. prompt #############################################
# Starship must be last so it reflects the final PATH and env.
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
