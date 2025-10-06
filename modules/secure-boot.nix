{ inputs, pkgs, lib, ... }: {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  
  environment.systemPackages = [
    pkgs.sbctl
  ];

  boot.lanzaboote = {
    enable = true;

    configurationLimit = 10;
    pkiBundle = lib.mkDefault "/etc/secureboot";
  };

  boot.kernelPatches = [
    {
      name = "lockdown";
      patch = null;

      # Auto-sign kernel modules and (not) enable kernel lockdown.
      #
      # Trimming kernel symbols is safe, because we can't build
      # out-of-tree modules anymore anyway.
      #
      # Kernel lockdown is currently disabled because it prevents suspend-to-ram?
      # [268876.864150] Lockdown: systemd-logind: hibernation is restricted; see man kernel_lockdown.7
      #
      # SECURITY_LOCKDOWN_LSM y
      # SECURITY_LOCKDOWN_LSM_EARLY y
      # LOCK_DOWN_KERNEL_FORCE_INTEGRITY y

      # Disabled: Incompatible with bcachefs module
      # extraConfig = ''
      #   MODULE_SIG y
      #   MODULE_SIG_FORCE y
      #   MODULE_SIG_ALL y

      #   TRIM_UNUSED_KSYMS y
      # '';
    }
  ];
}
