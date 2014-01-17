unit uGameInfo;

interface

uses
  System.Generics.Collections;

type
  TGameType = (gtHoldem, gtOmaha);
  TGameLimit = (glNoLimit, glLimit, glPotLimit);

  TGameInfo = class
  private
    FMongoId   : String;
    FClubId    : Int64;
    FCreatorId : String;
    FName      : String;
    FSmallBlind: Integer;
    FBigBlind  : Integer;
    FGameType  : TGameType;
    FGameLimit : TGameLimit;
    FSeats     : Integer;

    function GetGameTypeStr: String;
    function GetGameTypeStrFull: String;

  public
    constructor Create(const AMongoId, ACreatorId: String; AClubId: Int64; const AName: String; const AGameType: TGameType; const AGameLimit: TGameLimit; const ASmallBlind, ABigBlind, ASeats: Integer);

    property MongoId        : String read FMongoId write FMongoId;
    property ClubId         : Int64 read FClubId write FClubId;
    property CreatorId      : String read FCreatorId write FCreatorId;
    property Name           : String read FName write FName;
    property SmallBlind     : Integer read FSmallBlind write FSmallBlind;
    property BigBlind       : Integer read FBigBlind write FBigBlind;
    property GameType       : TGameType read FGameType write FGameType;
    property GameTypeStr    : String read GetGameTypeStr;
    property GameTypeStrFull: String read GetGameTypeStrFull;
    property Limit          : TGameLimit read FGameLimit write FGameLimit;
    property Seats          : Integer read FSeats write FSeats;
  end;

  TGamesInfo = class(TObjectList<TGameInfo>)
  public
    function AddGame(const AMongoId, ACreatorId: String; AClubId: Int64; const AName: String; const AGameType: TGameType; const AGameLimit: TGameLimit; const ASmallBlind, ABigBlind, ASeats: Integer): TGameInfo;
    function FindGame(const AMongoId: String; var AGameInfo: TGameInfo): Boolean;
    function IndexOf(const AMongoId: String): Integer;
  end;

implementation

{ TGameInfo }

constructor TGameInfo.Create(const AMongoId, ACreatorId: String; AClubId: Int64; const AName: String; const AGameType: TGameType; const AGameLimit: TGameLimit; const ASmallBlind, ABigBlind, ASeats: Integer);
begin
  FMongoId := AMongoId;
  FCreatorId := ACreatorId;
  FClubId := AClubId;
  FName := AName;
  FSmallBlind := ASmallBlind;
  FBigBlind := ABigBlind;
  FGameType := AGameType;
  FGameLimit := AGameLimit;
  FSeats := ASeats;
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
    glLimit: result := 'L ' + result;
    glPotLimit: result := 'PL ' + result;
  end;
end;

{ TGamesInfo }

function TGamesInfo.AddGame(const AMongoId, ACreatorId: String; AClubId: Int64; const AName: String; const AGameType: TGameType; const AGameLimit: TGameLimit; const ASmallBlind, ABigBlind, ASeats: Integer): TGameInfo;
var
  index: Integer;
begin
  index := IndexOf(AMongoId);
  if index = -1 then
    index := Add(TGameInfo.Create(AMongoId, ACreatorId, AClubId, AName, AGameType, AGameLimit, ASmallBlind, ABigBlind, ASeats))
  else
  begin
    Items[index].MongoId := AMongoId;
    Items[index].CreatorId := ACreatorId;
    Items[index].ClubId := AClubId;
    Items[index].Name := AName;
    Items[index].SmallBlind := ASmallBlind;
    Items[index].BigBlind := ABigBlind;
    Items[index].GameType := AGameType;
    Items[index].Limit := AGameLimit;
    Items[index].Seats := ASeats;
  end;
  result := Items[index];
end;

function TGamesInfo.FindGame(const AMongoId: String; var AGameInfo: TGameInfo): Boolean;
var
  gameinfo: TGameInfo;
begin
  for gameinfo in self.ToArray do
    if gameinfo.MongoId = AMongoId then
    begin
      AGameInfo := gameinfo;
      Exit(TRUE);
    end;

  Exit(FALSE);
end;

function TGamesInfo.IndexOf(const AMongoId: String): Integer;
var
  C1: Integer;
begin
  for C1 := 0 to Length(self.ToArray) - 1 do
    if self.ToArray[C1].MongoId = AMongoId then
      Exit(C1);

  Exit(-1);
end;


end.
