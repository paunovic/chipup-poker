{ stdenv, qmakeHook, makeQtWrapper, qtbase, qtscript, qtmultimedia, protobuf, protos }:

stdenv.mkDerivation {
  name = "poker-client";
  src = ./.;
  postConfigure = ''
    echo 1 > client/version.inc
  '';
  nativeBuildInputs = [ qmakeHook makeQtWrapper ];
  buildInputs = [ qmakeHook qtbase qtscript qtmultimedia protobuf protos ];
  enableParallelBuilding = true;
}
