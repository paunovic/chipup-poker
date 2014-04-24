unit Poker.Server.Socket;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.SysUtils, OverbyteIcsWndControl, System.Generics.Collections, OverbyteIcsWSocket,
  Poker.Protobufs.Objects.RpcMessage, Poker.Protobufs.Objects.Base, Poker.Protobufs.Enum.ServerCodes, Poker.Protobufs.Objects.Game,
  Poker.Protobufs.Objects.ContactMessage, Poker.Server.SocketConnect;

type
  TServerSocket = class
  private
    const
      TIMER_ID_PING         = 1;
      TIMER_ID_PING_TIMEOUT = 2;

    var
      FSocket                : TSslWSocket;
      FSocketConnectThread   : TSocketConnectThread;
      FServer                : String;
      FPort                  : Integer;
      FConnectCode           : Integer;
      FReceiveBuffer         : PAnsiChar;
      FReceiveBufferSize     : Integer;
      FInternalMessageHandler: HWND;
      FLatency               : Integer;
      FServerTime            : UINT64;
      FTimeOffset            : UINT64;

    procedure WndMethod(var AMessage: TMessage);

    procedure ConnectThreadTerminated(Sender: TObject);
    procedure ConnectThreadConnectFailed(Sender: TObject);

    procedure SocketSessionConnected(Sender: TObject; ErrCode: Word);
    procedure SocketSessionClosed(Sender: TObject; ErrCode: Word);
    procedure SocketSslHandshakeDone(Sender: TObject; ErrCode: Word; PeerCert: TX509Base; var Disconnect: Boolean);
    procedure SocketSslVerifyPeer(Sender: TObject; var Ok: Integer; Cert: TX509Base);
    procedure SocketChangeState(Sender: TObject; OldState, NewState: TSocketState);
    procedure SocketDataAvailable(Sender: TObject; Error: Word);
    procedure SocketError(Sender: TObject);

    function ParseRpcMessage(const ARpcMessage: TPB_RpcMessage; const ADataPointer: pointer; out ADataObject: TObject): Boolean;

    procedure ResetPingTimeoutTimer;
    procedure ResetPingTimer;
    procedure KillPingTimer;
    procedure KillPingTimeoutTimer;

  public
    class procedure Initialize(const AServer: String; const APort: Integer);
    class procedure Deinitialize;

    constructor Create(const AServer: String; const APort: Integer);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    function IsConnected: Boolean;

    procedure SendProtobuf(const AMethodId: TServerCodes; const AProtobuf: TProtobufBaseObject);
    procedure SendRawBytes(const AMethodId: TServerCodes; const AProtobuf; const ASize: Integer);

    procedure Login(const ALogin, APass: String);
    procedure Logout;
    procedure CreateAccount(const AUsername, APassword, AEMail: String);
    procedure ForgotPassword(const AEMail: String);
    procedure Status;
    procedure CreateClub(const AName, AInvCode: String; const AClubRake: Integer);
    procedure JoinClub(const AId: Int64; const ACode: String);
    procedure LeaveClub(const AId: Int64);
    procedure KickPlayer(const AClubId: Int64; const APlayerId: TBytes);
    procedure GiveOwnership(const AClubId: Int64; const APlayerId: TBytes);
    procedure ChangeClubDetails(const AClubId: Int64; const AClubName, AClubCode: String; const AClubRake: Integer);
    procedure DisbandClub(const AClubId: Int64);
    procedure TransferChips(const APlayerId: TBytes; const AChipAmount: Integer);
    procedure ChangeEMail(const ANewMail: String);
    procedure ChangePassword(const APassword: String);
    procedure SetAvatar(const AAvatarId: TBytes);
    procedure CreateGame(const AClubId: Int64; const AGameName: String; const AGameType: TGameType; const AGameLimit: TGameLimit; const ASmallBlind, ABigBlind, ABuyinMin, ABuyinMax, ASeats: Integer);
    procedure CloseGame(const AGameId: TBytes; const ASeconds: UINT32);
    procedure EditGame(const AGameId: TBytes; const AGameName: String; const AGameType: TGameType; const AGameLimit: TGameLimit; const ASmallBlind, ABigBlind, ABuyinMin, ABuyinMax, ASeats: Integer);
    procedure SendTableChatLine(const AGameId: TBytes; const ALine: String);
    procedure JoinTable(const AGameId: TBytes);
    procedure LeaveTable(const AGameId: TBytes);
    procedure TableSit(const AGameId: TBytes; const ASeatIndex, AChips: Integer);
    procedure TableAddOn(const AGameId: TBytes; const AChips: Integer);
    procedure TableStandUp(const AGameId: TBytes);
    procedure TablePlayNow(const AGameId: TBytes);
    procedure TableSitOutNextHand(const AGameId: TBytes; const AFlag: Boolean);
    procedure TableSitOutNextBB(const AGameId: TBytes; const AFlag: Boolean);
    procedure Ping;
    procedure ChangePlayerSuspendState(const AClubId, APlayerId: TBytes; const ASuspended: Boolean);
    procedure GetUserInfos(const AMongoIds: TArray<TBytes>);
    procedure Fold(const AGameId: TBytes);
    procedure PutChips(const AGameId: TBytes; const AChipAmount: Integer);
    procedure TableBoolFlag(const ACommand: TServerCodes; const AGameId: TBytes; const AFlag: Boolean);
    procedure ResendVerificationMail;
    procedure ShowCards(const AGameId: TBytes);
    procedure QueryTableStats(const ATables: array of TBytes);
    procedure ContactUs(const AReason: TContactReason; const AMessage: String);

    property Server: String read FServer;
    property Socket: TSslWSocket read FSocket;
    property Latency: Integer read FLatency;
    property ServerTime: UINT64 read FServerTime;
    property TimeOffset: UINT64 read FTimeOffset;
  end;

