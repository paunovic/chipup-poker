unit Poker.Clubs.Club;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Games.GameList,
  Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.ClubStatsReply,
  Poker.Protobufs.Objects.ClubPlayerStats, Poker.Protobufs.Objects.ClubMember,
  Poker.Types;

type
  TClubInfo = class(TPB_Club)
  private
    FGames: TGameList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Assign(const AProtobufObject: TPB_Club); overload;
    procedure Assign(const AClubInfo: TClubInfo; const AAssignGames: Boolean = TRUE); overload;
    procedure UpdateFromClubStats(const AClubStats: TPB_ClubStatsReply);
    procedure UpdateMember(const AMemberId: TMongoId; const ALimit: UINT32; const AUnlimited: Boolean);
    procedure SetMemberInfo(const AMemberInfo: TPB_ClubMember);

    procedure AddMember(const AClubMemberInfo: TPB_ClubMember);
    function GetMemberInfo(const AMongoId: TMongoId; out AMemberInfo: TPB_ClubMember): Boolean;

    property Games: TGameList read FGames;
  end;

implementation

uses
  Poker.Common.Misc, Poker.Games.Game;

{ TClubInfo }

constructor TClubInfo.Create;
begin
  inherited Create(TRUE);
  FGames := TGameList.Create;
end;

destructor TClubInfo.Destroy;
begin
  FGames.Free;

  inherited;
end;

function TClubInfo.GetMemberInfo(const AMongoId: TMongoId; out AMemberInfo: TPB_ClubMember): Boolean;
var
  member: TPB_ClubMember;
begin
  for member in Members do
    if AMongoId = member.MongoId then
    begin
      AMemberInfo := member;
      Exit(TRUE);
    end;
  Exit(FALSE);
end;

procedure TClubInfo.Assign(const AProtobufObject: TPB_Club);
begin
  Clear;
  MergeFrom(AProtobufObject);
end;

procedure TClubInfo.Assign(const AClubInfo: TClubInfo; const AAssignGames: Boolean = TRUE);
var
  game: TGameInfo;
  gamecopy: TGameInfo;
begin
  Clear;
  MergeFrom(AClubInfo as TPB_Club);
  FGames.Clear;
  if AAssignGames then
    for game in AClubInfo.Games.Values do
    begin
      gamecopy := TGameInfo.Create;
      gamecopy.Assign(game);
      FGames.Add(gamecopy.MongoId, gamecopy);
    end;
end;

procedure TClubInfo.UpdateFromClubStats(const AClubStats: TPB_ClubStatsReply);
var
  playerstats: TPB_ClubPlayerStats;
  member: TPB_ClubMember;
begin
  for playerstats in AClubStats.PlayerStats do
    if GetMemberInfo(playerstats.Userid, member) then
      member.ClubBalance := playerstats.ClubBalance;
end;

procedure TClubInfo.UpdateMember(const AMemberId: TMongoId; const ALimit: UINT32; const AUnlimited: Boolean);
var
  member: TPB_ClubMember;
begin
  if GetMemberInfo(AMemberId, member) then
  begin
    member.BalanceLimit := ALimit;
    member.UnlimitedLimit := AUnlimited;
  end;
end;

procedure TClubInfo.SetMemberInfo(const AMemberInfo: TPB_ClubMember);
var
  member: TPB_ClubMember;
begin
  if GetMemberInfo(AMemberInfo.MongoId, member) then
  begin
    member.Clear;
    member.MergeFrom(AMemberInfo);
  end
  else
    AddMember(AMemberInfo);
end;

procedure TClubInfo.AddMember(const AClubMemberInfo: TPB_ClubMember);
var
  cmi: TPB_ClubMember;
begin
  cmi := TPB_ClubMember.Create(AClubMemberInfo, TRUE);
  Members.Add(cmi);
end;

end.
