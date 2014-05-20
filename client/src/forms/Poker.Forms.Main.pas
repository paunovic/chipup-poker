unit Poker.Forms.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.ActnList, Vcl.StdCtrls, Vcl.Menus, Vcl.AppEvnts, dxSkinsCore, cxLookAndFeels, dxSkinsForm, cxGraphics, cxControls,
  cxLookAndFeelPainters, dxSkinscxPCPainter, cxCustomData, cxDataStorage, cxEdit, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxClasses, cxGridLevel, cxGrid, cxTextEdit, cxSpinEdit, cxContainer, cxLabel, cxButtons, OverbyteIcsWSocket, Poker.Objects.ClubInfo,
  cxMaskEdit, cxDropDownEdit, Poker.Forms.Login, Poker.Objects.GameInfo, cxBlobEdit, cxImage, Vcl.ActnMan, Vcl.ActnMenus,
  Vcl.PlatformDefaultStyleActnCtrls, cxStyles, cxFilter, cxData, Poker.Protobufs.Objects.Club,
  dxGDIPlusClasses, ChipUpPokerDarkSkin, cxPC, cxPCdxBarPopupMenu;

type
  TfrmChipUpMain = class(TForm)
    ActionManager: TActionManager;
    acLogout: TAction;
    acShowChangeEMailForm: TAction;
    acShowChangePasswordForm: TAction;
    acShowChangeAvatarForm: TAction;
    acShowCreateClubForm: TAction;
    acShowJoinClubForm: TAction;
    acShowGameTableForm: TAction;
    acOpenClubLobby: TAction;
    MainMenu: TMainMenu;
    Account1: TMenuItem;
    ChangeEmailAddress1: TMenuItem;
    ChangePassword1: TMenuItem;
    ChangeAvatar1: TMenuItem;
    N1: TMenuItem;
    Logout1: TMenuItem;
    acShowTournamentLayout: TAction;
    acShowHomeGamesLayout: TAction;
    imgCashier: TcxImage;
    acOpenCashier: TAction;
    imgHeader: TcxImage;
    paMain: TPanel;
    btTournaments: TcxButton;
    btHomeGames: TcxButton;
    Resendverificationmail1: TMenuItem;
    N2: TMenuItem;
    acResendVerificationMail: TAction;
    btFiller1: TcxButton;
    pcTabs: TcxPageControl;
    tsHomeGames: TcxTabSheet;
    tsTournaments: TcxTabSheet;
    gridPublicHomeGames: TcxGrid;
    gridPublicHomeGamesTable: TcxGridTableView;
    gridClubsId: TcxGridColumn;
    gridClubsName: TcxGridColumn;
    gridPublicHomeGamesLevel: TcxGridLevel;
    btMyHomeGames: TcxButton;
    btPublicHomeGames: TcxButton;
    gridGames: TcxGrid;
    gridGamesTable: TcxGridTableView;
    gridGamesId: TcxGridColumn;
    gridGamesName: TcxGridColumn;
    gridGamesType: TcxGridColumn;
    gridGamesBlinds: TcxGridColumn;
    gridGamesBuyinLimits: TcxGridColumn;
    gridGamesPlayers: TcxGridColumn;
    gridGamesStatus: TcxGridColumn;
    gridGamesLevel: TcxGridLevel;
    btOpenClubLobby: TcxButton;
    btOpenTable: TcxButton;
    btCreateClub: TcxButton;
    btJoinClub: TcxButton;
    btTournamentsHeader: TcxButton;
    lbsTournamentsComingSoon: TcxLabel;
    tiBringToFront: TTimer;
    Help1: TMenuItem;
    ContactUs1: TMenuItem;
    acShowContactUsForm: TAction;
    TermsofService1: TMenuItem;
    acTermsAndConditions: TAction;
    acShowAboutForm: TAction;
    N3: TMenuItem;
    AboutChipUPPoker1: TMenuItem;
    Options1: TMenuItem;
    miSounds: TMenuItem;
    acSoundsOnOff: TAction;
    gridMyHomeGames: TcxGrid;
    gridMyHomeGamesTable: TcxGridTableView;
    gridJoinedClubsId: TcxGridColumn;
    gridJoinedClubsClubName: TcxGridColumn;
    gridJoinedClubsStatus: TcxGridColumn;
    gridMyHomeGamesLevel: TcxGridLevel;
    Developer1: TMenuItem;
    Disconnect1: TMenuItem;
    N4: TMenuItem;
    miCheckOnFold: TMenuItem;
    acFoldChecks: TAction;
    Gameplay1: TMenuItem;
    procedure acLogoutExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acShowCreateClubFormExecute(Sender: TObject);
    procedure acShowJoinClubFormExecute(Sender: TObject);
    procedure gridMyHomeGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure acShowChangeEMailFormExecute(Sender: TObject);
    procedure acShowChangePasswordFormExecute(Sender: TObject);
    procedure acShowChangeAvatarFormExecute(Sender: TObject);
    procedure gridMyHomeGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure gridGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure acShowGameTableFormExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure acOpenClubLobbyExecute(Sender: TObject);
    procedure acShowHomeGamesLayoutExecute(Sender: TObject);
    procedure acShowTournamentLayoutExecute(Sender: TObject);
    procedure imgCashierMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure acOpenCashierExecute(Sender: TObject);
    procedure imgCashierMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure acResendVerificationMailExecute(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure gridPublicHomeGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure FormResize(Sender: TObject);
    procedure gridPublicHomeGamesEnter(Sender: TObject);
    procedure gridMyHomeGamesEnter(Sender: TObject);
    procedure gridPublicHomeGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure pcTabsChange(Sender: TObject);
    procedure tiBringToFrontTimer(Sender: TObject);
    procedure acShowContactUsFormExecute(Sender: TObject);
    procedure acTermsAndConditionsExecute(Sender: TObject);
    procedure acSoundsOnOffExecute(Sender: TObject);
    procedure Disconnect1Click(Sender: TObject);
    procedure acShowAboutFormExecute(Sender: TObject);
    procedure acFoldChecksExecute(Sender: TObject);
  private
    FSelectedClub: Integer;
    FSelectedGame: TBytes;
    FCallbacksId: Integer;

    procedure ModalFormClose(ASender: TObject);

    procedure ShowLoginForm;

    procedure DoLogout;
    procedure UpdateClublist;
    procedure UpdatePublicClublist;
    procedure UpdateGamelist;

    procedure ShowTournamentLayout(const AShow: Boolean);

    procedure CSRLeaveClub(const AMethodId: Integer; const AObject: TObject);
    procedure CSRClubCommand(const AMethodId: Integer; const AObject: TObject);
    procedure CSRStatus(const AMethodId: Integer; const AObject: TObject);
    procedure CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
    procedure CSRETransferChipsOk(const AMethodId: Integer; const AObject: TObject);

    procedure CSRLogout(const AMethodId: Integer; const AObject: TObject);
    procedure CSESecondaryLoginDetected(const AMethodId: Integer; const AObject: TObject);
    procedure CSEChatEvent(const AMethodId: Integer; const AObject: TObject);
    procedure CSEAccountConfirmed(const AMethodId: Integer; const AObject: TObject);
    procedure CSEClubDeleted(const AMethodId: Integer; const AObject: TObject);
    procedure CSREClubOperation(const AMethodId: Integer; const AObject: TObject);
    procedure CSREGameOperation(const AMethodId: Integer; const AObject: TObject);
    procedure CSREGameDelete(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableStatus(const AMethodId: Integer; const AObject: TObject);
    procedure CSEUserChange(const AMethodId: Integer; const AObject: TObject);
    procedure CSRTableStats(const AMethodId: Integer; const AObject: TObject);

    procedure AvatarChanged(Sender: TObject);

    function ConfirmToCloseTables: Boolean;
    function ProcessClubObject(const AClub: TPB_Club; const AMethodId: Integer): TClubInfo;

    procedure SocketStateChange(const AOldState, ANewState: TSocketState);

    procedure ConfigureGUI;

    function GetSelectedGame(var AGame: TGameInfo): Boolean;
    function GetSelectedClub(var AClub: TClubInfo): Boolean;
  protected
    procedure DoCreate; override;

  public
    procedure LoginStatus(const AValue: TLoginStatus);
  end;


var
  frmChipUpMain: TfrmChipUpMain;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  System.Generics.Collections, Poker.Protobufs.Objects.GameQuery, SynDBSQLite3,
  Poker.Server.Socket, Poker.Protobufs.Enum.ServerCodes, Poker.Common.Misc, Poker.DataModule, Poker.Forms.CreateClub, Poker.Forms.JoinClub,
  Poker.Server.MessageContainer, Poker.Objects.PlayerInfo, Poker.Forms.ChangeEMail, Poker.Forms.ChangePassword, Poker.Forms.ChangeAvatar,
  Poker.Protobufs.Objects.ClubCommandReply, Poker.Protobufs.Objects.User, Poker.Protobufs.Objects.StatusReply,
  Poker.Server.MessageCallbacks, Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.TableStatus, Poker.Protobufs.Objects.ListClubsReply,
  Poker.Table.Tables, Poker.Protobufs.Objects.GetUserParams, Poker.Common.FormsContainer, Poker.Protobufs.Objects.TransferChipsParams,
  Poker.Forms.Updater, Poker.Forms.ClubLobby, Poker.Protobufs.Objects.UserChangeParams, Poker.Database.Core, Poker.Settings,
  Poker.Protobufs.Objects.TableStatsReplies, Poker.Stats.Table, Poker.Protobufs.Objects.TableStatsReply,
  Poker.Forms.ContactUs, Poker.Forms.Reconnect, Poker.Avatars, Poker.Forms.About, Poker.Protobufs.Objects.ChatEvent,
  Poker.Forms.SystemTrayPopup;


procedure TfrmChipUpMain.Disconnect1Click(Sender: TObject);
begin
  ServerSocket.Disconnect;
end;

procedure TfrmChipUpMain.DoCreate;
begin
  inherited;

  ShowLoginForm;
end;

procedure TfrmChipUpMain.FormCreate(Sender: TObject);
begin
  LoadImageFromResource(imgCashier, 'CashierNormal');

  btHomeGames.Font.Name := 'Sintony Bold';
  btHomeGames.Font.Style := [];
  btHomeGames.Font.Size := 8;

  btJoinClub.Font.Assign(btHomeGames.Font);
  btTournaments.Font.Assign(btHomeGames.Font);
  btOpenClubLobby.Font.Assign(btHomeGames.Font);
  btCreateClub.Font.Assign(btHomeGames.Font);
  btJoinClub.Font.Assign(btHomeGames.Font);

  pcTabs.ActivePage := tsHomeGames;

  Avatars.OnAvatarChanged := AvatarChanged;

  EnableWindow(Handle, TRUE);
end;

procedure TfrmChipUpMain.FormDestroy(Sender: TObject);
begin
  FormsContainer.CloseAllForms;
  MessageContainer.RemoveCallbacks(FCallbacksId);
end;

procedure TfrmChipUpMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmChipUpMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmToCloseTables;
  if CanClose then
  begin
    ServerSocket.Logout;
    Tables.ClearWithoutNotification;
  end;
end;

procedure TfrmChipUpMain.FormDeactivate(Sender: TObject);
begin
  LoadImageFromResource(imgCashier, 'CashierNormal');
end;

procedure TfrmChipUpMain.FormResize(Sender: TObject);
begin
  btPublicHomeGames.Width := (tsHomeGames.Width - btPublicHomeGames.Left - 3 - 11) div 2; // 3 = middle gap, 11 = right border
  btMyHomeGames.Left := btPublicHomeGames.Left + btPublicHomeGames.Width + 3;
  btMyHomeGames.Width := btPublicHomeGames.Width;
  gridPublicHomeGames.Left := btPublicHomeGames.Left;
  gridPublicHomeGames.Width := btPublicHomeGames.Width;
  gridMyHomeGames.Left := btMyHomeGames.Left;
  gridMyHomeGames.Width := btMyHomeGames.Width;
  gridGames.Width := btMyHomeGames.Left + btMyHomeGames.Width - btPublicHomeGames.Left;
  btTournamentsHeader.Left := btPublicHomeGames.Left;
  btTournamentsHeader.Width := btPublicHomeGames.Width + 3 + btMyHomeGames.Width;
end;

procedure TfrmChipUpMain.DoLogout;
begin
  FormsContainer.CloseAllForms;
  gridMyHomeGamesTable.DataController.SetRecordCount(0);
  gridGamesTable.DataController.SetRecordCount(0);
  dmMain.SelfInfo.Flush;
  Players.Clear;
  TablesStats.Clear;
  Tables.ClearWithoutNotification;
end;

procedure TfrmChipUpMain.ShowLoginForm;
begin
  Application.ShowMainForm := FALSE;
  DoLogout;
  Hide;
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.RunForm(TfrmLogin, self, [], FALSE);
end;

procedure TfrmChipUpMain.ShowTournamentLayout(const AShow: Boolean);
begin
  btCreateClub.Visible := not AShow;
  btJoinClub.Visible := not AShow;
  gridMyHomeGames.Visible := not AShow;
  gridPublicHomeGames.Visible := not AShow;
  btMyHomeGames.Visible := not AShow;
  btOpenTable.Visible := not AShow;
  btPublicHomeGames.Visible := not AShow;
  gridGames.Visible := not AShow;
  btOpenClubLobby.Visible := not AShow;
end;

procedure TfrmChipUpMain.SocketStateChange(const AOldState, ANewState: TSocketState);
var
  reconnect_form: TfrmReconnect;
begin
  case ANewState of
    wsClosed: begin // handle disconnection here (try to reconnect)
      // first, check if reconnect form already exists, if it does, don't recreate it!
      if not FormsContainer.Contains(TfrmReconnect) then
      begin
        // save form states and disable them
        FormsContainer.SaveState;
        FormsContainer.DisableAll;

        // disable all tables
        Tables.DisableAll;

        // disable main form (its not in forms container)
        EnableWindow(Handle, FALSE);

        // open reconection form
        reconnect_form := FormsContainer.RunForm(TfrmReconnect, nil, [], FALSE) as TfrmReconnect;
        reconnect_form.SetCloseCallback(ModalFormClose);
      end;
    end;
  end;
end;

procedure TfrmChipUpMain.tiBringToFrontTimer(Sender: TObject);
var
  table: TTable;
begin
  if IsIconic(Handle) then
    ShowWindow(Handle, SW_RESTORE);
  Show;

  if Tables.Count > 0 then
    for table in Tables do
      table.BringToFront;

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

procedure TfrmChipUpMain.acFoldChecksExecute(Sender: TObject);
begin
  Settings.FoldChecks := not Settings.FoldChecks;
  miCheckOnFold.Checked := Settings.FoldChecks
end;

procedure TfrmChipUpMain.acLogoutExecute(Sender: TObject);
begin
  if not ConfirmToCloseTables then
    Exit;

  ServerSocket.Logout;
end;

procedure TfrmChipUpMain.acOpenCashierExecute(Sender: TObject);
begin
  dmMain.OpenCashierLink;
end;

procedure TfrmChipUpMain.acOpenClubLobbyExecute(Sender: TObject);
var
  club: TClubInfo;
  form: TForm;
  found: Boolean;
begin
  if not dmMain.CheckAuthed then
    Exit;

  if not dmMain.SelfInfo.Clubs.FindClub(FSelectedClub, club) then
    Exit;

  found := FALSE;
  for form in FormsContainer.Items do
    if (form is TfrmClubLobby) and
       ((form as TfrmClubLobby).ClubId = FSelectedClub) then
    begin
      form.SetFocus;
      found := TRUE;
      Break;
    end;

  if not found then
    FormsContainer.RunForm(TfrmClubLobby, self, [@FSelectedClub], TRUE);
end;

procedure TfrmChipUpMain.acResendVerificationMailExecute(Sender: TObject);
begin
  ServerSocket.ResendVerificationMail;
  MessageDlg(Format('Verification mail sent to %s. Please check your inbox.', [dmMain.SelfInfo.EMail]), mtInformation, [mbOK], 0);
end;

procedure TfrmChipUpMain.acShowAboutFormExecute(Sender: TObject);
begin
  FormsContainer.RunForm(TfrmAbout, self, [], FALSE);
end;

procedure TfrmChipUpMain.acShowChangeAvatarFormExecute(Sender: TObject);
begin
  FormsContainer.RunForm(TfrmChangeAvatar, self, [], FALSE);
end;

procedure TfrmChipUpMain.acShowChangeEMailFormExecute(Sender: TObject);
begin
  FormsContainer.RunForm(TfrmChangeEMail, self, [], FALSE);
end;

procedure TfrmChipUpMain.acShowChangePasswordFormExecute(Sender: TObject);
begin
  FormsContainer.RunForm(TfrmChangePassword, self, [], FALSE);
end;

procedure TfrmChipUpMain.acShowContactUsFormExecute(Sender: TObject);
begin
  FormsContainer.RunForm(TfrmContactUs, self, [], FALSE);
end;

procedure TfrmChipUpMain.acShowCreateClubFormExecute(Sender: TObject);
begin
  if not dmMain.CheckAuthed then
    Exit;

  FormsContainer.RunForm(TfrmCreateClub, self, [], FALSE);
end;

procedure TfrmChipUpMain.acShowGameTableFormExecute(Sender: TObject);
var
  game: TGameInfo;
  club: TClubInfo;
  table: TTable;
  member: TClubMemberInfo;
begin
  if not dmMain.CheckAuthed then
    Exit;

  if (not GetSelectedClub(club)) or (not GetSelectedGame(game)) then
    Exit;

  member := nil;
  if (club.IsPrivate) and (not club.GetMemberInfo(dmMain.SelfInfo.Id, member)) then
    Exit;

  if (Assigned(member)) and
     (member.Suspended) then
    MessageDlg('You are currently suspended in this club, and cannot join any tables. Please contact club owner to resolve this issue.', mtWarning, [mbOK], 0)
  else
    if Tables.FindTable(game.MongoId, table) then
      table.BringToFront
    else
      Tables.AddTable(club, game, FALSE, TRUE);
end;

procedure TfrmChipUpMain.acShowJoinClubFormExecute(Sender: TObject);
begin
  if not dmMain.CheckAuthed then
    Exit;

  FormsContainer.RunForm(TfrmJoinClub, self, [], FALSE);
end;

procedure TfrmChipUpMain.ConfigureGUI;
var
  cpt: String;
  club: TClubInfo;
begin
  cpt := Format('ChipUP Poker - %s', [dmMain.SelfInfo.Nick]);
  if not dmMain.SelfInfo.Authed then
    cpt := cpt + ' (account verification pending)';
  if cpt <> Caption then
    Caption := cpt;

  Resendverificationmail1.Visible := not dmMain.SelfInfo.Authed;

  acOpenClubLobby.Enabled := (dmMain.SelfInfo.Clubs.FindClub(FSelectedClub, club)) and
                             (CompareBytes(club.OwnerId, dmMain.SelfInfo.Id));

  miSounds.Checked := Settings.Sounds;
  miCheckOnFold.Checked := Settings.FoldChecks;

  Developer1.Visible := Settings.DeveloperMode;

  UpdateClublist;
  UpdateGamelist;
  UpdatePublicClublist;
end;

function TfrmChipUpMain.ConfirmToCloseTables: Boolean;
begin
  result := TRUE;
  if Tables.SittingCount > 0 then
    result := MessageDlg('If you close the application, you will automatically leave the tables you are currently playing on. Proceed?', mtWarning, mbYesNo, 0) = mrYes;
end;

procedure TfrmChipUpMain.UpdateClublist;
var
  club: TClubInfo;
  status: String;
  recidx: Integer;
  member: TClubMemberInfo;
begin
  gridMyHomeGamesTable.DataController.BeginFullUpdate;
  try
    gridMyHomeGamesTable.DataController.SetRecordCount(0);
    for club in dmMain.SelfInfo.Clubs do
      if club.IsPrivate then
      begin
        recidx := gridMyHomeGamesTable.DataController.AppendRecord;

        gridMyHomeGamesTable.DataController.SetValue(recidx, gridJoinedClubsId.Index, club.Id);
        gridMyHomeGamesTable.DataController.SetValue(recidx, gridJoinedClubsClubName.Index, club.Name);

        if CompareBytes(dmMain.SelfInfo.Id, club.OwnerId) then
          status := 'Manager'
        else
          if club.GetMemberInfo(dmMain.SelfInfo.id, member) then
          begin
            if member.Suspended then
              status := 'Suspended'
            else
              status := 'Member';
          end
          else
            status := 'Unknown';
        gridMyHomeGamesTable.DataController.SetValue(recidx, gridJoinedClubsStatus.Index, status);
      end;
  finally
    gridMyHomeGamesTable.DataController.EndFullUpdate;
  end;
  gridMyHomeGamesTable.DataController.Refresh;
end;

procedure TfrmChipUpMain.UpdateGamelist;
var
  C1: Integer;
  game: TGameInfo;
  c: TcxGridDataController;
  club: TClubInfo;
  recidx: Integer;
begin
  c := gridGamesTable.DataController;
  c.BeginFullUpdate;
  try
    c.SetRecordCount(0);
    if not GetSelectedClub(club) then
      Exit;

    for C1 := 0 to club.Games.Count - 1 do
    begin
      game := club.Games[C1];

      if game.State = gsClosed then
        Continue;

      recidx := c.AppendRecord;

      c.SetValue(recidx, gridGamesId.Index, game.MongoId);
      c.SetValue(recidx, gridGamesName.Index, game.Name);
      c.SetValue(recidx, gridGamesType.Index, game.GameTypeStrFull);
      c.SetValue(recidx, gridGamesBlinds.Index, Format('%d/%d', [Trunc(game.SmallBlind / 100), Trunc(game.BigBlind / 100)]));
      c.SetValue(recidx, gridGamesBuyinLimits.Index, Format('%d-%d', [game.MinBuyin, game.MaxBuyin]));
      c.SetValue(recidx, gridGamesPlayers.Index, Format('%d/%d', [game.Sitting, game.Seats]));
      c.SetValue(recidx, gridGamesStatus.Index, game.StateAsStr);
    end;
  finally
    c.EndFullUpdate;
  end;
  c.Refresh;
end;

procedure TfrmChipUpMain.UpdatePublicClublist;
var
  rcount: Integer;
  club: TClubInfo;
  c: TcxGridDataController;
begin
  c := gridPublicHomeGamesTable.DataController;

  c.BeginFullUpdate;
  try
    rcount := 0;
    c.SetRecordCount(0);

    for club in dmMain.SelfInfo.Clubs do
      if not club.IsPrivate then
      begin
        Inc(rcount);
        c.SetRecordCount(rcount);
        c.SetValue(rcount - 1, gridClubsId.Index, club.Id);
        c.SetValue(rcount - 1, gridClubsName.Index, club.Name);
      end;
  finally
    c.EndFullUpdate;
  end;
  c.Refresh;
end;

procedure TfrmChipUpMain.gridMyHomeGamesEnter(Sender: TObject);
begin
  gridPublicHomeGamesTable.DataController.FocusedRecordIndex := -1;
end;

procedure TfrmChipUpMain.gridPublicHomeGamesEnter(Sender: TObject);
begin
  gridMyHomeGamesTable.DataController.FocusedRecordIndex := -1;
end;

procedure TfrmChipUpMain.gridMyHomeGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acOpenClubLobby.Execute;
end;

procedure TfrmChipUpMain.gridPublicHomeGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acOpenClubLobby.Execute;
end;

procedure TfrmChipUpMain.gridPublicHomeGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  club_id: Integer;
  club: TclubInfo;
begin
  recIndex := gridPublicHomeGamesTable.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
    FSelectedClub := -1
  else
  begin
    club_id := gridPublicHomeGamesTable.DataController.GetValue(recIndex, gridClubsId.Index);
    if dmMain.SelfInfo.Clubs.IndexOf(club_id) = -1 then
      FSelectedClub := -1
    else
    begin
      FSelectedClub := club_id;
      SetLength(FSelectedGame, 0);
      gridGamesTable.DataController.FocusedRecordIndex := -1;
    end;
  end;

  acOpenClubLobby.Enabled := (dmMain.SelfInfo.Clubs.FindClub(FSelectedClub, club)) and
                             (CompareBytes(club.OwnerId, dmMain.SelfInfo.Id));

  UpdateGamelist;
end;

procedure TfrmChipUpMain.gridGamesTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acShowGameTableForm.Execute;
end;

procedure TfrmChipUpMain.gridMyHomeGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  club_id: Int64;
  club: TClubInfo;
begin
  recIndex := gridMyHomeGamesTable.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
    FSelectedClub := -1
  else
  begin
    club_id := gridMyHomeGamesTable.DataController.GetValue(recIndex, gridJoinedClubsId.Index);
    if dmMain.SelfInfo.Clubs.IndexOf(club_id) = -1 then
      FSelectedClub := -1
    else
    begin
      FSelectedClub := club_id;
      SetLength(FSelectedGame, 0);
      gridGamesTable.DataController.FocusedRecordIndex := -1;
    end;
  end;

  acOpenClubLobby.Enabled := dmMain.SelfInfo.Clubs.FindClub(FSelectedClub, club);

  UpdateGamelist;
end;

procedure TfrmChipUpMain.gridGamesTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  game_id: TBytes;
  club: TClubInfo;
begin
  recIndex := gridGamesTable.DataController.GetFocusedRecordIndex;
  if (recIndex = -1) or
     (not GetSelectedClub(club)) then
    SetLength(FSelectedGame, 0)
  else
  begin
    game_id := gridGamesTable.DataController.GetValue(recIndex, gridGamesId.Index);
    if club.Games.IndexOf(game_id) = -1 then
      SetLength(FSelectedGame, 0)
    else
      FSelectedGame := game_id;
  end;

  acShowGameTableForm.Enabled := Length(FSelectedGame) > 0;
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

procedure TfrmChipUpMain.LoginStatus(const AValue: TLoginStatus);
begin
  case AValue of
    lsLoggedIn: begin
      FCallbacksId := MessageContainer.AddCallbacks([
                          TSocketStateChangeCallback.Create(SocketStateChange),
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
                          TServerMessageCallback.Create(seTableStatus, CSRTableStatus),
                          TServerMessageCallback.Create(srTableStandUpOk, CSRTableStatus),
                          TServerMessageCallback.Create(srTableSitOk, CSRTableStatus),
                          TServerMessageCallback.Create(seUserChange, CSEUserChange),
                          TServerMessageCallback.Create(srTableStatsReply, CSRTableStats)
                      ]);

      FSelectedClub := -1;
      SetLength(FSelectedGame, 0);
      ConfigureGUI;
      Show;
      tiBringToFront.Enabled := TRUE;
    end;

    lsUpdating: FormsContainer.RunForm(TfrmUpdater, self, [], FALSE);
  else
    Close;
  end;
end;

procedure TfrmChipUpMain.ModalFormClose(ASender: TObject);
begin
  if ASender is TfrmReconnect then
  begin
    case (ASender as TfrmReconnect).CurrentStatus of
      rsLoggedIn: ;
    else
      FormsContainer.Items.Extract(ASender as TForm);
      ShowLoginForm;
    end;
  end;

  EnableWindow(Handle, TRUE);
end;

procedure TfrmChipUpMain.pcTabsChange(Sender: TObject);
begin
  if pcTabs.ActivePage = tsHomeGames then
    ShowTournamentLayout(FALSE);
  if pcTabs.ActivePage = tsTournaments then
    ShowTournamentLayout(TRUE);
end;

procedure TfrmChipUpMain.CSRLeaveClub(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AObject as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: begin
      ProcessClubObject(pbreply.Club, AMethodId);
      ConfigureGUI;
    end;
  end;
end;

function TfrmChipUpMain.ProcessClubObject(const AClub: TPB_Club; const AMethodId: Integer): TClubInfo;
var
  C1: Integer;
  club: TClubInfo;
  player: TPlayerInfo;
  query_users: TArray<TBytes>;
  empty_array: TBytes;
  member: TClubMemberInfo;
begin
  if AMethodId <> Integer(srClubDisbandOk) then
  begin
    club := dmMain.SelfInfo.Clubs.AddClub(AClub);
    SetLength(query_users, 0);
    if not Players.FindPlayerById(AClub.Owner, player) then
    begin
      SetLength(query_users, 1);
      query_users[0] := AClub.Owner;
    end;
    for C1 := 0 to AClub.Members.Count - 1 do
      if not Players.FindPlayerById(AClub.Members[C1].MongoId, player) then
      begin
        SetLength(query_users, Length(query_users) + 1);
        query_users[Length(query_users) - 1] := AClub.Members[C1].MongoId;
      end;
    if Length(query_users) > 0 then
    begin
      SetLength(empty_array, 0);
      for C1 := 0 to Length(query_users) - 1 do
        Players.AddPlayer(query_users[C1], 'Retrieving...', '', 0, empty_array);

      ServerSocket.GetUserInfos(query_users);
    end;

    // we got kicked.. or club got deleted
    if (not club.GetMemberInfo(dmMain.SelfInfo.Id, member)) and
       (club.IsPrivate) then
    begin
      Tables.CloseTablesForClub(club.MongoId);
      dmMain.SelfInfo.Clubs.Remove(club);
      club := nil;
    end;
  end
  else
  begin
    Tables.CloseTablesForClub(AClub.MongoId);
    if dmMain.SelfInfo.Clubs.FindClub(AClub.Seq, club) then
      dmMain.SelfInfo.Clubs.Remove(club);
  end;

  result := club;
end;

procedure TfrmChipUpMain.CSRClubCommand(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
  club: TClubInfo;
begin
  pbreply := AObject as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: begin
      club := ProcessClubObject(pbreply.Club, AMethodId);

      if (AMethodId in [Integer(srJoinClubReply), Integer(srChangeClubDetailsReply)]) and
         (Assigned(club)) then
        club.Games.UpdateFromProtobufObjects(pbreply.Games);

      Tables.ReassignObjects;
      ConfigureGUI;
    end;
  end;
end;

procedure TfrmChipUpMain.CSREClubOperation(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
begin
  pbclub := AObject as TPB_Club;

  ProcessClubObject(pbclub, AMethodId);

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_GetUserParams;
  user: TPB_User;
begin
  pbreply := AObject as TPB_GetUserParams;

  for user in pbreply.Users do
    Players.AddPlayer(user);
end;

procedure TfrmChipUpMain.CSRETransferChipsOk(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_TransferChipsParams;
  player_info: TPlayerInfo;
begin
  pbreply := AObject as TPB_TransferChipsParams;

  if AMethodId = Integer(seTransferChips) then
  begin
    dmMain.SelfInfo.Balance := dmMain.SelfInfo.Balance + pbreply.ChipAmount;
    if Players.FindPlayerById(pbreply.PlayerMongoId, player_info) then
      player_info.Balance := player_info.Balance - pbreply.ChipAmount;
  end
  else
  begin
    dmMain.SelfInfo.Balance := dmMain.SelfInfo.Balance - pbreply.ChipAmount;
    if Players.FindPlayerById(pbreply.PlayerMongoId, player_info) then
      player_info.Balance := player_info.Balance + pbreply.ChipAmount;
  end;
  dmMain.UpdateSelfInfoInPlayers;
end;

procedure TfrmChipUpMain.acShowHomeGamesLayoutExecute(Sender: TObject);
begin
  pcTabs.ActivePage := tsHomeGames;
end;

procedure TfrmChipUpMain.acShowTournamentLayoutExecute(Sender: TObject);
begin
  pcTabs.ActivePage := tsTournaments;
end;

procedure TfrmChipUpMain.acSoundsOnOffExecute(Sender: TObject);
begin
  Settings.Sounds := not Settings.Sounds;
  miSounds.Checked := Settings.Sounds;
end;

procedure TfrmChipUpMain.acTermsAndConditionsExecute(Sender: TObject);
begin
  dmMain.OpenTACLink;
end;

procedure TfrmChipUpMain.AvatarChanged(Sender: TObject);
var
  table: TTable;
begin
  for table in Tables do
    table.UpdateAvatars(Sender as TAvatar);
end;

procedure TfrmChipUpMain.CSESecondaryLoginDetected(const AMethodId: Integer; const AObject: TObject);
begin
  ShowLoginForm;
end;

procedure TfrmChipUpMain.CSEUserChange(const AMethodId: Integer; const AObject: TObject);
var
  pbusers: TPB_UserChangeParams;
  pbuser: TPB_user;
begin
  pbusers := AObject as TPB_UserChangeParams;

  for pbuser in pbusers.Users do
    Players.AddPlayer(pbuser);
end;

procedure TfrmChipUpMain.CSRStatus(const AMethodId: Integer; const AObject: TObject);
var
  pbstatus: TPB_StatusReply;
begin
  pbstatus := AObject as TPB_StatusReply;
  dmMain.ProcessStatusProtobuf(pbstatus);
  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSRLogout(const AMethodId: Integer; const AObject: TObject);
begin
  ShowLoginForm;
end;

procedure TfrmChipUpMain.CSEAccountConfirmed(const AMethodId: Integer; const AObject: TObject);
var
  pbuser: TPB_User;
begin
  pbuser := AObject as TPB_User;

  dmMain.SelfInfo.Id := pbuser.MongoId;
  dmMain.SelfInfo.Balance := pbuser.Chips;
  dmMain.SelfInfo.EMail := pbuser.Email;
  dmMain.SelfInfo.Nick := pbuser.Displayname;
  dmMain.SelfInfo.AvatarId := pbuser.Avatar;
  dmMain.SelfInfo.Authed := pbuser.Authed;

  dmMain.UpdateSelfInfoInPlayers;

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSEChatEvent(const AMethodId: Integer; const AObject: TObject);
var
  chatEvent: TPB_ChatEvent;
begin
  chatEvent := AObject as TPB_ChatEvent;
  if chatEvent.Event = ceServerMessage then
    TfrmSystemTrayPopup.ShowPopup(chatEvent.Msg.Msg);
end;

procedure TfrmChipUpMain.CSEClubDeleted(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
  index : Integer;
begin
  pbclub := AObject as TPB_Club;

  Tables.CloseTablesForClub(pbclub.MongoId);
  index := dmMain.SelfInfo.Clubs.IndexOf(pbclub.Seq);
  if index <> -1 then
    dmMain.SelfInfo.Clubs.Delete(index);

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSREGameDelete(const AMethodId: Integer; const AObject: TObject);
var
  pbgame: TPB_Game;
  club: TClubInfo;
  game: TGameInfo;
  C1: Integer;
begin
  pbgame := AObject as TPB_Game;

  if (dmMain.SelfInfo.Clubs.FindClub(pbgame.Clubseq, club)) and
     (club.Games.FindGame(pbgame.MongoId, game)) then
  begin
    for C1 := 0 to Tables.Count - 1 do
      if Tables[C1].Game = game then
      begin
        Tables.Delete(C1);
        Break;
      end;

    club.Games.AddGame(pbgame);
  end;

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSREGameOperation(const AMethodId: Integer; const AObject: TObject);
var
  pbgame: TPB_Game;
  club: TClubInfo;
  game: TGameInfo;
begin
  pbgame := AObject as TPB_Game;

  if dmMain.SelfInfo.Clubs.FindClub(pbgame.Clubseq, club) then
  begin
    game := club.Games.AddGame(pbgame);

    if (Assigned(game)) and
       (AMethodId = Integer(srCreateGameOk)) then
      Tables.AddTable(club, game, FALSE, TRUE);
  end;

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSRTableStatus(const AMethodId: Integer; const AObject: TObject);
var
  pbtstatus: TPB_TableStatus;
  table: TTable;
begin
  pbtstatus := AObject as TPB_TableStatus;
  if not Tables.FindTable(pbtstatus.TableMongoId, table) then
    Exit;

  table.Game.UpdateFromTableStatus(pbtstatus);
  if not table.Form.Visible then
    table.BringToFront;

  ConfigureGUI;
end;

procedure TfrmChipUpMain.CSRTableStats(const AMethodId: Integer; const AObject: TObject);
var
  pb: TPB_TableStatsReplies;
  tablepb: TPB_TableStatsReply;
  tablestats: TTableStats;
  player: TPB_User;
  playerinfo: TPlayerInfo;
  club: TClubInfo;
begin
  pb := AObject as TPB_TableStatsReplies;

  for player in pb.Players do
    if Players.FindPlayerById(player.MongoId, playerinfo) then
      playerinfo.Nick := player.Displayname
    else
      Players.AddPlayer(player);

  for tablepb in pb.Reply do
  begin
    if TablesStats.Find(tablepb.Gameid, tablestats) then
      tablestats.Assign(tablepb)
    else
    begin
      tablestats := TTableStats.Create;
      tablestats.Assign(tablepb);
      TablesStats.Add(tablestats);
    end;

    if dmMain.SelfInfo.Clubs.FindClub(tablepb.Clubid, club) then
      club.UpdateFromTableStats(tablepb.Playerstats);
  end;
end;


end.
