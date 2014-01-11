unit uPB_Game;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils, System.Generics.Collections, pbOutput, uProtobufBaseObject, uProtobufReader;

type
  TPB_Game = class(TProtobufBaseObject)
  private
    const
      FN_MONGOID = 1;
      FN_CREATOR = 2;
      FN_NAME = 3;
      FN_CLUBSEQ = 4;
      FN_GAMETYPE = 5;
      FN_GAMELIMIT = 6;
      FN_SMALLBLIND = 7;
      FN_BIGBLIND = 8;
      FN_SEATS = 9;
    function GetCreatorMongoId: AnsiString;
    function GetMongoId: AnsiString;

    var
      FMongoId: TBytes;
      FCreatorMongoId: TBytes;
      FName: AnsiString;
      FClubSeq: Integer;
      FGameType: Integer;
      FGameLimit: Integer;
      FSmallBlind: Integer;
      FBigBlind: Integer;
      FSeats: Integer;

  public
    constructor Create(const AMongoId: AnsiString; const ACreatorMongoId: AnsiString; const AName: AnsiString; const AClubSeq: Integer; const AGameType: Integer; const AGameLimit: Integer; const ASmallBlind: Integer; const ABigBlind: Integer; const ASeats: Integer); overload;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property MongoId: AnsiString read GetMongoId;
    property CreatorMongoId: AnsiString read GetCreatorMongoId;
    property Name: AnsiString read FName;
    property ClubSeq: Integer read FClubSeq;
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


constructor TPB_Game.Create(const AMongoId: AnsiString; const ACreatorMongoId: AnsiString; const AName: AnsiString; const AClubSeq: Integer; const AGameType: Integer; const AGameLimit: Integer; const ASmallBlind: Integer; const ABigBlind: Integer; const ASeats: Integer);
begin
  HexToBytes(AMongoId, FMongoId);
  HexToBytes(ACreatorMongoId, FCreatorMongoId);
  FName := AName;
  FClubSeq := AClubSeq;
  FGameType := AGameType;
  FGameLimit := AGameLimit;
  FSmallBlind := ASmallBlind;
  FBigBlind := ABigBlind;
  FSeats := ASeats;
end;

procedure TPB_Game.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag         : Integer;
  wire_type   : Integer;
  field_number: Integer;
  endpos      : Integer;
begin
  FClubSeq := -1;
  FGameType := -1;
  FGameLimit := -1;
  FSmallBlind := -1;
  FBigBlind := -1;
  FSeats := -1;
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_MONGOID: AProtobufReader.readMongoId(FMongoId);
      FN_CREATOR: AProtobufReader.readMongoId(FCreatorMongoId);
      FN_NAME: FName := AProtobufReader.readString;
      FN_CLUBSEQ: FClubSeq := AProtobufReader.readInt32;
      FN_GAMETYPE: FGameType := AProtobufReader.readInt32;
      FN_GAMELIMIT: FGameLimit := AProtobufReader.readInt32;
      FN_SMALLBLIND: FSmallBlind := AProtobufReader.readInt32;
      FN_BIGBLIND: FBigBlind := AProtobufReader.readInt32;
      FN_SEATS: FSeats := AProtobufReader.readInt32;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_Game.GetProtobuf: TProtoBufOutput;
var
  pboutput: TProtoBufOutput;
begin
  pboutput := TProtoBufOutput.Create;
  result := pboutput;
end;

function TPB_Game.GetCreatorMongoId: AnsiString;
begin
  result := BytesToHex(FCreatorMongoId);
end;

function TPB_Game.GetMongoId: AnsiString;
begin
  result := BytesToHex(FMongoId);
end;

end.