var
  ServerSocket: TServerSocket;

implementation

uses
  Winapi.WinSock, Poker.Settings, Poker.Common.Misc, pbOutput, Poker.Server.MessageContainer,
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Protobufs.Objects.LoginParams, Poker.Protobufs.Objects.StatusReply, Poker.Protobufs.Objects.HelloReply,
  Poker.Protobufs.Objects.RegisterParams, Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.ChangeEMailParams,
  Poker.Protobufs.Objects.ForgotPasswordParams, Poker.Protobufs.Objects.ListClubsReply, Poker.Protobufs.Objects.TransferChipsParams,
  Poker.Protobufs.Objects.ClubCommandReply, Poker.Protobufs.Objects.SetAvatarReply, Poker.Protobufs.Objects.KickPlayerParams,
  Poker.Protobufs.Objects.PingParams, Poker.Protobufs.Objects.PingReply, Poker.Protobufs.Objects.GiveClubOwnershipParams,
  Poker.Protobufs.Objects.ChangePasswordParams, Poker.Protobufs.Objects.RegisterReply, Poker.Protobufs.Objects.LoginReply,
  Poker.Protobufs.Objects.GetUserParams, Poker.Protobufs.Objects.SetAvatarParams, Poker.Protobufs.Objects.ChatEvent,
  Poker.Protobufs.Objects.ChatMessage, Poker.Protobufs.Objects.TableSit, Poker.Protobufs.Objects.TableStatus,
  Poker.Protobufs.Objects.ChangeSuspendState, Poker.Protobufs.Objects.ChangeMailReply, Poker.Protobufs.Objects.TableBoolFlag,
  Poker.Protobufs.Objects.PutChips, Poker.Protobufs.Objects.User, Poker.Protobufs.Objects.UserChangeParams,
  Poker.Protobufs.Objects.CloseGameData, Poker.Protobufs.Objects.QueryTableStats, Poker.Protobufs.Objects.TableStatsReplies,
  Poker.Server.SSLCerts;


class procedure TServerSocket.Initialize(const AServer: String; const APort: Integer);
begin
  ServerSocket := TServerSocket.Create(AServer, APort);
end;

class procedure TServerSocket.Deinitialize;
begin
  FreeAndNil(ServerSocket);
end;

constructor TServerSocket.Create(const AServer: String; const APort: Integer);
begin
  FConnectCode := -1;
  FServer := AServer;
  FPort := APort;

  FInternalMessageHandler := AllocateHWnd(WndMethod);

  FSocket := TSslWSocket.Create(nil);
  FSocket.SslContext := TSslContext.Create(nil);
  FSocket.SslContext.SslVerifyPeer := TRUE;
  FSocket.SslContext.SslVerifyDepth := 1;
  FSocket.SslContext.SslVerifyFlags := [sslX509_V_FLAG_CRL_CHECK_ALL];
  FSocket.SslContext.SslVerifyPeerModes := [SslVerifyMode_FAIL_IF_NO_PEER_CERT];
  FSocket.SslContext.SslSessionCacheModes := [sslSESS_CACHE_CLIENT];
  FSocket.SslContext.SslVersionMethod := sslV3;
  FSocket.SslContext.InitContext;
  FSocket.SslContext.TrustCert(SSLCert_Server);
end;

destructor TServerSocket.Destroy;
begin
  {$IFDEF DEBUG} DebugLn('TServerSocket.Destroy', ditSocket); {$ENDIF}

  if IsConnected then
    Disconnect;

  FSocket.SslContext.DeInitContext;
  FSocket.SslContext.Free;
  FSocket.Free;

  DeallocateHWnd(FInternalMessageHandler);

  inherited;
end;

