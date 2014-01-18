set PATH=cpp-protobuf-generator/;%PATH%
mkdir android\
mkdir android\src
protoc message.proto -o message.desc --java_out=android/src/ --delphi_out=delphi/
