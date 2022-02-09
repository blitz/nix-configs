{ pkgsUnstable }:
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgsUnstable; [
    rust-analyzer
    cargo
    rustc
    gcc
  ];
}
