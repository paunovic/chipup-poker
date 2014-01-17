unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ActnList, Vcl.StdCtrls, Vcl.Menus, Vcl.AppEvnts, dxSkinsCore,
  cxLookAndFeels, dxSkinsForm, cxGraphics, cxControls, cxLookAndFeelPainters, cxStyles, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxClasses,
  cxGridLevel, cxGrid, cxTextEdit, cxSpinEdit, cxContainer, cxLabel, cxButtons, OverbyteIcsWSocket, uClubInfo, cxMaskEdit, cxDropDownEdit,
  uMessageItem, dxSkinDarkRoom, uGameInfo, cxBlobEdit;

type
  TfrmChipUpMain = class(TForm)
    alMainForm: TActionList;
    acLogout: TAction;
    MainMenu: TMainMenu;
    mmiAccount: TMenuItem;
    mmiClubs: TMenuItem;
    mmiOptions: TMenuItem;
    mmiLogout: TMenuItem;
    tiBringToFront: TTimer;
    gridJoinedClubsLevel: TcxGridLevel;
    gridJoinedClubs: TcxGrid;
    gridJoinedClubsTable: TcxGridTableView;
    gridJoinedClubsClubName: TcxGridColumn;
    mmiCreateClub: TMenuItem;
    acShowCreateClubForm: TAction;
    gridJoinedClubsId: TcxGridColumn;
    mmiJoinClub: TMenuItem;
    acShowJoinClubForm: TAction;
    acShowManageClubsForm: TAction;
    mmiSeparator3: TMenuItem;
    Manageclubs1: TMenuItem;
    SkinController: TdxSkinController;
    lbUserInfo: TcxLabel;
    mmiSeparator1: TMenuItem;
    mmiBuyTokens: TMenuItem;
    mmiChangeEMail: TMenuItem;
    mmiChangePassword: TMenuItem;
    mmiChangeAvatar: TMenuItem;
    acBuyTokens: TAction;
    mmiBuyChips: TMenuItem;
    acBuyChips: TAction;
    acShowChangeEMailForm: TAction;
    acShowChangePasswordForm: TAction;
    acShowChangeAvatarForm: TAction;
    mmiCashier: TMenuItem;
    gridJoinedClubsStatus: TcxGridColumn;
    btCreateClub: TcxButton;
    btJoinClub: TcxButton;
    gridGames: TcxGrid;
    gridGamesTable: TcxGridTableView;
    gridGamesId: TcxGridColumn;
    gridGamesName: TcxGridColumn;
    gridGamesType: TcxGridColumn;
    gridGamesLevel: TcxGridLevel;
    gridGamesBlinds: TcxGridColumn;
    gridGamesPlayers: TcxGridColumn;
    gridGamesStatus: TcxGridColumn;
    SearchPublicClubs1: TMenuItem;
    acShowPublicGamesListForm: TAction;
    btClubLobby: TcxButton;
    cxLabel1: TcxLabel;
    acShowGameTableForm: TAction;
    procedure acLogoutExecute(Sender: TObject);
    procedure tiBringToFrontTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acShowCreateClubFormExecute(Sender: TObject);
    procedure acShowJoinClubFormExecute(Sender: TObject);
    procedure btLeaveClubClick(Sender: TObject);
    procedure gridJoinedClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure acShowManageClubsFormExecute(Sender: TObject);
    procedure acBuyTokensExecute(Sender: TObject);
    procedure acBuyChipsExecute(Sender: TObject);
    procedure acShowChangeEMailFormExecute(Sender: TObject);
    procedure acShowChangePasswordFormExecute(Sender: TObject);
    procedure acShowChangeAvatarFormExecute(Sender: TObject);
    procedure gridJoinedClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure acShowPublicGamesListFormExecute(Sender: TObject);
    procedure gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure gridGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure acShowGameTableFormExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FSelectedClub: Integer;
    FSelectedGame: TBytes;

    function ShowLoginForm: Integer;

    procedure DoLogout;
    procedure UpdateClublist;
    procedure UpdateGamelist;

    procedure TCStatusReply(const AMessage: TMessageItem);
    procedure TCLeaveClubOk(const AMessage: TMessageItem);
    procedure TCLeaveClubInvalidId(const AMessage: TMessageItem);
    procedure TCLogout(const AMessage: TMessageItem);
    procedure TCSecondaryLoginDetected(const AMessage: TMessageItem);
    procedure TCChatEvent(const AMessage: TMessageItem);
    procedure TCAccountConfirmed(const AMessage: TMessageItem);

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
  uPlayerInfo, uManageClubsForm, uChangeEMailForm, uChangePasswordForm, uChangeAvatarForm, uAvatar, uPublicClubsList,
  uPB_StatusReply, uMessageContainer, uServerMessageCallback,
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uPB_ChatEvent, uPB_ChatMessage;


