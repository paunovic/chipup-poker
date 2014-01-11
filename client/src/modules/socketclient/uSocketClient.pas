unit uSocketClient;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Classes, System.Generics.Collections, System.SysUtils,
  superobject, OverbyteIcsWndControl, OverbyteIcsWSocket, uPB_RpcMessage, uProtobufBaseObject;

type
  TSocketClient = class
  private
    FSocket               : TSslWSocket;
    FServer               : String;
    FPort                 : Integer;
    FConnectCode          : Integer;
    FReceiveBuffer        : PAnsiChar;
    FReceiveBufferSize    : Integer;

    procedure SocketChangeState(Sender: TObject; OldState, NewState: TSocketState);
    procedure SocketDataAvailable(Sender: TObject; Error: Word);
    procedure SocketError(Sender: TObject);

    function ParseRpcMessage(const ARpcMessage: TPB_RpcMessage; const ADataPointer: pointer; out ADataObject: TObject): Boolean;

  public
    constructor Create(const AServer: String; const APort: Integer);
    destructor Destroy; override;

    procedure Connect;
    procedure Disconnect;
    function IsConnected: Boolean;

    procedure SendCommand(const ACommand: String);
    procedure SendProtobuf(const AMethodId: DWORD; const AProtobuf: TProtobufBaseObject);

    procedure Login(const ALogin, APass: String);
    procedure Logout;
    procedure CreateAccount(const AUsername, APassword, AEMail: String);
    procedure ForgotPassword(const AEMail: String);
    procedure Status;
    procedure CreateClub(const AName, AInvCode: String; const APrivate: Boolean);
    procedure JoinClub(const AId: Int64; const ACode: String);
    procedure LeaveClub(const AId: Int64);
    procedure KickPlayer(const AClubId: Int64; const APlayerId: String);
    procedure GiveOwnership(const AClubId: Int64; const APlayerId: String);
    procedure ChangeClubDetails(const AClubId: Int64; const AJSON: ISuperObject); overload;
    procedure ChangeClubDetails(const AClubId: Int64; const AClubName, AClubCode: String; const APrivate: Boolean); overload;
    procedure DisbandClub(const AClubId: Int64);
    procedure TransferChips(const AClubId: Int64; const APlayerId: String; const AChipAmount: Integer);
    procedure ChangeEMail(const ANewMail: String);
    procedure ChangePassword(const APassword: String);
    procedure SetAvatar(const AAvatarId: String);
    procedure CreateGame(const AClubId: Int64; const AGameName: String; const AGameType, AGameLimit, ASmallBlind, ABigBlind, ASeats: Integer);
    procedure DeleteGame(const AGameId: String);
    procedure EditGame(const AGameId: String; const AGameName: String; const AGameType, AGameLimit, ASmallBlind, ABigBlind, ASeats: Integer);
    procedure ListPublicClubs;

    property Socket                  : TSslWSocket read FSocket;
    property ConnectCode             : Integer read FConnectCode;

  end;

var
  SocketClient: TSocketClient;

implementation

uses
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uServerCodes, uSettings, uCommon,
  uPB_OldMessage, uPB_LoginParams, uPB_StatusReply, uPB_HelloArguments, uPB_RegisterParams,
  uPB_ForgotPasswordParams, uPB_Game, uPB_ListClubsReply, pbOutput,
  uMessageContainer,
  pbInput;


constructor TSocketClient.Create(const AServer: String; const APort: Integer);
begin
  FConnectCode := -1;
  FServer := AServer;
  FPort := APort;
end;

destructor TSocketClient.Destroy;
begin
  inherited;
end;

procedure TSocketClient.Connect;
begin
  {$IFDEF DEBUG} DebugLn(Format('Connecting to %s:%d...', [FServer, FPort]), ditApplication); {$ENDIF}

  FReceiveBufferSize := 0;

  FSocket := TSslWSocket.Create(nil);
  FSocket.MultiThreaded := TRUE;
  FSocket.Addr := FServer;
  FSocket.Port := IntToStr(FPort);
  FSocket.TimeoutConnect := 10000;
  FSocket.ComponentOptions := [wsoSIO_RCVALL];
  FSocket.SslEnable := FALSE;
  FSocket.SslContext := TSslContext.Create(nil);
  FSocket.SslContext.InitContext;
  FSocket.OnChangeState := SocketChangeState;
  FSocket.OnDataAvailable := SocketDataAvailable;
  FSocket.OnError := SocketError;

  FSocket.Connect;
end;

