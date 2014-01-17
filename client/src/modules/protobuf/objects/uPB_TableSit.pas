unit uPB_TableSit;

interface

uses
  Winapi.Windows, System.SysUtils, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_TableSit = class(TProtobufBaseObject)
  private
    const
      FN_GAMEID = 1;
      FN_SEATINDEX = 2;
      FN_CHIPS = 3;

    var
      FGameId: TBytes;
      FSeatIndex: Integer;
      FChips: Integer;

    procedure SetGameId(const AValue: TBytes);
    procedure SetSeatIndex(const AValue: Integer);
    procedure SetChips(const AValue: Integer);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property GameId: TBytes read FGameId write SetGameId;
    property SeatIndex: Integer read FSeatIndex write SetSeatIndex;
    property Chips: Integer read FChips write SetChips;
  end;

implementation

uses
  pbPublic;

procedure TPB_TableSit.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
  bytes                               : TBytes;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_GAMEID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(bytes);
        SetGameId(bytes);
      end;
      FN_SEATINDEX: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetSeatIndex(AProtobufReader.readInt32);
      end;
      FN_CHIPS: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetChips(AProtobufReader.readInt32);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_TableSit.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  if IsModifiedField(FN_GAMEID) then
    pbout.writeBytes(FN_GAMEID, FGameId);
  if IsModifiedField(FN_SEATINDEX) then
    pbout.writeInt32(FN_SEATINDEX, FSeatIndex);
  if IsModifiedField(FN_CHIPS) then
    pbout.writeInt32(FN_CHIPS, FChips);
  result := pbout;
end;

procedure TPB_TableSit.SetGameId(const AValue: TBytes);
begin
  FGameId := AValue;
  AddModifiedField(FN_GAMEID);
end;

procedure TPB_TableSit.SetSeatIndex(const AValue: Integer);
begin
  FSeatIndex := AValue;
  AddModifiedField(FN_SEATINDEX);
end;

procedure TPB_TableSit.SetChips(const AValue: Integer);
begin
  FChips := AValue;
  AddModifiedField(FN_CHIPS);
end;

end.
