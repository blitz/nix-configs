{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    lix = {
      url = "git+https://git@git.lix.systems/lix-project/lix?ref=refs/tags/2.90-beta.1";
      flake = false;
    };

    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.lix.follows = "lix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager = {
    #   url = "github:nix-community/home-manager/release-23.11";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

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
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixos-hardware
    , home-manager
    , hercules-ci
    , fenix
    , dwarffs
    , flake-parts
    , hercules-ci-effects
    , lanzaboote
    , lix
    , lix-module
    , kernelDev
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
        nixosConfigurations =
          let
            kernelDevOverlayX86 = final: prev: {
              inherit (kernelDev.packages.x86_64-linux) kernelDevTools;
            };
          in {
            canaan = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";

              modules = [
                ({ config, ... }: {
                  nixpkgs.overlays = [ fenix.overlays.default kernelDevOverlayX86 ];
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
                # dwarffs.nixosModules.dwarffs

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

            avalon = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";

              modules = [
                ({ config, ... }: {
                  nixpkgs.overlays = [ fenix.overlays.default kernelDevOverlayX86 ];
                })

                ./host/avalon/configuration.nix
                ./host/avalon/hardware-configuration.nix

                home-manager.nixosModules.default

                nixos-hardware.nixosModules.framework-13-7040-amd

                # Living on the edge.
                lix-module.nixosModules.default

                lanzaboote.nixosModules.lanzaboote

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

            first-temple = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";

              modules = [
                ({ config, ... }: {
                  nixpkgs.overlays = [ fenix.overlays.default kernelDevOverlayX86 ];
                })

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
                hercules-ci.nixosModules.agent-service
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

            ig-11 = nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";

              modules = [
                ({ config, ... }: {
                  nixpkgs.overlays = [ fenix.overlays.default kernelDevOverlayX86 ];
                })

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

      perSystem = { config, ... }: { };
    };
}
