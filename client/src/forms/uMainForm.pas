unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ActnList, Vcl.StdCtrls, Vcl.Menus, Vcl.AppEvnts, dxSkinsCore,
  dxSkinDevExpressStyle, cxLookAndFeels, dxSkinsForm, cxGraphics, cxControls, cxLookAndFeelPainters, cxStyles, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxClasses,
  cxGridLevel, cxGrid, cxTextEdit, cxSpinEdit, cxContainer, cxLabel, cxButtons, OverbyteIcsWSocket, uClubInfo, cxMaskEdit, cxDropDownEdit,
  uMessageItem, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinDevExpressDarkStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky,
  dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinPumpkin,
  dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TfrmMain = class(TForm)
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
    btLeaveClub: TcxButton;
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
    btOpenTable: TButton;
    mmiCashier: TMenuItem;
    gridJoinedClubsStatus: TcxGridColumn;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    cxButton3: TcxButton;
    cxGrid1: TcxGrid;
    cxGridTableView1: TcxGridTableView;
    cxGridColumn1: TcxGridColumn;
    cxGridColumn2: TcxGridColumn;
    cxGridColumn3: TcxGridColumn;
    cxGridLevel1: TcxGridLevel;
    cxGridTableView1Column1: TcxGridColumn;
    cxGridTableView1Column2: TcxGridColumn;
    cxGridTableView1Column3: TcxGridColumn;
    SearchPublicClubs1: TMenuItem;
    acShowPublicGamesListForm: TAction;
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
    procedure btOpenTableClick(Sender: TObject);
    procedure gridJoinedClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
      AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure acShowPublicGamesListFormExecute(Sender: TObject);
  private
    FSelectedClub: TClubInfo;

    function ShowLoginForm: Integer;

    procedure DoLogout;
    procedure UpdateClublist;

    procedure TCStatusReply(const AMessage: TMessageItem);
    procedure TCLeaveClubOk(const AMessage: TMessageItem);
    procedure TCLeaveClubInvalidId(const AMessage: TMessageItem);
    procedure TCLogout(const AMessage: TMessageItem);
    procedure TCSecondaryLoginDetected(const AMessage: TMessageItem);

    procedure SocketChangeState(const AOldState, ANewState: TSocketState);

    procedure ConfigureGUI;

  protected
    procedure DoCreate; override;
    procedure WndProc(var AMessage: TMessage); override;

  public
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses
  uSettings, uLoginForm, uSocketClient, uServerCodes, uCommon, uMainDataModule, uCreateClubForm, uJoinClubForm,
  uPlayerInfo, uManageClubsForm, uChangeEMailForm, uChangePasswordForm, uChangeAvatarForm, uAvatar, uPublicClubsList,
  uPB_StatusReply, uMessageContainer, uServerMessageCallback;


procedure TfrmMain.DoCreate;
begin
  inherited;

  ShowLoginForm;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmMain.WndProc(var AMessage: TMessage);
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
                            TServerMessageCallback.Create(SR_SECONDARY_LOGIN_DETECTED, TCSecondaryLoginDetected)
                          ]
                        );

      mtSocketChangeState: SocketChangeState(msg.OldState, msg.NewState);
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmMain.DoLogout;
begin
  lbUserInfo.Caption := '';
  gridJoinedClubsTable.DataController.SetRecordCount(0);
  btLeaveClub.Enabled := FALSE;
  dmMain.SelfInfo.Flush;
  dmMain.Players.Clear;
end;

function TfrmMain.ShowLoginForm: Integer;
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

procedure TfrmMain.SocketChangeState(const AOldState, ANewState: TSocketState);
begin
  case ANewState of
    wsClosed: begin
      SocketClient.Disconnect;
      ShowLoginForm;
    end;
  end;
end;

procedure TfrmMain.tiBringToFrontTimer(Sender: TObject);
begin
  BringToFront;
  tiBringToFront.Enabled := FALSE;
end;

procedure TfrmMain.acBuyChipsExecute(Sender: TObject);
begin
  dmMain.OpenBuyChipsLink;
end;

procedure TfrmMain.acBuyTokensExecute(Sender: TObject);
begin
  dmMain.OpenBuyTokensLink;
