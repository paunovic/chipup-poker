let
  config = {
    packageOverrides = pkgs_in: {
      runCommandCC = if pkgs_in ? runCommandCC then pkgs_in.runCommandCC else pkgs_in.runCommand;
    };
  };
  pkgs = import <nixpkgs> { inherit config; };
  callPackage = pkgs.newScope self;
  multiArchSet = system: let arch_pkgs = import <nixpkgs> { inherit system config; }; in rec {
    client = arch_pkgs.qt5.callPackage ./qt-client/client.nix { inherit protos; };
    protos = arch_pkgs.callPackage ./protos { inherit (arch_pkgs) runCommandCC; };
  };
  self = rec {
    client = pkgs.enableDebugging (pkgs.qt5.callPackage ./qt-client/client.nix { inherit protos; });
    server = callPackage ./server {};
    generator = callPackage ./cpp-protobuf-generator/generator.nix {};
    generator-env = callPackage ./cpp-protobuf-generator/env.nix {};
    wine-util = callPackage ./utils/wine.nix {};
    tests = import ./tests { system = "x86_64-linux"; };
    test-driver = callPackage ./tests/test-driver.nix {};
    protos = callPackage ./protos { };
    "x86_64-darwin" = multiArchSet "x86_64-darwin";
  };
in self
