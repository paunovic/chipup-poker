unit Poker.Forms.ContactUs;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, cxMaskEdit,
  cxDropDownEdit, cxTextEdit, cxLabel, Vcl.Menus, Vcl.StdCtrls, cxButtons,
  cxMemo, Vcl.ActnList;

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

var
  frmContactUs: TfrmContactUs;

implementation

{$R *.dfm}

uses
  Poker.Server.MessageContainer, Poker.Common.FormsContainer, Poker.Server.Socket, Poker.Protobufs.Objects.ContactMessage,
  Poker.Protobufs.Enum.ServerCodes, Poker.Server.MessageCallbacks;


procedure TfrmContactUs.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                     TServerMessageCallback.Create(srContactUsOk, CSRContactUsOk)
  ]);
end;

procedure TfrmContactUs.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmContactUs.acSendExecute(Sender: TObject);
begin
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
  MessageDlg('Message successfully sent. We will contact you back via E-Mail address associated to this account.',
     mtInformation, [mbOK], 0);
  Close;
end;

end.
