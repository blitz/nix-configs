{ inputs, config, lib, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  home-manager.users.julian = import ../home-modules/nixos-gnome.nix;
}
