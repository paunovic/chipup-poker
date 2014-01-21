unit uTableSitForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinDarkRoom, Vcl.Menus, Vcl.StdCtrls, cxButtons, cxTextEdit, cxMaskEdit, cxSpinEdit, cxLabel, Vcl.ActnList, uGameInfo, uIFormParams,
  uMessageItem;

type
  TfrmTableSit = class(TForm, IFormParams)
    lbsBuyinAmount: TcxLabel;
    seBuyin: TcxSpinEdit;
    btOK: TcxButton;
    btCancel: TcxButton;
    alTableSit: TActionList;
    acOK: TAction;
    acCancel: TAction;
    procedure acCancelExecute(Sender: TObject);
    procedure acOKExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FGame     : TGameInfo;
    FSeatIndex: Integer;

    procedure TCTableSitOk(const AMessage: TMessageItem);
    procedure TCTableSitSeatTaken(const AMessage: TMessageItem);
  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
    procedure SetParams(const AParams: array of pointer);
  end;

var
  frmTableSit: TfrmTableSit;

implementation

{$R *.dfm}

uses
  uSocketClient, uMessageContainer, uServerCodes, uServerMessageCallback;


procedure TfrmTableSit.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmTableSit.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmTableSit.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_RETURN: begin
      acOK.Execute;
      Key := #0;
    end;
    VK_ESCAPE: begin
      acCancel.Execute;
      Key := #0;
    end;
  end;
end;

procedure TfrmTableSit.SetParams(const AParams: array of pointer);
begin
  FGame := AParams[0];
  FSeatIndex := PInteger(AParams[1])^;
end;

procedure TfrmTableSit.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(SR_TABLE_SIT_OK, TCTableSitOk),
                            TServerMessageCallback.Create(SR_TABLE_SIT_SEAT_TAKEN, TCTableSitSeatTaken)
                          ]
                        );
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmTableSit.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmTableSit.acOKExecute(Sender: TObject);
begin
  SocketClient.TableSit(FGame.MongoId, FSeatIndex, seBuyin.Value);
  acOK.Enabled := FALSE;
end;

procedure TfrmTableSit.TCTableSitOk(const AMessage: TMessageItem);
begin
  ModalResult := mrOk;
end;

procedure TfrmTableSit.TCTableSitSeatTaken(const AMessage: TMessageItem);
begin
  MessageDlg('Seat is already taken. Please choose another seat', mtWarning, [mbOK], 0);
  ModalResult := mrClose;
end;

end.
