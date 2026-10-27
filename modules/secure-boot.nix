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

  boot.initrd.systemd.emergencyAccess = "$y$j9T$A2U8SmdosL3CNAuUH1lpJ/$0CXHTyO5gDCaXMTnqEHC.iD4W4ryD3zky68f8IG80EB";
  systemd.enableEmergencyMode = true;

  boot.kernelPatches = [
    # Is this still needed after this PR?
    # https://github.com/NixOS/nixpkgs/pull/571181
    #     {
    #       name = "lockdown";
    #       patch = null;
    #
    #       # Auto-sign kernel modules and enable kernel lockdown.
    #       #
    #       # Trimming kernel symbols is safe, because we can't build
    #       # out-of-tree modules anymore anyway.
    #       structuredExtraConfig = with lib.kernel; {
    #         MODULE_SIG = yes;
    #         MODULE_SIG_FORCE = yes;
    #         MODULE_SIG_ALL = yes;
    #         MODULE_SIG_KEY_TYPE_RSA = yes;
    #
    #         TRIM_UNUSED_KSYMS = yes;
    #
    #         SECURITY_LOCKDOWN_LSM = yes;
    #         SECURITY_LOCKDOWN_LSM_EARLY = yes;
    #         LOCK_DOWN_KERNEL_FORCE_INTEGRITY = yes;
    #       };
    #     }
    {
      name = "builtin-essentials";
      patch = null;

      structuredExtraConfig = with lib.kernel; {
        # USB Host Controller
        USB_SUPPORT = yes;
        USB = yes;
        USB_XHCI_HCD = yes;
        USB_XHCI_PCI = yes;

        HID = yes;
        HID_GENERIC = yes;
        USB_HID = yes;
        INPUT = yes;
        INPUT_EVDEV = yes;

        XFS_FS = yes;
        VFAT_FS = yes;
        FAT_FS = yes;
        FUSE_FS = yes;
        EFIVAR_FS = yes;
        AUTOFS_FS = yes;
        CONFIGFS_FS = yes;

        BLK_DEV_NVME = yes;
        NVME_AUTH = lib.mkForce yes;
        BLK_DEV_DM = yes;
        X86_PMEM_LEGACY = yes;
        DAX = yes;
        DM_CRYPT = yes;
        CRYPTO_AES_NI_INTEL = yes;
        ENCRYPTED_KEYS = yes;
        TRUSTED_KEYS = yes;
      };
    }
  ];

}
