{ pkgs, lib, ... }: {

  home.packages = with pkgs; [
    bc
    cachix
    dmidecode
    dool                        # dstat is EOL
    file
    gnupg
    libarchive
    man-pages
    nix-top
    nmap
    psmisc
    pv
    pwgen
    tig
    wget
    zile
    unzip
    inetutils                   # telnet
  ];
  
  nixpkgs.config.allowUnfree = true;

  programs = {
    ssh = {
      enable = true;
      forwardAgent = true;

      matchBlocks = {
        "*" = {
          extraOptions = {
            "IdentityAgent" = "~/.1password/agent.sock";
          };
        };
      };
    };

    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;

      userName = "Julian Stecklina";
      userEmail = lib.mkDefault "js@alien8.de";

      lfs.enable = true;

      aliases = {
        sed = "! git grep -z --full-name -l '.' | xargs -0 sed -i -e";
        unstage = "reset HEAD --";
      };

      extraConfig = {
        init.defaultBranch = "main";
        rebase.autosquash = true;
        diff.algorithm = "patience";
        credential.helper = "${pkgs.gitAndTools.gitFull}/bin/git-credential-libsecret";
      };
    };

    emacs = {
      enable = true;
      extraConfig = builtins.readFile ../dotfiles/emacs/js-config.el;

      extraPackages = (epkgs: (with epkgs.melpaPackages;
        [
          clang-format
          cmake-mode
          dante
          dhall-mode
          direnv
          editorconfig
          flymake-hlint
          ggtags
          haskell-mode
          hlint-refactor
          lsp-haskell
          lsp-mode
          lsp-ui
          magit
          markdown-mode
          nasm-mode
          nix-mode
          rustic
          toml-mode
          use-package
          web-mode
          yaml-mode
          go-mode
          flycheck-grammarly
          flycheck-inline
          flycheck-pos-tip
        ]));
    };
  };

  home.file =
    {
      ".config/mpv/mpv.conf".text = ''
        hwdec=auto
      '';

      ".config/rustfmt/rustfmt.toml".text = ''
        edition = "2021"
      '';

      # For gnome-boxes
      ".config/libvirt/qemu.conf".text = ''
        nvram = [ "/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd" ]
      '';

      ".config/zed/settings.json".text =
        let
          zedSettings = {
            lsp = {
              "rust-analyzer" = {
                binary = {
                  path = "/run/current-system/sw/bin/rust-analyzer";
                };
              };
            };
          };
        in
        builtins.toJSON zedSettings;
    };
}
