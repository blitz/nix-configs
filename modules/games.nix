{ config, pkgs, ... }:
{
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    # Gaming
    wineWowPackages.unstableFull
    lutris

    # Casual gaming
    cataclysm-dda
  ];
}
