{ config, pkgs, lib, inputs, ... }: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.self.nixosModules.syncthing
    inputs.self.nixosModules.dconf
  ];

  # Allow steam package for steam-hardware udev rules
  nixpkgs.config.allowUnfreePredicate = pkg:
    (lib.getName pkg) == "steam-unwrapped";

  nix.settings = {
    keep-outputs = true;
    extra-sandbox-paths = lib.optional config.programs.ccache.enable
      config.programs.ccache.cacheDir;
  };

  users.users.archit.extraGroups = [ "dialout" "wireshark" "video" "render" ];

  hardware = {
    graphics.enable = true;
    sensor.iio.enable = true;
    steam-hardware.enable = true;
  };

  boot = {
    kernelParams = [ "quiet" "plymouth.use-simpledrm" ];
    plymouth = {
      enable = true;
      font =
        "${pkgs.adwaita-fonts}/share/fonts/Adwaita/AdwaitaSans-Regular.ttf";
      extraConfig = ''
        DeviceScale=2
      '';
    };
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    clight.settings = {
      backlight = {
        no_smooth_transition = true;
        ac_timeouts = [ 10 10 10 ];
      };
      keyboard.disabled = true;
      gamma.disabled = true;
      dimmer.disabled = true;
      dpms.disabled = true;
      screen.disabled = true;
    };
    flatpak.enable = true;
    # uaccess rules must come before 73-seat-late.rules
    udev.packages = lib.singleton (pkgs.writeTextFile {
      name = "usb-disk-udev-rules";
      destination = "/etc/udev/rules.d/70-usb-disks.rules";
      text = ''
        SUBSYSTEMS=="usb", SUBSYSTEM=="block", TAG+="uaccess"
      '';
    });
    gnome = {
      gcr-ssh-agent.enable = false;
      tinysparql.enable = false;
      localsearch.enable = false;
      gnome-browser-connector.enable = false;
      gnome-initial-setup.enable = false;
      gnome-remote-desktop.enable = false;
      gnome-user-share.enable = false;
      rygel.enable = false;
    };
    pcscd.enable = true;
  };

  systemd = {
    packages = [ pkgs.usbguard-notifier ];
    user.services.usbguard-notifier = {
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
    };
    tmpfiles.settings.preservation = {
      "/var/lib/colord".d =
        { user = "colord"; group = "colord"; mode = "0755"; };
      "/home/archit".d =
        { user = "archit"; group = "users"; mode = "0755"; };
    } // (lib.flip lib.genAttrs (_: { d.mode = lib.mkForce "0700"; }) [
      "/home/archit/.ssh"
      "/home/archit/.librewolf"
    ]);
  };

  security = {
    polkit.extraConfig = builtins.readFile ./misc/polkit-udisks2.js;
    wrappers.poop = {
      owner = "root";
      group = "root";
      source = "${pkgs.poop}/bin/poop";
      capabilities = "cap_perfmon+p";
    };
  };

  programs = {
    ccache.enable = true;
    bash.enableLsColors = false;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    adb.enable = true;
    yubikey-touch-detector = {
      enable = true;
      unixSocket = false;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.archit = inputs.self.homeModules.nixos;
    extraSpecialArgs = { inherit inputs; };
  };

  xdg.portal.xdgOpenUsePortal = true;

  environment = {
    sessionVariables = {
      GST_PLUGIN_SYSTEM_PATH_1_0 =
        lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
          pkgs.gst_all_1.gst-plugins-base
          pkgs.gst_all_1.gst-plugins-good
          pkgs.gst_all_1.gst-libav
        ];
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DECORATION = "adwaita";
    };
    systemPackages = [
      pkgs.gnome-accent-directories
      pkgs.morewaita-icon-theme
      pkgs.adw-gtk3
      pkgs.qadwaitadecorations
      pkgs.qadwaitadecorations-qt6
    ];
    wordlist = {
      enable = true;
      lists.WORDLIST = [
        "${pkgs.scowl}/share/dict/words.txt"
        "${pkgs.miscfiles}/share/web2"
      ];
    };
    etc."nixos/flake.nix".source = pkgs.runCommandLocal "flake-symlink" { } ''
      ln -s "/home/archit/projects/config-flake/flake.nix" $out
    '';
  };

  sysconfig.dconf = with lib.gvariant; {
    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      locate-pointer = true;
      accent-color = "purple";
      icon-theme = "Adwaita-Purple";
    };
    "org/gnome/desktop/media-handling" = {
      automount = false;
      autorun-never = true;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
    };
    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 180;
    };
    "org/gnome/mutter" = {
      experimental-features = [
        "scale-monitor-framebuffer"
        "xwayland-native-scaling"
      ];
    };
    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = mkUint32 4226;
      night-light-schedule-automatic = false;
      night-light-schedule-from = 20.0;
      night-light-schedule-to = 8.0;
    };
  };

  preservation.preserveAt = {
    state = {
      files = [
        {
          file = "/var/lib/colord/mapping.db";
          user = "colord";
          group = "colord";
        }
      ];
      users.archit = {
        directories = (map (d: { directory = d; mode = "0700"; }) [
          "projects"
          ".ssh/config.d"
          ".config/emacs"
          ".librewolf/profile"
          ".local/share/vault"
          ".local/share/gnupg"
          ".local/share/pass"
          ".var/app/com.valvesoftware.Steam"
        ]) ++ (map (d: { directory = d; mode = "0755"; }) [
          ".local/share/icc"
        ]);
        files = map (f: { file = f; mode = "0600"; }) [
          ".ssh/id_ed25519_sk"
          ".ssh/id_ed25519_sk-cert.pub"
        ];
      };
    };
    data.users.archit.directories =
      map (d: { directory = d; mode = "0700"; }) [
        "Documents"
        "Music"
        "Pictures"
        "Videos"
        "Library"
      ];
    cache.users.archit.directories =
      map (d: { directory = d; mode = "0700"; }) [
        "Downloads"
        "playground"
        ".local/share/flatpak"
      ];
  };
}
