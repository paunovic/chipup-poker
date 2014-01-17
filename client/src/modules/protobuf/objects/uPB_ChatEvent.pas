unit uPB_ChatEvent;

interface

uses
  Winapi.Windows, System.SysUtils, pbOutput, uProtobufBaseObject, uProtobufReader, uPB_ChatMessage;

type
  TChatEvent = (ceUserMessage = 0, ceServerMessage);

  TPB_ChatEvent = class(TProtobufBaseObject)
  private
    const
      FN_EVENT = 1;
      FN_MESSAGE = 2;
      FN_TABLEID = 3;

    var
      FEvent: TChatEvent;
      FMessage: TPB_ChatMessage;
      FTableId: TBytes;

    procedure SetEvent(const AValue: TChatEvent);
    procedure SetMessage(const AValue: TPB_ChatMessage);
    procedure SetTableId(const AValue: TBytes);

  public
    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property Event: TChatEvent read FEvent write SetEvent;
    property Msg: TPB_ChatMessage read FMessage write SetMessage;
    property TableId: TBytes read FTableId write SetTableId;
  end;

implementation

uses
  pbPublic, uCommon;


destructor TPB_ChatEvent.Destroy;
begin
  if Assigned(FMessage) then
    FMessage.Free;

  inherited;
end;

procedure TPB_ChatEvent.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
  bytes                               : TBytes;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_EVENT: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetEvent(TChatEvent(AProtobufReader.readEnum));
      end;
      FN_MESSAGE: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetMessage(TPB_ChatMessage.Create(AProtobufReader, AProtobufReader.readInt32));
      end;
      FN_TABLEID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(bytes);
        SetTableId(bytes);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

procedure TPB_ChatEvent.SetEvent(const AValue: TChatEvent);
begin
  FEvent := AValue;
  ProtobufOutput.writeInt32(FN_EVENT, Integer(FEvent));
end;

procedure TPB_ChatEvent.SetMessage(const AValue: TPB_ChatMessage);
begin
  FMessage := AValue;
  ProtobufOutput.writeMessage(FN_MESSAGE, FMessage.ProtobufOutput);
end;

procedure TPB_ChatEvent.SetTableId(const AValue: TBytes);
begin
  FTableId := AValue;
  ProtobufOutput.writeBytes(FN_TABLEID, FTableId);
end;


end.

