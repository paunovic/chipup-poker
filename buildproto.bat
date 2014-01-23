set PATH=C:/dev-cpp/bin/;cpp-protobuf-generator/;%PATH%
cd cpp-protobuf-generator
c:\dev-cpp\bin\make
cd ..
protoc message.proto --delphi_out=cpp-protobuf-generator/output/
copy /y "cpp-protobuf-generator\output\uServerCodes.pas" "client\src\modules\protobuf\objects\uServerCodes.pas"