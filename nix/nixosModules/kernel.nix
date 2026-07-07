{ pkgs, lib, config, ... }:
let
  use-ccache = false;
  stdenv = llvmStdenv pkgs.llvmPackages;
  base-kernel = pkgs.linux;

  extraMakeFlags = [ "INSTALL_MOD_STRIP=1" ];

  llvmStdenv = llvmPackages:
    let inherit (llvmPackages) stdenv bintools; in
    pkgs.overrideCC stdenv (stdenv.cc.override { inherit bintools; });

  baseConfig = (base-kernel.override (prev: {
    inherit stdenv extraMakeFlags;
    enableCommonConfig = false;
    kernelPatches = prev.kernelPatches or [ ] ++ config.boot.kernelPatches;
  })).configfile;

  configFragment = pkgs.writeText "kconfig_settings"
    (lib.concatStrings (lib.mapAttrsToList
      (k: v:
        if v.freeform != null then
          if lib.match "-?[0-9]+|0x[0-9a-fA-F]+" v.freeform != null
          then "CONFIG_${k}=${v.freeform}\n"
          else "CONFIG_${k}=\"${v.freeform}\"\n"
        else if v.tristate == null then ""
        else if v.tristate == "n" then "# CONFIG_${k} is not set\n"
        else "CONFIG_${k}=${v.tristate}\n")
      baseConfig.structuredConfig));

  requiredConfig = pkgs.writeText "required_kconfig"
    (lib.concatStrings ([ "(" ] ++
      (lib.mapAttrsToList
        (k: v:
          if v.freeform != null then "(${k} . \"${v.freeform}\")"
          else if v.tristate != null then "(${k} . ${v.tristate})"
          else "(${k} . unset)")
        (lib.filterAttrs (_: v: !v.optional) baseConfig.structuredConfig))
      ++ [ ")" ]));

  configfile = stdenv.mkDerivation {
    inherit (baseConfig) pname version depsBuildBuild nativeBuildInputs
      makeFlags preUnpack src patches installPhase enableParallelBuilding;
    inherit (base-kernel) postPatch;
    buildPhase = ''
      export buildRoot="''${buildRoot:-build}"
      mkdir -p "$buildRoot"
      export MAKEFLAGS="$makeFlags"
      ./scripts/kconfig/merge_config.sh -O "$buildRoot" -Q \
        kernel/configs/hardening.config \
        arch/x86/configs/hardening.config \
        ${configFragment}
      ${pkgs.guile}/bin/guile --no-auto-compile -s ${./misc/check_kconfig.scm} \
        ${requiredConfig} "$buildRoot/.config"
    '';
  };
