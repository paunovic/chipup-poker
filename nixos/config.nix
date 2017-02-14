{
  packageOverrides = pkgs: rec {
    poker = (pkgs.callPackage ../server {}).package;
  };
}
