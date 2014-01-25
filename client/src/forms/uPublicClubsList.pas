unit uPublicClubsList;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, cxSpinEdit, cxTextEdit,
  Vcl.Menus, Vcl.ActnList, Vcl.StdCtrls, cxButtons, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxClasses, cxGridCustomView, cxGrid,
  uMessageItem, dxSkinDarkRoom, Vcl.ExtCtrls;

type
  TfrmPublicClubsList = class(TForm)
    gridClubs: TcxGrid;
    gridClubsTable: TcxGridTableView;
    gridClubsId: TcxGridColumn;
    gridClubsName: TcxGridColumn;
    gridClubsInvitationCode: TcxGridColumn;
    gridClubsLevel: TcxGridLevel;
    gridClubsPlayers: TcxGridColumn;
    btJoinClub: TcxButton;
    btRefreshList: TcxButton;
    alPublicClubsList: TActionList;
    acRefresh: TAction;
    acJoinClub: TAction;
    tiRefreshActionEnabler: TTimer;
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure gridClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure acJoinClubExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tiRefreshActionEnablerTimer(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FSelectedClubId: Int64;

    procedure CSRListClubs(const AMessage: TMessageItem);

  protected
    procedure WndProc(var AMessage: TMessage); override;

  public
  end;

var
  frmPublicClubsList: TfrmPublicClubsList;

implementation

{$R *.dfm}

uses
  uSocketClient, uCommon, uServerCodes, uMainDataModule, uJoinClubForm, uMessageContainer, uServerMessageCallback,
  uPB_ListClubsReply, uPB_Club;


procedure TfrmPublicClubsList.FormCreate(Sender: TObject);
begin
  FSelectedClubId := -1;
end;

procedure TfrmPublicClubsList.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmPublicClubsList.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: ModalResult := mrCancel;
  end;
end;

procedure TfrmPublicClubsList.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_ESCAPE: begin
      ModalResult := mrCancel;
      Key := #0;
    end;
  end;
end;

procedure TfrmPublicClubsList.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
  SocketClient.ListPublicClubs;
end;

procedure TfrmPublicClubsList.gridClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  recIndex: Integer;
begin
  recIndex := gridClubsTable.DataController.GetFocusedRecordIndex;
  if recIndex = -1 then
    FSelectedClubId := -1
  else
    FSelectedClubId := gridClubsTable.DataController.GetValue(recIndex, gridClubsId.Index);

  acJoinClub.Enabled := FSelectedClubId <> -1;
end;

procedure TfrmPublicClubsList.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(srListClubs, CSRListClubs)
                          ]
                        );

      mtSocketChangeState: ;
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmPublicClubsList.acJoinClubExecute(Sender: TObject);
begin
  if RunModalForm(TfrmJoinClub, self, [@FSelectedClubId]) = mrOk then;
end;

procedure TfrmPublicClubsList.acRefreshExecute(Sender: TObject);
begin
  acRefresh.Enabled := FALSE;

  gridClubsTable.DataController.BeginFullUpdate;
  try
    gridClubsTable.DataController.SetRecordCount(0);
  finally
    gridClubsTable.DataController.EndFullUpdate;
  end;
  SocketClient.ListPublicClubs;

  tiRefreshActionEnabler.Enabled := TRUE;
end;

procedure TfrmPublicClubsList.CSRListClubs(const AMessage: TMessageItem);
var
  rcount: Integer;
  club  : TPB_Club;
  clubs : TPB_ListClubsReply;
  tmp   : String;
begin
  clubs := AMessage.Object_ as TPB_ListClubsReply;

  gridClubsTable.DataController.BeginFullUpdate;
  try
    rcount := 0;
    gridClubsTable.DataController.SetRecordCount(0);

    for club in clubs.Clubs do
    begin
      Inc(rcount);
      gridClubsTable.DataController.SetRecordCount(rcount);
      gridClubsTable.DataController.SetValue(rcount - 1, gridClubsId.Index, club.Seq);
      gridClubsTable.DataController.SetValue(rcount - 1, gridClubsName.Index, club.Name);

      if club.HasPassword then
        tmp := 'Yes'
      else
        tmp := 'No';
      gridClubsTable.DataController.SetValue(rcount - 1, gridClubsInvitationCode.Index, tmp);

      gridClubsTable.DataController.SetValue(rcount - 1, gridClubsPlayers.Index, club.MemberCount);
    end;
  finally
    gridClubsTable.DataController.EndFullUpdate;
  end;
end;



procedure TfrmPublicClubsList.tiRefreshActionEnablerTimer(Sender: TObject);
begin
  acRefresh.Enabled := TRUE;
  tiRefreshActionEnabler.Enabled := FALSE;
end;

end.
