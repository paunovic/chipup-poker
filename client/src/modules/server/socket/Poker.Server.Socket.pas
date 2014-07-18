unit Poker.Server.Socket;

interface

uses
  System.SysUtils, System.Generics.Collections, Poker.Server.Socket.Core, Poker.Protobufs.Objects.User,
  Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.CloseGameData, Poker.Protobufs.Objects.TableStatus, Poker.Protobufs.Enum.ServerCodes,
  Poker.Protobufs.Objects.ContactMessage, Poker.Protobufs.Objects.UpdateFileInfo;

type
  TServerSocket = class(TServerSocketCore)
  private
  public
    class procedure Initialize(const AServer: String; const APort: Integer);
    class procedure Deinitialize;

    procedure Login(const ALogin, APass: String);
    procedure Logout;
    procedure CreateAccount(const AUsername, APassword, AEMail: String);
    procedure ForgotPassword(const AEMail: String);
    procedure CreateClub(const AName, AInvCode: String; const AClubRake: Integer);
    procedure JoinClub(const AClubId: Int64; const ACode: String);
    procedure LeaveClub(const AClubId: TBytes);
    procedure KickPlayer(const AClubId: TBytes; const APlayerId: TBytes);
    procedure GiveOwnership(const AClubId: TBytes; const APlayerId: TBytes);
    procedure ChangeClubDetails(const AClubId: TBytes; const AClubName, AClubCode: String; const AClubRake: Integer; const ADefaultPlayerLimit: UINT32; const AUnlimitedDefaultBalance: Boolean);
    procedure DisbandClub(const AClubId: TBytes);
    procedure ChangeEMail(const ANewMail: String);
    procedure ChangePassword(const APassword: String);
    procedure SetAvatar(const AAvatarId: TBytes);
    procedure CreateGame(const AClubId: TBytes; const AGameName: String; const AGameType: TGameType; const AGameLimit: TGameLimit; const ABlinds: TGameBlinds; const ABuyinMin, ABuyinMax, ASeats: Integer);
    procedure CloseGame(const AGameId: TBytes; const ATimestamp: TCloseGameTime);
    procedure SendTableChatLine(const AGameId: TBytes; const ALine: String);
    procedure JoinTable(const AGameId: TBytes);
    procedure LeaveTable(const AGameId: TBytes);
    procedure TableSit(const AGameId: TBytes; const ASeatIndex, AChips: Integer);
    procedure TableAddOn(const AGameId: TBytes; const AChips: Integer);
    procedure TableStandUp(const AGameId: TBytes);
    procedure TablePlayNow(const AGameId: TBytes);
    procedure TableSitOutNextHand(const AGameId: TBytes; const AFlag: Boolean);
    procedure TableSitOutNextBB(const AGameId: TBytes; const AFlag: Boolean);
    procedure ChangePlayerSuspendState(const AClubId, APlayerId: TBytes; const ASuspended: Boolean);
    procedure GetUserInfos(const AMongoIds: array of TBytes);
    procedure Fold(const AGameId: TBytes);
    procedure PutChips(const AGameId: TBytes; const AChipAmount: Integer; const ATableState: TTableState);
    procedure TableBoolFlag(const ACommand: TServerCodes; const AGameId: TBytes; const AFlag: Boolean);
    procedure ResendVerificationMail;
    procedure ShowCards(const AGameId: TBytes);
    procedure QueryTableStats(const ATables: array of TBytes);
    procedure ContactUs(const AReason: TContactReason; const AMessage: String);
    procedure Hello(const ADebug: Boolean; const AFiles: TObjectList<TPB_UpdateFileInfo>);
    procedure SetPlayerLimit(const AClubId, AMemberId: TBytes; const ALimit: UINT32; const AUnlimited: Boolean);
    procedure ResetPlayerBalance(const AClubId, AMemberId: TBytes);
    procedure QueryAssets(const AAssets: TObjectList<TPB_UpdateFileInfo>);
    procedure SubscriptionPlanChange(const ASubscriptionPlan: TPlayerSubscriptionPlan);

    {$IFDEF DEBUG}
    procedure CrashTest;
    {$ENDIF}
  end;

var
  ServerSocket: TServerSocket;

implementation

