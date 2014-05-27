unit Poker.Forms.HandHistory;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  ChipUpPokerDarkSkin, cxLabel, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxMemo, Vcl.Menus, Vcl.StdCtrls, cxButtons, Vcl.ActnList;

type
  TfrmHandHistory = class(TForm)
    cbTable: TcxComboBox;
    lbsTable: TcxLabel;
    meHandHistory: TcxMemo;
    btOK: TcxButton;
    btCancel: TcxButton;
    alHandHistory: TActionList;
    acOK: TAction;
    acClose: TAction;
    cxComboBox1: TcxComboBox;
    cxLabel1: TcxLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure acOKExecute(Sender: TObject);
    procedure acCloseExecute(Sender: TObject);
    procedure FormClick(Sender: TObject);
  private
    procedure ShowHand(const AHandId: UINT32);
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
  end;

var
  frmHandHistory: TfrmHandHistory;

implementation

{$R *.dfm}

uses
  Poker.Common.FormsContainer, Poker.HandHistory.Core, Poker.HandHistory.HandHistoryItem, Poker.Objects.ClubInfo, Poker.Objects.GameInfo,
  Poker.DataModule;


procedure TfrmHandHistory.FormDestroy(Sender: TObject);
begin
  FormsContainer.Remove(self);
end;

procedure TfrmHandHistory.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.ExStyle := AParams.ExStyle or WS_EX_APPWINDOW;
  AParams.WndParent := 0;
end;

procedure TfrmHandHistory.FormClick(Sender: TObject);
begin
  ShowHand(HandHistory.Items.Last.HandId);
end;

procedure TfrmHandHistory.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;


procedure TfrmHandHistory.acCloseExecute(Sender: TObject);
begin
  ModalResult := mrClose;
  Close;
end;

procedure TfrmHandHistory.acOKExecute(Sender: TObject);
begin
  ModalResult := mrOk;
  Close;
end;

procedure TfrmHandHistory.ShowHand(const AHandId: UINT32);
var
  hhi: THandHistoryItem;
begin
  meHandHistory.Clear;
  if not HandHistory.Find(AHandId, hhi) then
    Exit;
  meHandHistory.Lines.AddStrings(hhi.Lines);
end;


end.
