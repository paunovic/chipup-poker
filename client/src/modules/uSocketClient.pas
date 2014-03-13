unit uSocketClient;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Generics.Collections, System.SysUtils,
  OverbyteIcsWndControl, OverbyteIcsWSocket, uPB_RpcMessage, uProtobufBaseObject, uServerCodes, uPB_Game;

type
  TSocketClient = class
  private
    const
      TIMER_ID_PING         = 1;
      TIMER_ID_PING_TIMEOUT = 2;

    var
      FSocket                : TSslWSocket;
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

    procedure SocketSessionConnected(Sender: TObject; ErrCode: Word);
    procedure SocketSessionClosed(Sender: TObject; ErrCode: Word);
    procedure SocketSslHandshakeDone(Sender: TObject; ErrCode: Word; PeerCert: TX509Base; var Disconnect: Boolean);
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
    procedure CreateClub(const AName, AInvCode: String; const APrivate: Boolean; const AClubRake: Integer);
    procedure JoinClub(const AId: Int64; const ACode: String);
    procedure LeaveClub(const AId: Int64);
    procedure KickPlayer(const AClubId: Int64; const APlayerId: TBytes);
    procedure GiveOwnership(const AClubId: Int64; const APlayerId: TBytes);
    procedure ChangeClubDetails(const AClubId: Int64; const AClubName, AClubCode: String; const APrivate: Boolean; const AClubRake: Integer);
    procedure DisbandClub(const AClubId: Int64);
    procedure TransferChips(const APlayerId: TBytes; const AChipAmount: Integer);
    procedure ChangeEMail(const ANewMail: String);
    procedure ChangePassword(const APassword: String);
    procedure SetAvatar(const AAvatarId: TBytes);
    procedure CreateGame(const AClubId: Int64; const AGameName: String; const AGameType: TGameType; const AGameLimit: TGameLimit; const ASmallBlind, ABigBlind, ABuyinMin, ABuyinMax, ASeats: Integer);
    procedure DeleteGame(const AGameId: TBytes);
    procedure EditGame(const AGameId: TBytes; const AGameName: String; const AGameType: TGameType; const AGameLimit: TGameLimit; const ASmallBlind, ABigBlind, ABuyinMin, ABuyinMax, ASeats: Integer);
    procedure ListPublicClubs;
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

    property Socket: TSslWSocket read FSocket;
    property Latency: Integer read FLatency;
    property ServerTime: UINT64 read FServerTime;
    property TimeOffset: UINT64 read FTimeOffset;
  end;

var
  SocketClient: TSocketClient;

implementation

uses
  Winapi.WinSock, uSettings, uCommon, pbOutput, pbInput, uMessageContainer,
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uPB_LoginParams, uPB_StatusReply, uPB_HelloReply, uPB_RegisterParams, uPB_Club, uPB_ChangeEMailParams, uPB_ForgotPasswordParams,
  uPB_ListClubsReply, uPB_TransferChipsParams, uPB_ClubCommandReply, uPB_SetAvatarReply, uPB_KickPlayerParams, uPB_PingParams, uPB_PingReply,
  uPB_GiveClubOwnershipParams, uPB_ChangePasswordParams, uPB_RegisterReply, uPB_LoginReply, uPB_GetUserParams, uPB_SetAvatarParams,
  uPB_ChatEvent, uPB_ChatMessage, uPB_TableSit, uPB_TableStatus, uPB_ChangeSuspendState, uPB_ChangeMailReply, uPB_TableEvent, uPB_TableBoolFlag,
  uPB_PutChips, uMainDataModule;

var
  FConnectThreadId: DWORD;


class procedure TSocketClient.Initialize(const AServer: String; const APort: Integer);
begin
  SocketClient := TSocketClient.Create(AServer, APort);
end;

class procedure TSocketClient.Deinitialize;
begin
  FreeAndNil(SocketClient);
end;


function DoConnect(AParameter: pointer): Integer;
begin
  try
    SocketClient.Socket.Connect;
  except
    on E: Exception do
    begin
      {$IFDEF DEBUG} DebugLn(Format('Error connecting to server: ', [E.Message]), ditException); {$ENDIF}
      if Assigned(SocketClient) then
        SocketClient.SocketError(nil);
    end;
  end;

  result := 0;
  EndThread(0);
end;

constructor TSocketClient.Create(const AServer: String; const APort: Integer);
begin
  FConnectCode := -1;
  FServer := AServer;
  FPort := APort;

  FInternalMessageHandler := AllocateHWnd(WndMethod);

  FSocket := TSslWSocket.Create(nil);
  FSocket.SslContext := TSslContext.Create(nil);
  FSocket.SslContext.InitContext;
