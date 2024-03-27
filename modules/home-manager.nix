{ config, pkgs, ... }:
{
  home-manager.users.julian = { pkgs, ... }: {

    home.file.".config/rustfmt/rustfmt.toml".text = ''
      edition = "2021"
    '';

    programs = let
      isWork = config.networking.hostName == "babylon" || config.networking.hostName == "avalon";
    in {
      ssh = {
        enable = true;
        forwardAgent = true;

        matchBlocks = {
          "*" = {
            identityFile = [
              "~/.ssh/id_ed25519"
              "~/.id_pika"
              "~/.ssh/id_ecdsa_sk"
            ];
          };

          "artemis" = {
            hostname = "artemis";
            user = "jstecklina";
          };
        };
      };

      git = {
        enable = true;
        package = pkgs.gitAndTools.gitFull;

        userName = config.users.users.julian.description;
        userEmail = if isWork then "julian.stecklina@cyberus-technology.de" else "js@alien8.de";

        lfs.enable = true;

        aliases = {
          sed = "! git grep -z --full-name -l '.' | xargs -0 sed -i -e";
          unstage = "reset HEAD --";
        };

        extraConfig = {
          init.defaultBranch = "master";

          sendemail = if isWork then {
            smtpserver = "smtp.office365.com";
            smtpuser = "julian.stecklina@cyberus-technology.de";
            smtpencryption = "tls";
            port = 587;
          } else {
            # TODO
          };

          rebase.autosquash = true;
          diff.algorithm = "patience";
          credential.helper = "${pkgs.gitAndTools.gitFull}/bin/git-credential-libsecret";
        };
      };

      emacs = {
        enable = true;
        package = if config.services.xserver.desktopManager.gnome.enable
                  then pkgs.emacs29-pgtk
                  else pkgs.emacs29-nox;

        extraConfig = builtins.readFile ../dotfiles/emacs/js-config.el;

        extraPackages = (epkgs: (with epkgs.melpaPackages;
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
          ]));
      };
    };

    home.stateVersion = "23.05";
  };
}
