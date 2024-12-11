{ pkgs, ... }: {

  imports = [
    ./common.nix
  ];

  programs.ssh.matchBlocks."artemis" = {
    hostname = "artemis";
    user = "jstecklina";
  };

  programs.emacs.package = pkgs.emacs30-pgtk;

  programs.git.userEmail = "julian.stecklina@cyberus-technology.de";
  programs.git.extraConfig = {
    sendemail = {
      smtpserver = "smtp.office365.com";
      smtpuser = "julian.stecklina@cyberus-technology.de";
      smtpencryption = "tls";
      port = 587;

      linux = {
        tocmd = "`pwd`/scripts/get_maintainer.pl --nogit --nogit-fallback --norolestats --nol";
        cccmd = "`pwd`/scripts/get_maintainer.pl --nogit --nogit-fallback --norolestats --nom";
      };
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
  home.file =
    let
      autostartPrograms = [
        pkgs._1password-gui
      ];
    in
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
              filterFiles = dirContents: lib.attrsets.filterAttrs (_: fileType: elem fileType [ "regular" "symlink" ]) dirContents;
            in
            (
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
}
