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
        nixos-hardware.nixosModules.lenovo-thinkpad-l14-amd
      ];
    };

    # For Hercules CI.
    ciNix = flake-compat-ci.lib.recurseIntoFlakeWith {
      flake = self;

      # Optional. Systems for which to perform CI.
      # By default, every system attr in the flake will be built.
      # Example: [ "x86_64-darwin" "aarch64-linux" ];
      systems = [ "x86_64-linux" ];
    };
  };
}
