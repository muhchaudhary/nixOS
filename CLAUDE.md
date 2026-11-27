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

# Build every declared system at once (CI-style gate). On the desktop this also
# fills its binary cache, so the laptop/server switches download instead of building;
# keep the ./result link, it's the GC root for those builds.
nilla build allSystems

# Format nix files (alejandra is installed system-wide, and in the dev shell)
alejandra .

# Dev shell with alejandra/npins/nixd/sops (`shells.default`; direnv loads it via .envrc)
nilla shell   # or: nix-shell

# What CI runs (.github/workflows/check.yml): format check + evaluate every host
alejandra --check .
nix eval --impure --json --expr 'builtins.mapAttrs (n: s: s.result.config.system.build.toplevel.drvPath) (import ./nilla.nix).systems.nixos'

# Dependency management (npins replaces flake inputs)
npins show            # list pinned sources
npins update          # update all pins
npins update nixpkgs  # update a single pin
./scripts/update-vscode-insiders  # bump VS Code Insiders (modules/home/apps/vscode-insiders.json; needs jq: run in the dev shell)
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
- **`.github/workflows/`** — `check.yml` (format + evaluate all hosts on every push/PR) and
  `update.yml` (weekly `npins update` + VS Code Insiders bump, opened as a PR only if every host still evaluates).
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
  `gaming/steam.nix` → nix-gaming platformOptimizations).
- Cross-cutting settings just merge via the NixOS/HM module system — e.g. feature modules append to
  `users.users.muhammad.extraGroups` and `nix.settings.substituters` (list options merge).
- **Shell scripts:** small ones (a few lines, e.g. `steamos-session-select`, `gamemode-cpu-epp`) stay
  inline in the `.nix` file. Larger or more complex ones (e.g. `gaming-mode`, `gaming-browser`,
  `steam-ui-watchdog`) go in a `scripts/` folder next to the module, as `foo.sh` files loaded with
  `writeShellApplication { text = builtins.readFile ./scripts/foo.sh; }`. Keep Nix interpolation
  out of the `.sh` file: pass tools through `runtimeInputs` and store paths through `runtimeEnv`.
  Start each file with `# shellcheck shell=bash` (no shebang: `writeShellApplication` adds it), and
  `git add` it before evaluating.

### Home Manager: base → profile → host

Home Manager runs **as a NixOS module**, wired by `modules/nixos/home-manager.nix` (part of the
NixOS `base`): `useGlobalPkgs`, `extraSpecialArgs = {inputs, homeModules}`, and
`home-manager.users.muhammad.imports = [homeModules.base hosts/<host>/home.nix]`. One
`nilla os switch` activates system + home together. (`generators.home` is *not* used — it builds
standalone HM configs.)

1. **`base`** (`modules/home/base.nix`, every host, automatic) — user, stateVersion, core `cli`
   (direnv/fastfetch/fzf/fish/git; `infra` is deliberately not in the `cli` barrel).
2. **profile** (`modules/home/profiles/*.nix`) — `workstation` = `apps` + `ai` + `infra` + `gtk` +
   `hyprland`, shared by desktop and laptop. Add a new profile file for a new role rather than
   adding conditionals.
3. **host** (`hosts/<host>/home.nix`) — picks a profile and adds host-only modules/overrides.

