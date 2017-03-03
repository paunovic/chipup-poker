{ system }:

with import  <nixpkgs/nixos/lib/testing.nix> { inherit system; };

let
  mypkgs = import ../default.nix;
in {
  boot = makeTest {
    name = "boot";
    nodes = {
      server = { ... }:
      {
        imports = [ ../nixos/poker.nix ../nixos/core.nix ];
        services.poker.enable = true;
      };
    };
    testScript = ''
      startAll;
      $server->waitForUnit("poker");
      $server->shutdown;
    '';
  };
}