end;

destructor TSocketClient.Destroy;
begin
  {$IFDEF DEBUG} DebugLn('TSocketClient.Destroy', ditSocket); {$ENDIF}

  FSocket.SslContext.DeInitContext;
  FSocket.SslContext.Free;
  FSocket.Free;

  DeallocateHWnd(FInternalMessageHandler);

  inherited;
end;

procedure TSocketClient.Connect;
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
  FSocket.OnSslHandshakeDone := SocketSslHandshakeDone;

  ResetPingTimer;

  if FConnectThreadId <> 0 then
    TerminateThread(FConnectThreadId, 0);

  CloseHandle(BeginThread(nil, 0, @DoConnect, Addr(FSocket), 0, FConnectThreadId));
end;

procedure TSocketClient.Disconnect;
begin
  KillPingTimer;

  if FConnectThreadId <> 0 then
  begin
    TerminateThread(FConnectThreadId, 0);
    FConnectThreadId := 0;
  end;

  if FSocket.State <> TSocketState.wsClosed then
  begin
    {$IFDEF DEBUG} DebugLn('Closing socket...', ditSocket); {$ENDIF}
    FSocket.Close;
    while (Assigned(FSocket)) and (FSocket.State <> wsClosed) do
      FSocket.ProcessMessages;
  end;
end;

procedure TSocketClient.SocketSessionConnected(Sender: TObject; ErrCode: Word);
begin
  if ErrCode = 0 then
  begin
    {$IFDEF DEBUG} DebugLn('Connected. Starting SSL handshake...', ditSocket); {$ENDIF}
    FSocket.StartSslHandshake;
  end
  else
  begin
    FSocket.LastError := ErrCode;
    SocketError(Sender);
  end;
end;

procedure TSocketClient.SocketSessionClosed(Sender: TObject; ErrCode: Word);
begin
  {$IFDEF DEBUG} DebugLn('Session closed.', ditException); {$ENDIF}

  if FReceiveBufferSize > 0 then
    FreeMem(FReceiveBuffer, FReceiveBufferSize);

  FConnectCode := -1;
end;

procedure TSocketClient.SocketSslHandshakeDone(Sender: TObject; ErrCode: Word; PeerCert: TX509Base; var Disconnect: Boolean);
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

procedure TSocketClient.SocketDataAvailable(Sender: TObject; Error: Word);
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

procedure TSocketClient.SocketChangeState(Sender: TObject; OldState, NewState: TSocketState);
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


procedure TSocketClient.SocketError(Sender: TObject);
begin
  {$IFDEF DEBUG} DebugLn(Format('Socket error: %s', [WSocketErrorDesc(FSocket.LastError)]), ditException); {$ENDIF}

  case FSocket.State of
    wsConnected: ;
    wsClosed: ;
  else
    Disconnect;
  end;
end;

procedure TSocketClient.ResetPingTimer;
begin
  SetTimer(FInternalMessageHandler, TIMER_ID_PING, Settings.Hardcoded.TCP_PING_INTERVAL * 1000, nil);
end;

procedure TSocketClient.ResetPingTimeoutTimer;
begin
  SetTimer(FInternalMessageHandler, TIMER_ID_PING_TIMEOUT, Settings.Hardcoded.TCP_PING_TIMEOUT * 1000, nil);
end;

procedure TSocketClient.KillPingTimer;
begin
  KillTimer(FInternalMessageHandler, TIMER_ID_PING);
end;

procedure TSocketClient.KillPingTimeoutTimer;
begin
  KillTimer(FInternalMessageHandler, TIMER_ID_PING_TIMEOUT);
end;

procedure TSocketClient.WndMethod(var AMessage: TMessage);
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

function TSocketClient.IsConnected: Boolean;
begin
  result := (Assigned(FSocket)) and (FSocket.State = wsConnected) and (FConnectCode = Integer(srHello));
end;

function TSocketClient.ParseRpcMessage(const ARpcMessage: TPB_RpcMessage; const ADataPointer: pointer; out ADataObject: TObject): Boolean;
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
    seAccountConfirmed: ;
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
  else
    result := FALSE;
    {$IFDEF DEBUG} DebugLn(Format('Unhandled MethodId received: %d', [ARpcMessage.MethodId]), ditException); {$ENDIF}
  end;
end;

procedure TSocketClient.SendRawBytes(const AMethodId: TServerCodes; const AProtobuf; const ASize: Integer);
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

procedure TSocketClient.SendProtobuf(const AMethodId: TServerCodes; const AProtobuf: TProtobufBaseObject);
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

procedure TSocketClient.Login(const ALogin, APass: String);
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

procedure TSocketClient.Logout;
begin
  SendProtobuf(scLogout, nil);
