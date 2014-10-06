unit Poker.Clubs.Club;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Games.GameList, Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.ClubStatsReply,
  Poker.Protobufs.Objects.ClubPlayerStats, Poker.Protobufs.Objects.ClubMember, Poker.Types;

type
  TClubInfo = class
  private
    FId: Integer;
    FMongoId: TMongoId;
    FOwnerId: TMongoId;
    FName: String;
    FPassword: String;
    FMembers: TObjectList<TPB_ClubMember>;
    FGames: TGameList;
    FRake: Integer;
    FPrivate: Boolean;
    FDefaultBalanceLimit: UINT32;
    FUnlimitedDefaultBalance: Boolean;
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

    property Id: Integer read FId;
    property MongoId: TMongoId read FMongoId;
    property OwnerId: TMongoId read FOwnerId;
    property Name: String read FName;
    property Password: String read FPassword;
    property Members: TObjectList<TPB_ClubMember> read FMembers;
    property Games: TGameList read FGames;
    property Rake: Integer read FRake;
    property IsPrivate: Boolean read FPrivate write FPrivate;
    property DefaultBalanceLimit: UINT32 read FDefaultBalanceLimit;
    property UnlimitedDefaultBalance: Boolean read FUnlimitedDefaultBalance;
  end;

implementation

uses
  Poker.Common.Misc, Poker.Games.Game;

{ TClubInfo }

constructor TClubInfo.Create;
begin
  FMembers := TObjectList<TPB_ClubMember>.Create;
  FGames := TGameList.Create;
end;

destructor TClubInfo.Destroy;
begin
  FGames.Free;
  FMembers.Free;

  inherited;
end;

function TClubInfo.GetMemberInfo(const AMongoId: TMongoId; out AMemberInfo: TPB_ClubMember): Boolean;
var
  member: TPB_ClubMember;
begin
  for member in FMembers do
    if AMongoId = member.MongoId then
    begin
      AMemberInfo := member;
      Exit(TRUE);
    end;
  Exit(FALSE);
end;

procedure TClubInfo.Assign(const AProtobufObject: TPB_Club);
var
  member: TPB_ClubMember;
begin
  FMongoId := AProtobufObject.MongoId;
  FOwnerId := AProtobufObject.Owner;
  FId := AProtobufObject.Seq;
  FName := AProtobufObject.Name;
  FPassword := AProtobufObject.Password;
  FMembers.Clear;
  for member in AProtobufObject.Members do
    AddMember(member);
  FRake := AProtobufObject.Rake;
  FPrivate := AProtobufObject.IsPrivate;
  FDefaultBalanceLimit := AProtobufObject.DefaultBalanceLimit;
  FUnlimitedDefaultBalance := AProtobufObject.UnlimitedDefaultBalance;
end;

procedure TClubInfo.Assign(const AClubInfo: TClubInfo; const AAssignGames: Boolean = TRUE);
var
  member: TPB_ClubMember;
  game: TGameInfo;
  gamecopy: TGameInfo;
begin
  FMongoId := AClubInfo.MongoId;
  FOwnerId := AClubInfo.OwnerId;
  FId := AClubInfo.Id;
  FName := AClubInfo.Name;
  FPassword := AClubInfo.Password;
  FMembers.Clear;
  for member in AClubInfo.Members do
    AddMember(member);
  FRake := AClubInfo.Rake;
  FPrivate := AClubInfo.IsPrivate;
  FDefaultBalanceLimit := AClubInfo.DefaultBalanceLimit;
  FUnlimitedDefaultBalance := AClubInfo.UnlimitedDefaultBalance;
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
  FMembers.Add(cmi);
end;

end.
