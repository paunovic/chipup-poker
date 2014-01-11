unit uPB_RegisterParams;

interface

uses
  Winapi.Windows, System.Classes, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_RegisterParams = class(TProtobufBaseObject)
  private
    const
      FN_EMAIL = 1;
      FN_PASSWORD = 2;
      FN_DISPLAYNAME = 3;

    var
      FEMail: AnsiString;
      FPassword: AnsiString;
      FDisplayName: AnsiString;

  public
    constructor Create(const AEMail: AnsiString; const APassword: AnsiString; const ADisplayName: AnsiString); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property EMail: AnsiString read FEMail;
    property Password: AnsiString read FPassword;
    property DisplayName: AnsiString read FDisplayName;
  end;

implementation

uses
  System.SysUtils, pbPublic;


constructor TPB_RegisterParams.Create(const AEMail: AnsiString; const APassword: AnsiString; const ADisplayName: AnsiString);
begin
  FEMail := AEMail;
  FPassword := APassword;
  FDisplayName := ADisplayName;
end;

procedure TPB_RegisterParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
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
      FN_EMAIL: FEMail := AProtobufReader.readString;
      FN_PASSWORD: FPassword := AProtobufReader.readString;
      FN_DISPLAYNAME: FDisplayName := AProtobufReader.readString;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_RegisterParams.GetProtobuf: TProtoBufOutput;
var
  pboutput: TProtoBufOutput;
begin
  pboutput := TProtoBufOutput.Create;
  pboutput.writeString(FN_EMAIL, FEMail);
  pboutput.writeString(FN_PASSWORD, FPassword);
  pboutput.writeString(FN_DISPLAYNAME, FDisplayName);
  result := pboutput;
end;

end.