procedure TSocketClient.Disconnect;
begin
  {$IFDEF DEBUG} DebugLn('Closing socket...', ditApplication); {$ENDIF}

  if FSocket.State <> TSocketState.wsClosed then
    FSocket.Close;
  FSocket.SslContext.DeInitContext;
  FSocket.SslContext.Free;
  FSocket.Free;
  FSocket := nil;

  if FReceiveBufferSize > 0 then
    FreeMem(FReceiveBuffer, FReceiveBufferSize);

  FConnectCode := -1;
end;

function TSocketClient.IsConnected: Boolean;
begin
  result := (Assigned(FSocket)) and (FSocket.State = wsConnected) and (FConnectCode = SR_HELLO);
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
  len := FSocket.Receive(@rcv_buf[0], FSocket.RcvdCount);

  if len < 0 then
  begin
    {$IFDEF DEBUG} DebugLn(Format('Socket error: %d', [FSocket.LastError]), ditException); {$ENDIF}
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
    if not rpc_message.IsValid then
    begin
      {$IFDEF DEBUG} DebugLn('Invalid RPC message', ditException); {$ENDIF}
      Exit;
    end;

    if (rpc_size + SizeOf(rpc_size) + rpc_message.DataSize > FReceiveBufferSize) then
      Exit;

    if ParseRpcMessage(rpc_message, pointer(Integer(FReceiveBuffer) + SizeOf(rpc_size) + rpc_size), data_obj) then
    begin
      {$IFDEF DEBUG} DebugLn(Format('MethodId: %d; DataSize: %d', [rpc_message.MethodId, rpc_message.DataSize]), ditSocketInc); {$ENDIF}
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
  {$IFDEF DEBUG} DebugLn(Format('Socket error: %d', [FSocket.LastError]), ditException); {$ENDIF}

  Disconnect;
end;

function TSocketClient.ParseRpcMessage(const ARpcMessage: TPB_RpcMessage; const ADataPointer: pointer; out ADataObject: TObject): Boolean;
begin
  if FConnectCode = -1 then
    FConnectCode := ARpcMessage.MethodId;

  ADataObject := nil;
  result := TRUE;
  case ARpcMessage.MethodId of
    SR_OLD_MESSAGE: begin
      ADataObject := TPB_OldMessage.Create(ADataPointer, ARpcMessage.DataSize);
      if FConnectCode = SR_OLD_MESSAGE then
        FConnectCode := (ADataObject as TPB_OldMessage).Code;
    end;
    SR_NOT_IMPLEMENTED: ;
    SR_HELLO: ADataObject := TPB_HelloArguments.Create(ADataPointer, ARpcMessage.DataSize);
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
    SR_CREATECLUB_NO_GOLD: ;
    SR_CLUB_DETAILS_CHANGE_NO_GOLD: ;
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
  else
    result := FALSE;
  end;
end;

procedure TSocketClient.Login(const ALogin, APass: String);
var
  protobuf: TPB_LoginParams;
