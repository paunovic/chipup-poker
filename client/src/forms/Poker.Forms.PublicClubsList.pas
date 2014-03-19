unit Poker.Forms.PublicClubsList;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinscxPCPainter, cxCustomData, cxDataStorage, cxEdit, cxSpinEdit, cxTextEdit,
  Vcl.ActnList, Vcl.StdCtrls, cxButtons, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxClasses, cxGridCustomView, cxGrid,
   Vcl.ExtCtrls, dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton, cxStyles, cxFilter, cxData, Vcl.Menus;

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
    procedure FormDestroy(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure gridClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure acJoinClubExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tiRefreshActionEnablerTimer(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure gridClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FSelectedClubId: Int64;
    FCallbacksId: Integer;

    procedure CSRListClubs(const AMethodId: Integer; const AObject: TObject);

  protected
  public
  end;

implementation

{$R *.dfm}

uses
  Poker.Server.Socket, Poker.Common.Misc, Poker.Protobufs.Enum.ServerCodes, Poker.DataModule, Poker.Forms.JoinClub, Poker.Server.MessageCallbacks, Poker.Server.MessageContainer, Poker.Common.FormsContainer,
  Poker.Protobufs.Objects.ListClubsReply, Poker.Protobufs.Objects.Club;


procedure TfrmPublicClubsList.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srListClubs, CSRListClubs)
                  ]);

  FSelectedClubId := -1;

  ServerSocket.ListPublicClubs;
end;

procedure TfrmPublicClubsList.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmPublicClubsList.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmPublicClubsList.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: Close;
  end;
end;

procedure TfrmPublicClubsList.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_ESCAPE: begin
      Close;
      Key := #0;
    end;
  end;
end;

procedure TfrmPublicClubsList.gridClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if acJoinClub.Enabled then
    acJoinClub.Execute;
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

procedure TfrmPublicClubsList.acJoinClubExecute(Sender: TObject);
begin
  if not dmMain.CheckAuthed then
    Exit;

  FormsContainer.RunForm(TfrmJoinClub, self, [@FSelectedClubId], FALSE);
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
  ServerSocket.ListPublicClubs;

  tiRefreshActionEnabler.Enabled := TRUE;
end;

procedure TfrmPublicClubsList.CSRListClubs(const AMethodId: Integer; const AObject: TObject);
var
  rcount: Integer;
  club  : TPB_Club;
  clubs : TPB_ListClubsReply;
  tmp   : String;
begin
  clubs := AObject as TPB_ListClubsReply;

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
