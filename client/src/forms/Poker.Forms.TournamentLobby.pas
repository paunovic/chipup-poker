unit Poker.Forms.TournamentLobby;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Poker.Interfaces.FormParams, Poker.Types, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxBlobEdit, cxTextEdit, cxSpinEdit, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxClasses, cxGridCustomView, cxGrid, cxCurrencyEdit,
  Vcl.Menus, Vcl.ActnList, Vcl.StdCtrls, cxButtons;

type
  TfrmTournamentLobby = class(TForm, IFormParams)
    gridPlayers: TcxGrid;
    gridPlayersTable: TcxGridTableView;
    gridPlayersMongoId: TcxGridColumn;
    gridPlayersName: TcxGridColumn;
    gridPlayersLevel: TcxGridLevel;
    gridPlayersChips: TcxGridColumn;
    StyleRepository: TcxStyleRepository;
    stylePlayersSelf: TcxStyle;
    stylePlayersOther: TcxStyle;
    btTournamentRegister: TcxButton;
    alTournamentLobby: TActionList;
    acRegister: TAction;
    acUnregister: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure gridPlayersTableStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure acRegisterExecute(Sender: TObject);
    procedure acUnregisterExecute(Sender: TObject);
  private
    {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}
    FTournamentId: TMongoId;
    FCallbacksId: Integer;

    procedure QueryTournamentInfo;
    procedure CSRTournamentDetails(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTournamentReply(const AMethodId: Integer; const AObject: TObject);
    procedure UpdatePlayersGrid;
    procedure RefreshAll;
  public
    procedure SetParams(const AParams: array of pointer);

    property TournamentId: TMongoId read FTournamentId;
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Server.MessageContainer, Poker.Protobufs.Enum.ServerCodes, Poker.Common.FormsContainer, Poker.Server.Socket, Poker.Server.MessageCallbacks,
  Poker.Protobufs.Objects.TournamentInfo, Poker.Tournaments, Poker.Tournaments.Info, Poker.DataModule, Poker.Protobufs.Objects.TournamentCommandParams;

procedure TfrmTournamentLobby.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srTournamentDetails, CSRTournamentDetails),
                      TServerMessageCallback.Create(srTournamentReply, CSRTournamentReply)
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
  QueryTournamentInfo;
end;

procedure TfrmTournamentLobby.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmTournamentLobby.QueryTournamentInfo;
begin
  ServerSocket.GetTournamentDetails(FTournamentId);
end;

procedure TfrmTournamentLobby.CSRTournamentDetails(const AMethodId: Integer; const AObject: TObject);
var
  proto: TPB_TournamentInfo;
begin
  if not TTypes.TryCast<TPB_TournamentInfo>(AObject, proto) then
    Exit;

  Tournaments.Add(proto);
  gridPlayersTable.OptionsView.NoDataToDisplayInfoText := ' ';
  alTournamentLobby.State := asNormal;
  RefreshAll;
end;

procedure TfrmTournamentLobby.UpdatePlayersGrid;
var
  c: TcxDataController;
  tournament: TTournamentInfo;
  rec_count: Integer;
  C1: Integer;
begin
  if Tournaments.GetAndLock(FTournamentId, tournament) then
  try
    c := gridPlayersTable.DataController;
    c.BeginFullUpdate;
    try
      rec_count := 0;
      for C1 := 0 to tournament.Players.Count - 1 do
      begin
        Inc(rec_count);
        if rec_count > c.RecordCount then
          c.SetRecordCount(rec_count);
        c.SetValue(rec_count - 1, gridPlayersMongoId.Index, tournament.Players[C1].MongoId.ToVariant);
        c.SetValue(rec_count - 1, gridPlayersName.Index, tournament.Players[C1].Displayname);
        c.SetValue(rec_count - 1, gridPlayersChips.Index, tournament.Players[C1].Chips / 100);
      end;
      c.SetRecordCount(rec_count);
    finally
      c.EndFullUpdate;
    end;
  finally
    Tournaments.Unlock;
  end;
end;

procedure TfrmTournamentLobby.gridPlayersTableStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
var
  mongoid: TMongoId;
begin
  mongoid := ARecord.Values[gridPlayersMongoId.Index];
  if mongoid = dmMain.SelfInfo.MongoId then
    AStyle := stylePlayersSelf
  else
    AStyle := stylePlayersOther;
end;

procedure TfrmTournamentLobby.CSRTournamentReply(const AMethodId: Integer; const AObject: TObject);
var
  proto: TPB_TournamentCommandParams;
begin
  if not TTypes.TryCast<TPB_TournamentCommandParams>(AObject, proto) then
    Exit;
  if proto.MongoId <> FTournamentId then
    Exit;

  QueryTournamentInfo;
end;

procedure TfrmTournamentLobby.acRegisterExecute(Sender: TObject);
begin
  ServerSocket.TournamentRegister(FTournamentId);
end;

procedure TfrmTournamentLobby.acUnregisterExecute(Sender: TObject);
begin
  ServerSocket.TournamentUnregister(FTournamentId);
end;

procedure TfrmTournamentLobby.RefreshAll;
var
  tournament: TTournamentInfo;
begin
  if not Tournaments.GetAndLock(FTournamentId, tournament) then
  begin
    acRegister.Enabled := FALSE;
    acUnregister.Enabled := FALSE;
  end
  else
    try
      acRegister.Enabled := (tournament.State = tnsOpen) and (not dmMain.SelfInfo.RegisteredTournaments.Contains(FTournamentId));
      acUnregister.Enabled := (tournament.State = tnsOpen) and (dmMain.SelfInfo.RegisteredTournaments.Contains(FTournamentId));
    finally
      Tournaments.Unlock;
    end;

  if acUnregister.Enabled then
  begin
    btTournamentRegister.Action := acUnregister;
    btTournamentRegister.Colors.HotText := $001111DF;
    btTournamentRegister.Colors.NormalText := $001111BF;
    btTournamentRegister.Colors.PressedText := $001111BF;
  end
  else
  begin
    btTournamentRegister.Action := acRegister;
    btTournamentRegister.Colors.HotText := $0000E600;
    btTournamentRegister.Colors.NormalText := $0000BF00;
    btTournamentRegister.Colors.PressedText := $0000BF00;
  end;

  UpdatePlayersGrid;
end;



end.
