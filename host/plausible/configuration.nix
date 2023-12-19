{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect

    ../../modules/common.nix
    ../../modules/tailscale-exit-node.nix
    ../../modules/cachix.nix

    ../../modules/plausible.nix
  ];

  system.autoUpgrade.enable = true;

  services.hercules-ci-agent = {
    enable = true;
    settings.concurrentTasks = 4;
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:blitz/nix-configs";
    flags = [
      " --no-write-lock-file"
    ];
  };

  zramSwap.enable = true;
  networking.hostName = "plausible";
  networking.domain = "x86.lol";
  services.openssh.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "23.05"; # Did you read the comment?
}
