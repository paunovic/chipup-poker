unit Poker.Forms.About;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, Vcl.Controls, Vcl.Forms, cxLabel,
  Poker.Forms.LayeredForm, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, dxSkinsCore, ChipUPPokerDarkSkin;

type
  TfrmAbout = class(TForm)
    lbsCopyright: TcxLabel;
    lbsURL: TcxLabel;
    procedure lbsURLClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDeactivate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FLayeredForm: TfrmLayered;
  protected
    procedure WMMove(var AMessage: TMessage); message WM_MOVE;
  public
  end;

implementation

{$R *.dfm}

uses
  Poker.DataModule, Poker.Settings, Poker.Common.FormsContainer, PNGImage,
  Poker.Common.Misc, System.SysUtils;

procedure TfrmAbout.FormCreate(Sender: TObject);
var
  url: String;
begin
  FLayeredForm := TfrmLayered.Create(self, 'AboutBackground');
  Caption := Settings.Hardcoded.PROJECT_CAPTION;
  lbsCopyright.Caption := Format('Copyright © 2015 %s', [Settings.Hardcoded.PROJECT_CAPTION]);

  url := Settings.Hardcoded.SERVER_LIST[Settings.ServerIndex].URL;
  if Pos('://', url) > 0 then
    Delete(url, 1, Pos('://', url) + 2);
  lbsURL.Caption := url;
end;

procedure TfrmAbout.FormDestroy(Sender: TObject);
begin
  FLayeredForm.Free;
  FormsContainer.Remove(self);
end;


procedure TfrmAbout.FormHide(Sender: TObject);
begin
  FLayeredForm.Hide;
end;

procedure TfrmAbout.FormDeactivate(Sender: TObject);
begin
  if (Screen.ActiveForm <> FLayeredForm) and
     (Screen.ActiveForm <> self) then
  begin
    ModalResult := mrOk;
    Close;
  end;
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

procedure TfrmAbout.FormShow(Sender: TObject);
begin
  RoundControl(self, 15);

  if Assigned(FLayeredForm) then
  begin
    FLayeredForm.UpdatePosition;
    FLayeredForm.Show;
  end;
end;

procedure TfrmAbout.lbsURLClick(Sender: TObject);
begin
  dmMain.OpenSiteLink;
end;

procedure TfrmAbout.WMMove(var AMessage: TMessage);
begin
  inherited;
  if Assigned(FLayeredForm) then
    FLayeredForm.UpdatePosition;
end;

end.

