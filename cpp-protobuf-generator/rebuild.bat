cd ..
set PATH=cpp-generator/;%PATH%
protoc message.proto --delphi_out=client/src/modules/protobuf/objects/
cd cpp-generator
