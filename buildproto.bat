set PATH=C:/dev-cpp/bin/;cpp-protobuf-generator/;%PATH%
cd cpp-protobuf-generator
make
cd ..
protoc message.proto backend.proto common.proto -o message.desc --delphi_out=cpp-protobuf-generator/output/
copy /y "cpp-protobuf-generator\output\Poker.Protobufs.Enum.ServerCodes.pas" "client\src\modules\protobuf\objects\Poker.Protobufs.Enum.ServerCodes.pas"
