unit Poker.Forms.JoinClub;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxContainer,
  cxButtons, cxLabel, cxTextEdit, Vcl.ActnList, cxSpinEdit,
  Poker.Interfaces.FormParams, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxEdit, dxSkinsCore, ChipUpPokerDarkSkin,
  Vcl.Menus, Vcl.StdCtrls, cxMaskEdit;

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
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FCallbacksId: Integer;

    procedure CSRJoinClub(const AMethodId: Integer; const AObject: TObject);
  protected
  public
    procedure SetParams(const AParams: array of pointer);
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Server.Socket, Poker.Protobufs.Enum.ServerCodes, Poker.Server.MessageCallbacks, Poker.Protobufs.Objects.ClubCommandReply, Poker.Server.MessageContainer, Poker.Server.Settings,
  Poker.Common.FormsContainer, Poker.Server.Validators;


procedure TfrmJoinClub.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srJoinClubReply, CSRJoinClub)
                  ]);
  edClubCode.Properties.MaxLength := ServerSettings.MaxStringLengths.ClubInvCode;
end;

procedure TfrmJoinClub.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmJoinClub.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
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

procedure TfrmJoinClub.edClubIDPropertiesChange(Sender: TObject);
begin
  if edClubID.Value > edClubID.Properties.MaxValue then
    edClubID.Value := edClubID.Properties.MaxValue;
  if edClubID.Value < 1 then
    edClubID.Value := 1;
end;

procedure TfrmJoinClub.acCancelExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmJoinClub.acOkExecute(Sender: TObject);
var
  error: String;
begin
  error := '';
  if not ValidateClubPassword(edClubCode.Text, error) then
    edClubCode.SetFocus;

  if error <> '' then
  begin
    MessageDlg(error, mtError, [mbOK], 0);
    Exit;
  end;

  acOK.Enabled := FALSE;
  ServerSocket.JoinClub(edClubID.Value, edClubCode.Text);
end;

procedure TfrmJoinClub.CSRJoinClub(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AObject as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: begin
      if (not Assigned(pbreply.Club)) or
         (pbreply.Club.Seq <> edClubID.Value) then
        Exit;

      MessageDlg('Successfully joined', mtInformation, [mbOK], 0);
      Close;
    end;
    csInvalidClubId: begin
      MessageDlg('Invalid club ID', mtError, [mbOK], 0);
      edClubID.SetFocus;
    end;
    csAlreadyMember: begin
      MessageDlg('You are already member of this club', mtInformation, [mbOK], 0);
      edClubID.SetFocus;
    end;
    csInvalidPassword: begin
      MessageDlg('Invalid club password', mtError, [mbOK], 0);
      edClubCode.SetFocus;
    end;
  else
    {$IFDEF DEBUG} DebugLn(Format('CSRJoinClub: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
  end;

  acOK.Enabled := TRUE;
end;


end.
