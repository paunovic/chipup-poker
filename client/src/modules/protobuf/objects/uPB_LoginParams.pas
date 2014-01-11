unit uPB_LoginParams;

interface

uses
  Winapi.Windows, System.Classes, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_LoginParams = class(TProtobufBaseObject)
  private
    const
      FN_USERNAME = 1;
      FN_PASSWORD = 2;

    var
      FUsername: AnsiString;
      FPassword: AnsiString;

  public
    constructor Create(const AUsername: AnsiString; const APassword: AnsiString); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Username: AnsiString read FUsername;
    property Password: AnsiString read FPassword;
  end;

implementation

uses
  System.SysUtils, pbPublic;


constructor TPB_LoginParams.Create(const AUsername: AnsiString; const APassword: AnsiString);
begin
  FUsername := AUsername;
  FPassword := APassword;
end;

procedure TPB_LoginParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag         : Integer;
  wire_type   : Integer;
  field_number: Integer;
  endpos      : Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_USERNAME: FUsername := AProtobufReader.readString;
      FN_PASSWORD: FPassword := AProtobufReader.readString;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_LoginParams.GetProtobuf: TProtoBufOutput;
var
  pboutput: TProtoBufOutput;
begin
  pboutput := TProtoBufOutput.Create;
  pboutput.writeString(FN_USERNAME, FUsername);
  pboutput.writeString(FN_PASSWORD, FPassword);
  result := pboutput;
end;

end.
