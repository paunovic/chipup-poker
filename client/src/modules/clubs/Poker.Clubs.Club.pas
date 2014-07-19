unit Poker.Clubs.Club;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Games.GameList, Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.ClubStatsReply,
  Poker.Protobufs.Objects.ClubPlayerStats, Poker.Clubs.Member, Poker.Protobufs.Objects.ClubMember, Poker.Types;

type
  TClubInfo = class
  private
    FId: Integer;
    FMongoId: TMongoId;
    FOwnerId: TMongoId;
    FName: String;
    FPassword: String;
    FMembers: TObjectList<TClubMemberInfo>;
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
    procedure ResetMemberBalance(const AMemberId: TMongoId);

    procedure AddMember(const AClubMemberInfo: TPB_ClubMember); overload;
    procedure AddMember(const AClubMemberInfo: TClubMemberInfo); overload;
    function GetMemberInfo(const AMongoId: TMongoId; out AMemberInfo: TClubMemberInfo): Boolean;

    property Id: Integer read FId;
    property MongoId: TMongoId read FMongoId;
    property OwnerId: TMongoId read FOwnerId;
    property Name: String read FName;
    property Password: String read FPassword;
    property Members: TObjectList<TClubMemberInfo> read FMembers;
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
  FMembers := TObjectList<TClubMemberInfo>.Create;
  FGames := TGameList.Create;
end;

destructor TClubInfo.Destroy;
begin
  FGames.Free;
  FMembers.Free;

  inherited;
end;

function TClubInfo.GetMemberInfo(const AMongoId: TMongoId; out AMemberInfo: TClubMemberInfo): Boolean;
var
  member: TClubMemberInfo;
begin
  for member in FMembers do
    if CompareMongoId(AMongoId, member.MongoId) then
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
  member: TClubMemberInfo;
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
  member: TClubMemberInfo;
begin
  for playerstats in AClubStats.PlayerStats do
    if GetMemberInfo(playerstats.Userid, member) then
      member.ClubBalance := playerstats.ClubBalance;
end;

procedure TClubInfo.UpdateMember(const AMemberId: TMongoId; const ALimit: UINT32; const AUnlimited: Boolean);
var
  member: TClubMemberInfo;
begin
  if GetMemberInfo(AMemberId, member) then
  begin
    member.BalanceLimit := ALimit;
    member.UnlimitedLimit := AUnlimited;
  end;
end;

procedure TClubInfo.ResetMemberBalance(const AMemberId: TMongoId);
var
  member: TClubMemberInfo;
begin
  if GetMemberInfo(AMemberId, member) then
    member.ClubBalance := 0;
end;

procedure TClubInfo.AddMember(const AClubMemberInfo: TPB_ClubMember);
var
  cmi: TClubMemberInfo;
begin
  cmi := TClubMemberInfo.Create(AClubMemberInfo);
  FMembers.Add(cmi);
end;

procedure TClubInfo.AddMember(const AClubMemberInfo: TClubMemberInfo);
var
  cmi: TClubMemberInfo;
begin
  cmi := TClubMemberInfo.Create(AClubMemberInfo);
  FMembers.Add(cmi);
end;


end.
