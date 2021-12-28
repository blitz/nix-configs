{ config, pkgs, ... }:

{
  nix = {
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
    '';
    buildMachines = [
      {
        hostName = "eu.nixbuild.net";
        maxJobs = 10;
        sshKey = "/root/.ssh/id_ed25519";
        sshUser = "root";
        supportedFeatures = [ "big-parallel" "benchmark" ];
        systems = [ "x86_64-linux" ];
        speedFactor = 2;
      }
    ];
  };
}