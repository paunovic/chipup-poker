let
  pkgs = import <nixpkgs> {};
  callPackage = pkgs.newScope self;
  runCommandCC = if pkgs ? runCommandCC then pkgs.runCommandCC else pkgs.runCommand;
  self = rec {
    client = pkgs.enableDebugging (pkgs.qt5.callPackage ./qt-client/client.nix { inherit protos; });
    server = callPackage ./server {};
    generator = callPackage ./cpp-protobuf-generator/generator.nix {};
    generator-env = callPackage ./cpp-protobuf-generator/env.nix {};
    wine-util = callPackage ./utils/wine.nix {};
    tests = import ./tests { system = "x86_64-linux"; };
    test-driver = callPackage ./tests/test-driver.nix {};
    protos = callPackage ./protos { inherit runCommandCC; };
  };
in self
