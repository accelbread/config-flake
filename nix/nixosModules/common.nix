{ config, options, pkgs, lib, inputs, hostname, ... }:
let
  inherit (inputs) self;
  inherit (builtins) mapAttrs substring hashString;

  machine-id = substring 0 32 (hashString "sha256" "accelbread-${hostname}");
in
{
  imports = [
    inputs.preservation.nixosModules.preservation
    inputs.lanzaboote.nixosModules.lanzaboote
    self.nixosModules.lix
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
      timeout = 0;
      systemd-boot = {
        enable = !config.boot.lanzaboote.enable;
        editor = false;
        configurationLimit = 120;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd.systemd = {
      enable = true;
      contents."/etc/machine-id".text = machine-id;
      storePaths = with pkgs;
        [
          coreutils
          util-linux
          btrfs-progs
          btrfs-subvol-rm-r
          bash
          gawk
          gnused
        ];
      services.wipe-root-subvolume = {
        wantedBy = [ "initrd.target" ];
        requires = [ "local-fs-pre.target" "initrd-root-device.target" ];
        after = [ "local-fs-pre.target" "initrd-root-device.target" ];
        before = [ "sysroot.mount" "create-needed-for-boot-dirs.service" ];
        unitConfig.DefaultDependencies = false;
        serviceConfig.Type = "oneshot";
        script = with pkgs; ''
          ${coreutils}/bin/mkdir -p /mnt
          ${util-linux}/bin/mount -t btrfs -o noatime,compress=zstd \
            /dev/${hostname}_vg1/pool /mnt
          ${lib.getExe btrfs-subvol-rm-r} /mnt/root
          ${btrfs-progs}/bin/btrfs subvolume create /mnt/root
          ${util-linux}/bin/umount /mnt
        '';
      };
    };
  };

  hardware = {
    firmware = [ pkgs.linux-firmware ];
    rasdaemon.enable = true;
    i2c.enable = true;
  };

  networking = {
    hostName = hostname;
    networkmanager = {
      enable = true;
      dns = "none";
      wifi.macAddress = "random";
      ethernet.macAddress = "random";
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
    suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];
    tpm2.enable = false;
    services = {
      systemd-time-wait-sync.wantedBy = [ "sysinit.target" ];
      NetworkManager-wait-online.serviceConfig.ExecStart =
        [ "" "${pkgs.networkmanager}/bin/nm-online -q" ];
      sshd.serviceConfig = {
        IPAddressAllow = "localhost 100.64.0.0/10";
        IPAddressDeny = "any";
      };
      colord.path = [ pkgs.argyllcms ];
    };
    tmpfiles.settings.preservation =
      (lib.flip lib.genAttrs
        (k: { d = { user = "root"; group = "root"; mode = "0700"; }; }) [
        "/etc/NetworkManager"
      ]) //
      (lib.flip lib.genAttrs
        (k: { d = { user = "root"; group = "root"; mode = "0755"; }; }) [
        "/etc"
      ])
    ;
  };

  services = {
    fwupd.enable = true;
    pulseaudio.enable = false;
    dnscrypt-proxy = {
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
    logind.settings.Login = {
      HandleLidSwitch = "hibernate";
      KillUserProcesses = true;
    };
    usbguard = {
      enable = true;
      IPCAllowedGroups = [ "wheel" ];
    };
    avahi.enable = false;
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
    printing.enable = false;
    bpftune.enable = true;
  };

  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      liberation_ttf
      gyre-fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
    ];
    fontDir.decompressFonts = true;
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "Adwaita Sans" ];
        serif = [ "Noto Serif" ];
        monospace = [ "Adwaita Mono" ];
      };
      useEmbeddedBitmaps = true;
    };
  };

  users = {
    mutableUsers = false;
    users.archit = {
      isNormalUser = true;
      description = "Archit Gupta";
      extraGroups = [ "wheel" "networkmanager" ];
      uid = 1000;
      hashedPasswordFile = "/persist/state/system/user_pass";
    };
  };

  environment = {
    etc.machine-id.text = machine-id;
    defaultPackages = with pkgs; [ zile git ];
    systemPackages = with pkgs; [
      lkl
      (sbctl.override {
        databasePath = "/persist/state/secureboot";
      })
    ];
    gnome.excludePackages = [ pkgs.gnome-tour ];
    variables.EDITOR = "zile";
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
        PKCS11Provider ${pkgs.yubico-piv-tool}/lib/libykcs11.so
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

  preservation = {
    enable = true;
    preserveAt = mapAttrs
      (k: v: v // {
        persistentStoragePath = "/persist/${k}";
        commonMountOptions = [ "x-gvfs-hide" "x-gdu.hide" ];
      })
      {
        state = { };
        data = { };
        cache = {
          directories = (map (d: { directory = d; mode = "0700"; }) [
            "/etc/NetworkManager/system-connections"
            "/var/lib/bluetooth"
            "/var/lib/private/tailscale"
          ]) ++ [
            "/var/log"
            "/var/lib/systemd/coredump"
            "/var/lib/systemd/timesync"
          ];
          files = [{
            file = "/var/lib/systemd/random-seed";
            how = "symlink";
            inInitrd = true;
          }];
        };
      };
  };
}
