self: super:

let
  emacsWithPackages = (super.emacsPackagesNgGen super.emacs).emacsWithPackages;
in {
  emacs = emacsWithPackages (epkgs:
    (with epkgs.melpaPackages; [
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
      #clang-format
    ]));

}
