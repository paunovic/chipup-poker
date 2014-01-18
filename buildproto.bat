set PATH=cpp-protobuf-generator/;%PATH%
protoc message.proto --delphi_out=output/
copy /y "cpp-generator\output\uServerCodes.pas" "client\src\modules\protobuf\objects\uServerCodes.pas"

