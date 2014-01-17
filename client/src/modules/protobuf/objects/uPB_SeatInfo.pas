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

    property Seat: Integer read FSeat write SetSeat;
    property PlayerMongoId: TBytes read FPlayerId write SetPlayerId;
    property Chips: Integer read FChips write SetChips;
    property Cards: Integer read FCards write SetCards;
  end;

  TPB_SeatInfos = TObjectList<TPB_SeatInfo>;


implementation

uses
  pbPublic;

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

procedure TPB_SeatInfo.SetSeat(const AValue: Integer);
begin
  FSeat := AValue;
  ProtobufOutput.writeInt32(FN_SEAT, FSeat);
end;

procedure TPB_SeatInfo.SetPlayerId(const AValue: TBytes);
begin
  FPlayerId := AValue;
  ProtobufOutput.writeBytes(FN_PLAYERID, FPlayerId);
end;

procedure TPB_SeatInfo.SetChips(const AValue: Integer);
begin
  FChips := AValue;
  ProtobufOutput.writeInt32(FN_CHIPS, FChips);
end;

procedure TPB_SeatInfo.SetCards(const AValue: Integer);
begin
  FCards := AValue;
  ProtobufOutput.writeInt32(FN_CARDS, FCards);
end;


end.
