{ config, pkgs, ... }: {

  nix.extraOptions = ''
    # This is for direnv.
    keep-outputs = true
  '';

  environment.systemPackages = with pkgs; [
    # Github / Gitlab
    gh
    git-imerge
    glab

    # Model checking
    # (vscode-with-extensions.override {
    #   vscodeExtensions = with vscode-extensions; [
    #     ms-vscode.hexeditor
    #     ms-vscode.cpptools
    #     ms-vscode.cmake-tools
    #     ms-vscode.makefile-tools
    #     ms-vscode-remote.remote-ssh
    #     rust-lang.rust-analyzer
    #   ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    #     {
    #       name = "vscode-tlaplus";
    #       publisher = "alygin";
    #       version = "1.5.4";
    #       sha256 = "vZU0XIw/067gFFqfbhAoWYv8Why1YSM3WJ+bT4hAyVU=";
    #     }
    #   ];
    # })

    # Model checking
    # tlaplus
    # jdk

    # Nix
    nixpkgs-fmt
    nil
    nix-diff
    nix-tree
    nix-output-monitor          # nom
    nixpkgs-review

    # Misc
    global
    gdb
    trace-cmd
    kernelshark

    # Elm Development
    # elmPackages.elm-format
    # elmPackages.elm-language-server
    # elmPackages.elm

    # Rust development
    # TODO Uncomment when fenix has a newer version
    #pkgs.rust-analyzer-nightly
    pkgs.rust-analyzer

    pkgs.gcc
    (pkgs.fenix.stable.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])

    # Linux kernel development. See: https://github.com/blitz/kernel-dev
    kernelDevTools

    # C++ development
    pkgs.clang-tools_17         # We want the newest one for clangd/LSP
  ];
}
