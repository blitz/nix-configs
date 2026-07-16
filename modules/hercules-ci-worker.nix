{ inputs, config, ... }:
{
  imports = [
    ./secrets.nix

    inputs.hercules-ci.nixosModules.multi-agent-service
  ];

  age.secrets.blitz-cluster-join-token = {
    file = ../secrets/hci/blitz-cluster-join-token.key.age;
    owner = "hci-blitz";
  };

  age.secrets.blitz-binary-caches = {
    file = ../secrets/hci/blitz-binary-caches.json.age;
    owner = "hci-blitz";
  };

  age.secrets.blitz-secrets = {
    file = ../secrets/hci/blitz-secrets.json.age;
    owner = "hci-blitz";
  };

  age.secrets.celler-cluster-join-token = {
    file = ../secrets/hci/celler-cluster-join-token.key.age;
    owner = "hci-celler";
  };

  age.secrets.celler-binary-caches = {
    file = ../secrets/hci/celler-binary-caches.json.age;
    owner = "hci-celler";
  };

  age.secrets.celler-secrets = {
    file = ../secrets/hci/celler-secrets.json.age;
    owner = "hci-celler";
  };


  services.hercules-ci-agents = {
    blitz.settings = {
      concurrentTasks = 2;
      clusterJoinTokenPath = config.age.secrets.blitz-cluster-join-token.path;
      binaryCachesPath = config.age.secrets.blitz-binary-caches.path;
      secretsJsonPath = config.age.secrets.blitz-secrets.path;
    };

    celler.settings = {
      concurrentTasks = 2;
      clusterJoinTokenPath = config.age.secrets.celler-cluster-join-token.path;
      binaryCachesPath = config.age.secrets.celler-binary-caches.path;
      secretsJsonPath = config.age.secrets.celler-secrets.path;
    };
  };

  nix.gc = {
    automatic = true;
    dates = "monthly";
  };
}
