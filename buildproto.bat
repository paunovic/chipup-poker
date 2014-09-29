set devcpp=0

if exist "C:\dev-cpp\devcpp.exe" (
	set devcpp=1
	set PATH=C:/dev-cpp/bin/;cpp-protobuf-generator;%PATH%
)

if %devcpp%==0 (
	set devcpp=0
	set PATH=cpp-protobuf-generator/;cpp-protobuf-generator/cpp-protobuf-generator/debug/;%PATH%
)

cd cpp-protobuf-generator
mkdir output

if %devcpp%==0  "c:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" "cpp-protobuf-generator\cpp-protobuf-generator.sln"
if %devcpp%==1 make

cd ..
protoc message.proto backend.proto common.proto -o message.desc --delphi_out=cpp-protobuf-generator/output/
protocopier\bin\Win32\release\protocopier.exe