unit uClubLobbyForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, uIFormParams, uClubInfo, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, cxLabel, Vcl.Menus, cxButtons, dxSkinscxPCPainter,
  cxPCdxBarPopupMenu, cxPC, cxGroupBox, Vcl.ActnList, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator, cxBlobEdit,
  cxTextEdit, cxSpinEdit, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxClasses, cxGridCustomView, cxGrid, uPlayerInfo, dxBevel,
  uMessageItem, dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton, dxGDIPlusClasses, cxImage;

type
  TfrmClubLobby = class(TForm, IFormParams)
    lbsHeader: TcxLabel;
    lbsSubheader: TcxLabel;
    btClubHome: TcxButton;
    btTables: TcxButton;
    pcTabs: TcxPageControl;
    tsClubHome: TcxTabSheet;
    tsTables: TcxTabSheet;
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
    gbTables: TcxGroupBox;
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
    btLeaveClub: TcxButton;
    acLeaveClub: TAction;
    imgHeader: TcxImage;
    btPrijatnaPunina: TcxButton;
    procedure btClubHomeClick(Sender: TObject);
    procedure btTablesClick(Sender: TObject);
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
    procedure acLeaveClubExecute(Sender: TObject);
    procedure gridGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FClubId: Integer;
    FSelectedPlayerId: TBytes;
    FSelectedGameId: TBytes;

    procedure ConfigureGUI;

    procedure UpdatePlayerlist;
    procedure UpdateGamesList;

    procedure CSRStatus(const AMessage: TMessageItem);
    procedure CSRLeaveClub(const AMessage: TMessageItem);
    procedure CSRClubDetailsChange(const AMessage: TMessageItem);
    procedure CSRKickPlayer(const AMessage: TMessageItem);
    procedure CSRGetUsers(const AMessage: TMessageItem);
    procedure CSRETransferChipsOk(const AMessage: TMessageItem);

    procedure CSROwnerGiveawayNotOwner(const AMessage: TMessageItem);
    procedure CSROwnerGiveawayInvalidPlayerId(const AMessage: TMessageItem);
    procedure CSROwnerGiveawayInvalidClubId(const AMessage: TMessageItem);
    procedure CSREGameOperation(const AMessage: TMessageItem);
    procedure CSREClubOperation(const AMessage: TMessageItem);

  protected
    procedure WndProc(var AMessage: TMessage); override;

  public
    procedure SetParams(const AParams: array of pointer);
  end;


implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uCommon, uSocketClient, uMainDataModule, uGiveChipsForm, uChangeClubDetailsForm, uServerMessageCallback, uServerCodes,
  uMessageContainer, uPB_StatusReply, uGameInfo, uCreateGameForm, uEditGameForm, uPB_Club, uPB_Game, uPB_ClubCommandReply;


procedure TfrmClubLobby.FormCreate(Sender: TObject);
begin
  // following block fixes Delphi IDE bug that shifts components by several pixels up occassionally
  btGiveChips.Top := gbPlayers.Height - btGiveChips.Height - 13;
  btGiveOwnership.Top := btGiveChips.Top;
  btRemovePlayerFromClub.Top := btGiveChips.Top;
  btSuspendUnsuspend.Top := btGiveChips.Top - btGiveChips.Height - 5;
  btNewGame.Top := gbTables.Height - btNewGame.Height - 13;
  btEditGame.Top := btNewGame.Top;
  btDeleteGame.Top := btNewGame.Top;
end;

procedure TfrmClubLobby.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmClubLobby.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmClubLobby.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmClubLobby.SetParams(const AParams: array of pointer);
begin
  FClubId := PInteger(AParams[0])^;

  btClubHome.Click;
  ConfigureGUI;
end;

