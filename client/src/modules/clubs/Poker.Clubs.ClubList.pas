unit Poker.Clubs.ClubList;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Clubs.Club, Poker.Protobufs.Objects.Club, Poker.Games.Game, Poker.Common.SafeMutex, Poker.Types;

type
  TClubList = class(TObjectDictionary<TMongoId, TClubInfo>)
  private
    FLock: TSafeMutex;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;

    function GetAndLock(const AClubId: TMongoId; out AClub: TClubInfo): Boolean; overload;
    function GetAndLockByGame(const AGameId: TMongoId; out AClub: TClubInfo; out AGame: TGameInfo): Boolean;

    procedure AddClub(const AProtobufObject: TPB_Club);
  end;

implementation


{ TClubList }

constructor TClubList.Create;
begin
  FLock := TSafeMutex.Create;
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
  FLock.Acquire;
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
    FLock.Release;
  end;
end;

function TClubList.GetAndLockByGame(const AGameId: TMongoId; out AClub: TClubInfo; out AGame: TGameInfo): Boolean;
var
  club: TClubInfo;
  game: TGameInfo;
begin
  Lock;
  for club in Values do
    if club.Games.TryGetValue(AGameId, game) then
    begin
      AClub := club;
      AGame := game;
      Exit(TRUE);
    end;
  Unlock;
  Exit(FALSE);
end;

function TClubList.GetAndLock(const AClubId: TMongoId; out AClub: TClubInfo): Boolean;
begin
  AClub := nil;
  Lock;
  result := TryGetValue(AClubId, AClub);
  if not result then
    Unlock;
end;

procedure TClubList.Lock;
begin
  FLock.Acquire;
end;

procedure TClubList.Unlock;
begin
  FLock.Release;
end;

end.
