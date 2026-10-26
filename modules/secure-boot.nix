{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  environment.systemPackages = [
    pkgs.sbctl
  ];

  boot.lanzaboote = {
    enable = true;

    configurationLimit = 4;
    pkiBundle = lib.mkDefault "/etc/secureboot";

    allowUnsigned = true;

    autoGenerateKeys.enable = true;
    autoEnrollKeys.enable = true;

    measuredBoot = {
      enable = true;
      pcrs = [
        0
        4
        7
      ];
    };
  };

  boot.kernelPatches = [
    {
      name = "lockdown";
      patch = null;

      # Auto-sign kernel modules and enable kernel lockdown.
      #
      # Trimming kernel symbols is safe, because we can't build
      # out-of-tree modules anymore anyway.
      extraConfig = ''
        MODULE_SIG y
        MODULE_SIG_FORCE y
        MODULE_SIG_ALL y
        MODULE_SIG_KEY_TYPE_ECDSA y

        TRIM_UNUSED_KSYMS y

        SECURITY_LOCKDOWN_LSM y
        SECURITY_LOCKDOWN_LSM_EARLY y
        LOCK_DOWN_KERNEL_FORCE_INTEGRITY y
      '';
    }

    {
      name = "builtin-keyboard";
      patch = null;

      structuredExtraConfig = with lib.kernel; {
        # USB Host Controller
        USB_SUPPORT = yes;
        USB = yes;
        USB_XHCI_HCD = yes;
        USB_XHCI_PCI = yes;

        # HID Support
        HID = yes;
        HID_GENERIC = yes;
        USB_HID = yes;

        # Input Device Core
        INPUT = yes;
        INPUT_EVDEV = yes;
      };
    }
  ];

}
