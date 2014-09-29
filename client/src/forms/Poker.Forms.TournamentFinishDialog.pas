unit Poker.Forms.TournamentFinishDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, Vcl.Menus,
  Vcl.StdCtrls, cxButtons, cxLabel;

type
  TfrmTournamentFinishDialog = class(TForm)
    lbvText: TcxLabel;
    btOk: TcxButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
  public
    class procedure Run(const AOwner: TComponent; const AText: String);

    procedure SetText(const AText: String);
  end;

implementation

{$R *.dfm}

{ TfrmTournamentFinishDialog }

class procedure TfrmTournamentFinishDialog.Run(const AOwner: TComponent; const AText: String);
var
  form: TfrmTournamentFinishDialog;
begin
  form := TfrmTournamentFinishDialog.Create(AOwner);
  form.SetText(AText);
  form.Show;
end;

procedure TfrmTournamentFinishDialog.SetText(const AText: String);
begin
  lbvText.Caption := AText;
end;

procedure TfrmTournamentFinishDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
