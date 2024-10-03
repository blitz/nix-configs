{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixpkgs-unstable-llvm.url = "github:blitz/nixpkgs/kernel-lld";

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
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixos-hardware
    , nixpkgs-unstable
    , nixpkgs-unstable-llvm
    , home-manager
    , hercules-ci
    , fenix
    , dwarffs
    , flake-parts
    , hercules-ci-effects
    , lanzaboote
    , lix-module
    , kernelDev
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
          in
          {
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

                # Living on the edge.
                lix-module.nixosModules.default

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

            avalon = withSystem "x86_64-linux" (ctx@{ config, inputs', ... }: nixpkgs.lib.nixosSystem {
              specialArgs = {
                packages = config.packages;
              };

              modules = [
                ({ config, packages, lib, ... }: {
                  nixpkgs.overlays = [
                    fenix.overlays.default
                    kernelDevOverlayX86

                    (self: super: let
                      pkgsLLVM = nixpkgs-unstable-llvm.legacyPackages.x86_64-linux.pkgsLLVM;
                    in {
                      linuxPackages_latest = (self.linuxPackagesFor ((pkgsLLVM.linuxPackages_latest.kernel.override {
                        structuredExtraConfig = with lib.kernel; {
                          LTO_CLANG_FULL = yes;

                          # This kernel is only used on baremetal.
                          HYPERVISOR_GUEST = lib.mkForce no;
                          PARAVIRT = lib.mkForce no;

                          # Not used.
                          FTRACE = lib.mkForce no;
                          KPROBES = lib.mkForce no;

                          # AMD doesn't have IBT, but shadow stacks (since Zen 3)!
                          X86_USER_SHADOW_STACK = yes;

                          # Not strictly necessary, but not useful on AMD either.
                          X86_INTEL_MEMORY_PROTECTION_KEYS = lib.mkForce no;

                          # No need to dynamically set this.
                          PREEMPT_DYNAMIC = no;
                        };

                        # There are lots of PARAVIRT-related options that don't apply, if we disable PARAVIRT.
                        ignoreConfigErrors = true;
                      }).overrideAttrs (old: {
                        # Breaks with clang otherwise:
                        #
                        # error: argument unused during compilation: '-fno-strict-overflow'
                        #hardeningDisable = old.hardeningDisable ++ [ "strictoverflow" ];
                      })));
                    })
                  ];

                  environment.systemPackages = [
                    packages.gitlab-timelogs
                  ];
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
            });

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

      perSystem = { config, pkgs, system, ... }: {
        packages = {
          inherit (nixpkgs-unstable.legacyPackages."${system}") gitlab-timelogs;
        };
      };
    });
}
