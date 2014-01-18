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
      FEmail: String;
      FPassword: String;
      FDisplayname: String;

    procedure SetEmail(const AValue: String);
    procedure SetPassword(const AValue: String);
    procedure SetDisplayname(const AValue: String);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property Email: String read FEmail write SetEmail;
    property Password: String read FPassword write SetPassword;
    property Displayname: String read FDisplayname write SetDisplayname;
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
        SetEmail(AProtobufReader.readUtf8String);
      end;
      FN_PASSWORD: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetPassword(AProtobufReader.readUtf8String);
      end;
      FN_DISPLAYNAME: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetDisplayname(AProtobufReader.readUtf8String);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

procedure TPB_RegisterParams.SetEmail(const AValue: String);
begin
  FEmail := AValue;
  ProtobufOutput.writeString(FN_EMAIL, FEmail);
end;

procedure TPB_RegisterParams.SetPassword(const AValue: String);
begin
  FPassword := AValue;
  ProtobufOutput.writeString(FN_PASSWORD, FPassword);
end;

procedure TPB_RegisterParams.SetDisplayname(const AValue: String);
begin
  FDisplayname := AValue;
  ProtobufOutput.writeString(FN_DISPLAYNAME, FDisplayname);
end;

end.

