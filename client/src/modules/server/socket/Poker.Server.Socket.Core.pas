unit Poker.Server.Socket.Core;

interface

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Winapi.Windows, System.Classes, System.SysUtils, System.Generics.Collections, OverbyteIcsWSocket, Poker.Server.Socket.ConnectThread,
  Poker.Protobufs.Objects.RpcMessage, Poker.Protobufs.Enum.ServerCodes, Poker.Protobufs.Objects.Base;

type
  TServerSocketCore = class
  private
    FSocket: TSslWSocket;
    FServer: String;
    FPort: Integer;
    FReceiveBuffer: PAnsiChar;
    FReceiveBufferSize: Integer;
    FLatency: Integer;
    FServerTime: UINT64;
    FTimeOffset: UINT64;
    FTimerIdInactivityPing: UINT32;
    FTimerIdPing: UINT32;
    FTimerIdPingTimeout: UINT32;
    FSSLHandshakeDone: Boolean;
    FSocketConnectThread: TServerSocketConnectThread;
    {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}

    procedure SocketSessionConnected(Sender: TObject; ErrCode: Word);
    procedure SocketSessionClosed(Sender: TObject; ErrCode: Word);
    procedure SocketSslHandshakeDone(Sender: TObject; ErrCode: Word; PeerCert: TX509Base; var Disconnect: Boolean);
    procedure SocketSslVerifyPeer(Sender: TObject; var Ok: Integer; Cert: TX509Base);
    procedure SocketChangeState(Sender: TObject; OldState, NewState: TSocketState);
    procedure SocketDataAvailable(Sender: TObject; Error: Word);
    procedure SocketError(Sender: TObject);
    procedure SocketConnectThreadTerminate(Sender: TObject);

    procedure FreeReceiveBuffer;
    function ParseRpcMessage(const ARpcMessage: TPB_RpcMessage; const ADataPointer: pointer; out ADataObject: TObject): Boolean;

    procedure ResetPingTimeoutTimer;
    procedure ResetPingTimer;
    procedure ResetInactivityPingTimer;
    procedure KillPingTimers;
    procedure KillPingTimeoutTimer;

    {$IFDEF DEBUG}
    procedure DebugRpcMessage(const ADebugType: TDebugInfoType; const ARpcMessage: TPB_RpcMessage; const ADataObject: TObject; const AStreamSize: Int64 = 0);
    {$ENDIF}

  public
    constructor Create(const AServer: String; const APort: Integer);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    function IsConnected: Boolean;

    function IsPinging: Boolean;

    procedure SendProtobuf(const AMethodId: TServerCodes; const AProtobuf: TProtobufBaseObject);
    procedure SendRawBytes(const AMethodId: TServerCodes; const AProtobuf; const ASize: Integer);
    procedure ProcessTimer(const ATimerId: UINT_PTR);

    procedure Ping;

    property Server: String read FServer;
    property Socket: TSslWSocket read FSocket;
    property Latency: Integer read FLatency;
    property ServerTime: UINT64 read FServerTime;
    property TimeOffset: UINT64 read FTimeOffset;
  end;

implementation

uses
  Winapi.WinSock, Poker.Settings, Poker.Common.Misc, pbOutput, Poker.Server.MessageContainer, Poker.Server.Socket,
  Poker.Server.SSLCerts, Poker.WindowMessages, Poker.Protobufs.Objects.LoginParams, Poker.Protobufs.Objects.StatusReply,
  Poker.Protobufs.Objects.HelloReply, Poker.Protobufs.Objects.RegisterParams, Poker.Protobufs.Objects.Club,
  Poker.Protobufs.Objects.ChangeEMailParams, Poker.Protobufs.Objects.ForgotPasswordParams, Poker.Protobufs.Objects.ListClubsReply,
  Poker.Protobufs.Objects.TransferChipsParams, Poker.Protobufs.Objects.ClubCommandReply, Poker.Protobufs.Objects.SetAvatarReply,
  Poker.Protobufs.Objects.PingParams, Poker.Protobufs.Objects.PingReply, Poker.Protobufs.Objects.GiveClubOwnershipParams,
  Poker.Protobufs.Objects.ChangePasswordParams, Poker.Protobufs.Objects.RegisterReply, Poker.Protobufs.Objects.LoginReply,
  Poker.Protobufs.Objects.GetUserParams, Poker.Protobufs.Objects.SetAvatarParams, Poker.Protobufs.Objects.ChatEvent,
  Poker.Protobufs.Objects.ChatMessage, Poker.Protobufs.Objects.TableSit, Poker.Protobufs.Objects.ChangeSuspendState,
  Poker.Protobufs.Objects.ChangeMailReply, Poker.Protobufs.Objects.TableBoolFlag, Poker.Protobufs.Objects.PutChips,
  Poker.Protobufs.Objects.User, Poker.Protobufs.Objects.UserChangeParams, Poker.Protobufs.Objects.QueryTableStats,
  Poker.Protobufs.Objects.TableStatsReplies, Poker.Protobufs.Objects.ClubHandHistoryReply, Poker.Protobufs.Objects.BuyinError,
  Poker.Protobufs.Objects.PlayerLimitParams, Poker.Protobufs.Objects.AssetList, Poker.Protobufs.Objects.HelloParams,
  Poker.Protobufs.Objects.TableStatus, Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.KickPlayerParams,
  Poker.Protobufs.Objects.SubscriptionPlanChange;


