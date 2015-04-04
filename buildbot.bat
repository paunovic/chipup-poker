set PATH=cpp-protobuf-generator/;%PATH%
mkdir android\
mkdir android\src
mkdir delphi
protoc message.proto -o message.desc --java_out=android/src/ --delphi_out=delphi/