procedure TServerSocket.Connect;
begin
  {$IFDEF DEBUG} DebugLn(Format('Connecting to %s:%d...', [FServer, FPort]), ditSocket); {$ENDIF}

  FReceiveBufferSize := 0;
  FSocket.Addr := FServer;
  FSocket.Port := IntToStr(FPort);
  FSocket.TimeoutConnect := 10000;
  FSocket.SslEnable := TRUE;
  FSocket.OnChangeState := SocketChangeState;
  FSocket.OnDataAvailable := SocketDataAvailable;
  FSocket.OnError := SocketError;
  FSocket.OnSessionConnected := SocketSessionConnected;
  FSocket.OnSessionClosed := SocketSessionClosed;
  FSocket.OnSslVerifyPeer := SocketSslVerifyPeer;
  FSocket.OnSslHandshakeDone := SocketSslHandshakeDone;

  ResetPingTimer;

  if Assigned(FSocketConnectThread) then
  begin
    FSocketConnectThread.Shutdown;
    FreeAndNil(FSocketConnectThread);
  end;

  FSocketConnectThread := TSocketConnectThread.Create(self);
  FSocketConnectThread.OnTerminate := ConnectThreadTerminated;
  FSocketConnectThread.OnConnectFailed := ConnectThreadConnectFailed;
  FSocketConnectThread.Start;
end;

procedure TServerSocket.ConnectThreadConnectFailed(Sender: TObject);
begin
  SocketError(Sender);
end;

procedure TServerSocket.ConnectThreadTerminated(Sender: TObject);
begin
  FSocketConnectThread := nil;
end;

procedure TServerSocket.Disconnect;
begin
  KillPingTimer;
  KillPingTimeoutTimer;

  if Assigned(FSocketConnectThread) then
  begin
    FSocketConnectThread.Shutdown;
    FreeAndNil(FSocketConnectThread);
  end;

  if FSocket.State <> TSocketState.wsClosed then
  begin
    {$IFDEF DEBUG} DebugLn('Closing socket...', ditSocket); {$ENDIF}
    FSocket.CloseDelayed;
{    while (Assigned(FSocket)) and (FSocket.State <> wsClosed) do // FIXME
      FSocket.ProcessMessages;}
  end;
end;

procedure TServerSocket.SocketSessionConnected(Sender: TObject; ErrCode: Word);
begin
  if ErrCode = 0 then
  begin
    {$IFDEF DEBUG} DebugLn('Starting SSL handshake...', ditSocket); {$ENDIF}
    FSocket.StartSslHandshake;
  end
  else
  begin
    FSocket.LastError := ErrCode;
    SocketError(Sender);
  end;
end;

procedure TServerSocket.SocketSessionClosed(Sender: TObject; ErrCode: Word);
begin
  {$IFDEF DEBUG} DebugLn(Format('Session closed [%d]', [ErrCode]), ditException); {$ENDIF}

  FSocket.Flush;

  if FReceiveBufferSize > 0 then
  begin
    FreeMem(FReceiveBuffer, FReceiveBufferSize);
    FReceiveBufferSize := 0;
  end;

  FConnectCode := -1;

  KillPingTimer;
  KillPingTimeoutTimer;
end;

procedure TServerSocket.SocketSslHandshakeDone(Sender: TObject; ErrCode: Word; PeerCert: TX509Base; var Disconnect: Boolean);
begin
  if ErrCode = 0 then
  begin
    {$IFDEF DEBUG} DebugLn('SSL handshake completed successfully', ditSocket); {$ENDIF}
  end
  else
  begin
    FSocket.LastError := ErrCode;
    SocketError(Sender);
  end;
end;

procedure TServerSocket.SocketSslVerifyPeer(Sender: TObject; var Ok: Integer; Cert: TX509Base);
begin
  {$IFDEF DEBUG} DebugLn(Format('SSL verify peer result: %d', [Ok]), ditSocket); {$ENDIF}
end;

procedure TServerSocket.SocketDataAvailable(Sender: TObject; Error: Word);
const
  BUFFER_SIZE = 16 * 1024;
var
  len        : Integer;
  rcv_buf    : array[0..BUFFER_SIZE - 1] of AnsiChar;
  rpc_size   : Word;
  rpc_message: TPB_RpcMessage;
  data_obj   : TObject;
  ptmp       : pointer;
