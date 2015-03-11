if exist "C:\dev-cpp\devcpp.exe" (GOTO :setdevcpp) else (if exist "c:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" (GOTO :setvs) else (GOTO :notfound))

:setdevcpp
	set PATH=C:/dev-cpp/bin/;cpp-protobuf-generator;%PATH%
	set buildcommand=make
	goto :build

:setvs
	set PATH=cpp-protobuf-generator/;cpp-protobuf-generator/cpp-protobuf-generator/debug/;%PATH%
	set buildcommand="c:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe" "cpp-protobuf-generator\cpp-protobuf-generator.sln"
	goto :build

:build
	cd cpp-protobuf-generator
	mkdir output
	%buildcommand%
	cd ..
	protoc message.proto backend.proto common.proto -o message.desc --delphi_out=cpp-protobuf-generator/output/
	protocopier\bin\Win32\release\protocopier.exe
	goto :end
	
:notfound
	echo "ERROR: Dev C++ or Visual Studio not found!"
	goto :end
	
:end