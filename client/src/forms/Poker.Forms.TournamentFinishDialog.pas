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
  private
  public
    class function RunModal(const AOwner: TComponent; const AText: String): Integer;

    procedure SetText(const AText: String);
  end;

implementation

{$R *.dfm}

{ TfrmTournamentFinishDialog }

class function TfrmTournamentFinishDialog.RunModal(const AOwner: TComponent; const AText: String): Integer;
var
  form: TfrmTournamentFinishDialog;
begin
  form := TfrmTournamentFinishDialog.Create(AOwner);
  try
    form.SetText(AText);
    result := form.ShowModal;
  finally
    form.Free;
  end;
end;

procedure TfrmTournamentFinishDialog.SetText(const AText: String);
begin
  lbvText.Caption := AText;
end;

end.
