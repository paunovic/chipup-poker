unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ActnList, Vcl.StdCtrls, Vcl.Menus, Vcl.AppEvnts, dxSkinsCore,
  cxLookAndFeels, dxSkinsForm, cxGraphics, cxControls, cxLookAndFeelPainters, cxStyles, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxClasses,
  cxGridLevel, cxGrid, cxTextEdit, cxSpinEdit, cxContainer, cxLabel, cxButtons, OverbyteIcsWSocket, uClubInfo, cxMaskEdit, cxDropDownEdit,
  uMessageItem, uGameInfo, cxBlobEdit, cxImage, dxsChipUpDark, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.ActnMenus,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnColorMaps, dxGDIPlusClasses, dxsChipUpDarkTabs, dxsChipUpRedButton;

type
  TfrmChipUpMain = class(TForm)
    SkinController: TdxSkinController;
    ActionManager: TActionManager;
    acLogout: TAction;
    acShowChangeEMailForm: TAction;
    acShowChangePasswordForm: TAction;
    acShowChangeAvatarForm: TAction;
    acShowCreateClubForm: TAction;
    acShowPublicClubsListForm: TAction;
    acShowJoinClubForm: TAction;
    acShowGameTableForm: TAction;
    acOpenClubLobby: TAction;
    MainMenu: TMainMenu;
    Account1: TMenuItem;
    Clubs1: TMenuItem;
    ChangeEmailAddress1: TMenuItem;
    ChangePassword1: TMenuItem;
    ChangeAvatar1: TMenuItem;
    N1: TMenuItem;
    Logout1: TMenuItem;
    SearchPublicClubs1: TMenuItem;
    acShowTournamentLayout: TAction;
    acShowHomeGamesLayout: TAction;
    imgCashier: TcxImage;
    acOpenCashier: TAction;
    imgHeader: TcxImage;
    paMain: TPanel;
    gridTournaments: TcxGrid;
    gridTournamentsTable: TcxGridTableView;
    cxGridColumn2: TcxGridColumn;
    gridTournamentsTableColumn4: TcxGridColumn;
    gridTournamentsTableColumn3: TcxGridColumn;
    gridTournamentsTableColumn1: TcxGridColumn;
    gridTournamentsTableColumn2: TcxGridColumn;
    cxGridColumn3: TcxGridColumn;
    gridTournamentsLevel: TcxGridLevel;
    btOpenClubLobby: TcxButton;
    gridGames: TcxGrid;
    gridGamesTable: TcxGridTableView;
    gridGamesId: TcxGridColumn;
    gridGamesName: TcxGridColumn;
    gridGamesType: TcxGridColumn;
    gridGamesBlinds: TcxGridColumn;
    gridGamesPlayers: TcxGridColumn;
    gridGamesStatus: TcxGridColumn;
    gridGamesLevel: TcxGridLevel;
    gridJoinedClubs: TcxGrid;
    gridJoinedClubsTable: TcxGridTableView;
    gridJoinedClubsId: TcxGridColumn;
    gridJoinedClubsClubName: TcxGridColumn;
    gridJoinedClubsStatus: TcxGridColumn;
    gridJoinedClubsLevel: TcxGridLevel;
    btTournaments: TcxButton;
    btHomeGames: TcxButton;
    btPrijatnaPunina: TcxButton;
    btOpenTournamentLobby: TcxButton;
    btCreateClub: TcxButton;
    btJoinClub: TcxButton;
    procedure acLogoutExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acShowCreateClubFormExecute(Sender: TObject);
    procedure acShowJoinClubFormExecute(Sender: TObject);
    procedure gridJoinedClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure acShowChangeEMailFormExecute(Sender: TObject);
    procedure acShowChangePasswordFormExecute(Sender: TObject);
    procedure acShowChangeAvatarFormExecute(Sender: TObject);
    procedure gridJoinedClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure gridGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure acShowGameTableFormExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure acOpenClubLobbyExecute(Sender: TObject);
    procedure acShowPublicClubsListFormExecute(Sender: TObject);
    procedure acShowHomeGamesLayoutExecute(Sender: TObject);
    procedure acShowTournamentLayoutExecute(Sender: TObject);
    procedure imgCashierMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure acOpenCashierExecute(Sender: TObject);
    procedure imgCashierMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
  private
    FSelectedClub: Integer;
    FSelectedGame: TBytes;

    function ShowLoginForm: Integer;

    procedure DoLogout;
    procedure UpdateClublist;
    procedure UpdateGamelist;

    procedure CSRLeaveClub(const AMessage: TMessageItem);
    procedure CSRClubCommand(const AMessage: TMessageItem);
    procedure CSRStatus(const AMessage: TMessageItem);
    procedure CSRGetUsers(const AMessage: TMessageItem);
    procedure CSRETransferChipsOk(const AMessage: TMessageItem);

    procedure CSRLogout(const AMessage: TMessageItem);
    procedure CSESecondaryLoginDetected(const AMessage: TMessageItem);
    procedure CSEChatEvent(const AMessage: TMessageItem);
    procedure CSEAccountConfirmed(const AMessage: TMessageItem);
    procedure CSEClubDeleted(const AMessage: TMessageItem);
    procedure CSREClubOperation(const AMessage: TMessageItem);
    procedure CSREGameOperation(const AMessage: TMessageItem);
    procedure CSREGameDelete(const AMessage: TMessageItem);
    procedure CSRTableStatus(const AMessage: TMessageItem);

    function ConfirmToCloseTables: Boolean;

    procedure SocketChangeState(const AOldState, ANewState: TSocketState);

    procedure ConfigureGUI;

    function GetSelectedGame(var AGame: TGameInfo): Boolean;
    function GetSelectedClub(var AClub: TClubInfo): Boolean;

  protected
    procedure DoCreate; override;
    procedure WndProc(var AMessage: TMessage); override;

  public
  end;

