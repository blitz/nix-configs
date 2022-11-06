{ config, pkgs, lib, ... }:

{
  imports =
    [
      ../../modules/common.nix
      ../../modules/cachix.nix
    ];

  services.hercules-ci-agent = {
    enable = true;
    settings.concurrentTasks = 2;
  };

  # Nix 2.8.1 has problems with Hercules CI.
  nix.package = pkgs.nixUnstable;

  system.autoUpgrade = {
    enable = true;
    flake = "github:blitz/nix-configs";
    flags = [
      " --no-write-lock-file"
    ];
  };
}
