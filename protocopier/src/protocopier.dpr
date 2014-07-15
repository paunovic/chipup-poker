program protocopier;

{$APPTYPE CONSOLE}

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Protocopier.Common in 'Protocopier.Common.pas';

const
  CPP_PROTO_PATH    = '..\..\..\..\cpp-protobuf-generator\output';
  DELPHI_PROTO_PATH = '..\..\..\..\client\src\modules\protobuf\objects';
  REGEX_SEARCH      = '^.*\.(pas)$';

var
  delphi_protobufs: TStringList;
  cpp_protobufs: TStringList;
  fname, fhash: String;
  C1, C2: Integer;
  self_path: String;

begin
  self_path := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  delphi_protobufs := TStringList.Create;
  try
    cpp_protobufs := TStringList.Create;
    try
      EnumerateFiles(self_path + DELPHI_PROTO_PATH, REGEX_SEARCH, 0, delphi_protobufs);
      EnumerateFiles(self_path + CPP_PROTO_PATH, REGEX_SEARCH, 0, cpp_protobufs);

      for C1 := 0 to delphi_protobufs.Count - 1 do
      begin
        fname := ExtractFileName(delphi_protobufs[C1]);
        fhash := MD5File(delphi_protobufs[C1]);
        for C2 := 0 to cpp_protobufs.Count - 1 do
          if ExtractFileName(cpp_protobufs[C2]) = fname then
          begin
            if MD5File(cpp_protobufs[C2]) <> fhash then
            begin
              CopyFile(PChar(cpp_protobufs[C2]), PChar(delphi_protobufs[C1]), FALSE);
              WriteLn(Format('%s replaced', [fname]));
            end;
            Break;
          end;
      end;
    finally
      cpp_protobufs.Free;
    end;
  finally
    delphi_protobufs.Free;
  end;
end.
