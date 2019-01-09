let
pkgs = import <nixpkgs> {};
in
  [
    pkgs.elmPackages.elm
    pkgs.elmPackages.elm-format
    pkgs.yarn
  ]
