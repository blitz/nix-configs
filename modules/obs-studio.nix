{ config, pkgs, ... }:
{
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];

  environment.systemPackages = with pkgs; [
    # OBS Studio
    (wrapOBS {
      plugins = [
        # Add plugins here.
      ];
    })
  ];
}
