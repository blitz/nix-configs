{ config, pkgs, inputs, ... }:
{
  environment.systemPackages = [
    inputs.celler.packages.${pkgs.stdenv.system}.attic-client
  ];
}
