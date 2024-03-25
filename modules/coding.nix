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
    pkgs.rust-analyzer-nightly
    pkgs.gcc
    (pkgs.fenix.stable.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])

    # C++ development
    pkgs.clang-tools_17         # We want the newest one for clangd/LSP

    # Legacy Coding
    # TODO Replace this with a mkShell environment with ncurses available.
    (pkgs.buildFHSUserEnv {
      name = "legacy-env";
      targetPkgs = pkgs: with pkgs; [
        gcc
        binutils
        gnumake
        coreutils
        patch
        zlib
        zlib.dev
        curl
        git
        m4
        bison
        flex
        acpica-tools
        ncurses.dev
        elfutils.dev
        openssl
        openssl.dev
        cpio
        pahole
        gawk
        perl
        bc
        nettools
        rsync
        gmp
        gmp.dev
        libmpc
        mpfr
        mpfr.dev
        zstd
        python3Minimal
        file
        unzip
        global

        # make isoimage
        syslinux
        cdrkit                  # genisoimage
      ];

      profile = ''
        export RUST_LIB_SRC=${pkgs.rustPlatform.rustLibSrc}
        unset LD_LIBRARY_PATH
      '';
    })
  ];

}
