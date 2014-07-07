unit Poker.Clubs.Member;

interface

uses
  System.SysUtils, Poker.Protobufs.Objects.ClubMember;

type
  TClubMemberInfo = class
  private
    FMongoId: TBytes;
    FSuspended: Boolean;
    FBalanceLimit: UINT32;
    FClubBalance: Int32;
    FUnlimitedLimit: Boolean;
  public
    constructor Create(const AClubMemberProtobuf: TPB_ClubMember); overload;
    constructor Create(const AClubMemberInfo: TClubMemberInfo); overload;

    property MongoId: TBytes read FMongoId;
    property Suspended: Boolean read FSuspended;
    property BalanceLimit: UINT32 read FBalanceLimit write FBalanceLimit;
    property ClubBalance: Int32 read FClubBalance write FClubBalance;
    property UnlimitedLimit: Boolean read FUnlimitedLimit write FUnlimitedLimit;
  end;

implementation

{ TClubMemberInfo }

constructor TClubMemberInfo.Create(const AClubMemberProtobuf: TPB_ClubMember);
begin
  FMongoId := AClubMemberProtobuf.MongoId;
  FSuspended := AClubMemberProtobuf.Suspended;
  FBalanceLimit := AClubMemberProtobuf.BalanceLimit;
  FClubBalance := AClubMemberProtobuf.ClubBalance;
  FUnlimitedLimit := AClubMemberProtobuf.UnlimitedLimit;
  Assert(Length(FMongoId) = 12);
end;

constructor TClubMemberInfo.Create(const AClubMemberInfo: TClubMemberInfo);
begin
  FMongoId := AClubMemberInfo.MongoId;
  FSuspended := AClubMemberInfo.Suspended;
  FBalanceLimit := AClubMemberInfo.BalanceLimit;
  FClubBalance := AClubMemberInfo.ClubBalance;
  FUnlimitedLimit := AClubMemberInfo.UnlimitedLimit;
end;

end.
