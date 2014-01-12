unit uPB_OldMessage;

interface

uses
  Winapi.Windows,
  pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_OldMessage = class(TProtobufBaseObject)
    const
      FN_CODE = 1;
      FN_MSG = 2;
      FN_COMMAND = 3;

    var
      FCode: Integer;
      FMsg: AnsiString;
      FCommand: AnsiString;

  public
    constructor Create(const ACode: Integer; const AMsg: AnsiString; const ACommand: AnsiString); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Code: Integer read FCode;
    property Msg: AnsiString read FMsg;
    property Command: AnsiString read FCommand;
  end;

implementation

uses
  pbPublic;

constructor TPB_OldMessage.Create(const ACode: Integer; const AMsg: AnsiString; const ACommand: AnsiString);
begin
  FCode := ACode;
  FMsg := AMsg;
  FCommand := ACommand;
end;

procedure TPB_OldMessage.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_CODE: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FCode := AProtobufReader.readInt32;
      end;
      FN_MSG: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FMsg := AProtobufReader.readString;
      end;
      FN_COMMAND: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FCommand := AProtobufReader.readString;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_OldMessage.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  if FCode <> 0 then
    pbout.writeInt32(FN_CODE, FCode);
  if FMsg <> '' then
    pbout.writeString(FN_MSG, FMsg);
  if FCommand <> '' then
    pbout.writeString(FN_COMMAND, FCommand);
  result := pbout;
end;

end.

