{ system }:

with import  <nixpkgs/nixos/lib/testing.nix> { inherit system; };

let
  mypkgs = import ../default.nix;
  makeLuaTest = makeLuaTest2 [];
  makeLuaTest2 = stack: source: mongo:
  makeTest {
    name = "lua-test";
    nodes = {
      server = { pkgs, ... }:
      {
        imports = [ ../nixos/poker.nix ../nixos/core.nix ];
        services.poker = {
          enable = true;
          autoSelfSigned = true;
          testingEnv = true;
          inherit stack;
        };
        services.klogd.enable = false;
        environment.systemPackages = [ mypkgs.test-driver pkgs.valgrind ];
        boot.kernelParams = [ "quiet" ];
        boot.kernelPackages =
          let
            self = pkgs.linuxPackagesFor (pkgs.linux.overrideDerivation (oldAttr: { patches = oldAttr.patches ++ [ ./fs-9p-Compare-qid.path-in-v9fs_test_inode.patch ]; })) self;
          in self;
      };
    };
    testScript = ''
      startAll;
      $server->waitForUnit("poker");
      $server->waitForOpenPort(12346);
      $server->sleep(5);
      print $server->succeed("time valgrind --leak-check=full test-driver -h localhost -e /home/poker/chipuppoker/cert.pem -c ${source}");
      ${if mongo != null then ''
        print $server->execute("echo '${mongo}' | mongo poker");
      '' else ""}
      $server->sleep(1);
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
  register_login = makeLuaTest ./register_login.lua null;
  makeClub = makeLuaTest ./makeClub.lua ''
    db.clubBalances.find().pretty()
  '';
  simpleGame = makeLuaTest ./simpleGame.lua null;
  scenario1 = makeLuaTest2 [ 0 1 2 3 4 5 6 7 8 ] ./scenario1.lua null;
}
