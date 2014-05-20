unit Poker.Forms.Reconnect;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Poker.Interfaces.ModalForm, OverbyteIcsWSocket, Vcl.ExtCtrls, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, ChipUpPokerDarkSkin, cxLabel, cxProgressBar;

type
  TReconnectionStatus = (rsIdle, rsConnecting, rsConnected, rsHelloing, rsHelloOk, rsLoggingIn, rsLoggedIn, rsInvalidCredentials);

  TfrmReconnect = class(TForm, IModalForm)
    tiReconnectTimer: TTimer;
    lbsStatus: TcxLabel;
    pbReconnecting: TcxProgressBar;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tiReconnectTimerTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    const
      RED_COLOR = $00002ECC;
      GREEN_COLOR = clGreen;

    var
      FCloseCallback: TNotifyEvent;
      FCallbacksId: Integer;
      FCurrentStatus: TReconnectionStatus;
      FDots: Integer;

    procedure CSRHello(const AMethodId: Integer; const AObject: TObject);
    procedure CSRLogin(const AMethodId: Integer; const AObject: TObject);

    procedure HelloServer;

    procedure SocketStateChange(const AOldState, ANewState: TSocketState);
    procedure SetStatusMessage;

  protected
    procedure CreateParams(var AParams: TCreateParams); override;

  public
    procedure SetCloseCallback(const ACallback: TNotifyEvent);

    property CurrentStatus: TReconnectionStatus read FCurrentStatus;
  end;

var
  frmReconnect: TfrmReconnect;

implementation

{$R *.dfm}

uses
  Poker.Common.FormsContainer, Poker.Server.MessageContainer, Poker.Server.MessageCallbacks, Poker.Server.Socket, Poker.DataModule,
  Poker.Protobufs.Objects.HelloReply, Poker.Protobufs.Objects.LoginReply, Poker.Protobufs.Enum.ServerCodes, Poker.Server.Settings,
  Poker.Forms.Debug, Poker.Table.Tables, Poker.Forms.Main, Poker.Protobufs.Objects.UpdateFileInfo, System.Generics.Collections,
  Poker.Settings;

{ TfrmReconnect }

procedure TfrmReconnect.FormCreate(Sender: TObject);
begin
  FDots := 3;
  SetStatusMessage;

  FCallbacksId := MessageContainer.AddCallbacks([
                      TSocketStateChangeCallback.Create(SocketStateChange),
                      TServerMessageCallback.Create(srHello, CSRHello),
                      TServerMessageCallback.Create(srLoginReply, CSRLogin)
  ]);

  FCurrentStatus := rsIdle;
end;

procedure TfrmReconnect.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);
  FormsContainer.Remove(self);
end;

procedure TfrmReconnect.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.ExStyle := AParams.ExStyle or WS_EX_APPWINDOW;
  AParams.WndParent := 0;
end;

procedure TfrmReconnect.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  if Assigned(FCloseCallback) then
    FCloseCallback(self);
end;

procedure TfrmReconnect.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not (FCurrentStatus in [rsLoggingIn]);
end;

procedure TfrmReconnect.SetCloseCallback(const ACallback: TNotifyEvent);
begin
  FCloseCallback := ACallback;
end;

procedure TfrmReconnect.HelloServer;
var
  files: TObjectList<TPB_UpdateFileInfo>;
begin
  FCurrentStatus := rsHelloing;
  files := TObjectList<TPB_UpdateFileInfo>.Create(FALSE);
  try
    dmMain.GetUpdateFilesList(files);
    {$IFDEF DEBUG}
    ServerSocket.Hello(TRUE, files);
    {$ELSE}
    ServerSocket.Hello(FALSE, files);
    {$ENDIF};
  finally
    files.Free;
  end;
end;

procedure TfrmReconnect.SetStatusMessage;
var
  tmp: String;
  C1: Integer;
begin
  for C1 := 1 to FDots do
    tmp := tmp + '.';

  lbsStatus.Caption := 'Lost connection to server.'#10'Reconnecting' + tmp;
  lbsStatus.Refresh;
end;

procedure TfrmReconnect.tiReconnectTimerTimer(Sender: TObject);
begin
  if ServerSocket.Socket.State = wsClosed then
    FCurrentStatus := rsIdle;

  if FCurrentStatus = rsIdle then
  begin
    FCurrentStatus := rsConnecting;
    ServerSocket.Connect;
  end;

  if (CurrentStatus = rsConnected) and
     (ServerSocket.IsConnected) then
    HelloServer;

  if FDots = 3 then
    FDots := 0;
  Inc(FDots);
  SetStatusMessage;
end;

procedure TfrmReconnect.SocketStateChange(const AOldState, ANewState: TSocketState);
begin
  case ANewState of
    wsOpened,
    wsBound,
    wsConnecting: begin
      FCurrentStatus := rsConnecting;
      pbReconnecting.Properties.BeginColor := RED_COLOR;
    end;
    wsConnected: begin
      pbReconnecting.Properties.BeginColor := GREEN_COLOR;
      FCurrentStatus := rsConnected;
    end;
    wsClosed: begin
      FCurrentStatus := rsIdle;
      ServerSocket.Disconnect;
      pbReconnecting.Properties.BeginColor := RED_COLOR;
    end;
  end;
end;

procedure TfrmReconnect.CSRHello(const AMethodId: Integer; const AObject: TObject);
var
  pbhello: TPB_HelloReply;
begin
  pbhello := AObject as TPB_HelloReply;

  FCurrentStatus := rsHelloOk;

  ServerSettings.ParseHelloMessage(pbhello);

  if ServerSocket.IsConnected then
  begin
    FCurrentStatus := rsLoggingIn;
    ServerSocket.Login(dmMain.SelfInfo.Nick, dmMain.SelfInfo.Password);
  end
  else
    ServerSocket.Disconnect;
end;

procedure TfrmReconnect.CSRLogin(const AMethodId: Integer; const AObject: TObject);
var
  pbreply: TPB_LoginReply;
begin
  pbreply := AObject as TPB_LoginReply;

  case pbreply.LoginStatus of
    lrSuccess: begin
      dmMain.ProcessStatusProtobuf(pbreply.Status);
      dmMain.ProcessReconnectedTables(pbreply.ReconnectTables);
      FCurrentStatus := rsLoggedIn;
      FormsContainer.ResetState;
      Tables.EnableAll;
      ServerSocket.Ping;
      Close;
    end;
    lrInvalid: begin
      FCurrentStatus := rsInvalidCredentials;
      Close;
    end;
  else
    {$IFDEF DEBUG} DebugLn(Format('CSRLogin: invalid status received [%d]]', [Integer(pbreply.Status)]), ditException); {$ENDIF}
  end;
end;

end.