var
  frmChipUpMain: TfrmChipUpMain;

implementation

{$R *.dfm}

uses
  uSettings, uLoginForm, uSocketClient, uServerCodes, uCommon, uMainDataModule, uCreateClubForm, uJoinClubForm,
  uPlayerInfo, uChangeEMailForm, uChangePasswordForm, uChangeAvatarForm, uAvatars, uPublicClubsList, uPB_ClubCommandReply, uPB_User,
  uPB_StatusReply, uMessageContainer, uServerMessageCallback, uPB_Club, uPB_Game, uPB_TableStatus, uTables, uPB_GetUserParams,
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uPB_TransferChipsParams, uPB_ChatEvent, uPB_ChatMessage, uClubLobbyForm;


procedure TfrmChipUpMain.DoCreate;
begin
  inherited;

  ShowLoginForm;
end;

procedure TfrmChipUpMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmToCloseTables;
  if CanClose then
    dmMain.Tables.ClearWithoutNotification;
end;

procedure TfrmChipUpMain.FormCreate(Sender: TObject);
begin
  LoadImageFromResource(imgCashier, 'CashierNormal');
end;

procedure TfrmChipUpMain.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmChipUpMain.WndProc(var AMessage: TMessage);
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
                            TServerMessageCallback.Create(srChangeClubDetailsReply, CSRClubCommand),
                            TServerMessageCallback.Create(srCreateClubReply, CSRClubCommand),
                            TServerMessageCallback.Create(srJoinClubReply, CSRClubCommand),
                            TServerMessageCallback.Create(srKickPlayerReply, CSRClubCommand),
                            TServerMessageCallback.Create(srGetPlayers, CSRGetUsers),
                            TServerMessageCallback.Create(srLogout, CSRLogout),
                            TServerMessageCallback.Create(srEditGameOk, CSREGameOperation),
                            TServerMessageCallback.Create(srCreateGameOk, CSREGameOperation),
                            TServerMessageCallback.Create(srClubDisbandOk, CSREClubOperation),
                            TServerMessageCallback.Create(seSecondaryLoginDetected, CSESecondaryLoginDetected),
                            TServerMessageCallback.Create(seChat, CSEChatEvent),
                            TServerMessageCallback.Create(seAccountConfirmed, CSEAccountConfirmed),
                            TServerMessageCallback.Create(seClubChange, CSREClubOperation),
                            TServerMessageCallback.Create(srSuspendPlayerOk, CSREClubOperation),
                            TServerMessageCallback.Create(srReinstatePlayerOk, CSREClubOperation),
                            TServerMessageCallback.Create(srOwnershipGiveAwayOk, CSREClubOperation),
                            TServerMessageCallback.Create(srTransferChipsOk, CSRETransferChipsOk),
                            TServerMessageCallback.Create(seTransferChips, CSRETransferChipsOk),
                            TServerMessageCallback.Create(seClubDeleted, CSEClubDeleted),
                            TServerMessageCallback.Create(seGameChange, CSREGameOperation),
                            TServerMessageCallback.Create(seGameCreate, CSREGameOperation),
                            TServerMessageCallback.Create(seGameDelete, CSREGameDelete),
                            TServerMessageCallback.Create(srDeleteGameOk, CSREGameDelete),
                            TServerMessageCallback.Create(seTableStatus, CSRTableStatus),
                            TServerMessageCallback.Create(srTableStandUpOk, CSRTableStatus),
                            TServerMessageCallback.Create(srTableSitOk, CSRTableStatus)
                          ]
                        );

      mtSocketChangeState: SocketChangeState(msg.OldState, msg.NewState);
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmChipUpMain.DoLogout;
begin
  gridJoinedClubsTable.DataController.SetRecordCount(0);
  gridGamesTable.DataController.SetRecordCount(0);
  dmMain.SelfInfo.Flush;
  dmMain.Players.Clear;
  dmMain.Tables.ClearWithoutNotification;