procedure TfrmClubLobby.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(srStatus, CSRStatus),
                            TServerMessageCallback.Create(srLeaveClubReply, CSRLeaveClub),
                            TServerMessageCallback.Create(srChangeClubDetailsReply, CSRClubDetailsChange),
                            TServerMessageCallback.Create(srKickPlayerReply, CSRKickPlayer),
                            TServerMessageCallback.Create(srGetPlayers, CSRGetUsers),
                            TServerMessageCallback.Create(srOwnershipGiveAwayNotOwner, CSROwnerGiveawayNotOwner),
                            TServerMessageCallback.Create(srOwnershipGiveawayInvalidPlayerId, CSROwnerGiveawayInvalidPlayerId),
                            TServerMessageCallback.Create(srOwnershipGiveAwayInvalidClubId, CSROwnerGiveawayInvalidClubId),
                            TServerMessageCallback.Create(srOwnershipGiveAwayOk, CSREClubOperation),
                            TServerMessageCallback.Create(srSuspendPlayerOk, CSREClubOperation),
                            TServerMessageCallback.Create(srReinstatePlayerOk, CSREClubOperation),
                            TServerMessageCallback.Create(seClubChange, CSREClubOperation),
                            TServerMessageCallback.Create(seClubDeleted, CSREClubOperation),
                            TServerMessageCallback.Create(seGameDelete, CSREGameOperation),
                            TServerMessageCallback.Create(seGameChange, CSREGameOperation),
                            TServerMessageCallback.Create(seGameCreate, CSREGameOperation),
                            TServerMessageCallback.Create(srEditGameOk, CSREGameOperation),
                            TServerMessageCallback.Create(srCreateGameOk, CSREGameOperation),
                            TServerMessageCallback.Create(srClubDisbandOk, CSREClubOperation),
                            TServerMessageCallback.Create(srTransferChipsOk, CSRETransferChipsOk),
                            TServerMessageCallback.Create(seTransferChips, CSRETransferChipsOk),
                            TServerMessageCallback.Create(srDeleteGameOk, CSREGameOperation)
                          ]
                        );
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmClubLobby.ConfigureGUI;
var
  club         : TClubInfo;
  player       : TPlayerInfo;
  manager      : String;
  admin_visible: Boolean;
begin
  if dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
  begin
    Caption := Format('%s Lobby', [club.Name]);

    lbsHeader.Caption := club.Name;

    manager := '';
    if dmMain.Players.FindPlayerById(club.OwnerId, player) then
      manager := player.Nick;

    lbsSubheader.Caption := Format('Club Manager: %s           Members: %d           Club ID: %d', [manager, Length(club.Players), club.Id]);

    admin_visible := CompareBytes(club.OwnerId, dmMain.SelfInfo.Id);

    btChangeClubDetails.Visible := admin_visible;
    acShowClubChangeDetailsForm.Enabled := admin_visible;
    btCloseClub.Visible := admin_visible;
    acCloseClub.Enabled := admin_visible;
    btGiveChips.Visible := admin_visible;
    acGiveChips.Enabled := (admin_visible) and (Length(FSelectedPlayerId) > 0) and (CompareBytes(club.OwnerId, dmMain.SelfInfo.Id)) and (not CompareBytes(club.OwnerId, FSelectedPlayerId));
    btGiveOwnership.Visible := admin_visible;
    acGiveOwnership.Enabled := acGiveChips.Enabled;
    btRemovePlayerFromClub.Visible := admin_visible;
    acRemovePlayer.Enabled := acGiveChips.Enabled;
    btSuspendUnsuspend.Visible := admin_visible;
    acSuspendPlayer.Enabled := acGiveChips.Enabled;
    acReinstatePlayer.Enabled := acGiveChips.Enabled;
    btNewGame.Visible := admin_visible;
    acShowCreateGameForm.Enabled := admin_visible;
    btDeleteGame.Visible := admin_visible;
    acDeleteGame.Enabled := (admin_visible) and (Length(FSelectedGameId) > 0);
    btEditGame.Visible := admin_visible;
    acShowEditGameForm.Enabled := (admin_visible) and (Length(FSelectedGameId) > 0);
    Bevel1.Visible := admin_visible;
    btLeaveClub.Visible := not admin_visible;
    acLeaveClub.Enabled := not admin_visible;
    if admin_visible then
    begin
      gridPlayersList.Align := alTop;
      gridGames.Align := alTop;

      gridPlayersList.Height := btSuspendUnsuspend.Top - 5;
      gridGames.Height := btNewGame.Top - 5;
    end
    else
    begin
      gridPlayersList.Align := alClient;
      gridGames.Align := alClient;
    end;

    UpdatePlayerlist;
    UpdateGamesList;
  end;
end;

procedure TfrmClubLobby.btTablesClick(Sender: TObject);
begin
  pcTabs.ActivePage := tsTables;
end;

procedure TfrmClubLobby.btClubHomeClick(Sender: TObject);
begin
  pcTabs.ActivePage := tsClubHome;
end;

procedure TfrmClubLobby.gridGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acShowEditGameForm.Execute;
end;

procedure TfrmClubLobby.gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
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

  actions_enabled := (Length(FSelectedGameId) > 0) and (CompareBytes(club.OwnerId, dmMain.SelfInfo.Id));
  acDeleteGame.Enabled := actions_enabled;
  acShowEditGameForm.Enabled := actions_enabled;
end;

