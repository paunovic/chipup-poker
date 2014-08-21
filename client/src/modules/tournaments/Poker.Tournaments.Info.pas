unit Poker.Tournaments.Info;

interface

uses
  Poker.Protobufs.Objects.TournamentInfo, Poker.Protobufs.Objects.TournamentMember, System.Generics.Collections, Poker.Protobufs.Objects.Game,
  Poker.Games.GameList;

type
  TTournamentInfo = class(TPB_TournamentInfo)
  private
  public
    constructor Create(const ATournamentInfo: TPB_TournamentInfo);
    destructor Destroy; override;

    procedure AddGame(const AGame: TPB_Game);
    function SecondsUntilNextLevel: Integer;

    function StateToStr: String;
  end;

implementation

uses
  Winapi.Windows, Poker.Server.Socket;

{ TTournamentInfo }

constructor TTournamentInfo.Create(const ATournamentInfo: TPB_TournamentInfo);
begin
  inherited Create(ATournamentInfo, TRUE);
end;

destructor TTournamentInfo.Destroy;
begin
  inherited;
end;

function TTournamentInfo.SecondsUntilNextLevel: Integer;
var
  current_level_end_time, gtc: DWORD;
begin
  gtc := GetTickCount;
  current_level_end_time := CurrentBlindLevelEndTime - ServerSocket.TimeOffset;
  if current_level_end_time < gtc then
    result := 0
  else
    result := (current_level_end_time - gtc) div 1000;
end;

function TTournamentInfo.StateToStr: String;
begin
  case State of
    tnsOpen: result := 'Open';
    tnsInProgress: result := 'In Progress';
    tnsCancelled: result := 'Cancelled'
  else
    result := 'Unknown';
  end;
end;

procedure TTournamentInfo.AddGame(const AGame: TPB_Game);
var
  game: TPB_Game;
begin
  for game in Games do
    if game.MongoId = AGame.MongoId then
    begin
      game.Clear;
      game.MergeFrom(AGame);
      Exit;
    end;
  Games.Add(TPB_Game.Create(AGame));
end;


end.
