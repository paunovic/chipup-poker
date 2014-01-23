unit uClubLobbyManagerForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uIFormParams, uClubInfo, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinDarkRoom, cxLabel, Vcl.Menus, cxButtons, dxSkinscxPCPainter,
  cxPCdxBarPopupMenu, cxPC, cxGroupBox, Vcl.ActnList, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator, cxBlobEdit,
  cxTextEdit, cxSpinEdit, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxClasses, cxGridCustomView, cxGrid, uPlayerInfo, dxBevel,
  uMessageItem;

type
  TfrmClubLobbyManager = class(TForm, IFormParams)
    lbsHeader: TcxLabel;
    lbsSubheader: TcxLabel;
    btManageClub: TcxButton;
    btGames: TcxButton;
    pcTabs: TcxPageControl;
    tsManageClub: TcxTabSheet;
    tsGames: TcxTabSheet;
    gbClubSettings: TcxGroupBox;
    btCloseClub: TcxButton;
    gbPlayers: TcxGroupBox;
    gridPlayersList: TcxGrid;
    gridPlayersListTable: TcxGridTableView;
    gridPlayersListId: TcxGridColumn;
    gridPlayersListName: TcxGridColumn;
    gridPlayersListBalance: TcxGridColumn;
    gridPlayersListLevel: TcxGridLevel;
    btGiveChips: TcxButton;
    btGiveOwnership: TcxButton;
    btRemovePlayerFromClub: TcxButton;
    alManageClubs: TActionList;
    acRemovePlayer: TAction;
    acGiveOwnership: TAction;
    acShowClubChangeDetailsForm: TAction;
    acCloseClub: TAction;
    acGiveChips: TAction;
    acShowCreateGameForm: TAction;
    acDeleteGame: TAction;
    acShowEditGameForm: TAction;
    btChangeClubDetails: TcxButton;
    gridPlayersListStatus: TcxGridColumn;
    Bevel1: TdxBevel;
    btSuspendUnsuspend: TcxButton;
    gbGames: TcxGroupBox;
    gridGames: TcxGrid;
    gridGamesTable: TcxGridTableView;
    gridGamesId: TcxGridColumn;
    gridGamesName: TcxGridColumn;
    gridGamesType: TcxGridColumn;
    gridGamesBlinds: TcxGridColumn;
    gridGamesSeats: TcxGridColumn;
    gridGamesLevel: TcxGridLevel;
    btNewGame: TcxButton;
    btDeleteGame: TcxButton;
    btEditGame: TcxButton;
    acSuspendPlayer: TAction;
    acReinstatePlayer: TAction;
    procedure btManageClubClick(Sender: TObject);
    procedure btGamesClick(Sender: TObject);
    procedure acCloseClubExecute(Sender: TObject);
    procedure gridPlayersListTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure acGiveChipsExecute(Sender: TObject);
    procedure acGiveOwnershipExecute(Sender: TObject);
    procedure acRemovePlayerExecute(Sender: TObject);
    procedure acShowClubChangeDetailsFormExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure acShowCreateGameFormExecute(Sender: TObject);
    procedure acDeleteGameExecute(Sender: TObject);
    procedure acShowEditGameFormExecute(Sender: TObject);
    procedure acSuspendPlayerExecute(Sender: TObject);
    procedure acReinstatePlayerExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FClubId: Integer;
    FSelectedPlayerId: TBytes;
    FSelectedGameId: TBytes;

    procedure ConfigureGUI;

    procedure UpdatePlayerlist;
    procedure UpdateGamesList;

    procedure TCStatusReply(const AMessage: TMessageItem);
    procedure TCKickPlayerOk(const AMessage: TMessageItem);
    procedure TCKickPlayerInvalidClubId(const AMessage: TMessageItem);
    procedure TCKickPlayerInvalidPlayerId(const AMessage: TMessageItem);
    procedure TCOwnerGiveawayOk(const AMessage: TMessageItem);
    procedure TCOwnerGiveawayNotOwner(const AMessage: TMessageItem);
    procedure TCOwnerGiveawayInvalidPlayerId(const AMessage: TMessageItem);
    procedure TCOwnerGiveawayInvalidClubId(const AMessage: TMessageItem);
    procedure TCClubDisbandOk(const AMessage: TMessageItem);
    procedure TCDeleteGameOk(const AMessage: TMessageItem);
    procedure TCSuspendPlayerOk(const AMessage: TMessageItem);
    procedure TCReinstatePlayerOk(const AMessage: TMessageItem);
    procedure CSEClubChange(const AMessage: TMessageItem);
    procedure CSEClubDeleted(const AMessage: TMessageItem);
    procedure CSEGameChange(const AMessage: TMessageItem);

  protected
    procedure WndProc(var AMessage: TMessage); override;

  public
    procedure SetParams(const AParams: array of pointer);
  end;


