{
  pkgs,
  inputs,
  ...
}:
{
  nix = {
    settings = {
      substituters = [
        "https://blitz-cache.x86.lol/"
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
