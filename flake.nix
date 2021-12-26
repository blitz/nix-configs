{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };
  
  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.canaan = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./canaan.nix
        ./canaan-hardware.nix
        ./cachix.nix
        ./nixbuild.nix
        nixos-hardware.nixosModules.lenovo-thinkpad-l14-amd
      ];
    };
  };
}
