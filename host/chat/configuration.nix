{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect

    ../../modules/common.nix
    ../../modules/tailscale-exit-node.nix
    ../../modules/cachix.nix
    ../../modules/matrix-synapse.nix
  ];

  system.autoUpgrade.enable = true;

  # /boot is very small.
  boot.loader.grub.configurationLimit = 3;

  networking.hostName = "chat";
  networking.domain = "x86.lol";

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICeIiTyh7jJD9x8N64kgUGDgeo3F96i5Av3tHvwePHq5'' ];

  system.stateVersion = "23.11";
}
