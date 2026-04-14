{
  pkgs,
  inputs,
  ...
}:
{
  nix = {
    settings = {
      substituters = [
        "https://cache.x86.lol/blitz"
      ];
      trusted-public-keys = [
        "blitz:2+sGBneZ99Gz4bIWifuLiHXDPINTgQgmhaFKUhNwpsU="
      ];
    };
  };

  environment.systemPackages = [
    inputs.celler.packages.${pkgs.stdenv.system}.celler
  ];
}
