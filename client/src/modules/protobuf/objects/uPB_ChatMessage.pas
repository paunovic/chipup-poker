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

    procedure SetMongoId(const AValue: TBytes);
    procedure SetUsername(const AValue: AnsiString);
    procedure SetMsg(const AValue: AnsiString);
    procedure SetTimestamp(const AValue: Int64);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property MongoId: TBytes read FMongoId write SetMongoId;
    property Username: AnsiString read FUsername write SetUsername;
    property Msg: AnsiString read FMsg write SetMsg;
    property Timestamp: Int64 read FTimestamp write SetTimestamp;
  end;

implementation

uses
  pbPublic;

procedure TPB_ChatMessage.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
  bytes                               : TBytes;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_MONGOID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(bytes);
        SetMongoId(bytes);
      end;
      FN_USERNAME: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetUsername(AProtobufReader.readString);
      end;
      FN_MSG: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetMsg(AProtobufReader.readString);
      end;
      FN_TIMESTAMP: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetTimestamp(AProtobufReader.readInt64);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

procedure TPB_ChatMessage.SetMongoId(const AValue: TBytes);
begin
  FMongoId := AValue;
  ProtobufOutput.writeBytes(FN_MONGOID, FMongoId);
end;

procedure TPB_ChatMessage.SetUsername(const AValue: AnsiString);
begin
  FUsername := AValue;
  ProtobufOutput.writeString(FN_USERNAME, FUsername);
end;

procedure TPB_ChatMessage.SetMsg(const AValue: AnsiString);
begin
  FMsg := AValue;
  ProtobufOutput.writeString(FN_MSG, FMsg);
end;

procedure TPB_ChatMessage.SetTimestamp(const AValue: Int64);
begin
  FTimestamp := AValue;
  ProtobufOutput.writeInt64(FN_TIMESTAMP, FTimestamp);
end;

end.

