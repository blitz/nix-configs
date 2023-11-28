{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hercules-ci = {
      url = "github:hercules-ci/hercules-ci-agent";

      # This breaks Hercules CI's cachix version.
      #
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
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

    tuxedo-rs = {
      # TODO Remove with NixOS 23.05. There is no hardware.tuxedo-rs in Nixpkgs.
      url = "github:AaronErhardt/tuxedo-rs/a77a9f6c64e6dd1ede3511934392cbc16271ef6b";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixos-hardware
    , home-manager
    , hercules-ci
    , rust-overlay
    , dwarffs
    , flake-parts
    , hercules-ci-effects
    , lanzaboote
    , tuxedo-rs
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
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
        nixosConfigurations = {
          canaan = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              ({ config, ... }: {
                nixpkgs.overlays = [ rust-overlay.overlays.default ];
              })

              ./host/canaan/configuration.nix
              ./host/canaan/hardware-configuration.nix

              home-manager.nixosModules.default

              # There is a Thinkpad L14 AMD module, but it disables the
              # IOMMU.
              nixos-hardware.nixosModules.lenovo-thinkpad
              nixos-hardware.nixosModules.common-pc-laptop-ssd
              nixos-hardware.nixosModules.common-cpu-amd
              nixos-hardware.nixosModules.common-gpu-amd

              lanzaboote.nixosModules.lanzaboote

              # For debugging.
              dwarffs.nixosModules.dwarffs

              ({ config, pkgs, ... }: {
                environment.systemPackages = [
                  pkgs.sbctl
                ];

                boot.lanzaboote = {
                  enable = true;

                  configurationLimit = 20;
                  pkiBundle = "/etc/secureboot";
                };
              })
            ];
          };

          babylon = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              ({ config, ... }: {
                nixpkgs.overlays = [ rust-overlay.overlays.default ];
              })

              ./host/babylon/configuration.nix
              ./host/babylon/hardware-configuration.nix

              home-manager.nixosModules.default

              tuxedo-rs.nixosModules.default

              dwarffs.nixosModules.dwarffs

              nixos-hardware.nixosModules.common-pc-laptop
              nixos-hardware.nixosModules.common-pc-laptop-ssd
              nixos-hardware.nixosModules.common-cpu-intel
            ];
          };

          second-temple = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              ./host/second-temple/configuration.nix
              ./host/second-temple/hardware-configuration.nix

              nixos-hardware.nixosModules.common-pc-ssd
              nixos-hardware.nixosModules.common-cpu-intel

              hercules-ci.nixosModules.agent-service
            ];
          };

          third-temple = nixpkgs.lib.nixosSystem {
            system = "aarch64-linux";

            modules = [
              ./host/third-temple/configuration.nix
              hercules-ci.nixosModules.agent-service
            ];
          };

          # installation-media = nixpkgs.lib.nixosSystem {
          #   system = "x86_64-linux";

          #   modules = [
          #     ./host/installation-media/configuration.nix
          #   ];
          # };

          ig-11 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
              ({ config, ... }: {
                nixpkgs.overlays = [ rust-overlay.overlays.default ];
              })

              ./host/ig-11/configuration.nix
              ./host/ig-11/hardware-configuration.nix

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

      perSystem = { config, ... }: { };
    };
}
