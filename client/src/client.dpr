program client;

{$R *.dres}
{$R *.res}

uses
  FastMM4 in '3rdparty\FastMM\FastMM4.pas',
  Winapi.Windows,
  Vcl.Forms,
  uMainDataModule in 'uMainDataModule.pas' {dmMain: TDataModule},
  uMainForm in 'forms\uMainForm.pas' {frmChipUpMain},
  uLoginForm in 'forms\uLoginForm.pas' {frmLogin},
  uCreateAccountForm in 'forms\uCreateAccountForm.pas' {frmCreateAccount},
  uForgotPasswordForm in 'forms\uForgotPasswordForm.pas' {frmForgotPassword},
  uCreateClubForm in 'forms\uCreateClubForm.pas' {frmCreateClub},
  uJoinClubForm in 'forms\uJoinClubForm.pas' {frmJoinClub},
  uEditGameForm in 'forms\uEditGameForm.pas' {frmEditGame},
  uChangeClubDetailsForm in 'forms\uChangeClubDetailsForm.pas' {frmChangeClubDetails},
  uGiveChipsForm in 'forms\uGiveChipsForm.pas' {frmGiveChips},
  uChangeEMailForm in 'forms\uChangeEMailForm.pas' {frmChangeEMail},
  uChangePasswordForm in 'forms\uChangePasswordForm.pas' {frmChangePassword},
  uTableForm in 'forms\uTableForm.pas' {frmTable},
  uCreateGameForm in 'forms\uCreateGameForm.pas' {frmCreateGame},
  uDebugForm in 'forms\uDebugForm.pas' {frmDebug},
  uPublicClubsList in 'forms\uPublicClubsList.pas' {frmPublicClubsList},
  uChangeAvatarForm in 'forms\uChangeAvatarForm.pas' {frmChangeAvatar},
  uTableSitForm in 'forms\uTableSitForm.pas' {frmTableSit},
  uServerSettings in 'modules\uServerSettings.pas',
  uIFormParams in 'forms\uIFormParams.pas',
  uSettings in 'modules\settings\uSettings.pas',
  uHardcodedSettings in 'modules\settings\uHardcodedSettings.pas',
  uCommon in 'uCommon.pas',
  uValidators in 'modules\uValidators.pas',
  uPlayerInfo in 'modules\uPlayerInfo.pas',
  uClubInfo in 'modules\uClubInfo.pas',
  uTables in 'modules\uTables.pas',
  uGameInfo in 'modules\uGameInfo.pas',
  uInstanceController in 'modules\uInstanceController.pas',
  uAvatars in 'modules\uAvatars.pas',
  uEncryption in 'modules\uEncryption.pas',
  uSocketClient in 'modules\uSocketClient.pas',
  uProtobufReader in 'modules\protobuf\uProtobufReader.pas',
  uPB_RpcMessage in 'modules\protobuf\objects\uPB_RpcMessage.pas',
  uPB_LoginParams in 'modules\protobuf\objects\uPB_LoginParams.pas',
  uPB_Club in 'modules\protobuf\objects\uPB_Club.pas',
  uPB_StatusReply in 'modules\protobuf\objects\uPB_StatusReply.pas',
  uPB_HelloReply in 'modules\protobuf\objects\uPB_HelloReply.pas',
  uPB_StringSizes in 'modules\protobuf\objects\uPB_StringSizes.pas',
  uPB_RegisterParams in 'modules\protobuf\objects\uPB_RegisterParams.pas',
  uPB_ForgotPasswordParams in 'modules\protobuf\objects\uPB_ForgotPasswordParams.pas',
  uPB_User in 'modules\protobuf\objects\uPB_User.pas',
  uMessageContainer in 'modules\message_container\uMessageContainer.pas',
  uMessageItem in 'modules\message_container\uMessageItem.pas',
  uServerMessageCallback in 'modules\message_container\uServerMessageCallback.pas',
  uPB_ListClubsReply in 'modules\protobuf\objects\uPB_ListClubsReply.pas',
  uPB_GiveClubOwnershipParams in 'modules\protobuf\objects\uPB_GiveClubOwnershipParams.pas',
  uPB_KickPlayerParams in 'modules\protobuf\objects\uPB_KickPlayerParams.pas',
  uPB_ChangeEMailParams in 'modules\protobuf\objects\uPB_ChangeEMailParams.pas',
  uPB_ChangePasswordParams in 'modules\protobuf\objects\uPB_ChangePasswordParams.pas',
  uPB_Game in 'modules\protobuf\objects\uPB_Game.pas',
  uPB_SetAvatarParams in 'modules\protobuf\objects\uPB_SetAvatarParams.pas',
  uPB_TransferChipsParams in 'modules\protobuf\objects\uPB_TransferChipsParams.pas',
  uPB_ChatMessage in 'modules\protobuf\objects\uPB_ChatMessage.pas',
  uPB_ChatEvent in 'modules\protobuf\objects\uPB_ChatEvent.pas',
  pbInput in '3rdparty\protobufs\pbInput.pas',
  pbOutput in '3rdparty\protobufs\pbOutput.pas',
  pbPublic in '3rdparty\protobufs\pbPublic.pas',
  StrBuffer in '3rdparty\protobufs\StrBuffer.pas',
  FastMM4Messages in '3rdparty\FastMM\FastMM4Messages.pas',
  uPB_TableSit in 'modules\protobuf\objects\uPB_TableSit.pas',
  uProtobufBaseObject in 'modules\protobuf\uProtobufBaseObject.pas',
  uPB_TableStatus in 'modules\protobuf\objects\uPB_TableStatus.pas',
  uPB_SeatInfo in 'modules\protobuf\objects\uPB_SeatInfo.pas',
  uServerCodes in 'modules\protobuf\objects\uServerCodes.pas',
  dxGDIPlusAPI in '3rdparty\devexpress\dxGDIPlusAPI.pas',
  uClubLobbyForm in 'forms\uClubLobbyForm.pas' {frmClubLobby},
  uPB_ChangeSuspendState in 'modules\protobuf\objects\uPB_ChangeSuspendState.pas',
  uPB_RegisterReply in 'modules\protobuf\objects\uPB_RegisterReply.pas',
  uPB_ClubCommandReply in 'modules\protobuf\objects\uPB_ClubCommandReply.pas',
  uPB_LoginReply in 'modules\protobuf\objects\uPB_LoginReply.pas',
  uPB_SetAvatarReply in 'modules\protobuf\objects\uPB_SetAvatarReply.pas',
  uPB_ChangeMailReply in 'modules\protobuf\objects\uPB_ChangeMailReply.pas',
  uPB_GetUserParams in 'modules\protobuf\objects\uPB_GetUserParams.pas';

procedure FocusPokerApp;
var
  window_handle: THandle;
begin
  window_handle := FindWindow('TfrmChipUpMain', nil);
  if window_handle <> 0 then
    SetForegroundWindow(window_handle);
end;

begin
  {$IFDEF DEBUG} ReportMemoryLeaksOnShutdown := TRUE; {$ENDIF}

  TInstanceController.MutexName := Settings.Hardcoded.INSTANCE_MUTEX_NAME;
  if not TInstanceController.IsAlphaInstance then
  begin
    FocusPokerApp;
    Exit;
  end;

  TInstanceController.RegisterInstance;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TfrmChipUpMain, frmChipUpMain);
  Application.Run;

  TInstanceController.UnregisterInstance;
end.
