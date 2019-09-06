{ emacs, emacsPackagesNgGen }:

let
  myEmacs = emacs;
  emacsWithPackages = (emacsPackagesNgGen myEmacs).emacsWithPackages;
in
  emacsWithPackages (epkgs: (with epkgs.melpaPackages; [
    magit nix-mode yaml-mode
  ]))
