{ config, pkgs, ... }:
{
  #nixpkgs.overlays = [ rust-overlay ];

  environment.systemPackages = [
    pkgs.rust-analyzer
    pkgs.gcc

    # From rust-overlay
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" ];
    })
  ];
}
