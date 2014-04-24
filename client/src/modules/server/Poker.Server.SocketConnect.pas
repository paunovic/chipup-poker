unit Poker.Server.SocketConnect;

interface

uses
  System.Classes;

type
  TSocketConnectThread = class(TThread)
  private
    FServerSocket: TObject;
    FOnConnectFailed: TNotifyEvent;

    procedure syncConnectFailed;

  protected
    procedure Execute; override;
  public
    constructor Create(const AServerSocket: TObject);

    procedure Shutdown;

    property OnConnectFailed: TNotifyEvent read FOnConnectFailed write FOnConnectFailed;
  end;

implementation

uses
  System.SysUtils, Poker.Server.Socket, Poker.Forms.Debug;

{ TSocketConnectThread }

constructor TSocketConnectThread.Create(const AServerSocket: TObject);
begin
  inherited Create(TRUE);
  FreeOnTerminate := TRUE;
  FServerSocket := AServerSocket;
end;

procedure TSocketConnectThread.Execute;
var
  server_socket: TServerSocket;
begin
  if not Assigned(FServerSocket) then
    Exit;

  server_socket := FServerSocket as TServerSocket;

  try
    server_socket.Socket.Connect;
  except
    on E: Exception do
    begin
      {$IFDEF DEBUG} DebugLn(Format('Error connecting to server: ', [E.Message]), ditException); {$ENDIF}
      if Assigned(FOnConnectFailed) then
        Synchronize(syncConnectFailed);
    end;
  end;
end;

procedure TSocketConnectThread.Shutdown;
begin
  Terminate;
  WaitFor;
end;

procedure TSocketConnectThread.syncConnectFailed;
begin
  FOnConnectFailed(self);
end;

end.
