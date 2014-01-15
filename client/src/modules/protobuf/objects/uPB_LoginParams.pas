unit uPB_LoginParams;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_LoginParams = class(TProtobufBaseObject)
  private
    const
      FN_USERNAME = 1;
      FN_PASSWORD = 2;

    var
      FUsername: AnsiString;
      FPassword: AnsiString;

    procedure SetUsername(const AValue: AnsiString);
    procedure SetPassword(const AValue: AnsiString);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Username: AnsiString read FUsername write SetUsername;
    property Password: AnsiString read FPassword write SetPassword;
  end;

implementation

uses
  pbPublic;

procedure TPB_LoginParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_USERNAME: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetUsername(AProtobufReader.readString);
      end;
      FN_PASSWORD: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetPassword(AProtobufReader.readString);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_LoginParams.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  if IsModifiedField(FN_USERNAME) then
    pbout.writeString(FN_USERNAME, FUsername);
  if IsModifiedField(FN_PASSWORD) then
    pbout.writeString(FN_PASSWORD, FPassword);
  result := pbout;
end;

procedure TPB_LoginParams.SetUsername(const AValue: AnsiString);
begin
  FUsername := AValue;
  AddModifiedField(FN_USERNAME);
end;

procedure TPB_LoginParams.SetPassword(const AValue: AnsiString);
begin
  FPassword := AValue;
  AddModifiedField(FN_PASSWORD);
end;

end.

