# Disable Ubuntu global compinit; run compinit from ~/.zshrc after custom fpath setup.
skip_global_compinit=1

# Workaround for https://github.com/anthropics/claude-code/issues/64986
# Claude Code --bg-pty-host injects BROWSER=true; override here so it applies
# to non-interactive zsh subshells (where .zshrc is not sourced).
[[ -n "$WSL_DISTRO_NAME" ]] && export BROWSER="$HOME/.local/bin/wsl-open"