end;

function TfrmChipUpMain.ShowLoginForm: Integer;
begin
  DoLogout;
  Hide;
  MessageContainer.RemoveMessageHandler(Handle);
  result := RunModalForm(TfrmLogin, self, []);
  if result = mrOk then
  begin
    MessageContainer.AddMessageHandler(Handle);
    FSelectedClub := -1;
    SetLength(FSelectedGame, 0);
    ConfigureGUI;
    Show;
  end
  else
  begin
    Close;
    Application.Terminate;
  end;
end;

procedure TfrmChipUpMain.SocketChangeState(const AOldState, ANewState: TSocketState);
begin
  case ANewState of
    wsClosed: begin
      SocketClient.Disconnect;
      ShowLoginForm;
    end;
  end;
end;

function TfrmChipUpMain.GetSelectedClub(var AClub: TClubInfo): Boolean;
begin
  result := dmMain.SelfInfo.Clubs.FindClub(FSelectedClub, AClub);
end;

function TfrmChipUpMain.GetSelectedGame(var AGame: TGameInfo): Boolean;
var
  club: TClubInfo;
begin
  result := (GetSelectedClub(club)) and (club.Games.FindGame(FSelectedGame, AGame));
end;

procedure TfrmChipUpMain.acLogoutExecute(Sender: TObject);
begin
  if not ConfirmToCloseTables then
    Exit;

  SocketClient.Logout;
end;

procedure TfrmChipUpMain.acOpenCashierExecute(Sender: TObject);
begin
  dmMain.OpenCashierLink;
end;

procedure TfrmChipUpMain.acOpenClubLobbyExecute(Sender: TObject);
var
  club: TClubInfo;
begin
  if not dmMain.SelfInfo.Clubs.FindClub(FSelectedClub, club) then
    Exit;

  RunForm(TfrmClubLobby, nil, [@FSelectedClub]);
end;

procedure TfrmChipUpMain.acShowChangeAvatarFormExecute(Sender: TObject);
begin
  RunModalForm(TfrmChangeAvatar, self, []);
end;

procedure TfrmChipUpMain.acShowChangeEMailFormExecute(Sender: TObject);
begin
  RunModalForm(TfrmChangeEMail, self, []);
end;

procedure TfrmChipUpMain.acShowChangePasswordFormExecute(Sender: TObject);
begin
  RunModalForm(TfrmChangePassword, self, []);
end;

procedure TfrmChipUpMain.acShowCreateClubFormExecute(Sender: TObject);
begin
  RunModalForm(TfrmCreateClub, self, []);
end;

procedure TfrmChipUpMain.acShowGameTableFormExecute(Sender: TObject);
var
  game: TGameInfo;
  club: TClubInfo;