procedure TfrmChipUpMain.DoCreate;
begin
  inherited;

  ShowLoginForm;
end;

procedure TfrmChipUpMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if dmMain.Tables.SittingCount > 0 then
    CanClose := MessageDlg('If you close the application, you will automatically leave the tables you are currently playing on. Proceed?', mtWarning, mbYesNo, 0) = mrYes;
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
                            TServerMessageCallback.Create(SR_STATUS, TCStatusReply),
                            TServerMessageCallback.Create(SR_LOGOUT, TCLogout),
                            TServerMessageCallback.Create(SR_LEAVECLUB_OK, TCLeaveClubOk),
                            TServerMessageCallback.Create(SR_LEAVECLUB_INVALID_ID, TCLeaveClubInvalidId),
                            TServerMessageCallback.Create(SR_SECONDARY_LOGIN_DETECTED, TCSecondaryLoginDetected),
                            TServerMessageCallback.Create(EVENT_CHAT, TCChatEvent),
                            TServerMessageCallback.Create(SR_ACCOUNT_CONFIRMED, TCAccountConfirmed)
                          ]
                        );

      mtSocketChangeState: SocketChangeState(msg.OldState, msg.NewState);
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmChipUpMain.DoLogout;
begin
  lbUserInfo.Caption := '';
  gridJoinedClubsTable.DataController.SetRecordCount(0);
  gridGamesTable.DataController.SetRecordCount(0);
  dmMain.SelfInfo.Flush;
  dmMain.Players.Clear;
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
    ConfigureGUI;
    UpdateClublist;
    Show;
    tiBringToFront.Enabled := TRUE;
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

procedure TfrmChipUpMain.tiBringToFrontTimer(Sender: TObject);
begin
  BringToFront;
  tiBringToFront.Enabled := FALSE;
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


procedure TfrmChipUpMain.acBuyChipsExecute(Sender: TObject);
begin
  dmMain.OpenBuyChipsLink;
end;

procedure TfrmChipUpMain.acBuyTokensExecute(Sender: TObject);
begin
  dmMain.OpenBuyTokensLink;
end;

procedure TfrmChipUpMain.acLogoutExecute(Sender: TObject);
begin
  SocketClient.Logout;
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
  if RunModalForM(TfrmCreateClub, self, []) = mrOk then
    SocketClient.Status;
end;

procedure TfrmChipUpMain.acShowGameTableFormExecute(Sender: TObject);
var
  game: TGameInfo;
  club: TClubInfo;
begin
  if (not GetSelectedClub(club)) or (not GetSelectedGame(game)) then
    Exit;

  dmMain.Tables.AddTable(club, game);
end;

procedure TfrmChipUpMain.acShowJoinClubFormExecute(Sender: TObject);
begin
  if RunModalForm(TfrmJoinClub, self, []) = mrOk then
    SocketClient.Status;
end;

procedure TfrmChipUpMain.acShowManageClubsFormExecute(Sender: TObject);
begin
  if RunModalForm(TfrmManageClubs, self, []) = mrOk then
    SocketClient.Status;
end;

