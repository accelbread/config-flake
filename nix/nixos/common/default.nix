{ config, pkgs, lib, inputs, hostname, ... }:
let
  inherit (inputs) self;
  inherit (builtins) mapAttrs;
in
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
    self.nixosModules.bind-fonts-icons
    self.nixosModules.tpm2-tss-fapi
    ./kernel.nix
    ./desktop.nix
    ./disks
  ];

  nixpkgs.overlays = with inputs; [
    self.overlays.overrides
    emacs-overlay.overlays.package
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
    lanzaboote = {
      enable = pkgs.system == "x86_64-linux";
      pkiBundle = "/persist/vault/secureboot";
    };
    loader = {
      systemd-boot = {
        enable = !config.boot.lanzaboote.enable;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      preDeviceCommands = ''
        echo "[1;36m"
        echo Hello, this is ${hostname}.
        echo Owner: Archit Gupta
        echo Email: accelbread@gmail.com
        echo "[0m"
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
      wifi.macAddress = "random";
      ethernet.macAddress = "stable";
    };
    firewall = {
      checkReversePath = "loose";
      allowedUDPPorts = [ config.services.tailscale.port ];
      interfaces."tailscale0".allowedTCPPorts = [ 22 ];
    };
    search = [ "fluffy-bebop.ts.net" ];
  };

  time.timeZone = "America/Los_Angeles";

  location.provider = "geoclue2";

  security = {
    sudo.extraConfig = "Defaults lecture = never";
    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
    pam.mount.fuseMountOptions = [ "noatime" "nosuid" "nodev" ];
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
        forwarding_rules = pkgs.writeText "forwarding-rules.txt" ''
          ts.net 100.100.100.100
        '';
      };
    };
    logind = {
      lidSwitch = "hibernate";
      killUserProcesses = true;
    };
    usbguard = {
      enable = true;
      IPCAllowedGroups = [ "wheel" ];
    };
    avahi = {
      enable = true;
      nssmdns = true;
    };
    udev.packages = with pkgs; [ r8152-udev-rules ];
    tailscale.enable = true;
    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        PermitRootLogin = "no";
        AllowGroups = [ "users" ];
        AuthenticationMethods = "publickey";
        PasswordAuthentication = false;
        ChallengeResponseAuthentication = false;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
        AllowTcpForwarding = false;
        AllowAgentForwarding = false;
        AllowStreamLocalForwarding = false;
        TrustedUserCAKeys = "${self + /misc/ssh_ca_user_key.pub}";
        HostCertificate = "/persist/vault/ssh_host_ed25519_key-cert.pub";
        ClientAliveInterval = 15;
      };
      hostKeys = [{
        path = "/persist/vault/ssh_host_ed25519_key";
        type = "ed25519";
      }];
    };
  };

  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-extra
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];
  };

  users = {
    mutableUsers = false;
    users.archit = {
      isNormalUser = true;
      description = "Archit Gupta";
      extraGroups = [ "wheel" "networkmanager" "tss" ];
      uid = 1000;
      hashedPasswordFile = "/persist/vault/user_pass";
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
        "/var/lib/tailscale"
      ];
      files = [ "/etc/machine-id" ];
    };
    defaultPackages = with pkgs; [ zile git ];
    systemPackages = lib.singleton (pkgs.sbctl.override {
      databasePath = "/persist/vault/secureboot";
    });
    gnome.excludePackages = [ pkgs.gnome-tour ];
    variables.EDITOR = "zile";
    sessionVariables.TPM2_PKCS11_LOG_LEVEL = "0";
  };

  programs = {
    nano.enable = false;
    bash.interactiveShellInit = ''
      HISTCONTROL=ignoreboth
    '';
    ssh = {
      knownHosts."*" = {
        publicKeyFile = self + /misc/ssh_ca_host_key.pub;
        certAuthority = true;
      };
      extraConfig = ''
        PKCS11Provider /run/current-system/sw/lib/libtpm2_pkcs11.so
        CertificateFile ~/.ssh/ssh-cert.pub
        StrictHostKeyChecking yes
        VerifyHostKeyDNS ask
        UpdateHostKeys ask
      '';
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
}
