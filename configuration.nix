{ config, pkgs, lib, ... }:
with builtins;
with lib; {
  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.editor = false;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [ "elevator=none" ];
    kernelModules = [ "kvm-intel" "cpuid" "coretemp" ];
    kernel.sysctl = {
      "kernel.kptr_restrict" = "2";
      "kernel.yama.ptrace_scope" = "1";
      "net.core.bpf_jit_enable" = false;
      "kernel.ftrace_enabled" = false;
    };
    zfs = {
      devNodes = "/dev/shadowfang_vg/rootvol";
      forceImportRoot = false;
    };
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" ];
      luks.devices.shadowfang_luksunlocked = {
        device = "/dev/nvme0n1p2";
        bypassWorkqueues = true;
      };
      postDeviceCommands = lib.mkAfter ''
        zfs rollback -r shadowfang/sys/root@blank
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
    mcelog.enable = true;
    pulseaudio.enable = false;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [ intel-compute-runtime ];
    };
  };

  sound.enable = true;

  security = {
    sudo = {
      execWheelOnly = true;
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
      reinit-touchpad = rec {
        enable = true;
        description = "Reload i2c_hid_acpi on wakeup.";
        after = [
          "systemd-suspend.service"
          "systemd-hibernate.service"
          "systemd-hybrid-sleep.service"
        ];
        wantedBy = [ "sleep.target" ];
        script = ''
          rmmod i2c_hid_acpi
          modprobe i2c_hid_acpi
        '';
      };
    };
  };

  fileSystems = mapAttrs (name: value:
    value // {
      options = value.options or [ ] ++ [ "noatime" "nosuid" "nodev" ];
    }) ({
      "/boot" = {
        device = "/dev/nvme0n1p1";
        fsType = "vfat";
        options = [ "noexec" ];
      };
    } // mapAttrs (name: value: value // { fsType = "zfs"; }) {
      "/".device = "shadowfang/sys/root";
      "/nix".device = "shadowfang/sys/nix";
      "/persist" = {
        device = "shadowfang/data/persist";
        options = [ "noexec" ];
        neededForBoot = true;
      };
      "/persist/home/archit" = {
        device = "shadowfang/data/home";
        neededForBoot = true;
      };
    });

  swapDevices = [{ device = "/dev/shadowfang_vg/swap"; }];

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
    users.archit = import ./home.nix;
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    allowed-users = [ "@wheel" ];
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
    zfs = {
      autoScrub.enable = true;
      autoSnapshot = {
        enable = true;
        flags = "-k -p --utc";
        frequent = 4;
        hourly = 24;
        daily = 7;
        weekly = 4;
        monthly = 0;
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
      singleton (stdenv.mkDerivation rec {
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
    ]) ++ singleton (pkgs.stdenv.mkDerivation {
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
    };
  };

  qt5 = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  system.stateVersion = "22.05";
}

