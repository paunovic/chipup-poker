unit uPublicClubsList;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinDevExpressStyle, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, cxSpinEdit, cxTextEdit,
  Vcl.Menus, Vcl.ActnList, Vcl.StdCtrls, cxButtons, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxClasses, cxGridCustomView, cxGrid;

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
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure gridClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure acJoinClubExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FSelectedClubId: Int64;

    procedure TCListClubs(const AData: TObject);

  protected
    procedure WndProc(var AMessage: TMessage); override;

  public
  end;

var
  frmPublicClubsList: TfrmPublicClubsList;

implementation

{$R *.dfm}

uses
  uSocketClient, uCommon, uServerCodes, superobject, uMainDataModule, uJoinClubForm, uMessageContainer;

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
begin
  inherited;
                  {
  if SocketClient.IsServerResponseMessage(AMessage) then
    SocketClient.ParseWndMessage(AMessage,
      [
        TWndCallback.Create(SR_LIST_CLUBS, TCListClubs)
      ]
    );             }
end;

procedure TfrmPublicClubsList.acJoinClubExecute(Sender: TObject);
begin
  if RunModalForm(TfrmJoinClub, self, [@FSelectedClubId]) = mrOk then;
end;

procedure TfrmPublicClubsList.acRefreshExecute(Sender: TObject);
begin
  acJoinClub.Enabled := FALSE;
  acRefresh.Enabled := FALSE;
  gridClubsTable.DataController.BeginFullUpdate;
  try
    gridClubsTable.DataController.SetRecordCount(0);
  finally
    gridClubsTable.DataController.EndFullUpdate;
  end;
  SocketClient.ListPublicClubs;
end;

procedure TfrmPublicClubsList.TCListClubs(const AData: TObject);
var
  json, sub_json: ISuperObject;
  rcount        : Integer;
begin
  json := TSuperObject.ParseString(PChar(AData), FALSE);

  gridClubsTable.DataController.BeginFullUpdate;
  try
    rcount := 0;
    gridClubsTable.DataController.SetRecordCount(0);
    if not Assigned(json) then
      Exit;

    for sub_json in json do
    begin
      Inc(rcount);
      gridClubsTable.DataController.SetRecordCount(rcount);
      gridClubsTable.DataController.SetValue(rcount - 1, gridClubsId.Index, sub_json.I['seq']);
      gridClubsTable.DataController.SetValue(rcount - 1, gridClubsName.Index, sub_json.S['name']);
      gridClubsTable.DataController.SetValue(rcount - 1, gridClubsInvitationCode.Index, sub_json.S['invcode']);
      gridClubsTable.DataController.SetValue(rcount - 1, gridClubsPlayers.Index, sub_json.I['member_count']);
    end;
  finally
    gridClubsTable.DataController.EndFullUpdate;
  end;

  acRefresh.Enabled := TRUE;
end;



end.
