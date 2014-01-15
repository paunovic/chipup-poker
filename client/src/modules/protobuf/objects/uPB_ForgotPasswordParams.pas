unit uPB_ForgotPasswordParams;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_ForgotPasswordParams = class(TProtobufBaseObject)
  private
    const
      FN_EMAIL = 1;

    var
      FEmail: AnsiString;

    procedure SetEmail(const AValue: AnsiString);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Email: AnsiString read FEmail write SetEmail;
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
        SetEmail(AProtobufReader.readString);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_ForgotPasswordParams.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  if IsModifiedField(FN_EMAIL) then
    pbout.writeString(FN_EMAIL, FEmail);
  result := pbout;
end;

procedure TPB_ForgotPasswordParams.SetEmail(const AValue: AnsiString);
begin
  FEmail := AValue;
  AddModifiedField(FN_EMAIL);
end;

end.

