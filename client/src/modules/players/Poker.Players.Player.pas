unit Poker.Players.Player;

interface

uses
  System.Generics.Collections, System.SysUtils, Poker.Clubs.ClubList, Poker.Protobufs.Objects.LoginReply, Poker.Types,
  Poker.Protobufs.Objects.User;

type
  TPlayerInfo = class(TPB_User)
  private
    FPassword: String;
    FClubs: TClubList;
    FRegisteredTournaments: TList<TMongoId>;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Flush;

    procedure LoadFromLoginReply(const ALoginReply: TPB_LoginReply);

    property Password: String read FPassword write FPassword;
    property Clubs: TClubList read FClubs;
    property RegisteredTournaments: TList<TMongoId> read FRegisteredTournaments;
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
end;

destructor TPlayerInfo.Destroy;
begin
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
end;

procedure TPlayerInfo.LoadFromLoginReply(const ALoginReply: TPB_LoginReply);
begin
  Clear;
  MergeFrom(ALoginReply.Self);
end;

end.
