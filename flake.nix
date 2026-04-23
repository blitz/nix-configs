{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    ctrl-os-modules = {
      url = "github:cyberus-ctrl-os/ctrl-os-modules";
      inputs.flake-parts.follows = "flake-parts";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hercules-ci = {
      url = "github:hercules-ci/hercules-ci-agent";

      # This breaks Hercules CI's cachix version.
      #
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kernelDev = {
      url = "github:blitz/kernel-dev";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fenix.follows = "fenix";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };

    celler = {
      url = "github:blitz/celler";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      hercules-ci,
      fenix,
      flake-parts,
      hercules-ci-effects,
      lanzaboote,
      kernelDev,
      disko,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, inputs, ... }:
      {
        imports = [
          hercules-ci-effects.flakeModule
        ];

        hercules-ci.flake-update = {
          enable = true;
          createPullRequest = false;

          nix.package = { pkgs, ... }: pkgs.lixPackageSets.stable.lix;

          baseMerge = {
            enable = true;
            method = "reset";
          };

          when = {
            hour = 0;
          };
        };

        herculesCI.ciSystems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        perSystem =
          { system, pkgs, ... }:
          {
            formatter = pkgs.nixfmt-tree;
          };

        flake = {
          nixosConfigurations =
            let
              nixosSystem =
                {
                  system,
                  modules,
                  nixpkgs ? inputs.nixpkgs,
                }:
                nixpkgs.lib.nixosSystem {
                  inherit system modules;

                  specialArgs = {
                    inherit inputs;
                    flakeSelf = self;
                    packages = self.packages."${system}";
                  };
                };
            in
            {
              avalon = nixosSystem {
                system = "x86_64-linux";

                modules = [
                  ./host/avalon/configuration.nix
                  ./host/avalon/hardware-configuration.nix
                ];
              };

              first-temple = nixosSystem {
                system = "x86_64-linux";

                modules = [
                  ./host/first-temple/configuration.nix
                  ./host/first-temple/hardware-configuration.nix
                ];
              };

              plausible = nixosSystem {
                system = "aarch64-linux";

                modules = [
                  ./host/plausible/configuration.nix
                ];
              };

              chat = nixosSystem {
                system = "aarch64-linux";

                modules = [
                  ./host/chat/configuration.nix
                ];
              };

              ms-a2 = nixosSystem {
                system = "x86_64-linux";

                modules = [
                  inputs.disko.nixosModules.disko
                  ./host/ms-a2/configuration.nix
                ];
              };

              jetson = nixosSystem {
                system = "aarch64-linux";

                modules = [
                  ./host/jetson/configuration.nix
                ];
              };
            };
        };

        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
      }
    );
}
