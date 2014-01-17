unit uPB_SeatInfo;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_SeatInfo = class(TProtobufBaseObject)
  private
    const
      FN_SEAT = 1;
      FN_PLAYERID = 2;
      FN_CHIPS = 3;
      FN_CARDS = 4;
    function GetPlayerIdHex: AnsiString;
    procedure SetPlayerIdHex(const AValue: AnsiString);

    var
      FSeat: Integer;
      FPlayerId: TBytes;
      FChips: Integer;
      FCards: Integer;

    procedure SetSeat(const AValue: Integer);
    procedure SetPlayerId(const AValue: TBytes);
    procedure SetChips(const AValue: Integer);
    procedure SetCards(const AValue: Integer);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Seat: Integer read FSeat write SetSeat;
    property PlayerMongoId: TBytes read FPlayerId write SetPlayerId;
    property PlayerMongoIdHex: AnsiString read GetPlayerIdHex write SetPlayerIdHex;
    property Chips: Integer read FChips write SetChips;
    property Cards: Integer read FCards write SetCards;
  end;

  TPB_SeatInfos = TObjectList<TPB_SeatInfo>;


implementation

uses
  pbPublic, uCommon;

procedure TPB_SeatInfo.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
  bytes                               : TBytes;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_SEAT: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetSeat(AProtobufReader.readInt32);
      end;
      FN_PLAYERID: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(bytes);
        SetPlayerId(bytes);
      end;
      FN_CHIPS: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetChips(AProtobufReader.readInt32);
      end;
      FN_CARDS: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetCards(AProtobufReader.readInt32);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_SeatInfo.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
  if IsModifiedField(FN_SEAT) then
    pbout.writeInt32(FN_SEAT, FSeat);
  if IsModifiedField(FN_PLAYERID) then
    pbout.writeBytes(FN_PLAYERID, FPlayerId);
  if IsModifiedField(FN_CHIPS) then
    pbout.writeInt32(FN_CHIPS, FChips);
  if IsModifiedField(FN_CARDS) then
    pbout.writeInt32(FN_CARDS, FCards);
  result := pbout;
end;

procedure TPB_SeatInfo.SetSeat(const AValue: Integer);
begin
  FSeat := AValue;
  AddModifiedField(FN_SEAT);
end;

procedure TPB_SeatInfo.SetPlayerId(const AValue: TBytes);
begin
  FPlayerId := AValue;
  AddModifiedField(FN_PLAYERID);
end;

procedure TPB_SeatInfo.SetChips(const AValue: Integer);
begin
  FChips := AValue;
  AddModifiedField(FN_CHIPS);
end;

procedure TPB_SeatInfo.SetCards(const AValue: Integer);
begin
  FCards := AValue;
  AddModifiedField(FN_CARDS);
end;

procedure TPB_SeatInfo.SetPlayerIdHex(const AValue: AnsiString);
var
  bytes: TBytes;
begin
  HexToBytes(AValue, bytes);
  SetPlayerId(bytes);
end;

function TPB_SeatInfo.GetPlayerIdHex: AnsiString;
begin
  result := BytesToHex(FPlayerId);
end;


end.
