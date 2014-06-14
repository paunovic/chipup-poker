unit Poker.Forms.Settings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore, ChipUpPokerDarkSkin,
  dxSkinscxPCPainter, cxPCdxBarPopupMenu, cxPC, Vcl.StdCtrls, dximctrl, cxContainer, cxEdit, cxGroupBox, Vcl.ImgList, cxListBox, cxLabel,
  dxGDIPlusClasses, cxImage, cxRadioGroup, Vcl.Menus, Vcl.ActnList, cxButtons;

type
  TfrmSettings = class(TForm)
    gbLeftPanel: TcxGroupBox;
    lbOptions: TcxListBox;
    gbRightPanel: TcxGroupBox;
    pcSettings: TcxPageControl;
    tsGeneral: TcxTabSheet;
    tsThemes: TcxTabSheet;
    lbsCardBackground: TcxLabel;
    imgCardBack1: TcxImage;
    imgCardBack2: TcxImage;
    rbCardBack1: TcxRadioButton;
    rbCardBack2: TcxRadioButton;
    btOK: TcxButton;
    btCancel: TcxButton;
    alSettings: TActionList;
    acOK: TAction;
    acCancel: TAction;
    procedure imgCardBack1Click(Sender: TObject);
    procedure imgCardBack2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure acOKExecute(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure lbOptionsClick(Sender: TObject);
    procedure lbOptionsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    procedure LeftListboxChanged;
  public

  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.dfm}

uses
  Poker.Settings, Poker.Common.FormsContainer;

procedure TfrmSettings.FormCreate(Sender: TObject);
var
  rb: TcxRadioButton;
  comp: TComponent;
begin
  pcSettings.ActivePageIndex := 0;

  comp := FindComponent(Format('rbCardBack%d', [Settings.CardBackground]));
  if not Assigned(comp) then
    rb := rbCardBack1
  else
    rb := comp as TcxRadioButton;
  rb.Checked := TRUE;
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
var
  C1: Integer;
  comp: TComponent;
begin
  if ModalResult = mrOk then
  begin
    for C1 := 1 to 2 do
    begin
      comp := FindComponent(Format('rbCardBack%d', [C1]));
      if not Assigned(comp) then
        Continue;
      if (comp as TcxRadioButton).Checked then
      begin
        Settings.CardBackground := C1;
        Break;
      end;
    end;
    Settings.Save;
  end;
end;

procedure TfrmSettings.imgCardBack1Click(Sender: TObject);
begin
  rbCardBack1.Checked := TRUE;
end;

procedure TfrmSettings.imgCardBack2Click(Sender: TObject);
begin
  rbCardBack2.Checked := TRUE;
end;

procedure TfrmSettings.lbOptionsClick(Sender: TObject);
begin
  LeftListboxChanged;
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



end.
