{
  config,
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
        "blitz:kcxXejFpSOHmN7xdiB3g5vl89ugTXDjZ59thWCArEvw="
      ];
    };
  };

  environment.systemPackages = [
    inputs.celler.packages.${pkgs.stdenv.system}.attic-client
  ];
}
