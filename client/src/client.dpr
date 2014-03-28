program client;

{$R 'Poker.Resources.Fonts.res' 'resources\Poker.Resources.Fonts.rc'}
{$R 'Poker.Resources.Sounds.res' 'resources\Poker.Resources.Sounds.rc'}
{$R *.dres}
{$R *.res}

{$I defines.inc}

uses
  FastMM4 in '3rdparty\FastMM\FastMM4.pas',
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Winapi.Windows,
  Vcl.Forms,
  pbInput in '3rdparty\protobufs\pbInput.pas',
  pbOutput in '3rdparty\protobufs\pbOutput.pas',
  pbPublic in '3rdparty\protobufs\pbPublic.pas',
  StrBuffer in '3rdparty\protobufs\StrBuffer.pas',
  FastMM4Messages in '3rdparty\FastMM\FastMM4Messages.pas',
  dxGDIPlusAPI in '3rdparty\devexpress\dxGDIPlusAPI.pas',
  dxsChipUpDark in 'skins\ChipUpDarkStyle\dxsChipUpDark.pas',
  dxsChipUpDarkTabs in 'skins\ChipUpDarkTabs\dxsChipUpDarkTabs.pas',
  dxsChipUpRedButton in 'skins\ChipUpRedButton\dxsChipUpRedButton.pas',
  Poker.DataModule in 'Poker.DataModule.pas' {dmMain: TDataModule},
  Poker.Forms.Main in 'forms\Poker.Forms.Main.pas' {frmChipUpMain},
  Poker.Forms.Login in 'forms\Poker.Forms.Login.pas' {frmLogin},
  Poker.Forms.CreateAccount in 'forms\Poker.Forms.CreateAccount.pas' {frmCreateAccount},
  Poker.Forms.ForgotPassword in 'forms\Poker.Forms.ForgotPassword.pas' {frmForgotPassword},
  Poker.Forms.CreateClub in 'forms\Poker.Forms.CreateClub.pas' {frmCreateClub},
  Poker.Forms.JoinClub in 'forms\Poker.Forms.JoinClub.pas' {frmJoinClub},
  Poker.Forms.ChangeClubDetails in 'forms\Poker.Forms.ChangeClubDetails.pas' {frmChangeClubDetails},
  Poker.Forms.GiveChips in 'forms\Poker.Forms.GiveChips.pas' {frmGiveChips},
  Poker.Forms.ChangeEMail in 'forms\Poker.Forms.ChangeEMail.pas' {frmChangeEMail},
  Poker.Forms.ChangePassword in 'forms\Poker.Forms.ChangePassword.pas' {frmChangePassword},
  Poker.Forms.Table in 'forms\Poker.Forms.Table.pas' {frmTable},
  Poker.Forms.CreateEditGame in 'forms\Poker.Forms.CreateEditGame.pas' {frmCreateEditGame},
  Poker.Forms.Debug in 'forms\Poker.Forms.Debug.pas' {frmDebug},
  Poker.Forms.ChangeAvatar in 'forms\Poker.Forms.ChangeAvatar.pas' {frmChangeAvatar},
  Poker.Forms.TableSit in 'forms\Poker.Forms.TableSit.pas' {frmTableSit},
  Poker.Forms.ClubLobby in 'forms\Poker.Forms.ClubLobby.pas' {frmClubLobby},
  Poker.Forms.Updater in 'forms\Poker.Forms.Updater.pas' {frmUpdater},
  Poker.Forms.CloseTable in 'forms\Poker.Forms.CloseTable.pas' {frmCloseTable},
  Poker.Interfaces.FormParams in 'interfaces\Poker.Interfaces.FormParams.pas',
  Poker.Interfaces.ModalForm in 'interfaces\Poker.Interfaces.ModalForm.pas',
  Poker.Helpers.AsphyreImage in 'helpers\Poker.Helpers.AsphyreImage.pas',
  Poker.Common.Misc in 'modules\common\Poker.Common.Misc.pas',
  Poker.Common.Encryption in 'modules\common\Poker.Common.Encryption.pas',
  Poker.Common.FormsContainer in 'modules\common\Poker.Common.FormsContainer.pas',
  Poker.Common.InstanceController in 'modules\common\Poker.Common.InstanceController.pas',
  Poker.HardcodedSettings in 'modules\settings\Poker.HardcodedSettings.pas',
  Poker.Settings in 'modules\settings\Poker.Settings.pas',
  Poker.Server.Settings in 'modules\server\Poker.Server.Settings.pas',
  Poker.Server.Validators in 'modules\server\Poker.Server.Validators.pas',
  Poker.Server.Socket in 'modules\server\Poker.Server.Socket.pas',
  Poker.Server.MessageContainer in 'modules\server\Poker.Server.MessageContainer.pas',
  Poker.Server.MessageCallbacks in 'modules\server\Poker.Server.MessageCallbacks.pas',
  Poker.DirectX.Core in 'modules\directx\Poker.DirectX.Core.pas',
  Poker.DirectX.Timer in 'modules\directx\Poker.DirectX.Timer.pas',
  Poker.DirectX.Animation in 'modules\directx\Poker.DirectX.Animation.pas',
  Poker.Objects.PlayerInfo in 'modules\objects\Poker.Objects.PlayerInfo.pas',
  Poker.Objects.ClubInfo in 'modules\objects\Poker.Objects.ClubInfo.pas',
  Poker.Objects.GameInfo in 'modules\objects\Poker.Objects.GameInfo.pas',
  Poker.Table.Tables in 'modules\table\Poker.Table.Tables.pas',
  Poker.Table.Status in 'modules\table\Poker.Table.Status.pas',
  Poker.Table.Resources in 'modules\table\Poker.Table.Resources.pas',
  Poker.Avatars in 'modules\Poker.Avatars.pas',
  Poker.Cards in 'modules\Poker.Cards.pas',
  Poker.ChipStackMaker in 'modules\Poker.ChipStackMaker.pas',
  Poker.Sounds in 'modules\Poker.Sounds.pas',
  Poker.Database.Core in 'modules\database\Poker.Database.Core.pas',
  Poker.Protobufs.Enum.ServerCodes in 'modules\protobuf\objects\Poker.Protobufs.Enum.ServerCodes.pas',
  Poker.Protobufs.Reader in 'modules\protobuf\Poker.Protobufs.Reader.pas',
  Poker.Protobufs.Objects.Base in 'modules\protobuf\Poker.Protobufs.Objects.Base.pas',
  Poker.Protobufs.Objects.RpcMessage in 'modules\protobuf\objects\Poker.Protobufs.Objects.RpcMessage.pas',
  Poker.Protobufs.Objects.LoginParams in 'modules\protobuf\objects\Poker.Protobufs.Objects.LoginParams.pas',
  Poker.Protobufs.Objects.Club in 'modules\protobuf\objects\Poker.Protobufs.Objects.Club.pas',
  Poker.Protobufs.Objects.StatusReply in 'modules\protobuf\objects\Poker.Protobufs.Objects.StatusReply.pas',
  Poker.Protobufs.Objects.HelloReply in 'modules\protobuf\objects\Poker.Protobufs.Objects.HelloReply.pas',
  Poker.Protobufs.Objects.StringSizes in 'modules\protobuf\objects\Poker.Protobufs.Objects.StringSizes.pas',
  Poker.Protobufs.Objects.RegisterParams in 'modules\protobuf\objects\Poker.Protobufs.Objects.RegisterParams.pas',
  Poker.Protobufs.Objects.ForgotPasswordParams in 'modules\protobuf\objects\Poker.Protobufs.Objects.ForgotPasswordParams.pas',
  Poker.Protobufs.Objects.User in 'modules\protobuf\objects\Poker.Protobufs.Objects.User.pas',
  Poker.Protobufs.Objects.ListClubsReply in 'modules\protobuf\objects\Poker.Protobufs.Objects.ListClubsReply.pas',
  Poker.Protobufs.Objects.GiveClubOwnershipParams in 'modules\protobuf\objects\Poker.Protobufs.Objects.GiveClubOwnershipParams.pas',
  Poker.Protobufs.Objects.KickPlayerParams in 'modules\protobuf\objects\Poker.Protobufs.Objects.KickPlayerParams.pas',
  Poker.Protobufs.Objects.ChangeEMailParams in 'modules\protobuf\objects\Poker.Protobufs.Objects.ChangeEMailParams.pas',
  Poker.Protobufs.Objects.ChangePasswordParams in 'modules\protobuf\objects\Poker.Protobufs.Objects.ChangePasswordParams.pas',
  Poker.Protobufs.Objects.Game in 'modules\protobuf\objects\Poker.Protobufs.Objects.Game.pas',
  Poker.Protobufs.Objects.SetAvatarParams in 'modules\protobuf\objects\Poker.Protobufs.Objects.SetAvatarParams.pas',
  Poker.Protobufs.Objects.TransferChipsParams in 'modules\protobuf\objects\Poker.Protobufs.Objects.TransferChipsParams.pas',
  Poker.Protobufs.Objects.ChatMessage in 'modules\protobuf\objects\Poker.Protobufs.Objects.ChatMessage.pas',
  Poker.Protobufs.Objects.ChatEvent in 'modules\protobuf\objects\Poker.Protobufs.Objects.ChatEvent.pas',
  Poker.Protobufs.Objects.TableSit in 'modules\protobuf\objects\Poker.Protobufs.Objects.TableSit.pas',
  Poker.Protobufs.Objects.TableStatus in 'modules\protobuf\objects\Poker.Protobufs.Objects.TableStatus.pas',
  Poker.Protobufs.Objects.SeatInfo in 'modules\protobuf\objects\Poker.Protobufs.Objects.SeatInfo.pas',
  Poker.Protobufs.Objects.ChangeSuspendState in 'modules\protobuf\objects\Poker.Protobufs.Objects.ChangeSuspendState.pas',
  Poker.Protobufs.Objects.RegisterReply in 'modules\protobuf\objects\Poker.Protobufs.Objects.RegisterReply.pas',
  Poker.Protobufs.Objects.ClubCommandReply in 'modules\protobuf\objects\Poker.Protobufs.Objects.ClubCommandReply.pas',
  Poker.Protobufs.Objects.LoginReply in 'modules\protobuf\objects\Poker.Protobufs.Objects.LoginReply.pas',
  Poker.Protobufs.Objects.SetAvatarReply in 'modules\protobuf\objects\Poker.Protobufs.Objects.SetAvatarReply.pas',
  Poker.Protobufs.Objects.ChangeMailReply in 'modules\protobuf\objects\Poker.Protobufs.Objects.ChangeMailReply.pas',
  Poker.Protobufs.Objects.GetUserParams in 'modules\protobuf\objects\Poker.Protobufs.Objects.GetUserParams.pas',
  Poker.Protobufs.Objects.TableEvent in 'modules\protobuf\objects\Poker.Protobufs.Objects.TableEvent.pas',
  Poker.Protobufs.Objects.PutChips in 'modules\protobuf\objects\Poker.Protobufs.Objects.PutChips.pas',
  Poker.Protobufs.Objects.WinnerData in 'modules\protobuf\objects\Poker.Protobufs.Objects.WinnerData.pas',
  Poker.Protobufs.Objects.PotInfo in 'modules\protobuf\objects\Poker.Protobufs.Objects.PotInfo.pas',
  Poker.Protobufs.Objects.PingParams in 'modules\protobuf\objects\Poker.Protobufs.Objects.PingParams.pas',
  Poker.Protobufs.Objects.PingReply in 'modules\protobuf\objects\Poker.Protobufs.Objects.PingReply.pas',
  Poker.Protobufs.Objects.Pot in 'modules\protobuf\objects\Poker.Protobufs.Objects.Pot.pas',
  Poker.Protobufs.Objects.TableBoolFlag in 'modules\protobuf\objects\Poker.Protobufs.Objects.TableBoolFlag.pas',
  Poker.Protobufs.Objects.UserChangeParams in 'modules\protobuf\objects\Poker.Protobufs.Objects.UserChangeParams.pas',
  Poker.Protobufs.Objects.CloseGameData in 'modules\protobuf\objects\Poker.Protobufs.Objects.CloseGameData.pas',
  Poker.Protobufs.Objects.ClubQuery in 'modules\protobuf\objects\Poker.Protobufs.Objects.ClubQuery.pas',
  Poker.Protobufs.Objects.FetchHandHistory in 'modules\protobuf\objects\Poker.Protobufs.Objects.FetchHandHistory.pas',
  Poker.Protobufs.Objects.FetchHandReply in 'modules\protobuf\objects\Poker.Protobufs.Objects.FetchHandReply.pas',
  Poker.HandDownloader in 'modules\Poker.HandDownloader.pas';

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
