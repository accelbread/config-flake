{ config, lib, pkgs, flakes, hostname, ... }: {
  imports = [ flakes.nixos-hardware.nixosModules.raspberry-pi-4 ];

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_rpi4;
    loader.systemd-boot.enable = lib.mkForce false;
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

  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree.overlays = [
      {
        name = "spi";
        dtsText = ''
          /dts-v1/;
          /plugin/;

          / {
            compatible = "raspberrypi";
            fragment@0 {
              target = <&spi>;
              __overlay__ {
                cs-gpios = <&gpio 8 1>, <&gpio 7 1>;
                status = "okay";
                pinctrl-names = "default";
                pinctrl-0 = <&spi0_pins &spi0_cs_pins>;
                #address-cells = <1>;
                #size-cells = <0>;
                spidev@0 {
                  reg = <0>;  // CE0
                  spi-max-frequency = <500000>;
                  compatible = "spidev";
                };

                spidev@1 {
                  reg = <1>;  // CE1
                  spi-max-frequency = <500000>;
                  compatible = "spidev";
                };
              };
            };
                  fragment@1 {
              target = <&alt0>;
              __overlay__ {
                // Drop GPIO 7, SPI 8-11
                brcm,pins = <4 5>;
              };
            };

            fragment@2 {
              target = <&gpio>;
              __overlay__ {
                spi0_pins: spi0_pins {
                  brcm,pins = <9 10 11>;
                  brcm,function = <4>; // alt0
                };
                spi0_cs_pins: spi0_cs_pins {
                  brcm,pins = <8 7>;
                  brcm,function = <1>; // out
                };
              };
            };
          };
        '';
      }
      {
        name = "letstrust-tpm";
        dtsText = ''
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
      }
    ];
  };
}
