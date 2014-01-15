unit uPB_RegisterParams;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_RegisterParams = class(TProtobufBaseObject)
  private
    const
      FN_EMAIL = 1;
      FN_PASSWORD = 2;
      FN_DISPLAYNAME = 3;

    var
      FEmail: AnsiString;
      FPassword: AnsiString;
      FDisplayname: AnsiString;

    procedure SetEmail(const AValue: AnsiString);
    procedure SetPassword(const AValue: AnsiString);
    procedure SetDisplayname(const AValue: AnsiString);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Email: AnsiString read FEmail write SetEmail;
    property Password: AnsiString read FPassword write SetPassword;
    property Displayname: AnsiString read FDisplayname write SetDisplayname;
  end;

implementation

uses
  pbPublic;

procedure TPB_RegisterParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_EMAIL: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetEmail(AProtobufReader.readString);
      end;
      FN_PASSWORD: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetPassword(AProtobufReader.readString);
      end;
      FN_DISPLAYNAME: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetDisplayname(AProtobufReader.readString);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_RegisterParams.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  if IsModifiedField(FN_EMAIL) then
    pbout.writeString(FN_EMAIL, FEmail);
  if IsModifiedField(FN_PASSWORD) then
    pbout.writeString(FN_PASSWORD, FPassword);
  if IsModifiedField(FN_DISPLAYNAME) then
    pbout.writeString(FN_DISPLAYNAME, FDisplayname);
  result := pbout;
end;

procedure TPB_RegisterParams.SetEmail(const AValue: AnsiString);
begin
  FEmail := AValue;
  AddModifiedField(FN_EMAIL);
end;

procedure TPB_RegisterParams.SetPassword(const AValue: AnsiString);
begin
  FPassword := AValue;
  AddModifiedField(FN_PASSWORD);
end;

procedure TPB_RegisterParams.SetDisplayname(const AValue: AnsiString);
begin
  FDisplayname := AValue;
  AddModifiedField(FN_DISPLAYNAME);
end;

end.

