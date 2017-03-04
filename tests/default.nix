{ system }:

with import  <nixpkgs/nixos/lib/testing.nix> { inherit system; };

let
  mypkgs = import ../default.nix;
  makeLuaTest = source: makeTest {
    name = "lua-test";
    nodes = {
      server = { ... }:
      {
        imports = [ ../nixos/poker.nix ../nixos/core.nix ];
        services.poker = {
          enable = true;
          autoSelfSigned = true;
        };
        environment.systemPackages = [ mypkgs.test-driver ];
      };
    };
    testScript = ''
      startAll;
      $server->waitForUnit("poker");
      $server->waitForOpenPort(12346);
      $server->sleep(5);
      $server->mustSucceed("test-driver -h localhost -e /home/poker/chipuppoker/cert.pem -c ${source}");
      $server->shutdown;
    '';
  };
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
  register_login = makeLuaTest ./register_login.lua;
}
