{
  description = "System Configuration";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-25.05/nixexprs.tar.xz";
    nixpkgs-unstable.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    ctrl-os-modules.url = "github:cyberus-ctrl-os/ctrl-os-modules";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sbomnix = {
      url = "github:tiiuae/sbomnix";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixos-hardware
    , home-manager
    , hercules-ci
    , fenix
    , flake-parts
    , hercules-ci-effects
    , lanzaboote
    , kernelDev
    , nix-link-cleanup
    , disko
    , ...
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
            nixosSystem = { system, modules, nixpkgs ? inputs.nixpkgs }: nixpkgs.lib.nixosSystem {
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
              nixpkgs = inputs.nixpkgs-unstable;

              modules = [
                ./host/avalon/configuration.nix
                ./host/avalon/hardware-configuration.nix
              ];
            };

            first-temple = nixosSystem {
              system = "x86_64-linux";
              nixpkgs = inputs.nixpkgs-unstable;

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

            canaan = nixosSystem {
              system = "x86_64-linux";
              nixpkgs = inputs.nixpkgs-unstable;

              modules = [
                inputs.disko.nixosModules.disko
                ./host/canaan/configuration.nix
              ];
            };

            ms-a2 = nixosSystem {
              system = "x86_64-linux";
              nixpkgs = inputs.nixpkgs-unstable;

              modules = [
                inputs.disko.nixosModules.disko
                ./host/ms-a2/configuration.nix
              ];
            };
          };
      };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem = { config, pkgs, system, lib, ... }: {

        # Make it possible to generate an SBOM for all NixOS configurations.
        #
        # packages = lib.attrsets.concatMapAttrs (k: v: lib.optionalAttrs (v.pkgs.system == system) {
        #   # sbomnix needs to rebuild the derivation to generate a runtime SBOM and thus can't run here.
        #   "make-sbom-${k}" = pkgs.writeShellScriptBin "sbom-${k}" ''
        #     ${lib.getExe' inputs.sbomnix.packages.${system}.sbomnix "sbomnix"} ${v.config.system.build.toplevel.outPath} "$@"
        #   '';
        # }) self.nixosConfigurations;
      };
    });
}