begin
  if (not GetSelectedClub(club)) or (not GetSelectedGame(game)) then
    Exit;

  if club.IsSuspendedPlayer(dmMain.SelfInfo.Id) then
    MessageDlg('You are currently suspended in this club, and cannot join any tables. Please contact club owner to resolve this issue.', mtWarning, [mbOK], 0)
  else
    dmMain.Tables.AddTable(club, game);
end;

procedure TfrmChipUpMain.acShowJoinClubFormExecute(Sender: TObject);
begin
  RunModalForm(TfrmJoinClub, self, []);
end;

procedure TfrmChipUpMain.acShowPublicClubsListFormExecute(Sender: TObject);
begin
  RunModalForm(TfrmPublicClubsList, self, []);
end;

procedure TfrmChipUpMain.ConfigureGUI;
begin
  Caption := Format('ChipUP Poker - Logged in as %s', [dmMain.SelfInfo.Nick]);
  if not dmMain.SelfInfo.Authed then
    Caption := Caption + ' (account confirmation pending)';

  acOpenClubLobby.Enabled := FSelectedClub <> -1;
  UpdateClublist;
  UpdateGamelist;
end;

function TfrmChipUpMain.ConfirmToCloseTables: Boolean;
begin
  result := TRUE;
  if dmMain.Tables.SittingCount > 0 then
    result := MessageDlg('If you close the application, you will automatically leave the tables you are currently playing on. Proceed?', mtWarning, mbYesNo, 0) = mrYes;
end;

procedure TfrmChipUpMain.UpdateClublist;
var
  C1    : Integer;
  club  : TClubInfo;
  status: String;
begin
  gridJoinedClubsTable.DataController.BeginFullUpdate;
  try
    gridJoinedClubsTable.DataController.SetRecordCount(dmMain.SelfInfo.Clubs.Count);
    for C1 := 0 to dmMain.SelfInfo.Clubs.Count - 1 do
    begin
      club := dmMain.SelfInfo.Clubs[C1];

      gridJoinedClubsTable.DataController.SetValue(C1, gridJoinedClubsId.Index, club.Id);
      gridJoinedClubsTable.DataController.SetValue(C1, gridJoinedClubsClubName.Index, club.Name);

      if CompareBytes(dmMain.SelfInfo.Id, club.OwnerId) then
        status := 'Owner'
      else
        status := 'Player';
      gridJoinedClubsTable.DataController.SetValue(C1, gridJoinedClubsStatus.Index, status);
    end;
  finally
    gridJoinedClubsTable.DataController.EndFullUpdate;
  end;
end;

procedure TfrmChipUpMain.UpdateGamelist;
var
  C1  : Integer;
  game: TGameInfo;
  c   : TcxGridDataController;
  club: TClubInfo;
begin
  c := gridGamesTable.DataController;
  c.BeginFullUpdate;
  try
    if not GetSelectedClub(club) then
    begin
      c.SetRecordCount(0);
      Exit;
    end
    else
      c.SetRecordCount(club.Games.Count);

    for C1 := 0 to club.Games.Count - 1 do
    begin
      game := club.Games[C1];

      c.SetValue(C1, gridGamesId.Index, game.MongoId);
      c.SetValue(C1, gridGamesName.Index, game.Name);
      c.SetValue(C1, gridGamesType.Index, game.GameTypeStrFull);
      c.SetValue(C1, gridGamesBlinds.Index, Format('%d/%d', [Trunc(game.SmallBlind / 100), Trunc(game.BigBlind / 100)]));
      c.SetValue(C1, gridGamesPlayers.Index, Format('%d/%d', [game.Sitting, game.Seats]));
      c.SetValue(C1, gridGamesStatus.Index, 'unknown');
    end;
  finally
    c.EndFullUpdate;
  end;
end;

procedure TfrmChipUpMain.gridJoinedClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acOpenClubLobby.Execute;
end;

procedure TfrmChipUpMain.gridGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acShowGameTableForm.Execute;
end;

