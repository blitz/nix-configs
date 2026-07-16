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

  nixpkgs.overlays = [
    (final: prev: {
      inherit (inputs.celler.packages.${pkgs.stdenv.hostPlatform.system}) celler;
    })
  ];

  environment.systemPackages = [
    pkgs.celler
  ];
}
