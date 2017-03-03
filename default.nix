let
  pkgs = import <nixpkgs> {};
  callPackage = pkgs.newScope self;
  self = {
    server = callPackage ./server {};
    generator = callPackage ./cpp-protobuf-generator/generator.nix {};
    generator-env = callPackage ./cpp-protobuf-generator/env.nix {};
    wine-util = callPackage ./utils/wine.nix {};
    tests = import ./tests { system = "x86_64-linux"; };
    test-driver = callPackage ./tests/test-driver.nix {};
  };
in self
