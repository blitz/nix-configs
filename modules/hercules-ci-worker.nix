{ inputs, config, ... }:
{
  imports = [
    ./secrets.nix

    inputs.hercules-ci.nixosModules.multi-agent-service
  ];

  age.secrets.blitz-cluster-join-token = {
    file = ../secrets/blitz-cluster-join-token.key.age;
    owner = "hci-blitz";
  };

  age.secrets.blitz-binary-caches = {
    file = ../secrets/blitz-binary-caches.json.age;
    owner = "hci-blitz";
  };

  age.secrets.celler-cluster-join-token = {
    file = ../secrets/celler-cluster-join-token.key.age;
    owner = "hci-celler";
  };

  age.secrets.celler-binary-caches = {
    file = ../secrets/celler-binary-caches.json.age;
    owner = "hci-celler";
  };

  services.hercules-ci-agents = {
    blitz = {
      settings.concurrentTasks = 2;

      settings.clusterJoinTokenPath = config.age.secrets.blitz-cluster-join-token.path;
      settings.binaryCachesPath = config.age.secrets.blitz-binary-caches.path;
    };

    celler = {
      settings.concurrentTasks = 2;

      settings.clusterJoinTokenPath = config.age.secrets.celler-cluster-join-token.path;
      settings.binaryCachesPath = config.age.secrets.celler-binary-caches.path;
    };
  };

  nix.gc = {
    automatic = true;
    dates = "monthly";
  };
}