end;

procedure TfrmMain.acLogoutExecute(Sender: TObject);
begin
  SocketClient.Logout;
end;


procedure TfrmMain.acShowChangeAvatarFormExecute(Sender: TObject);
begin
  RunModalForm(TfrmChangeAvatar, self, []);
end;

procedure TfrmMain.acShowChangeEMailFormExecute(Sender: TObject);
begin
  RunModalForm(TfrmChangeEMail, self, []);
end;

procedure TfrmMain.acShowChangePasswordFormExecute(Sender: TObject);
begin
  RunModalForm(TfrmChangePassword, self, []);
end;

procedure TfrmMain.acShowCreateClubFormExecute(Sender: TObject);
begin
  if RunModalForM(TfrmCreateClub, self, []) = mrOk then
    SocketClient.Status;
end;

procedure TfrmMain.acShowJoinClubFormExecute(Sender: TObject);
begin
  if RunModalForM(TfrmJoinClub, self, []) = mrOk then
    SocketClient.Status;
end;

procedure TfrmMain.acShowManageClubsFormExecute(Sender: TObject);
begin
  RunModalForM(TfrmManageClubs, self, []);
end;

procedure TfrmMain.acShowPublicGamesListFormExecute(Sender: TObject);
begin
  RunModalForm(TfrmPublicClubsList, self, []);
  SocketClient.Status;
end;

procedure TfrmMain.btLeaveClubClick(Sender: TObject);
begin
  if not Assigned(FSelectedClub) then
    Exit;

  SocketClient.LeaveClub(FSelectedClub.Id);
end;

procedure TfrmMain.btOpenTableClick(Sender: TObject);
begin
  dmMain.Tables.AddTable(Random(10000000));
end;

procedure TfrmMain.ConfigureGUI;
begin
  lbUserInfo.Caption := Format('You have %d tokens.', [dmMain.SelfInfo.Tokens]);

  Caption := Format('ChipUP Poker - Logged in as %s', [dmMain.SelfInfo.Nick]);
  if not dmMain.SelfInfo.Authed then
    Caption := Caption + ' (account confirmation pending)';
end;

procedure TfrmMain.UpdateClublist;
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

procedure TfrmMain.gridJoinedClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  acShowManageClubsForm.Execute;
end;

procedure TfrmMain.gridJoinedClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
  club_id : Int64;
begin
  recIndex := gridJoinedClubsTable.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
  begin
    btLeaveClub.Enabled := FALSE;
    FSelectedClub := nil;
    Exit;
  end;

  club_id := gridJoinedClubsTable.DataController.GetValue(recIndex, gridJoinedClubsId.Index);
  if dmMain.SelfInfo.Clubs.FindClub(club_id, FSelectedClub) then
  begin
    if FSelectedClub.OwnerId = dmMain.SelfInfo.Id then
      btLeaveClub.Enabled := FALSE
    else
      btLeaveClub.Enabled := TRUE;
  end
  else
    FSelectedClub := nil;
end;

procedure TfrmMain.TCSecondaryLoginDetected(const AMessage: TMessageItem);
begin
  ShowLoginForm;
end;

procedure TfrmMain.TCStatusReply(const AMessage: TMessageItem);
var
  pbstatus: TPB_StatusReply;
begin
  pbstatus := AMessage.Object_ as TPB_StatusReply;

  dmMain.SelfInfo.ParseStatus(pbstatus);
  dmMain.Avatars.Add(dmMain.SelfInfo.AvatarId);
  dmMain.Players.ParseStatus(pbstatus);
  ConfigureGUI;
  UpdateClublist;
end;

procedure TfrmMain.TCLeaveClubInvalidId(const AMessage: TMessageItem);
begin
  MessageDlg('Invalid club ID', mtError, [mbOK], 0);
end;

procedure TfrmMain.TCLeaveClubOk(const AMessage: TMessageItem);
begin
  MessageDlg('Successfully left the club', mtInformation, [mbOK], 0);
  SocketClient.Status;
end;

procedure TfrmMain.TCLogout(const AMessage: TMessageItem);
begin
  ShowLoginForm;
end;

end.
