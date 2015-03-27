unit Poker.Forms.Settings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore, ChipUpPokerDarkSkin,
  dxSkinscxPCPainter, cxPCdxBarPopupMenu, cxPC, Vcl.StdCtrls, dximctrl, cxContainer,
  cxEdit, cxGroupBox, Vcl.ImgList, cxListBox, cxLabel, dxGDIPlusClasses, cxImage,
  cxRadioGroup, Vcl.Menus, Vcl.ActnList, cxButtons, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, Vcl.ExtCtrls;

type
  TfrmSettings = class(TForm)
    gbLeftPanel: TcxGroupBox;
    lbOptions: TcxListBox;
    gbRightPanel: TcxGroupBox;
    pcSettings: TcxPageControl;
    tsGeneral: TcxTabSheet;
    tsThemes: TcxTabSheet;
    lbsCardBackground: TcxLabel;
    btOK: TcxButton;
    btCancel: TcxButton;
    alSettings: TActionList;
    acOK: TAction;
    acCancel: TAction;
    lbsRoomBackground: TcxLabel;
    cbCardBackground: TcxComboBox;
    cbRoomBackground: TcxComboBox;
    procedure FormCreate(Sender: TObject);
    procedure acOKExecute(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure lbOptionsClick(Sender: TObject);
    procedure lbOptionsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lbOptionsDrawItem(AControl: TcxListBox; ACanvas: TcxCanvas; AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
  private
    procedure LeftListboxChanged;
  public
    procedure RenderThemeTable;
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Settings, Poker.Common.FormsContainer, Poker.DataModule, Poker.Forms.Table, cxClasses;

procedure TfrmSettings.FormCreate(Sender: TObject);
begin
  pcSettings.ActivePageIndex := 0;
  lbOptions.Selected[0] := TRUE;
//  cbCardBackground.ItemIndex := Settings.CardBackground;
end;

procedure TfrmSettings.FormDestroy(Sender: TObject);
begin
  FormsContainer.Remove(self);
end;

procedure TfrmSettings.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = vk_ESCAPE then
    acCancel.Execute;
end;

procedure TfrmSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmSettings.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult = mrOk then
  begin
//    Settings.CardBackground := cbCardBackground.ItemIndex;
    Settings.Save;
  end;
end;

procedure TfrmSettings.lbOptionsClick(Sender: TObject);
begin
  LeftListboxChanged;
end;

procedure TfrmSettings.lbOptionsDrawItem(AControl: TcxListBox; ACanvas: TcxCanvas; AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
begin
  if odSelected in AState then
    ACanvas.Brush.Color := $00000073;

  ACanvas.FillRect(ARect);
  ACanvas.DrawTexT('  ' + lbOptions.Items[AIndex], ARect, taLeftJustify, vaCenter, FALSE, FALSE);

  if odFocused in AState then
    ACanvas.DrawFocusRect(ARect);
end;

procedure TfrmSettings.lbOptionsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  LeftListboxChanged;
end;

procedure TfrmSettings.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TfrmSettings.acOKExecute(Sender: TObject);
begin
  ModalResult := mrOk;
  Close;
end;

procedure TfrmSettings.LeftListboxChanged;
begin
  pcSettings.ActivePageIndex := lbOptions.ItemIndex;
end;

procedure TfrmSettings.RenderThemeTable;
begin
  //
end;

end.




