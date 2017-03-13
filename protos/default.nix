{ runCommandCC, protobuf }:

runCommandCC "protos" { buildInputs = [ protobuf ]; } ''
mkdir -pv $out/lib $out/include/poker/

cp -vi ${../message.proto} message.proto
cp -vi ${../extra.proto} extra.proto
cp -vi ${../common.proto} common.proto
cp -vir ${../google} google
protoc --cpp_out=. message.proto extra.proto common.proto

for x in *.cc; do $CXX -c $x -o ''${x%.*}.o ; done
cp -vi *.h *.cc $out/include/poker/
ar rvs $out/lib/libprotos.a *.o
''
