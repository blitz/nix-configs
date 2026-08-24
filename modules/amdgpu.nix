{
  config,
  pkgs,
  lib,
  ...
}:

{
  boot.kernelParams = [
    # May help with AMDGPU gfxhub page faults.
    #
    # TODO: We have a discrete GPU now. Let's see!
    # "amdgpu.sg_display=0"
  ];

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
