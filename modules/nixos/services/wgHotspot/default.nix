{
  lib,
  pkgs,
  namespace,
  config,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.services.wgHotspot;
in {
  options.${namespace}.services.wgHotspot = {
    enable = mkBoolOpt false "Whether to enable a WiFi hotspot routed through wg0.";
    ssid = mkOpt types.str "muhammadAP" "Hotspot SSID.";
    passwordFile = mkOpt types.str "/etc/hostapd/ap.psk" "Path to file containing the WPA2 passphrase (single line, no trailing newline matters less since we strip).";
    gateway = mkOpt types.str "10.42.0.1" "Hotspot gateway/AP IP. Subnet is derived as /24.";
    upstream = mkOpt types.str "wlan0" "Built-in WiFi interface used as the parent radio for the AP virtual iface.";
    wgInterface = mkOpt types.str "wg0" "WireGuard interface to route hotspot traffic through.";
    autoStart = mkBoolOpt true "Start the hotspot automatically at boot.";
    band = mkOpt (types.enum ["2.4" "5"]) "2.4" "Radio band. NB: ath11k cards (e.g. WCN685x) self-manage regulatory and refuse AP on 5 GHz — keep 2.4 unless you've confirmed your card permits AP-mode IR on 5 GHz channels via `iw phy phy0 info`.";
    channel = mkOpt types.int 0 "AP channel. 0 = let lnxrouter pick (1 on 2.4, 36 on 5). On 2.4, prefer 1/6/11.";
    country = mkOpt types.str "CA" "Country code passed to lnxrouter. Ignored by self-managed drivers like ath11k.";
    enableAC = mkBoolOpt true "Enable 802.11ac (VHT). Only takes effect on 5 GHz.";
    enableAX = mkBoolOpt true "Enable 802.11ax (HE / Wi-Fi 6). Works on 2.4 too — helps modern clients.";
    extraArgs = mkOpt (types.listOf types.str) [] "Extra args passed to lnxrouter.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [linux-router iw];

    # Hotspot requires wg0; force it to autostart so the dependency is satisfiable at boot.
    networking.wg-quick.interfaces.${cfg.wgInterface}.autostart = mkForce true;

    # wg-quick resolves the peer endpoint via DNS at start; make sure the network is actually online first.
    systemd.services."wg-quick-${cfg.wgInterface}" = {
      after = ["network-online.target" "nss-lookup.target" "NetworkManager-wait-online.service"];
      wants = ["network-online.target" "nss-lookup.target"];
    };
    systemd.services.NetworkManager-wait-online.enable = true;

    # Open hotspot subnet on the AP virtual interface (DHCP + DNS via dnsmasq from linux-router).
    # lnxrouter names the iface x0<upstream> when --no-virt is not passed.
    networking.firewall.interfaces."x0${cfg.upstream}" = {
      allowedUDPPorts = [53 67];
      allowedTCPPorts = [53];
    };
    networking.networkmanager.unmanaged = ["interface-name:x0${cfg.upstream}"];

    # Kernel forwarding for the NAT path.
    boot.kernel.sysctl."net.ipv4.ip_forward" = mkDefault 1;

    # Ensure the wireless regulatory database is loaded and pin the country at boot,
    # so the AP can advertise 5 GHz at full power without needing late-stage `iw reg set`.
    hardware.wirelessRegulatoryDatabase = true;
    boot.extraModprobeConfig = ''
      options cfg80211 ieee80211_regdom=${cfg.country}
    '';

    systemd.services.wg-hotspot = {
      description = "WireGuard-routed WiFi Hotspot (linux-router)";
      after = ["wg-quick-${cfg.wgInterface}.service" "NetworkManager.service"];
      requires = ["wg-quick-${cfg.wgInterface}.service"];
      bindsTo = ["wg-quick-${cfg.wgInterface}.service"];
      wantedBy = optional cfg.autoStart "multi-user.target";

      path = with pkgs; [linux-router iw iproute2 hostapd dnsmasq iptables coreutils gawk];

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 5;
      };

      preStart = ''
        if [ ! -r ${cfg.passwordFile} ]; then
          echo "Missing passphrase file: ${cfg.passwordFile}" >&2
          exit 1
        fi
        # Fail-closed: drop any forwarded packet from the hotspot that is NOT exiting via wg.
        # lnxrouter names the AP virtual iface x0<upstream>, so match that.
        iptables -C FORWARD -i x0${cfg.upstream} ! -o ${cfg.wgInterface} -j DROP 2>/dev/null \
          || iptables -I FORWARD 1 -i x0${cfg.upstream} ! -o ${cfg.wgInterface} -j DROP
        # MSS clamping: prevent fragmentation collapse for TCP flows entering wg0 (MTU 1420).
        # Without this, hotspot clients on 1500-MTU links produce oversize packets that fragment
        # and throughput drops by ~10x.
        iptables -t mangle -C FORWARD -o ${cfg.wgInterface} -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null \
          || iptables -t mangle -I FORWARD 1 -o ${cfg.wgInterface} -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
      '';

      script = let
        wifi5Flags = optionalString (cfg.enableAC && cfg.band == "5") "--wifi5 --vht-ch-width 2";
        wifi6Flags = optionalString cfg.enableAX "--wifi6";
        channelFlag = optionalString (cfg.channel != 0) "-c ${toString cfg.channel}";
        extra = concatStringsSep " " (map escapeShellArg cfg.extraArgs);
      in ''
        PASS="$(tr -d '\n' < ${cfg.passwordFile})"
        exec lnxrouter \
          --ap ${cfg.upstream} ${cfg.ssid} \
          -p "$PASS" \
          -g ${cfg.gateway} \
          -o ${cfg.wgInterface} \
          --freq-band ${cfg.band} \
          --country ${cfg.country} \
          ${channelFlag} \
          --wifi4 \
          ${wifi5Flags} \
          ${wifi6Flags} \
          --no-haveged \
          ${extra}
      '';

      postStop = ''
        iptables -D FORWARD -i x0${cfg.upstream} ! -o ${cfg.wgInterface} -j DROP 2>/dev/null || true
        iptables -t mangle -D FORWARD -o ${cfg.wgInterface} -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null || true
      '';
    };
  };
}
