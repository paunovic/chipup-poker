set PATH=C:/dev-cpp/bin/;cpp-protobuf-generator/;%PATH%
cd cpp-protobuf-generator
mkdir output
make
cd ..
protoc message.proto backend.proto common.proto -o message.desc --delphi_out=cpp-protobuf-generator/output/
protocopier\bin\Win32\release\protocopier.exe