procedure TimerProc(HWND: HWND; uMsg: UINT; idEvent: UINT_PTR; dwTime: DWORD); stdcall;
begin
  if Assigned(ServerSocket) then
    ServerSocket.ProcessTimer(idEvent);
end;

constructor TServerSocketCore.Create(const AServer: String; const APort: Integer);
begin
  {$IFDEF DEBUG} FDebugId := RegisterDebugObject('Socket'); {$ENDIF}

  FServer := AServer;
  FPort := APort;

  FTimerIdPing := 0;
  FTimerIdInactivityPing := 0;
  FTimerIdPingTimeout := 0;

  FSocket := TSslWSocket.Create(nil);
  FSocket.TimeoutConnect := 1500;
  FSocket.TimeoutIdle := 1500;
  FSocket.TimeoutSampling := 1500;
  FSocket.SslContext := TSslContext.Create(nil);
  FSocket.SslContext.SslVerifyPeer := TRUE;
  FSocket.SslContext.SslVerifyDepth := 1;
  FSocket.SslContext.SslVerifyFlags := [sslX509_V_FLAG_CRL_CHECK_ALL];
  FSocket.SslContext.SslVerifyPeerModes := [SslVerifyMode_FAIL_IF_NO_PEER_CERT];
  FSocket.SslContext.SslSessionCacheModes := [sslSESS_CACHE_CLIENT];
  FSocket.SslContext.SslVersionMethod := sslV3;
  FSocket.SslContext.InitContext;
  FSocket.SslContext.TrustCert(SSLCert_DevServer);
  FSocket.SslContext.TrustCert(SSLCert_OfficialServer);
end;

destructor TServerSocketCore.Destroy;
begin
  {$IFDEF DEBUG} DebugLn(FDebugId, 'TServerSocketCore.Destroy', ditSocket); {$ENDIF}

  Disconnect;

  FSocket.SslContext.DeInitContext;
  FSocket.SslContext.Free;
  FreeAndNil(FSocket);

  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}

  inherited;
end;

procedure TServerSocketCore.Connect;
begin
  if (FSocket.State <> wsClosed) or
     (Assigned(FSocketConnectThread)) then
    Exit;

  {$IFDEF DEBUG} DebugLn(FDebugId, Format('Connecting to %s:%d...', [FServer, FPort]), ditSocket); {$ENDIF}

  FreeReceiveBuffer;

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

  KillPingTimers;
  KillPingTimeoutTimer;

  FSocketConnectThread := TServerSocketConnectThread.Create(FSocket);
  FSocketConnectThread.FreeOnTerminate := TRUE;
  FSocketConnectThread.OnTerminate := SocketConnectThreadTerminate;
  FSocketConnectThread.Start;
end;

procedure TServerSocketCore.Disconnect;
begin
  KillPingTimers;
  KillPingTimeoutTimer;
  if FSocket.State <> TSocketState.wsClosed then
  begin
    {$IFDEF DEBUG} DebugLn(FDebugId, 'Closing socket...', ditSocket); {$ENDIF}
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
    {$IFDEF DEBUG} DebugLn(FDebugId, 'Starting SSL handshake...', ditSocket); {$ENDIF}
    FSocket.StartSslHandshake;
  end
  else
  begin
    FSocket.LastError := ErrCode;
    SocketError(Sender);
  end;
