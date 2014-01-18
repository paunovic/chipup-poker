set PATH=cpp-protobuf-generator/;%PATH%
protoc message.proto --delphi_out=cpp-protobuf-generator/output/
copy /y "cpp-protobuf-generator\output\uServerCodes.pas" "client\src\modules\protobuf\objects\uServerCodes.pas"

