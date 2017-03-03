{ stdenv, protobuf, libressl, lua }:

stdenv.mkDerivation {
  name = "test-driver";
  buildInputs = [ protobuf libressl lua ];
  src = ./.;
  enableParallelBuilding = true;
}
