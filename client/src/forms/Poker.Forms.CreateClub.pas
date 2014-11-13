unit Poker.Forms.CreateClub;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  cxContainer, cxLabel, cxTextEdit, cxButtons, Vcl.ActnList, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxEdit,
  dxSkinsCore, ChipUpPokerDarkSkin, Vcl.Menus, Vcl.StdCtrls;

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
    {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}

    procedure CSRCreateClub(const AMethodId: Integer; const AObject: TObject);
  protected
  public
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Server.Socket, Poker.Protobufs.Enum.ServerCodes, Poker.Server.Validators, Poker.Protobufs.Objects.ClubCommandReply,
  Poker.Server.MessageContainer, Poker.Server.Settings, Poker.Server.MessageCallbacks, Poker.Common.FormsContainer, Poker.Types,
  Poker.Common.Misc, Poker.Common.ModalDialogs;


procedure TfrmCreateClub.FormCreate(Sender: TObject);
begin
  {$IFDEF DEBUG} FDebugId := RegisterDebugObject(Name); {$ENDIF}

  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(srCreateClubReply, CSRCreateClub)
                  ]);

  edClubName.Properties.MaxLength := ServerSettings.MaxStringLengths.ClubName;
  edClubCode.Properties.MaxLength := ServerSettings.MaxStringLengths.ClubInvCode;
end;

procedure TfrmCreateClub.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);

  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}
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
        SelectNext(ActiveControl, TRUE, TRUE)
      else
        acOK.Execute;
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
    if not ValidateClubPassword(edClubCode.Text, error) then
      edClubCode.SetFocus;

  if error <> '' then
  begin
    ModalDialogs.ShowWarning(error);
    Exit;
  end;

  acOK.Enabled := FALSE;
  ServerSocket.CreateClub(edClubName.Text, edClubCode.Text, 5, 30);
end;


procedure TfrmCreateClub.CSRCreateClub(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_ClubCommandReply;
begin
  if not TTypes.TryCast<TPB_ClubCommandReply>(AObject, pbreply) then
    Exit;

  case pbreply.Status of
    csSuccess: begin
      ModalDialogs.ShowInformation(Format('Club created successfully!'#10'You can invite your friends to play in your club by providing them your club ID (%d) and password.', [pbreply.Club.Seq]));
      Close;
    end;
    csInvalidName: begin
      ModalDialogs.ShowWarning('Invalid club name');
      edClubName.SetFocus;
    end;
    csNameExists: begin
      ModalDialogs.ShowWarning('Club name already exists');
      edClubName.SetFocus;
    end;
    csInvalidPassword: begin
      ModalDialogs.ShowWarning('Invalid club password');
      edClubCode.SetFocus;
    end;
  else
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('CSRCreateClub: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
  end;

  acOK.Enabled := TRUE;
end;

end.
