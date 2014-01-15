set PATH=cpp-generator/;%PATH%
mkdir android/
mkdir android/src/
protoc message.proto -o message.desc --java_out=android/src/ --delphi_out=delphi/
