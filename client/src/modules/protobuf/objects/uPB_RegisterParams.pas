unit uPB_RegisterParams;

interface

uses
  Winapi.Windows,
  pbOutput, uProtobufBaseObject, uProtobufReader;

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
      FDisplayName: AnsiString;

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Email: AnsiString read FEmail write FEmail;
    property Password: AnsiString read FPassword write FPassword;
    property DisplayName: AnsiString read FDisplayName write FDisplayName;
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
        FEmail := AProtobufReader.readString;
      end;
      FN_PASSWORD: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FPassword := AProtobufReader.readString;
      end;
      FN_DISPLAYNAME: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FDisplayName := AProtobufReader.readString;
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
  pbout.writeString(FN_EMAIL, FEmail);
  pbout.writeString(FN_PASSWORD, FPassword);
  pbout.writeString(FN_DISPLAYNAME, FDisplayName);
  result := pbout;
end;

end.

