unit uGameInfo;

interface

uses
  System.Generics.Collections, System.SysUtils, uPB_Game, uPB_TableStatus, uCommon;

type
  TGameInfo = class
  private
    FMongoId   : TBytes;
    FClubId    : Int64;
    FCreatorId : TBytes;
    FName      : String;
    FSmallBlind: Integer;
    FBigBlind  : Integer;
    FGameType  : TGameType;
    FGameLimit : TGameLimit;
    FMinBuyin  : Integer;
    FMaxBuyin  : Integer;
    FSeats     : Integer;
    FSitting   : Integer;

    function GetGameTypeStr: String;
    function GetGameTypeStrFull: String;

  public
    constructor Create(const AProtobufObject: TPB_Game); overload;

    procedure UpdateFromProtobufObject(const AProtobufObject: TPB_Game);
    procedure UpdateFromTableStatus(const ATableStatus: TPB_TableStatus);

    property MongoId        : TBytes read FMongoId write FMongoId;
    property ClubId         : Int64 read FClubId write FClubId;
    property CreatorId      : TBytes read FCreatorId write FCreatorId;
    property Name           : String read FName write FName;
    property SmallBlind     : Integer read FSmallBlind write FSmallBlind;
    property BigBlind       : Integer read FBigBlind write FBigBlind;
    property GameType       : TGameType read FGameType write FGameType;
    property GameTypeStr    : String read GetGameTypeStr;
    property GameTypeStrFull: String read GetGameTypeStrFull;
    property Limit          : TGameLimit read FGameLimit write FGameLimit;
    property MinBuyin       : Integer read FMinBuyin write FMinBuyin;
    property MaxBuyin       : Integer read FMaxBuyin write FMaxBuyin;
    property Seats          : Integer read FSeats write FSeats;
    property Sitting        : Integer read FSitting write FSitting;
  end;

  TGamesInfo = class(TObjectList<TGameInfo>)
  public
    procedure UpdateFromProtobufObjects(const AProtobufObjects: TPB_Games);

    function AddGame(const AProtobufObject: TPB_Game): TGameInfo;
    function FindGame(const AMongoId: TBytes; var AGameInfo: TGameInfo): Boolean;
    function IndexOf(const AMongoId: TBytes): Integer;
  end;

implementation

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
  end;
end;

function TGameInfo.GetGameTypeStrFull: String;
begin
  case FGameType of
    gtHoldem: result := 'Holdem';
    gtOmaha: result := 'Omaha';
  end;

  case FGameLimit of
    glNoLimit: result := 'NL ' + result;
    glFixedLimit: result := 'FL ' + result;
    glPotLimit: result := 'PL ' + result;
  end;
end;


{ TGamesInfo }

function TGamesInfo.AddGame(const AProtobufObject: TPB_Game): TGameInfo;
var
  index: Integer;
begin
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
