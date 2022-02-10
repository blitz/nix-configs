{ pkgsUnstable }:
{ config, pkgs, ... }:
{
  environment.systemPackages = [
    pkgsUnstable.rust-analyzer
    pkgs.gcc

    # From rust-overlay
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" ];
    })
  ];
}
