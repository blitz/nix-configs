{ config, pkgs, ... }:
{
  home-manager.users.julian = { pkgs, ... }: {

    programs = {
      git = {
        enable = true;
        package = pkgs.gitAndTools.gitFull;

        userName = config.users.users.julian.description;
        userEmail = if config.networking.hostName == "babylon" then "julian.stecklina@cyberus-technology.de" else "js@alien8.de";

        aliases = {
          sed = "! git grep -z --full-name -l '.' | xargs -0 sed -i -e";
          unstage = "reset HEAD --";
        };

        extraConfig = {
          init.defaultBranch = "master";
          sendemail.smtpserver = "${pkgs.msmtp}/bin/msmtp";
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
