unit uSocketClient;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Generics.Collections, System.SysUtils,
  OverbyteIcsWndControl, OverbyteIcsWSocket, uPB_RpcMessage, uProtobufBaseObject;

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
    constructor Create(const AServer: String; const APort: Integer);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    function IsConnected: Boolean;

    procedure SendProtobuf(const AMethodId: DWORD; const AProtobuf: TProtobufBaseObject);

    procedure Login(const ALogin, APass: String);
    procedure Logout;
    procedure CreateAccount(const AUsername, APassword, AEMail: String);
    procedure ForgotPassword(const AEMail: String);
    procedure Status;
    procedure CreateClub(const AName, AInvCode: String; const APrivate: Boolean);
    procedure JoinClub(const AId: Int64; const ACode: String);
    procedure LeaveClub(const AId: Int64);
    procedure KickPlayer(const AClubId: Int64; const APlayerId: TBytes);
    procedure GiveOwnership(const AClubId: Int64; const APlayerId: TBytes);
    procedure ChangeClubDetails(const AClubId: Int64; const AClubName, AClubCode: String; const APrivate: Boolean); overload;
    procedure DisbandClub(const AClubId: Int64);
    procedure TransferChips(const AClubId: Int64; const APlayerId: TBytes; const AChipAmount: Integer);
    procedure ChangeEMail(const ANewMail: String);
    procedure ChangePassword(const APassword: String);
    procedure SetAvatar(const AAvatarId: TBytes);
    procedure CreateGame(const AClubId: Int64; const AGameName: String; const AGameType, AGameLimit, ASmallBlind, ABigBlind, ASeats: Integer);
    procedure DeleteGame(const AGameId: TBytes);
    procedure EditGame(const AGameId: TBytes; const AGameName: String; const AGameType, AGameLimit, ASmallBlind, ABigBlind, ASeats: Integer);
    procedure ListPublicClubs;
    procedure SendTableChatLine(const ATableId: TBytes; const ALine: String);
    procedure JoinTable(const AGameId: TBytes);
    procedure LeaveTable(const AGameId: TBytes);
    procedure TableSit(const AGameId: TBytes; const ASeatIndex, AChips: Integer);
    procedure TableStandUp(const AGameId: TBytes);
    procedure Ping;

    property Socket: TSslWSocket read FSocket;
  end;

var
  SocketClient: TSocketClient;

implementation

uses
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uServerCodes, uSettings, uCommon,
  uPB_LoginParams, uPB_StatusReply, uPB_HelloReply, uPB_RegisterParams, uPB_Club, uPB_ChangeEMailParams,
  uPB_ForgotPasswordParams, uPB_Game, uPB_ListClubsReply, uPB_TransferChipsParams,
  uPB_KickPlayerParams, uPB_GiveClubOwnershipParams, uPB_ChangePasswordParams,
  uPB_SetAvatarParams, uPB_ChatEvent, uPB_ChatMessage, uPB_TableSit, uPB_TableStatus,
  pbOutput, pbInput, uMessageContainer, Winapi.WinSock;


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
  FSocket.Flush;

  ResetPingTimer;

  try
    FSocket.Connect;
  except
    on E: ESocketException do
    begin
      {$IFDEF DEBUG} DebugLn(Format('Error connecting to server: ', [E.Message]), ditException); {$ENDIF}
    end;
  end;
end;

procedure TSocketClient.Disconnect;
begin
  KillPingTimer;

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
  {$IFDEF DEBUG} DebugLn('Session closed.', ditSocket); {$ENDIF}

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
      MessageContainer.AddServerMessage(rpc_message.MethodId, data_obj);
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

  MessageContainer.AddSocketChangeMessage(OldState, NewState);
end;


procedure TSocketClient.SocketError(Sender: TObject);
begin
  {$IFDEF DEBUG} DebugLn(Format('Socket error: %s', [WSocketErrorDesc(FSocket.LastError)]), ditException); {$ENDIF}
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
  result := (Assigned(FSocket)) and (FSocket.State = wsConnected) and (FConnectCode = SR_HELLO);
end;

function TSocketClient.ParseRpcMessage(const ARpcMessage: TPB_RpcMessage; const ADataPointer: pointer; out ADataObject: TObject): Boolean;
var
  err: String;
