unit uPB_SetAvatarParams;

interface

uses
  Winapi.Windows,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_SetAvatarParams = class(TProtobufBaseObject)
  private
    const
      FN_AVATARMONGOID = 1;

    var
      FAvatarMongoId: AnsiString;

  public
    constructor Create(const AAvatarMongoId: AnsiString); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property AvatarMongoId: AnsiString read FAvatarMongoId;
  end;

//  TPB_SetAvatarParamss = TObjectList<TPB_SetAvatarParams>;

implementation

uses
  pbPublic;

constructor TPB_SetAvatarParams.Create(const AAvatarMongoId: AnsiString);
begin
  FAvatarMongoId := AAvatarMongoId;
end;

procedure TPB_SetAvatarParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_AVATARMONGOID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FAvatarMongoId := AProtobufReader.readString;
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
  pbout.writeString(FN_AVATARMONGOID, FAvatarMongoId);
  result := pbout;
end;

end.
