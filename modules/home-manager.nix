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
            extraOptions = {
              "IdentityAgent" = "~/.1password/agent.sock";
            };
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

            linux = {
              tocmd = "`pwd`/scripts/get_maintainer.pl --nogit --nogit-fallback --norolestats --nol";
              cccmd = "`pwd`/scripts/get_maintainer.pl --nogit --nogit-fallback --norolestats --nom";
            };
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
          ]));
      };
    };

    # Enable experimental fractional scaling support in Gnome 45.
    dconf.settings = {
      "org/gnome/mutter" = {
        experimental-features = [ "scale-monitor-framebuffer" ];
      };
    };

    home.stateVersion = "23.05";
  };
}
