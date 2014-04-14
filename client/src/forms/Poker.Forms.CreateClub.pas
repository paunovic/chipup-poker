unit Poker.Forms.CreateClub;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, dxSkinsCore, cxLookAndFeels, dxSkinsForm, cxGraphics, cxControls,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit, Vcl.StdCtrls, cxRadioGroup, cxButtons, Vcl.ActnList,
  Vcl.Menus, ChipUpPokerDarkSkin;

type
  TfrmCreateClub = class(TForm)
    edClubName: TcxTextEdit;
    lbsClubName: TcxLabel;
    edClubCode: TcxTextEdit;
    lbsInvCode: TcxLabel;
    alCreateClub: TActionList;
    acOK: TAction;
    btOK: TcxButton;
    btCancel: TcxButton;
    acCancel: TAction;
    procedure acOKExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acCancelExecute(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FCallbacksId: Integer;

    procedure CSRCreateClub(const AMethodId: Integer; const AObject: TObject);
  protected
  public
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Server.Socket, Poker.Common.Misc, Poker.Protobufs.Enum.ServerCodes, Poker.Server.Validators, Poker.Protobufs.Objects.ClubCommandReply, Poker.Server.MessageContainer, Poker.Server.Settings,
  Poker.Server.MessageCallbacks, Poker.Common.FormsContainer;


procedure TfrmCreateClub.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srCreateClubReply, CSRCreateClub)
                  ]);

  edClubName.Properties.MaxLength := ServerSettings.StringLengths.ClubName;
  edClubCode.Properties.MaxLength := ServerSettings.StringLengths.ClubInvCode;
end;

procedure TfrmCreateClub.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmCreateClub.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
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
  Close;
end;

procedure TfrmCreateClub.acOKExecute(Sender: TObject);
var
  error: String;
begin
  if not ValidateClubName(edClubName.Text, error) then
    edClubName.SetFocus
  else
    if not ValidateClubCode(edClubCode.Text, error) then
      edClubCode.SetFocus;

  if error <> '' then
  begin
    MessageDlg(error, mtError, [mbOK], 0);
    Exit;
  end;

  acOK.Enabled := FALSE;
  ServerSocket.CreateClub(edClubName.Text, edClubCode.Text, 5);
end;


procedure TfrmCreateClub.CSRCreateClub(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
begin
  pbreply := AObject as TPB_ClubCommandReply;

  case pbreply.Status of
    csSuccess: begin
      MessageDlg('Club created successfully!', mtInformation, [mbOK], 0);
      Close;
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
