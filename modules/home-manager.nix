{ config, pkgs, lib, ... }:
let
  isWork = config.networking.hostName == "babylon" || config.networking.hostName == "avalon";
in
{
  home-manager.users.julian = { pkgs, ... }: {

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

    # Autostart hack from:
    # https://github.com/nix-community/home-manager/issues/3447#issuecomment-2213029759
    home.file = let
      autostartPrograms = [
        # Nothing here yet
      ]
      ++ (lib.optional config.programs._1password-gui.enable config.programs._1password-gui.package);
    in
      {
        ".config/rustfmt/rustfmt.toml".text = ''
          edition = "2021"
        '';
      } //
      builtins.listToAttrs (map
        (pkg: {
          name = ".config/autostart/" + pkg.pname + ".desktop";
          value =
            if pkg ? desktopItem
            then {
              # Application has a desktopItem entry.
              # Assume that it was made with makeDesktopEntry, which exposes a
              # text attribute with the contents of the .desktop file
              text = pkg.desktopItem.text;
            }
            else {
              # Application does *not* have a desktopItem entry. Try to find a
              # matching .desktop name in /share/applications
              source = with builtins; let
                appsPath = "${pkg}/share/applications";
                # function to filter out subdirs of /share/applications
                filterFiles = dirContents: lib.attrsets.filterAttrs (_: fileType: elem fileType ["regular" "symlink"]) dirContents;
              in (
                # if there's a desktop file by the app's pname, use that
                if (pathExists "${appsPath}/${pkg.pname}.desktop")
                then "${appsPath}/${pkg.pname}.desktop"
                  # if there's not, find the first desktop file in the app's directory and assume that's good enough
                else
                  (
                    if pathExists "${appsPath}"
                    then "${appsPath}/${head (attrNames (filterFiles (readDir "${appsPath}")))}"
                    else throw "no desktop file for app ${pkg.pname}"
                  )
              );
            };
        })
        autostartPrograms);

    home.stateVersion = "23.05";
  };
}