procedure TfrmChipUpMain.gridJoinedClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  club_id : Int64;
begin
  recIndex := gridJoinedClubsTable.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
  begin
    FSelectedClub := -1;
    Exit;
  end;

  club_id := gridJoinedClubsTable.DataController.GetValue(recIndex, gridJoinedClubsId.Index);
  if dmMain.SelfInfo.Clubs.IndexOf(club_id) = -1 then
    FSelectedClub := -1
  else
  begin
    FSelectedClub := club_id;
    SetLength(FSelectedGame, 0);
    gridGamesTable.DataController.FocusedRecordIndex := -1;
  end;

  acOpenClubLobby.Enabled := FSelectedClub <> -1;
  UpdateGamelist;
end;

procedure TfrmChipUpMain.gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  game_id : TBytes;
  club    : TClubInfo;
begin
  recIndex := gridGamesTable.DataController.GetFocusedRecordIndex;
  if (recIndex = -1) or
     (not GetSelectedClub(club)) then
  begin
    SetLength(FSelectedGame, 0);
    Exit;
  end;

  game_id := gridGamesTable.DataController.GetValue(recIndex, gridGamesId.Index);
  if club.Games.IndexOf(game_id) = -1 then
  begin
    SetLength(FSelectedGame, 0);
    Exit;
  end
  else
    FSelectedGame := game_id;
end;

procedure TfrmChipUpMain.CSESecondaryLoginDetected(const AMessage: TMessageItem);
begin
  ShowLoginForm;
end;

procedure TfrmChipUpMain.CSRStatus(const AMessage: TMessageItem);
var
  pbstatus: TPB_StatusReply;
begin
  pbstatus := AMessage.Object_ as TPB_StatusReply;
  dmMain.ProcessStatusProtobuf(pbstatus);
  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSRLogout(const AMessage: TMessageItem);
begin
  ShowLoginForm;
end;

procedure TfrmChipUpMain.CSEAccountConfirmed(const AMessage: TMessageItem);
begin
  dmMain.SelfInfo.Authed := TRUE;
  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSEChatEvent(const AMessage: TMessageItem);
var
  chatEvent: TPB_ChatEvent;
begin
  chatEvent := AMessage.Object_ as TPB_ChatEvent;
end;

procedure TfrmChipUpMain.CSEClubDeleted(const AMessage: TMessageItem);
var
  pbclub: TPB_Club;
  index : Integer;
begin
  pbclub := AMessage.Object_ as TPB_Club;

  index := dmMain.SelfInfo.Clubs.IndexOf(pbclub.Seq);
  if index = -1 then
    Exit;

  dmMain.SelfInfo.Clubs.Delete(index);

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSREGameDelete(const AMessage: TMessageItem);
var
  pbgame: TPB_Game;
  club  : TClubInfo;
  game  : TGameInfo;
begin
  pbgame := AMessage.Object_ as TPB_Game;

  if (dmMain.SelfInfo.Clubs.FindClub(pbgame.Clubseq, club)) and
     (club.Games.FindGame(pbgame.MongoId, game)) then
    club.Games.Remove(game);

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSREClubOperation(const AMessage: TMessageItem);
var
  pbclub: TPB_Club;
  club  : TClubInfo;
begin
  pbclub := AMessage.Object_ as TPB_Club;

  club := dmMain.SelfInfo.Clubs.AddClub(pbclub);

  if not club.IsPlayerInTheClub(dmMain.SelfInfo.Id) then
    dmMain.SelfInfo.Clubs.Remove(club);

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSREGameOperation(const AMessage: TMessageItem);
var
  pbgame: TPB_Game;
  club  : TClubInfo;
begin
  pbgame := AMessage.Object_ as TPB_Game;

  if dmMain.SelfInfo.Clubs.FindClub(pbgame.Clubseq, club) then
    club.Games.AddGame(pbgame);

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSRTableStatus(const AMessage: TMessageItem);
var
  pbtstatus: TPB_TableStatus;
  table    : TTable;
begin
  pbtstatus := AMessage.Object_ as TPB_TableStatus;

  if not dmMain.Tables.FindTable(pbtstatus.TableMongoId, table) then
    Exit;

  table.Game.UpdateFromTableStatus(pbtstatus);

  ConfigureGUI;
end;

