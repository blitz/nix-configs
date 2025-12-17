{ config, pkgs, ... }:
{
  # boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  # boot.kernelModules = [ "v4l2loopback" ];
  # boot.extraModprobeConfig = ''
  #   options v4l2loopback video_nr=10 card_label="OBS Video Source" exclusive_caps=1
  # '';

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };
}
