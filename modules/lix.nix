{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.blitz.lix;
in
{
  options = {
    blitz.lix.flavor = lib.mkOption {
      type = lib.types.enum [
        "stable"
        "latest"
      ];
      default = "latest";
    };
  };

  config =
    let
      lixFlavors = {
        inherit (pkgs.lixPackageSets) stable latest;
      };

      lixPkgs = lixFlavors.${cfg.flavor};
    in
    {
      programs.direnv.nix-direnv.package = lixPkgs.nix-direnv;
      nix.package = lixPkgs.lix;
    };
}
