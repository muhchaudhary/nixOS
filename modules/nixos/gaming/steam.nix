{
  pkgs,
  inputs,
  ...
}: let
  # GameMode's start/end hook (run as root through pkexec): CPU energy
  # performance preference to `performance` for the game, then back to what
  # it was (balance_performance by default; on the laptop whatever its power
  # management set). No-op on CPUs without EPP.
  cpuEpp = pkgs.writeShellScript "gamemode-cpu-epp" ''
    set -eu
    saved=/run/gamemode-cpu-epp
    shopt -s nullglob
    files=(/sys/devices/system/cpu/cpu[0-9]*/cpufreq/energy_performance_preference)
    [ ''${#files[@]} -gt 0 ] || exit 0
    case "''${1:-}" in
      start)
        [ -e "$saved" ] || cat "''${files[0]}" >"$saved"
        for f in "''${files[@]}"; do echo performance >"$f"; done
        ;;
      end)
        [ -e "$saved" ] || exit 0
        epp=$(cat "$saved")
        for f in "''${files[@]}"; do echo "$epp" >"$f"; done
        rm -f "$saved"
        ;;
      *) exit 2 ;;
    esac
  '';
in {
  # Provides programs.steam.platformOptimizations.
  imports = [inputs.nix-gaming.result.nixosModules.platformOptimizations];

  programs.gamemode = {
    enable = true;
    settings = {
      # Leave the governor alone: on amd-pstate-epp, gamemode's switch to
      # `performance` and back leaves the EPP at `performance` until reboot.
      # Set the EPP directly instead, and put back whatever it was.
      general = {
        desiredgov = "powersave";
        defaultgov = "powersave";
      };
      custom = {
        start = "/run/wrappers/bin/pkexec ${cpuEpp} start";
        end = "/run/wrappers/bin/pkexec ${cpuEpp} end";
      };
    };
  };
  # Only this helper, only for the active local session, without a password.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.policykit.exec" &&
          action.lookup("program") == "${cpuEpp}" &&
          subject.local && subject.active && subject.isInGroup("gamemode")) {
        return polkit.Result.YES;
      }
    });
  '';
  # SDL2 on SDL3 (sdl2-compat) at a fixed path, for native games that bundle
  # an old SDL2: their SDL2 hands every call over to it with the launch option
  # `SDL_DYNAMIC_API=/etc/sdl2-compat/libSDL2-2.0.so.0 %command%`. Newer
  # controller support, e.g. gyro from the GameSir C2 (SInput) with Steam
  # Input off (Longshot).
  environment.etc."sdl2-compat/libSDL2-2.0.so.0".source = "${pkgs.sdl2-compat}/lib/libSDL2-2.0.so.0";

  programs.gamescope.enable = true;
  users.users.muhammad.extraGroups = ["gamemode"];
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    localNetworkGameTransfers.openFirewall = true;
    extest.enable = true;
    protontricks.enable = true;
    platformOptimizations.enable = true;
  };
}
