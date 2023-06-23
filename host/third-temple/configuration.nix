{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect

    ../../modules/common.nix
    ../../modules/cachix.nix
  ];

  services.hercules-ci-agent = {
    enable = true;
    settings.concurrentTasks = 4;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:blitz/nix-configs";
    flags = [
      " --no-write-lock-file"
    ];
  };

  zramSwap.enable = true;
  networking.hostName = "third-temple";
  networking.domain = "";
  services.openssh.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "23.05"; # Did you read the comment?
}
