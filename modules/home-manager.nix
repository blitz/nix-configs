{ config, pkgs, ... }:
{
  home-manager.users.julian = { pkgs, ... }: {

    home.stateVersion = "23.05";
  };
}
