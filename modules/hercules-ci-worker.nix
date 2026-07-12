{ inputs, config, ... }:
{
  imports = [
    ./secrets.nix

    inputs.hercules-ci.nixosModules.multi-agent-service
  ];

  age.secrets.hercules-ci-cluster-join-token = {
    file = ../secrets/cluster-join-token.key.age;
    owner = "hci-blitz";
  };

  age.secrets.binary-caches = {
    file = ../secrets/binary-caches.json.age;
    owner = "hci-blitz";
  };

  services.hercules-ci-agents = {
    blitz = {
      settings.concurrentTasks = 2;

      settings.clusterJoinTokenPath = config.age.secrets.hercules-ci-cluster-join-token.path;
      settings.binaryCachesPath = config.age.secrets.binary-caches.path;
    };
  };

  nix.gc = {
    automatic = true;
    dates = "monthly";
  };
}