begin
  if FConnectCode = -1 then
    FConnectCode := ARpcMessage.MethodId;

  ADataObject := nil;
  result := TRUE;
  case ARpcMessage.MethodId of
    SR_NOT_IMPLEMENTED: begin
      SetString(err, PAnsiChar(ADataPointer), ARpcMessage.DataSize);
      {$IFDEF DEBUG} DebugLn(Format('Received NOT_IMPLEMENTED MethodId: %s', [err]), ditException); {$ENDIF}
    end;
    SR_HELLO: ADataObject := TPB_HelloReply.Create(ADataPointer, ARpcMessage.DataSize);
    SR_LOGIN_OK: ;
    SR_INVALID_LOGIN: ;
    SR_LOGOUT: ;
    SR_REGISTER_OK: ;
    SR_REGISTER_DUPLICATE_MAIL: ;
    SR_REGISTER_DUPLICATE_USERNAME: ;
    SR_REGISTER_INVALID_MAIL: ;
    SR_LIST_CLUBS: ADataObject := TPB_ListClubsReply.Create(ADataPointer, ARpcMessage.DataSize);
    SR_STATUS: ADataObject := TPB_StatusReply.Create(ADataPointer, ARpcMessage.DataSize);
    SR_CREATECLUB_OK: ;
    SR_CREATECLUB_NAME_EXISTS: ;
    SR_CREATECLUB_INVALID_NAME: ;
    SR_CREATECLUB_INVALID_CODE: ;
    SR_JOINCLUB_OK: ;
    SR_JOINCLUB_INVALID_ID: ;
    SR_JOINCLUB_INVALID_CODE: ;
    SR_JOINCLUB_ALREADY_MEMBER: ;
    SR_LEAVECLUB_OK: ;
    SR_LEAVECLUB_INVALID_ID: ;
    SR_KICKPLAYER_OK: ;
    SR_KICKPLAYER_INVALID_CLUB_ID: ;
    SR_KICKPLAYER_INVALID_PLAYER_ID: ;
    SR_OWNERSHIP_GIVEAWAY_NOT_OWNER: ;
    SR_OWNERSHIP_GIVEAWAY_INVALID_PLAYER_ID: ;
    SR_OWNERSHIP_GIVEAWAY_INVALID_CLUB_ID: ;
    SR_OWNERSHIP_GIVEAWAY_OK: ;
    SR_CLUB_DETAILS_CHANGE_OK: ;
    SR_CLUB_DETAILS_CLUBNAME_EXISTS: ;
    SR_CLUB_DISBAND_OK: ;
    SR_CLUB_TRANFER_CHIPS_OK: ;
    SR_CLUB_TRANFER_CHIPS_INVALID_AMOUNT: ;
    SR_CREATECLUB_NO_TOKENS: ;
    SR_CLUB_DETAILS_CHANGE_NO_TOKENS: ;
    SR_CHANGE_MAIL_OK: ;
    SR_CHANGE_MAIL_INVALID_MAIL: ;
    SR_CHANGE_MAIL_DUPLICATE_MAIL: ;
    SR_CHANGE_PASSWORD_OK: ;
    SR_CHANGE_PASSWORD_INVALID_PASSWORD: ;
    SR_CHANGE_AVATAR_OK: ;
    SR_CHANGE_AVATAR_INVALID_ID: ;
    SR_CREATE_GAME_OK: ;
    SR_DELETE_GAME_OK: ;
    SR_EDIT_GAME_OK: ;
    SR_SECONDARY_LOGIN_DETECTED: ;
    SR_ACCOUNT_CONFIRMED: ADataObject := TPB_TableStatus.Create(ADataPointer, ARpcMessage.DataSize);
    EVENT_CHAT: ADataObject := TPB_ChatEvent.Create(ADataPointer, ARpcMessage.DataSize);
    SR_TABLE_STATUS,
    SR_TABLE_SIT_OK,
    SR_TABLE_SIT_SEAT_TAKEN,
    SR_TABLE_STAND_UP_OK: ADataObject := TPB_TableStatus.Create(ADataPointer, ARpcMessage.DataSize);
    SR_PONG: begin
      KillPingTimeoutTimer;
      ResetPingTimer;
    end;
  else
    result := FALSE;
    {$IFDEF DEBUG} DebugLn(Format('Invalid MethodId received: %d', [ARpcMessage.MethodId]), ditException); {$ENDIF}
  end;
end;

