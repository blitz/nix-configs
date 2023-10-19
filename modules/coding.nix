{ pkgs, ... }: {

  environment.systemPackages = with pkgs; [
    # Github / Gitlab
    gitAndTools.gh
    glab

    # Model checking
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-vscode.hexeditor
        ms-vscode.cpptools
        ms-vscode.cmake-tools
        ms-vscode.makefile-tools
        ms-vscode-remote.remote-ssh
        rust-lang.rust-analyzer
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "vscode-tlaplus";
          publisher = "alygin";
          version = "1.5.4";
          sha256 = "vZU0XIw/067gFFqfbhAoWYv8Why1YSM3WJ+bT4hAyVU=";
        }
      ];
    })

    # Model checking
    tlaplus
    jdk

    # Emacs
    ((emacsPackagesFor pkgs.emacs29-pgtk).emacsWithPackages
      (epkgs: (with epkgs.melpaPackages;
      [
        clang-format
        cmake-mode
        dante
        dhall-mode
        direnv
        flymake-hlint
        haskell-mode
        hlint-refactor
        magit
        markdown-mode
        nasm-mode
        nix-mode
        use-package
        yaml-mode
        lsp-mode
        lsp-haskell
        lsp-ui
        rustic
        editorconfig
        toml-mode
        ggtags
        elm-mode
        (epkgs.callPackage ../emacs/promela-mode.nix { })
      ])))

    # Nix
    nixpkgs-fmt
    nil
    nix-diff
    nix-output-monitor          # nom
    nixpkgs-review

    # Misc
    global

    # Elm Development
    # elmPackages.elm-format
    # elmPackages.elm-language-server
    # elmPackages.elm

    # Rust development
    pkgs.rust-analyzer
    pkgs.gcc

    # From rust-overlay
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" ];
    })

    # Legacy Coding
    msmtp
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
      ];
    })
  ];

}
