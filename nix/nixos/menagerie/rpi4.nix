{ config, pkgs, lib, inputs, ... }: {
  imports = [ inputs.nixos-hardware.nixosModules.raspberry-pi-4 ];

  boot.loader.generic-extlinux-compatible.enable = false;

  # DNSCrypt-proxy needs NTP which needs DNS; use public resolver for boot
  networking.nameservers = [ "1.1.1.1" ];

  systemd.services.enable-local-resolver =
    assert config.networking.resolvconf.enable; {
      description = "Set DNS resolver to localhost";
      after = [ "time-sync.target" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        ${pkgs.openresolv}/sbin/resolvconf -m 1 -a static <<EOF
        nameserver 127.0.0.1
        EOF
      '';
    };

  networking.enableIPv6 = false;
}

