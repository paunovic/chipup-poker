unit uCreateClubForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dxSkinsCore, cxLookAndFeels, dxSkinsForm, cxGraphics, cxControls,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit, Vcl.StdCtrls, cxRadioGroup, Vcl.Menus, cxButtons, Vcl.ActnList,
  uMessageItem, dxsChipUpDark, dxsChipUpDarkTabs, dxsChipUpRedButton;

type
  TfrmCreateClub = class(TForm)
    edClubName: TcxTextEdit;
    lbsClubName: TcxLabel;
    edClubCode: TcxTextEdit;
    lbsInvCode: TcxLabel;
    lbsClubType: TcxLabel;
    rbPrivate: TcxRadioButton;
    rbPublic: TcxRadioButton;
    alCreateClub: TActionList;
    acOK: TAction;
    btOK: TcxButton;
    btCancel: TcxButton;
    acCancel: TAction;
    procedure acOKExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    procedure CSRCreateClub(const AMessage: TMessageItem);
  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uSocketClient, uCommon, uServerCodes, uValidators, uMainDataModule, uPB_ClubCommandReply, uMessageContainer, uServerSettings,
  uServerMessageCallback;


procedure TfrmCreateClub.FormCreate(Sender: TObject);
begin

  edClubName.Properties.MaxLength := ServerSettings.StringLengths.ClubName;
  edClubCode.Properties.MaxLength := ServerSettings.StringLengths.ClubInvCode;
end;

procedure TfrmCreateClub.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmCreateClub.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmCreateClub.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_ESCAPE: begin
      acCancel.Execute;
      Key := #0;
    end;
    VK_RETURN: begin
      if not edClubCode.Focused then
        SelectNext(ActiveControl, TRUE, TRUE);
      Key := #0;
    end;
  end;
end;

procedure TfrmCreateClub.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmCreateClub.acOKExecute(Sender: TObject);
var
  error: String;
begin
  if not ValidateClubName(edClubName.Text, error) then
    edClubName.SetFocus
  else
    if not ValidateClubCode(edClubCode.Text, error) then
      edClubCode.SetFocus
    else
      if not ValidatePrivateClubCode(rbPrivate.Checked, edClubCode.Text, error) then
        edClubCode.SetFocus;

  if error <> '' then
  begin
    MessageDlg(error, mtError, [mbOK], 0);
    Exit;
  end;

  acOK.Enabled := FALSE;
  SocketClient.CreateClub(edClubName.Text, edClubCode.Text, rbPrivate.Checked, 5);
end;

procedure TfrmCreateClub.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                           [
                             TServerMessageCallback.Create(srCreateClubReply, CSRCreateClub)
                           ]
                         );
    end;

    MessageContainer.RemoveMessageReader(AMessage.WParam, Handle);
  end;
end;

procedure TfrmCreateClub.CSRCreateClub(const AMessage: TMessageItem);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AMessage.Object_ as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: begin
      MessageDlg('Club created successfully!', mtInformation, [mbOK], 0);
      ModalResult := mrOk;
    end;
    csInvalidName: begin
      MessageDlg('Invalid club name', mtError, [mbOK], 0);
      edClubName.SetFocus;
    end;
    csNameExists: begin
      MessageDlg('Club name already exists', mtError, [mbOK], 0);
      edClubName.SetFocus;
    end;
    csBadPassword: begin
      MessageDlg('Invalid club code', mtError, [mbOK], 0);
      edClubCode.SetFocus;
    end;
  else
    {$IFDEF DEBUG} DebugLn(Format('CSRCreateClub: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
  end;

  acOK.Enabled := TRUE;
end;

end.