implementation

{$R *.dfm}

uses
  uCommon, uSocketClient, uMainDataModule, uGiveChipsForm, uChangeClubDetailsForm, uServerMessageCallback, uServerCodes,
  uMessageContainer, uPB_StatusReply, uGameInfo, uCreateGameForm, uEditGameForm, uPB_Club, uPB_Game;


procedure TfrmClubLobbyManager.FormCreate(Sender: TObject);
begin
  btGiveChips.Top := gbPlayers.Height - btGiveChips.Height - 13;
  btGiveOwnership.Top := btGiveChips.Top;
  btRemovePlayerFromClub.Top := btGiveChips.Top;
  btSuspendUnsuspend.Top := btGiveChips.Top - btGiveChips.Height - 5;

  btNewGame.Top := gbGames.Height - btNewGame.Height - 13;
  btEditGame.Top := btNewGame.Top;
  btDeleteGame.Top := btNewGame.Top;
end;

procedure TfrmClubLobbyManager.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmClubLobbyManager.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmClubLobbyManager.SetParams(const AParams: array of pointer);
begin
  FClubId := PInteger(AParams[0])^;

  btManageClub.Click;
  ConfigureGUI;
end;

procedure TfrmClubLobbyManager.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(srStatus, TCStatusReply),
                            TServerMessageCallback.Create(srKickPlayerOk, TCKickPlayerOk),
                            TServerMessageCallback.Create(srKickPlayerInvalidClubId, TCKickPlayerInvalidClubId),
                            TServerMessageCallback.Create(srKickPlayerInvalidPlayerId, TCKickPlayerInvalidPlayerId),
                            TServerMessageCallback.Create(srOwnershipGiveAwayNotOwner, TCOwnerGiveawayNotOwner),
                            TServerMessageCallback.Create(srOwnershipGiveawayInvalidPlayerId, TCOwnerGiveawayInvalidPlayerId),
                            TServerMessageCallback.Create(srOwnershipGiveAwayInvalidClubId, TCOwnerGiveawayInvalidClubId),
                            TServerMessageCallback.Create(srOwnershipGiveAwayOk, TCOwnerGiveawayOk),
                            TServerMessageCallback.Create(srClubDisbandOk, TCClubDisbandOk),
                            TServerMessageCallback.Create(srDeleteGameOk, TCDeleteGameOk),
                            TServerMessageCallback.Create(srSuspendPlayerOk, TCSuspendPlayerOk),
                            TServerMessageCallback.Create(srReinstatePlayerOk, TCReinstatePlayerOk),
                            TServerMessageCallback.Create(seClubChange, CSEClubChange),
                            TServerMessageCallback.Create(seClubDeleted, CSEClubDeleted)
//                            TServerMessageCallback.Create(seGameChange, CSEGameChange)
                          ]
                        );
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmClubLobbyManager.ConfigureGUI;
var
  club   : TClubInfo;
  player : TPlayerInfo;
  manager: String;
