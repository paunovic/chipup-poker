{ clangStdenv, stdenv, protobuf, libressl, lua, libevent, protos }:

let
  lib = stdenv.lib;
  filter = name: type: let baseName = baseNameOf (toString name); in (
    lib.hasSuffix ".cpp" baseName ||
    lib.hasSuffix ".cc" baseName ||
    lib.hasSuffix ".h" baseName ||
    baseName == "Makefile"
  );
in stdenv.mkDerivation {
  preferLocalBuild = true;
  name = "test-driver";
  buildInputs = [ protobuf libressl lua libevent protos ];
  src = builtins.filterSource filter ./.;
  enableParallelBuilding = true;
  dontStrip = true;
}
