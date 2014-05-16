unit Poker.Objects.GameInfo;

interface

uses
  Winapi.Windows, System.Generics.Collections, System.SysUtils, Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.TableStatus,
  Poker.Common.Misc;

type
  TGameInfo = class
  private
    FMongoId    : TBytes;
    FClubId     : Int64;
    FCreatorId  : TBytes;
    FName       : String;
    FSmallBlind : UINT32;
    FBigBlind   : UINT32;
    FGameType   : TGameType;
    FGameLimit  : TGameLimit;
    FMinBuyin   : UINT32;
    FMaxBuyin   : UINT32;
    FSeats      : Integer;
    FSitting    : Integer;
    FState      : TGameState;
    FClosingTime: DWORD;
    FLastHandId : UINT32;

    function GetGameTypeStr: String;
    function GetGameTypeStrFull: String;
    function GetStateStr: String;

  public
    constructor Create(const AProtobufObject: TPB_Game); overload;

    procedure UpdateFromProtobufObject(const AProtobufObject: TPB_Game);
    procedure UpdateFromTableStatus(const ATableStatus: TPB_TableStatus);

    property MongoId        : TBytes read FMongoId write FMongoId;
    property ClubId         : Int64 read FClubId write FClubId;
    property CreatorId      : TBytes read FCreatorId write FCreatorId;
    property Name           : String read FName write FName;
    property SmallBlind     : UINT32 read FSmallBlind write FSmallBlind;
    property BigBlind       : UINT32 read FBigBlind write FBigBlind;
    property GameType       : TGameType read FGameType write FGameType;
    property GameTypeStr    : String read GetGameTypeStr;
    property GameTypeStrFull: String read GetGameTypeStrFull;
    property Limit          : TGameLimit read FGameLimit write FGameLimit;
    property MinBuyin       : UINT32 read FMinBuyin write FMinBuyin;
    property MaxBuyin       : UINT32 read FMaxBuyin write FMaxBuyin;
    property Seats          : Integer read FSeats write FSeats;
    property Sitting        : Integer read FSitting write FSitting;
    property State          : TGameState read FState write FState;
    property StateAsStr     : String read GetStateStr;
    property ClosingTime    : DWORD read FClosingTime write FClosingTime;
    property LastHandId     : UINT32 read FLastHandId;

  end;

  TPB_Games = TObjectList<TPB_Game>;

  TGamesInfo = class(TObjectList<TGameInfo>)
  public
    procedure UpdateFromProtobufObjects(const AProtobufObjects: TPB_Games);

    function AddGame(const AProtobufObject: TPB_Game): TGameInfo;
    function FindGame(const AMongoId: TBytes; var AGameInfo: TGameInfo): Boolean;
    function IndexOf(const AMongoId: TBytes): Integer;
  end;

implementation

{$IFDEF DEBUG}
uses
  Poker.Forms.Debug;
{$ENDIF}

constructor TGameInfo.Create(const AProtobufObject: TPB_Game);
begin
  UpdateFromProtobufObject(AProtobufObject);
end;

procedure TGameInfo.UpdateFromProtobufObject(const AProtobufObject: TPB_Game);
begin
  FMongoId := AProtobufObject.MongoId;
  FCreatorId := AProtobufObject.CreatorMongoId;
  FClubId := AProtobufObject.Clubseq;
  FName := AProtobufObject.Gamename;
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

procedure TGameInfo.UpdateFromTableStatus(const ATableStatus: TPB_TableStatus);
begin
  FMongoId := ATableStatus.TableMongoId;
  FSitting := ATableStatus.Seats.Count;
end;

function TGameInfo.GetGameTypeStr: String;
begin
  case FGameType of
    gtHoldem: result := 'Holdem';
    gtOmaha: result := 'Omaha';
    gtRotationNLHPLO: result := 'Rotation NLH/PLO';
  end;
end;

function TGameInfo.GetGameTypeStrFull: String;
begin
  result := GetGameTypeStr;
  if FGameType = gtRotationNLHPLO then
    Exit;

  case FGameLimit of
    glNoLimit: result := 'NL ' + result;
    glFixedLimit: result := 'FL ' + result;
    glPotLimit: result := 'PL ' + result;
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

{ TGamesInfo }

function TGamesInfo.AddGame(const AProtobufObject: TPB_Game): TGameInfo;
var
  index: Integer;
begin
  {$IFDEF DEBUG}
  if Length(AProtobufObject.MongoId) = 0 then
    DebugLn(Format('Game [%s] mongo id is empty!', [AProtobufObject.Gamename]), ditException);
  {$ENDIF}

  index := IndexOf(AProtobufObject.MongoId);
  if index = -1 then
    index := Add(TGameInfo.Create(AProtobufObject))
  else
    Items[index].UpdateFromProtobufObject(AProtobufObject);
  result := Items[index];
end;

function TGamesInfo.FindGame(const AMongoId: TBytes; var AGameInfo: TGameInfo): Boolean;
var
  index: Integer;
begin
  index := IndexOf(AMongoId);
  if index = -1 then
    Exit(FALSE)
  else
  begin
    AGameInfo := ToArray[index];
    Exit(TRUE);
  end;
end;

function TGamesInfo.IndexOf(const AMongoId: TBytes): Integer;
var
  C1   : Integer;
  a1len: Integer;
begin
  a1len := Length(AMongoId);
  for C1 := 0 to Length(ToArray) - 1 do
    if CompareBytes(AMongoId, ToArray[C1].MongoId, a1len) then
      Exit(C1);

  Exit(-1);
end;

procedure TGamesInfo.UpdateFromProtobufObjects(const AProtobufObjects: TPB_Games);
var
  game: TPB_Game;
begin
  Clear;
  for game in AProtobufObjects do
    AddGame(game);
end;

end.
