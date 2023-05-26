{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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

    tuxedo-nixos = {
      url = "github:blitz/tuxedo-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, hercules-ci, rust-overlay, dwarffs,
                     tuxedo-nixos, flake-parts, hercules-ci-effects, lanzaboote }:
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
                hardware.tuxedo-control-center.package = tuxedo-nixos.packages.x86_64-linux.default;
              })

              ./host/babylon/configuration.nix
              ./host/babylon/hardware-configuration.nix

              tuxedo-nixos.nixosModules.default

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

          # installation-media = nixpkgs.lib.nixosSystem {
          #   system = "x86_64-linux";

          #   modules = [
          #     ./host/installation-media/configuration.nix
          #   ];
          # };

          ig-11 = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            modules = [
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
      ];
      perSystem = { config, ... }: {
      };
    };
}
