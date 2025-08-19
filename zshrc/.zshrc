# ── General PATH setup ────────────────────────────────────────
# Keep pyenv shims and your git-tools early on PATH.
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$HOME/git-tools:$PATH"

# ── Homebrew (Apple Silicon) ergonomics ──────────────────────
# Ensure brew-managed CLIs are found early.
[[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:$PATH"

# ── Pyenv (Python version manager) ────────────────────────────
# Initialise pyenv so shims work for python/pip, etc.
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# ── Upgrade every outdated package in the current pyenv env ───
pip-upgrade-all() {
  python -m pip list --outdated --format=json \
    | jq -r '.[].name' \
    | xargs -n1 python -m pip install --upgrade
}

# ── Prompt (Starship) ────────────────────────────────────────
# Fast, pretty prompt.
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ── Docker CLI completions ───────────────────────────────────
# Add Docker completion functions to fpath.
fpath=("$HOME/.docker/completions" $fpath)

# ── Palette: Catppuccin Macchiato ────────────────────────────
# Reference: https://catppuccin.com/palette/macchiato
export FZF_DEFAULT_OPTS="\
--color=fg:#cad3f5,bg:#24273a,hl:#c6a0f6 \
--color=fg+:#cad3f5,bg+:#494d64,hl+:#c6a0f6 \
--color=header:#8087a2,info:#91d7e3,pointer:#a6da95 \
--color=marker:#f5a97f,spinner:#8bd5ca,prompt:#7dc4e4"

# ── fzf key-bindings & completion widgets ────────────────────
# Adds Ctrl-R / Ctrl-T / Alt-C shortcuts and completion helpers.
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# ── Autosuggestions (history “ghost text”) ───────────────────
# Subtle suggestions; keep before syntax highlighting.
if [ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#8087a2'
fi

# ── fzf-tab: fuzzy <Tab> completion with preview ─────────────
# Works with your fzf theme; shows directory previews via eza.
if [ -r "$HOME/.local/share/fzf-tab/fzf-tab.plugin.zsh" ]; then
  source "$HOME/.local/share/fzf-tab/fzf-tab.plugin.zsh"
  zstyle ':fzf-tab:*' use-fzf-default-opts yes
  zstyle ':fzf-tab:*' switch-group '<' '>'
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always ${(q)realpath}'
fi

# ── Syntax highlighting (MUST load last) ─────────────────────
if [ -r /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  typeset -gA ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[command]='fg=#8aadf4'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#a6da95'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=#f5bde6'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#eed49f'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ed8796,bold'
fi

# ── Completions: initialise once & cache ─────────────────────
# Use -C to skip re-building if cache exists; speeds up startup.
autoload -Uz compinit
compinit -C

# ── Homebrew site-functions (eza + others) ───────────────────
# Adds brew-provided completions (incl. eza) to fpath.
if command -v brew >/dev/null 2>&1; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  # After changing fpath, rebuild cache once.
  compinit -C
fi

# ── eza (modern ls) aliases ──────────────────────────────────
# Handy defaults that play nicely with your fzf-tab previews.
if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
  alias ll='eza -al --group-directories-first --git'
  alias lt='eza -aT --level=2'
fi

# ── zoxide (smart cd) ────────────────────────────────────────
# Jump to dirs with `z`; interactive picker with `zi`.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# ── History: better defaults ─────────────────────────────────
# Bigger history, dedup, share across sessions for better fzf/Ctrl-R.
HISTFILE=~/.zsh_history
HISTSIZE=200000
SAVEHIST=200000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS \
       INC_APPEND_HISTORY SHARE_HISTORY EXTENDED_HISTORY
