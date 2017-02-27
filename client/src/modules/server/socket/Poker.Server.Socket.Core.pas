unit Poker.Server.Socket.Core;

interface

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Winapi.Windows, System.Classes, System.SysUtils, System.Generics.Collections, OverbyteIcsWSocket, Poker.Server.Socket.ConnectThread,
  Poker.Common.SSLCert, Poker.Protobufs.Objects.RpcMessage, Poker.Protobufs.Enum.ServerCodes, Poker.Protobufs.Objects.Base, Winapi.Messages;

type
  TServerSocketCore = class
  private
    const
      TIMER_ID_PING = 1;
      TIMER_ID_PING_TIMEOUT = 2;
      TIMER_ID_INACTIVITY_PING = 3;

    var
      FSocket: TSslWSocket;
      FInternalHWND: HWND;
      FReceiveBuffer: PAnsiChar;
      FReceiveBufferSize: Integer;
      FLatency: Integer;
      FServerTime: UINT64;
      FTimeOffset: UINT64;
      FPinging: Boolean;
      FSSLHandshakeDone: Boolean;
      FSocketConnectThread: TServerSocketConnectThread;
      FSSLCert: TSSLCert;
      FBytesDownloaded: DWORD;
      FBytesSent: DWORD;

    procedure SocketSessionConnected(Sender: TObject; ErrCode: Word);
    procedure SocketSessionClosed(Sender: TObject; ErrCode: Word);
    procedure SocketSslHandshakeDone(Sender: TObject; ErrCode: Word; PeerCert: TX509Base; var Disconnect: Boolean);
    procedure SocketSslVerifyPeer(Sender: TObject; var Ok: Integer; Cert: TX509Base);
    procedure SocketChangeState(Sender: TObject; OldState, NewState: TSocketState);
    procedure SocketSendData(Sender: TObject; BytesSent: Integer);
    procedure SocketDataAvailable(Sender: TObject; Error: Word);
    procedure SocketError(Sender: TObject);
    procedure SocketConnectThreadTerminate(Sender: TObject);
    procedure WndProc(var AMessage: TMessage);
    procedure FreeReceiveBuffer;
    function ParseRpcMessage(const ARpcMessage: TPB_RpcMessage; const ADataPointer: pointer; out ADataObject: TObject): Boolean;
    procedure ResetPingTimeoutTimer;
    procedure ResetPingTimer;
    procedure ResetInactivityPingTimer;
    procedure KillPingTimers;
    procedure KillPingTimeoutTimer;
    {$IFDEF DEBUG}
    procedure DebugRpcMessage(const ADebugType: TDebugInfoType; const ARpcMessage: TPB_RpcMessage; const ADataObject: TObject; const AStreamSize: Int64 = 0; const ABuffer: pointer = nil; const ABufferSize: Integer = 0);
    {$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;

    procedure Connect(const AServer: String; const APort: Integer; const ASSLEnable: Boolean; const ASSLCert: String; const AConnectSynchronously: Boolean = FALSE);
    procedure Disconnect;
    function IsConnected: Boolean;
    procedure SendProtobuf(const AServerCode: TServerCodes; const AProtobuf: TProtobufBaseObject);
    procedure SendRawProtobuf(const AServerCode: TServerCodes; const AProtobuf; const ASize: Integer);
    procedure SendRaw(const ABuffer: pointer; const ASize: Integer);
    procedure AppendToReceiveBuffer(const APointer: pointer; const ASize: Integer);
    procedure ParseReceiveBuffer;
    procedure Ping;

    property Socket: TSslWSocket read FSocket;
    property Latency: Integer read FLatency;
    property ServerTime: UINT64 read FServerTime;
    property TimeOffset: UINT64 read FTimeOffset;
    property IsPinging: Boolean read FPinging;
    property SSLCertificate: TSSLCert read FSSLCert;
    property BytesDownloaded: DWORD read FBytesDownloaded;
    property BytesSent: DWORD read FBytesSent;
  end;

implementation

uses
  Winapi.WinSock, Poker.Settings, Poker.Common.Misc, pbOutput, Poker.Server.MessageContainer, Poker.Server.Socket,
  Poker.WindowMessages, Poker.Protobufs.Objects.LoginParams,
  Poker.Protobufs.Objects.HelloReply, Poker.Protobufs.Objects.RegisterParams, Poker.Protobufs.Objects.Club,
  Poker.Protobufs.Objects.ChangeEMailParams, Poker.Protobufs.Objects.ForgotPasswordParams, Poker.Protobufs.Objects.ClubCommandReply,
  Poker.Protobufs.Objects.SetAvatarReply, Poker.Protobufs.Objects.PingParams, Poker.Protobufs.Objects.PingReply,
  Poker.Protobufs.Objects.ChangePasswordParams, Poker.Protobufs.Objects.RegisterReply,
  Poker.Protobufs.Objects.LoginReply, Poker.Protobufs.Objects.GetUserParams, Poker.Protobufs.Objects.SetAvatarParams,
  Poker.Protobufs.Objects.ChatEvent, Poker.Protobufs.Objects.ChatMessage, Poker.Protobufs.Objects.TableSit,
  Poker.Protobufs.Objects.ChangeMailReply, Poker.Protobufs.Objects.TableBoolFlag, Poker.Protobufs.Objects.PutChips,
  Poker.Protobufs.Objects.User, Poker.Protobufs.Objects.UserChangeParams, Poker.SoftExceptions,
  Poker.Protobufs.Objects.TableStatsReplies, Poker.Protobufs.Objects.HandHistoryReply, Poker.Protobufs.Objects.BuyinError,
  Poker.Protobufs.Objects.PlayerLimitParams, Poker.Protobufs.Objects.AssetList, Poker.Protobufs.Objects.HelloParams,
  Poker.Protobufs.Objects.TableStatus, Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.KickPlayerParams,
  Poker.Protobufs.Objects.TournamentList, Poker.Protobufs.Objects.TournamentCommandParams,
  Poker.Protobufs.Objects.TournamentInfo, Poker.Protobufs.Objects.TournamentTableStart, Poker.Protobufs.Objects.TournamentPlayerFinished,
  Poker.Protobufs.Objects.TableMessage, Poker.Protobufs.Objects.TournamentPlayerTransfer, Poker.Protobufs.Objects.PlayerClubStatus,
  Poker.Protobufs.Objects.ReservedSeatFree;


constructor TServerSocketCore.Create;
begin
  FInternalHWND := AllocateHwnd(WndProc);

  FSocket := TSslWSocket.Create(nil);
  FSocket.TimeoutConnect := Settings.Hardcoded.SERVER_CONNECT_TIMEOUT * 1000;
  FSocket.TimeoutIdle := Settings.Hardcoded.SERVER_CONNECT_TIMEOUT * 1000;
  FSocket.TimeoutSampling := Settings.Hardcoded.SERVER_CONNECT_TIMEOUT * 1000;

  FSocket.OnChangeState := SocketChangeState;
  FSocket.OnDataAvailable := SocketDataAvailable;
  FSocket.OnError := SocketError;
  FSocket.OnSessionConnected := SocketSessionConnected;
  FSocket.OnSessionClosed := SocketSessionClosed;
  FSocket.OnSslVerifyPeer := SocketSslVerifyPeer;
  FSocket.OnSslHandshakeDone := SocketSslHandshakeDone;
  FSocket.OnSendData := SocketSendData;
end;

destructor TServerSocketCore.Destroy;
begin
  {$IFDEF DEBUG} DebugLn('Destroying socket...', ditSocket); {$ENDIF}

  Disconnect;

  if Assigned(FSocket.SslContext) then
  begin
    FSocket.SslContext.DeInitContext;
    if Assigned(FSSLCert) then
      FreeAndNil(FSSLCert);
    FSocket.SslContext.Free;
    FSocket.SslContext := nil;
  end;
  FreeAndNil(FSocket);

  DeallocateHWnd(FInternalHWND);

  inherited;
end;

procedure TServerSocketCore.Connect(const AServer: String; const APort: Integer;
     const ASSLEnable: Boolean; const ASSLCert: String;
     const AConnectSynchronously: Boolean = FALSE);
begin
  if (FSocket.State <> wsClosed) or
     (Assigned(FSocketConnectThread)) then
    Exit;

  FreeReceiveBuffer;

  KillPingTimers;
  KillPingTimeoutTimer;

  FSocket.Addr := AServer;
  FSocket.Port := IntToStr(APort);
  FSocket.SslEnable := ASSLEnable;

  if FSocket.SslEnable then
  begin
    if not Assigned(FSocket.SslContext) then
    begin
      FSocket.SslContext := TSslContext.Create(nil);
      FSocket.SslContext.sslVersionMethod := sslTLS_V1_2;
      FSocket.SslContext.SslVerifyPeer := TRUE;
      FSocket.SslContext.SslVerifyDepth := 9;
      FSocket.SslContext.SslVerifyFlags := [sslX509_V_FLAG_CRL_CHECK_ALL];
      FSocket.SslContext.SslVerifyPeerModes := [SslVerifyMode_PEER];
      FSocket.SslContext.SslSessionCacheModes := [sslSESS_CACHE_CLIENT, sslSESS_CACHE_NO_INTERNAL_LOOKUP, sslSESS_CACHE_NO_INTERNAL_STORE];
      FSocket.SslContext.InitContext;
    end;

    if (Assigned(FSSLCert)) and
       (FSSLCert.CertResourceName <> ASSLCert) then
      FreeAndNil(FSSLCert);

    if not Assigned(FSSLCert) then
    begin
      FSSLCert := TSSLCert.Create(nil);
      FSSLCert.LoadFromResource(ASSLCert);
    end;

    FSocket.SslContext.TrustCert(FSSLCert);
  end
  else
  begin
    if Assigned(FSocket.SslContext) then
    begin
      FSocket.SslContext.Free;
      FSocket.SslContext := nil;
    end;

    if Assigned(FSSLCert) then
      FreeAndNil(FSSLCert);
  end;

  {$IFDEF DEBUG} DebugLn(Format('Connecting to %s:%s...', [FSocket.Addr, FSocket.Port]), ditSocket); {$ENDIF}

  if AConnectSynchronously then
    FSocket.Connect
  else
  begin
    FSocketConnectThread := TServerSocketConnectThread.Create(FSocket);
    FSocketConnectThread.FreeOnTerminate := TRUE;
    FSocketConnectThread.OnTerminate := SocketConnectThreadTerminate;
    FSocketConnectThread.Start;
  end;
end;

procedure TServerSocketCore.Disconnect;
begin
  KillPingTimers;
  KillPingTimeoutTimer;

  if FSocket.State <> TSocketState.wsClosed then
  begin
    FSocket.Flush;
    FSocket.CloseDelayed;
  end;

  FSSLHandshakeDone := FALSE;
  FreeReceiveBuffer;
end;

procedure TServerSocketCore.SocketSessionConnected(Sender: TObject; ErrCode: Word);
begin
  if ErrCode = 0 then
  begin
    if FSocket.SslEnable then
    begin
      {$IFDEF DEBUG} DebugLn(Format('Starting SSL handshake (cert size: %d bytes)...', [FSSLCert.Size]), ditSocket); {$ENDIF}
      FSocket.StartSslHandshake;
    end
    else
    begin
      {$IFDEF DEBUG} DebugLn('SSL not enabled for this server', ditSocket); {$ENDIF}
      ResetInactivityPingTimer;
      ResetPingTimer;
    end;
  end
  else
  begin
    FSocket.LastError := ErrCode;
    SocketError(Sender);
  end;
end;

procedure TServerSocketCore.SocketSendData(Sender: TObject; BytesSent: Integer);
begin
  Inc(FBytesSent, BytesSent);
  {$IFDEF DEBUG} RefreshDebugForm([dfiSocket]); {$ENDIF}
end;

procedure TServerSocketCore.SocketSessionClosed(Sender: TObject; ErrCode: Word);
begin
  {$IFDEF DEBUG} DebugLn('Session closed', ditSocket); {$ENDIF}
  Disconnect;
end;

procedure TServerSocketCore.SocketSslHandshakeDone(Sender: TObject; ErrCode: Word; PeerCert: TX509Base; var Disconnect: Boolean);
begin
  if ErrCode = 0 then
  begin
    FSSLHandshakeDone := TRUE;
    ResetInactivityPingTimer;
    ResetPingTimer;
    {$IFDEF DEBUG} DebugLn('SSL handshake done', ditSocket); {$ENDIF}
  end
  else
  begin
    FSSLHandshakeDone := FALSE;
    FSocket.LastError := ErrCode;
    SocketError(Sender);
  end;
end;

procedure TServerSocketCore.SocketSslVerifyPeer(Sender: TObject; var Ok: Integer; Cert: TX509Base);
begin
  case Ok of
    0: SoftException('SSL peer not verified');
    1: {$IFDEF DEBUG} DebugLn('SSL peer successfully verified', ditSocket) {$ENDIF};
  else
    SoftException(Format('SSL verify peer result: %d', [Ok]));
  end;
end;

procedure TServerSocketCore.WndProc(var AMessage: TMessage);
begin
  inherited;

  case AMessage.Msg of
    WM_TIMER: case AMessage.WParam of
      TIMER_ID_PING, TIMER_ID_INACTIVITY_PING: Ping;
      TIMER_ID_PING_TIMEOUT: begin
        SoftException('Ping timeout');
        Disconnect;
      end;
    end;
  end;
end;

{$IFDEF DEBUG}
procedure TServerSocketCore.DebugRpcMessage(const ADebugType: TDebugInfoType; const ARpcMessage: TPB_RpcMessage; const ADataObject: TObject; const AStreamSize: Int64 = 0; const ABuffer: pointer = nil; const ABufferSize: Integer = 0);
var
  dbgtype: TDebugInfoType;
  serialized_object: String;
begin
  if ARpcMessage.MethodId in [Integer(scPing), Integer(srPong)] then
    dbgtype := ditPingPong
  else
    dbgtype := ADebugType;

  if ARpcMessage.DataSize = 0 then
    DebugLn(Format('Code: %s', [Poker.Protobufs.Enum.ServerCodes.TranslateCode(ARpcMessage.MethodId)]), dbgtype, '', ABuffer, ABufferSize)
  else
  begin
    if (IsDebugFormAssigned) and
       (IsDebugRTTIEnabled) then
      serialized_object := SerializeObject(ADataObject)
    else
      serialized_object := '';

    if AStreamSize = 0 then
      DebugLn(Format('Code: %s; data size: %d', [Poker.Protobufs.Enum.ServerCodes.TranslateCode(ARpcMessage.MethodId), ARpcMessage.DataSize]), dbgtype, serialized_object, ABuffer, ABufferSize)
    else
      DebugLn(Format('Code: %s; data size: %d; stream size: %d', [Poker.Protobufs.Enum.ServerCodes.TranslateCode(ARpcMessage.MethodId), ARpcMessage.DataSize, AStreamSize]), dbgtype, serialized_object, ABuffer, ABufferSize);
  end;
end;
{$ENDIF}

procedure TServerSocketCore.AppendToReceiveBuffer(const APointer: pointer; const ASize: Integer);
var
  new_size: Integer;
begin
  new_size := FReceiveBufferSize + ASize;
  ReallocMem(FReceiveBuffer, new_size);
  Move(APointer^, FReceiveBuffer[new_size - ASize], ASize);
  FReceiveBufferSize := new_size;
  Inc(FBytesDownloaded, ASize);
  {$IFDEF DEBUG} RefreshDebugForm([dfiSocket]); {$ENDIF}
end;

procedure TServerSocketCore.ParseReceiveBuffer;
var
  rpc_size: Word;
  rpc_message: TPB_RpcMessage;
  data_obj: TObject;
  ptmp: pointer;
begin
  if FReceiveBufferSize = 0 then
    Exit;

  rpc_size := PWord(FReceiveBuffer)^;
  if FReceiveBufferSize < SizeOf(rpc_size) + rpc_size then
    Exit;

  rpc_message := TPB_RpcMessage.Create(pointer(NativeUInt(FReceiveBuffer) + SizeOf(rpc_size)), rpc_size);
  try
    if not rpc_message.IsInitialized then
    begin
      SoftException('RPC message not initialized');
      Exit;
    end;

    if rpc_size + SizeOf(rpc_size) + rpc_message.DataSize > FReceiveBufferSize then
      Exit;

    if ParseRpcMessage(rpc_message, pointer(NativeUInt(FReceiveBuffer) + SizeOf(rpc_size) + rpc_size), data_obj) then
    begin
      ResetInactivityPingTimer;
      {$IFDEF DEBUG} DebugRpcMessage(ditSocketInc, rpc_message, data_obj, 0,
        FReceiveBuffer, SizeOf(rpc_size) + rpc_size + rpc_message.DataSize); {$ENDIF}
      PostMessage(MessageContainer.HWND, WM_MESSAGE_CALLBACK_PROTO, NativeUInt(data_obj), rpc_message.MethodId);
    end;

    ptmp := pointer(NativeInt(FReceiveBuffer) + SizeOf(rpc_size) + rpc_size + rpc_message.DataSize);
    Dec(FReceiveBufferSize, SizeOf(rpc_size) + rpc_size + rpc_message.DataSize);
    Move(ptmp^, FReceiveBuffer, FReceiveBufferSize);
    ReallocMem(FReceiveBuffer, FReceiveBufferSize);
  finally
    rpc_message.Free;
  end;
end;

procedure TServerSocketCore.SocketDataAvailable(Sender: TObject; Error: Word);
const
  BUFFER_SIZE = 16 * 1024;
var
  len: Integer;
  rcv_buf: TArray<AnsiChar>;
begin
  if Error <> 0 then
  begin
    FSocket.LastError := Error;
    SocketError(Sender);
    Exit;
  end;

  SetLength(rcv_buf, BUFFER_SIZE);
  FillChar(rcv_buf[0], BUFFER_SIZE, 0);
  len := FSocket.Receive(@rcv_buf[0], FSocket.RcvdCount);

  if len < 0 then
  begin
    FSocket.LastError := WSAGetLastError;
    SocketError(Sender);
  end
  else
    AppendToReceiveBuffer(@rcv_buf[0], len);

  ParseReceiveBuffer;
end;

procedure TServerSocketCore.SocketChangeState(Sender: TObject; OldState, NewState: TSocketState);
begin
  case NewState of
    wsInvalidState: ;
    wsOpened: ;
    wsBound: ;
    wsConnecting: begin
{      if not Assigned(FSocketConnectThread) then
        Disconnect;}
    end;
    wsSocksConnected: ;
    wsConnected: ;
    wsAccepting: ;
    wsListening: ;
    wsClosed: ;
  end;

  PostMessage(MessageContainer.HWND, WM_MESSAGE_CALLBACK_SOCKET_STATE, Integer(OldState), Integer(NewState));
end;


procedure TServerSocketCore.SocketConnectThreadTerminate(Sender: TObject);
begin
  FSocketConnectThread := nil;
end;

procedure TServerSocketCore.SocketError(Sender: TObject);
{$IFDEF DEBUG}
var
  last_err, wsa_err: Integer;
  line: String;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  last_err := FSocket.LastError;
  wsa_err := WSAGetLastError;
  if last_err <> WSAEWOULDBLOCK then // ignore WSAEWOULDBLOCK
  begin
    line := '';

    if last_err > 0 then
      line := Format('%s (#%d)', [WSocketErrorDesc(last_err), last_err]);

    if wsa_err > 0 then
    begin
      if line <> '' then
        line := line + ' | ';
      line := line + Format('%s (#%d)', [WSocketErrorDesc(wsa_err), wsa_err]);
    end;

    if line <> '' then
      SoftException(Format('Socket error: %s', [line]))
    else
      SoftException('Unknown socket error');
  end;
  {$ENDIF}

  case FSocket.State of
    wsConnected: ;
    wsClosed: ;
  else
    Disconnect;
  end;
end;

procedure TServerSocketCore.ResetPingTimer;
begin
  SetTimer(FInternalHWND, TIMER_ID_PING, Settings.Hardcoded.SERVER_PING_INTERVAL * 1000, nil);
end;

procedure TServerSocketCore.ResetInactivityPingTimer;
begin
  SetTimer(FInternalHWND, TIMER_ID_INACTIVITY_PING, Settings.Hardcoded.SERVER_INACTIVITY_PING_INTERVAL * 1000, nil);
end;

procedure TServerSocketCore.ResetPingTimeoutTimer;
begin
  SetTimer(FInternalHWND, TIMER_ID_PING_TIMEOUT, Settings.Hardcoded.SERVER_PING_TIMEOUT * 1000, nil);
  FPinging := TRUE;
  {$IFDEF DEBUG} RefreshDebugForm([dfiSocket]); {$ENDIF}
end;

procedure TServerSocketCore.KillPingTimers;
begin
  KillTimer(FInternalHWND, TIMER_ID_PING);
  KillTimer(FInternalHWND, TIMER_ID_INACTIVITY_PING);
end;

procedure TServerSocketCore.KillPingTimeoutTimer;
begin
  KillTimer(FInternalHWND, TIMER_ID_PING_TIMEOUT);
  FPinging := FALSE;
end;

function TServerSocketCore.IsConnected: Boolean;
begin
  result := (Assigned(FSocket)) and (FSocket.State = wsConnected) and
   ((not FSocket.SslEnable) or (FSSLHandshakeDone));
end;


function TServerSocketCore.ParseRpcMessage(const ARpcMessage: TPB_RpcMessage; const ADataPointer: pointer; out ADataObject: TObject): Boolean;
var
  err: String;
  gtc: DWORD;
  hexdump: String;
begin
  ADataObject := nil;

  case ARpcMessage.MethodId of
    Integer(srNotImplemented): begin
      SetString(err, PAnsiChar(ADataPointer), ARpcMessage.DataSize);
      SoftException(Format('Received unimplemented code: %s', [err]));
    end;
    Integer(srLoginReply): ADataObject := TPB_LoginReply.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srLogout): ;
    Integer(srRegisterReply): ADataObject := TPB_RegisterReply.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srChangePasswordOk): ;
    Integer(seSecondaryLoginDetected): ;
    Integer(seAccountConfirmed): ADataObject := TPB_User.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srPlayerLimitOk): ADataObject := TPB_PlayerLimitParams.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srGetPlayers): ADataObject := TPB_GetUserParams.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srChangeMailReply): ADataObject := TPB_ChangeMailReply.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srSetAvatarReply): ADataObject := TPB_SetAvatarReply.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srCreateClubReply),
    Integer(srJoinClubReply),
    Integer(srLeaveClubReply),
    Integer(srChangeClubDetailsReply),
    Integer(srKickPlayerReply): ADataObject := TPB_ClubCommandReply.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srHello): ADataObject := TPB_HelloReply.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srTableAddonOverLimit),
    Integer(seTableStatus),
    Integer(srTableSitOk),
    Integer(srTableSitSeatTaken),
    Integer(srTableAddonOk),
    Integer(srClubBalanceReached),
    Integer(seReservedSeatTimeout),
    Integer(srTableStandUpOk): ADataObject := TPB_TableStatus.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srPong): begin
      gtc := GetTickCount;
      ADataObject := TPB_PingReply.Create(ADataPointer, ARpcMessage.DataSize);
      FLatency := gtc - (ADataObject as TPB_PingReply).Uptime;
      FServerTime := (ADataObject as TPB_PingReply).Servertime + FLatency div 2;
      FTimeOffset := FServerTime - gtc;
      KillPingTimeoutTimer;
      ResetPingTimer;
      {$IFDEF DEBUG} RefreshDebugForm([dfiSocket]); {$ENDIF}
    end;
    Integer(seChat): ADataObject := TPB_ChatEvent.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srClubDisbandOk),
    Integer(srOwnershipGiveAwayNotOwner),
    Integer(srOwnershipGiveawayInvalidPlayerId),
    Integer(srOwnershipGiveAwayInvalidClubId),
    Integer(srOwnershipGiveAwayOk),
    Integer(srSuspendPlayerOk),
    Integer(srReinstatePlayerOk),
    Integer(seClubChange),
    Integer(srResetPlayerBalanceOk),
    Integer(seClubDeleted): ADataObject := TPB_Club.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srCreateGameOk),
    Integer(srDeleteGameOk),
    Integer(seGameChange),
    Integer(seGameCreate),
    Integer(srNotSitting),
    Integer(seGameDelete): ADataObject := TPB_Game.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(seUserChange): ADataObject := TPB_UserChangeParams.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srTableStatsReply): ADataObject := TPB_TableStatsReplies.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srContactUsOk): ;
    Integer(srTableBuyinLessThanCashout),
    Integer(srInvalidTableBuyin): ADataObject := TPB_BuyinError.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srHandHistoryMsg): ADataObject := TPB_HandHistoryReply.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srQueryAssetsReply): ADataObject := TPB_AssetList.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(seTournamentList): ADataObject := TPB_TournamentList.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srTournamentReply): ADataObject := TPB_TournamentCommandParams.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srTournamentDetails): ADataObject := TPB_TournamentInfo.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(srTournamentOpenTable): ADataObject := TPB_TournamentTableStart.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(seTournamentPlayerFinished): ADataObject := TPB_TournamentPlayerFinished.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(seTournamentPlayerTransfer): ADataObject := TPB_TournamentPlayerTransfer.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(sePlayerClubStatus): ADataObject := TPB_PlayerClubStatus.Create(ADataPointer, ARpcMessage.DataSize);
    Integer(seReservedSeatFree): ADataObject := TPB_ReservedSeatFree.Create(ADataPointer, ARpcMessage.DataSize);
  else
    SoftException(Format('Unhandled code received: %s', [Poker.Protobufs.Enum.ServerCodes.TranslateCode(ARpcMessage.MethodId)]));
    Exit(FALSE);
  end;

  if (Assigned(ADataObject)) and
     (not (ADataObject as TProtobufBaseObject).IsInitialized) then
  begin
    SetLength(hexdump, ARpcMessage.DataSize * 2);
    BinToHex(ADataPointer, PWideChar(@hexdump[1]), ARpcMessage.DataSize);
    SoftException(Format('Data object not initialized for code: %s', [Poker.Protobufs.Enum.ServerCodes.TranslateCode(ARpcMessage.MethodId)]), hexdump);
    FreeAndNil(ADataObject);
    Exit(FALSE);
  end;

  Exit(TRUE);