in
{
  security.lsm = [ "lockdown" ];

  boot = {
    kernelPackages = pkgs.linuxPackagesFor (pkgs.linuxManualConfig ({
      inherit (base-kernel) version pname modDirVersion src kernelPatches;
      inherit stdenv extraMakeFlags configfile;
      config.CONFIG_MODULES = "y";
    } // lib.optionalAttrs use-ccache {
      stdenv = pkgs.ccacheStdenv.override { inherit stdenv; };
      buildPackages = pkgs.buildPackages // {
        stdenv = pkgs.buildPackages.ccacheStdenv;
      };
    }));
    kernelPatches = map
      (p: { name = baseNameOf p; patch = builtins.path { path = p; }; })
      (lib.filesystem.listFilesRecursive ./kernel-patches) ++
    lib.mapAttrsToList
      (k: v: { name = k; patch = null; structuredExtraConfig = v; })
      (with lib.kernel; {
        "base" = {
          BINFMT_MISC = yes;
          BINFMT_SCRIPT = yes;
          BLK_DEV_INITRD = yes;
          BLK_DEV_NVME = yes;
          BLK_DEV_SD = module;
          BPF = yes;
          BPF_JIT = yes;
          BPF_SYSCALL = yes;
          CGROUPS = yes;
          CGROUP_BPF = yes;
          CGROUP_PIDS = yes;
          CRYPTO_CHACHA20POLY1305 = module; # for kTLS
          DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT = yes;
          DEVTMPFS = yes;
          EPOLL = yes;
          EXPERT = yes;
          FANOTIFY = yes;
          FUSE_FS = module;
          FW_LOADER = yes;
          FW_LOADER_COMPRESS = yes;
          FW_LOADER_COMPRESS_ZSTD = yes;
          HAVE_EBPF_JIT = yes;
          HIBERNATION = yes;
          HIGH_RES_TIMERS = yes;
          HWMON = yes;
          I2C = yes;
          I2C_CHARDEV = module;
          INET = yes;
          INOTIFY_USER = yes;
          INPUT = yes;
          INPUT_EVDEV = module;
          INPUT_KEYBOARD = yes;
          IPV6 = yes;
          IPV6_MULTIPLE_TABLES = yes;
          IP_ADVANCED_ROUTER = yes;
          IP_MULTICAST = yes;
          IP_MULTIPLE_TABLES = yes;
          IP_ROUTE_VERBOSE = yes;
          KCMP = yes;
          KERNEL_ZSTD = yes;
          LOG_BUF_SHIFT = freeform "18";
          LRU_GEN = yes;
          LRU_GEN_ENABLED = yes;
          MD = yes;
          MEDIA_SUPPORT_FILTER = yes;
          MODULES = yes;
          MODULE_COMPRESS = yes;
          MODULE_COMPRESS_ALL = yes;
          MODULE_COMPRESS_ZSTD = yes;
          MODULE_UNLOAD = yes;
          MPTCP = yes;
          MPTCP_IPV6 = yes;
          MQ_IOSCHED_DEADLINE = yes;
          NAMESPACES = yes;
          NET = yes;
          NETDEVICES = yes;
          NETFILTER = yes;
          NETFILTER_ADVANCED = yes;
          NET_NS = yes;
          NET_SCHED = yes;
          NF_TABLES_INET = yes;
          NF_TABLES_IPV4 = yes;
          NF_TABLES_IPV6 = yes;
          NVME_HWMON = yes;
          PACKET = module;
          PCIEAER = yes;
          POSIX_MQUEUE = yes;
          PRINTK_TIME = yes;
          PROC_FS = yes;
          RTC_HCTOSYS = yes;
          RT_GROUP_SCHED = no;
          SCHED_CORE = yes;
          SCSI_CONSTANTS = yes;
          SECCOMP = yes;
          SECCOMP_FILTER = yes;
          SECURITY = yes;
          SECURITY_LANDLOCK = yes;
          SIGNALFD = yes;
          SMP = yes;
          SYSFS = yes;
          SYSVIPC = yes;
          THERMAL = yes;
          THERMAL_HWMON = yes;
          TIMERFD = yes;
          TLS = module;
          TMPFS = yes;
          TMPFS_POSIX_ACL = yes;
          TMPFS_XATTR = yes;
          TRANSPARENT_HUGEPAGE = yes;
          UNIX = yes;
          USER_NS = yes;
          WATCHDOG = yes;
          WATCHDOG_SYSFS = yes;
        };
        "x86_64" = {
          ACPI = yes;
          ACPI_APEI = yes;
          ACPI_BUTTON = module;
          ACPI_THERMAL = module;
          ACPI_TINY_POWER_BUTTON = module;
          CRYPTO_AES_NI_INTEL = yes;
          CRYPTO_GHASH_CLMUL_NI_INTEL = module;
          HPET = no;
          IA32_EMULATION = yes;
          IRQ_REMAP = yes;
          MICROCODE = yes;
          MTRR = yes;
          PCI = yes;
          PERF_EVENTS_INTEL_RAPL = module;
          PROCESSOR_SELECT = yes;
          RTC_CLASS = yes;
          RTC_DRV_CMOS = yes;
          SERIO = module;
          X86_MCE = yes;
          X86_PAT = yes;
          X86_USER_SHADOW_STACK = yes;
          X86_X2APIC = yes;
        };
        "performance" = {
          BLK_WBT = yes;
          BLK_WBT_MQ = yes;
          CPU_FREQ_DEFAULT_GOV_SCHEDUTIL = yes;
          CPU_IDLE_GOV_MENU = no;
          CPU_IDLE_GOV_TEO = yes;
          CRYPTO_LZ4 = yes;
          DEFAULT_BBR = yes;
          DEFAULT_FQ_CODEL = yes;
          DEFERRED_STRUCT_PAGE_INIT = yes;
          HIBERNATION_COMP_LZ4 = yes;
          HIGH_RES_TIMERS = yes;
          HZ_1000 = yes;
          JUMP_LABEL = yes;
          NET_SCH_DEFAULT = yes;
          NET_SCH_FQ_CODEL = yes;
          NO_HZ = yes;
          NO_HZ_IDLE = yes;
          PCIEASPM_POWER_SUPERSAVE = yes;
          PERSISTENT_HUGE_ZERO_FOLIO = yes;
          PREEMPT = yes;
          PREEMPT_DYNAMIC = no;
          RCU_EXPERT = yes;
          RCU_LAZY = yes;
          RCU_NOCB_CPU = yes;
          READ_ONLY_THP_FOR_FS = yes;
          SCHED_AUTOGROUP = yes;
          TCP_CONG_ADVANCED = yes;
          TCP_CONG_BBR = yes;
          THERMAL_DEFAULT_GOV_STEP_WISE = yes;
          TRANSPARENT_HUGEPAGE_ALWAYS = yes;
          X86_64_VERSION = freeform "3";
          ZSWAP = yes;
          ZSWAP_COMPRESSOR_DEFAULT_ZSTD = yes;
        };
        "compiler" = {
          DEBUG_INFO_COMPRESSED_ZLIB = yes;
          OBJTOOL_WERROR = yes;
          STRIP_ASM_SYMS = yes;
          TRIM_UNUSED_KSYMS = yes;
        };
        "monitoring" = {
          IRQ_TIME_ACCOUNTING = yes;
          TASKSTATS = yes;
          TASK_DELAY_ACCT = yes;
          TASK_IO_ACCOUNTING = yes;
          TASK_XACCT = yes;
        };
        "systemd" = {
          AUTOFS_FS = module;
          BPF_LSM = yes;
          CFS_BANDWIDTH = yes;
          CGROUP_SCHED = yes;
          DEBUG_INFO_BTF = yes;
          DMIID = yes;
          DMI_SYSFS = module;
          FAIR_GROUP_SCHED = yes;
          FHANDLE = yes;
          FW_LOADER_USER_HELPER = no;
          MEMCG = yes;
          PSI = yes;
          UEVENT_HELPER = no;
        };
        "uefi" = {
          EFI = yes;
          EFIVAR_FS = yes;
          EFI_PARTITION = yes;
          EFI_STUB = yes;
          EFI_VARS_PSTORE = yes;
          NLS_CODEPAGE_437 = module;
          NLS_DEFAULT = freeform "iso8859-1";
          NLS_ISO8859_1 = module;
          VFAT_FS = module;
        };
        "dm-crypt" = {
          CRYPTO_AES = yes;
          CRYPTO_SHA256 = yes;
          CRYPTO_XTS = yes;
          DM_CRYPT = yes;
        };
        "filesystem" = {
          BLK_DEV_DM = yes;
          BTRFS_FS = module;
          BTRFS_FS_POSIX_ACL = yes;
          FS_VERITY = yes;
          OVERLAY_FS = module;
          OVERLAY_FS_XINO_AUTO = yes;
        };
        "display" = {
          ACPI_BGRT = yes;
          BACKLIGHT_CLASS_DEVICE = yes;
          DRM = yes;
          DRM_FBDEV_EMULATION = yes;
          DRM_PANIC = yes;
          DRM_PANIC_SCREEN = freeform "kmsg";
          DRM_SIMPLEDRM = yes;
          FB = yes;
          FONTS = yes;
          FONT_8x16 = yes;
          FONT_TER16x32 = yes;
          FRAMEBUFFER_CONSOLE = yes;
          FRAMEBUFFER_CONSOLE_DEFERRED_TAKEOVER = yes;
          FRAMEBUFFER_CONSOLE_DETECT_PRIMARY = yes;
          SYSFB_SIMPLEFB = yes;
          VGA_ARB_MAX_GPUS = freeform "2";
          X86_VERBOSE_BOOTUP = no;
        };
        "audio" = {
          SND = module;
          SND_DYNAMIC_MINORS = yes;
          SND_HDA_CODEC_HDMI = module;
          SND_HDA_GENERIC = module;
          SND_HDA_INTEL = module;
          SND_HDA_POWER_SAVE_DEFAULT = freeform "10";
          SND_MAX_CARDS = freeform "16";
          SND_USB_AUDIO = module;
          SOUND = module;
        };
        "usb" = {
          USB = yes;
          USB_ANNOUNCE_NEW_DEVICES = yes;
          USB_HID = module;
          USB_HIDDEV = yes;
          USB_STORAGE = module;
          USB_UAS = module;
          USB_XHCI_HCD = module;
        };
        "hid" = {
          HID = module;
          HIDRAW = yes;
          HID_BATTERY_STRENGTH = yes;
          HID_GENERIC = module;
          HID_HAPTIC = yes;
          HID_MULTITOUCH = module;
        };
        "wireless" = {
          BT = module;
          BT_HCIBTUSB_AUTOSUSPEND = yes;
          CFG80211 = module;
          MAC80211 = module;
          MAC80211_LEDS = yes;
          RFKILL = module;
          RFKILL_INPUT = yes;
          UHID = module;
        };
        "amdgpu" = {
          DEVICE_PRIVATE = yes;
          DMABUF_MOVE_NOTIFY = yes;
          DRM_AMDGPU = module;
          DRM_AMD_DC = yes;
          HSA_AMD = yes;
          HSA_AMD_P2P = yes;
          HSA_AMD_SVM = yes;
          MEMORY_HOTPLUG = yes;
          MEMORY_HOTREMOVE = yes;
          PCI_P2PDMA = yes;
          RANDOMIZE_MEMORY_PHYSICAL_PADDING = freeform "0x1";
          ZONE_DEVICE = yes;
        };
        "VMs" = {
          KVM = module;
          UDMABUF = yes;
        };
        "nftables" = {
          NETLINK_DIAG = module;
          NFT_CT = module;
          NFT_FIB_INET = module;
          NFT_FIB_IPV4 = module;
          NFT_FIB_IPV6 = module;
          NFT_LIMIT = module;
          NFT_LOG = module;
          NFT_MASQ = module;
          NFT_NAT = module;
          NFT_REDIR = module;
          NFT_REJECT = module;
          NFT_SOCKET = module;
          NFT_TPROXY = module;
          NF_CONNTRACK = module;
          NF_CONNTRACK_MARK = yes;
          NF_LOG_SYSLOG = module;
          NF_TABLES = module;
        };
        "misc" = {
          BLK_DEV_LOOP = module;
          CGROUP_PERF = yes;
          CPUSETS = yes;
          IKCONFIG = module;
          IKCONFIG_PROC = yes;
          IKHEADERS = module;
          INPUT_MISC = yes;
          INPUT_UINPUT = module;
          NTSYNC = module;
          PACKET_DIAG = module;
          SCHED_CLASS_EXT = yes;
          TUN = module;
          UNIX_DIAG = module;
          VETH = module;
          WIREGUARD = module;
        };
        "debug" = {
          DETECT_HUNG_TASK = yes;
          HARDLOCKUP_DETECTOR = yes;
          LOCKUP_DETECTOR = yes;
          SOFTLOCKUP_DETECTOR = yes;
        };
        "hardening" = {
          # WERROR = yes; # TODO: make this work
          AIO = no;
          AMD_IOMMU = yes;
          AUDIT = yes;
          BLK_DEV_WRITE_MOUNTED = no;
          BPF_JIT_ALWAYS_ON = yes;
          BUG = yes;
          BUG_ON_DATA_CORRUPTION = yes;
          COMPAT_BRK = no;
          COMPAT_VDSO = no;
          CRYPTO_USER_API = option no;
          CRYPTO_USER_API_AEAD = no;
          CRYPTO_USER_API_HASH = no;
          CRYPTO_USER_API_RNG = no;
          CRYPTO_USER_API_SKCIPHER = no;
          DEBUG_FS = no;
          DEBUG_LIST = yes;
          DEBUG_NOTIFIERS = yes;
          DEBUG_PLIST = yes;
          DEBUG_SG = yes;
          DEBUG_VIRTUAL = yes;
          DEBUG_WX = yes;
          DEVMEM = no;
          DEVPORT = no;
          EFI_DISABLE_PCI_DMA = yes;
          FORTIFY_SOURCE = yes;
          FUNCTION_TRACER = no;
          HARDENED_USERCOPY = yes;
          HARDENED_USERCOPY_DEFAULT_ON = yes;
          HW_RANDOM = yes;
          HW_RANDOM_TPM = yes;
          INET_DIAG = no;
          INIT_ON_ALLOC_DEFAULT_ON = yes;
          INIT_ON_FREE_DEFAULT_ON = yes;
          INIT_STACK_ALL_ZERO = yes;
          INTEL_IOMMU = yes;
          INTEL_IOMMU_DEFAULT_ON = yes;
          INTEL_IOMMU_SVM = yes;
          IOMMU_DEFAULT_DMA_STRICT = yes;
          IOMMU_DEFAULT_PASSTHROUGH = no;
          IOMMU_SUPPORT = yes;
          KEXEC = no;
          KEXEC_FILE = no;
          KFENCE = yes;
          KSTACK_ERASE = yes;
          LDISC_AUTOLOAD = no;
          LEGACY_PTYS = no;
          LEGACY_TIOCSTI = no;
          LEGACY_VSYSCALL_NONE = yes;
          LIST_HARDENED = yes;
          LOCK_DOWN_KERNEL_FORCE_INTEGRITY = yes;
          MAGIC_SYSRQ = no;
          MITIGATION_PAGE_TABLE_ISOLATION = yes;
          MITIGATION_SLS = yes;
          MODIFY_LDT_SYSCALL = no;
          MODULE_HASHES = yes;
          MODULE_SIG = no;
          MODULE_SIG_FORCE = yes;
          MSEAL_SYSTEM_MAPPINGS = yes;
          NFS_DEBUG = unset;
          OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW = no;
          PAGE_TABLE_CHECK = yes;
          PAGE_TABLE_CHECK_ENFORCED = yes;
          PANIC_ON_OOPS = yes;
          PANIC_TIMEOUT = freeform "-1";
          PROC_KCORE = no;
          PROC_MEM_NO_FORCE = yes;
          RANDOMIZE_BASE = yes;
          RANDOMIZE_KSTACK_OFFSET_DEFAULT = yes;
          RANDOMIZE_MEMORY = yes;
          RANDOM_KMALLOC_CACHES = yes;
          RESET_ATTACK_MITIGATION = yes;
          SCHED_STACK_END_CHECK = yes;
          SECURITY_DMESG_RESTRICT = yes;
          SECURITY_LOCKDOWN_LSM = yes;
          SECURITY_LOCKDOWN_LSM_EARLY = yes;
          SECURITY_YAMA = yes;
          SHUFFLE_PAGE_ALLOCATOR = yes;
          SLAB_BUCKETS = yes;
          SLAB_FREELIST_HARDENED = yes;
          SLAB_FREELIST_RANDOM = yes;
          SLAB_MERGE_DEFAULT = no;
          SLUB_DEBUG = yes;
          STACKPROTECTOR = yes;
          STACKPROTECTOR_STRONG = yes;
          STRICT_KERNEL_RWX = yes;
          STRICT_MODULE_RWX = yes;
          SYN_COOKIES = yes;
          TCG_TPM = yes;
          UBSAN = yes;
          UBSAN_ALIGNMENT = option no;
          UBSAN_BOOL = option no;
          UBSAN_BOUNDS = yes;
          UBSAN_DIV_ZERO = option no;
          UBSAN_ENUM = option no;
          UBSAN_INTEGER_WRAP = option no;
          UBSAN_SHIFT = option no;
          UBSAN_TRAP = yes;
          UBSAN_UNREACHABLE = option no;
          UID16 = no;
          USERFAULTFD = no;
          VMAP_STACK = yes;
          X86_16BIT = unset;
          X86_INTEL_TSX_MODE_OFF = yes;
          X86_IOPL_IOPERM = no;
          X86_KERNEL_IBT = yes;
          ZERO_CALL_USED_REGS = yes;
        } // lib.optionalAttrs (!stdenv.cc.isClang) {
          GCC_PLUGINS = yes;
        } // lib.optionalAttrs stdenv.cc.isClang {
          CFI = yes;
          CFI_PERMISSIVE = no;
          FINEIBT = no;
        };
        "linux-hardened config" = {
          OVERLAY_FS_UNPRIVILEGED = yes;
          SLAB_CANARY = no;
          USER_NS_UNPRIVILEGED = yes;
        };
        "shadowfang hardware" = {
          ACPI_AC = module;
          ACPI_BATTERY = module;
          ACPI_EC = yes;
          ACPI_FAN = module;
          ACPI_PROCESSOR_AGGREGATOR = module;
          BT_HCIBTUSB = module;
          CHARGER_CROS_CONTROL = module;
          CHROME_PLATFORMS = yes;
          CROS_EC = module;
          CROS_EC_CHARDEV = module;
          CROS_EC_LPC = module;
          CROS_KBD_LED_BACKLIGHT = module;
          DRM_XE = module;
          DRM_XE_FORCE_PROBE = freeform "*";
          HID_SENSOR_ALS = module;
          HID_SENSOR_HUB = module;
          HOTPLUG_PCI_PCIE = yes;
          I2C_DESIGNWARE_CORE = module;
          I2C_DESIGNWARE_PLATFORM = module;
          I2C_HID = module;
          I2C_HID_ACPI = module;
          I2C_I801 = module;
          IIO = module;
          INT340X_THERMAL = module;
          INTEL_HFI_THERMAL = yes; # used by intel-lpmd
          INTEL_IDLE = yes;
          INTEL_MEI = module;
          INTEL_PMC_CORE = module;
          INTEL_PMT_TELEMETRY = module;
          INTEL_POWERCLAMP = module; # used by thermald
          INTEL_RAPL = module;
          INTEL_VSEC = module;
          ITCO_WDT = module;
          IWLMVM = module;
          IWLWIFI = module;
          KEYBOARD_ATKBD = module;
          KVM_INTEL = module;
          MFD_CROS_EC_DEV = module;
          MFD_INTEL_LPSS_PCI = module;
          MOUSE_PS2 = module;
          PERF_EVENTS_INTEL_CSTATE = module;
          PERF_EVENTS_INTEL_UNCORE = module;
          PINCTRL_TIGERLAKE = module;
          SCHED_CLUSTER = yes;
          SENSORS_CORETEMP = module;
          SERIO = module;
          SND_HDA_CODEC_SIGMATEL = module;
          SND_SOC = module;
          SND_SOC_SOF_HDA_AUDIO_CODEC = yes;
          SND_SOC_SOF_HDA_LINK = yes;
          SND_SOC_SOF_INTEL_TOPLEVEL = yes;
          SND_SOC_SOF_PCI = module;
          SND_SOC_SOF_TIGERLAKE = module;
          SND_SOC_SOF_TOPLEVEL = yes;
          TCG_TIS = yes;
          THERMAL_GOV_USER_SPACE = yes; # used by thermald
          TYPEC = module;
          TYPEC_DP_ALTMODE = module;
          TYPEC_TBT_ALTMODE = module;
          TYPEC_UCSI = module;
          UCSI_ACPI = module;
          USB4 = module;
          X86_INTEL_LPSS = yes;
          X86_INTEL_PSTATE = yes;
          X86_PKG_TEMP_THERMAL = module;
        };
        "solace hardware" = {
          AMD_ATL = module;
          ATA = module;
          BT_HCIBTUSB = module;
          EDAC = module;
          EDAC_AMD64 = module;
          GIGABYTE_WMI = module;
          I2C_PIIX4 = module;
          IGB = module;
          IWLMVM = module;
          IWLWIFI = module;
          KVM_AMD = module;
          MEMORY_FAILURE = yes;
          PERF_EVENTS_AMD_BRS = yes;
          PINCTRL_AMD = yes;
          R8169 = module;
          SATA_AHCI = module;
          SENSORS_IT87 = module;
          SENSORS_K10TEMP = module;
          SND_HDA_CODEC_REALTEK = module;
          SND_HRTIMER = module;
          SP5100_TCO = module;
          TCG_TIS = yes;
          X86_AMD_PLATFORM_DEVICE = yes;
          X86_AMD_PSTATE = yes;
        };
        "peripherals" = {
          BLK_DEV_SR = module;
          BT_RFCOMM = module;
          HID_LOGITECH = module;
          HID_LOGITECH_DJ = module;
          HID_MAGICMOUSE = module;
          HID_MICROSOFT = module;
          HID_PLAYSTATION = module;
          HID_STEAM = module;
          HID_WACOM = module;
          INPUT_JOYDEV = module;
          INPUT_JOYSTICK = yes;
          JOYSTICK_XPAD = module;
          JOYSTICK_XPAD_FF = yes;
          JOYSTICK_XPAD_LEDS = yes;
          LEDS_CLASS_MULTICOLOR = module;
          MEDIA_CAMERA_SUPPORT = yes;
          MEDIA_SUPPORT = module;
          MEDIA_USB_SUPPORT = yes;
          PLAYSTATION_FF = yes;
          USB_ACM = module;
          USB_NET_DRIVERS = module;
          USB_RTL8152 = module;
          USB_SERIAL = yes;
          USB_SERIAL_CH341 = module;
          USB_SERIAL_CP210X = module;
          USB_SERIAL_FTDI_SIO = module;
          USB_SERIAL_PL2303 = module;
          USB_VIDEO_CLASS = module;
        };
        "defconfig junk" = {
          ACPI_DEBUG = no;
          ACPI_I2C_OPREGION = no;
          ACPI_PCC = no;
          ACPI_PRMT = no;
          ACPI_REV_OVERRIDE_POSSIBLE = no;
          ACPI_SPCR_TABLE = no;
          ACPI_TABLE_UPGRADE = no;
          AF_UNIX_OOB = no;
          ALLOW_DEV_COREDUMP = no;
          ATA_FORCE = no;
          ATA_SFF = no;
          BLOCK_LEGACY_AUTOLOAD = no;
          BT_HCIBTUSB_BCM = no;
          BT_HCIBTUSB_RTL = no;
          CHARGER_CROS_PCHG = no;
          CPU_ISOLATION = no;
          CPU_SUP_CENTAUR = no;
          CPU_SUP_HYGON = no;
          CPU_SUP_ZHAOXIN = no;
          CROS_EC_LIGHTBAR = no;
          CROS_EC_SENSORHUB = no;
          CROS_EC_SYSFS = no;
          CROS_TYPEC_SWITCH = no;
          CROS_USBPD_NOTIFY = no;
          DEBUG_MISC = no;
          DNOTIFY = no;
          DRM_XE_PAGEMAP = no;
          EARLY_PRINTK = no;
          EDAC_LEGACY_SYSFS = no;
          EFI_HANDOVER_PROTOCOL = no;
          EPROBE_EVENTS = no;
          FB_DEVICE = no;
          FIRMWARE_MEMMAP = no; # kexec
          FW_LOADER_COMPRESS_XZ = no;
          GPIO_CDEV = no;
          HIBERNATION_SNAPSHOT_DEV = no;
          HW_RANDOM_AMD = no;
          HW_RANDOM_INTEL = no;
          HW_RANDOM_VIA = no;
          I2C_HELPER_AUTO = no;
          IGB_HWMON = no;
          INTEGRITY = no;
          INTEL_IOMMU_PERF_EVENTS = no;
          INTEL_IOMMU_SCALABLE_MODE_DEFAULT_ON = no;
          IP6_NF_IPTABLES = no;
          IPV6_SIT = no;
          IP_NF_IPTABLES = no;
          ISA_DMA_API = no;
          IWLWIFI_DEVICE_TRACING = no;
          KVM_HYPERV = no;
          KVM_SMM = no;
          LOCALVERSION_AUTO = no;
          MEDIA_SUBDRV_AUTOSELECT = no;
          MOUSE_PS2_ALPS = no;
          MOUSE_PS2_BYD = no;
          MOUSE_PS2_CYPRESS = no;
          MOUSE_PS2_FOCALTECH = no;
          MOUSE_PS2_LIFEBOOK = no;
          MOUSE_PS2_LOGIPS2PP = no;
          MOUSE_PS2_SYNAPTICS = no;
          MOUSE_PS2_SYNAPTICS_SMBUS = no;
          MOUSE_PS2_TRACKPOINT = no;
          MQ_IOSCHED_KYBER = no;
          MTRR_SANITIZER = no;
          NETFILTER_EGRESS = no;
          NETFILTER_INGRESS = no;
          NETFILTER_XTABLES = no;
          NET_FLOW_LIMIT = no;
          NF_CT_PROTO_SCTP = no;
          NF_CT_PROTO_UDPLITE = no;
          PCSPKR_PLATFORM = no;
          PERF_EVENTS_AMD_UNCORE = no;
          PNP_DEBUG_MESSAGES = no;
          PTP_1588_CLOCK = no;
          RAID6_PQ_BENCHMARK = no;
          RAS_FMPM = no;
          RCU_TRACE = no;
          RD_BZIP2 = no;
          RD_GZIP = no;
          RD_LZ4 = no;
          RD_LZMA = no;
          RD_LZO = no;
          RD_XZ = no;
          RFS_ACCEL = no;
          RTC_INTF_PROC = no;
          RTC_NVMEM = no;
          RTC_SYSTOHC = no;
          RUNTIME_TESTING_MENU = no;
          SATA_PMP = no;
          SCSI_LOWLEVEL = no;
          SCSI_PROC_FS = no;
          SECRETMEM = no;
          SECURITYFS = no;
          SECURITY_SELINUX = no;
          SERIO_SERPORT = no;
          SGETMASK_SYSCALL = no;
          SND_HDA_CODEC_ALC260 = no;
          SND_HDA_CODEC_ALC262 = no;
          SND_HDA_CODEC_ALC268 = no;
          SND_HDA_CODEC_ALC269 = no;
          SND_HDA_CODEC_ALC662 = no;
          SND_HDA_CODEC_ALC680 = no;
          SND_HDA_CODEC_ALC861 = no;
          SND_HDA_CODEC_ALC861VD = no;
          SND_HDA_CODEC_ALC880 = no;
          SND_HDA_CODEC_HDMI_NVIDIA = no;
          SND_HDA_CODEC_HDMI_NVIDIA_MCP = no;
          SND_HDA_CODEC_HDMI_SIMPLE = no;
          SND_HDA_CODEC_HDMI_TEGRA = no;
          SND_PCM_TIMER = no;
          SND_PROC_FS = no;
          SND_SOC_SOF_ALDERLAKE = no;
          SND_SOC_SOF_APOLLOLAKE = no;
          SND_SOC_SOF_CANNONLAKE = no;
          SND_SOC_SOF_COFFEELAKE = no;
          SND_SOC_SOF_COMETLAKE = no;
          SND_SOC_SOF_ELKHARTLAKE = no;
          SND_SOC_SOF_GEMINILAKE = no;
          SND_SOC_SOF_ICELAKE = no;
          SND_SOC_SOF_JASPERLAKE = no;
          SND_SOC_SOF_KABYLAKE = no;
          SND_SOC_SOF_LUNARLAKE = no;
          SND_SOC_SOF_MERRIFIELD = no;
          SND_SOC_SOF_METEORLAKE = no;
          SND_SOC_SOF_PANTHERLAKE = no;
          SND_SOC_SOF_SKYLAKE = no;
          SND_SST_ATOM_HIFI2_PLATFORM_ACPI = no;
          SND_SUPPORT_OLD_API = no;
          TCP_CONG_BIC = no;
          TCP_CONG_CUBIC = no;
          TCP_CONG_HTCP = no;
          TCP_CONG_WESTWOOD = no;
          TRACEFS_AUTOMOUNT_DEPRECATED = no;
          USB_PCI_AMD = no;
          VHOST_ENABLE_FORK_OWNER_CONTROL = no;
          VIDEO_CAMERA_LENS = no;
          VIDEO_CAMERA_SENSOR = no;
          WMI_BMOF = no;
          X86_DEBUG_FPU = no;
          X86_MPPARSE = no;
          X86_VSYSCALL_EMULATION = no;
          ZONE_DMA = no;
        };
      });

    kernelParams = [
      "lockdown_hibernate"
      "iommu=force"
      "intel_iommu=on"
      "amd_iommu=force_isolation"
      "page_alloc.shuffle=1"
      "pti=on"
      "random.trust_bootloader=off"
      "random.trust_cpu=off"
      "proc_mem.force_override=never"
      "hash_pointers=always"
      "slub_debug=ZF"
      "zswap.enabled=1"
      "zswap.shrinker_enabled=1"
      "vdso32=0"
    ];

    kernel.sysctl = {
      "fs.protected_symlinks" = 1;
      "fs.protected_hardlinks" = 1;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "fs.suid_dumpable" = 0;
      "kernel.io_uring_disabled" = 2;
      "kernel.kptr_restrict" = 2;
      "kernel.perf_event_paranoid" = 3;
      "kernel.unprivileged_bpf_disabled" = 1;
      "kernel.yama.ptrace_scope" = 1;
      "net.core.bpf_jit_harden" = 2;
      "net.core.rmem_max" = 5000000;
      "net.core.wmem_max" = 5000000;
      "net.ipv4.conf.all.accept_redirects" = false;
      "net.ipv4.conf.all.rp_filter" = 2;
      "net.ipv4.conf.all.secure_redirects" = false;
      "net.ipv4.conf.all.send_redirects" = false;
      "net.ipv4.conf.default.accept_redirects" = false;
      "net.ipv4.conf.default.rp_filter" = 2;
      "net.ipv4.conf.default.secure_redirects" = false;
      "net.ipv4.conf.default.send_redirects" = false;
      "net.ipv4.tcp_thin_linear_timeouts" = 1;
      "net.ipv6.conf.all.accept_redirects" = false;
      "net.ipv6.conf.all.use_tempaddr" = 2;
      "net.ipv6.conf.default.accept_redirects" = false;
    };

    kernelModules = [ "configs" ];

    initrd = {
      includeDefaultModules = false;
      systemd.contents."/etc/lvm/lvm.conf".text = lib.mkAfter ''
        global/use_aio = 0
      '';
    };
  };

  environment.etc."lvm/lvm.conf".text = lib.mkAfter ''
    global/use_aio = 0
  '';
}
