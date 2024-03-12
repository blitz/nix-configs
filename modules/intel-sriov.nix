{ config, pkgs, lib, ... }:
{
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_6_6.override {
    argsOverride = rec {
      src = pkgs.fetchFromGitHub {
        owner = "intel";
        repo = "linux-intel-lts";
        rev = "lts-v6.6.15-linux-240219T085932Z";
        hash = "sha256-JJXvPK0nDeoGAIIE/gAjbHor47DYYg0Uugs0fFXqrVc=";
      };
      version = "6.6.15";
      modDirVersion = "6.6.15";
    };
  });

  boot.kernelParams = [
    "i915.enable_guc=3"
    "i915.max_vfs=7"
  ];

  boot.kernelPatches = [
    {
        name = "sriov-config";
        patch = null;

        # No extra config needed?
        extraConfig = "";
    }
  ];
}