end;

procedure TServerSocketCore.SocketSessionClosed(Sender: TObject; ErrCode: Word);
begin
  {$IFDEF DEBUG} DebugLn(FDebugId, Format('Session closed [%d]', [ErrCode]), ditException); {$ENDIF}
  Disconnect;
end;

procedure TServerSocketCore.SocketSslHandshakeDone(Sender: TObject; ErrCode: Word; PeerCert: TX509Base; var Disconnect: Boolean);
begin
  if ErrCode = 0 then
  begin
    FSSLHandshakeDone := TRUE;
    ResetInactivityPingTimer;
    ResetPingTimer;
    {$IFDEF DEBUG} DebugLn(FDebugId, 'SSL handshake done', ditSocket); {$ENDIF}
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
  {$IFDEF DEBUG} DebugLn(FDebugId, Format('SSL verify peer result: %d', [Ok]), ditSocket); {$ENDIF}
end;

{$IFDEF DEBUG}
procedure TServerSocketCore.DebugRpcMessage(const ADebugType: TDebugInfoType; const ARpcMessage: TPB_RpcMessage; const ADataObject: TObject; const AStreamSize: Int64 = 0);
var
  dbgtype: TDebugInfoType;
  serialized_object: String;
begin
  if ARpcMessage.MethodId in [Integer(scPing), Integer(srPong)] then
    dbgtype := ditPingPong
  else
    dbgtype := ADebugType;

  if ARpcMessage.DataSize = 0 then
    DebugLn(FDebugId, Format('Method: %s', [TranslateServerCode(ARpcMessage.MethodId)]), dbgtype)
  else
  begin
    if (IsDebugFormAssigned) and
       (IsDebugRTTIEnabled) then
      serialized_object := SerializeObject(ADataObject)
    else
      serialized_object := '';

    if AStreamSize = 0 then
      DebugLn(FDebugId, Format('Method: %s; DataSize: %d', [TranslateServerCode(ARpcMessage.MethodId), ARpcMessage.DataSize]), dbgtype, serialized_object)
    else
      DebugLn(FDebugId, Format('Method: %s; DataSize: %d; StreamSize: %d', [TranslateServerCode(ARpcMessage.MethodId), ARpcMessage.DataSize, AStreamSize]), dbgtype, serialized_object);
  end;
end;
{$ENDIF}

procedure TServerSocketCore.SocketDataAvailable(Sender: TObject; Error: Word);
const
  BUFFER_SIZE = 16 * 1024;
var
  len: Integer;
  rcv_buf: TArray<AnsiChar>;
  rpc_size: Word;
  rpc_message: TPB_RpcMessage;
  data_obj: TObject;
  ptmp: pointer;
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
  begin
    Inc(FReceiveBufferSize, len);
    ReallocMem(FReceiveBuffer, FReceiveBufferSize);
    Move(rcv_buf[0], FReceiveBuffer[FReceiveBufferSize - len], len);
  end;

  if FReceiveBufferSize = 0 then
    Exit;

  rpc_size := PWord(FReceiveBuffer)^;
  if FReceiveBufferSize < SizeOf(rpc_size) + rpc_size then
    Exit;

  rpc_message := TPB_RpcMessage.Create(pointer(Integer(FReceiveBuffer) + SizeOf(rpc_size)), rpc_size);
  try
    if not rpc_message.IsInitialized then
    begin
      {$IFDEF DEBUG} DebugLn(FDebugId, 'RPC message not initialized', ditException); {$ENDIF}
      Exit;
    end;

    if rpc_size + SizeOf(rpc_size) + rpc_message.DataSize > FReceiveBufferSize then
      Exit;

    if ParseRpcMessage(rpc_message, pointer(Integer(FReceiveBuffer) + SizeOf(rpc_size) + rpc_size), data_obj) then
    begin
      ResetInactivityPingTimer;
      {$IFDEF DEBUG} DebugRpcMessage(ditSocketInc, rpc_message, data_obj); {$ENDIF}
      PostMessage(MessageContainer.HWND, WM_MESSAGE_CALLBACK_PROTO, NativeUInt(data_obj), rpc_message.MethodId);
    end;

    ptmp := pointer(Integer(FReceiveBuffer) + SizeOf(rpc_size) + rpc_size + rpc_message.DataSize);
    Dec(FReceiveBufferSize, SizeOf(rpc_size) + rpc_size + rpc_message.DataSize);
    Move(ptmp^, FReceiveBuffer, FReceiveBufferSize);
    ReallocMem(FReceiveBuffer, FReceiveBufferSize);
  finally
    rpc_message.Free;
  end;
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
  last_err: Integer;
{$ENDIF}
begin
  {$IFDEF DEBUG}
  last_err := FSocket.LastError;
  if last_err <> WSAEWOULDBLOCK then // ignore WSAEWOULDBLOCK
    DebugLn(FDebugId, Format('Socket error [%d]: %s', [last_err, WSocketErrorDesc(last_err)]), ditException);
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
  FTimerIdPing := SetTimer(0, FTimerIdPing, Settings.Hardcoded.TCP_PING_INTERVAL * 1000, @TimerProc);
