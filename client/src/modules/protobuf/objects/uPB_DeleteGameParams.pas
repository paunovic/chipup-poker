unit uPB_DeleteGameParams;

interface

uses
  Winapi.Windows, System.SysUtils,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_DeleteGameParams = class(TProtobufBaseObject)
  private
    const
      FN_GAMEMONGOID = 1;

    var
      FGameMongoId: TBytes;

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property GameMongoId: TBytes read FGameMongoId write FGameMongoId;
  end;


implementation


uses
  pbPublic;


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
        AProtobufReader.readBytes(FGameMongoId);
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
  pbout.writeBytes(FN_GAMEMONGOID, FGameMongoId);
  result := pbout;
end;

end.
