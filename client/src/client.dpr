program client;

{$R *.dres}
{$R *.res}

uses
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
  uManageClubsForm in 'forms\uManageClubsForm.pas' {frmManageClubs},
  uChangeClubDetailsForm in 'forms\uChangeClubDetailsForm.pas' {frmChangeClubDetails},
  uGiveChipsForm in 'forms\uGiveChipsForm.pas' {frmGiveChips},
  uChangeEMailForm in 'forms\uChangeEMailForm.pas' {frmChangeEMail},
  uServerSettings in 'modules\server_settings\uServerSettings.pas',
  uChangePasswordForm in 'forms\uChangePasswordForm.pas' {frmChangePassword},
  uChangeAvatarForm in 'forms\uChangeAvatarForm.pas' {frmChangeAvatar},
  uTableForm in 'forms\uTableForm.pas' {frmTable},
  uCreateGameForm in 'forms\uCreateGameForm.pas' {frmCreateGame},
  uDebugForm in 'forms\uDebugForm.pas' {frmDebug},
  uPublicClubsList in 'forms\uPublicClubsList.pas' {frmPublicClubsList},
  uIFormParams in 'forms\uIFormParams.pas',
  uSettings in 'modules\settings\uSettings.pas',
  uHardcodedSettings in 'modules\settings\uHardcodedSettings.pas',
  uCommon in 'uCommon.pas',
  uServerCodes in 'uServerCodes.pas',
  uValidators in 'modules\validators\uValidators.pas',
  uPlayerInfo in 'modules\playerinfo\uPlayerInfo.pas',
  uClubInfo in 'modules\clubinfo\uClubInfo.pas',
  uTables in 'modules\tables\uTables.pas',
  uTable in 'modules\tables\uTable.pas',
  uGameInfo in 'modules\gameinfo\uGameInfo.pas',
  uInstanceController in 'modules\instance_controller\uInstanceController.pas',
  uAvatars in 'modules\avatars\uAvatars.pas',
  uAvatar in 'modules\avatars\uAvatar.pas',
  uEncryption in 'modules\encryption\uEncryption.pas',
  uSocketClient in 'modules\socketclient\uSocketClient.pas',
  uProtobufReader in 'modules\protobuf\uProtobufReader.pas',
  uPB_RpcMessage in 'modules\protobuf\objects\uPB_RpcMessage.pas',
  uPB_LoginParams in 'modules\protobuf\objects\uPB_LoginParams.pas',
  uPB_Club in 'modules\protobuf\objects\uPB_Club.pas',
  uPB_StatusReply in 'modules\protobuf\objects\uPB_StatusReply.pas',
  uProtobufBaseObject in 'modules\protobuf\uProtobufBaseObject.pas',
  uPB_HelloArguments in 'modules\protobuf\objects\uPB_HelloArguments.pas',
  uPB_StringSizes in 'modules\protobuf\objects\uPB_StringSizes.pas',
  uPB_TokenPrices in 'modules\protobuf\objects\uPB_TokenPrices.pas',
  uPB_RegisterParams in 'modules\protobuf\objects\uPB_RegisterParams.pas',
  uPB_ForgotPasswordParams in 'modules\protobuf\objects\uPB_ForgotPasswordParams.pas',
  uPB_User in 'modules\protobuf\objects\uPB_User.pas',
  uMessageContainer in 'modules\message_container\uMessageContainer.pas',
  uMessageItem in 'modules\message_container\uMessageItem.pas',
  uServerMessageCallback in 'modules\message_container\uServerMessageCallback.pas',
  uPB_ListClubsReply in 'modules\protobuf\objects\uPB_ListClubsReply.pas',
  uPB_CreateClubParams in 'modules\protobuf\objects\uPB_CreateClubParams.pas',
  uPB_GiveClubOwnershipParams in 'modules\protobuf\objects\uPB_GiveClubOwnershipParams.pas',
  uPB_JoinClubParams in 'modules\protobuf\objects\uPB_JoinClubParams.pas',
  uPB_KickPlayerParams in 'modules\protobuf\objects\uPB_KickPlayerParams.pas',
  uPB_LeaveClubParams in 'modules\protobuf\objects\uPB_LeaveClubParams.pas',
  uPB_ChangeEMailParams in 'modules\protobuf\objects\uPB_ChangeEMailParams.pas',
  uPB_ChangePasswordParams in 'modules\protobuf\objects\uPB_ChangePasswordParams.pas',
  uPB_DeleteClubParams in 'modules\protobuf\objects\uPB_DeleteClubParams.pas',
  uPB_DeleteGameParams in 'modules\protobuf\objects\uPB_DeleteGameParams.pas',
  uPB_Game in 'modules\protobuf\objects\uPB_Game.pas',
  uPB_SetAvatarParams in 'modules\protobuf\objects\uPB_SetAvatarParams.pas',
  uPB_TransferChipsParams in 'modules\protobuf\objects\uPB_TransferChipsParams.pas';

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
