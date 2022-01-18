{ config, pkgs, lib, ... }:
let
  herculesContainerCfg = { config, pkgs, lib, ... }: {
    imports = [
      ../../modules/cachix.nix
    ];

    services.hercules-ci-agent.enable = true;
    services.hercules-ci-agent.settings.concurrentTasks = 2;
    nixpkgs.config.allowUnfree = true;

    nix.trustedUsers = [ "*" ];
    nix.distributedBuilds = true;

    # For some reason we always get a tmpfs in the container, even
    # though this ends up being to small.
    #
    # We need to set SYSTEMD_NSPAWN_TMPFS_TMP for systemd-nspawn. See
    # https://github.com/poettering/systemd/commit/a3905172d15c552bbed98445bae544bd82114920
    boot.tmpOnTmpfs = false;

    boot.cleanTmpDir = true;
  };

in
{
  nix.trustedUsers = [ "*" ];

  containers.hercules-blitz = {
    config = herculesContainerCfg;
    autoStart = true;
  };
  systemd.services."container@hercules-blitz".environment = {
    "SYSTEMD_NSPAWN_TMPFS_TMP" = "0";
  };

  containers.hercules-ukvly = {
    config = herculesContainerCfg;
    autoStart = true;
  };
  systemd.services."container@hercules-ukvly".environment = {
    "SYSTEMD_NSPAWN_TMPFS_TMP" = "0";
  };

}
