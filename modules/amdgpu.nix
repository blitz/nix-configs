{ config, pkgs, lib, ... }:

{
  hardware.amdgpu = {
    #initrd.enable = true;
    opencl.enable = true;
  };

  services.kmscon.enable = true;
  
  boot.kernelPatches = [
    {
      name = "amdgpu";
      patch = null;

      structuredExtraConfig = with lib.kernel; {
        DRM_AMDGPU = yes;
      };
    }
  ];
}
