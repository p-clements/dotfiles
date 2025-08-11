# General PATH setup
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$HOME/git-tools:$PATH"

# ── Pyenv (Python version manager) ────────────────────────────
eval "$(pyenv init -)"

# ── Upgrade every outdated package in the current pyenv environment
pip-upgrade-all() {
  python -m pip list --outdated --format=json \
    | jq -r '.[].name' \
    | xargs -n1 python -m pip install --upgrade
}

# ── Prompt (Starship) ────────────────────────────────────────
eval "$(starship init zsh)"

# ── Docker CLI completions ───────────────────────────────────
fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit          # load Zsh's completion system
compinit                       # initialise it

# ── Palette: Catppuccin Macchiato ─────────────────────────────
# Reference: https://catppuccin.com/palette/macchiato
export FZF_DEFAULT_OPTS="\
--color=fg:#cad3f5,bg:#24273a,hl:#c6a0f6 \
--color=fg+:#cad3f5,bg+:#494d64,hl+:#c6a0f6 \
--color=header:#8087a2,info:#91d7e3,pointer:#a6da95 \
--color=marker:#f5a97f,spinner:#8bd5ca,prompt:#7dc4e4"

# ── fzf key‑bindings & completion widgets ─────────────────────
# Adds Ctrl‑R / Ctrl‑T / Alt‑C shortcuts and completion helpers.
source <(fzf --zsh)

# ── Autosuggestions (history “ghost text”) ────────────────────
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#8087a2'

# ── fzf‑tab: fuzzy <Tab> completion with preview ──────────────
source "$HOME/.local/share/fzf-tab/fzf-tab.plugin.zsh"

# fzf‑tab styles & behaviour
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# ── Syntax highlighting (MUST load last) ──────────────────────
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#8aadf4'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#a6da95'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#f5bde6'
ZSH_HIGHLIGHT_STYLES[path]='fg=#eed49f'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ed8796,bold'

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/peterclements/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