uses
  Winapi.Windows,
  Poker.Protobufs.Objects.LoginParams, Poker.Protobufs.Objects.StatusReply, Poker.Protobufs.Objects.HelloReply,
  Poker.Protobufs.Objects.RegisterParams, Poker.Protobufs.Objects.Club, Poker.Protobufs.Objects.ChangeEMailParams,
  Poker.Protobufs.Objects.ForgotPasswordParams, Poker.Protobufs.Objects.ListClubsReply, Poker.Protobufs.Objects.TransferChipsParams,
  Poker.Protobufs.Objects.ClubCommandReply, Poker.Protobufs.Objects.SetAvatarReply, Poker.Protobufs.Objects.KickPlayerParams,
  Poker.Protobufs.Objects.PingParams, Poker.Protobufs.Objects.PingReply, Poker.Protobufs.Objects.GiveClubOwnershipParams,
  Poker.Protobufs.Objects.ChangePasswordParams, Poker.Protobufs.Objects.RegisterReply, Poker.Protobufs.Objects.LoginReply,
  Poker.Protobufs.Objects.GetUserParams, Poker.Protobufs.Objects.SetAvatarParams, Poker.Protobufs.Objects.ChatEvent,
  Poker.Protobufs.Objects.ChatMessage, Poker.Protobufs.Objects.TableSit, Poker.Protobufs.Objects.ChangeSuspendState,
  Poker.Protobufs.Objects.ChangeMailReply, Poker.Protobufs.Objects.TableBoolFlag, Poker.Protobufs.Objects.PutChips,
  Poker.Protobufs.Objects.UserChangeParams, Poker.Protobufs.Objects.QueryTableStats, Poker.Protobufs.Objects.TableStatsReplies,
  Poker.Protobufs.Objects.ClubHandHistoryReply, Poker.Protobufs.Objects.BuyinError, Poker.Protobufs.Objects.PlayerLimitParams,
  Poker.Protobufs.Objects.AssetList, Poker.Protobufs.Objects.HelloParams, Poker.Protobufs.Objects.SubscriptionPlanChange;


class procedure TServerSocket.Initialize(const AServer: String; const APort: Integer);
begin
  ServerSocket := TServerSocket.Create(AServer, APort);
end;

class procedure TServerSocket.Deinitialize;
begin
  FreeAndNil(ServerSocket);
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

procedure TServerSocket.JoinClub(const AClubId: Int64; const ACode: String);
var
  protobuf: TPB_Club;
