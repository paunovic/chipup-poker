unit PokerClient.Protobufs.Objects.ForgotPasswordParams;

interface

uses
  Winapi.Windows, pbOutput, PokerClient.Protobufs.Objects.Base, PokerClient.Protobufs.Reader;

type
  TPB_ForgotPasswordParams = class(TProtobufBaseObject)
  private
    const
      FN_EMAIL = 1;

    var
      FEmail: String;

    procedure SetEmail(const AValue: String);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property Email: String read FEmail write SetEmail;
  end;

implementation

uses
  pbPublic;

procedure TPB_ForgotPasswordParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
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
    else
      AProtobufReader.skipField(tag);
    end;
end;


procedure TPB_ForgotPasswordParams.SetEmail(const AValue: String);
begin
  FEmail := AValue;
  ProtobufOutput.writeString(FN_EMAIL, FEmail);
end;

end.

