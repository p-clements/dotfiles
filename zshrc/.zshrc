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
path=("$HOME/.local/bin" $path)
[[ -d /opt/mssql-tools18/bin ]] && path+=("/opt/mssql-tools18/bin")
typeset -U path
export PATH

#### 4. completions #########################################
ZSH_CACHE_DIR="$HOME/.cache/zsh"
mkdir -p "$ZSH_CACHE_DIR"

if [[ -n "$HOMEBREW_PREFIX" && -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi

# WSL: Docker Desktop can leave a broken symlink when its mount isn't present.
if [[ -L /usr/share/zsh/vendor-completions/_docker && ! -e /usr/share/zsh/vendor-completions/_docker ]]; then
  fpath=(${fpath:#/usr/share/zsh/vendor-completions})
fi

fpath+=(~/.zsh/completions ~/.zfunc)
autoload -Uz compinit && compinit -d "$ZSH_CACHE_DIR/zcompdump"
zstyle ':completion:*' menu select

# uv shell completions (must come after compinit)
if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
fi

# Cortex CLI completion (disable via /settings in cortex)
[[ -s ~/.zsh/completions/cortex.zsh ]] && source ~/.zsh/completions/cortex.zsh

#### 5. zoxide #############################################
# Must come after compinit for completions to work.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

#### 6. fzf #################################################
[[ -t 0 && -x "$(command -v fzf)" ]] && source <(fzf --zsh)

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
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Run coding agents through Headroom's context-optimization proxy.
alias hcodex='headroom wrap codex'
alias hclaude='headroom wrap claude'

if command -v eza >/dev/null 2>&1; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

if command -v fzf >/dev/null 2>&1 && command -v bat >/dev/null 2>&1; then
  alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
fi

# Pull all git repos under a root dir, excluding dotfiles.
# Pass a path, or run from the root you want to scan.
gpullall() {
  local script="$HOME/.zsh/scripts/gpullall"
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
