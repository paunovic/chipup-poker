unit Poker.Games.Game;

interface

uses
  Winapi.Windows, System.SysUtils, Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.TableStatus, Poker.Types;

type
  TGameInfo = class
  private
    FMongoId: TMongoId;
    FClubId: TMongoId;
    FTournamentId: TMongoId;
    FCreatorId: TMongoId;
    FName: String;
    FSmallBlind: UINT32;
    FBigBlind: UINT32;
    FBlinds: TGameBlinds;
    FGameType: TGameType;
    FGameLimit: TGameLimit;
    FMinBuyin: UINT32;
    FMaxBuyin: UINT32;
    FSeats: Integer;
    FSitting: Integer;
    FState: TGameState;
    FClosingTime: DWORD;
    FLastHandId: UINT32;

    function GetStateStr: String;

  public
    procedure Assign(const AProtobufObject: TPB_Game); overload;
    procedure Assign(const AGameInfo: TGameInfo); overload;

    class procedure BlindsEnumToInts(const ABlinds: TGameBlinds; out ASmallBlind, ABigBlind: UINT32);
    class function GameTypeToStr(const AGameType: TGameType; const AGameLimit: TGameLimit; const AShort: Boolean): String;

    function AsString(const AShort: Boolean): String;

    property MongoId: TMongoId read FMongoId write FMongoId;
    property ClubId: TMongoId read FClubId write FClubId;
    property TournamentId: TMongoId read FTournamentId write FTournamentId;
    property CreatorId: TMongoId read FCreatorId write FCreatorId;
    property Name: String read FName write FName;
    property Blinds: TGameBlinds read FBlinds;
    property SmallBlind: UINT32 read FSmallBlind;
    property BigBlind: UINT32 read FBigBlind;
    property GameType: TGameType read FGameType write FGameType;
    property Limit: TGameLimit read FGameLimit write FGameLimit;
    property MinBuyin: UINT32 read FMinBuyin write FMinBuyin;
    property MaxBuyin: UINT32 read FMaxBuyin write FMaxBuyin;
    property Seats: Integer read FSeats write FSeats;
    property Sitting: Integer read FSitting write FSitting;
    property State: TGameState read FState write FState;
    property StateAsStr: String read GetStateStr;
    property ClosingTime: DWORD read FClosingTime write FClosingTime;
    property LastHandId: UINT32 read FLastHandId;
  end;

implementation

{ TGameInfo }

procedure TGameInfo.Assign(const AProtobufObject: TPB_Game);
begin
  FMongoId := AProtobufObject.MongoId;
  FCreatorId := AProtobufObject.CreatorMongoId;
  FClubId := AProtobufObject.ClubMongoid;
  FTournamentId := AProtobufObject.Tournament;
  FName := AProtobufObject.Gamename;
  FBlinds := AProtobufObject.Blinds;
  BlindsEnumToInts(FBlinds, FSmallBlind, FBigBlind);
  FSmallBlind := AProtobufObject.SmallBlind;
  FBigBlind := AProtobufObject.BigBlind;
  FGameType := TGameType(AProtobufObject.GameType);
  FGameLimit := TGameLimit(AProtobufObject.GameLimit);
  FMinBuyin := AProtobufObject.BuyinMin;
  FMaxBuyin := AProtobufObject.BuyinMax;
  FSeats := AProtobufObject.Seats;
  FSitting := AProtobufObject.Sitting;
  FState := AProtobufObject.State;
  FClosingTime := AProtobufObject.Closetime;
  FLastHandId := AProtobufObject.Lasthandid;
end;

procedure TGameInfo.Assign(const AGameInfo: TGameInfo);
begin
  FMongoId := AGameInfo.MongoId;
  FCreatorId := AGameInfo.CreatorId;
  FClubId := AGameInfo.ClubId;
  FTournamentId := AGameInfo.TournamentId;
  FName := AGameInfo.Name;
  FBlinds := AGameInfo.Blinds;
  FSmallBlind := AGameInfo.SmallBlind;
  FBigBlind := AGameInfo.BigBlind;
  FGameType := AGameInfo.GameType;
  FGameLimit := AGameInfo.Limit;
  FMinBuyin := AGameInfo.MinBuyin;
  FMaxBuyin := AGameInfo.MaxBuyin;
  FSeats := AGameInfo.Seats;
  FSitting := AGameInfo.Sitting;
  FState := AGameInfo.State;
  FClosingTime := AGameInfo.ClosingTime;
  FLastHandId := AGameInfo.LastHandId;
end;

class procedure TGameInfo.BlindsEnumToInts(const ABlinds: TGameBlinds; out ASmallBlind, ABigBlind: UINT32);
begin
  case ABlinds of
    gb1x2: begin
      ASmallBlind := 1;
      ABigBlind := 2;
    end;
    gb5x5: begin
      ASmallBlind := 5;
      ABigBlind := 5;
    end;
    gb5x10: begin
      ASmallBlind := 5;
      ABigBlind := 10;
    end;
    gb10x25: begin
      ASmallBlind := 10;
      ABigBlind := 25;
    end;
    gb25x50: begin
      ASmallBlind := 25;
      ABigBlind := 50;
    end;
    gb50x100: begin
      ASmallBlind := 50;
      ABigBlind := 100;
    end;
    gsOther: begin
      ASmallBlind := 0;
      ABigBlind := 0;
    end;
  end;
end;

function TGameInfo.AsString(const AShort: Boolean): String;
begin
  result := GameTypeToStr(FGameType, FGameLimit, AShort);
end;

class function TGameInfo.GameTypeToStr(const AGameType: TGameType; const AGameLimit: TGameLimit; const AShort: Boolean): String;
begin
  result := '';
  case AGameLimit of
    glNoLimit: if AShort then
      result := 'NL'
    else
      result := 'No Limit';
    glFixedLimit: if AShort then
      result := 'FL'
    else
      result := 'Fixed Limit';
    glPotLimit: if AShort then
      result := 'PL'
    else
      result := 'Pot Limit';
  end;

  case AGameType of
    gtHoldem: if AShort then
      result := result + 'H'
    else
      result := result + ' Hold''em';
    gtOmaha: if AShort then
      result := result + 'O'
    else
      result := result + ' Omaha';
    gtRotationNLHPLO: result := 'Rotation NLH/PLO';
  end;
end;

function TGameInfo.GetStateStr: String;
begin
  case FState of
    gsActive: result := 'Open';
    gsClosing: result := 'Closing';
    gsClosed: result := 'Closed';
    gsEmpty: result := 'Open';
  else
    result := 'Unknown';
  end;
end;

end.
