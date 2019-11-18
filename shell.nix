{ pkgs ? import <nixpkgs> {} }:
with pkgs;
stdenv.mkDerivation {
  name = "math-quiz";
  buildInputs = import ./default.nix;
}
