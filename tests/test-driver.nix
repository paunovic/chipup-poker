{ stdenv, protobuf, libressl, lua, libevent }:

stdenv.mkDerivation {
  name = "test-driver";
  buildInputs = [ protobuf libressl lua libevent ];
  src = ./.;
  enableParallelBuilding = true;
}
