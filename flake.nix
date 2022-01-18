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
    nixosConfigurations.canaan = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./canaan.nix
        ./canaan-hardware.nix

        # There is a Thinkpad L14 AMD module, but it disables the
        # IOMMU.
        nixos-hardware.nixosModules.lenovo-thinkpad
        nixos-hardware.nixosModules.common-pc-laptop-ssd
        nixos-hardware.nixosModules.common-pc-laptop-acpi_call
        nixos-hardware.nixosModules.common-cpu-amd
        nixos-hardware.nixosModules.common-gpu-amd
      ];
    };

    # For Hercules CI.
    ciNix = flake-compat-ci.lib.recurseIntoFlakeWith {
      flake = self;

      # Optional. Systems for which to perform CI.
      systems = [ "x86_64-linux" ];
    };
  };
}
