{ pkgs, lib, inputs, ... }:
let
  base-kernel = pkgs.linux_latest;
in
{
  security = {
    forcePageTableIsolation = true;
    lsm = [ "lockdown" ];
  };

  boot = {
    kernelPackages = pkgs.linuxPackagesFor (base-kernel.override (prev: {
      extraMakeFlags = prev.extraMakeFlags or [ ] ++ [ "INSTALL_MOD_STRIP=1" ];
    }));
    kernelPatches = [
      {
        name = "nixpkgs hardened config";
        patch = null;
        structuredExtraConfig = import
          (inputs.nixpkgs + /pkgs/os-specific/linux/kernel/hardened/config.nix)
          { inherit (pkgs) stdenv lib; inherit (base-kernel) version; };
      }
      {
        name = "hardening";
        patch = null;
        structuredExtraConfig = with lib.kernel; {
          AIO = lib.mkForce no;
          AUDIT = yes;
          BPF_JIT_ALWAYS_ON = lib.mkForce yes;
          BUG_ON_DATA_CORRUPTION = yes;
          CHECKPOINT_RESTORE = lib.mkForce no;
          COMPAT_BRK = no;
          DEBUG_FS_ALLOW_NONE = yes;
          DEBUG_WX = yes;
          DEVMEM = no;
          DEVPORT = no;
          EXPERT = yes;
          FORTIFY_SOURCE = yes;
          HARDENED_USERCOPY = yes;
          HW_RANDOM_TPM = yes;
          INIT_ON_ALLOC_DEFAULT_ON = yes;
          INIT_ON_FREE_DEFAULT_ON = yes;
          INIT_STACK_ALL_ZERO = yes;
          IOMMU_DEFAULT_DMA_STRICT = yes;
          KCMP = yes;
          KEXEC = no;
          KEXEC_SIG = yes;
          KEXEC_SIG_FORCE = yes;
          KSTACK_ERASE = yes;
          LDISC_AUTOLOAD = no;
          LEGACY_PTYS = no;
          LEGACY_TIOCSTI = no;
          LEGACY_VSYSCALL_NONE = yes;
          LIST_HARDENED = yes;
          LOCK_DOWN_KERNEL_FORCE_INTEGRITY = yes;
          MEM_SOFT_DIRTY = lib.mkForce (option unset);
          MODIFY_LDT_SYSCALL = no;
          MODULE_HASHES = yes;
          MODULE_SIG = no;
          MODULE_SIG_FORCE = yes;
          MSEAL_SYSTEM_MAPPINGS = yes;
          NFS_DEBUG = unset;
          PANIC_ON_OOPS = yes;
          PROC_VMCORE = lib.mkForce no;
          RANDOMIZE_BASE = yes;
          RANDOMIZE_KSTACK_OFFSET_DEFAULT = yes;
          RANDOM_KMALLOC_CACHES = yes;
          RESET_ATTACK_MITIGATION = yes;
          SECURITY = yes;
          SECURITY_DMESG_RESTRICT = yes;
          SECURITY_LOCKDOWN_LSM = lib.mkForce yes;
          SECURITY_LOCKDOWN_LSM_EARLY = yes;
          SECURITY_NETWORK = yes;
          SECURITY_YAMA = yes;
          SLAB_FREELIST_HARDENED = yes;
          SLAB_FREELIST_RANDOM = yes;
          SLAB_MERGE_DEFAULT = no;
          SYN_COOKIES = yes;
          UBSAN = yes;
          UBSAN_BOUNDS = yes;
          UBSAN_TRAP = yes;
          UID16 = no;
          USERFAULTFD = lib.mkForce no;
          X86_16BIT = unset;
          X86_IOPL_IOPERM = no;
          ZERO_CALL_USED_REGS = yes;
        } // lib.optionalAttrs (pkgs.system == "aarch64-linux") {
          ARM64_SW_TTBR0_PAN = yes;
        };
      }
    ] ++ (map (p: { name = baseNameOf p; patch = p; })
      (lib.filesystem.listFilesRecursive ./kernel-patches));

    kernelParams = [
      "lockdown_hibernate"
      "init_on_alloc=1"
      "init_on_free=1"
      "iommu.passthrough=0"
      "iommu.strict=1"
      "iommu=force"
      "intel_iommu=on"
      "amd_iommu=force_isolation"
      "randomize_kstack_offset=on"
      "page_alloc.shuffle=1"
      "slab_nomerge"
      "mce=0"
      "vsyscall=none"
      "random.trust_bootloader=off"
      "random.trust_cpu=off"
    ];

    kernel.sysctl = {
      "dev.tty.ldisc_autoload" = 0;
      "dev.tty.legacy_tiocsti" = false;
      "fs.protected_symlinks" = 1;
      "fs.protected_hardlinks" = 1;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "kernel.dmesg_restrict" = true;
      "kernel.ftrace_enabled" = false;
      "kernel.io_uring_disabled" = 2;
      "kernel.kexec_load_disabled" = true;
      "kernel.kptr_restrict" = 2;
      "kernel.perf_event_paranoid" = 3;
      "kernel.sysrq" = 0;
      "kernel.unprivileged_bpf_disabled" = 1;
      "kernel.yama.ptrace_scope" = 1;
      "net.core.bpf_jit_harden" = 2;
      "net.core.rmem_max" = 2500000;
      "net.core.wmem_max" = 2500000;
      "net.ipv4.conf.all.accept_redirects" = false;
      "net.ipv4.conf.all.rp_filter" = 2;
      "net.ipv4.conf.all.secure_redirects" = false;
      "net.ipv4.conf.all.send_redirects" = false;
      "net.ipv4.conf.default.accept_redirects" = false;
      "net.ipv4.conf.default.rp_filter" = 2;
      "net.ipv4.conf.default.secure_redirects" = false;
      "net.ipv4.conf.default.send_redirects" = false;
      "net.ipv6.conf.all.accept_redirects" = false;
      "net.ipv6.conf.all.use_tempaddr" = 2;
      "net.ipv6.conf.default.accept_redirects" = false;
    };
  };
}
