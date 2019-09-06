{ pkgs ? import <nixpkgs> {} }:

{
  emacs = pkgs.callPackage ./emacs.nix {};
}
