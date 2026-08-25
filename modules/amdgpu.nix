{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.blitz.amdgpu;
in
{
  options.blitz.amdgpu = {
    hwVideoDecoding = lib.mkEnableOption "hardware video decoding" // {
      default = true;
    };

    hwVideoEncoding = lib.mkEnableOption "hardware video encoding";
  };

  config = {
    boot.kernelParams = [
      # May help with AMDGPU gfxhub page faults.
      #
      # TODO: We have a discrete GPU now. Let's see!
      # "amdgpu.sg_display=0"
    ];

    nixpkgs.overlays = [
      (final: prev: {
        google-chrome = prev.google-chrome.override {
          commandLineArgs =
            [ ]
            ++ (lib.optional cfg.hwVideoDecoding "--enable-features=VaapiVideoDecoder")
            ++ (lib.optional cfg.hwVideoEncoding "--enable-features=VaapiVideoEncoder");
        };
      })
    ];

    nixpkgs.config.rocmSupport = true;

    hardware.amdgpu = {
      #
      #initrd.enable = true;

      opencl.enable = true;
    };

    services.kmscon.enable = true;
    services.lact.enable = true;

    boot.kernelPatches = [
      {
        name = "amdgpu";
        patch = null;

        structuredExtraConfig = with lib.kernel; {
          DRM_AMDGPU = yes;
        };
      }
    ];
  };
}
