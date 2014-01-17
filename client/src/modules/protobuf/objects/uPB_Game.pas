unit uPB_Game;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_Game = class(TProtobufBaseObject)
  private
    const
      FN_MONGOID = 1;
      FN_CREATOR = 2;
      FN_GAMENAME = 3;
      FN_CLUBSEQ = 4;
      FN_GAMETYPE = 5;
      FN_GAMELIMIT = 6;
      FN_SMALLBLIND = 7;
      FN_BIGBLIND = 8;
      FN_SEATS = 9;

    var
      FMongoId: TBytes;
      FCreator: TBytes;
      FGamename: AnsiString;
      FClubseq: Integer;
      FGameType: Integer;
      FGameLimit: Integer;
      FSmallBlind: Integer;
      FBigBlind: Integer;
      FSeats: Integer;

    function GetCreatorMongoIdHex: AnsiString;
    function GetMongoIdHex: AnsiString;
    procedure SetMongoIdHex(const AValue: AnsiString);
    procedure SetMongoId(const AValue: TBytes);
    procedure SetCreator(const AValue: TBytes);
    procedure SetGamename(const AValue: AnsiString);
    procedure SetClubseq(const AValue: Integer);
    procedure SetGameType(const AValue: Integer);
    procedure SetGameLimit(const AValue: Integer);
    procedure SetSmallBlind(const AValue: Integer);
    procedure SetBigBlind(const AValue: Integer);
    procedure SetSeats(const AValue: Integer);

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;

    property MongoId: TBytes read FMongoId write SetMongoId;
    property Creator: TBytes read FCreator write SetCreator;
//    property MongoIdHex: AnsiString read GetMongoIdHex write SetMongoIdHex;
//    property CreatorMongoIdHex: AnsiString read GetCreatorMongoIdHex;
    property Gamename: AnsiString read FGamename write SetGamename;
    property Clubseq: Integer read FClubseq write SetClubseq;
    property GameType: Integer read FGameType write SetGameType;
    property GameLimit: Integer read FGameLimit write SetGameLimit;
    property SmallBlind: Integer read FSmallBlind write SetSmallBlind;
    property BigBlind: Integer read FBigBlind write SetBigBlind;
    property Seats: Integer read FSeats write SetSeats;
  end;

  TPB_Games = TObjectList<TPB_Game>;

implementation

uses
  pbPublic, uCommon;



procedure TPB_Game.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
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
      FN_CREATOR: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(bytes);
        SetCreator(bytes);
      end;
      FN_GAMENAME: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        SetGamename(AProtobufReader.readString);
      end;
      FN_CLUBSEQ: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetClubseq(AProtobufReader.readInt32);
      end;
      FN_GAMETYPE: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetGameType(AProtobufReader.readInt32);
      end;
      FN_GAMELIMIT: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetGameLimit(AProtobufReader.readInt32);
      end;
      FN_SMALLBLIND: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetSmallBlind(AProtobufReader.readInt32);
      end;
      FN_BIGBLIND: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetBigBlind(AProtobufReader.readInt32);
      end;
      FN_SEATS: begin
        Assert(wire_type = WIRETYPE_VARINT);
        SetSeats(AProtobufReader.readInt32);
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_Game.GetCreatorMongoIdHex: AnsiString;
begin
  result := BytesToHex(FCreator);
end;

function TPB_Game.GetMongoIdHex: AnsiString;
begin
  result := BytesToHex(FMongoId);
end;

procedure TPB_Game.SetMongoIdHex(const AValue: AnsiString);
var
  bytes: TBytes;
begin
  HexToBytes(AValue, bytes);
  SetMongoId(bytes)
end;

procedure TPB_Game.SetMongoId(const AValue: TBytes);
begin
  FMongoId := AValue;
  ProtobufOutput.writeBytes(FN_MONGOID, FMongoId);
end;

procedure TPB_Game.SetCreator(const AValue: TBytes);
begin
  FCreator := AValue;
  ProtobufOutput.writeBytes(FN_CREATOR, FCreator);
end;

procedure TPB_Game.SetGamename(const AValue: AnsiString);
begin
  FGamename := AValue;
  ProtobufOutput.writeString(FN_GAMENAME, FGamename);
end;

procedure TPB_Game.SetClubseq(const AValue: Integer);
begin
  FClubseq := AValue;
  ProtobufOutput.writeInt32(FN_CLUBSEQ, FClubseq);
end;

procedure TPB_Game.SetGameType(const AValue: Integer);
begin
  FGameType := AValue;
  ProtobufOutput.writeInt32(FN_GAMETYPE, FGameType);
end;

procedure TPB_Game.SetGameLimit(const AValue: Integer);
begin
  FGameLimit := AValue;
  ProtobufOutput.writeInt32(FN_GAMELIMIT, FGameLimit);
end;

procedure TPB_Game.SetSmallBlind(const AValue: Integer);
begin
  FSmallBlind := AValue;
  ProtobufOutput.writeInt32(FN_SMALLBLIND, FSmallBlind);
end;

procedure TPB_Game.SetBigBlind(const AValue: Integer);
begin
  FBigBlind := AValue;
  ProtobufOutput.writeInt32(FN_BIGBLIND, FBigBlind);
end;

procedure TPB_Game.SetSeats(const AValue: Integer);
begin
  FSeats := AValue;
  ProtobufOutput.writeInt32(FN_SEATS, FSeats);
end;


end.

