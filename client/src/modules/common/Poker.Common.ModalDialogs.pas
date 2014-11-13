unit Poker.Common.ModalDialogs;

interface

uses
  System.Generics.Collections, Vcl.Dialogs, Vcl.Forms;

type
  TModalDialogs = class
  private
    FHandles: TList<THandle>;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    procedure CloseAll;
    function ShowDialog(const AText: String; const AType: TMsgDlgType; const AButtons: TMsgDlgButtons; const ADefaultButton: TMsgDlgBtn): Integer;
    procedure ShowWarning(const AWarning: String);
    procedure ShowInformation(const AInformation: String);
    function ShowConfirmation(const AConfirmation: String; const AButtons: TMsgDlgButtons = mbYesNo; const ADefaultButton: TMsgDlgBtn = mbYes): Integer;
  end;

var
  ModalDialogs: TModalDialogs;

implementation

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils;

{ TModalDialogs }

class procedure TModalDialogs.Initialize;
begin
  ModalDialogs := TModalDialogs.Create;
end;

class procedure TModalDialogs.Deinitialize;
begin
  FreeAndNil(ModalDialogs);
end;

constructor TModalDialogs.Create;
begin
  FHandles := TList<THandle>.Create;
end;

destructor TModalDialogs.Destroy;
begin
  CloseAll;
  FHandles.Free;
  inherited;
end;

procedure TModalDialogs.CloseAll;
var
  handle: THandle;
begin
  for handle in FHandles do
    SendMessage(handle, WM_CLOSE, 0, 0);
end;

function TModalDialogs.ShowDialog(const AText: String; const AType: TMsgDlgType; const AButtons: TMsgDlgButtons; const ADefaultButton: TMsgDlgBtn): Integer;
var
  dialog: TForm;
begin
  dialog := CreateMessageDialog(AText, AType, AButtons, ADefaultButton);
  try
    FHandles.Add(dialog.Handle);
    result := dialog.ShowModal;
  finally
    FHandles.Remove(dialog.Handle);
    dialog.Free;
  end;
end;

procedure TModalDialogs.ShowInformation(const AInformation: String);
begin
  ShowDialog(AInformation, mtInformation, [mbOK], mbOK);
end;

procedure TModalDialogs.ShowWarning(const AWarning: String);
begin
  ShowDialog(AWarning, mtWarning, [mbOK], mbOK);
end;

function TModalDialogs.ShowConfirmation(const AConfirmation: String; const AButtons: TMsgDlgButtons = mbYesNo; const ADefaultButton: TMsgDlgBtn = mbYes): Integer;
begin
  result := ShowDialog(AConfirmation, mtConfirmation, AButtons, ADefaultButton);
end;


end.
