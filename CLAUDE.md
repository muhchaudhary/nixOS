# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal NixOS configuration built on [Nilla](https://nilla.dev) (with
[nilla-utils](https://github.com/arnarg/nilla-utils)) and [npins](https://github.com/andir/npins)
for dependency pinning. It manages three hosts:
- `muhammadDesktop` — AMD CPU + Nvidia GPU, gaming-focused desktop
- `muhammadLaptop` — Lenovo ThinkPad T14 AMD Gen4, power-managed laptop
- `laptopServer` — headless ThinkPad X1 (Intel) server

The entrypoint is `nilla.nix`, not `flake.nix`. There is no flake.

## Common Commands

```bash
# Build/switch a host (nilla-utils' `os` plugin; run switch as root)
nilla os build muhammadDesktop
sudo nilla os switch muhammadDesktop
sudo nilla os switch muhammadLaptop

# Remote deploy over SSH (replaces the old deploy-rs workflow)
nilla os switch laptopServer --target <ssh-host>

# Build every declared system at once (CI-style gate)
nilla build allSystems

# Format nix files (alejandra is installed system-wide)
alejandra .

# Dependency management (npins replaces flake inputs)
npins show            # list pinned sources
npins update          # update all pins
npins update nixpkgs  # update a single pin
```

If the `nilla` CLI is not installed: `nix profile install github:nilla-nix/cli` (the
nilla-utils plugins provide the `os`/`home` subcommands).

## Architecture

### Nilla / npins conventions

- **`npins/`** — pinned dependency sources (`sources.json` + `default.nix`). Every input
  (nixpkgs, home-manager, hyprland, nix-gaming, sops-nix, zen-browser, blender-bin, …) is a pin.
- **`nilla.nix`** — the whole project wiring, in one file:
  - `generators.inputs.pins = pins` turns every npin into `config.inputs.<name>`. Flake inputs
    expose outputs under `.result` (e.g. `inputs.hyprland.result.packages.<system>`). `nixpkgs`
    (= the `nixos-unstable` pin) carries `settings` (allowUnfree + overlays). `blender-bin` is
    excluded from the generator and defined by hand (`src` = the `blender` subdir) because a
    generated `src` can't be overridden.
  - `generators.nixos.folder = ./hosts` creates `systems.nixos.<host>` for each
    `hosts/<host>/configuration.nix`, sets `networking.hostName = <host>`, and applies
    `modules.nixos.base` to every host.
  - `modules.nixos.*` / `modules.home.*` — the **named module registry** (see below).
- **`overlays/`** — raw `final: prev:` overlays that aren't new packages (only `openldap.nix`,
  intentionally not applied — see the note in `nilla.nix`).

**Directory layout:**
- `hosts/<host>/` — everything for one machine: `configuration.nix` (NixOS), `hardware.nix`,
  `home.nix` (Home Manager), plus host-only files (`hyprland.nix`, `hypr/monitors.lua`,
  `secrets.yaml`).
- `modules/nixos/`, `modules/home/` — plain feature modules, flat `foo.nix` files; a directory
  `default.nix` is only ever an `imports` barrel (`system/`, `gaming/`, `apps/`, `cli/`) or a module
  that owns non-nix files (`home/hyprland/` with its `config/`).
- `modules/home/profiles/` — role bundles shared by several hosts (`workstation.nix`).

**Gotcha:** the nixos generator imports `"${./hosts}/<host>/configuration.nix"`, i.e. from a
store copy of `hosts/`. Paths in a `configuration.nix` must therefore stay inside `hosts/`
(`../../secrets/x` breaks — that's why secrets live in the host dir). `home.nix` is imported from the
working tree, but keep the same rule for consistency. Because of the store copy, use
`nix eval --impure` (not `nix-instantiate --eval`, which can't write to the store) when evaluating by hand.

### Module pattern — explicit composition, no toggles

Modules are **plain config** with no `enable` options and no custom namespace. What a host gets is
exactly what it imports.

```nix
# a leaf module — just config
{ pkgs, ... }: {
  services.printing.enable = true;
}
```

- **Hosts import modules by name** via special args: `nixosModules` (= `config.modules.nixos`,
  passed by nilla-utils) in `configuration.nix`, `homeModules` (= `config.modules.home`, passed
  via `generators.nixos.args` and HM `extraSpecialArgs`) in `home.nix`:
  ```nix
  {nixosModules, inputs, ...}: {
    imports = with nixosModules; [./hardware.nix inputs.nixos-hardware.result.nixosModules.common-pc-ssd system gaming hyprland];
  }
  ```
  A new module must be registered in `nilla.nix` (`modules.nixos.<name>` / `modules.home.<name>`)
  before a host can import it by name.
- **Modules refer to each other by relative path** (barrels, profiles, `base`), not by name.
- A module that needs an upstream module imports it itself (`secrets.nix` → sops-nix,
  `gaming/steam.nix` → nix-gaming platformOptimizations, `home/apps/media.nix` → spicetify).
- Cross-cutting settings just merge via the NixOS/HM module system — e.g. feature modules append to
  `users.users.muhammad.extraGroups` and `nix.settings.substituters` (list options merge).

### Home Manager: base → profile → host

Home Manager runs **as a NixOS module**, wired by `modules/nixos/home-manager.nix` (part of the
NixOS `base`): `useGlobalPkgs`, `extraSpecialArgs = {inputs, homeModules}`, and
`home-manager.users.muhammad.imports = [homeModules.base hosts/<host>/home.nix]`. One
`nilla os switch` activates system + home together. (`generators.home` is *not* used — it builds
standalone HM configs.)

1. **`base`** (`modules/home/base.nix`, every host, automatic) — user, stateVersion, core `cli`
   (direnv/fastfetch/fzf/fish/git; `infra` is deliberately not in the `cli` barrel).
2. **profile** (`modules/home/profiles/*.nix`) — `workstation` = `apps` + `infra` + `gtk` +
   `hyprland`, shared by desktop and laptop. Add a new profile file for a new role rather than
   adding conditionals.
3. **host** (`hosts/<host>/home.nix`) — picks a profile and adds host-only modules/overrides.

Host-unique config: an app only one host wants → import `homeModules.<app>` from that host (and drop
it from the `apps` barrel if others shouldn't get it); same app with different settings → a host file
that sets extra options (merges, like `hosts/*/hyprland.nix`); override a shared value → `mkDefault`
in the shared module; hardware-dependent → read `osConfig` (as `vscode.nix` does for CUDA).

### Key module groups

**NixOS (`modules/nixos/`):** `base` (nix + user + home-manager, every host), `system`
(boot/locale + sound/network/bluetooth/printer barrel), `hardware/*`, `desktop/{hyprland,fonts,polkit}`,
`gtk`, `gaming` (steam/heroic), `secrets` (sops-nix), `virtualisation` (docker), `wg-hotspot`.

**Home Manager (`modules/home/`):** `base`, `profiles/workstation`, `apps` (Firefox/Zen/Obsidian/
Blender/…, each also exported individually), `cli` (+ `infra`), `gtk` (Colloid-Dark + Bibata),
`hyprland`.

### Notable inputs (pins)

`nilla` / `nilla-utils` — framework; `hyprland` / `hyprland-plugins` / `hyprland-qtutils`;
`home-manager`; `nixos-hardware`; `nix-gaming`; `sops-nix`; `spicetify-nix`; `zen-browser`;
`blender-bin` (Blender overlay, pinned at the `blender` subdir of edolstra/nix-warez).