end;

procedure TServerSocketCore.ResetInactivityPingTimer;
begin
  FTimerIdInactivityPing := SetTimer(0, FTimerIdInactivityPing, Settings.Hardcoded.TCP_INACTIVITY_PING_INTERVAL * 1000, @TimerProc);
end;

procedure TServerSocketCore.ResetPingTimeoutTimer;
begin
  FTimerIdPingTimeout := SetTimer(0, FTimerIdPingTimeout, Settings.Hardcoded.TCP_PING_TIMEOUT * 1000, @TimerProc);
  {$IFDEF DEBUG} RefreshDebugForm([dfiSocketState, dfiLatency]); {$ENDIF}
end;

procedure TServerSocketCore.KillPingTimers;
begin
  KillTimer(0, FTimerIdPing);
  FTimerIdPing := 0;
  KillTimer(0, FTimerIdInactivityPing);
  FTimerIdInactivityPing := 0;
end;

procedure TServerSocketCore.KillPingTimeoutTimer;
begin
  KillTimer(0, FTimerIdPingTimeout);
  FTimerIdPingTimeout := 0;
end;

function TServerSocketCore.IsConnected: Boolean;
begin
  result := (Assigned(FSocket)) and (FSocket.State = wsConnected) and (FSSLHandshakeDone);
end;

function TServerSocketCore.ParseRpcMessage(const ARpcMessage: TPB_RpcMessage; const ADataPointer: pointer; out ADataObject: TObject): Boolean;
var
  err: String;
  sc: TServerCodes;
  valid_sc: Boolean;
  gtc: DWORD;
