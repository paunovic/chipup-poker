unit Poker.Objects.Clubs.ClubList;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Objects.Clubs.Club, Poker.Protobufs.Objects.Club, Poker.Objects.Games.Game;

type
  TClubList = class(TObjectDictionary<TBytes, TClubInfo>)
  public
    constructor Create;

    function AddClub(const AProtobufObject: TPB_Club): TClubInfo;
    function FindClubBySeq(const ASeq: Integer; var AClubInfo: TClubInfo): Boolean;
    function FindGame(const AMongoId: TBytes; out AClub: TClubInfo; out AGame: TGameInfo): Boolean;
  end;

implementation


{ TClubList }

constructor TClubList.Create;
begin
  inherited Create([doOwnsValues]);
end;


function TClubList.AddClub(const AProtobufObject: TPB_Club): TClubInfo;
var
  club: TClubInfo;
begin
  if TryGetValue(AProtobufObject.MongoId, club) then
    club.Assign(AProtobufObject)
  else
  begin
    club := TClubInfo.Create;
    club.Assign(AProtobufObject);
    Add(club.MongoId, club);
  end;

  result := club;
end;

function TClubList.FindClubBySeq(const ASeq: Integer; var AClubInfo: TClubInfo): Boolean;
var
  clubinfo: TClubInfo;
begin
  for clubinfo in Values do
    if clubinfo.Id = ASeq then
    begin
      AClubInfo := clubinfo;
      Exit(TRUE);
    end;

  Exit(FALSE);
end;

function TClubList.FindGame(const AMongoId: TBytes; out AClub: TClubInfo; out AGame: TGameInfo): Boolean;
var
  club: TClubInfo;
  game: TGameInfo;
begin
  for club in Values do
    if club.Games.TryGetValue(AMongoId, game) then
    begin
      AClub := club;
      AGame := game;
      Exit(TRUE);
    end;
  Exit(FALSE);
end;

end.
