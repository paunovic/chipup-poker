unit uPB_SetAvatarParams;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_SetAvatarParams = class(TProtobufBaseObject)
  private
    const
      FN_AVATARID = 1;

    var
      FAvatarId: AnsiString;

    procedure SetAvatarId(const AValue: AnsiString);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property AvatarId: AnsiString read FAvatarId write SetAvatarId;
  end;

implementation

uses
  pbPublic;


procedure TPB_SetAvatarParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_AVATARID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetAvatarId(AProtobufReader.readString);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

procedure TPB_SetAvatarParams.SetAvatarId(const AValue: AnsiString);
begin
  FAvatarId := AValue;
  ProtobufOutput.writeString(FN_AVATARID, FAvatarId);
end;

end.

