# WiFi hotspot routed through WireGuard (wg0), via linux-router.
#
# Previously an opt-in `internal.services.wgHotspot` module with tunables; now a
# plain module carrying the former defaults inline. It is not imported by any
# host by default — a host that wants the hotspot imports this file. To retune
# (SSID, band, upstream iface, passphrase path, …) edit the `let` bindings below.
{
  lib,
  pkgs,
  ...
}:
with lib; let
  ssid = "muhammadAP";
  passwordFile = "/etc/hostapd/ap.psk";
  gateway = "10.42.0.1";
  # Built-in WiFi interface used as the parent radio for the AP virtual iface.
  upstream = "wlan0";
  # WireGuard interface to route hotspot traffic through.
  wgInterface = "wg0";
  autoStart = true;
  # NB: ath11k cards (e.g. WCN685x) self-manage regulatory and refuse AP on 5 GHz —
  # keep "2.4" unless you've confirmed your card permits AP-mode IR on 5 GHz.
  band = "2.4";
  # 0 = let lnxrouter pick (1 on 2.4, 36 on 5). On 2.4, prefer 1/6/11.
  channel = 0;
  country = "CA";
  enableAC = true; # 802.11ac (VHT); only takes effect on 5 GHz.
  enableAX = true; # 802.11ax (Wi-Fi 6); helps modern clients on 2.4 too.
  extraArgs = [];
in {
  environment.systemPackages = with pkgs; [linux-router iw];

  # Hotspot requires wg0; force it to autostart so the dependency is satisfiable at boot.
  networking.wg-quick.interfaces.${wgInterface}.autostart = mkForce true;

  # wg-quick resolves the peer endpoint via DNS at start; make sure the network is actually online first.
  systemd.services."wg-quick-${wgInterface}" = {
    after = ["network-online.target" "nss-lookup.target" "NetworkManager-wait-online.service"];
    wants = ["network-online.target" "nss-lookup.target"];
  };
  systemd.services.NetworkManager-wait-online.enable = true;

  # Open hotspot subnet on the AP virtual interface (DHCP + DNS via dnsmasq from linux-router).
  # lnxrouter names the iface x0<upstream> when --no-virt is not passed.
  networking.firewall.interfaces."x0${upstream}" = {
    allowedUDPPorts = [53 67];
    allowedTCPPorts = [53];
  };
  networking.networkmanager.unmanaged = ["interface-name:x0${upstream}"];

  # Kernel forwarding for the NAT path.
  boot.kernel.sysctl."net.ipv4.ip_forward" = mkDefault 1;

  # Ensure the wireless regulatory database is loaded and pin the country at boot,
  # so the AP can advertise 5 GHz at full power without needing late-stage `iw reg set`.
  hardware.wirelessRegulatoryDatabase = true;
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=${country}
  '';

  systemd.services.wg-hotspot = {
    description = "WireGuard-routed WiFi Hotspot (linux-router)";
    after = ["wg-quick-${wgInterface}.service" "NetworkManager.service"];
    requires = ["wg-quick-${wgInterface}.service"];
    bindsTo = ["wg-quick-${wgInterface}.service"];
    wantedBy = optional autoStart "multi-user.target";

    path = with pkgs; [linux-router iw iproute2 hostapd dnsmasq iptables coreutils gawk];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
    };

    preStart = ''
      if [ ! -r ${passwordFile} ]; then
        echo "Missing passphrase file: ${passwordFile}" >&2
        exit 1
      fi
      # Fail-closed: drop any forwarded packet from the hotspot that is NOT exiting via wg.
      # lnxrouter names the AP virtual iface x0<upstream>, so match that.
      iptables -C FORWARD -i x0${upstream} ! -o ${wgInterface} -j DROP 2>/dev/null \
        || iptables -I FORWARD 1 -i x0${upstream} ! -o ${wgInterface} -j DROP
      # MSS clamping: prevent fragmentation collapse for TCP flows entering wg0 (MTU 1420).
      # Without this, hotspot clients on 1500-MTU links produce oversize packets that fragment
      # and throughput drops by ~10x.
      iptables -t mangle -C FORWARD -o ${wgInterface} -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null \
        || iptables -t mangle -I FORWARD 1 -o ${wgInterface} -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
    '';

    script = let
      wifi5Flags = optionalString (enableAC && band == "5") "--wifi5 --vht-ch-width 2";
      wifi6Flags = optionalString enableAX "--wifi6";
      channelFlag = optionalString (channel != 0) "-c ${toString channel}";
      extra = concatStringsSep " " (map escapeShellArg extraArgs);
    in ''
      PASS="$(tr -d '\n' < ${passwordFile})"
      exec lnxrouter \
        --ap ${upstream} ${ssid} \
        -p "$PASS" \
        -g ${gateway} \
        -o ${wgInterface} \
        --freq-band ${band} \
        --country ${country} \
        ${channelFlag} \
        --wifi4 \
        ${wifi5Flags} \
        ${wifi6Flags} \
        --no-haveged \
        ${extra}
    '';

    postStop = ''
      iptables -D FORWARD -i x0${upstream} ! -o ${wgInterface} -j DROP 2>/dev/null || true
      iptables -t mangle -D FORWARD -o ${wgInterface} -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null || true
    '';
  };
}
