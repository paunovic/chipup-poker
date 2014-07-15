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

    function AddClub(const AProtobufObject: TPB_Club): TClubInfo;
    function FindClubBySeq(const ASeq: Integer; var AClubInfo: TClubInfo): Boolean;
    function FindGame(const AMongoId: TBytes; out AClub: TClubInfo; out AGame: TGameInfo): Boolean;
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

function TClubList.AddClub(const AProtobufObject: TPB_Club): TClubInfo;
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

    result := club;
  finally
    FLock.Leave;
  end;
end;

function TClubList.FindClubBySeq(const ASeq: Integer; var AClubInfo: TClubInfo): Boolean;
var
  clubinfo: TClubInfo;
begin
  FLock.Enter;
  try
    for clubinfo in Values do
      if clubinfo.Id = ASeq then
      begin
        AClubInfo := clubinfo;
        Exit(TRUE);
      end;

    Exit(FALSE);
  finally
    FLock.Leave;
  end;
end;

function TClubList.FindGame(const AMongoId: TBytes; out AClub: TClubInfo; out AGame: TGameInfo): Boolean;
var
  club: TClubInfo;
  game: TGameInfo;
begin
  FLock.Enter;
  try
    for club in Values do
      if club.Games.TryGetValue(AMongoId, game) then
      begin
        AClub := club;
        AGame := game;
        Exit(TRUE);
      end;
    Exit(FALSE);
  finally
    FLock.Leave;
  end;
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
