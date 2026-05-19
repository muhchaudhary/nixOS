# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal NixOS configuration flake using [Snowfall Lib](https://github.com/snowfallorg/lib) to manage two hosts:
- `muhammadDesktop` — AMD CPU + Nvidia GPU, gaming-focused desktop
- `muhammadLaptop` — Lenovo ThinkPad T14 AMD Gen4, power-managed laptop

## Common Commands

```bash
# Rebuild and switch NixOS (run as root or with sudo)
sudo nixos-rebuild switch --flake .#muhammadDesktop
sudo nixos-rebuild switch --flake .#muhammadLaptop

# Format nix files (alejandra is installed system-wide)
alejandra .

# Check flake outputs without building
nix flake check

# Build without switching
nixos-rebuild build --flake .#muhammadDesktop

# Update flake inputs
nix flake update

# Deploy remotely via deploy-rs
deploy .#muhammadDesktop
```

## Architecture

### Snowfall Lib Conventions

Snowfall Lib auto-discovers modules, homes, and systems by directory structure — no manual imports needed. The `namespace` variable throughout modules resolves to `internal` (derived from flake name).

**Directory layout:**
- `systems/x86_64-linux/<hostname>/` — NixOS system configuration per host
- `homes/x86_64-linux/<user>[@<hostname>]/` — Home Manager config; `muhammad/` applies to all hosts, `muhammad@muhammadDesktop/` is host-specific
- `modules/nixos/` — NixOS modules, auto-exposed under `config.internal.*`
- `modules/home/` — Home Manager modules, auto-exposed under `config.internal.*`
- `lib/` — Custom library functions exposed as `lib.internal.*`

### Module Pattern

All modules follow the same opt-in pattern:

```nix
options.internal.feature = {
  enable = mkBoolOpt false "Description";
};
config = mkIf cfg.enable { ... };
```

**Aggregate modules** (`apps/default.nix`, `cli/default.nix`) auto-enable all subdirectories when their parent is enabled — e.g., `internal.apps = enabled` enables every subdirectory under `modules/home/apps/`.

### Custom Lib Helpers (`lib/modules/default.nix`)

- `mkBoolOpt` / `mkBoolOpt'` — shorthand for boolean module options
- `mkOpt` / `mkOpt'` — shorthand for typed module options with/without description
- `enabled` / `disabled` — `{ enable = true; }` / `{ enable = false; }`

These are used pervasively; always prefer them over raw `mkOption`.

### Key Module Groups

**NixOS (`modules/nixos/`):**
- `system` — umbrella enabling boot, locale, bluetooth, network, sound, printer
- `desktop/hyprland` — Hyprland WM + SDDM + KDE Connect
- `nix` — nix daemon settings, GC, substituters (enabled by default)
- `user` — user account, fish shell, base packages

**Home Manager (`modules/home/`):**
- `apps` — GUI applications (Firefox, Zen, Obsidian, Blender, etc.)
- `cli` — CLI tools (direnv, fzf, git, fastfetch, fish config)
- `themes/gtk` — GTK/Qt theming (Colloid-Dark + Bibata cursors)

### Inputs

Notable flake inputs:
- `snowfall-lib` — repo structure framework
- `hyprland` / `hyprland-plugins` — Wayland compositor
- `home-manager` — follows nixpkgs
- `deploy-rs` — remote deployment
- `spicetify-nix` — Spotify theming
- `zen-browser` — Zen browser flake
- `blender-bin` — pre-built Blender overlay
