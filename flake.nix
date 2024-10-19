{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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

    dwarffs = {
      url = "github:edolstra/dwarffs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    kernelDev = {
      url = "github:blitz/kernel-dev";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fenix.follows = "fenix";
    };

    nix-link-cleanup = {
      url = "github:blitz/nix-link-cleanup";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixos-hardware
    , nixpkgs-unstable
    , home-manager
    , hercules-ci
    , fenix
    , dwarffs
    , flake-parts
    , hercules-ci-effects
    , lanzaboote
    , lix-module
    , kernelDev
    , nix-link-cleanup
    }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ withSystem, inputs, ... }: {
      imports = [
        hercules-ci-effects.flakeModule
      ];

      hercules-ci.flake-update = {
        enable = true;
        createPullRequest = false;

        when = {
          hour = 0;
        };
      };

      herculesCI.ciSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      flake = {
        nixosConfigurations =
          let
            kernelDevOverlayX86 = final: prev: {
              inherit (kernelDev.packages.x86_64-linux) kernelDevTools;
            };

            nixosSystem = { system, modules }: nixpkgs.lib.nixosSystem {
              inherit system;

              specialArgs = {
                inherit inputs;
                packages = self.packages."$system";
              };

              modules = modules ++ [
                {
                  nixpkgs.overlays = [
                    fenix.overlays.default
                    kernelDevOverlayX86
                  ];
                }
              ];
            };
          in
          {
            canaan = nixosSystem {
              system = "x86_64-linux";

              modules = [
                ./host/canaan/configuration.nix
                ./host/canaan/hardware-configuration.nix

                # Living on the edge.
                lix-module.nixosModules.default

                nix-link-cleanup.nixosModules.default

                # For debugging.
                # dwarffs.nixosModules.dwarffs

                ({ config, pkgs, ... }: {
                  programs.nix-link-cleanup.enable = true;
                })
              ];
            };

            avalon = nixosSystem {
              system = "x86_64-linux";

              modules = [
                ./host/avalon/configuration.nix
                ./host/avalon/hardware-configuration.nix

                nixos-hardware.nixosModules.framework-13-7040-amd

                # Living on the edge.
                lix-module.nixosModules.default

                nix-link-cleanup.nixosModules.default

                ({ config, pkgs, ... }: {
                  programs.nix-link-cleanup.enable = true;
                })
              ];
            };

            first-temple = nixosSystem {
              system = "x86_64-linux";

              modules = [
                ./host/first-temple/configuration.nix
                ./host/first-temple/hardware-configuration.nix

                home-manager.nixosModules.default

                nixos-hardware.nixosModules.common-pc-ssd
                nixos-hardware.nixosModules.common-cpu-intel

                hercules-ci.nixosModules.agent-service
              ];
            };

            plausible = nixpkgs.lib.nixosSystem {
              system = "aarch64-linux";

              modules = [
                ./host/plausible/configuration.nix
              ];
            };

            chat = nixpkgs.lib.nixosSystem {
              system = "aarch64-linux";

              modules = [
                ./host/chat/configuration.nix
              ];
            };

            # installation-media = nixpkgs.lib.nixosSystem {
            #   system = "x86_64-linux";

            #   modules = [
            #     ./host/installation-media/configuration.nix
            #   ];
            # };

            ig-11 = nixosSystem {
              system = "x86_64-linux";

              modules = [
                ./host/ig-11/configuration.nix
                ./host/ig-11/hardware-configuration.nix

                home-manager.nixosModules.default

                nixos-hardware.nixosModules.common-pc-ssd

                # TODO Enable pstate later.
                nixos-hardware.nixosModules.common-cpu-amd
                nixos-hardware.nixosModules.common-gpu-amd
              ];
            };
          };
      };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = { config, pkgs, system, ... }: {
        packages = {
          inherit (nixpkgs-unstable.legacyPackages."${system}") gitlab-timelogs;
        };
      };
    });
}