begin
  if dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
  begin
    Caption := Format('%s Lobby', [club.Name]);

    lbsHeader.Caption := club.Name;

    manager := '';
    if dmMain.Players.FindPlayerById(club.OwnerId, player) then
      manager := player.Nick;

    lbsSubheader.Caption := Format('Club Manager: %s          Members: %d          Club ID: %d', [manager, Length(club.Players), club.Id]);

    UpdatePlayerlist;
    UpdateGamesList;
  end;
end;

procedure TfrmClubLobbyManager.btGamesClick(Sender: TObject);
begin
  pcTabs.ActivePage := tsGames;
end;

procedure TfrmClubLobbyManager.btManageClubClick(Sender: TObject);
begin
  pcTabs.ActivePage := tsManageClub;
end;

procedure TfrmClubLobbyManager.gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex       : Integer;
  club           : TClubInfo;
  actions_enabled: Boolean;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  recIndex := gridGamesTable.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
    SetLength(FSelectedGameId, 0)
  else
    FSelectedGameId := gridGamesTable.DataController.GetValue(recIndex, gridGamesId.Index);

  actions_enabled := Length(FSelectedGameId) > 0;
  acDeleteGame.Enabled := actions_enabled;
  acShowEditGameForm.Enabled := actions_enabled;
end;

procedure TfrmClubLobbyManager.gridPlayersListTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex      : Integer;
  action_enabled: Boolean;
  club          : TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  recIndex := gridPlayersListTable.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
    SetLength(FSelectedPlayerId, 0)
  else
    FSelectedPlayerId := gridPlayersListTable.DataController.GetValue(recIndex, gridPlayersListId.Index);

  action_enabled := (Length(FSelectedPlayerId) > 0) and (CompareBytes(club.OwnerId, dmMain.SelfInfo.Id)) and (not CompareBytes(club.OwnerId, FSelectedPlayerId));
  acRemovePlayer.Enabled := action_enabled;
  acGiveOwnership.Enabled := action_enabled;
  acGiveChips.Enabled := action_enabled;

  if action_enabled then
  begin
    if club.IsSuspendedPlayer(FSelectedPlayerId) then
    begin
      btSuspendUnsuspend.Action := acReinstatePlayer;
      acSuspendPlayer.Enabled := FALSE;
      acReinstatePlayer.Enabled := TRUE;
    end
    else
    begin
      btSuspendUnsuspend.Action := acSuspendPlayer;
      acReinstatePlayer.Enabled := FALSE;
      acSuspendPlayer.Enabled := TRUE;
    end;
  end
  else
  begin
    acSuspendPlayer.Enabled := FALSE;
    acReinstatePlayer.Enabled := FALSE;
  end;
end;

procedure TfrmClubLobbyManager.UpdatePlayerlist;
var
  club: TClubInfo;

  procedure AddPlayerToGrid(const ARowIndex: Integer; AId: TBytes);
  var
    player: TPlayerInfo;
    status: String;
  begin
    if not dmMain.Players.FindPlayerById(AId, player) then
      Exit;

    gridPlayersListTable.DataController.SetValue(ARowIndex, gridPlayersListId.Index, player.Id);
    gridPlayersListTable.DataController.SetValue(ARowIndex, gridPlayersListName.Index, player.Nick);
    gridPlayersListTable.DataController.SetValue(ARowIndex, gridPlayersListBalance.Index, player.Balance);

    if CompareBytes(player.Id, club.OwnerId) then
      status := 'Owner'
    else
    begin
      status := 'Member';
      if club.IsSuspendedPlayer(AId) then
        status := 'Suspended';
    end;
    gridPlayersListTable.DataController.SetValue(ARowIndex, gridPlayersListStatus.Index, status);
  end;

var
  C1: Integer;
