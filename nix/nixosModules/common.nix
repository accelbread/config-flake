{ config, pkgs, lib, inputs, hostname, ... }:
let
  inherit (inputs) self;
  inherit (builtins) mapAttrs substring hashString;
in
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    inputs.lanzaboote.nixosModules.lanzaboote
    self.nixosModules.bind-fonts-icons
    self.nixosModules.tpm2-tss-fapi
    self.nixosModules.kernel
    self.nixosModules.disks
    self.nixosModules.tailscale
  ];

  system.configurationRevision = self.rev or null;

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
      pkiBundle = "/persist/state/secureboot";
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
      postResumeCommands = lib.mkBefore ''
        mkdir -p /mnt
        mount -t btrfs -o noatime,compress=zstd /dev/${hostname}_vg1/pool /mnt
        ${lib.getExe pkgs.btrfs-subvol-rm-r} /mnt/root
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
    nftables.enable = true;
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
    pam = {
      services = lib.genAttrs [ "login" "systemd-user" "sshd" ] (_: {
        rules.session.umask = {
          order = 0;
          control = "optional";
          modulePath = "pam_umask.so";
        };
      });
      mount.fuseMountOptions = [ "noatime" "nosuid" "nodev" ];
    };
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
    services = {
      systemd-time-wait-sync.wantedBy = [ "sysinit.target" ];
      sshd.serviceConfig = {
        IPAddressAllow = "localhost 100.64.0.0/10";
        IPAddressDeny = "any";
      };
      # Remove when nixpkgs package is updated
      colord.serviceConfig = {
        ConfigurationDirectory = "colord";
        StateDirectory = "colord";
        CacheDirectory = "colord";
        RestrictAddressFamilies = "";
      };
    };
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
      nssmdns4 = true;
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
        HostCertificate = "/persist/state/sshd/ssh_host_ed25519_key-cert.pub";
        ClientAliveInterval = 15;
      };
      hostKeys = [{
        path = "/persist/state/sshd/ssh_host_ed25519_key";
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
      hashedPasswordFile = "/persist/state/system/user_pass";
    };
  };

  environment = {
    etc.machine-id.text = substring 0 32
      (hashString "sha256" "accelbread-${hostname}");
    persistence."/persist/cache".directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
      "/var/log"
      "/var/lib/systemd/coredump"
      "/var/lib/systemd/timesync"
      "/var/lib/tailscale"
    ];
    defaultPackages = with pkgs; [ zile git ];
    systemPackages = lib.singleton (pkgs.sbctl.override {
      databasePath = "/persist/state/secureboot";
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