begin
  if Error <> 0 then
  begin
    FSocket.LastError := Error;
    SocketError(Sender);
    Exit;
  end;

  len := FSocket.Receive(@rcv_buf[0], FSocket.RcvdCount);

  if len < 0 then
  begin
    FSocket.LastError := WSAGetLastError;
    SocketError(Sender);
  end
  else
  begin
    Inc(FReceiveBufferSize, len);
    ReallocMem(FReceiveBuffer, FReceiveBufferSize);
    Move(rcv_buf, FReceiveBuffer[FReceiveBufferSize - len], len);
  end;

  if FReceiveBufferSize = 0 then
    Exit;

  rpc_size := PWord(FReceiveBuffer)^;
  if FReceiveBufferSize < SizeOf(rpc_size) + rpc_size then
    Exit;

  rpc_message := TPB_RpcMessage.Create(pointer(Integer(FReceiveBuffer) + SizeOf(rpc_size)), rpc_size);
  try
    if (rpc_size + SizeOf(rpc_size) + rpc_message.DataSize > FReceiveBufferSize) then
      Exit;

    if ParseRpcMessage(rpc_message, pointer(Integer(FReceiveBuffer) + SizeOf(rpc_size) + rpc_size), data_obj) then
    begin
      {$IFDEF DEBUG}
      if rpc_message.DataSize = 0 then
        DebugLn(Format('Method: %s', [TranslateServerCode(rpc_message.MethodId)]), ditSocketInc)
      else
        DebugLn(Format('Method: %s; DataSize: %d', [TranslateServerCode(rpc_message.MethodId), rpc_message.DataSize]), ditSocketInc);
      {$ENDIF}
      ResetPingTimer;

      PostMessage(MessageContainer.ReceiverWnd, MessageContainer.ServerReplyMsg, WPARAM(pointer(data_obj)), LPARAM(rpc_message.MethodId));
    end;

    ptmp := pointer(Integer(FReceiveBuffer) + SizeOf(rpc_size) + rpc_size + rpc_message.DataSize);
    Dec(FReceiveBufferSize, SizeOf(rpc_size) + rpc_size + rpc_message.DataSize);
    Move(ptmp^, FReceiveBuffer, FReceiveBufferSize);
    ReallocMem(FReceiveBuffer, FReceiveBufferSize);
  finally
    rpc_message.Free;
  end;
end;

procedure TServerSocket.SocketChangeState(Sender: TObject; OldState, NewState: TSocketState);
begin
  case NewState of
    wsInvalidState: ;
    wsOpened: ;
    wsBound: ;
    wsConnecting: ;
    wsSocksConnected: ;
    wsConnected: ;
    wsAccepting: ;
    wsListening: ;
    wsClosed: ;
  end;

  PostMessage(MessageContainer.ReceiverWnd, MessageContainer.SocketStateChangeMsg, WPARAM(OldState), LPARAM(NewState));
end;


procedure TServerSocket.SocketError(Sender: TObject);
begin
  {$IFDEF DEBUG} DebugLn(Format('Socket error: %s', [WSocketErrorDesc(FSocket.LastError)]), ditException); {$ENDIF}

  case FSocket.State of
    wsConnected: ;
    wsClosed: ;
  else
    Disconnect;
  end;
end;

procedure TServerSocket.ResetPingTimer;
begin
  SetTimer(FInternalMessageHandler, TIMER_ID_PING, Settings.Hardcoded.TCP_PING_INTERVAL * 1000, nil);
end;

procedure TServerSocket.ResetPingTimeoutTimer;
begin
  SetTimer(FInternalMessageHandler, TIMER_ID_PING_TIMEOUT, Settings.Hardcoded.TCP_PING_TIMEOUT * 1000, nil);
end;

procedure TServerSocket.KillPingTimer;
begin
  KillTimer(FInternalMessageHandler, TIMER_ID_PING);
end;

procedure TServerSocket.KillPingTimeoutTimer;
begin
  KillTimer(FInternalMessageHandler, TIMER_ID_PING_TIMEOUT);
end;

procedure TServerSocket.WndMethod(var AMessage: TMessage);
begin
  case AMessage.Msg of
    WM_TIMER: case AMessage.WParam of
                TIMER_ID_PING: begin
                  Ping;
                  KillPingTimer;
                  ResetPingTimeoutTimer;
                end;

                TIMER_ID_PING_TIMEOUT: begin
                  {$IFDEF DEBUG} DebugLn('Ping timeout', ditException); {$ENDIF}
                  KillPingTimeoutTimer;
                  Disconnect;
                end;
              end;
  end;
end;

function TServerSocket.IsConnected: Boolean;
begin
  result := (Assigned(FSocket)) and (FSocket.State = wsConnected) and (FConnectCode = Integer(srHello));
end;

function TServerSocket.ParseRpcMessage(const ARpcMessage: TPB_RpcMessage; const ADataPointer: pointer; out ADataObject: TObject): Boolean;
var
  err     : String;
  sc      : TServerCodes;
  valid_sc: Boolean;
  gtc     : DWORD;