begin
  gridPlayersListTable.DataController.BeginFullUpdate;
  try
    gridPlayersListTable.DataController.SetRecordCount(0);

    if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    begin
      gridPlayersListTable.DataController.SetRecordCount(0);
      Exit;
    end;

    gridPlayersListTable.DataController.SetRecordCount(Length(club.Players));
    for C1 := 0 to Length(club.Players) - 1 do
      AddPlayerToGrid(C1, club.Players[C1]);
  finally
    gridPlayersListTable.DataController.EndFullUpdate;
  end;
end;

procedure TfrmClubLobbyManager.UpdateGamesList;
var
  C1  : Integer;
  game: TGameInfo;
  club: TClubInfo;
begin
  gridGamesTable.DataController.BeginFullUpdate;
  try
    gridGamesTable.DataController.SetRecordCount(0);

    if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    begin
      gridGamesTable.DataController.SetRecordCount(0);
      Exit;
    end;

    gridGamesTable.DataController.SetRecordCount(club.Games.Count);
    for C1 := 0 to club.Games.Count - 1 do
    begin
      game := club.Games[C1];

      gridGamesTable.DataController.SetValue(C1, gridGamesId.Index, game.MongoId);
      gridGamesTable.DataController.SetValue(C1, gridGamesName.Index, game.Name);
      gridGamesTable.DataController.SetValue(C1, gridGamesType.Index, game.GameTypeStrFull);
      gridGamesTable.DataController.SetValue(C1, gridGamesBlinds.Index, Format('%d/%d', [game.SmallBlind, game.BigBlind]));
      gridGamesTable.DataController.SetValue(C1, gridGamesSeats.Index, game.Seats);
    end;
  finally
    gridGamesTable.DataController.EndFullUpdate;
  end;
end;

procedure TfrmClubLobbyManager.acCloseClubExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  if MessageDlg('Are you sure you want to disband the club?', mtConfirmation, mbYesNo, 0) = mrYes then
    SocketClient.DisbandClub(club.Id);
end;

procedure TfrmClubLobbyManager.acGiveChipsExecute(Sender: TObject);
var
  club  : TClubInfo;
  player: TPlayerInfo;
begin
  if (not dmMain.SelfInfo.Clubs.FindClub(FClubId, club)) or
     (not dmMain.Players.FindPlayerById(FSelectedPlayerId, player)) then
    Exit;

  if RunModalForm(TfrmGiveChips, GetParentForm(self) as TForm, [club, player]) = mrOk then
    SocketClient.Status;
end;

procedure TfrmClubLobbyManager.acGiveOwnershipExecute(Sender: TObject);
var
  club  : TClubInfo;
  player: TPlayerInfo;
begin
  if (not dmMain.SelfInfo.Clubs.FindClub(FClubId, club)) or
     (not dmMain.Players.FindPlayerById(FSelectedPlayerId, player)) then
    Exit;

  if MessageDlg(Format('Are you sure you want to give club ownership to %s?', [player.Nick]), mtConfirmation, mbYesNo, 0) = mrYes then
    SocketClient.GiveOwnership(club.Id, player.Id);
end;

procedure TfrmClubLobbyManager.acRemovePlayerExecute(Sender: TObject);
var
  club  : TClubInfo;
  player: TPlayerInfo;
begin
  if (not dmMain.SelfInfo.Clubs.FindClub(FClubId, club)) or
     (not dmMain.Players.FindPlayerById(FSelectedPlayerId, player)) then
    Exit;

  if MessageDlg(Format('Are you sure you want to remove %s from the club?', [player.Nick]), mtConfirmation, mbYesNo, 0) = mrYes then
    SocketClient.KickPlayer(club.Id, player.Id);
end;

procedure TfrmClubLobbyManager.acShowClubChangeDetailsFormExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  if RunModalForm(TfrmChangeClubDetails, self, [club]) = mrOk then
    SocketClient.Status;
end;

procedure TfrmClubLobbyManager.acShowCreateGameFormExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  if RunModalForm(TfrmCreateGame, self, [club]) = mrOk then
    SocketClient.Status;
