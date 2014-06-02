unit Poker.Forms.About;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, Vcl.Menus, dxSkinsCore, ChipUpPokerDarkSkin,
  Vcl.ActnList, Vcl.StdCtrls, cxButtons, cxControls, cxContainer, cxEdit, dxGDIPlusClasses, cxImage, cxLabel;

type
  TfrmAbout = class(TForm)
    btOK: TcxButton;
    ActionList: TActionList;
    acOK: TAction;
    imgHeader: TcxImage;
    lbsClientVersion: TcxLabel;
    lbvClientVersion: TcxLabel;
    lbsCopyright: TcxLabel;
    imgChip: TcxImage;
    lbsURL: TcxLabel;
    procedure acOKExecute(Sender: TObject);
    procedure lbsURLClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
  public
  end;

implementation

{$R *.dfm}

uses
  Poker.DataModule, Poker.Settings, Poker.Common.FormsContainer;


procedure TfrmAbout.FormCreate(Sender: TObject);
begin
  lbvClientVersion.Caption := Settings.Hardcoded.VERSION;
end;

procedure TfrmAbout.FormDestroy(Sender: TObject);
begin
  FormsContainer.Remove(self);
end;

procedure TfrmAbout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;


procedure TfrmAbout.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = vk_ESCAPE then
  begin
    ModalResult := mrClose;
    Close;
  end;
end;

procedure TfrmAbout.acOKExecute(Sender: TObject);
begin
  ModalResult := mrOk;
  Close;
end;

procedure TfrmAbout.lbsURLClick(Sender: TObject);
begin
  dmMain.OpenSiteLink;
end;

end.