begin
  ADataObject := nil;
  valid_sc := FALSE;
  for sc := Low(TServerCodes) to High(TServerCodes) do
    if ARpcMessage.MethodId = Integer(sc) then
    begin
      valid_sc := TRUE;
      Break;
    end;

  if not valid_sc then
  begin
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('Invalid MethodId received: %d', [ARpcMessage.MethodId]), ditException); {$ENDIF}
    Exit(FALSE);
  end;

  case TServerCodes(ARpcMessage.MethodId) of
    srNotImplemented: begin
      SetString(err, PAnsiChar(ADataPointer), ARpcMessage.DataSize);
      {$IFDEF DEBUG} DebugLn(FDebugId, Format('Received not implemented MethodId: %s', [err]), ditException); {$ENDIF}
    end;
    srLoginReply: ADataObject := TPB_LoginReply.Create(ADataPointer, ARpcMessage.DataSize);
    srLogout: ;
    srRegisterReply: ADataObject := TPB_RegisterReply.Create(ADataPointer, ARpcMessage.DataSize);
    srChangePasswordOk: ;
    seSecondaryLoginDetected: ;
    seAccountConfirmed: ADataObject := TPB_User.Create(ADataPointer, ARpcMessage.DataSize);
    srPlayerLimitOk,
    srResetPlayerBalanceOk: ADataObject := TPB_PlayerLimitParams.Create(ADataPointer, ARpcMessage.DataSize);
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
    srTableAddonOverLimit,
    seTableStatus,
    srTableSitOk,
    srTableSitSeatTaken,
    srTableAddonOk,
    srClubBalanceReached,
    srTableStandUpOk: ADataObject := TPB_TableStatus.Create(ADataPointer, ARpcMessage.DataSize);
    srPong: begin
      gtc := GetTickCount;
      ADataObject := TPB_PingReply.Create(ADataPointer, ARpcMessage.DataSize);
      FLatency := gtc - (ADataObject as TPB_PingReply).Uptime;
      FServerTime := (ADataObject as TPB_PingReply).Servertime + FLatency div 2;
      FTimeOffset := FServerTime - gtc;
      KillPingTimeoutTimer;
      ResetPingTimer;
      {$IFDEF DEBUG} RefreshDebugForm([dfiLatency]); {$ENDIF}
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
    srCreateGameOk,
    srDeleteGameOk,
    seGameChange,
    seGameCreate,
    srNotSitting,
    seGameDelete: ADataObject := TPB_Game.Create(ADataPointer, ARpcMessage.DataSize);
    seUserChange: ADataObject := TPB_UserChangeParams.Create(ADataPointer, ARpcMessage.DataSize);
    srTableStatsReply: ADataObject := TPB_TableStatsReplies.Create(ADataPointer, ARpcMessage.DataSize);
    srContactUsOk: ;
    srTableBuyinLessThanCashout,
    srInvalidTableBuyin: ADataObject := TPB_BuyinError.Create(ADataPointer, ARpcMessage.DataSize);
    srHandHistoryMsg: ADataObject := TPB_ClubHandHistoryReply.Create(ADataPointer, ARpcMessage.DataSize);
    srQueryAssetsReply: ADataObject := TPB_AssetList.Create(ADataPointer, ARpcMessage.DataSize);
    srSubscriptionPlanChange: ADataObject := TPB_SubscriptionPlanChange.Create(ADataPointer, ARpcMessage.DataSize);
  else
    Exit(FALSE);
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('Unhandled MethodId received: %d', [ARpcMessage.MethodId]), ditException); {$ENDIF}
  end;

  if (Assigned(ADataObject)) and
     (not (ADataObject as TProtobufBaseObject).IsInitialized) then
  begin
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('MethodId: %s; ADataObject not initialized', [TranslateServerCode(ARpcMessage.MethodId)]), ditException); {$ENDIF}
    FreeAndNil(ADataObject);
    Exit(FALSE);
  end;

  Exit(TRUE);
end;

procedure TServerSocketCore.SendRawBytes(const AMethodId: TServerCodes; const AProtobuf; const ASize: Integer);
var
  rpc_message: TPB_RpcMessage;
  mstream: TMemoryStream;
  rpcsize: Word;
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

      {$IFDEF DEBUG} DebugRpcMessage(ditSocketOut, rpc_message, nil, mstream.Size); {$ENDIF}
      FSocket.Send(mstream.Memory, mstream.Size);
    finally
      mstream.Free;
    end;
  finally
    rpc_message.Free;
  end;
end;

procedure TServerSocketCore.SendProtobuf(const AMethodId: TServerCodes; const AProtobuf: TProtobufBaseObject);
var
  rpc_message: TPB_RpcMessage;
  mstream: TMemoryStream;
  rpcsize: Word;
begin
  rpc_message := TPB_RpcMessage.Create;
  try
    rpc_message.Methodid := Integer(AMethodId);
    if Assigned(AProtobuf) then
      rpc_message.DataSize := AProtobuf.ProtobufOutputSize;
    mstream := TMemoryStream.Create;
    try
      rpcsize := rpc_message.ProtobufOutputSize;
      mstream.WriteBuffer(rpcsize, SizeOf(rpcsize));
      rpc_message.ProtobufOutput.SaveToStream(mstream);
      if rpc_message.Datasize > 0 then
        AProtobuf.ProtobufOutput.SaveToStream(mstream);

      {$IFDEF DEBUG} DebugRpcMessage(ditSocketOut, rpc_message, AProtobuf, mstream.Size); {$ENDIF}
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

procedure TServerSocketCore.ProcessTimer(const ATimerId: UINT_PTR);
begin
  if (ATimerId = FTimerIdPing) or
     (ATimerId = FTimerIdInactivityPing) then
    Ping;

  if ATimerId = FTimerIdPingTimeout then
  begin
    {$IFDEF DEBUG} DebugLn(FDebugId, 'Ping timeout', ditException); {$ENDIF}
    Disconnect;
  end;
end;

function TServerSocketCore.IsPinging: Boolean;
begin
  result := FTimerIdPingTimeout <> 0;
end;




end.


















