self: super:

let
  emacsWithPackages = (super.emacsPackagesNgGen super.emacs).emacsWithPackages;
  nixfmtSrc = self.fetchFromGitHub {
    owner = "serokell";
    repo = "nixfmt";
    rev = "v0.3.0";
    sha256 = "1agzz8v6lpxjr1arfb6q00r1yk4nwyh8l3sd8zmdhvh2zckip6j9";
  };
in {
  emacs = emacsWithPackages
    (epkgs: (with epkgs.melpaPackages; [ magit nix-mode yaml-mode ]));

  # nixfmt is in nixpkgs as of September 2019. We can switch to that later.
  nixfmt = import nixfmtSrc { installOnly = true; };
}