begin
  if FConnectCode = -1 then
    FConnectCode := ARpcMessage.MethodId;

  ADataObject := nil;
  result := TRUE;
  valid_sc := FALSE;
  for sc := Low(TServerCodes) to High(TServerCodes) do
    if ARpcMessage.MethodId = Integer(sc) then
    begin
      valid_sc := TRUE;
      Break;
    end;

  if not valid_sc then
  begin
    result := FALSE;
    {$IFDEF DEBUG} DebugLn(Format('Invalid MethodId received: %d', [ARpcMessage.MethodId]), ditException); {$ENDIF}
    Exit;
  end;

  case TServerCodes(ARpcMessage.MethodId) of
    srNotImplemented: begin
      SetString(err, PAnsiChar(ADataPointer), ARpcMessage.DataSize);
      {$IFDEF DEBUG} DebugLn(Format('Received NOT_IMPLEMENTED MethodId: %s', [err]), ditException); {$ENDIF}
    end;
    srLoginReply: ADataObject := TPB_LoginReply.Create(ADataPointer, ARpcMessage.DataSize);
    srLogout: ;
    srRegisterReply: ADataObject := TPB_RegisterReply.Create(ADataPointer, ARpcMessage.DataSize);
    srChangePasswordOk: ;
    seSecondaryLoginDetected: ;
    seAccountConfirmed: ADataObject := TPB_User.Create(ADataPointer, ARpcMessage.DataSize);
    srTransferChipsInvalidAmount: ;

    seTransferChips,
    srTransferChipsOk: ADataObject := TPB_TransferChipsParams.Create(ADataPointer, ARpcMessage.DataSize);
    srGetPlayers: ADataObject := TPB_GetUserParams.Create(ADataPointer, ARpcMessage.DataSize);
    srChangeMailReply: ADataObject := TPB_ChangeMailReply.Create(ADataPointer, ARpcMessage.DataSize);
    srSetAvatarReply: ADataObject := TPB_SetAvatarReply.Create(ADataPointer, ARpcMessage.DataSize);
    srCreateClubReply,
    srJoinClubReply,
    srLeaveClubReply,
    srChangeClubDetailsReply,
    srKickPlayerReply: ADataObject := TPB_ClubCommandReply.Create(ADataPointer, ARpcMessage.DataSize);

    srHello: ADataObject := TPB_HelloReply.Create(ADataPointer, ARpcMessage.DataSize);
    srListClubs: ADataObject := TPB_ListClubsReply.Create(ADataPointer, ARpcMessage.DataSize);
    srStatus: ADataObject := TPB_StatusReply.Create(ADataPointer, ARpcMessage.DataSize);
    srTableSitNoChips,
    srTableAddonOverLimit,
    seTableStatus,
    srTableSitOk,
    srTableSitSeatTaken,
    srTableAddonOk,
    srTableStandUpOk: ADataObject := TPB_TableStatus.Create(ADataPointer, ARpcMessage.DataSize);
    srPong: begin
      gtc := GetTickCount;
      ADataObject := TPB_PingReply.Create(ADataPointer, ARpcMessage.DataSize);
      FLatency := gtc - (ADataObject as TPB_PingReply).Uptime;
      FServerTime := (ADataObject as TPB_PingReply).Servertime + FLatency div 2;
      FTimeOffset := FServerTime - gtc;

      {$IFDEF DEBUG}
      DebugLn(Format('LATENCY: %dms', [FLatency]), ditApplication);
      {$ENDIF}

      KillPingTimeoutTimer;
      ResetPingTimer;
    end;
    seChat: ADataObject := TPB_ChatEvent.Create(ADataPointer, ARpcMessage.DataSize);
    srClubDisbandOk,
    srOwnershipGiveAwayNotOwner,
    srOwnershipGiveawayInvalidPlayerId,
    srOwnershipGiveAwayInvalidClubId,
    srOwnershipGiveAwayOk,
    srSuspendPlayerOk,
    srReinstatePlayerOk,
    seClubChange,
    seClubDeleted: ADataObject := TPB_Club.Create(ADataPointer, ARpcMessage.DataSize);
    srEditGameOk,
    srCreateGameOk,
    srDeleteGameOk,
    seGameChange,
    seGameCreate,
    seGameDelete: ADataObject := TPB_Game.Create(ADataPointer, ARpcMessage.DataSize);
    seUserChange: ADataObject := TPB_UserChangeParams.Create(ADataPointer, ARpcMessage.DataSize);
    srTableStatsReply: ADataObject := TPB_TableStatsReplies.Create(ADataPointer, ARpcMessage.DataSize);
    srContactUsOk: ADataObject := TPB_ContactMessage.Create(ADataPointer, ARpcMessage.DataSize);
  else
    result := FALSE;
    {$IFDEF DEBUG} DebugLn(Format('Unhandled MethodId received: %d', [ARpcMessage.MethodId]), ditException); {$ENDIF}
  end;
end;

procedure TServerSocket.SendRawBytes(const AMethodId: TServerCodes; const AProtobuf; const ASize: Integer);
var
  rpc_message: TPB_RpcMessage;
  mstream    : TMemoryStream;
  rpcsize    : Word;
