{ stdenv, protobuf, libressl }:

stdenv.mkDerivation {
  name = "test-driver";
  buildInputs = [ protobuf libressl ];
  src = ./.;
  enableParallelBuilding = true;
}