procedure TSocketClient.SendProtobuf(const AMethodId: DWORD; const AProtobuf: TProtobufBaseObject);
var
  rpc_message: TPB_RpcMessage;
  mstream    : TMemoryStream;
  rpcsize    : Word;
begin
  rpc_message := TPB_RpcMessage.Create;
  try
    rpc_message.Methodid := AMethodId;
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
    SendProtobuf(CMD_LOGIN, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TSocketClient.Logout;
begin
  SendProtobuf(CMD_LOGOUT, nil);
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
    SendProtobuf(CMD_REGISTER, protobuf);
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
    SendProtobuf(CMD_FORGOT_PASSWORD, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TSocketClient.Status;
begin
  SendProtobuf(CMD_STATUS, nil);
end;

procedure TSocketClient.CreateClub(const AName, AInvCode: String; const APrivate: Boolean);
var
  protobuf: TPB_Club;
begin
  protobuf := TPB_Club.Create;
  try
    protobuf.Name := AName;
    protobuf.IsPrivate := APrivate;
    protobuf.Password := AInvCode;
    SendProtobuf(CMD_CREATE_CLUB, protobuf);
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
    SendProtobuf(CMD_JOIN_CLUB, protobuf);
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
    SendProtobuf(CMD_KICK_PLAYER, protobuf);
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
    SendProtobuf(CMD_LEAVE_CLUB, protobuf);
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
    SendProtobuf(CMD_GIVE_CLUB_OWNERSHIP, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TSocketClient.ChangeClubDetails(const AClubId: Int64; const AClubName, AClubCode: String; const APrivate: Boolean);
var
  protobuf: TPB_Club;
begin
  protobuf := TPB_Club.Create;
  try
    protobuf.Seq := AClubId;
    protobuf.Name := AClubName;
    protobuf.Password := AClubCode;
    protobuf.IsPrivate := APrivate;
    SendProtobuf(CMD_CHANGE_CLUB_DETAILS, protobuf);
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
    SendProtobuf(CMD_DELETE_CLUB, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TSocketClient.TransferChips(const AClubId: Int64; const APlayerId: TBytes; const AChipAmount: Integer);
var
  protobuf: TPB_TransferChipsParams;
begin
  protobuf := TPB_TransferChipsParams.Create;
  try
    protobuf.ClubSeq := AClubId;
    protobuf.PlayerMongoId := APlayerId;
    protobuf.ChipAmount := AChipAmount;
    SendProtobuf(CMD_TRANSFER_CHIPS, protobuf);
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
    SendProtobuf(CMD_CHANGE_EMAIL, protobuf);
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
    SendProtobuf(CMD_CHANGE_PASSWORD, protobuf);
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
    SendProtobuf(CMD_SET_AVATAR, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TSocketClient.CreateGame(const AClubId: Int64; const AGameName: String; const AGameType, AGameLimit, ASmallBlind, ABigBlind, ASeats: Integer);
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
    protobuf.Seats := ASeats;
    SendProtobuf(CMD_CREATE_GAME, protobuf);
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
    SendProtobuf(CMD_DELETE_GAME, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TSocketClient.EditGame(const AGameId: TBytes; const AGameName: String; const AGameType, AGameLimit, ASmallBlind, ABigBlind, ASeats: Integer);
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
    protobuf.Seats := ASeats;
    SendProtobuf(CMD_EDIT_GAME, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TSocketClient.ListPublicClubs;
begin
  SendProtobuf(CMD_LIST_PUBLIC_CLUBS, nil);
end;

procedure TSocketClient.SendTableChatLine(const ATableId: TBytes; const ALine: String);
var
  protobuf: TPB_ChatEvent;
  pbmsg   : TPB_ChatMessage;
begin
  protobuf := TPB_ChatEvent.Create;
  try
    protobuf.Event := ceUserMessage;
    protobuf.TableId := ATableId;
    pbmsg := TPB_ChatMessage.Create;
    pbmsg.Msg := ALine;
    protobuf.Msg := pbmsg;
    SendProtobuf(EVENT_CHAT, protobuf);
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
    SendProtobuf(CMD_TABLE_JOIN, protobuf);
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
    SendProtobuf(CMD_TABLE_LEAVE, protobuf);
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
    SendProtobuf(CMD_TABLE_SIT, protobuf);
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
    SendProtobuf(CMD_TABLE_STAND_UP, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TSocketClient.Ping;
begin
  SendProtobuf(CMD_PING, nil);
end;



end.
