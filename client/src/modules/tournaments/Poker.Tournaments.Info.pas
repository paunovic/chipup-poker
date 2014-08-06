unit Poker.Tournaments.Info;

interface

uses
  Poker.Protobufs.Objects.TournamentInfo, Poker.Protobufs.Objects.TournamentMember, System.Generics.Collections,
  Poker.Games.GameList;

type
  TTournamentInfo = class(TPB_TournamentInfo)
  private
    FGames: TGameList;
  public
    constructor Create(const ATournamentInfo: TPB_TournamentInfo);
    destructor Destroy; override;

    property Games: TGameList read FGames write FGames;
  end;

implementation

{ TTournamentInfo }

constructor TTournamentInfo.Create(const ATournamentInfo: TPB_TournamentInfo);
begin
  inherited Create(ATournamentInfo);
  FGames := TGameList.Create;
end;

destructor TTournamentInfo.Destroy;
begin
  FGames.Free;
  inherited;
end;

end.