end;

procedure TServerSocketCore.SendRaw(const ABuffer: pointer; const ASize: Integer);
var
  rpc_size: Word;
  rpc_message: TPB_RpcMessage;
begin
  rpc_size := PWord(ABuffer)^;
  if ASize < SizeOf(rpc_size) + rpc_size then
    Exit;

  rpc_message := TPB_RpcMessage.Create(pointer(NativeUInt(ABuffer) + SizeOf(rpc_size)), rpc_size);
  try
    if rpc_message.IsInitialized then
    begin
      {$IFDEF DEBUG} DebugRpcMessage(ditSocketOut, rpc_message, nil, ASize, ABuffer, ASize); {$ENDIF}
    end
    else
    begin
      {$IFDEF DEBUG} DebugLn('Buffer sent', ditSocketOut, '', ABuffer, ASize); {$ENDIF}
    end;
  finally
    rpc_message.Free;
  end;

  FSocket.Send(ABuffer, ASize);
end;

procedure TServerSocketCore.SendRawProtobuf(const AServerCode: TServerCodes; const AProtobuf; const ASize: Integer);
var
  rpc_message: TPB_RpcMessage;
  mstream: TMemoryStream;
  rpcsize: Word;
begin
  rpc_message := TPB_RpcMessage.Create;
  try
    rpc_message.MethodId := Integer(AServerCode);
    if ASize > 0 then
      rpc_message.DataSize := ASize;
    mstream := TMemoryStream.Create;
    try
      rpcsize := rpc_message.ProtobufOutputSize;
      mstream.WriteBuffer(rpcsize, SizeOf(rpcsize));
      rpc_message.ProtobufOutput.SaveToStream(mstream);
      if ASize > 0 then
        mstream.Write(AProtobuf, rpc_message.DataSize);

      {$IFDEF DEBUG} DebugRpcMessage(ditSocketOut, rpc_message, nil, mstream.Size, mstream.Memory, mstream.Size); {$ENDIF}
      FSocket.Send(mstream.Memory, mstream.Size);
    finally
      mstream.Free;
    end;
  finally
    rpc_message.Free;
  end;
