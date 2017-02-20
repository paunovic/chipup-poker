{ stdenv, protobuf }:

stdenv.mkDerivation {
  name = "generator";
  buildInputs = [ protobuf ];
  src = ./.;
  installPhase = ''
    mkdir -pv $out/bin/
    cp -vi protoc-gen-delphi $out/bin/
  '';
}
