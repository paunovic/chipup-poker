unit Protocopier.Common;

interface

uses
  Winapi.Windows, System.Classes;

function EnumerateFiles(const APath, ARegEx: String; const ASearchDepth: Integer; const AFiles: TStrings): Integer;
function MD5File(const AFileName: String): String;

implementation

uses
  System.SysUtils, IdHashMessageDigest, idHash, System.RegularExpressions;


function EnumerateFiles(const APath, ARegEx: String; const ASearchDepth: Integer; const AFiles: TStrings): Integer;
var
  SearchRec: TSearchRec;
  IsFound: Boolean;
begin
  result := 0;
  IsFound := FindFirst(IncludeTrailingPathDelimiter(APath) + '*.*', faAnyFile, SearchRec) = 0;
  while IsFound Do
  begin
    if (SearchRec.Name <> '.') and
       (SearchRec.Name <> '..') then
    begin
      if (ASearchDepth <> 0) and
         (SearchRec.Attr and faDirectory = faDirectory) then
        Inc(result, EnumerateFiles(IncludeTrailingPathDelimiter(APath) + SearchRec.Name, ARegEx, ASearchDepth - 1, AFiles))
      else
        if (TRegEx.IsMatch(SearchRec.Name, ARegEx, [roIgnoreCase])) and
           (SearchRec.Attr and faDirectory <> faDirectory) then
        begin
          AFiles.Add(IncludeTrailingPathDelimiter(APath) + SearchRec.Name);
          Inc(result);
        end;
    end;
    IsFound := FindNext(SearchRec) = 0;
  end;
  FindClose(SearchRec);
end;

function MD5File(const AFileName: String): String;
var
  IdMD5: TIdHashMessageDigest5;
  fs: TFileStream;
begin
  IdMD5 := TIdHashMessageDigest5.Create;
  try
    fs := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
    try
      result := IdMD5.HashStreamAsHex(FS)
    finally
      fs.Free;
    end;
  finally
    IdMD5.Free;
  end;
end;



end.