begin
  protobuf := TPB_Club.Create;
  try
    protobuf.Seq := AClubId;
    protobuf.Password := ACode;
    SendProtobuf(scJoinClub, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.KickPlayer(const AClubId: TBytes; const APlayerId: TBytes);
var
  protobuf: TPB_KickPlayerParams;
begin
  protobuf := TPB_KickPlayerParams.Create;
  try
    protobuf.ClubMongoId := AClubId;
    protobuf.PlayerMongoId := APlayerId;
    SendProtobuf(scKickPlayer, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.LeaveClub(const AClubId: TBytes);
var
  protobuf: TPB_Club;
begin
  protobuf := TPB_Club.Create;
  try
    protobuf.MongoId := AClubId;
    SendProtobuf(scLeaveClub, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.GiveOwnership(const AClubId: TBytes; const APlayerId: TBytes);
var
  protobuf: TPB_GiveClubOwnershipParams;
begin
  protobuf := TPB_GiveClubOwnershipParams.Create;
  try
    protobuf.ClubMongoId := AClubId;
    protobuf.PlayerMongoId := APlayerId;
    SendProtobuf(scGiveClubOwnership, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.ChangeClubDetails(const AClubId: TBytes; const AClubName, AClubCode: String; const AClubRake: Integer; const ADefaultPlayerLimit: UINT32; const AUnlimitedDefaultBalance: Boolean);
var
  protobuf: TPB_Club;
begin
  protobuf := TPB_Club.Create;
  try
    protobuf.MongoId := AClubId;
    protobuf.Name := AClubName;
    protobuf.Password := AClubCode;
    protobuf.Rake := AClubRake;
    protobuf.DefaultBalanceLimit := ADefaultPlayerLimit;
    protobuf.UnlimitedDefaultBalance := AUnlimitedDefaultBalance;
    SendProtobuf(scChangeClubDetails, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.DisbandClub(const AClubId: TBytes);
var
  protobuf: TPB_Club;
begin
  protobuf := TPB_Club.Create;
  try
    protobuf.MongoId := AClubId;
    SendProtobuf(scDeleteClub, protobuf);
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

procedure TServerSocket.CreateGame(const AClubId: TBytes; const AGameName: String; const AGameType: TGameType; const AGameLimit: TGameLimit; const ABlinds: TGameBlinds; const ABuyinMin, ABuyinMax, ASeats: Integer);
var
  protobuf: TPB_Game;
begin
  protobuf := TPB_Game.Create;
  try
    protobuf.Gamename := AGameName;
    protobuf.ClubMongoid := AClubId;
    protobuf.GameType := AGameType;
    protobuf.GameLimit := AGameLimit;
    protobuf.Blinds := ABlinds;
    protobuf.BuyinMin := ABuyinMin;
    protobuf.BuyinMax := ABuyinMax;
    protobuf.Seats := ASeats;
    SendProtobuf(scCreateGame, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.CloseGame(const AGameId: TBytes; const ATimestamp: TCloseGameTime);
var
  protobuf: TPB_CloseGameData;
begin
  protobuf := TPB_CloseGameData.Create;
  try
    protobuf.Gameid := AGameId;
    protobuf.Timestamp := ATimestamp;
    SendProtobuf(scCloseGame, protobuf);
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
    Assert(Length(AGameId) = 12);
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

procedure TServerSocket.GetUserInfos(const AMongoIds: array of TBytes);
var
  protobuf: TPB_GetUserParams;
  C1: Integer;
begin
  protobuf := TPB_GetUserParams.Create;
  try
    for C1 := Low(AMongoIds) to High(AMongoIds) do
    begin
      Assert(Length(AMongoIds[C1]) = 12);
      protobuf.UserMongoIds.Add(AMongoIds[C1]);
    end;
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

procedure TServerSocket.PutChips(const AGameId: TBytes; const AChipAmount: Integer; const ATableState: TTableState);
var
  protobuf: TPB_PutChips;
begin
  protobuf := TPB_PutChips.Create;
  try
    protobuf.TableMongoId := AGameId;
    protobuf.ChipAmount := AChipAmount;
    protobuf.CurrentState := ATableState;
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
    SendProtobuf(scShowCards, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.QueryTableStats(const ATables: array of TBytes);
var
  protobuf: TPB_QueryTableStats;
  C1: Integer;
begin
  protobuf := TPB_QueryTableStats.Create;
  try
    for C1 := Low(ATables) to High(ATables) do
      protobuf.Gameid.Add(ATables[C1]);
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

procedure TServerSocket.Hello(const ADebug: Boolean; const AFiles: TObjectList<TPB_UpdateFileInfo>);
var
  protobuf: TPB_HelloParams;
begin
  protobuf := TPB_HelloParams.Create;
  try
    protobuf.Debug := ADebug;
    protobuf.Files.AddRange(AFiles);
    SendProtobuf(scHello, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure StringToBytes(const AString: String; var ABytes: TBytes);
var
  C1: Integer;
begin
  Assert(Length(AString) mod 2 = 0);
  SetLength(ABytes, Length(AString) div 2);
  for C1 := 0 to Length(AString) div 2 - 1 do
    ABytes[C1] := StrToInt('$' + Copy(AString, C1 * 2 + 1, 2));
end;

procedure TServerSocket.SetPlayerLimit(const AClubId, AMemberId: TBytes; const ALimit: UINT32; const AUnlimited: Boolean);
var
  protobuf: TPB_PlayerLimitParams;
begin
  protobuf := TPB_PlayerLimitParams.Create;
  try
    protobuf.Clubid := AClubId;
    protobuf.Userid := AMemberId;
    protobuf.Limit := ALimit;
    protobuf.Unlimited := AUnlimited;
    SendProtobuf(scSetPlayerLimit, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.ResetPlayerBalance(const AClubId, AMemberId: TBytes);
var
  protobuf: TPB_PlayerLimitParams;
begin
  protobuf := TPB_PlayerLimitParams.Create;
  try
    protobuf.Clubid := AClubId;
    protobuf.Userid := AMemberId;
    protobuf.Limit := 0;
    protobuf.Unlimited := FALSE;
    SendProtobuf(scResetPlayerBalance, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.QueryAssets(const AAssets: TObjectList<TPB_UpdateFileInfo>);
var
  protobuf: TPB_AssetList;
begin
  protobuf := TPB_AssetList.Create;
  try
    protobuf.Assets.AddRange(AAssets);
    SendProtobuf(scQueryAssets, protobuf);
  finally
    protobuf.Free;
  end;
end;

procedure TServerSocket.SubscriptionPlanChange(const ASubscriptionPlan: TPlayerSubscriptionPlan);
var
  protobuf: TPB_SubscriptionPlanChange;
begin
  protobuf := TPB_SubscriptionPlanChange.Create;
  try
    protobuf.SubscriptionPlan := ASubscriptionPlan;
    SendProtobuf(scSubscriptionPlanChange, protobuf);
  finally
    protobuf.Free;
  end;
end;


{$IFDEF DEBUG}
procedure TServerSocket.CrashTest;
var
  pb: TPB_HelloParams;
  tmp: String;
  bytes: TBytes;
{  bytes1: TBytes;
  bytesx2: TArray<TBytes>;   }
begin
  SetLength(tmp, 100);
  SetLength(bytes, 100);
  FillChar(tmp[1], Length(tmp) * SizeOf(Char), 65);
  FillChar(bytes[0], Length(bytes) * SizeOf(Byte), 66);
  StringToBytes('537badf134a82b1763f7aee8', bytes);
//  StringToBytes('533da6a40427a9b03915560d', bytes1);
  pb := TPB_HelloParams.Create;
  try
    SendProtobuf(scHello, pb);
  finally
    pb.Free;
  end;
end;
{$ENDIF}


end.
