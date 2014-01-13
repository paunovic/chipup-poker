unit uPB_Game;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections,
  pbOutput, uProtobufBaseObject, uProtobufReader;

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

    function GetCreatorMongoId: AnsiString;
    function GetMongoId: AnsiString;
    procedure SetMongoId(const AValue: AnsiString);

  public
    constructor Create(const AGamename: AnsiString; const AClubseq: Integer; const AGameType: Integer; const AGameLimit: Integer; const ASmallBlind: Integer; const ABigBlind: Integer; const ASeats: Integer); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property MongoId: AnsiString read GetMongoId write SetMongoId;
    property CreatorMongoId: AnsiString read GetCreatorMongoId;
    property Gamename: AnsiString read FGamename;
    property Clubseq: Integer read FClubseq;
    property GameType: Integer read FGameType;
    property GameLimit: Integer read FGameLimit;
    property SmallBlind: Integer read FSmallBlind;
    property BigBlind: Integer read FBigBlind;
    property Seats: Integer read FSeats;
  end;

  TPB_Games = TObjectList<TPB_Game>;

implementation

uses
  pbPublic, uCommon;


constructor TPB_Game.Create(const AGamename: AnsiString; const AClubseq: Integer; const AGameType: Integer; const AGameLimit: Integer; const ASmallBlind: Integer; const ABigBlind: Integer; const ASeats: Integer);
begin
  FGamename := AGamename;
  FClubseq := AClubseq;
  FGameType := AGameType;
  FGameLimit := AGameLimit;
  FSmallBlind := ASmallBlind;
  FBigBlind := ABigBlind;
  FSeats := ASeats;
end;

procedure TPB_Game.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
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
      FN_CREATOR: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        AProtobufReader.readBytes(FCreator);
      end;
      FN_GAMENAME: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        FGamename := AProtobufReader.readString;
      end;
      FN_CLUBSEQ: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FClubseq := AProtobufReader.readInt32;
      end;
      FN_GAMETYPE: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FGameType := AProtobufReader.readInt32;
      end;
      FN_GAMELIMIT: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FGameLimit := AProtobufReader.readInt32;
      end;
      FN_SMALLBLIND: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FSmallBlind := AProtobufReader.readInt32;
      end;
      FN_BIGBLIND: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FBigBlind := AProtobufReader.readInt32;
      end;
      FN_SEATS: begin
        Assert(wire_type = WIRETYPE_VARINT);
        FSeats := AProtobufReader.readInt32;
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;


function TPB_Game.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;

  if Length(FMongoId) > 0 then
    pbout.writeBytes(FN_MONGOID, FMongoId);

  if Length(FCreator) > 0 then
    pbout.writeBytes(FN_CREATOR, FCreator);

  pbout.writeString(FN_GAMENAME, FGamename);
  pbout.writeInt32(FN_CLUBSEQ, FClubseq);
  pbout.writeInt32(FN_GAMETYPE, FGameType);
  pbout.writeInt32(FN_GAMELIMIT, FGameLimit);
  pbout.writeInt32(FN_SMALLBLIND, FSmallBlind);
  pbout.writeInt32(FN_BIGBLIND, FBigBlind);
  pbout.writeInt32(FN_SEATS, FSeats);
  result := pbout;
end;

function TPB_Game.GetCreatorMongoId: AnsiString;
begin
  result := BytesToHex(FCreator);
end;

function TPB_Game.GetMongoId: AnsiString;
begin
  result := BytesToHex(FMongoId);
end;

procedure TPB_Game.SetMongoId(const AValue: AnsiString);
begin
  HexToBytes(AValue, FMongoId);
end;


end.
