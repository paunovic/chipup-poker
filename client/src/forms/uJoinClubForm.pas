unit uJoinClubForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  Vcl.Menus, Vcl.StdCtrls, cxButtons, cxLabel, cxTextEdit, Vcl.ActnList, dxSkinsForm, cxMaskEdit, cxSpinEdit,
  uIFormParams, uMessageItem, dxSkinDarkRoom;

type
  TfrmJoinClub = class(TForm, IFormParams)
    lbsClubID: TcxLabel;
    edClubCode: TcxTextEdit;
    lbsInvCode: TcxLabel;
    alJoinClub: TActionList;
    acOk: TAction;
    edClubID: TcxSpinEdit;
    btOK: TcxButton;
    btCancel: TcxButton;
    acCancel: TAction;
    procedure acOkExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edClubIDPropertiesChange(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    procedure CSRJoinClub(const AMessage: TMessageItem);
  protected
    procedure WndProc(var AMessage: TMessage); override;
  public
    procedure SetParams(const AParams: array of pointer);
  end;

implementation

{$R *.dfm}

uses
  uSocketClient, uCommon, uServerCodes, uMainDataModule, uMessageContainer, uServerMessageCallback, uPB_ClubCommandReply;


procedure TfrmJoinClub.edClubIDPropertiesChange(Sender: TObject);
begin
  if edClubID.Value > edClubID.Properties.MaxValue then
    edClubID.Value := edClubID.Properties.MaxValue;
  if edClubID.Value < 1 then
    edClubID.Value := 1;
end;

procedure TfrmJoinClub.FormCreate(Sender: TObject);
begin
  edClubCode.Properties.MaxLength := dmMain.ServerSettings.StringLengths.ClubInvCode;
end;

procedure TfrmJoinClub.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);
end;

procedure TfrmJoinClub.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
end;

procedure TfrmJoinClub.SetParams(const AParams: array of pointer);
begin
  edClubCode.TabOrder := 0;
  edClubID.TabOrder := 1;
  edClubID.Text := IntToStr(PInt64(AParams[0])^);
end;

procedure TfrmJoinClub.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: acCancel.Execute;
    VK_RETURN:
  end;
end;

procedure TfrmJoinClub.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_RETURN: begin
      if not edClubCode.Focused then
        SelectNext(ActiveControl, TRUE, TRUE)
      else
        acOk.Execute;
      Key := #0;
    end;
    VK_ESCAPE: begin
      acCancel.Execute;
      Key := #0;
    end;
  end;
end;

procedure TfrmJoinClub.WndProc(var AMessage: TMessage);
var
  msg: TMessageItem;
begin
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                           [
                             TServerMessageCallback.Create(srJoinClubReply, CSRJoinClub)
                           ]
                         );
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmJoinClub.acCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmJoinClub.acOkExecute(Sender: TObject);
begin
  acOK.Enabled := FALSE;
  SocketClient.JoinClub(edClubID.Value, edClubCode.Text);
end;

procedure TfrmJoinClub.CSRJoinClub(const AMessage: TMessageItem);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AMessage.Object_ as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: begin
      MessageDlg('Successfully joined', mtInformation, [mbOK], 0);
      ModalResult := mrOk;
    end;
    csInvalidClubId: begin
      MessageDlg('Invalid club ID', mtError, [mbOK], 0);
      edClubID.SetFocus;
    end;
    csAlreadyMember: begin
      MessageDlg('You are already member of this club', mtInformation, [mbOK], 0);
      edClubID.SetFocus;
    end;
    csBadPassword: begin
      MessageDlg('Invalid club code', mtError, [mbOK], 0);
      edClubCode.SetFocus;
    end;
  end;

  acOK.Enabled := TRUE;
end;


end.