end;

procedure TServerSocketCore.SendProtobuf(const AServerCode: TServerCodes; const AProtobuf: TProtobufBaseObject);
var
  rpc_message: TPB_RpcMessage;
  mstream: TMemoryStream;
  rpcsize: Word;
begin
  rpc_message := TPB_RpcMessage.Create;
  try
    rpc_message.Methodid := Integer(AServerCode);
    if Assigned(AProtobuf) then
      rpc_message.DataSize := AProtobuf.ProtobufOutputSize;
    mstream := TMemoryStream.Create;
    try
      rpcsize := rpc_message.ProtobufOutputSize;
      mstream.WriteBuffer(rpcsize, SizeOf(rpcsize));
      rpc_message.ProtobufOutput.SaveToStream(mstream);
      if rpc_message.Datasize > 0 then
        AProtobuf.ProtobufOutput.SaveToStream(mstream);

      {$IFDEF DEBUG} DebugRpcMessage(ditSocketOut, rpc_message, AProtobuf, mstream.Size, mstream.Memory, mstream.Size); {$ENDIF}
      FSocket.Send(mstream.Memory, mstream.Size);
    finally
      mstream.Free;
    end;
  finally
    rpc_message.Free;
  end;
end;

procedure TServerSocketCore.FreeReceiveBuffer;
begin
  if FReceiveBufferSize > 0 then
  begin
    FreeMem(FReceiveBuffer, FReceiveBufferSize);
    FReceiveBufferSize := 0;
    FReceiveBuffer := nil;
  end;
end;

procedure TServerSocketCore.Ping;
var
  protobuf: TPB_PingParams;
begin
  protobuf := TPB_PingParams.Create;
  try
    protobuf.Uptime := GetTickCount;
    SendProtobuf(scPing, protobuf);
    KillPingTimers;
    ResetPingTimeoutTimer;
  finally
    protobuf.Free;
  end;
end;

end.


















