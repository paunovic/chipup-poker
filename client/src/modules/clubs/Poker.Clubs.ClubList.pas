unit Poker.Clubs.ClubList;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Clubs.Club, Poker.Protobufs.Objects.Club, Poker.Games.Game, System.SyncObjs;

type
  TClubList = class(TObjectDictionary<TBytes, TClubInfo>)
  private
    FLock: TCriticalSection;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;

    function GetAndLock(const AId: TBytes; out AClub: TClubInfo): Boolean; overload;
    function GetAndLockByGame(const AMongoId: TBytes; out AClub: TClubInfo; out AGame: TGameInfo): Boolean;

    procedure AddClub(const AProtobufObject: TPB_Club);
  end;

implementation


{ TClubList }

constructor TClubList.Create;
begin
  FLock := TCriticalSection.Create;
  inherited Create([doOwnsValues]);
end;

destructor TClubList.Destroy;
begin
  inherited;
  FLock.Free;
end;

procedure TClubList.AddClub(const AProtobufObject: TPB_Club);
var
  club: TClubInfo;
begin
  FLock.Enter;
  try
    if TryGetValue(AProtobufObject.MongoId, club) then
      club.Assign(AProtobufObject)
    else
    begin
      club := TClubInfo.Create;
      club.Assign(AProtobufObject);
      Add(club.MongoId, club);
    end;
  finally
    FLock.Leave;
  end;
end;

function TClubList.GetAndLockByGame(const AMongoId: TBytes; out AClub: TClubInfo; out AGame: TGameInfo): Boolean;
var
  club: TClubInfo;
  game: TGameInfo;
begin
  Lock;
  for club in Values do
    if club.Games.TryGetValue(AMongoId, game) then
    begin
      AClub := club;
      AGame := game;
      Exit(TRUE);
    end;
  Unlock;
  Exit(FALSE);
end;

function TClubList.GetAndLock(const AId: TBytes; out AClub: TClubInfo): Boolean;
begin
  AClub := nil;
  Lock;
  result := TryGetValue(AId, AClub);
  if not result then
    Unlock;
end;

procedure TClubList.Lock;
begin
  FLock.Enter;
end;

procedure TClubList.Unlock;
begin
  FLock.Leave;
end;

end.
