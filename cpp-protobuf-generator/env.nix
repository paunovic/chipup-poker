{ runCommand, protobuf, generator }:

runCommand "proto-generator-env" { buildInputs = [ generator protobuf ]; } ''
  exit 1
''