procedure TfrmChipUpMain.imgCashierMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if IsPointInsideCircle(X, Y, imgCashier.Width div 2, imgCashier.Height div 2, 42) then
      LoadImageFromResource(imgCashier, 'CashierPressed');
  end;
end;

procedure TfrmChipUpMain.imgCashierMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    if IsPointInsideCircle(X, Y, imgCashier.Width div 2, imgCashier.Height div 2, 42) then
      dmMain.OpenCashierLink;
    LoadImageFromResource(imgCashier, 'CashierNormal');
  end;
end;

procedure TfrmChipUpMain.CSRLeaveClub(const AMessage: TMessageItem);
var
  pbreply: TPB_ClubCommandReply;
  index  : Integer;
begin
  pbreply := AMessage.Object_ as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: begin
      index := dmMain.SelfInfo.Clubs.IndexOf(pbreply.Club.Seq);
      if index <> -1 then
        dmMain.SelfInfo.Clubs.Delete(index);
      ConfigureGUI;
    end;
  end;
end;

procedure TfrmChipUpMain.CSRClubCommand(const AMessage: TMessageItem);
var
  pbreply    : TPB_ClubCommandReply;
  C1         : Integer;
  club       : TClubInfo;
  player     : TPlayerInfo;
  query_users: TArray<TBytes>;
  empty_array: TBytes;
begin
  pbreply := AMessage.Object_ as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: begin
      club := dmMain.SelfInfo.Clubs.AddClub(pbreply.Club);
      club.Games.UpdateFromProtobufObjects(pbreply.Games);

      SetLength(query_users, 0);
      for C1 := 0 to Length(pbreply.Club.Members) - 1 do
        if not dmMain.Players.FindPlayerById(pbreply.Club.Members[C1], player) then
        begin
          SetLength(query_users, Length(query_users) + 1);
          query_users[Length(query_users) - 1] := pbreply.Club.Members[C1];
        end;
      if Length(query_users) > 0 then
      begin
        SetLength(empty_array, 0);
        for C1 := 0 to Length(query_users) do
          dmMain.Players.AddPlayer(query_users[C1], 'Unknown', '', 0, empty_array);

        SocketClient.GetUserInfos(query_users);
      end;

      ConfigureGUI;
    end;
  end;
end;

procedure TfrmChipUpMain.CSRGetUsers(const AMessage: TMessageItem);
var
  pbreply: TPB_GetUserParams;
  user   : TPB_User;
begin
  pbreply := AMessage.Object_ as TPB_GetUserParams;

  for user in pbreply.Users do
    dmMain.Players.AddPlayer(user);
end;

procedure TfrmChipUpMain.CSRETransferChipsOk(const AMessage: TMessageItem);
var
  pbreply    : TPB_TransferChipsParams;
  player_info: TPlayerInfo;
  multiplier : Integer;
begin
  pbreply := AMessage.Object_ as TPB_TransferChipsParams;

  if AMessage.MethodId = Integer(seTransferChips) then
    multiplier := 1
  else
    multiplier := -1;

  dmMain.SelfInfo.Balance := dmMain.SelfInfo.Balance + pbreply.ChipAmount * multiplier;

  if dmMain.Players.FindPlayerById(dmMain.SelfInfo.Id, player_info) then
    player_info.Balance := player_info.Balance + pbreply.ChipAmount * multiplier;

  if dmMain.Players.FindPlayerById(pbreply.PlayerMongoId, player_info) then
    player_info.Balance := player_info.Balance - pbreply.ChipAmount * multiplier;
end;

procedure TfrmChipUpMain.acShowHomeGamesLayoutExecute(Sender: TObject);
begin
  btCreateClub.Show;
  btJoinClub.Show;
  btOpenTournamentLobby.Hide;
  gridTournaments.Hide;
  gridJoinedClubs.Show;
  gridGames.Show;
  btOpenClubLobby.Show;
end;

procedure TfrmChipUpMain.acShowTournamentLayoutExecute(Sender: TObject);
begin
  btCreateClub.Hide;
  btJoinClub.Hide;
  btOpenTournamentLobby.Show;
  gridTournaments.Show;
  gridJoinedClubs.Hide;
  gridGames.Hide;
  btOpenClubLobby.Hide;
end;



end.
