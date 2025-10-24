{ config, flakeSelf, inputs, pkgs, ... }:
let
  fenixToolchain = pkgs.fenix.stable.withComponents [
    "cargo"
    "clippy"
    "rust-src"
    "rustc"
    "rustfmt"
  ];
in {

  nixpkgs.overlays = [
    inputs.fenix.overlays.default

    (final: prev: {
      inherit (inputs.kernelDev.packages.x86_64-linux) kernelDevTools;
    })

    (final: prev: {
      cloud-hypervisor = prev.cloud-hypervisor.override {
        rustPlatform = pkgs.makeRustPlatform {
          cargo = fenixToolchain;
          rustc = fenixToolchain;
        };
      };
    })
  ];

  nix.extraOptions = ''
    # This is for direnv.
    keep-outputs = true
  '';

  environment.systemPackages = with pkgs; [
    # Github / Gitlab
    gh
    glab

    # Nix
    nixpkgs-fmt
    nil
    nix-diff
    nix-tree
    nix-output-monitor          # nom
    nixpkgs-review

    # Misc
    global
    # gdb
    # trace-cmd
    # kernelshark

    # Elm Development
    # elmPackages.elm-format
    # elmPackages.elm-language-server
    # elmPackages.elm

    # Rust development
    pkgs.rust-analyzer-nightly
    pkgs.gcc
    fenixToolchain

    # This should reference the correct architecture...
    (pkgs.writeShellScriptBin "cloud-hypervisor-dev" ''
      exec nix develop "$@" ${flakeSelf}#nixosConfigurations.ig-11.pkgs.cloud-hypervisor
    '')

    # Linux kernel development. See: https://github.com/blitz/kernel-dev
    kernelDevTools

    # C++ development
    pkgs.clang-tools
  ];
}
