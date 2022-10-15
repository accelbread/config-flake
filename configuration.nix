{ config, pkgs, lib, ... }:
with builtins; {
  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.editor = false;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "elevator=none" ];
    kernelModules = [ "kvm-intel" "cpuid" "coretemp" ];
    kernel.sysctl = {
      "kernel.kptr_restrict" = "2";
      "kernel.yama.ptrace_scope" = "1";
      "net.core.bpf_jit_enable" = false;
      "kernel.ftrace_enabled" = false;
    };
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" ];
      luks.devices.shadowfang_disk1 = {
        device = "/dev/nvme0n1p2";
        bypassWorkqueues = true;
      };
      preDeviceCommands = ''
        message="\
        Hello, this is ${config.networking.hostName}.
        Owner: Archit Gupta
        Email: accelbread@gmail.com
        "
        printf "$message" | ${pkgs.cowsay}/bin/cowsay -n
      '';
      postDeviceCommands = lib.mkAfter ''
        mkdir -p /mnt
        mount -t btrfs -o noatime,compress=zstd /dev/shadowfang_vg1/pool /mnt
        ${
          pkgs.writeShellApplication {
            name = "btrfs_rm";
            runtimeInputs = with pkgs; [ btrfs-progs gawk gnused ];
            text = readFile ./scripts/btrfs_subvol_rm_recursive;
          }
        }/bin/btrfs_rm /mnt/root
        btrfs subvolume create /mnt/root
        umount /mnt
      '';
    };
    tmpOnTmpfs = true;
  };

  networking = {
    hostName = "shadowfang";
    hostId = "fefcc72a";
    networkmanager.enable = true;
    networkmanager.dns = "none";
  };

  time.timeZone = "America/Los_Angeles";

  location.provider = "geoclue2";

  hardware = {
    cpu.intel.updateMicrocode = true;
    firmware = [ pkgs.linux-firmware ];
    video.hidpi.enable = true;
    rasdaemon.enable = true;
    pulseaudio.enable = false;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [ intel-compute-runtime ];
    };
  };

  sound.enable = true;

  security = {
    sudo = {
      extraConfig = ''
        Defaults lecture = never
      '';
    };
    tpm2 = {
      enable = true;
      pkcs11 = {
        enable = true;
        package = pkgs.tpm2-pkcs11.overrideAttrs (old: {
          configureFlags = old.configureFlags or [ ] ++ [ "--enable-fapi=no" ];
        });
      };
      tctiEnvironment.enable = true;
    };
    apparmor.enable = true;
    forcePageTableIsolation = true;
  };

  powerManagement.powertop.enable = true;

  systemd = {
    sleep.extraConfig = "HibernateDelaySec=10m";
    services = {
      reinit-touchpad = {
        enable = true;
        description = "Reload i2c_hid_acpi on wakeup.";
        after = [ "systemd-hibernate.service" ];
        wantedBy = [ "systemd-hibernate.target" ];
        script = ''
          rmmod i2c_hid_acpi
          modprobe i2c_hid_acpi
        '';
      };
    };
  };

  fileSystems = mapAttrs (_: v:
    v // {
      options = v.options or [ ] ++ [ "noatime" "nosuid" "nodev" ];
    }) ({
      "/boot" = {
        device = "/dev/nvme0n1p1";
        fsType = "vfat";
        options = [ "noexec" ];
      };
    } // mapAttrs (_: v:
      v // {
        device = "/dev/shadowfang_vg1/pool";
        fsType = "btrfs";
        options = v.options or [ ] ++ [
          "subvol=${v.device}"
          "compress=zstd"
          "autodefrag"
          "user_subvol_rm_allowed"
        ];
      }) {
        "/".device = "root";
        "/nix".device = "nix";
        "/persist" = {
          device = "persist";
          options = [ "noexec" ];
          neededForBoot = true;
        };
        "/persist/home" = {
          device = "persist/home";
          neededForBoot = true;
        };
      });

  swapDevices = [{ device = "/dev/shadowfang_vg1/swap"; }];

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/bluetooth"
      "/var/log"
      "/var/lib/systemd/coredump"
    ];
    files = [ "/etc/machine-id" ];
    users.archit = {
      directories = [
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Videos"
        "projects"
        "playground"
        ".config/emacs"
        ".librewolf/profile"
        ".local/share/tpm2_pkcs11"
        ".local/share/gnupg"
        ".local/share/pass"
        ".local/share/Zeal"
      ];
      files = [ ".face" ".config/monitors.xml" ];
    };
  };

  users = {
    mutableUsers = false;
    users.archit = {
      isNormalUser = true;
      description = "Archit Gupta";
      extraGroups = [ "wheel" "networkmanager" "tss" "dialout" ];
      uid = 1000;
      passwordFile = "/persist/vault/user_pass";
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.archit = (import ./home.nix config.users.users.archit);
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      allowed-users = [ "@wheel" ];
    };
  };

  documentation = {
    man.generateCaches = true;
    nixos.includeAllModules = true;
  };

  services = {
    fwupd.enable = true;
    tlp = {
      enable = true;
      settings = { PCIE_ASPM_ON_BAT = "powersupersave"; };
    };
    power-profiles-daemon.enable = false;
    thermald.enable = true;
    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [ "/" ];
    };
    btrbk.instances.btrbk = {
      onCalendar = "*:0/10";
      settings = {
        timestamp_format = "long";
        volume."/persist" = {
          subvolume = "home";
          snapshot_dir = ".snapshots";
          snapshot_preserve_min = "4h";
          snapshot_preserve = "48h 14d 4w";
        };
      };
    };
    logind = {
      lidSwitch = "hibernate";
      killUserProcesses = true;
    };
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    fprintd.enable = false;
    xserver = {
      enable = true;
      videoDrivers = [ "modesetting" ];
      excludePackages = [ pkgs.xterm ];
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
    };
    gnome.core-utilities.enable = false;
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
    avahi.nssmdns = true;
    printing = {
      enable = true;
      webInterface = false;
    };
    udev.packages = with pkgs;
      lib.singleton (stdenv.mkDerivation rec {
        pname = "r8152-udev-rules";
        version = "v2.16.3.20220914";
        src = fetchFromGitHub {
          owner = "wget";
          repo = "realtek-r8152-linux";
          rev = version;
          sha256 = "sha256-5IFDqt4kfJy7vjk638yGQOELotyWSa0h84PN3nhkQbM=";
        };
        dontBuild = true;
        dontConfigure = true;
        installPhase = ''
          mkdir -p $out/lib/udev/rules.d
          cp 50-usb-realtek-net.rules $out/lib/udev/rules.d/
        '';
      });
  };

  virtualisation.containers = {
    enable = true;
    storage.settings.storage.driver = "btrfs";
  };

  programs.bash.enableLsColors = false;

  fonts = {
    enableDefaultFonts = false;
    fonts = (with pkgs; [
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-extra
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ]) ++ lib.singleton (pkgs.stdenv.mkDerivation {
      name = "noto-fonts-bw-emoji";
      src = pkgs.fetchzip {
        name = "noto-emoji";
        url = "https://fonts.google.com/download?family=Noto%20Emoji";
        extension = "zip";
        stripRoot = false;
        sha256 = "sha256-q7WpqAhmio2ecNGOI7eX7zFBicrsvX8bURF02Pru2rM=";
      };
      installPhase = ''
        mkdir -p $out/share/fonts/noto
        cp NotoEmoji-*.ttf $out/share/fonts/noto
      '';
    });
  };

  environment = {
    defaultPackages = [ ];
    systemPackages = with pkgs; [
      zile
      git
      ripgrep
      fd
      tree
      jq
      librewolf
      v4l-utils
      gnome.nautilus
      gnome-console
      gnome.gnome-system-monitor
      gnome.evince
      gnome.eog
      gnome.gnome-characters
      gnome.gnome-clocks
      gnomeExtensions.system-action-hibernate
      (pkgs.stdenv.mkDerivation {
        name = "emacs-terminfo";
        dontUnpack = true;
        nativeBuildInputs = [ ncurses ];
        installPhase = ''
          mkdir -p $out/share/terminfo
          tic -x -o $out/share/terminfo ${./misc/dumb-emacs-ansi.ti}
        '';
      })
    ];
    gnome.excludePackages = [ pkgs.gnome-tour ];
    localBinInPath = true;
    variables.EDITOR = "zile";
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_USE_XINPUT2 = "1";
      MOZ_X11_EGL = "1";
      BROWSER = "librewolf";
      GDK_DPI_SCALE = "1.25";
      QT_SCALE_FACTOR = "1.25";
    };
  };

  qt5 = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  system.stateVersion = "22.05";
}

