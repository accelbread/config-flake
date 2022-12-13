{ config, lib, pkgs, flakes, hostname, ... }: {
  imports = [ flakes.nixos-hardware.nixosModules.raspberry-pi-4 ];

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_rpi4;
    loader.generic-extlinux-compatible.enable = false;
    initrd.kernelModules = [ "tpm_tis_spi" ];
  };

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

  services.home-assistant = {
    enable = true;
    configDir = "/persist/config/hass";
    openFirewall = true;
    configWritable = true;
    config = {
      http.server_host = [ "0.0.0.0" ];
      homeassistant = {
        name = "Archit Home";
        internal_url = "http://${hostname}.local:8123";
      };
      automation = "!include automations.yaml";
      scene = "!include scenes.yaml";
      script = "!include scripts.yaml";
      dhcp = { };
      zeroconf = { };
      sun = { };
      schedule = { };
      config = { };
      frontend = { };
      history = { };
      image = { };
      logbook = { };
      mobile_app = { };
    };
  };

  hardware.deviceTree.overlays = [{
    name = "letstrust-tpm-overlay";
    dtsText = ''
      /*
       * Device Tree overlay for the LetsTrust TPM (Infineon SLB9670) for the RPI
       *
       */

      /dts-v1/;
      /plugin/;

      / {
        compatible = "brcm,bcm2835", "brcm,bcm2708", "brcm,bcm2709";

        fragment@0 {
          target = <&spi0>;
          __overlay__ {
            status = "okay";
          };
        };

        fragment@1 {
          target = <&spidev1>;
          __overlay__ {
            status = "disabled";
          };
        };

        fragment@2 {
          target = <&spi0>;
          __overlay__ {
            /* needed to avoid dtc warning */
            #address-cells = <1>;
            #size-cells = <0>;

            slb9670: slb9670@0{
              compatible = "infineon,slb9670";
              reg = <1>;  /* CE1 */
              #address-cells = <1>;
              #size-cells = <0>;
              spi-max-frequency = <32000000>;
              status = "okay";
            };

          };
        };
      };
    '';
  }];
}
