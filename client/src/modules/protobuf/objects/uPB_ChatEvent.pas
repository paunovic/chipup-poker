unit uPB_ChatEvent;

interface

uses
  Winapi.Windows, System.SysUtils, pbOutput, uProtobufBaseObject, uProtobufReader, uPB_ChatMessage;

type
  TChatEvent = (ceMessage = 0, ceJoin, cePart);

  TPB_ChatEvent = class(TProtobufBaseObject)
  private
    const
      FN_EVENT = 1;
      FN_MESSAGE = 2;
      FN_CHANNEL = 3;

    var
      FEvent: TChatEvent;
      FMessage: TPB_ChatMessage;
      FChannel: AnsiString;

  public
    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Event: TChatEvent read FEvent write FEvent;
    property ChatMessage: TPB_ChatMessage read FMessage write FMessage;
    property Channel: AnsiString read FChannel write FChannel;
  end;

implementation

uses
  pbPublic;


destructor TPB_ChatEvent.Destroy;
begin
  if Assigned(FMessage) then
    FMessage.Free;

  inherited;
end;

procedure TPB_ChatEvent.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_EVENT: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FEvent := TChatEvent(AProtobufReader.readEnum);
      end;
      FN_MESSAGE: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        if Assigned(FMessage) then
          FreeAndNil(FMessage);
        FMessage := TPB_ChatMessage.Create(AProtobufReader,AProtobufReader.readInt32);
      end;
      FN_CHANNEL: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FChannel := AProtobufReader.readString;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;


function TPB_ChatEvent.GetProtobuf: TProtoBufOutput;
var
  pbout, pbmsg: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  pbout.writeInt32(FN_EVENT, Integer(FEvent));
  pbout.writeString(FN_CHANNEL, FChannel);
  if Assigned(FMessage) then
  begin
    pbmsg := FMessage.GetProtobuf;
    try
      pbmsg.writeTo(pbout);
    finally
      pbmsg.Free;
    end;
  end;
  result := pbout;
end;

end.

