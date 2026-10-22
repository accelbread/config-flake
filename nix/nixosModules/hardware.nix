# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  config,
  lib,
  ...
}:
let
  cfg = config.ab.hardware;

  mkConfigEntry =
    name: enable: settings:
    lib.mkIf enable {
      inherit name;
      patch = null;
      structuredExtraConfig = settings;
    };

  inherit (lib.kernel)
    yes
    no
    module
    freeform
    ;

  inherit (config.boot.kernelPackages) kernel;
  onStable = lib.mkIf (lib.versionOlder kernel.version "6.19.0");
  onLatest = lib.mkIf (lib.versionAtLeast kernel.version "6.19.0");
in
{
  options.ab.hardware = {
    cpu = {
      amd.enable = lib.mkEnableOption "AMD CPU support";
      intel.enable = lib.mkEnableOption "Intel CPU support";
    };
    gpu = {
      amd.enable = lib.mkEnableOption "AMD GPU support";
      xe = {
        enable = lib.mkEnableOption "Intel Xe GPU support";
        force = lib.mkEnableOption "Force Xe driver over i915";
      };
    };
    memory.ecc.enable = lib.mkEnableOption "ECC RAM support";
    disk.sata.enable = lib.mkEnableOption "SATA disk support";
    input.mouse.ps2.enable = lib.mkEnableOption "PS/2 mouse support";
    wireless.intel.ax200-ax210.enable = lib.mkEnableOption "Intel AX200/AX210 support";
    audio.intel.sof.enable = lib.mkEnableOption "SOF support";
    audio.realtek.alc882.enable = lib.mkEnableOption "Realtek ALC882 support";
  };

  config = {
    hardware.cpu = {
      amd.updateMicrocode = lib.mkIf cfg.cpu.amd.enable true;
      intel.updateMicrocode = lib.mkIf cfg.cpu.intel.enable true;
    };
    boot = {
      kernelParams =
        lib.optional cfg.cpu.intel.enable "intel_iommu=on"
        ++ lib.optional cfg.cpu.amd.enable "amd_iommu=force_isolation";
      kernelPatches = [
        (mkConfigEntry "AMD CPU" cfg.cpu.amd.enable {
          AMD_IOMMU = yes;
          CPU_SUP_AMD = yes;
          KVM_AMD = module;
          PERF_EVENTS_AMD_BRS = yes;
          PERF_EVENTS_AMD_UNCORE = no;
          SENSORS_K10TEMP = module;
          X86_AMD_PSTATE = yes;
          X86_MCE_AMD = yes;
        })
        (mkConfigEntry "AMD ECC" (cfg.cpu.amd.enable && cfg.memory.ecc.enable) {
          RAS = yes;
          AMD_ATL = module;
          EDAC = module;
          EDAC_AMD64 = module;
          MEMORY_FAILURE = yes;
          RAS_FMPM = no;
        })
        (mkConfigEntry "Intel CPU" cfg.cpu.intel.enable {
          CPU_SUP_INTEL = yes;
          INTEL_IOMMU = yes;
          INTEL_IOMMU_DEFAULT_ON = yes;
          INTEL_IOMMU_PERF_EVENTS = no;
          INTEL_IOMMU_SCALABLE_MODE_DEFAULT_ON = no;
          INTEL_IOMMU_SVM = yes;
          INTEL_IDLE = yes;
          KVM_INTEL = module;
          PERF_EVENTS_INTEL_CSTATE = module;
          PERF_EVENTS_INTEL_UNCORE = module;
          SENSORS_CORETEMP = module;
          X86_INTEL_PSTATE = yes;
          X86_INTEL_TSX_MODE_OFF = yes;
          X86_MCE_INTEL = yes;
          X86_PKG_TEMP_THERMAL = module;
        })
        (mkConfigEntry "AMD GPU" cfg.gpu.amd.enable {
          DEVICE_PRIVATE = yes;
          DMABUF_MOVE_NOTIFY = onStable yes;
          DRM_AMDGPU = module;
          DRM_AMD_DC = yes;
          HSA_AMD = yes;
          HSA_AMD_P2P = yes;
          HSA_AMD_SVM = yes;
          MEMORY_HOTPLUG = yes;
          MEMORY_HOTREMOVE = yes;
          PCI_P2PDMA = yes;
          ZONE_DEVICE = yes;
        })
        (mkConfigEntry "Intel Xe GPU" cfg.gpu.xe.enable {
          DRM_XE = module;
          DRM_XE_FORCE_PROBE = lib.mkIf cfg.gpu.xe.force (freeform "*");
          DRM_XE_PAGEMAP = no;
          MEMORY_HOTPLUG = yes;
          MEMORY_HOTREMOVE = yes;
          ZONE_DEVICE = yes;
        })
        (mkConfigEntry "SATA disk" cfg.disk.sata.enable {
          ATA = module;
          ATA_FORCE = no;
          ATA_SFF = no;
          BLK_DEV_SD = module;
          SATA_AHCI = module;
          SATA_PMP = no;
          SCSI = module;
          SCSI_CONSTANTS = yes;
        })
        (mkConfigEntry "PS/2 mouse" cfg.input.mouse.ps2.enable {
          MOUSE_PS2 = module;
          MOUSE_PS2_ALPS = no;
          MOUSE_PS2_BYD = no;
          MOUSE_PS2_CYPRESS = no;
          MOUSE_PS2_FOCALTECH = no;
          MOUSE_PS2_LIFEBOOK = no;
          MOUSE_PS2_LOGIPS2PP = no;
          MOUSE_PS2_SYNAPTICS = no;
          MOUSE_PS2_SYNAPTICS_SMBUS = no;
          MOUSE_PS2_TRACKPOINT = no;
          SERIO = module;
          SERIO_SERPORT = no;
        })
        (mkConfigEntry "Intel AX200/AX210" cfg.wireless.intel.ax200-ax210.enable {
          BT_HCIBTUSB = module;
          BT_HCIBTUSB_AUTOSUSPEND = yes;
          BT_HCIBTUSB_BCM = no;
          BT_HCIBTUSB_MTK = no;
          BT_HCIBTUSB_RTL = no;
          IWLMVM = module;
          IWLWIFI = module;
          IWLWIFI_DEVICE_TRACING = no;
        })
        (mkConfigEntry "Intel SOF audio" cfg.audio.intel.sof.enable {
          SND_SOC = module;
          SND_SOC_SDCA_FDL = onLatest no;
          SND_SOC_SOF_HDA_AUDIO_CODEC = yes;
          SND_SOC_SOF_HDA_LINK = yes;
          SND_SOC_SOF_INTEL_TOPLEVEL = yes;
          SND_SOC_SOF_PCI = module;
          SND_SOC_SOF_TOPLEVEL = yes;
          SND_SST_ATOM_HIFI2_PLATFORM_ACPI = no;
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
          SND_SOC_SOF_NOVALAKE = onLatest no;
          SND_SOC_SOF_PANTHERLAKE = lib.mkDefault no;
          SND_SOC_SOF_TIGERLAKE = lib.mkDefault no;
          SND_SOC_SOF_SKYLAKE = no;
        })
        (mkConfigEntry "Realtek ALC882" cfg.audio.realtek.alc882.enable {
          SND_HDA_CODEC_REALTEK = module;
          SND_HDA_CODEC_ALC882 = module;
          SND_HDA_CODEC_ALC260 = no;
          SND_HDA_CODEC_ALC262 = no;
          SND_HDA_CODEC_ALC268 = no;
          SND_HDA_CODEC_ALC269 = no;
          SND_HDA_CODEC_ALC662 = no;
          SND_HDA_CODEC_ALC680 = no;
          SND_HDA_CODEC_ALC861 = no;
          SND_HDA_CODEC_ALC861VD = no;
          SND_HDA_CODEC_ALC880 = no;
        })
      ];
    };
  };
}
