unit Poker.Forms.Settings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore, ChipUpPokerDarkSkin,
  dxSkinscxPCPainter, cxPCdxBarPopupMenu, cxPC, Vcl.StdCtrls, dximctrl, cxContainer, cxEdit, cxGroupBox, Vcl.ImgList, cxListBox, cxLabel,
  dxGDIPlusClasses, cxImage, cxRadioGroup, Vcl.Menus, Vcl.ActnList, cxButtons, cxTextEdit, cxMaskEdit, cxDropDownEdit, Vcl.ExtCtrls,
  Poker.Table.Tables;

type
  TPaintPanel = class(TPanel)
  protected
    procedure Paint; override;
  end;

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
    procedure FormShow(Sender: TObject);
    procedure lbOptionsDrawItem(AControl: TcxListBox; ACanvas: TcxCanvas; AIndex: Integer; ARect: TRect; AState: TOwnerDrawState);
    procedure tsThemesResize(Sender: TObject);
  private
    FTableThemePanel: TPaintPanel;
    FTable: TTable;
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
  cbCardBackground.ItemIndex := Settings.CardBackground;
end;

procedure TfrmSettings.FormDestroy(Sender: TObject);
begin
  FTableThemePanel.Free;
  FormsContainer.Remove(self);
end;

procedure TfrmSettings.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = vk_ESCAPE then
    acCancel.Execute;
end;

procedure TfrmSettings.FormShow(Sender: TObject);
begin
  if not Assigned(FTableThemePanel) then
  begin
    FTableThemePanel := TPaintPanel.Create(self);
    FTableThemePanel.AlignWithMargins := TRUE;
    FTableThemePanel.Parent := tsThemes;
    FTableThemePanel.Caption := '';
    FTableThemePanel.Align := alBottom;
    FTableThemePanel.BevelOuter := bvNone;
    FTableThemePanel.Color := clBlack;
    FTable := Tables.AddSettingsPreviewTable(FTableThemePanel.Handle);
  end;
end;

procedure TfrmSettings.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Tables.Remove(FTable);
  FTable := nil;
  Action := caFree;
end;

procedure TfrmSettings.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult = mrOk then
  begin
    Settings.CardBackground := cbCardBackground.ItemIndex;
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
  if (pcSettings.ActivePage = tsThemes) and
     (Assigned(FTable)) then
    FTable.Renderer.Render;
end;

procedure TfrmSettings.tsThemesResize(Sender: TObject);
begin
  if Assigned(FTableThemePanel) then
    FTableThemePanel.Height := Round(FTableThemePanel.Width / 1.35);

  if Assigned(FTable) then
    FTable.Renderer.UpdateDXAreaSize;
end;

{ TPaintPanel }

procedure TPaintPanel.Paint;
begin
  inherited;
  (Owner as TfrmSettings).RenderThemeTable;
end;

end.
