# 🛠️ dotfiles

Personal dotfiles for a consistent, version-controlled terminal and development environment across machines.

## 📦 Contents

- `starship/` — [Starship](https://starship.rs) prompt configuration using the Catppuccin Mocha theme, with powerline-style segments and Nerd Font support.
- `ghostty/` — Terminal themes and profiles for [Ghostty](https://ghostty.app), symlinked to `~/.config/ghostty`.
- `warp/` — Custom themes for [Warp](https://warp.dev), backed up for manual import.
- (more coming soon...)

## 🧪 Usage

Clone the repo:

```bash
git clone git@github.com:p-clements/dotfiles.git ~/code/repos/dotfiles
```

Then symlink your configs:
```bash
ln -sfn ~/code/repos/dotfiles/starship/starship.toml ~/.config/starship.toml
ln -sfn ~/code/repos/dotfiles/ghostty ~/.config/ghostty
```
Warp themes can be manually imported from warp/ if needed.

📌 Notes
	•	Starship uses the catppuccin_macchiato palette by default. Change this in starship.toml to switch flavour.
