unit Poker.Forms.ContactUs;

interface

uses
  Winapi.Windows, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  cxContainer,
  cxDropDownEdit, cxTextEdit, cxLabel, cxButtons,
  cxMemo, Vcl.ActnList, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxEdit, dxSkinsCore, ChipUpPokerDarkSkin, Vcl.Menus,
  Vcl.StdCtrls, cxMaskEdit;

type
  TfrmContactUs = class(TForm)
    lbsMessage: TcxLabel;
    cbType: TcxComboBox;
    lbsType: TcxLabel;
    meMessage: TcxMemo;
    btSend: TcxButton;
    btCancel: TcxButton;
    ActionList: TActionList;
    acSend: TAction;
    acCancel: TAction;
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure acSendExecute(Sender: TObject);
  private
    FCallbacksId: Integer;

    procedure CSRContactUsOk(const AMethodId: Integer; const AObject: TObject);
  public
  end;

implementation

{$R *.dfm}

uses
  Poker.Server.MessageContainer, Poker.Common.FormsContainer, Poker.Server.Socket.Commands, Poker.Protobufs.Objects.ContactMessage,
  Poker.Protobufs.Enum.ServerCodes, Poker.Server.MessageCallbacks, Poker.Server.Validators, Poker.Server.Settings;


procedure TfrmContactUs.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                     TServerMessageCallback.Create(srContactUsOk, CSRContactUsOk)
  ]);

  meMessage.Properties.MaxLength := ServerSettings.MaxStringLengths.ContactMessage;
end;

procedure TfrmContactUs.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmContactUs.acSendExecute(Sender: TObject);
var
  error: String;
begin
  if not ValidateContactMessage(meMessage.Text, error) then
    meMessage.SetFocus;

  if error <> '' then
  begin
    MessageDlg(error, mtError, [mbOK], 0);
    Exit;
  end;

  acSend.Enabled := FALSE;
  ServerSocket.ContactUs(TContactReason(cbType.ItemIndex), meMessage.Text);
end;

procedure TfrmContactUs.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmContactUs.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
  Close;
end;

procedure TfrmContactUs.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = vk_ESCAPE then
    acCancel.Execute;
end;

procedure TfrmContactUs.CSRContactUsOk(const AMethodId: Integer; const AObject: TObject);
begin
  MessageDlg('Ticket successfully created. Please check your inbox for more details.',  mtInformation, [mbOK], 0);
  Close;
end;

end.