begin
  rpc_message := TPB_RpcMessage.Create;
  try
    rpc_message.MethodId := Integer(AMethodId);
    if ASize > 0 then
      rpc_message.DataSize := ASize;
    mstream := TMemoryStream.Create;
    try
      rpcsize := rpc_message.ProtobufOutputSize;
      mstream.WriteBuffer(rpcsize, SizeOf(rpcsize));
      rpc_message.ProtobufOutput.SaveToStream(mstream);
      if ASize > 0 then
        mstream.Write(AProtobuf, rpc_message.DataSize);

      {$IFDEF DEBUG} DebugLn(Format('Method: %s; DataSize: %d; StreamSize: %d', [TranslateServerCode(rpc_message.MethodId), ASize, mstream.Size]), ditSocketOut); {$ENDIF}
      FSocket.Send(mstream.Memory, mstream.Size);
    finally
      mstream.Free;
    end;
  finally
    rpc_message.Free;
  end;
end;

procedure TServerSocket.SendProtobuf(const AMethodId: TServerCodes; const AProtobuf: TProtobufBaseObject);
var
  rpc_message: TPB_RpcMessage;
  mstream    : TMemoryStream;
  rpcsize    : Word;
begin
  rpc_message := TPB_RpcMessage.Create;
  try
    rpc_message.Methodid := Integer(AMethodId);
    if Assigned(AProtobuf) then
      rpc_message.Datasize := AProtobuf.ProtobufOutputSize;
    mstream := TMemoryStream.Create;
    try
      rpcsize := rpc_message.ProtobufOutputSize;
      mstream.WriteBuffer(rpcsize, SizeOf(rpcsize));
      rpc_message.ProtobufOutput.SaveToStream(mstream);
      if rpc_message.Datasize > 0 then
        AProtobuf.ProtobufOutput.SaveToStream(mstream);

      {$IFDEF DEBUG} DebugLn(Format('Method: %s; DataSize: %d; StreamSize: %d', [TranslateServerCode(rpc_message.MethodId), rpc_message.DataSize, mstream.Size]), ditSocketOut); {$ENDIF}
      FSocket.Send(mstream.Memory, mstream.Size);
    finally
      mstream.Free;
    end;
  finally
    rpc_message.Free;
  end;
end;

procedure TServerSocket.Login(const ALogin, APass: String);
var
  protobuf: TPB_LoginParams;
