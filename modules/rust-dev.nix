{ config, pkgs, pkgsUnstable, rust-overlay, ... }:
{
  nixpkgs.overlays = [ rust-overlay ];

  environment.systemPackages = [
    pkgsUnstable.rust-analyzer
    pkgs.gcc

    # From rust-overlay
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" ];
    })
  ];
}
