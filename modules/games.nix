{ config, pkgs, ... }:
{

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    # Gaming
    wineWowPackages.unstableFull
    lutris

    # Debugging
    clinfo
    intel-gpu-tools
    radeontop

    # Podcasting
    zoom-us
  ];
}