begin
  protobuf := TPB_LoginParams.Create;
  try
    protobuf.Username := ALogin;
    protobuf.Password := APass;
    SendProtobuf(scLogin, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.Logout;
begin
  SendProtobuf(scLogout, nil);
end;

procedure TServerSocket.CreateAccount(const AUsername, APassword, AEMail: String);
var
  protobuf: TPB_RegisterParams;
begin
  protobuf := TPB_RegisterParams.Create;
  try
    protobuf.Email := AEMail;
    protobuf.Password := APassword;
    protobuf.DisplayName := AUsername;
    SendProtobuf(scRegister, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.ForgotPassword(const AEMail: String);
var
  protobuf: TPB_ForgotPasswordParams;
begin
  protobuf := TPB_ForgotPasswordParams.Create;
  try
    protobuf.Email := AEMail;
    SendProtobuf(scForgotPassword, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.Status;
begin
  SendProtobuf(scStatus, nil);
end;

procedure TServerSocket.CreateClub(const AName, AInvCode: String; const AClubRake: Integer);
var
  protobuf: TPB_Club;
begin
  protobuf := TPB_Club.Create;
  try
    protobuf.Name := AName;
    protobuf.Password := AInvCode;
    protobuf.Rake := AClubRake;
    SendProtobuf(scCreateClub, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.JoinClub(const AId: Int64; const ACode: String);
var
  protobuf: TPB_Club;
begin
  protobuf := TPB_Club.Create;
  try
    protobuf.Seq := AId;
    protobuf.Password := ACode;
    SendProtobuf(scJoinClub, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.KickPlayer(const AClubId: Int64; const APlayerId: TBytes);
var
  protobuf: TPB_KickPlayerParams;
begin
  protobuf := TPB_KickPlayerParams.Create;
  try
    protobuf.ClubSeq := AClubId;
    protobuf.PlayerMongoId := APlayerId;
    SendProtobuf(scKickPlayer, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.LeaveClub(const AId: Int64);
var
  protobuf: TPB_Club;
begin
  protobuf := TPB_Club.Create;
  try
    protobuf.Seq := AId;
    SendProtobuf(scLeaveClub, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.GiveOwnership(const AClubId: Int64; const APlayerId: TBytes);
var
  protobuf: TPB_GiveClubOwnershipParams;
begin
  protobuf := TPB_GiveClubOwnershipParams.Create;
  try
    protobuf.ClubSeq := AClubId;
    protobuf.PlayerMongoId := APlayerId;
    SendProtobuf(scGiveClubOwnership, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.ChangeClubDetails(const AClubId: Int64; const AClubName, AClubCode: String; const AClubRake: Integer);
var
  protobuf: TPB_Club;
begin
  protobuf := TPB_Club.Create;
  try
    protobuf.Seq := AClubId;
    protobuf.Name := AClubName;
    protobuf.Password := AClubCode;
    protobuf.Rake := AClubRake;
    SendProtobuf(scChangeClubDetails, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.DisbandClub(const AClubId: Int64);
var
  protobuf: TPB_Club;
begin
  protobuf := TPB_Club.Create;
  try
    protobuf.Seq := AClubId;
    SendProtobuf(scDeleteClub, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.TransferChips(const APlayerId: TBytes; const AChipAmount: Integer);
var
  protobuf: TPB_TransferChipsParams;
begin
  protobuf := TPB_TransferChipsParams.Create;
  try
    protobuf.PlayerMongoId := APlayerId;
    protobuf.ChipAmount := AChipAmount;
    SendProtobuf(scTransferChips, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.ChangeEMail(const ANewMail: String);
var
  protobuf: TPB_ChangeEMailParams;
begin
  protobuf := TPB_ChangeEMailParams.Create;
  try
    protobuf.NewMail := ANewMail;
    SendProtobuf(scChangeEmail, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.ChangePassword(const APassword: String);
var
  protobuf: TPB_ChangePasswordParams;
begin
  protobuf := TPB_ChangePasswordParams.Create;
  try
    protobuf.NewPassword := APassword;
    SendProtobuf(scChangePassword, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.SetAvatar(const AAvatarId: TBytes);
var
  protobuf: TPB_SetAvatarParams;
begin
  protobuf := TPB_SetAvatarParams.Create;
  try
    protobuf.AvatarId := AAvatarId;
    SendProtobuf(scSetAvatar, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.CreateGame(const AClubId: Int64; const AGameName: String; const AGameType: TGameType; const AGameLimit: TGameLimit; const ASmallBlind, ABigBlind, ABuyinMin, ABuyinMax, ASeats: Integer);
var
  protobuf: TPB_Game;
begin
  protobuf := TPB_Game.Create;
  try
    protobuf.Gamename := AGameName;
    protobuf.Clubseq := AClubId;
    protobuf.GameType := AGameType;
    protobuf.GameLimit := AGameLimit;
    protobuf.SmallBlind := ASmallBlind;
    protobuf.BigBlind := ABigBlind;
    protobuf.BuyinMin := ABuyinMin;
    protobuf.BuyinMax := ABuyinMax;
    protobuf.Seats := ASeats;
    SendProtobuf(scCreateGame, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.CloseGame(const AGameId: TBytes; const ASeconds: UINT32);
var
  protobuf: TPB_CloseGameData;
begin
  protobuf := TPB_CloseGameData.Create;
  try
    protobuf.Gameid := AGameId;
    protobuf.Timestamp := ASeconds;
    SendProtobuf(scCloseGame, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.EditGame(const AGameId: TBytes; const AGameName: String; const AGameType: TGameType; const AGameLimit: TGameLimit; const ASmallBlind, ABigBlind, ABuyinMin, ABuyinMax, ASeats: Integer);
var
  protobuf: TPB_Game;
begin
  protobuf := TPB_Game.Create;
  try
    protobuf.MongoId := AGameId;
    protobuf.Gamename := AGameName;
    protobuf.GameType := AGameType;
    protobuf.GameLimit := AGameLimit;
    protobuf.SmallBlind := ASmallBlind;
    protobuf.BigBlind := ABigBlind;
    protobuf.BuyinMin := ABuyinMin;
    protobuf.BuyinMax := ABuyinMax;
    protobuf.Seats := ASeats;
    SendProtobuf(scEditGame, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.SendTableChatLine(const AGameId: TBytes; const ALine: String);
var
  protobuf: TPB_ChatEvent;
  pbmsg   : TPB_ChatMessage;
begin
  protobuf := TPB_ChatEvent.Create;
  try
    protobuf.Event := ceUserMessage;
    protobuf.TableId := AGameId;
    pbmsg := TPB_ChatMessage.Create;
    pbmsg.Msg := ALine;
    protobuf.Msg := pbmsg;
    SendProtobuf(seChat, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.JoinTable(const AGameId: TBytes);
var
  protobuf: TPB_Game;
begin
  protobuf := TPB_Game.Create;
  try
    protobuf.MongoId := AGameId;
    SendProtobuf(scTableJoin, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.LeaveTable(const AGameId: TBytes);
var
  protobuf: TPB_Game;
begin
  protobuf := TPB_Game.Create;
  try
    protobuf.MongoId := AGameId;
    SendProtobuf(scTableLeave, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.TableSit(const AGameId: TBytes; const ASeatIndex, AChips: Integer);
var
  protobuf: TPB_TableSit;
begin
  protobuf := TPB_TableSit.Create;
  try
    protobuf.GameId := AGameId;
    protobuf.SeatIndex := ASeatIndex;
    protobuf.Chips := AChips;
    SendProtobuf(scTableSit, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.TableAddOn(const AGameId: TBytes; const AChips: Integer);
var
  protobuf: TPB_TableSit;
begin
  protobuf := TPB_TableSit.Create;
  try
    protobuf.GameId := AGameId;
    protobuf.Chips := AChips;
    SendProtobuf(scTableAddOn, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.TableStandUp(const AGameId: TBytes);
var
  protobuf: TPB_Game;
begin
  protobuf := TPB_Game.Create;
  try
    protobuf.MongoId := AGameId;
    SendProtobuf(scTableStandUp, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.Ping;
var
  protobuf: TPB_PingParams;
begin
  protobuf := TPB_PingParams.Create;
  try
    protobuf.Uptime := GetTickCount;
    SendProtobuf(scPing, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.ChangePlayerSuspendState(const AClubId, APlayerId: TBytes; const ASuspended: Boolean);
var
  protobuf: TPB_ChangeSuspendState;
begin
  protobuf := TPB_ChangeSuspendState.Create;
  try
    protobuf.ClubMongoId := AClubId;
    protobuf.PlayerMongoId := APlayerId;
    protobuf.Suspended := ASuspended;
    SendProtobuf(scSuspendPlayer, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.GetUserInfos(const AMongoIds: TArray<TBytes>);
var
  protobuf: TPB_GetUserParams;
begin
  protobuf := TPB_GetUserParams.Create;
  try
    protobuf.UserMongoIds := AMongoIds;
    SendProtobuf(scGetPlayers, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.Fold(const AGameId: TBytes);
var
  protobuf: TPB_Game;
begin
  protobuf := TPB_Game.Create;
  try
    protobuf.MongoId := AGameId;
    SendProtobuf(scFold, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.PutChips(const AGameId: TBytes; const AChipAmount: Integer);
var
  protobuf: TPB_PutChips;
begin
  protobuf := TPB_PutChips.Create;
  try
    protobuf.TableMongoId := AGameId;
    protobuf.ChipAmount := AChipAmount;
    SendProtobuf(scPutChips, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.TablePlayNow(const AGameId: TBytes);
var
  protobuf: TPB_Game;
begin
  protobuf := TPB_Game.Create;
  try
    protobuf.MongoId := AGameId;
    SendProtobuf(scTablePlayNow, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.TableSitOutNextHand(const AGameId: TBytes; const AFlag: Boolean);
begin
  TableBoolFlag(scTableSitOutNextHand, AGameId, AFlag);
end;

procedure TServerSocket.TableSitOutNextBB(const AGameId: TBytes; const AFlag: Boolean);
begin
  TableBoolFlag(scTableSitOutNextBB, AGameId, AFlag);
end;

procedure TServerSocket.TableBoolFlag(const ACommand: TServerCodes; const AGameId: TBytes; const AFlag: Boolean);
var
  protobuf: TPB_TableBoolFlag;
begin
  protobuf := TPB_TableBoolFlag.Create;
  try
    protobuf.TableMongoId := AGameId;
    protobuf.Flag := AFlag;
    SendProtobuf(ACommand, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.ResendVerificationMail;
begin
  SendProtobuf(scResendVerificationMail, nil);
end;

procedure TServerSocket.ShowCards(const AGameId: TBytes);
var
  protobuf: TPB_Game;
begin
  protobuf := TPB_Game.Create;
  try
    protobuf.MongoId := AGameId;
    SendProtobuf(scShowLosingCards, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.QueryTableStats(const ATables: array of TBytes);
var
  protobuf: TPB_QueryTableStats;
  gameids: TArray<TBytes>;
  C1: Integer;
begin
  protobuf := TPB_QueryTableStats.Create;
  try
    SetLength(gameids, Length(ATables));
    for C1 := Low(ATables) to High(ATables) do
      gameids[C1] := ATables[C1];
    protobuf.Gameid := gameids;
    SendProtobuf(scQueryTableStats, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.ContactUs(const AReason: TContactReason; const AMessage: String);
var
  protobuf: TPB_ContactMessage;
begin
  protobuf := TPB_ContactMessage.Create;
  try
    protobuf.Reason := AReason;
    protobuf.Message := AMessage;
    SendProtobuf(scContactUs, protobuf);
  finally
    protobuf.Free;
  end;
end;


end.
