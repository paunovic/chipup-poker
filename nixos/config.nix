{
  packageOverrides = pkgs: rec {
    poker = (pkgs.callPackage ../server {}).package;
    toxvpn = pkgs.callPackage ./toxvpn.nix {};
    buildbot = pkgs.buildbot.overrideDerivation (old: {
      patches = [ ./buildbot.patch ];
    });
  };
}
