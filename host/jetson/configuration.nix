{ inputs, pkgs, modulesPath, ... }: {
  # TODO Will be able to consume this from CTRL-OS modules:
  # {{
  nixpkgs.hostPlatform = "aarch64-linux";

  boot.initrd.availableKernelModules = [
    # Enable PCIe support at boot time
    "phy_tegra194_p2u"
    "pcie_tegra194"
    # Enable USB support for USB Boot
    "xhci-tegra"
    "phy-tegra-xusb"
  ];
  # }}

  imports = [
    ../../modules/common.nix
    ../../modules/cachix.nix
    ../../modules/home-manager.nix

    inputs.nixos-hardware.nixosModules.common-pc-ssd

    ./disko.nix
  ];

  systemd.network.enable = true;
  systemd.network.wait-online.enable = true;

  networking = {
    useNetworkd = true;
    useDHCP = false;
    interfaces.enP8p1s0.useDHCP = true;
  };

  boot.initrd.systemd.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "jetson";
  networking.domain = "localhost";

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
