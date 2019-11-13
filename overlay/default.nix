self: super:

let
  emacsWithPackages = (super.emacsPackagesNgGen super.emacs).emacsWithPackages;
in {
  emacs = emacsWithPackages
    (epkgs: (with epkgs.melpaPackages; [ magit nix-mode yaml-mode direnv nasm-mode ]));

}
