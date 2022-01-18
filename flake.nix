{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-compat-ci.url = "github:hercules-ci/flake-compat-ci";
  };

  outputs = { self, nixpkgs, nixos-hardware, flake-compat, flake-compat-ci }: {
    nixosConfigurations = {
      canaan = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./host/canaan/configuration.nix
          ./host/canaan/hardware-configuration.nix

          # There is a Thinkpad L14 AMD module, but it disables the
          # IOMMU.
          nixos-hardware.nixosModules.lenovo-thinkpad
          nixos-hardware.nixosModules.common-pc-laptop-ssd
          nixos-hardware.nixosModules.common-pc-laptop-acpi_call
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-gpu-amd
        ];
      };

      first-temple = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./host/first-temple/configuration.nix
          ./host/first-temple/hardware-configuration.nix

          nixos-hardware.nixosModules.common-pc-ssd
          nixos-hardware.nixosModules.common-cpu-intel
        ];
      };
    };

    # For Hercules CI.
    ciNix = flake-compat-ci.lib.recurseIntoFlakeWith {
      flake = self;

      # Optional. Systems for which to perform CI.
      systems = [ "x86_64-linux" ];
    };
  };
}
