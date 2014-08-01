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
  FastMM4Messages in '3rdparty\FastMM\FastMM4Messages.pas',
  Winapi.Windows,
  Vcl.Forms,
  pbInput in '3rdparty\protobufs\pbInput.pas',
  pbOutput in '3rdparty\protobufs\pbOutput.pas',
  pbPublic in '3rdparty\protobufs\pbPublic.pas',
  StrBuffer in '3rdparty\protobufs\StrBuffer.pas',
  OverbyteIcsHttpProt in '3rdparty\icsv8\OverbyteIcsHttpProt.pas',
  ChipUpPokerDarkSkin in 'skins\ChipUpPokerDarkSkin\ChipUpPokerDarkSkin.pas',
  Poker.DataModule in 'Poker.DataModule.pas' {dmMain: TDataModule},
  Poker.Forms.Main in 'forms\Poker.Forms.Main.pas' {frmChipUpMain},
  Poker.Forms.Login in 'forms\Poker.Forms.Login.pas' {frmChipUpLogin},
  Poker.Forms.CreateAccount in 'forms\Poker.Forms.CreateAccount.pas' {frmCreateAccount},
  Poker.Forms.ForgotPassword in 'forms\Poker.Forms.ForgotPassword.pas' {frmForgotPassword},
  Poker.Forms.CreateClub in 'forms\Poker.Forms.CreateClub.pas' {frmCreateClub},
  Poker.Forms.JoinClub in 'forms\Poker.Forms.JoinClub.pas' {frmJoinClub},
  Poker.Forms.ChangeClubDetails in 'forms\Poker.Forms.ChangeClubDetails.pas' {frmChangeClubDetails},
  Poker.Forms.ChangeEMail in 'forms\Poker.Forms.ChangeEMail.pas' {frmChangeEMail},
  Poker.Forms.ChangePassword in 'forms\Poker.Forms.ChangePassword.pas' {frmChangePassword},
  Poker.Forms.Table in 'forms\Poker.Forms.Table.pas' {frmTable},
  Poker.Forms.CreateGame in 'forms\Poker.Forms.CreateGame.pas' {frmCreateGame},
  Poker.Forms.Debug in 'forms\Poker.Forms.Debug.pas' {frmDebug},
  Poker.Forms.ChangeAvatar in 'forms\Poker.Forms.ChangeAvatar.pas' {frmChangeAvatar},
  Poker.Forms.TableSit in 'forms\Poker.Forms.TableSit.pas' {frmTableSit},
  Poker.Forms.ClubLobby in 'forms\Poker.Forms.ClubLobby.pas' {frmClubLobby},
  Poker.Forms.Updater in 'forms\Poker.Forms.Updater.pas' {frmUpdater},
  Poker.Forms.CloseTable in 'forms\Poker.Forms.CloseTable.pas' {frmCloseTable},
  Poker.Forms.ImageCrop in 'forms\Poker.Forms.ImageCrop.pas' {frmImageCrop},
  Poker.Forms.ContactUs in 'forms\Poker.Forms.ContactUs.pas' {frmContactUs},
  Poker.Forms.Reconnect in 'forms\Poker.Forms.Reconnect.pas' {frmReconnect},
  Poker.Forms.About in 'forms\Poker.Forms.About.pas' {frmAbout},
  Poker.Forms.SystemTrayPopup in 'forms\Poker.Forms.SystemTrayPopup.pas' {frmSystemTrayPopup},
  Poker.Forms.CloseClubConfirmation in 'forms\Poker.Forms.CloseClubConfirmation.pas' {frmCloseClubConfirmation},
  Poker.Forms.HandHistory in 'forms\Poker.Forms.HandHistory.pas' {frmHandHistory},
  Poker.Forms.ClubMemberOptions in 'forms\Poker.Forms.ClubMemberOptions.pas' {frmClubMemberOptions},
  Poker.Forms.LayeredForm in 'forms\Poker.Forms.LayeredForm.pas' {frmLayered},
  Poker.Forms.Subscriptions in 'forms\Poker.Forms.Subscriptions.pas' {frmSubscriptions},
  Poker.Forms.Settings in 'forms\Poker.Forms.Settings.pas' {frmSettings},
  Poker.Forms.TournamentLobby in 'forms\Poker.Forms.TournamentLobby.pas' {frmTournamentLobby},
  Poker.Interfaces.FormParams in 'interfaces\Poker.Interfaces.FormParams.pas',
  Poker.Interfaces.ModalForm in 'interfaces\Poker.Interfaces.ModalForm.pas',
  Poker.Helpers.AsphyreImage in 'helpers\Poker.Helpers.AsphyreImage.pas',
  Poker.Helpers.DX9Canvas in 'helpers\Poker.Helpers.DX9Canvas.pas',
  Poker.Helpers.PB_Pot in 'helpers\Poker.Helpers.PB_Pot.pas',
  Poker.Helpers.HandHistoryMove in 'helpers\Poker.Helpers.HandHistoryMove.pas',
  Poker.Helpers.PB_TablePlayerStats in 'helpers\Poker.Helpers.PB_TablePlayerStats.pas',
  Poker.Common.Misc in 'modules\common\Poker.Common.Misc.pas',
  Poker.Common.Encryption in 'modules\common\Poker.Common.Encryption.pas',
  Poker.Common.FormsContainer in 'modules\common\Poker.Common.FormsContainer.pas',
  Poker.Common.InstanceController in 'modules\common\Poker.Common.InstanceController.pas',
  Poker.Common.AlphaBlendThread in 'modules\common\Poker.Common.AlphaBlendThread.pas',
  Poker.Common.CommandLineParams in 'modules\common\Poker.Common.CommandLineParams.pas',
  Poker.Common.WavePlayer.DirectSoundBuffer in 'modules\common\wave_player\Poker.Common.WavePlayer.DirectSoundBuffer.pas',
  Poker.Common.WavePlayer in 'modules\common\wave_player\Poker.Common.WavePlayer.pas',
  Poker.Common.WavePlayer.Reader in 'modules\common\wave_player\Poker.Common.WavePlayer.Reader.pas',
  Poker.Common.WavePlayer.DirectSoundBufferNotificationThread in 'modules\common\wave_player\Poker.Common.WavePlayer.DirectSoundBufferNotificationThread.pas',
  Poker.HardcodedSettings in 'modules\settings\Poker.HardcodedSettings.pas',
  Poker.Settings in 'modules\settings\Poker.Settings.pas',
  Poker.Server.Settings in 'modules\server\Poker.Server.Settings.pas',
  Poker.Server.Validators in 'modules\server\Poker.Server.Validators.pas',
  Poker.Server.MessageContainer in 'modules\server\Poker.Server.MessageContainer.pas',
  Poker.Server.MessageCallbacks in 'modules\server\Poker.Server.MessageCallbacks.pas',
  Poker.Server.SSLCerts in 'modules\server\Poker.Server.SSLCerts.pas',
  Poker.Server.Socket.Core in 'modules\server\socket\Poker.Server.Socket.Core.pas',
  Poker.Server.Socket in 'modules\server\socket\Poker.Server.Socket.pas',
  Poker.Server.Socket.ConnectThread in 'modules\server\socket\Poker.Server.Socket.ConnectThread.pas',
  Poker.DirectX.Core in 'modules\directx\Poker.DirectX.Core.pas',
  Poker.DirectX.Timer in 'modules\directx\Poker.DirectX.Timer.pas',
  Poker.DirectX.Animation in 'modules\directx\Poker.DirectX.Animation.pas',
  Poker.DirectX.Button in 'modules\directx\Poker.DirectX.Button.pas',
  Poker.DirectX.Animations in 'modules\directx\Poker.DirectX.Animations.pas',
  Poker.Players.Player in 'modules\players\Poker.Players.Player.pas',
  Poker.Players.PlayerList in 'modules\players\Poker.Players.PlayerList.pas',
  Poker.Clubs.Club in 'modules\clubs\Poker.Clubs.Club.pas',
  Poker.Clubs.Member in 'modules\clubs\Poker.Clubs.Member.pas',
  Poker.Clubs.ClubList in 'modules\clubs\Poker.Clubs.ClubList.pas',
  Poker.Games.Game in 'modules\games\Poker.Games.Game.pas',
  Poker.Games.GameList in 'modules\games\Poker.Games.GameList.pas',
  Poker.Tables.Status in 'modules\tables\Poker.Tables.Status.pas',
  Poker.Tables.Table in 'modules\tables\Poker.Tables.Table.pas',
  Poker.Tables.TableList in 'modules\tables\Poker.Tables.TableList.pas',
  Poker.Tables.Resources in 'modules\tables\Poker.Tables.Resources.pas',
  Poker.Tables.Renderer in 'modules\tables\Poker.Tables.Renderer.pas',
  Poker.Tables.RenderMetrics in 'modules\tables\Poker.Tables.RenderMetrics.pas',
  Poker.Tables.StatsList in 'modules\tables\Poker.Tables.StatsList.pas',
  Poker.HandHistory.Core in 'modules\hand_history\Poker.HandHistory.Core.pas',
  Poker.HandHistory.Items in 'modules\hand_history\Poker.HandHistory.Items.pas',
  Poker.HandHistory.Players in 'modules\hand_history\Poker.HandHistory.Players.pas',
  Poker.HandHistory.Playback in 'modules\hand_history\Poker.HandHistory.Playback.pas',
  Poker.Avatars.Avatar in 'modules\avatars\Poker.Avatars.Avatar.pas',
  Poker.Avatars.AvatarList in 'modules\avatars\Poker.Avatars.AvatarList.pas',
  Poker.ChipStackMaker in 'modules\chip_stack_maker\Poker.ChipStackMaker.pas',
  Poker.ChipStackMaker.ChipStack in 'modules\chip_stack_maker\Poker.ChipStackMaker.ChipStack.pas',
  Poker.Seats.Seat in 'modules\seats\Poker.Seats.Seat.pas',
  Poker.Seats.SeatList in 'modules\seats\Poker.Seats.SeatList.pas',
  Poker.ActionMainMenuBarStyle in 'modules\Poker.ActionMainMenuBarStyle.pas',
  Poker.Cards in 'modules\Poker.Cards.pas',
  Poker.Sounds in 'modules\Poker.Sounds.pas',
  Poker.WindowMessages in 'modules\Poker.WindowMessages.pas',
  Poker.HandStrengthCalculator in 'modules\Poker.HandStrengthCalculator.pas',
  Poker.Database.Core in 'modules\database\Poker.Database.Core.pas',
  Poker.Types in 'modules\Poker.Types.pas',
  Poker.Tournaments in 'modules\tournaments\Poker.Tournaments.pas',
  Poker.Protobufs.Reader in 'modules\protobufs\Poker.Protobufs.Reader.pas',
  Poker.Protobufs.Enum.ServerCodes in 'modules\protobufs\objects\Poker.Protobufs.Enum.ServerCodes.pas',
  Poker.Protobufs.Objects.RpcMessage in 'modules\protobufs\objects\Poker.Protobufs.Objects.RpcMessage.pas',
  Poker.Protobufs.Objects.LoginParams in 'modules\protobufs\objects\Poker.Protobufs.Objects.LoginParams.pas',
  Poker.Protobufs.Objects.Club in 'modules\protobufs\objects\Poker.Protobufs.Objects.Club.pas',
  Poker.Protobufs.Objects.StringSizes in 'modules\protobufs\objects\Poker.Protobufs.Objects.StringSizes.pas',
  Poker.Protobufs.Objects.RegisterParams in 'modules\protobufs\objects\Poker.Protobufs.Objects.RegisterParams.pas',
  Poker.Protobufs.Objects.ForgotPasswordParams in 'modules\protobufs\objects\Poker.Protobufs.Objects.ForgotPasswordParams.pas',
  Poker.Protobufs.Objects.User in 'modules\protobufs\objects\Poker.Protobufs.Objects.User.pas',
  Poker.Protobufs.Objects.GiveClubOwnershipParams in 'modules\protobufs\objects\Poker.Protobufs.Objects.GiveClubOwnershipParams.pas',
  Poker.Protobufs.Objects.KickPlayerParams in 'modules\protobufs\objects\Poker.Protobufs.Objects.KickPlayerParams.pas',
  Poker.Protobufs.Objects.ChangeEMailParams in 'modules\protobufs\objects\Poker.Protobufs.Objects.ChangeEMailParams.pas',
  Poker.Protobufs.Objects.ChangePasswordParams in 'modules\protobufs\objects\Poker.Protobufs.Objects.ChangePasswordParams.pas',
  Poker.Protobufs.Objects.Game in 'modules\protobufs\objects\Poker.Protobufs.Objects.Game.pas',
  Poker.Protobufs.Objects.SetAvatarParams in 'modules\protobufs\objects\Poker.Protobufs.Objects.SetAvatarParams.pas',
  Poker.Protobufs.Objects.ChatMessage in 'modules\protobufs\objects\Poker.Protobufs.Objects.ChatMessage.pas',
  Poker.Protobufs.Objects.ChatEvent in 'modules\protobufs\objects\Poker.Protobufs.Objects.ChatEvent.pas',
  Poker.Protobufs.Objects.TableSit in 'modules\protobufs\objects\Poker.Protobufs.Objects.TableSit.pas',
  Poker.Protobufs.Objects.TableStatus in 'modules\protobufs\objects\Poker.Protobufs.Objects.TableStatus.pas',
  Poker.Protobufs.Objects.SeatInfo in 'modules\protobufs\objects\Poker.Protobufs.Objects.SeatInfo.pas',
  Poker.Protobufs.Objects.ChangeSuspendState in 'modules\protobufs\objects\Poker.Protobufs.Objects.ChangeSuspendState.pas',
  Poker.Protobufs.Objects.RegisterReply in 'modules\protobufs\objects\Poker.Protobufs.Objects.RegisterReply.pas',
  Poker.Protobufs.Objects.ClubCommandReply in 'modules\protobufs\objects\Poker.Protobufs.Objects.ClubCommandReply.pas',
  Poker.Protobufs.Objects.LoginReply in 'modules\protobufs\objects\Poker.Protobufs.Objects.LoginReply.pas',
  Poker.Protobufs.Objects.SetAvatarReply in 'modules\protobufs\objects\Poker.Protobufs.Objects.SetAvatarReply.pas',
  Poker.Protobufs.Objects.ChangeMailReply in 'modules\protobufs\objects\Poker.Protobufs.Objects.ChangeMailReply.pas',
  Poker.Protobufs.Objects.GetUserParams in 'modules\protobufs\objects\Poker.Protobufs.Objects.GetUserParams.pas',
  Poker.Protobufs.Objects.TableEvent in 'modules\protobufs\objects\Poker.Protobufs.Objects.TableEvent.pas',
  Poker.Protobufs.Objects.PutChips in 'modules\protobufs\objects\Poker.Protobufs.Objects.PutChips.pas',
  Poker.Protobufs.Objects.WinnerData in 'modules\protobufs\objects\Poker.Protobufs.Objects.WinnerData.pas',
  Poker.Protobufs.Objects.PingParams in 'modules\protobufs\objects\Poker.Protobufs.Objects.PingParams.pas',
  Poker.Protobufs.Objects.PingReply in 'modules\protobufs\objects\Poker.Protobufs.Objects.PingReply.pas',
  Poker.Protobufs.Objects.Pot in 'modules\protobufs\objects\Poker.Protobufs.Objects.Pot.pas',
  Poker.Protobufs.Objects.TableBoolFlag in 'modules\protobufs\objects\Poker.Protobufs.Objects.TableBoolFlag.pas',
  Poker.Protobufs.Objects.UserChangeParams in 'modules\protobufs\objects\Poker.Protobufs.Objects.UserChangeParams.pas',
  Poker.Protobufs.Objects.CloseGameData in 'modules\protobufs\objects\Poker.Protobufs.Objects.CloseGameData.pas',
  Poker.Protobufs.Objects.TableStatsReplies in 'modules\protobufs\objects\Poker.Protobufs.Objects.TableStatsReplies.pas',
  Poker.Protobufs.Objects.TableStatsReply in 'modules\protobufs\objects\Poker.Protobufs.Objects.TableStatsReply.pas',
  Poker.Protobufs.Objects.TablePlayerStats in 'modules\protobufs\objects\Poker.Protobufs.Objects.TablePlayerStats.pas',
  Poker.Protobufs.Objects.ContactMessage in 'modules\protobufs\objects\Poker.Protobufs.Objects.ContactMessage.pas',
  Poker.Protobufs.Objects.BuyinError in 'modules\protobufs\objects\Poker.Protobufs.Objects.BuyinError.pas',
  Poker.Protobufs.Objects.UpdateFileInfo in 'modules\protobufs\objects\Poker.Protobufs.Objects.UpdateFileInfo.pas',
  Poker.Protobufs.Objects.HelloReply in 'modules\protobufs\objects\Poker.Protobufs.Objects.HelloReply.pas',
  Poker.Protobufs.Objects.HelloParams in 'modules\protobufs\objects\Poker.Protobufs.Objects.HelloParams.pas',
  Poker.Protobufs.Objects.ValidCharsRegex in 'modules\protobufs\objects\Poker.Protobufs.Objects.ValidCharsRegex.pas',
  Poker.Protobufs.Objects.ClubMember in 'modules\protobufs\objects\Poker.Protobufs.Objects.ClubMember.pas',
  Poker.Protobufs.Objects.PlayerLimitParams in 'modules\protobufs\objects\Poker.Protobufs.Objects.PlayerLimitParams.pas',
  Poker.Protobufs.Objects.ClubPlayerStats in 'modules\protobufs\objects\Poker.Protobufs.Objects.ClubPlayerStats.pas',
  Poker.Protobufs.Objects.ClubStatsReply in 'modules\protobufs\objects\Poker.Protobufs.Objects.ClubStatsReply.pas',
  Poker.Protobufs.Objects.ClubHandHistoryReply in 'modules\protobufs\objects\Poker.Protobufs.Objects.ClubHandHistoryReply.pas',
  Poker.Protobufs.Objects.HandHistory in 'modules\protobufs\objects\Poker.Protobufs.Objects.HandHistory.pas',
  Poker.Protobufs.Objects.PlayerHandHistory in 'modules\protobufs\objects\Poker.Protobufs.Objects.PlayerHandHistory.pas',
  Poker.Protobufs.Objects.AssetList in 'modules\protobufs\objects\Poker.Protobufs.Objects.AssetList.pas',
  Poker.Protobufs.Objects.HandHistoryMove in 'modules\protobufs\objects\Poker.Protobufs.Objects.HandHistoryMove.pas',
  Poker.Protobufs.Objects.SubscriptionPlanChange in 'modules\protobufs\objects\Poker.Protobufs.Objects.SubscriptionPlanChange.pas',
  Poker.Protobufs.Objects.Base in 'modules\protobufs\Poker.Protobufs.Objects.Base.pas',
  Poker.Protobufs.Objects.TournamentCommandParams in 'modules\protobufs\objects\Poker.Protobufs.Objects.TournamentCommandParams.pas',
  Poker.Protobufs.Objects.TournamentInfo in 'modules\protobufs\objects\Poker.Protobufs.Objects.TournamentInfo.pas',
  Poker.Protobufs.Objects.TournamentList in 'modules\protobufs\objects\Poker.Protobufs.Objects.TournamentList.pas',
  Poker.Protobufs.Objects.TournamentDetails in 'modules\protobufs\objects\Poker.Protobufs.Objects.TournamentDetails.pas',
  Poker.DirectX.AnimationNew in 'modules\directx\Poker.DirectX.AnimationNew.pas',
  Poker.Tournaments.Info in 'modules\tournaments\Poker.Tournaments.Info.pas',
  Poker.Protobufs.Objects.TournamentMember in 'modules\protobufs\objects\Poker.Protobufs.Objects.TournamentMember.pas',
  Poker.Protobufs.Objects.TournamentTableStart in 'modules\protobufs\objects\Poker.Protobufs.Objects.TournamentTableStart.pas';

procedure FocusApp;
var
  window_handle: THandle;
begin
  window_handle := FindWindow('TfrmChipUpLogin', nil);
  if window_handle = 0 then
    window_handle := FindWindow('TfrmChipUpMain', nil);
  if window_handle <> 0 then
    SetForegroundWindow(window_handle);
end;

begin
  {$IFDEF DEBUG} ReportMemoryLeaksOnShutdown := TRUE; {$ENDIF}

  TCommandLineParams.ParseParams;

  TInstanceController.MutexName := Settings.Hardcoded.INSTANCE_MUTEX_NAME;
  if not TInstanceController.IsAlphaInstance then
  begin
    FocusApp;
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