end;

procedure TSocketClient.CreateAccount(const AUsername, APassword, AEMail: String);
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

procedure TSocketClient.ForgotPassword(const AEMail: String);
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

procedure TSocketClient.Status;
begin
  SendProtobuf(scStatus, nil);
end;

procedure TSocketClient.CreateClub(const AName, AInvCode: String; const APrivate: Boolean; const AClubRake: Integer);
var
  protobuf: TPB_Club;
begin
  protobuf := TPB_Club.Create;
  try
    protobuf.Name := AName;
    protobuf.IsPrivate := APrivate;
    protobuf.Password := AInvCode;
    protobuf.Rake := AClubRake;
    SendProtobuf(scCreateClub, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TSocketClient.JoinClub(const AId: Int64; const ACode: String);
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

procedure TSocketClient.KickPlayer(const AClubId: Int64; const APlayerId: TBytes);
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

procedure TSocketClient.LeaveClub(const AId: Int64);
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

procedure TSocketClient.GiveOwnership(const AClubId: Int64; const APlayerId: TBytes);
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

procedure TSocketClient.ChangeClubDetails(const AClubId: Int64; const AClubName, AClubCode: String; const APrivate: Boolean; const AClubRake: Integer);
var
  protobuf: TPB_Club;
begin
  protobuf := TPB_Club.Create;
  try
    protobuf.Seq := AClubId;
    protobuf.Name := AClubName;
    protobuf.Password := AClubCode;
    protobuf.IsPrivate := APrivate;
    protobuf.Rake := AClubRake;
    SendProtobuf(scChangeClubDetails, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TSocketClient.DisbandClub(const AClubId: Int64);
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

procedure TSocketClient.TransferChips(const APlayerId: TBytes; const AChipAmount: Integer);
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

procedure TSocketClient.ChangeEMail(const ANewMail: String);
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

procedure TSocketClient.ChangePassword(const APassword: String);
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

procedure TSocketClient.SetAvatar(const AAvatarId: TBytes);
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

procedure TSocketClient.CreateGame(const AClubId: Int64; const AGameName: String; const AGameType: TGameType; const AGameLimit: TGameLimit; const ASmallBlind, ABigBlind, ABuyinMin, ABuyinMax, ASeats: Integer);
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

procedure TSocketClient.DeleteGame(const AGameId: TBytes);
var
  protobuf: TPB_Game;
begin
  protobuf := TPB_Game.Create;
  try
    protobuf.MongoId := AGameId;
    SendProtobuf(scDeleteGame, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TSocketClient.EditGame(const AGameId: TBytes; const AGameName: String; const AGameType: TGameType; const AGameLimit: TGameLimit; const ASmallBlind, ABigBlind, ABuyinMin, ABuyinMax, ASeats: Integer);
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

procedure TSocketClient.ListPublicClubs;
begin
  SendProtobuf(scListPublicClubs, nil);
end;

procedure TSocketClient.SendTableChatLine(const AGameId: TBytes; const ALine: String);
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

procedure TSocketClient.JoinTable(const AGameId: TBytes);
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

procedure TSocketClient.LeaveTable(const AGameId: TBytes);
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

procedure TSocketClient.TableSit(const AGameId: TBytes; const ASeatIndex, AChips: Integer);
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

procedure TSocketClient.TableAddOn(const AGameId: TBytes; const AChips: Integer);
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

procedure TSocketClient.TableStandUp(const AGameId: TBytes);
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

procedure TSocketClient.Ping;
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

procedure TSocketClient.ChangePlayerSuspendState(const AClubId, APlayerId: TBytes; const ASuspended: Boolean);
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

procedure TSocketClient.GetUserInfos(const AMongoIds: TArray<TBytes>);
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

procedure TSocketClient.Fold(const AGameId: TBytes);
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

procedure TSocketClient.PutChips(const AGameId: TBytes; const AChipAmount: Integer);
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

procedure TSocketClient.TablePlayNow(const AGameId: TBytes);
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

procedure TSocketClient.TableSitOutNextHand(const AGameId: TBytes; const AFlag: Boolean);
begin
  TableBoolFlag(scTableSitOutNextHand, AGameId, AFlag);
end;

procedure TSocketClient.TableSitOutNextBB(const AGameId: TBytes; const AFlag: Boolean);
begin
  TableBoolFlag(scTableSitOutNextBB, AGameId, AFlag);
end;

procedure TSocketClient.TableBoolFlag(const ACommand: TServerCodes; const AGameId: TBytes; const AFlag: Boolean);
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

procedure TSocketClient.ResendVerificationMail;
begin
  SendProtobuf(scResendVerificationMail, nil);
end;



end.
