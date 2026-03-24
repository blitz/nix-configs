{ inputs, config, ... }:
{
  imports = [
    ./secrets.nix
  ];

  age.secrets.hercules-ci-cluster-join-token.file = ../secrets/cluster-join-token.key.age;
  age.secrets.binary-caches.file = ../secrets/binary-caches.json.age;

  services.hercules-ci-agent = {
    enable = true;
    settings.concurrentTasks = 2;

    settings.clusterJoinTokenPath = config.age.secrets.hercules-ci-cluster-join-token.path;
    settings.binaryCachesPath = config.age.secrets.binary-caches.path;
  };

  nix.gc = {
    automatic = true;
    dates = "monthly";
  };
}
