unit Poker.Forms.TournamentLobby;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Poker.Interfaces.FormParams, Poker.Types;

type
  TfrmTournamentLobby = class(TForm, IFormParams)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}
    FTournamentId: TMongoId;
    FCallbacksId: Integer;
  public
    procedure SetParams(const AParams: array of pointer);

    property TournamentId: TMongoId read FTournamentId;
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Server.MessageContainer, Poker.Protobufs.Enum.ServerCodes, Poker.Common.FormsContainer;

procedure TfrmTournamentLobby.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                  ]);
end;

procedure TfrmTournamentLobby.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);

  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}
end;

procedure TfrmTournamentLobby.SetParams(const AParams: array of pointer);
begin
  FTournamentId := AParams[0];

  {$IFDEF DEBUG} FDebugId := RegisterDebugObject(Format('Tournament Lobby [%s]', [FTournamentId.ToString])); {$ENDIF}
end;

procedure TfrmTournamentLobby.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;


end.