procedure TfrmChipUpMain.acShowPublicGamesListFormExecute(Sender: TObject);
begin
  if RunModalForm(TfrmPublicClubsList, self, []) = mrOk then
    SocketClient.Status;
end;

procedure TfrmChipUpMain.btLeaveClubClick(Sender: TObject);
var
  club: TClubInfo;
begin
  if not GetSelectedClub(club) then
    Exit;

  SocketClient.LeaveClub(club.Id);
end;

procedure TfrmChipUpMain.ConfigureGUI;
begin
  lbUserInfo.Caption := Format('You have %d tokens', [dmMain.SelfInfo.Tokens]);

  Caption := Format('ChipUP Poker - Logged in as %s', [dmMain.SelfInfo.Nick]);
  if not dmMain.SelfInfo.Authed then
    Caption := Caption + ' (account confirmation pending)';
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

      if dmMain.SelfInfo.Id = club.OwnerId then
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
      c.SetValue(C1, gridGamesBlinds.Index, Format('%d/%d', [game.SmallBlind, game.BigBlind]));
      c.SetValue(C1, gridGamesPlayers.Index, Format('%d/%d', [0, game.Seats]));
      c.SetValue(C1, gridGamesStatus.Index, 'unknown');
    end;
  finally
    c.EndFullUpdate;
  end;
end;

procedure TfrmChipUpMain.gridJoinedClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acShowManageClubsForm.Execute;
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
    FSelectedClub := club_id;

  UpdateGamelist;
end;

procedure TfrmChipUpMain.gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  game_id : TBytes;
  g       : AnsiString;
  C1      : Integer;
  club    : TClubInfo;
  bytes   : TBytes;
begin
  recIndex := gridGamesTable.DataController.GetFocusedRecordIndex;
  if (recIndex = -1) or
     (not GetSelectedClub(club)) then
  begin
    SetLength(FSelectedGame, 0);
    Exit;
  end;

//  game_id := gridGamesTable.DataController.GetValue(recIndex, gridGamesId.Index);
  g := gridGamesTable.DataController.GetValue(recIndex, gridGamesId.Index);
  SetLength(bytes, Length(g));
  for C1 := 1 to length(g) do
    bytes[C1] := Ord(g[C1]);

  if club.Games.IndexOf(game_id) = -1 then
  begin
    SetLength(FSelectedGame, 0);
    Exit;
  end
  else
    FSelectedGame := game_id;
end;

procedure TfrmChipUpMain.TCSecondaryLoginDetected(const AMessage: TMessageItem);
begin
  ShowLoginForm;
end;

procedure TfrmChipUpMain.TCStatusReply(const AMessage: TMessageItem);
var
  pbstatus: TPB_StatusReply;
begin
  pbstatus := AMessage.Object_ as TPB_StatusReply;

  dmMain.SelfInfo.ParseStatus(pbstatus);
  dmMain.Avatars.Add(dmMain.SelfInfo.AvatarId);
  dmMain.Players.ParseStatus(pbstatus);
  ConfigureGUI;
  UpdateClublist;
  UpdateGamelist;
end;

procedure TfrmChipUpMain.TCLeaveClubInvalidId(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid club ID', mtError, [mbOK], 0);
end;

procedure TfrmChipUpMain.TCLeaveClubOk(const AMessage: TMessageItem);
begin
  MessageDlg('Successfully left the club', mtInformation, [mbOK], 0);
  SocketClient.Status;
end;

procedure TfrmChipUpMain.TCLogout(const AMessage: TMessageItem);
begin
  ShowLoginForm;
end;

procedure TfrmChipUpMain.TCAccountConfirmed(const AMessage: TMessageItem);
begin
  dmMain.SelfInfo.Authed := TRUE;
  ConfigureGUI;
end;

procedure TfrmChipUpMain.TCChatEvent(const AMessage: TMessageItem);
var
  chatEvent: TPB_ChatEvent;
begin
  chatEvent := AMessage.Object_ as TPB_ChatEvent;
end;




end.
