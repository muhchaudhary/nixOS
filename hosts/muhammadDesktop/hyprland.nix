# Desktop-specific hypridle timings (+ the TV's HDMI audio fix after sleep), monitor layout and per-monitor lock screen. The base Hyprland home
# module (modules/home/hyprland) already enables hypridle and
# sets settings.general; this only adds the listeners (module options merge).
{
  pkgs,
  hyprlockWidgets,
  ...
}: let
  # After a suspend the 3090's HDMI audio (the TV) plays silence until the
  # card's profile is switched away and back (what pwvucontrol's
  # HDMI -> DisplayPort -> HDMI does by hand). The garbling that came with it
  # is handled by the headroom rule in configuration.nix.
  hdmiAudioKick = pkgs.writeShellApplication {
    name = "hdmi-audio-kick";
    runtimeInputs = with pkgs; [pipewire wireplumber jq coreutils];
    text = ''
      card=alsa_card.pci-0000_06_00.1
      # Give the HDMI link a moment to come back, and PipeWire the card.
      sleep 3
      for _ in $(seq 20); do
        read -r id current other < <(pw-dump | jq -r --arg c "$card" '
          first(.[] | select(.info.props."device.name"? == $c)) as $d
          | ($d.info.params.Profile[0].index) as $cur
          | [$d.id, $cur,
             (first($d.info.params.EnumProfile[]
                | select(.index != $cur and .index != 0 and .available == "yes"
                         and (.name | startswith("output:"))) | .index) // "")]
          | @tsv') || true
        [ -n "''${id:-}" ] && break
        sleep 0.5
      done
      [ -n "''${id:-}" ] && [ -n "''${other:-}" ] || exit 0
      # Switching profiles recreates the sink, and WirePlumber then picks
      # another default; put the user's back.
      default=$(pw-dump | jq -r '.[] | select(.type == "PipeWire:Interface:Metadata" and .props."metadata.name" == "default") | .metadata[] | select(.key == "default.audio.sink") | .value.name')
      wpctl set-profile "$id" "$other"
      sleep 1
      wpctl set-profile "$id" "$current"
      for _ in $(seq 20); do
        sink=$(pw-dump | jq -r --arg n "$default" 'first(.[] | select(.info.props."node.name"? == $n) | .id) // ""')
        [ -n "$sink" ] && break
        sleep 0.25
      done
      if [ -n "$sink" ]; then wpctl set-default "$sink"; fi
    '';
  };

  # Lock screen per monitor: the LG as usual, the TV (couch distance, and
  # likely typed on from a controller) the same layout at twice the size.
  dp = hyprlockWidgets {monitor = "DP-1";};
  tv = hyprlockWidgets {
    monitor = "HDMI-A-1";
    scale = 2;
  };
in {
  programs.hyprlock.settings = {
    label = dp.label ++ tv.label;
    input-field = dp.input-field ++ tv.input-field;
  };

  services.hypridle.settings.general.after_sleep_cmd = "${hdmiAudioKick}/bin/hdmi-audio-kick";

  services.hypridle.settings.listener = [
    {
      timeout = 200;
      on-timeout = "loginctl lock-session";
    }
    {
      timeout = 500;
      on-timeout = "hyprctl dispatch dpms off";
      on-resume = "hyprctl dispatch dpms on";
    }
    {
      timeout = 2500;
      on-timeout = "systemctl suspend";
    }
  ];

  xdg.configFile."hypr/monitors.lua".source = ./hypr/monitors.lua;
}
