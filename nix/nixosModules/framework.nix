# Copyright (C) Archit Gupta <archit@accelbread.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
{
  config,
  lib,
  ...
}:
let
  mkConfigEntry = name: settings: {
    inherit name;
    patch = null;
    structuredExtraConfig = settings;
  };

  inherit (lib.kernel) yes no module;
in
{
  config = lib.mkMerge [
    {
      hardware.framework.enableKmod = false;
      hardware.sensor.iio.enable = true;

      boot = {
        initrd.availableKernelModules = {
          nvme = true;
          atkbd = true;
          i8042 = true;
          thunderbolt = true;
          hid-sensor-hub = lib.mkForce false; # Enabled by IIO module
        };
        kernelPatches = [
          (mkConfigEntry "Framework 13" {
            ACPI_AC = module;
            ACPI_BATTERY = module;
            ACPI_EC = yes;
            ACPI_FAN = module;
            ACPI_PROCESSOR_AGGREGATOR = module;
            CHARGER_CROS_CONTROL = module;
            CHARGER_CROS_PCHG = no;
            CHROME_PLATFORMS = yes;
            CROS_EC = module;
            CROS_EC_CHARDEV = module;
            CROS_EC_LIGHTBAR = no;
            CROS_EC_LPC = module;
            CROS_EC_SENSORHUB = no;
            CROS_EC_SYSFS = no;
            CROS_KBD_LED_BACKLIGHT = module;
            CROS_TYPEC_SWITCH = no;
            CROS_USBPD_NOTIFY = no;
            HID_SENSOR_ALS = module;
            HID_SENSOR_HUB = module;
            HOTPLUG_PCI_PCIE = yes;
            I2C_HID = module;
            I2C_HID_ACPI = module;
            IIO = module;
            KEYBOARD_ATKBD = module;
            MFD_CROS_EC_DEV = module;
            SERIO = module;
            TYPEC = module;
            TYPEC_DP_ALTMODE = module;
            TYPEC_TBT_ALTMODE = module;
            TYPEC_UCSI = module;
            UCSI_ACPI = module;
            USB4 = module;
          })
        ];
      };
    }

    (lib.mkIf config.ab.hardware.cpu.intel.enable {
      hardware.intelgpu = {
        driver = lib.mkIf config.ab.hardware.gpu.xe.enable "xe";
        vaapiDriver = "intel-media-driver";
      };

      services = {
        thermald.enable = true;
        intel-lpmd.enable = true;
      };

      boot = {
        kernelModules = [ "coretemp" ];
        kernelPatches = [
          (mkConfigEntry "Framework 13 Intel" {
            I2C_DESIGNWARE_CORE = module;
            I2C_DESIGNWARE_PLATFORM = module;
            I2C_I801 = module;
            INT340X_THERMAL = module;
            INTEL_HFI_THERMAL = yes; # used by intel-lpmd
            INTEL_MEI = module;
            INTEL_PMC_CORE = module;
            INTEL_PMT_TELEMETRY = module;
            INTEL_POWERCLAMP = module; # used by thermald
            INTEL_RAPL = module;
            INTEL_VSEC = module;
            ITCO_WDT = module;
            MFD_INTEL_LPSS_PCI = module;
            THERMAL_GOV_USER_SPACE = yes; # used by thermald
            X86_INTEL_LPSS = yes;
          })
        ];
      };
    })
  ];
}
