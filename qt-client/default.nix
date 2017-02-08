with import <nixpkgs> {};

{
  client = pkgs.qt5.callPackage ./client.nix {};
}
