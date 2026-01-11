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
    jq
    fzf
    ripgrep
    mergiraf
    nix-index
  ];

  nixpkgs.config.allowUnfree = true;

  programs = {
    ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks = {
        "*" = {
          forwardAgent = true;

          extraOptions = {
            "IdentityAgent" = "~/.1password/agent.sock";
          };
        };
      };
    };

    git = {
      enable = true;
      package = pkgs.gitFull;

      lfs.enable = true;

      settings = {
        user = {
          name = "Julian Stecklina";
          email = lib.mkDefault "js@alien8.de";
        };

        alias = {
          sed = "! git grep -z --full-name -l '.' | xargs -0 sed -i -e";
          unstage = "reset HEAD --";
        };

        init.defaultBranch = "main";
        rebase.autosquash = true;
        diff.algorithm = "patience";
        credential.helper = "${pkgs.gitFull}/bin/git-credential-libsecret";

        # https://b4.docs.kernel.org/en/latest/contributor/send.html
        b4.send-endpoint-web = "https://lkml.kernel.org/_b4_submit";
        patatt = {
          signingkey = "ed25519:20250320";
          selector = "20250320";
        };
      };
    };

    emacs = {
      enable = true;
      extraConfig = builtins.readFile ../dotfiles/emacs/js-config.el;

      extraPackages = (epkgs: (with epkgs.melpaPackages;
        [
          clang-format
          cmake-mode
          direnv
          editorconfig
          flymake-hlint
          ggtags
          hlint-refactor
          company
          lsp-mode
          lsp-ui
          magit
          markdown-mode
          nasm-mode
          nix-mode
          rustic
          toml-mode
          #use-package
          web-mode
          yaml-mode
          flycheck-grammarly
          flycheck-inline
          flycheck-pos-tip
          fzf
          rg
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
    };

  programs.zed-editor = {
    enable = true;

    # https://github.com/NixOS/nixpkgs/pull/478690
    package = pkgs.zed-editor.overrideAttrs (old: { doCheck = false; });

    userSettings = {
      lsp = {
        "rust-analyzer" = {
          binary = {
            path = "/run/current-system/sw/bin/rust-analyzer";
          };
          initialization_options = {
            check = {
              command = "clippy";
            };
          };
        };

        "nixd" = {
          binary = {
            path = "/run/current-system/sw/bin/nixd";
          };
        };

        "nil" = {
          binary = {
            path = "/run/current-system/sw/bin/nil";
          };
        };
      };
    };

    # This generates the keymap file, but doesn't work. Weird!
    #
    # userKeymaps = [
    #   {
    #     context = "Editor";

    #     # Emacs-like code navigation.
    #     bindings = {
    #       "alt+." = "editor::GoToDefinition";
    #       "alt+," = "pane::GoBack";
    #     };
    #   }
    # ];
  };
}