Host-unique config: an app only one host wants → import `homeModules.<app>` from that host (and drop
it from the `apps` barrel if others shouldn't get it); same app with different settings → a host file
that sets extra options (merges, like `hosts/*/hyprland.nix`); override a shared value → `mkDefault`
in the shared module; hardware-dependent → read `osConfig` (as `vscode.nix` does for CUDA).

### Key module groups

**NixOS (`modules/nixos/`):** `base` (nix + user + home-manager, every host), `system`
(boot/locale + sound/network/bluetooth/printer barrel), `hardware/*`, `desktop/{hyprland,fonts,polkit,plymouth}`, login: `sddm` (laptop) or `autologin` (desktop: greetd logs straight into Hyprland, hyprlock locks it at once; tuigreet after logout), `controllerUnlock` (desktop: gamepad types a PIN, set with `set-lock-pin`, that hyprlock accepts besides the password; only while tty1 is the foreground VT, so a background hyprlock doesn't take the gamepad from the gaming session), `gaming` (steam/heroic/hookshot/gaming-mode — `gaming-mode` (the "Gaming Mode" launcher entry toggles it) is a SteamOS-style Gaming Mode: desktop Steam swapped for `steam -gamepadui -steamos3` in fullscreen nested gamescope, also the desktop's Sunshine "Gaming Mode" app on the headless output; `gaming-session` (`gamingSession`, imported by the desktop after `gaming`; launcher entry "Gaming Mode (TV session)") is the same UI as its own session, like SteamOS: `gaming-session.service` runs gamescope on the DRM backend as the compositor of tty2 (a pam_systemd login session, `chvt 2`/`chvt 1` around it, `autovt@tty2` off, polkit lets the user start/stop the unit) while Hyprland stays logged in on tty1; `scripts/gaming-session.sh` (in Hyprland) stops the desktop Steam, records the TV's mode, `systemctl start --wait`s the unit, then restores Steam; `scripts/gaming-session-run.sh` (the unit's main process) relaunches gamescope after a crash and SIGKILLs it 3 s after Steam leaves (it hangs in libseat on exit), and sources `~/.config/gaming-session/overrides.sh` (trial knob for `gamescope_args`) if present; `gamescope-nvidia-gbm-scanout.patch` (farnoy's fork, gamescope#2309) + `gamescope_drm_gbm_scanout=1` allocate scanout buffers with GBM, without which NVIDIA shows corrupted output at 4K (small cursor-sized buffers still fail GBM and fall back to Vulkan: log noise only); `scripts/steam-ui-watchdog.sh` (started by it) SIGKILLs a hung Big Picture renderer (Steam CEF bug after a quick game quit) so Steam reloads its UI, and restarts steamwebhelper if CEF fell back to software compositing (GPU process crash); `scripts/gaming-mode-vrr.sh` makes Steam's "Enable VRR" toggle switch Hyprland's `misc:vrr` (nested gamescope can't; `gamescope-nested-vrr-capable.patch` + `GAMESCOPE_NESTED_VRR_CAPABLE=1` make Steam offer it); SteamOS's session env (from CachyOS's gamescope-session fork: scaling filters, mangoapp presets, links to Steam's browser via `~/.config/gamescope-mimeapps.list`) and a `steamos-select-branch` stub in Steam's FHS env; `gaming-browser` = Chromium wrapper for Gaming Mode, added to Steam as a non-Steam game: forced X11 so it opens inside gamescope, `--disable-gpu-sandbox` so Steam's injected overlay doesn't crash its GPU process, own profile, screen-sized and TV-scaled; `decky-loader` (not in the barrel; registered as `deckyLoader`, imported by the desktop only) = Decky Loader (plugins in ~/homebrew) from Jovian-NixOS's standalone module/package only; Hookshot is not packaged, `hookshot.nix` only enables AppImage binfmt + nix-ld so its self-updating builder and the game it builds run), `secrets` (sops-nix), `virtualisation` (docker), `quickemu` (desktop VMs), `nordvpn`, `tailscale`,
`ssh` (key-only OpenSSH + authorized key), `odesc` (ODESC/STM32 DFU udev rules),
`binaryCache` (Harmonia on the desktop) / `desktopCache` (laptop + server download from it).

**Home Manager (`modules/home/`):** `base`, `profiles/workstation`, `ai` (claude/opencode/pi/qwen-code/t3code, each also exported individually), `apps` (Firefox/Zen/Obsidian/
Blender/…, each also exported individually), `cli` (+ `infra`), `gtk` (Colloid-Dark + Bibata),
`hyprland`.

### Notable inputs (pins)

`nilla` / `nilla-utils` — framework; `hyprland` / `hyprland-plugins`;
`home-manager`; `nixos-hardware`; `nix-gaming`; `sops-nix`; `zen-browser`;
`spotifast` (native Spotify client); `llm-agents` (numtide/llm-agents.nix: every AI agent in `modules/home/ai`, used as a flake via `.result.packages` so builds come from `cache.numtide.com`); `blender-bin` (Blender overlay, pinned at the `blender` subdir of edolstra/nix-warez). `jovian`
(Jovian-NixOS, `development` branch): only `modules/decky-loader.nix` and `pkgs/decky-loader` are
used, via `inputs.jovian.src`, never its flake/overlay (that would swap in its SteamOS Steam/gamescope).
