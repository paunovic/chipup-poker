unit Poker.Players.Player;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Clubs.ClubList, Poker.Protobufs.Objects.LoginReply, Poker.Types,
  Poker.Protobufs.Objects.User, Poker.Protobufs.Objects.PlayerClubStatus;

type
  TPlayerInfo = class(TPB_User)
  private
    FPassword: String;
    FClubs: TClubList;
    FRegisteredTournaments: TList<TMongoId>;
    FClubStatuses: TObjectDictionary<TMongoId, TPB_PlayerClubStatus>;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Flush;

    procedure LoadFromLoginReply(const ALoginReply: TPB_LoginReply);

    property Password: String read FPassword write FPassword;
    property Clubs: TClubList read FClubs;
    property RegisteredTournaments: TList<TMongoId> read FRegisteredTournaments;
    property ClubStatuses: TObjectDictionary<TMongoId, TPB_PlayerClubStatus> read FClubStatuses;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Tables.TableList, Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.Game, Poker.Common.Misc, Poker.Clubs.Club,
  Poker.Tables.Table, Poker.Games.Game, Poker.Tournaments, Poker.Tournaments.Info;

{ TPlayerInfo }

constructor TPlayerInfo.Create;
begin
  inherited Create(TRUE);

  FClubs := TClubList.Create;
  FRegisteredTournaments := TList<TMongoId>.Create;
  FClubStatuses := TObjectDictionary<TMongoId, TPB_PlayerClubStatus>.Create([doOwnsValues]);
end;

destructor TPlayerInfo.Destroy;
begin
  FClubStatuses.Free;
  FRegisteredTournaments.Free;
  FClubs.Free;

  inherited;
end;

procedure TPlayerInfo.Flush;
begin
  Clear;
  FClubs.Clear;
  FPassword := '';
  FRegisteredTournaments.Clear;
  FClubStatuses.Clear;
end;

procedure TPlayerInfo.LoadFromLoginReply(const ALoginReply: TPB_LoginReply);
var
  pcs: TPB_PlayerClubStatus;
begin
  Clear;
  MergeFrom(ALoginReply.Self);
  FClubStatuses.Clear;
  for pcs in ALoginReply.PlayerClubStatuses do
    FClubStatuses.Add(pcs.Clubid, TPB_PlayerClubStatus.Create(pcs, TRUE));
end;

end.