procedure TfrmClubLobby.gridPlayersListTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
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

procedure TfrmClubLobby.UpdatePlayerlist;
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
    gridPlayersListTable.DataController.SetValue(ARowIndex, gridPlayersListBalance.Index, player.Balance / 100);

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

procedure TfrmClubLobby.UpdateGamesList;
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

procedure TfrmClubLobby.acCloseClubExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  if MessageDlg('Are you sure you want to disband the club?', mtConfirmation, mbYesNo, 0) = mrYes then
    SocketClient.DisbandClub(club.Id);
end;

procedure TfrmClubLobby.acGiveChipsExecute(Sender: TObject);
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

procedure TfrmClubLobby.acGiveOwnershipExecute(Sender: TObject);
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

procedure TfrmClubLobby.acLeaveClubExecute(Sender: TObject);
begin
  if MessageDlg('Are you sure you want to leave this club?', mtConfirmation, mbYesNo, 0) = mrYes then
    SocketClient.LeaveClub(FClubId);
end;

procedure TfrmClubLobby.acRemovePlayerExecute(Sender: TObject);
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

procedure TfrmClubLobby.acShowClubChangeDetailsFormExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  RunModalForm(TfrmChangeClubDetails, self, [club]);
end;

procedure TfrmClubLobby.acShowCreateGameFormExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  RunModalForm(TfrmCreateGame, self, [club]);
end;

procedure TfrmClubLobby.acShowEditGameFormExecute(Sender: TObject);
var
  club: TClubInfo;
  game: TGameInfo;
begin
  if (not dmMain.SelfInfo.Clubs.FindClub(FClubId, club)) or
     (not club.Games.FindGame(FSelectedGameId, game)) then
    Exit;

  RunModalForm(TfrmEditGame, self, [game]);
end;

procedure TfrmClubLobby.acSuspendPlayerExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  SocketClient.ChangePlayerSuspendState(club.MongoId, FSelectedPlayerId, TRUE);
end;

procedure TfrmClubLobby.acReinstatePlayerExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FClubId, club) then
    Exit;

  SocketClient.ChangePlayerSuspendState(club.MongoId, FSelectedPlayerId, FALSE);
end;

procedure TfrmClubLobby.acDeleteGameExecute(Sender: TObject);
begin
  SocketClient.DeleteGame(FSelectedGameId);
end;

procedure TfrmClubLobby.CSRStatus(const AMessage: TMessageItem);
begin
  ConfigureGUI;
end;

procedure TfrmClubLobby.CSRETransferChipsOk(const AMessage: TMessageItem);
begin
  ConfigureGUI;
end;

procedure TfrmClubLobby.CSRClubDetailsChange(const AMessage: TMessageItem);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AMessage.Object_ as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: ConfigureGUI;
    csNameExists: ;
  else
    {$IFDEF DEBUG} DebugLn(Format('CSRLeaveClub: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
  end;
end;

procedure TfrmClubLobby.CSRLeaveClub(const AMessage: TMessageItem);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AMessage.Object_ as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: ModalResult := mrClose;
    csInvalidClubId: ;
  else
    {$IFDEF DEBUG} DebugLn(Format('CSRLeaveClub: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
  end;
end;

procedure TfrmClubLobby.CSRKickPlayer(const AMessage: TMessageItem);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AMessage.Object_ as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: ConfigureGUI;
    csInvalidClubId: MessageDlg('Invalid club ID', mtError, [mbOk], 0);
  else
    {$IFDEF DEBUG} DebugLn(Format('CSRKickPlayer: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
  end;
end;

procedure TfrmClubLobby.CSROwnerGiveawayInvalidClubId(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid club ID', mtError, [mbOk], 0);
end;

procedure TfrmClubLobby.CSROwnerGiveawayInvalidPlayerId(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid player ID', mtError, [mbOk], 0);
end;

procedure TfrmClubLobby.CSROwnerGiveawayNotOwner(const AMessage: TMessageItem);
begin
  MessageDlg('You are not owner of this club', mtError, [mbOk], 0);
end;

procedure TfrmClubLobby.CSREClubOperation(const AMessage: TMessageItem);
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

procedure TfrmClubLobby.CSREGameOperation(const AMessage: TMessageItem);
var
  pbgame: TPB_Game;
begin
  pbgame := AMessage.Object_ as TPB_Game;

  if pbgame.Clubseq = FClubId then
    ConfigureGUI;
end;

procedure TfrmClubLobby.CSRGetUsers(const AMessage: TMessageItem);
begin
  UpdatePlayerlist;
end;

end.
