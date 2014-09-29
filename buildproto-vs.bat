set PATH=cpp-protobuf-generator\;cpp-protobuf-generator\cpp-protobuf-generator\debug\;%PATH%
cd cpp-protobuf-generator
mkdir output
"c:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" "cpp-protobuf-generator\cpp-protobuf-generator-vs.sln"
cd ..
protoc message.proto backend.proto common.proto -o message.desc --delphi_out=cpp-protobuf-generator/output/
protocopier\bin\Win32\release\protocopier.exe