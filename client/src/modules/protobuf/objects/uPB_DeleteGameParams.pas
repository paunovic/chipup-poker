unit uPB_DeleteGameParams;

interface

uses
  Winapi.Windows,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_DeleteGameParams = class(TProtobufBaseObject)
  private
    const
      FN_GAMEMONGOID = 1;

    var
      FGameMongoId: AnsiString;

  public
    constructor Create(const AGameMongoId: AnsiString); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property GameMongoId: AnsiString read FGameMongoId;
  end;

//  TPB_DeleteGameParamss = TObjectList<TPB_DeleteGameParams>;

implementation

uses
  pbPublic;

constructor TPB_DeleteGameParams.Create(const AGameMongoId: AnsiString);
begin
  FGameMongoId := AGameMongoId;
end;

procedure TPB_DeleteGameParams.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_GAMEMONGOID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FGameMongoId := AProtobufReader.readString;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_DeleteGameParams.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  pbout.writeString(FN_GAMEMONGOID, FGameMongoId);
  result := pbout;
end;

end.
