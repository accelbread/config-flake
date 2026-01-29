{ pkgs, lib, inputs, ... }:
let
  base-kernel = pkgs.linux_latest;
in
{
  security = {
    forcePageTableIsolation = true;
    unprivilegedUsernsClone = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackagesFor base-kernel;
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
          RANDOM_KMALLOC_CACHES = yes;
          LIST_HARDENED = yes;
          INIT_ON_ALLOC_DEFAULT_ON = yes;
          RESET_ATTACK_MITIGATION = yes;
          IOMMU_DEFAULT_DMA_STRICT = yes;
          LDISC_AUTOLOAD = no;
          BPF_JIT_ALWAYS_ON = lib.mkForce yes;
          HW_RANDOM_TPM = yes;
          INIT_STACK_ALL_ZERO = yes;
          UBSAN = yes;
          UBSAN_BOUNDS = yes;
          UBSAN_TRAP = yes;
          USERFAULTFD = lib.mkForce no;
          X86_IOPL_IOPERM = no;
          ZERO_CALL_USED_REGS = yes;
          KEXEC = no;
          KEXEC_SIG = yes;
          KEXEC_SIG_FORCE = yes;
          KSTACK_ERASE = yes;
        };
      }
    ] ++ (map (p: { name = baseNameOf p; patch = p; })
      (lib.filesystem.listFilesRecursive ./kernel-patches));

    kernelParams = [
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
