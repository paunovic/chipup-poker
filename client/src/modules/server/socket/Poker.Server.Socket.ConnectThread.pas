unit Poker.Server.Socket.ConnectThread;

interface

uses
  System.Classes, OverbyteIcsWSocket;

type
  TServerSocketConnectThread = class(TThread)
  private
    FSocket: TSslWSocket;
  protected
    procedure Execute; override;
  public
    constructor Create(const ASocket: TSslWSocket);
  end;

implementation

{ TServerSocketConnectThread }

constructor TServerSocketConnectThread.Create(const ASocket: TSslWSocket);
begin
  inherited Create(TRUE);

  FSocket := ASocket;
end;

procedure TServerSocketConnectThread.Execute;
begin
  NameThreadForDebugging('ServerSocketConnectThread');

  FSocket.Connect;
end;

end.
