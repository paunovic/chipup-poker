unit uPB_ChatMessage;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader, System.SysUtils;

type
  TPB_ChatMessage = class(TProtobufBaseObject)
  private
    const
      FN_MONGOID = 1;
      FN_USERNAME = 2;
      FN_MSG = 3;
      FN_TIMESTAMP = 4;

    var
      FMongoId: TBytes;
      FUsername: AnsiString;
      FMsg: AnsiString;
      FTimestamp: Int64;

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property MongoId: TBytes read FMongoId write FMongoId;
    property Username: AnsiString read FUsername write FUsername;
    property Msg: AnsiString read FMsg write FMsg;
    property Timestamp: Int64 read FTimestamp write FTimestamp;
  end;

implementation

uses
  pbPublic;

procedure TPB_ChatMessage.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_MONGOID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(FMongoId);
      end;
      FN_USERNAME: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FUsername := AProtobufReader.readString;
      end;
      FN_MSG: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FMsg := AProtobufReader.readString;
      end;
      FN_TIMESTAMP: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FTimestamp := AProtobufReader.readInt64;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_ChatMessage.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  if Length(FMongoId) > 0 then
    pbout.writeBytes(FN_MONGOID, FMongoId);
  if FUsername <> '' then
    pbout.writeString(FN_USERNAME, FUsername);
  pbout.writeString(FN_MSG, FMsg);
  if FTimestamp <> 0 then
    pbout.writeInt64(FN_TIMESTAMP, FTimestamp);
  result := pbout;
end;

end.