begin
  protobuf := TPB_LoginParams.Create(AnsiString(ALogin), AnsiString(APass));
  try
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
  protobuf := TPB_RegisterParams.Create(AnsiString(AEMail), AnsiString(APassword), AnsiString(AUsername));
  try
    SendProtobuf(CMD_REGISTER, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TSocketClient.ForgotPassword(const AEMail: String);
var
  protobuf: TPB_ForgotPasswordParams;
begin
  protobuf := TPB_ForgotPasswordParams.Create(AnsiString(AEMail));
  try
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
  priv: Integer;
begin
  if APrivate then
    priv := 1
  else
    priv := 0;

  SendCommand(Format('create_club %d %s %s', [priv, AInvCode, AName]))
end;

procedure TSocketClient.JoinClub(const AId: Int64; const ACode: String);
begin
  SendCommand(Format('join_club %d %s', [AId, ACode]));
end;

procedure TSocketClient.KickPlayer(const AClubId: Int64; const APlayerId: String);
begin
  SendCommand(Format('kick %d %s', [AClubId, APlayerId]));
end;

procedure TSocketClient.LeaveClub(const AId: Int64);
begin
  SendCommand(Format('leave_club %d', [AId]));
end;

procedure TSocketClient.GiveOwnership(const AClubId: Int64; const APlayerId: String);
begin
  SendCommand(Format('give_owner %d %s', [AClubId, APlayerId]));
end;

procedure TSocketClient.ChangeClubDetails(const AClubId: Int64; const AJSON: ISuperObject);
begin
  SendCommand(Format('club_change_details %d %s', [AClubId, AJSON.AsJSon]));
end;

procedure TSocketClient.ChangeClubDetails(const AClubId: Int64; const AClubName, AClubCode: String; const APrivate: Boolean);
var
  json: ISuperObject;
  priv: Integer;
begin
  json := SO;
  json.S['name'] := AClubName;
  json.S['invcode'] := AClubCode;

  if APrivate then
    priv := 1
  else
    priv := 0;
  json.I['private'] := priv;

  ChangeClubDetails(AClubId, json);
end;

procedure TSocketClient.DisbandClub(const AClubId: Int64);
begin
  SendCommand(Format('delete_club %d', [AClubId]));
end;

procedure TSocketClient.TransferChips(const AClubId: Int64; const APlayerId: String; const AChipAmount: Integer);
begin
  SendCommand(Format('transfer_chips %d %s %d', [AClubId, APlayerId, AChipAmount]));
end;

procedure TSocketClient.ChangeEMail(const ANewMail: String);
begin
  SendCommand(Format('change_email %s', [ANewMail]));
end;

procedure TSocketClient.ChangePassword(const APassword: String);
begin
  SendCommand(Format('change_password %s', [APassword]));
end;

procedure TSocketClient.SetAvatar(const AAvatarId: String);
begin
  SendCommand(Format('set_avatar %s', [AAvatarId]));
end;

procedure TSocketClient.CreateGame(const AClubId: Int64; const AGameName: String; const AGameType, AGameLimit, ASmallBlind, ABigBlind, ASeats: Integer);
begin
  SendCommand(Format('create_game %d %d %d %d %d %d %s', [AClubId, AGameType, AGameLimit, ASmallBlind, ABigBlind, ASeats, AGameName]));
end;

procedure TSocketClient.DeleteGame(const AGameId: String);
begin
  SendCommand(Format('delete_game %s', [AGameId]));
end;

procedure TSocketClient.EditGame(const AGameId, AGameName: String; const AGameType, AGameLimit, ASmallBlind, ABigBlind, ASeats: Integer);
begin
  SendCommand(Format('edit_game %s %d %d %d %d %d %s', [AGameId, AGameType, AGameLimit, ASmallBlind, ABigBlind, ASeats, AGameName]));
end;

procedure TSocketClient.ListPublicClubs;
begin
  SendProtobuf(CMD_LIST_PUBLIC_CLUBS, nil);
end;

procedure TSocketClient.SendCommand(const ACommand: String);
var
  old_message: TPB_OldMessage;
  cmd: String;
  params: String;
begin
  if Pos(' ', ACommand) > 0 then
  begin
    cmd := Copy(ACommand, 1, Pos(' ', ACommand) - 1);
    params := ACommand;
    Delete(params, 1, Length(cmd) + 1);
  end
  else
  begin
    cmd := ACommand;
    params := '';
  end;

  old_message := TPB_OldMessage.Create(-1, AnsiString(params), AnsiString(cmd));
  try
    SendProtobuf(SR_OLD_MESSAGE,old_message);
  finally
    old_message.Free;
  end;
end;

procedure TSocketClient.SendProtobuf(const AMethodId: DWORD; const AProtobuf: TProtobufBaseObject);
var
  rpc_message: TPB_RpcMessage;
  mstream    : TMemoryStream;
  protosize  : Integer;
  pbobject   : TProtobufOutput;
  rpcobject  : TProtoBufOutput;
  rpcsize    : Word;
begin
  if Assigned(AProtobuf) then
  begin
    pbobject := AProtobuf.GetProtobuf;
    protosize := pbobject.getSerializedSize;
  end
  else
  begin
    pbobject := nil;
    protosize := 0;
  end;

  rpc_message := TPB_RpcMessage.Create(AMethodId, protosize);
  try
    rpcobject := rpc_message.GetProtobuf;
    try
      mstream := TMemoryStream.Create;
      try
        rpcsize := rpcobject.getSerializedSize;
        mstream.WriteBuffer(rpcsize, SizeOf(rpcsize));
        rpcobject.SaveToStream(mstream);
        if Assigned(pbobject) then
        begin
          pbobject.SaveToStream(mstream);
          pbobject.Free;
        end;

        {$IFDEF DEBUG} DebugLn(Format('MethodId: %d; DataSize: %d', [rpc_message.MethodId, rpc_message.DataSize]), ditSocketOut); {$ENDIF}
        FSocket.Send(mstream.Memory, mstream.Size);
      finally
        mstream.Free;
      end;
    finally
      rpcobject.Free;
    end;
  finally
    rpc_message.Free;
  end;
end;

end.
