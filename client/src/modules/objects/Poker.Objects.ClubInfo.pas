unit Poker.Objects.ClubInfo;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Objects.GameInfo, Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.ClubMember,
  Poker.Protobufs.Objects.ClubStatsReply, Poker.Protobufs.Objects.ClubPlayerStats;


type
  TClubMemberInfo = class
  private
    FMongoId: TBytes;
    FSuspended: Boolean;
    FBalanceLimit: UINT32;
    FClubBalance: Int32;
    FUnlimitedLimit: Boolean;
  public
    constructor Create(const AClubMemberProtobuf: TPB_ClubMember);

    property MongoId: TBytes read FMongoId;
    property Suspended: Boolean read FSuspended;
    property BalanceLimit: UINT32 read FBalanceLimit;
    property ClubBalance: Int32 read FClubBalance write FClubBalance;
    property UnlimitedLimit: Boolean read FUnlimitedLimit;
  end;

  TClubInfo = class
  private
    FId: Integer;
    FMongoId: TBytes;
    FOwnerId: TBytes;
    FName: String;
    FInvCode: String;
    FMembers: TObjectList<TClubMemberInfo>;
    FGames: TGamesInfo;
    FRake: Integer;
    FPrivate: Boolean;
    FDefaultBalanceLimit: UINT32;
    FUnlimitedDefaultBalance: Boolean;
  public
    constructor Create(const AProtobufObject: TPB_Club);
    destructor Destroy; override;

    procedure UpdateFromProtobufObject(const AProtobufObject: TPB_Club);
    procedure UpdateFromClubStats(const AClubStats: TPB_ClubStatsReply);
    procedure UpdateMember(const AMemberId: TBytes; const ALimit: UINT32; const AUnlimited: Boolean);
    procedure ResetMemberBalance(const AMemberId: TBytes);

    procedure AddMember(const AClubMemberInfo: TPB_ClubMember);
    function GetMemberInfo(const AMongoId: TBytes; out AMemberInfo: TClubMemberInfo): Boolean;

    property Id: Integer read FId;
    property MongoId: TBytes read FMongoId;
    property OwnerId: TBytes read FOwnerId;
    property Name: String read FName;
    property InvCode: String read FInvCode;
    property Members: TObjectList<TClubMemberInfo> read FMembers;
    property Games: TGamesInfo read FGames;
    property Rake: Integer read FRake;
    property IsPrivate: Boolean read FPrivate write FPrivate;
    property DefaultBalanceLimit: UINT32 read FDefaultBalanceLimit;
    property UnlimitedDefaultBalance: Boolean read FUnlimitedDefaultBalance;
  end;

  TClubsInfo = class(TObjectList<TClubInfo>)
  public
    function AddClub(const AProtobufObject: TPB_Club): TClubInfo;
    function FindClub(const AId: Integer; var AClubInfo: TClubInfo): Boolean; overload;
    function FindClub(const AMongoId: TBytes; var AClubInfo: TClubInfo): Boolean; overload;
    function IndexOf(const AId: Integer): Integer;
  end;

implementation

uses
  Poker.Common.Misc;

{ TClubInfo }

constructor TClubInfo.Create(const AProtobufObject: TPB_Club);
begin
  FMembers := TObjectList<TClubMemberInfo>.Create;
  FGames := TGamesInfo.Create;
  UpdateFromProtobufObject(AProtobufObject);
end;

destructor TClubInfo.Destroy;
begin
  FGames.Free;
  FMembers.Free;

  inherited;
end;

function TClubInfo.GetMemberInfo(const AMongoId: TBytes; out AMemberInfo: TClubMemberInfo): Boolean;
var
  member: TClubMemberInfo;
begin
  for member in FMembers do
    if CompareBytes(AMongoId, member.MongoId) then
    begin
      AMemberInfo := member;
      Exit(TRUE);
    end;
  Exit(FALSE);
end;

procedure TClubInfo.UpdateFromProtobufObject(const AProtobufObject: TPB_Club);
var
  member: TPB_ClubMember;
begin
  FMongoId := AProtobufObject.MongoId;
  FOwnerId := AProtobufObject.Owner;
  FId := AProtobufObject.Seq;
  FName := AProtobufObject.Name;
  FInvCode := AProtobufObject.Password;
  FMembers.Clear;
  for member in AProtobufObject.Members do
    AddMember(member);
  FRake := AProtobufObject.Rake;
  FPrivate := AProtobufObject.IsPrivate;
  FDefaultBalanceLimit := AProtobufObject.DefaultBalanceLimit;
  FUnlimitedDefaultBalance := AProtobufObject.UnlimitedDefaultBalance;
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

procedure TClubInfo.UpdateMember(const AMemberId: TBytes; const ALimit: UINT32; const AUnlimited: Boolean);
var
  member: TClubMemberInfo;
begin
  if GetMemberInfo(AMemberId, member) then
  begin
    member.FBalanceLimit := ALimit;
    member.FUnlimitedLimit := AUnlimited;
  end;
end;

procedure TClubInfo.ResetMemberBalance(const AMemberId: TBytes);
var
  member: TClubMemberInfo;
begin
  if GetMemberInfo(AMemberId, member) then
    member.FClubBalance := 0;
end;

procedure TClubInfo.AddMember(const AClubMemberInfo: TPB_ClubMember);
var
  cmi: TClubMemberInfo;
begin
  cmi := TClubMemberInfo.Create(AClubMemberInfo);
  FMembers.Add(cmi);
end;


{ TPlayerClubsInfo }

function TClubsInfo.AddClub(const AProtobufObject: TPB_Club): TClubInfo;
var
  index: Integer;
begin
  index := IndexOf(AProtobufObject.Seq);
  if index = -1 then
    index := Add(TClubInfo.Create(AProtobufObject))
  else
    Items[index].UpdateFromProtobufObject(AProtobufObject);

  result := Items[index];
end;

function TClubsInfo.FindClub(const AId: Integer; var AClubInfo: TClubInfo): Boolean;
var
  clubinfo: TClubInfo;
begin
  for clubinfo in self.ToArray do
    if clubinfo.Id = AId then
    begin
      AClubInfo := clubinfo;
      Exit(TRUE);
    end;

  Exit(FALSE);
end;

function TClubsInfo.FindClub(const AMongoId: TBytes; var AClubInfo: TClubInfo): Boolean;
var
  clubinfo: TClubInfo;
begin
  for clubinfo in self.ToArray do
    if CompareBytes(clubinfo.MongoId, AMongoId) then
    begin
      AClubInfo := clubinfo;
      Exit(TRUE);
    end;

  Exit(FALSE);
end;

function TClubsInfo.IndexOf(const AId: Integer): Integer;
var
  C1: Integer;
begin
  for C1 := 0 to Length(self.ToArray) - 1 do
    if self.ToArray[C1].Id = AId then
      Exit(C1);

  Exit(-1);
end;

{ TClubMemberInfo }

constructor TClubMemberInfo.Create(const AClubMemberProtobuf: TPB_ClubMember);
begin
  FMongoId := AClubMemberProtobuf.MongoId;
  FSuspended := AClubMemberProtobuf.Suspended;
  FBalanceLimit := AClubMemberProtobuf.BalanceLimit;
  FClubBalance := AClubMemberProtobuf.ClubBalance;
  FUnlimitedLimit := AClubMemberProtobuf.UnlimitedLimit;
end;

end.
