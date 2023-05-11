{ config, pkgs, lib, inputs, hostname, ... }:
let
  inherit (inputs) self;
  inherit (builtins) mapAttrs;
in
{
  imports = [
    ./usbguard-dbus.nix
    ./flatpak-fonts.nix
    ./desktop.nix
    ./disks
  ];

  nixpkgs.overlays = with inputs; [
    self.overlays.overrides
    emacs-overlay.overlays.default
    nixgl.overlays.default
    self.overlays.default
  ];

  nix = {
    registry = mapAttrs (_: v: { flake = v; }) inputs;
    nixPath =
      lib.mapAttrsToList (k: v: "${k}=${v.to.path}") config.nix.registry;
    settings = {
      experimental-features = "nix-command flakes";
      allowed-users = [ "@wheel" ];
      auto-optimise-store = true;
    };
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = {
      "kernel.kptr_restrict" = "2";
      "kernel.yama.ptrace_scope" = "1";
      "net.core.bpf_jit_enable" = false;
      "kernel.ftrace_enabled" = false;
    };
    initrd = {
      preDeviceCommands = ''
        message="\
        Hello, this is ${hostname}.
        Owner: Archit Gupta
        Email: accelbread@gmail.com
        "
        printf "$message" | ${pkgs.cowsay}/bin/cowsay -n
      '';
      postDeviceCommands = lib.mkAfter ''
        # We need to attempt to resume before wiping root
        echo Attempting resume...
        if test -e /sys/power/resume -a -e /sys/power/disk; then
          resumeDevices=${toString (map (s: s.device) config.swapDevices)}
          for sd in $resumeDevices; do
            if waitDevice "$sd"; then
              resumeInfo="$(udevadm info -q property "$sd")"
              if [ "$(echo "$resumeInfo" | \
                  sed -n 's/^ID_FS_TYPE=//p')" = "swsuspend" ]; then
                resumeDev="$sd"
                break
              fi
            fi
          done
          if test -n "$resumeDev"; then
            resumeMajor="$(echo "$resumeInfo" | sed -n 's/^MAJOR=//p')"
            resumeMinor="$(echo "$resumeInfo" | sed -n 's/^MINOR=//p')"
            echo "$resumeMajor:$resumeMinor" \
                > /sys/power/resume 2> /dev/null || echo "Failed to resume..."
          fi
        fi

        mkdir -p /mnt
        mount -t btrfs -o noatime,compress=zstd /dev/${hostname}_vg1/pool /mnt
        ${
          pkgs.writeShellApplication {
            name = "btrfs-subvol-rm-r";
            runtimeInputs = with pkgs; [ btrfs-progs gawk gnused ];
            text = builtins.readFile (self + /scripts/btrfs-subvol-rm-r);
          }
        }/bin/btrfs-subvol-rm-r /mnt/root
        btrfs subvolume create /mnt/root
        umount /mnt
      '';
    };
    tmp.useTmpfs = true;
  };

  hardware = {
    firmware = [ pkgs.linux-firmware ];
    rasdaemon.enable = true;
    pulseaudio.enable = false;
    i2c.enable = true;
  };

  networking = {
    hostName = hostname;
    networkmanager = {
      enable = true;
      dns = "none";
    };
  };

  time.timeZone = "America/Los_Angeles";

  location.provider = "geoclue2";

  security = {
    sudo = {
      extraConfig = "Defaults lecture = never";
      execWheelOnly = true;
    };
    tpm2 = {
      enable = true;
      pkcs11 = {
        enable = true;
        package = pkgs.tpm2-pkcs11.overrideAttrs (old: {
          configureFlags = old.configureFlags or [ ]
            ++ [ "--enable-fapi=no" ];
        });
      };
      tctiEnvironment.enable = true;
    };
    apparmor.enable = true;
    forcePageTableIsolation = true;
    rtkit.enable = true;
  };

  virtualisation.containers = {
    enable = true;
    storage.settings.storage.driver = "btrfs";
  };

  documentation.man.generateCaches = true;

  systemd = {
    sleep.extraConfig = "HibernateDelaySec=10m";
    additionalUpstreamSystemUnits = [ "systemd-time-wait-sync.service" ];
    services.systemd-time-wait-sync.wantedBy = [ "sysinit.target" ];
  };

  services = {
    fwupd.enable = true;
    dnscrypt-proxy2 = {
      enable = true;
      settings = {
        ipv6_servers = true;
        doh_servers = false;
        require_dnssec = true;
        dnscrypt_ephemeral_keys = true;
        tls_disable_session_tickets = true;
      };
    };
    logind = {
      lidSwitch = "hibernate";
      killUserProcesses = true;
    };
    usbguard = {
      enable = true;
      dbus.enable = true;
      IPCAllowedGroups = [ "wheel" ];
    };
    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        userServices = true;
      };
    };
    udev.packages = with pkgs; [ r8152-udev-rules ];
  };

  fonts = {
    enableDefaultFonts = false;
    fonts = with pkgs; [
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-extra
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
  };

  users = {
    mutableUsers = false;
    users.archit = {
      isNormalUser = true;
      description = "Archit Gupta";
      extraGroups = [ "wheel" "networkmanager" "tss" "dialout" "wireshark" ];
      uid = 1000;
      passwordFile = "/persist/vault/user_pass";
    };
  };

  environment = {
    persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/bluetooth"
        "/var/log"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/timesync"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
    defaultPackages = with pkgs; [ zile git ];
    gnome.excludePackages = [ pkgs.gnome-tour ];
    localBinInPath = true;
    variables.EDITOR = "zile";
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
}
