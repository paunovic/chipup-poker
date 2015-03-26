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
    procedure gridClubsTableFocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure FormCreate(Sender: TObject);
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

procedure TfrmPublicClubsList.gridClubsTableCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if acJoinClub.Enabled then
    acJoinClub.Execute;
end;

end.