end;

procedure TfrmClubLobbyManager.acShowEditGameFormExecute(Sender: TObject);
var
  club: TClubInfo;
  game: TGameInfo;
begin
  if (not dmMain.SelfInfo.Clubs.FindClub(FClubId, club)) or
     (not club.Games.FindGame(FSelectedGameId, game)) then
    Exit;

  if RunModalForm(TfrmEditGame, self, [game]) = mrOk then
    SocketClient.Status;
end;

procedure TfrmClubLobbyManager.acSuspendPlayerExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  SocketClient.ChangeSuspendState(club.MongoId, FSelectedPlayerId, TRUE);
end;

procedure TfrmClubLobbyManager.acReinstatePlayerExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  SocketClient.ChangeSuspendState(club.MongoId, FSelectedPlayerId, FALSE);
end;

procedure TfrmClubLobbyManager.acDeleteGameExecute(Sender: TObject);
begin
  SocketClient.DeleteGame(FSelectedGameId);
end;


procedure TfrmClubLobbyManager.TCStatusReply(const AMessage: TMessageItem);
begin
  ConfigureGUI;
end;

procedure TfrmClubLobbyManager.TCKickPlayerInvalidClubId(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid club ID', mtError, [mbOk], 0);
end;

procedure TfrmClubLobbyManager.TCKickPlayerInvalidPlayerId(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid player ID', mtError, [mbOk], 0);
end;

procedure TfrmClubLobbyManager.TCKickPlayerOk(const AMessage: TMessageItem);
begin
  SocketClient.Status;
end;

procedure TfrmClubLobbyManager.TCOwnerGiveawayInvalidClubId(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid club ID', mtError, [mbOk], 0);
end;

procedure TfrmClubLobbyManager.TCOwnerGiveawayInvalidPlayerId(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid player ID', mtError, [mbOk], 0);
end;

procedure TfrmClubLobbyManager.TCOwnerGiveawayNotOwner(const AMessage: TMessageItem);
begin
  MessageDlg('You are not owner of this club', mtError, [mbOk], 0);
end;

procedure TfrmClubLobbyManager.TCOwnerGiveawayOk(const AMessage: TMessageItem);
begin
  SocketClient.Status;
end;

procedure TfrmClubLobbyManager.TCClubDisbandOk(const AMessage: TMessageItem);
begin
  ModalResult := mrClose;
  SocketClient.Status;
end;

procedure TfrmClubLobbyManager.TCDeleteGameOk(const AMessage: TMessageItem);
begin
  SocketClient.Status;
end;

procedure TfrmClubLobbyManager.TCSuspendPlayerOk(const AMessage: TMessageItem);
begin
  SocketClient.Status;
end;

procedure TfrmClubLobbyManager.TCReinstatePlayerOk(const AMessage: TMessageItem);
begin
  SocketClient.Status;
end;

procedure TfrmClubLobbyManager.CSEClubChange(const AMessage: TMessageItem);
var
  pbclub: TPB_Club;
  club  : TClubInfo;
begin
  pbclub := AMessage.Object_ as TPB_Club;

  if FClubId <> pbclub.Seq then
    Exit;

  if dmMain.SelfInfo.Clubs.FindClub(pbclub.Seq, club) then
    ConfigureGUI
  else
    ModalResult := mrClose
end;

procedure TfrmClubLobbyManager.CSEClubDeleted(const AMessage: TMessageItem);
var
  pbclub: TPB_Club;
begin
  pbclub := AMessage.Object_ as TPB_Club;

  if FClubId = pbclub.Seq then
    ModalResult := mrClose;
end;

procedure TfrmClubLobbyManager.CSEGameChange(const AMessage: TMessageItem);
var
  pbgame: TPB_Game;
begin
  pbgame := AMessage.Object_ as TPB_Game;

  if pbgame.Clubseq = FClubId then
    ConfigureGUI;
end;

end.
