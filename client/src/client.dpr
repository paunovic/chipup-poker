program client;

{$R 'PokerClient.Resources.Fonts.res' 'resources\PokerClient.Resources.Fonts.rc'}
{$R 'PokerClient.Resources.Sounds.res' 'resources\PokerClient.Resources.Sounds.rc'}
{$R *.dres}
{$R *.res}

{$I defines.inc}

uses
  Winapi.Windows, Vcl.Forms, FastMM4 in '3rdparty\FastMM\FastMM4.pas',
  madExcept, madLinkDisAsm, madListHardware, madListProcesses, madListModules,
  pbInput in '3rdparty\protobufs\pbInput.pas',
  pbOutput in '3rdparty\protobufs\pbOutput.pas',
  pbPublic in '3rdparty\protobufs\pbPublic.pas',
  StrBuffer in '3rdparty\protobufs\StrBuffer.pas',
  FastMM4Messages in '3rdparty\FastMM\FastMM4Messages.pas',
  dxGDIPlusAPI in '3rdparty\devexpress\dxGDIPlusAPI.pas',
  dxsChipUpDark in 'skins\ChipUpDarkStyle\dxsChipUpDark.pas',
  dxsChipUpDarkTabs in 'skins\ChipUpDarkTabs\dxsChipUpDarkTabs.pas',
  dxsChipUpRedButton in 'skins\ChipUpRedButton\dxsChipUpRedButton.pas',
  PokerClient.DataModule in 'PokerClient.DataModule.pas' {dmMain: TDataModule},
  PokerClient.Forms.Main in 'forms\PokerClient.Forms.Main.pas' {frmChipUpMain},
  PokerClient.Forms.Login in 'forms\PokerClient.Forms.Login.pas' {frmLogin},
  PokerClient.Forms.CreateAccount in 'forms\PokerClient.Forms.CreateAccount.pas' {frmCreateAccount},
  PokerClient.Forms.ForgotPassword in 'forms\PokerClient.Forms.ForgotPassword.pas' {frmForgotPassword},
  PokerClient.Forms.CreateClub in 'forms\PokerClient.Forms.CreateClub.pas' {frmCreateClub},
  PokerClient.Forms.JoinClub in 'forms\PokerClient.Forms.JoinClub.pas' {frmJoinClub},
  PokerClient.Forms.ChangeClubDetails in 'forms\PokerClient.Forms.ChangeClubDetails.pas' {frmChangeClubDetails},
  PokerClient.Forms.GiveChips in 'forms\PokerClient.Forms.GiveChips.pas' {frmGiveChips},
  PokerClient.Forms.ChangeEMail in 'forms\PokerClient.Forms.ChangeEMail.pas' {frmChangeEMail},
  PokerClient.Forms.ChangePassword in 'forms\PokerClient.Forms.ChangePassword.pas' {frmChangePassword},
  PokerClient.Forms.Table in 'forms\PokerClient.Forms.Table.pas' {frmTable},
  PokerClient.Forms.CreateEditGame in 'forms\PokerClient.Forms.CreateEditGame.pas' {frmCreateEditGame},
  PokerClient.Forms.Debug in 'forms\PokerClient.Forms.Debug.pas' {frmDebug},
  PokerClient.Forms.PublicClubsList in 'forms\PokerClient.Forms.PublicClubsList.pas' {frmPublicClubsList},
  PokerClient.Forms.ChangeAvatar in 'forms\PokerClient.Forms.ChangeAvatar.pas' {frmChangeAvatar},
  PokerClient.Forms.TableSit in 'forms\PokerClient.Forms.TableSit.pas' {frmTableSit},
  PokerClient.Forms.ClubLobby in 'forms\PokerClient.Forms.ClubLobby.pas' {frmClubLobby},
  PokerClient.Interfaces.FormParams in 'interfaces\PokerClient.Interfaces.FormParams.pas',
  PokerClient.Interfaces.ModalForm in 'interfaces\PokerClient.Interfaces.ModalForm.pas',
  PokerClient.Helpers.AsphyreImage in 'helpers\PokerClient.Helpers.AsphyreImage.pas',
  PokerClient.Common.Misc in 'modules\common\PokerClient.Common.Misc.pas',
  PokerClient.Common.Encryption in 'modules\common\PokerClient.Common.Encryption.pas',
  PokerClient.Common.FormsContainer in 'modules\common\PokerClient.Common.FormsContainer.pas',
  PokerClient.Common.InstanceController in 'modules\common\PokerClient.Common.InstanceController.pas',
  PokerClient.HardcodedSettings in 'modules\settings\PokerClient.HardcodedSettings.pas',
  PokerClient.Settings in 'modules\settings\PokerClient.Settings.pas',
  PokerClient.Server.Settings in 'modules\server\PokerClient.Server.Settings.pas',
  PokerClient.Server.Validators in 'modules\server\PokerClient.Server.Validators.pas',
  PokerClient.Server.Socket in 'modules\server\PokerClient.Server.Socket.pas',
  PokerClient.Server.MessageContainer in 'modules\server\PokerClient.Server.MessageContainer.pas',
  PokerClient.Server.MessageCallbacks in 'modules\server\PokerClient.Server.MessageCallbacks.pas',
  PokerClient.DirectX.Core in 'modules\directx\PokerClient.DirectX.Core.pas',
  PokerClient.DirectX.Timer in 'modules\directx\PokerClient.DirectX.Timer.pas',
  PokerClient.DirectX.Animation in 'modules\directx\PokerClient.DirectX.Animation.pas',
  PokerClient.Objects.PlayerInfo in 'modules\objects\PokerClient.Objects.PlayerInfo.pas',
  PokerClient.Objects.ClubInfo in 'modules\objects\PokerClient.Objects.ClubInfo.pas',
  PokerClient.Objects.GameInfo in 'modules\objects\PokerClient.Objects.GameInfo.pas',
  PokerClient.Table.Tables in 'modules\table\PokerClient.Table.Tables.pas',
  PokerClient.Table.Status in 'modules\table\PokerClient.Table.Status.pas',
  PokerClient.Table.Resources in 'modules\table\PokerClient.Table.Resources.pas',
  PokerClient.Avatars in 'modules\PokerClient.Avatars.pas',
  PokerClient.Cards in 'modules\PokerClient.Cards.pas',
  PokerClient.ChipStackMaker in 'modules\PokerClient.ChipStackMaker.pas',
  PokerClient.Sounds in 'modules\PokerClient.Sounds.pas',
  PokerClient.Protobufs.Enum.ServerCodes in 'modules\protobuf\objects\PokerClient.Protobufs.Enum.ServerCodes.pas',
  PokerClient.Protobufs.Reader in 'modules\protobuf\PokerClient.Protobufs.Reader.pas',
  PokerClient.Protobufs.Objects.Base in 'modules\protobuf\PokerClient.Protobufs.Objects.Base.pas',
  PokerClient.Protobufs.Objects.RpcMessage in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.RpcMessage.pas',
  PokerClient.Protobufs.Objects.LoginParams in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.LoginParams.pas',
  PokerClient.Protobufs.Objects.Club in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.Club.pas',
  PokerClient.Protobufs.Objects.StatusReply in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.StatusReply.pas',
  PokerClient.Protobufs.Objects.HelloReply in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.HelloReply.pas',
  PokerClient.Protobufs.Objects.StringSizes in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.StringSizes.pas',
  PokerClient.Protobufs.Objects.RegisterParams in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.RegisterParams.pas',
  PokerClient.Protobufs.Objects.ForgotPasswordParams in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.ForgotPasswordParams.pas',
  PokerClient.Protobufs.Objects.User in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.User.pas',
  PokerClient.Protobufs.Objects.ListClubsReply in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.ListClubsReply.pas',
  PokerClient.Protobufs.Objects.GiveClubOwnershipParams in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.GiveClubOwnershipParams.pas',
  PokerClient.Protobufs.Objects.KickPlayerParams in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.KickPlayerParams.pas',
  PokerClient.Protobufs.Objects.ChangeEMailParams in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.ChangeEMailParams.pas',
  PokerClient.Protobufs.Objects.ChangePasswordParams in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.ChangePasswordParams.pas',
  PokerClient.Protobufs.Objects.Game in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.Game.pas',
  PokerClient.Protobufs.Objects.SetAvatarParams in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.SetAvatarParams.pas',
  PokerClient.Protobufs.Objects.TransferChipsParams in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.TransferChipsParams.pas',
  PokerClient.Protobufs.Objects.ChatMessage in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.ChatMessage.pas',
  PokerClient.Protobufs.Objects.ChatEvent in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.ChatEvent.pas',
  PokerClient.Protobufs.Objects.TableSit in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.TableSit.pas',
  PokerClient.Protobufs.Objects.TableStatus in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.TableStatus.pas',
  PokerClient.Protobufs.Objects.SeatInfo in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.SeatInfo.pas',
  PokerClient.Protobufs.Objects.ChangeSuspendState in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.ChangeSuspendState.pas',
  PokerClient.Protobufs.Objects.RegisterReply in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.RegisterReply.pas',
  PokerClient.Protobufs.Objects.ClubCommandReply in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.ClubCommandReply.pas',
  PokerClient.Protobufs.Objects.LoginReply in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.LoginReply.pas',
  PokerClient.Protobufs.Objects.SetAvatarReply in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.SetAvatarReply.pas',
  PokerClient.Protobufs.Objects.ChangeMailReply in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.ChangeMailReply.pas',
  PokerClient.Protobufs.Objects.GetUserParams in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.GetUserParams.pas',
  PokerClient.Protobufs.Objects.TableEvent in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.TableEvent.pas',
  PokerClient.Protobufs.Objects.PutChips in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.PutChips.pas',
  PokerClient.Protobufs.Objects.WinnerData in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.WinnerData.pas',
  PokerClient.Protobufs.Objects.PotInfo in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.PotInfo.pas',
  PokerClient.Protobufs.Objects.PingParams in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.PingParams.pas',
  PokerClient.Protobufs.Objects.PingReply in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.PingReply.pas',
  PokerClient.Protobufs.Objects.Pot in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.Pot.pas',
  PokerClient.Protobufs.Objects.TableBoolFlag in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.TableBoolFlag.pas',
  PokerClient.Protobufs.Objects.UserChangeParams in 'modules\protobuf\objects\PokerClient.Protobufs.Objects.UserChangeParams.pas';

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
