cd ..
set PATH=cpp-generator/;%PATH%
protoc message.proto --delphi_out=cpp-generator/output
copy /y "cpp-generator\output\uServerCodes.pas" "client\src\uServerCodes.pas"
cd cpp-generator