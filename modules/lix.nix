{ pkgs, ... }:
let
  lixPkgs = pkgs.lixPackageSets.stable;
in {
  # Infinite recursion?
  #
  # nixpkgs.overlays = [ (final: prev: {
  #   inherit (final.lixPackageSets.stable)
  #     nixpkgs-review
  #     nix-direnv
  #     nix-eval-jobs
  #     nix-fast-build
  #     colmena;
  # }) ];

  programs.direnv.nix-direnv.package = lixPkgs.nix-direnv;
  nix.package = lixPkgs.lix;
}
