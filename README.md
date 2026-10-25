# nix

My Mac, declared with [nix-darwin](https://github.com/nix-darwin/nix-darwin)
and [home-manager](https://github.com/nix-community/home-manager).

```sh
darwin-rebuild switch --flake .
nix flake check   # secret scan
nix fmt
```

## Layout

```
flake.nix
darwin/    the system: nix, users, homebrew, macOS defaults, DNS blocklist
home/      home-manager: packages, shell, git, ssh, editors, macOS agents
config/    plain dotfiles: nushell, nvim, zed, cursor, ghostty, starship, tmux
agents/    coding agents: shared AGENTS.md and skills, plus Claude Code's config
```

Apps that rewrite their own settings (editors, shell, agents) are linked to
the checkout rather than copied into the store, so edits show up in git
without a rebuild. That assumes the repo lives at `/Volumes/Projects/nix`
(`repo` in `darwin/default.nix`).
