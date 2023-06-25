{ config, pkgs, lib, inputs, hostname, ... }:
let
  inherit (inputs) self;
  inherit (builtins) mapAttrs;
in
{
  imports = [
    self.nixosModules.usbguard-dbus
    self.nixosModules.bind-fonts-icons
    self.nixosModules.tpm2-tss-fapi
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
    kernelPackages = pkgs.linuxPackages_hardened;
    kernelPatches = [
      {
        name = "hardening";
        patch = null;
        extraStructuredConfig = with lib.kernel; {
          BPF_JIT_ALWAYS_ON = lib.mkForce yes;
          HW_RANDOM_TPM = yes;
          INIT_STACK_ALL_ZERO = yes;
          OVERLAY_FS_UNPRIVILEGED = yes;
          UBSAN = yes;
          UBSAN_BOUNDS = yes;
          UBSAN_SANITIZE_ALL = yes;
          UBSAN_TRAP = yes;
          USERFAULTFD = lib.mkForce no;
          X86_IOPL_IOPERM = no;
          ZERO_CALL_USED_REGS = yes;
        };
      }
      {
        name = "lkrg-in-tree";
        patch = pkgs.lkrg-in-tree-patch;
        extraStructuredConfig = with lib.kernel; {
          SECURITY_LKRG = yes;
          SECURITY_SELINUX = no;
          SECURITY_SELINUX_DISABLE = lib.mkForce (option no);
          OVERLAY_FS = yes;
        };
      }
    ];
    kernelParams = [
      "init_on_alloc=1"
      "init_on_free=1"
      "iommu.passthrough=0"
      "iommu.strict=1"
      "randomize_kstack_offset=on"
      "page_alloc.shuffle=1"
      "slab_nomerge"
      "mce=0"
      "vsyscall=none"
      "lkrg.umh_validate=0"
    ];
    kernel.sysctl = {
      "dev.tty.ldisc_autoload" = 0;
      "dev.tty.legacy_tiocsti" = false;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "kernel.dmesg_restrict" = true;
      "kernel.ftrace_enabled" = false;
      "kernel.kexec_load_disabled" = true;
      "kernel.kptr_restrict" = 2;
      "kernel.perf_event_paranoid" = 3;
      "kernel.sysrq" = 0;
      "kernel.unprivileged_bpf_disabled" = 1;
      "kernel.yama.ptrace_scope" = 1;
      "net.core.bpf_jit_harden" = 2;
      "net.ipv4.conf.all.accept_redirects" = false;
      "net.ipv4.conf.all.rp_filter" = 2;
      "net.ipv4.conf.all.secure_redirects" = false;
      "net.ipv4.conf.all.send_redirects" = false;
      "net.ipv4.conf.default.accept_redirects" = false;
      "net.ipv4.conf.default.rp_filter" = 2;
      "net.ipv4.conf.default.secure_redirects" = false;
      "net.ipv4.conf.default.send_redirects" = false;
      "net.ipv6.conf.all.accept_redirects" = false;
      "net.ipv6.conf.default.accept_redirects" = false;
    };
    extraModprobeConfig = ''
      softdep lkrg pre: overlay
    '';
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
    };
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
    apparmor.enable = true;
    forcePageTableIsolation = true;
    unprivilegedUsernsClone = true;
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
    services = {
      systemd-time-wait-sync.wantedBy = [ "sysinit.target" ];
      plymouth-quit.enable = config.boot.plymouth.enable;
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
    };
    udev.packages = with pkgs; [ r8152-udev-rules ];
    tailscale.enable = true;
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
      extraGroups = [ "wheel" "networkmanager" "tss" ];
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
        "/var/lib/tailscale"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
    defaultPackages = with pkgs; [ zile git ];
    systemPackages = with pkgs; [ lkl ];
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
