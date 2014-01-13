unit uPB_SetAvatarParams;

interface

uses
  Winapi.Windows,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_SetAvatarParams = class(TProtobufBaseObject)
  private
    const
      FN_AVATARID = 1;

    var
      FAvatarId: AnsiString;

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property AvatarId: AnsiString read FAvatarId write FAvatarId;
  end;

//  TPB_SetAvatarParamss = TObjectList<TPB_SetAvatarParams>;

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
        FAvatarId := AProtobufReader.readString;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_SetAvatarParams.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  pbout.writeString(FN_AVATARID, FAvatarId);
  result := pbout;
end;

end.
