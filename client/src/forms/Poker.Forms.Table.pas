unit Poker.Forms.Table;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, cxContainer, cxEdit, Poker.Objects.TableStatus, Poker.DirectX.Animation, Vectors2,
  Vcl.ActnList, cxLabel, Poker.Table.Tables, cxTextEdit, Vcl.ActnMan, cxSpinEdit, cxCheckBox, Poker.Protobufs.Objects.TableStatus,
  Vectors2px, Poker.Protobufs.Objects.TableEvent, System.Types, RVStyle, RVScroll, RichView, AsphyreImages, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore, ChipUpPokerDarkSkin, Vcl.Menus, Vcl.ImgList, Vcl.PlatformDefaultStyleActnCtrls,
  cxProgressBar, Vcl.StdCtrls, cxButtons, cxMaskEdit, Poker.HandHistory.Items;

type
  TfrmTable = class(TForm)
    ActionManager: TActionManager;
    acStandUp: TAction;
    acFold: TAction;
    acCall: TAction;
    acCheck: TAction;
    acRaise: TAction;
    tiActiveFrameBlink: TTimer;
    acPlayNow: TAction;
    tiSitOutNextHand: TTimer;
    tiSeatCaptionClear: TTimer;
    acRaiseMin: TAction;
    acRaise3BB: TAction;
    acRaisePot: TAction;
    acRaiseMax: TAction;
    tiSitOutNextBB: TTimer;
    acShowCards: TAction;
    edChat: TcxTextEdit;
    cbFoldToAnyBet: TcxCheckBox;
    cbSitOutNextHand: TcxCheckBox;
    cbSitOutNextBB: TcxCheckBox;
    seRaiseAmount: TcxSpinEdit;
    RVStyle: TRVStyle;
    rvChat: TRichView;
    tiGameLock: TTimer;
    lbvHandStrength: TcxLabel;
    lbvHandHistory: TcxLabel;
    acHandHistory: TAction;
    tiHandPlayback: TTimer;
    btPlayPause: TcxButton;
    il48px: TImageList;
    acHandPlaybackPlay: TAction;
    acHandPlaybackPause: TAction;
    btStepForward: TcxButton;
    btStepBackwards: TcxButton;
    pbHandPlaybackProgress: TcxProgressBar;
    acHandPlaybackStepForward: TAction;
    acHandPlaybackStepBackwards: TAction;
    tiRender: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure acStandUpExecute(Sender: TObject);
    procedure edChatKeyPress(Sender: TObject; var Key: Char);
    procedure acFoldExecute(Sender: TObject);
    procedure acCallExecute(Sender: TObject);
    procedure acCheckExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure acRaiseExecute(Sender: TObject);
    procedure tiActiveFrameBlinkTimer(Sender: TObject);
    procedure acPlayNowExecute(Sender: TObject);
    procedure cbSitOutNextHandPropertiesChange(Sender: TObject);
    procedure tiSitOutNextHandTimer(Sender: TObject);
    procedure tiSeatClearCaptionTimer(Sender: TObject);
    procedure seRaiseAmountPropertiesChange(Sender: TObject);
    procedure acRaiseMinExecute(Sender: TObject);
    procedure acRaise3BBExecute(Sender: TObject);
    procedure acRaisePotExecute(Sender: TObject);
    procedure acRaiseMaxExecute(Sender: TObject);
    procedure cbSitOutNextBBPropertiesChange(Sender: TObject);
    procedure tiSitOutNextBBTimer(Sender: TObject);
    procedure cbFoldToAnyBetPropertiesChange(Sender: TObject);
    procedure acShowCardsExecute(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure tiGameLockTimer(Sender: TObject);
    procedure edChatExit(Sender: TObject);
    procedure edChatEnter(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure seRaiseAmountKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure acHandHistoryExecute(Sender: TObject);
    procedure lbvHandHistoryClick(Sender: TObject);
    procedure tiHandPlaybackTimer(Sender: TObject);
    procedure acHandPlaybackPlayExecute(Sender: TObject);
    procedure acHandPlaybackPauseExecute(Sender: TObject);
    procedure acHandPlaybackStepForwardExecute(Sender: TObject);
    procedure acHandPlaybackStepBackwardsExecute(Sender: TObject);
    procedure tiRenderTimer(Sender: TObject);
  private
    const
      FORM_ASPECT_RATIO = 1.35;

    var
      FCallbacksId: Integer;
      FTable: TTable;
      FRaiseValue: UINT32;
      FWindowFocused: Boolean;

      FDXBFold: Integer;
      FDXBShowCards: Integer;
      FDXBCheck: Integer;
      FDXBCall: Integer;
      FDXBRaise: Integer;
      FDXBRaisePresets: array[0..3] of Integer;

    procedure SetRaiseActionCaption;
    procedure SetRaiseValue(const AValue: UINT32; const ASetSpinEditValue: Boolean = TRUE; const AAbsoluteJump: Boolean = TRUE; const AConfigureGUI: Boolean = TRUE);

    procedure EnableGameLockTimer(const ASeconds: Single);

    procedure AddUserChatMessage(const AUser, AMessage: String);
    procedure AddDealerChatMessage(const AMessage: String);
    procedure ModalFormClose(Sender: TObject);
    procedure CheckChatScrollbackLimit;
    procedure RendererDealerChatMessage(const AMessage: String);
    procedure RendererSoundPlay(const ASound: String);
    procedure RendererTimebankStarted(Sender: TObject);
    procedure ConfigureActions(out AFocusWindow: Boolean);

    procedure UpdateTableCaption;
    procedure UpdateHandHistoryLabel;
    procedure UpdateHandStrength;
    procedure FocusWindow;

    function ConfirmLeaveTable: Boolean;
    function ConfirmStandUp: Boolean;

    function GetHandHistoryItem(out AHandHistoryItem: THandHistoryItem): Boolean;

    procedure CSRChatEvent(const AMethodId: Integer; const AObject: TObject);
    procedure CSRETableStatus(const AMethodId: Integer; const AObject: TObject);
    procedure CSEUserChange(const AMethodId: Integer; const AObject: TObject);
    procedure CSEGameChange(const AMethodId: Integer; const AObject: TObject);
    procedure CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
    procedure CSRHandHistoryMsg(const AMethodId: Integer; const AObject: TObject);

    procedure TablePlaySound(const ASound: String);

    procedure ProcessTableEvent(const ATableEvent: TPB_TableEvent);

    procedure ConfigureGUI;
    procedure DefocusControls;
    procedure RefreshAll;

  protected
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure WMSizing(var AMessage: TMessage); message WM_SIZING;
    procedure WndProc(var AMessage: TMessage); override;

  public
    constructor Create(const ATable: TTable); reintroduce;

    procedure SetTableStatus(const ATableStatus: TPB_TableStatus; const AClearAnimations: Boolean);
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, System.TypInfo, {$ENDIF}
  Poker.Server.MessageContainer, Poker.Server.Settings, Poker.DirectX.Timer, Poker.Table.Renderer,
  Poker.Server.MessageCallbacks, Poker.Protobufs.Enum.ServerCodes, Poker.Protobufs.Objects.ChatEvent,
  Poker.Protobufs.Objects.ChatMessage, Poker.Protobufs.Objects.SeatInfo, Poker.Table.Resources, Poker.WindowMessages,
  Poker.DirectX.Core, Poker.Common.FormsContainer, Poker.Server.Socket.Commands, Poker.Common.Misc, Poker.Settings,
  Poker.Forms.TableSit, Poker.DataModule, Poker.Objects.PlayerInfo, Poker.Protobufs.Objects.Game, Poker.Objects.GameInfo,
  Poker.Protobufs.Objects.WinnerPotInfo, Poker.Sounds, Poker.Protobufs.Objects.WinnerData, Poker.HandStrengthCalculator,
  Poker.Forms.HandHistory, Poker.Forms.Main, Poker.HandHistory.Core, Poker.Objects.PotInfo, Poker.Objects.SeatInfo, Poker.Cards;


constructor TfrmTable.Create(const ATable: TTable);
begin
  FTable := ATable;

  inherited Create(nil);

  OnResize := nil;
  ClientWidth := Round(Screen.Monitors[0].Width / 2.5);
  ClientHeight := Round(ClientWidth / FORM_ASPECT_RATIO);
  OnResize := FormResize;
end;

procedure TfrmTable.FormCreate(Sender: TObject);
begin
  ActionManager.State := asSuspended;

  FCallbacksId := -1;
  case FTable.TableType of
    ttLiveGame: begin
      FCallbacksId := MessageContainer.AddCallbacks([
                          TServerMessageCallback.Create(seChat, CSRChatEvent),
                          TServerMessageCallback.Create(seTableStatus, CSRETableStatus),
                          TServerMessageCallback.Create(srTableSitOk, CSRETableStatus),
                          TServerMessageCallback.Create(srTableAddonOk, CSRETableStatus),
                          TServerMessageCallback.Create(srTableStandUpOk, CSRETableStatus),
                          TServerMessageCallback.Create(seUserChange, CSEUserChange),
                          TServerMessageCallback.Create(seGameChange, CSEGameChange),
                          TServerMessageCallback.Create(srGetPlayers, CSRGetUsers),
                          TServerMessageCallback.Create(srHandHistoryMsg, CSRHandHistoryMsg)
                      ]);
    end;
    ttHandPlayback: begin
      edChat.Visible := FALSE;
      lbvHandHistory.Visible := FALSE;
      lbvHandStrength.Visible := FALSE;

      pbHandPlaybackProgress.Properties.Min := 0;
      pbHandPlaybackProgress.Properties.Max := FTable.HandHistoryPlayback.States.Count - 1;
      pbHandPlaybackProgress.Visible := TRUE;
      btPlayPause.Visible := TRUE;
      btStepForward.Visible := TRUE;
      btStepBackwards.Visible := TRUE;
    end;
  end;

  FTable.Renderer.UpdateDXAreaSize;

  FTable.Renderer.OnDealerChatMessage := RendererDealerChatMessage;
  FTable.Renderer.OnSoundPlay := RendererSoundPlay;
  FTable.Renderer.OnTimebankStarted := RendererTimebankStarted;

  FTable.Renderer.AddDXButton(acStandUp, @FTable.Renderer.Metrics.StandUpButtonBounds, TableResources.StandUpButtonNormalImage, TableResources.StandUpButtonPressedImage, nil);
  FTable.Renderer.AddDXButton(acPlayNow, @FTable.Renderer.Metrics.PlayNowButtonBounds, TableResources.PlayNowButtonNormalImage, TableResources.PlayNowButtonPressedImage, nil);

  FDXBFold := FTable.Renderer.AddDXButton(acFold, @FTable.Renderer.Metrics.ActionButtonsBounds[0],
       TableResources.ActionButtonNormalImage, TableResources.ActionButtonPressedImage, nil, TRUE, 0.9);
  FDXBShowCards := FTable.Renderer.AddDXButton(acShowCards, @FTable.Renderer.Metrics.ActionButtonsBounds[0],
       TableResources.ActionButtonNormalImage, TableResources.ActionButtonPressedImage, nil, TRUE, 0.9);
  FDXBCheck := FTable.Renderer.AddDXButton(acCheck, @FTable.Renderer.Metrics.ActionButtonsBounds[1],
       TableResources.ActionButtonNormalImage, TableResources.ActionButtonPressedImage, nil, TRUE, 0.9);
  FDXBCall := FTable.Renderer.AddDXButton(acCall, @FTable.Renderer.Metrics.ActionButtonsBounds[1],
       TableResources.ActionButtonNormalImage, TableResources.ActionButtonPressedImage, nil, TRUE, 0.9);
  FDXBRaise := FTable.Renderer.AddDXButton(acRaise, @FTable.Renderer.Metrics.ActionButtonsBounds[2],
       TableResources.ActionButtonNormalImage, TableResources.ActionButtonPressedImage, nil, TRUE, 0.9);

  FDXBRaisePresets[0] := FTable.Renderer.AddDXButton(acRaiseMin, @FTable.Renderer.Metrics.RaisePresetButtonsBounds[0],
       TableResources.RaisePresetButtonNormalImage, TableResources.RaisePresetButtonPressedImage, nil, TRUE, 0.75);
  FDXBRaisePresets[1] := FTable.Renderer.AddDXButton(acRaise3BB, @FTable.Renderer.Metrics.RaisePresetButtonsBounds[1],
       TableResources.RaisePresetButtonNormalImage, TableResources.RaisePresetButtonPressedImage, nil, TRUE, 0.75);
  FDXBRaisePresets[2] := FTable.Renderer.AddDXButton(acRaisePot, @FTable.Renderer.Metrics.RaisePresetButtonsBounds[2],
       TableResources.RaisePresetButtonNormalImage, TableResources.RaisePresetButtonPressedImage, nil, TRUE, 0.75);
  FDXBRaisePresets[3] := FTable.Renderer.AddDXButton(acRaiseMax, @FTable.Renderer.Metrics.RaisePresetButtonsBounds[3],
       TableResources.RaisePresetButtonNormalImage, TableResources.RaisePresetButtonPressedImage, nil, TRUE, 0.75);

  Constraints.MinWidth := 600;
  Constraints.MinHeight := Round(Constraints.MinWidth / FORM_ASPECT_RATIO);

  rvChat.ClearAll;
  rvChat.Format;
end;

procedure TfrmTable.FormDestroy(Sender: TObject);
begin
  if FCallbacksId <> -1 then
    MessageContainer.RemoveCallbacks(FCallbacksId);

  DXTimer.RemoveAnimations(Handle);
end;

procedure TfrmTable.FormPaint(Sender: TObject);
begin
  FTable.Renderer.Render;
end;

procedure TfrmTable.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.ExStyle := AParams.ExStyle or WS_EX_APPWINDOW;
  AParams.WndParent := 0;
end;

procedure TfrmTable.WMSizing(var AMessage: TMessage);
begin
  inherited;

  if WindowState <> wsMaximized then
    case AMessage.wParam of
      WMSZ_LEFT, WMSZ_RIGHT, WMSZ_BOTTOMLEFT: with PRect(AMessage.LParam)^ do Bottom := Top + Round((Right - Left) / FORM_ASPECT_RATIO);
      WMSZ_TOP, WMSZ_BOTTOM, WMSZ_TOPRIGHT, WMSZ_BOTTOMRIGHT: with PRect(AMessage.LParam)^ do Right := Left + Round((Bottom - Top) * FORM_ASPECT_RATIO);
      WMSZ_TOPLEFT: with PRect(AMessage.LParam)^ do Top := Bottom - Round((Right - Left) / FORM_ASPECT_RATIO);
    end;
end;

procedure TfrmTable.WndProc(var AMessage: TMessage);
begin
  // prevent ALT key from switching between forms
  if (AMessage.Msg = WM_SYSCOMMAND) and
     (AMessage.WParam = SC_KEYMENU) then
    Exit;

  if AMessage.Msg = WM_DIRECTX_ANIMATION then
    FTable.Renderer.AnimationCallback(pointer(AMessage.WParam));

  inherited;
end;

procedure TfrmTable.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Tables.Remove(FTable);
  FTable := nil;
end;

procedure TfrmTable.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmLeaveTable;
end;

procedure TfrmTable.FormResize(Sender: TObject);
begin
  RefreshAll;
end;

procedure TfrmTable.FocusWindow;
var
  fgwin: HWND;
  C1: Integer;
begin
  // check if table is currently in focus
  fgwin := GetForegroundWindow;
  for C1 := 0 to Tables.Count - 1 do
    if tables[C1].Form.Handle = fgwin then
      Exit;

  // if its not in focus, focus it
  if not FWindowFocused then
  begin
    if IsIconic(Handle) then
      ShowWindow(Handle, SW_RESTORE);
    SetForegroundWindow(Handle);
    BringToFront;
    SetFocus;
    FWindowFocused := TRUE;

    // if chat is not focused, focus raise box, otherwise keep chatbox focus
    if (not edChat.Focused) and
       (seRaiseAmount.Visible) then
      seRaiseAmount.SetFocus;

    TablePlaySound(Sounds.SOUND_TIMEBAR);
  end;
end;

procedure TfrmTable.FormActivate(Sender: TObject);
begin
  DefocusControls;
end;

procedure TfrmTable.FormShow(Sender: TObject);
begin
  if FTable.TableType = ttHandPlayback then
  begin
    SetTableStatus(FTable.HandHistoryPlayback.CurrentState, FALSE);
    tiHandPlayback.Enabled := TRUE;
  end
  else
    RefreshAll;
end;

procedure TfrmTable.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  set_raise_amount: Boolean;
begin
  DefocusControls;
  FTable.Renderer.MouseDown(Button, Shift, X, Y, set_raise_amount);
  if set_raise_amount then
    SetRaiseValue(RoundToNearestBB(Round(FTable.Renderer.TableStatus.MaximumRaise * FTable.Renderer.RaiseThumbPosition), FTable.Game.BigBlind), TRUE, FALSE);
  FTable.Renderer.Render;
end;

procedure TfrmTable.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  set_raise_amount: Boolean;
begin
  FTable.Renderer.MouseMove(Shift, X, Y, set_raise_amount);

  if set_raise_amount then
    SetRaiseValue(RoundToNearestBB(Round(FTable.Renderer.TableStatus.MaximumRaise * FTable.Renderer.RaiseThumbPosition), FTable.Game.BigBlind));
end;

procedure TfrmTable.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FTable.Renderer.MouseUp(Button, Shift, X, Y);
  FTable.Renderer.Render;
end;

procedure TfrmTable.FormClick(Sender: TObject);
var
  seat_info: TSeatInfo;
  client_cursor_pos: TPoint;
  seat_index: Integer;
begin
  client_cursor_pos := ScreenToClient(Mouse.CursorPos);

  DefocusControls;

  if (FTable.TableType = ttLiveGame) and
     (FTable.Game.State <> gsClosed) and
     (FTable.Renderer.Metrics.IsPointInSeat(client_cursor_pos.X, client_cursor_pos.Y, seat_index)) and
     (((not FTable.IsSitting) and
       (not FTable.Renderer.TableStatus.IsSeatTaken(seat_index))) or
      ((FTable.IsSitting) and
       (FTable.SeatIndex = seat_index) and
       (FTable.Renderer.TableStatus.GetSeatInfo(FTable.SeatIndex, seat_info)) and
       (seat_info.Status in [psOutOfPlay, psOutOfHand]))) then
    FormsContainer.Add(RunModalForm(TfrmTableSit, self, [FTable, FTable.Renderer.TableStatus, @seat_index], ModalFormClose));
end;

procedure TfrmTable.seRaiseAmountKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = vk_RETURN then
    acRaise.Execute;
end;

procedure TfrmTable.seRaiseAmountPropertiesChange(Sender: TObject);
var
  val: Single;
  valuint: UINT32;
begin
  if TryStrToFloat(seRaiseAmount.Text, val) then
  begin
    valuint := Round(val * 100);
    if valuint > FTable.Renderer.TableStatus.MaximumRaise then
      valuint := FTable.Renderer.TableStatus.MaximumRaise;
    SetRaiseValue(valuint, FALSE);
  end;
end;

procedure TfrmTable.tiActiveFrameBlinkTimer(Sender: TObject);
begin
  if FTable.Renderer.TableStatus.CurrentSeat = -1 then
  begin
    tiActiveFrameBlink.Enabled := FALSE;
    Exit;
  end;

  if tiActiveFrameBlink.Tag = 0 then
    tiActiveFrameBlink.Tag := 1
  else
    tiActiveFrameBlink.Tag := 0;

  FTable.Renderer.Render;
end;

procedure TfrmTable.tiGameLockTimer(Sender: TObject);
begin
  tiGameLock.Enabled := FALSE;
  FTable.Renderer.TableStatus.LockTimerEnabled := tiGameLock.Enabled;
  RefreshAll;
end;

procedure TfrmTable.tiHandPlaybackTimer(Sender: TObject);
begin
  SetTableStatus(FTable.HandHistoryPlayback.NextState, TRUE);

  if FTable.Renderer.TableStatus.LockTimerEnabled then
    tiHandPlayback.Interval := tiGameLock.Interval
  else
    tiHandPlayback.Interval := 1000;

  if FTable.HandHistoryPlayback.CurrentStateIndex = FTable.HandHistoryPlayback.States.Count - 1 then
  begin
    tiHandPlayback.Enabled := FALSE;
    btPlayPause.Action := acHandPlaybackPlay;
  end;
end;

procedure TfrmTable.tiRenderTimer(Sender: TObject);
begin
  FTable.Renderer.Render;
  UpdateHandStrength;
end;

procedure TfrmTable.tiSitOutNextBBTimer(Sender: TObject);
var
  seat_info: TSeatInfo;
begin
  if (FTable.Renderer.TableStatus.GetSeatInfo(FTable.SeatIndex, seat_info)) and
     (seat_info.Status <> psOutOfPlay) then
    ServerSocket.TableSitOutNextBB(FTable.Game.MongoId, cbSitOutNextBB.Checked);

  tiSitOutNextBB.Enabled := FALSE;
end;

procedure TfrmTable.tiSitOutNextHandTimer(Sender: TObject);
var
  seat_info: TSeatInfo;
begin
  if (FTable.Renderer.TableStatus.GetSeatInfo(FTable.SeatIndex, seat_info)) and
     (seat_info.Status <> psOutOfPlay) then
    ServerSocket.TableSitOutNextHand(FTable.Game.MongoId, cbSitOutNextHand.Checked);

  tiSitOutNextHand.Enabled := FALSE;
end;

procedure TfrmTable.UpdateHandHistoryLabel;
var
  hhis: THandHistoryItems;
begin
  if (FTable.TableType = ttLiveGame) and
     (HandHistory.FindGame(FTable.GameId, hhis)) and
     (hhis.LastHandId > 0) then
  begin
    lbvHandHistory.Caption := Format('Previous Hand (#%d)', [hhis.LastHandId]);
    lbvHandHistory.Visible := TRUE;
  end
  else
    lbvHandHistory.Visible := FALSE
end;

procedure TfrmTable.UpdateHandStrength;
var
  seat_info: TSeatInfo;
begin
  if (FTable.IsSitting) and
     (FTable.Renderer.TableStatus.GetSeatInfo(FTable.SeatIndex, seat_info)) and
     (seat_info.Status in [psAllIn, psFolded, psInHand]) and
     (seat_info.CardCount > 0) and
     (seat_info.DealtCards = seat_info.CardCount) then
  begin
    if (FTable.Renderer.FlopAnimations.Count = 0) and
       (FTable.Renderer.TurnAnimations.Count = 0) and
       (FTable.Renderer.RiverAnimations.Count = 0) then
      lbvHandStrength.Caption := THandStrengthCalculator.GetHandStrength(seat_info.Cards.AsString,
            FTable.Renderer.TableStatus.FlopCards.AsString + FTable.Renderer.TableStatus.TurnCard.AsString + FTable.Renderer.TableStatus.RiverCard.AsString,
            FTable.Renderer.TableStatus.CurrentGame, TRUE)
  end
  else
    lbvHandStrength.Caption := '';
end;

procedure TfrmTable.UpdateTableCaption;
var
  cap: String;
  currentgame: String;
  rot_index: Integer;
  hhi: THandHistoryItem;
begin
  case FTable.TableType of
    ttLiveGame: begin
      if FTable.Game.GameType = gtRotationNLHPLO then
      begin
        case FTable.Renderer.TableStatus.CurrentGame of
          gtHoldem: currentgame := 'NLH';
          gtOmaha: currentgame := 'PLO';
        end;
        rot_index := FTable.Renderer.TableStatus.RotationHand;
        if rot_index = 0 then
          rot_index := 1;
        cap := Format('%s (%s/%s %s) (%d/%d %s) - %s', [FTable.Game.Name, ChipsToStr(FTable.Game.SmallBlind), ChipsToStr(FTable.Game.BigBlind), FTable.Game.AsString(TRUE), (rot_index - 1) mod FTable.Game.Seats + 1, FTable.Game.Seats, currentgame, FTable.Club.Name])
      end
      else
        cap := Format('%s (%s/%s %s) - %s', [FTable.Game.Name, ChipsToStr(FTable.Game.SmallBlind), ChipsToStr(FTable.Game.BigBlind), FTable.Game.AsString(TRUE), FTable.Club.Name]);
    end;

    ttHandPlayback: if GetHandHistoryItem(hhi) then
      cap := Format('Hand #%d: %s (%s/%s) - %s', [hhi.HandId, TGameInfo.GameTypeToStr(hhi.CurrentGame, hhi.ParentItems.Game.Limit, FALSE),
               ChipsToStr(hhi.ParentItems.Game.SmallBlind), ChipsToStr(hhi.ParentItems.Game.BigBlind), hhi.StartTimeStr]);
  end;

  if cap <> Caption then
    Caption := cap;
end;

function TfrmTable.GetHandHistoryItem(out AHandHistoryItem: THandHistoryItem): Boolean;
var
  hhis: THandHistoryItems;
begin
  if (FTable.TableType <> ttHandPlayback) or
     (not HandHistory.FindGame(FTable.GameId, hhis)) or
     (not hhis.FindHand(FTable.HandId, AHandHistoryItem)) then
    Exit(FALSE);

  Exit(TRUE);
end;

procedure TfrmTable.lbvHandHistoryClick(Sender: TObject);
begin
  acHandHistory.Execute;
end;

procedure TfrmTable.ModalFormClose(Sender: TObject);
begin
  EnableWindow(Handle, TRUE);
end;

procedure TfrmTable.edChatEnter(Sender: TObject);
begin
  if edChat.Style.TextColor = clGray then
  begin
    edChat.Clear;
    edChat.Style.TextColor := clWhite;
  end;
end;

procedure TfrmTable.edChatExit(Sender: TObject);
begin
  if edChat.Text = '' then
  begin
    edChat.Style.TextColor := clGray;
    edChat.Text := 'Click here to chat...';
  end;
end;

procedure TfrmTable.edChatKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_RETURN: begin
      if edChat.Text <> '' then
      begin
        if Trim(edChat.Text) <> '' then
          ServerSocket.SendTableChatLine(FTable.Game.MongoId, Trim(edChat.Text));
        edChat.Clear;
      end;
      Key := #0;
    end;
  end;
end;

procedure TfrmTable.EnableGameLockTimer(const ASeconds: Single);
begin
  tiGameLock.Enabled := FALSE;
  tiGameLock.Interval := Round(ASeconds * 1000);
  tiGameLock.Enabled := TRUE;
  FTable.Renderer.TableStatus.LockTimerEnabled := tiGameLock.Enabled;
end;

procedure TfrmTable.acShowCardsExecute(Sender: TObject);
var
  seat: TSeatInfo;
begin
  ServerSocket.ShowCards(FTable.Game.MongoId);
  acShowCards.Enabled := FALSE;
  if FTable.Renderer.TableStatus.GetSeatInfo(FTable.SeatIndex, seat) then
    seat.CardsVisible := TRUE;
  RefreshAll;
end;

procedure TfrmTable.acStandUpExecute(Sender: TObject);
begin
  if not ConfirmStandUp then
    Exit;

  ServerSocket.TableStandUp(FTable.Game.MongoId);
end;

procedure TfrmTable.AddDealerChatMessage(const AMessage: String);
begin
  CheckChatScrollbackLimit;

  rvChat.AddNL('Dealer: ', 2, 0);
  rvChat.AddNL(AMessage, 3, -1);

  if rvChat.VScrollPos < rvChat.VScrollMax then
    rvChat.Format
  else
    rvChat.FormatTail;
end;

procedure TfrmTable.AddUserChatMessage(const AUser, AMessage: String);
begin
  CheckChatScrollbackLimit;

  rvChat.AddNL(Format('%s: ', [AUser]), 0, 0);
  rvChat.AddNL(AMessage, 1, -1);

  if rvChat.VScrollPos < rvChat.VScrollMax then
    rvChat.Format
  else
    rvChat.FormatTail;
end;

procedure TfrmTable.cbFoldToAnyBetPropertiesChange(Sender: TObject);
begin
  RefreshAll;
end;

procedure TfrmTable.cbSitOutNextBBPropertiesChange(Sender: TObject);
begin
  tiSitOutNextBB.Enabled := FALSE;
  tiSitOutNextBB.Enabled := TRUE;
end;

procedure TfrmTable.cbSitOutNextHandPropertiesChange(Sender: TObject);
begin
  tiSitOutNextHand.Enabled := FALSE;
  tiSitOutNextHand.Enabled := TRUE;
end;

procedure TfrmTable.CSEGameChange(const AMethodId: Integer; const AObject: TObject);
begin
  FTable.Renderer.TableStatus.UpdateClosingTime(FTable.Game);
  RefreshAll;
end;

procedure TfrmTable.CSEUserChange(const AMethodId: Integer; const AObject: TObject);
begin
  RefreshAll;
end;

procedure TfrmTable.CSRChatEvent(const AMethodId: Integer; const AObject: TObject);
var
  chat_event: TPB_ChatEvent;
  chat_message: TPB_ChatMessage;
begin
  chat_event := AObject as TPB_ChatEvent;

  case chat_event.Event of
    ceUserMessage: begin
      chat_message := chat_event.Msg;
      if CompareBytes(chat_event.TableId, FTable.Game.MongoId) then
        AddUserChatMessage(chat_message.Username, chat_message.Msg);
    end;
    ceServerMessage: ;
  end;
end;

procedure TfrmTable.CheckChatScrollbackLimit;
begin
  if rvChat.ItemCount >= Settings.Hardcoded.TABLE_CHAT_SCROLLBACK_LINES then
    rvChat.DeleteParas(0, rvChat.ItemCount - Settings.Hardcoded.TABLE_CHAT_SCROLLBACK_LINES + 1);
end;

procedure TfrmTable.ConfigureActions(out AFocusWindow: Boolean);
var
  raise_en: Boolean;
  seat_info: TSeatInfo;
begin
  AFocusWindow := FALSE;
  raise_en := FTable.Renderer.TableStatus.ActionRaise;
  FTable.Renderer.TableStatus.ActionStandUp := FALSE;
  FTable.Renderer.TableStatus.ActionFold := FALSE;
  FTable.Renderer.TableStatus.ActionCall := FALSE;
  FTable.Renderer.TableStatus.ActionCheck := FALSE;
  FTable.Renderer.TableStatus.ActionRaise := FALSE;
  FTable.Renderer.TableStatus.ActionBet := FALSE;
  FTable.Renderer.TableStatus.ActionPlayNow := FALSE;
  FTable.Renderer.TableStatus.ActionSitOut := FALSE;
  FTable.Renderer.TableStatus.ActionFoldToAny := FALSE;
  FTable.Renderer.TableStatus.ActionSitOutNextBB := FALSE;
  FTable.Renderer.TableStatus.ActionShowCards := FALSE;

  seat_info := nil;
  if (FTable.TableType = ttLiveGame) and
     (FTable.Renderer.TableStatus.GetSeatInfo(FTable.SeatIndex, seat_info)) then
  begin
    FTable.Renderer.TableStatus.ActionStandUp := TRUE;

    if FTable.Game.State <> gsClosed then
      case seat_info.Status of
        psOutOfPlay: begin
          FTable.Renderer.TableStatus.ActionPlayNow := TRUE;
          FTable.Renderer.TableStatus.ActionFoldToAny := FALSE;
          FTable.Renderer.TableStatus.ActionSitOut := FALSE;
          FTable.Renderer.TableStatus.ActionSitOutNextBB := FALSE;
        end;

        psOutOfHand: begin
          FTable.Renderer.TableStatus.ActionFoldToAny := FALSE;
          FTable.Renderer.TableStatus.ActionSitOut := TRUE;
          FTable.Renderer.TableStatus.ActionSitOutNextBB := TRUE;
        end;

        psInHand, psAllIn: begin
          FTable.Renderer.TableStatus.ActionSitOut := TRUE;
          FTable.Renderer.TableStatus.ActionSitOutNextBB := TRUE;
          if (seat_info.Status = psInHand) and
             (FTable.Renderer.TableStatus.State in [tsPreFlop, tsFlop, tsTurn, tsRiver]) then
            FTable.Renderer.TableStatus.ActionFoldToAny := TRUE;

          if (FTable.Renderer.TableStatus.CurrentSeat = FTable.SeatIndex) and
             (not FTable.Renderer.TableStatus.Locked) and
             (not FTable.Renderer.TableStatus.LockTimerEnabled) then
            case FTable.Renderer.TableStatus.State of
              tsIdle: begin
                FTable.Renderer.TableStatus.ActionFoldToAny := FALSE;
              end;

              tsPreFlop, tsFlop, tsTurn, tsRiver: begin
                FTable.Renderer.TableStatus.ActionFold := TRUE;
                // check if our current bet is smaller than minimumbet (call/raise situation)
                if FTable.Renderer.TableStatus.GetBet(seat_info.SeatIndex) < FTable.Renderer.TableStatus.MinimumBet then
                begin
                  if seat_info.Chips <= FTable.Renderer.TableStatus.MinimumBet then
                       FTable.Renderer.TableStatus.ActionCallCaption := 'CALL (ALL-IN)'
                     else
                       FTable.Renderer.TableStatus.ActionCallCaption := Format('CALL (%s)', [ChipsToStr(FTable.Renderer.TableStatus.MinimumBet - FTable.Renderer.TableStatus.GetBet(seat_info.SeatIndex))]);
                     FTable.Renderer.TableStatus.ActionCall := TRUE;

                  // if we can call, there is a possibility that we can raise too - we check if we can raise here
                  if (seat_info.Chips > FTable.Renderer.TableStatus.MinimumBet) and
                     (FTable.Renderer.TableStatus.MinimumBet < FTable.Renderer.TableStatus.MinimumRaise) then
                    FTable.Renderer.TableStatus.ActionRaise := TRUE;
                end
                else // if our current bet isnt smaller than minimum bet, that means its check/raise situation
                begin
                  FTable.Renderer.TableStatus.ActionCheck := TRUE;
                  FTable.Renderer.TableStatus.ActionBet := TRUE;
                end;

                AFocusWindow := TRUE;
              end;

              tsWinning, tsWinning2: begin
                FTable.Renderer.TableStatus.ActionFoldToAny := FALSE;
              end;
            end
          else
            FWindowFocused := FALSE;
        end;

        psFolded: begin
          FTable.Renderer.TableStatus.ActionFoldToAny := FALSE;
          FTable.Renderer.TableStatus.ActionSitOut := TRUE;
          FTable.Renderer.TableStatus.ActionSitOutNextBB := TRUE;
        end;
      end;
  end;

  // if raise slider was not enabled, set it to minimum value
  if not raise_en then
    FRaiseValue := FTable.Renderer.TableStatus.MinimumRaise;
  SetRaiseValue(FRaiseValue, TRUE, TRUE, FALSE);

  // check if SHOW CARDS button is enabled
  FTable.Renderer.TableStatus.ActionShowCards := (FTable.Renderer.TableStatus.State in [tsWinning, tsWinning2]) and
                                  (Assigned(seat_info)) and
                                  (seat_info.CanShow) and
                                  (not seat_info.CardsVisible) and
                                  (seat_info.Status in [psFolded, psAllIn, psInHand]);

  // enable actions
  acStandUp.Enabled := FTable.Renderer.TableStatus.ActionStandUp;
  acFold.Enabled := FTable.Renderer.TableStatus.ActionFold;
  acCall.Enabled := FTable.Renderer.TableStatus.ActionCall;
  acCheck.Enabled := FTable.Renderer.TableStatus.ActionCheck;
  acRaise.Enabled := FTable.Renderer.TableStatus.ActionRaise;
  acRaise.Enabled := (FTable.Renderer.TableStatus.ActionBet) or (FTable.Renderer.TableStatus.ActionRaise);
  acRaiseMin.Enabled := acRaise.Enabled;
  acRaise3BB.Enabled := acRaise.Enabled;
  acRaisePot.Enabled := acRaise.Enabled;
  acRaiseMax.Enabled := acRaise.Enabled;
  acPlayNow.Enabled := FTable.Renderer.TableStatus.ActionPlayNow;
end;

procedure TfrmTable.ConfigureGUI;
var
  hround: Integer;
begin
  if WindowState <> wsMaximized then
  begin
    hround := Round(Width / FORM_ASPECT_RATIO);
    if Height <> hround then
      Height := hround;
  end;

  rvChat.BoundsRect := FTable.Renderer.Metrics.ChatBoxBounds;

  case FTable.TableType of
    ttLiveGame: begin
      edChat.BoundsRect := FTable.Renderer.Metrics.ChatEditBounds;
      seRaiseAmount.BoundsRect := FTable.Renderer.Metrics.RaiseAmountBoxBounds;
      seRaiseAmount.Style.Font.Size := FTable.Renderer.Metrics.RaiseAmountBoxFontSize;

      cbSitOutNextBB.Top := rvChat.Top + rvChat.Height - cbSitOutNextBB.Height;
      cbSitOutNextHand.Top := cbSitOutNextBB.Top - cbSitOutNextHand.Height;
      cbFoldToAnyBet.Top := cbSitOutNextHand.Top - cbFoldToAnyBet.Height;

      cbFoldToAnyBet.Left := FTable.Renderer.Metrics.CheckboxesLeft;
      cbSitOutNextHand.Left := FTable.Renderer.Metrics.CheckboxesLeft;
      cbSitOutNextBB.Left := FTable.Renderer.Metrics.CheckboxesLeft;

      if FTable.Renderer.TableStatus.ActionSitOut then
      begin
        cbSitOutNextHand.Visible := TRUE;
        cbSitOutNextBB.Visible := TRUE;
        cbFoldToAnyBet.Visible := TRUE;

        cbSitOutNextBB.Enabled := FTable.Renderer.TableStatus.ActionSitOutNextBB;
        cbFoldToAnyBet.Enabled := FTable.Renderer.TableStatus.ActionFoldToAny;

        if not cbSitOutNextBB.Enabled then
          cbSitOutNextBB.Checked := FALSE;

        if not cbFoldToAnyBet.Enabled then
          cbFoldToAnyBet.Checked := FALSE;
      end
      else
      begin
        cbSitOutNextHand.Visible := FALSE;
        cbSitOutNextBB.Visible := FALSE;
        cbFoldToAnyBet.Visible := FALSE;
        cbSitOutNextHand.Checked := FALSE;
        cbSitOutNextBB.Checked := FALSE;
        cbFoldToAnyBet.Checked := FALSE;
      end;

      seRaiseAmount.Visible := acRaise.Enabled;
      acRaiseMin.Enabled := acRaise.Enabled;
      acRaise3BB.Enabled := acRaise.Enabled;
      acRaisePot.Enabled := acRaise.Enabled;
      acRaiseMax.Enabled := acRaise.Enabled;

      if acRaise.Enabled then
      begin
        // if game is pot limit, we dont have to show MAX button, since POT = MAX
        if FTable.Renderer.TableStatus.CurrentLimit = glPotLimit then
        begin
          FTable.Renderer.GetDXButton(FDXBRaisePresets[0]).Action := nil;
          FTable.Renderer.GetDXButton(FDXBRaisePresets[1]).Action := acRaiseMin;
          FTable.Renderer.GetDXButton(FDXBRaisePresets[2]).Action := acRaise3BB;
          FTable.Renderer.GetDXButton(FDXBRaisePresets[3]).Action := acRaisePot;
        end
        else
        begin
          FTable.Renderer.GetDXButton(FDXBRaisePresets[0]).Action := acRaiseMin;
          FTable.Renderer.GetDXButton(FDXBRaisePresets[1]).Action := acRaise3BB;
          FTable.Renderer.GetDXButton(FDXBRaisePresets[2]).Action := acRaisePot;
          FTable.Renderer.GetDXButton(FDXBRaisePresets[3]).Action := acRaiseMax;
        end;

        SetRaiseValue(FRaiseValue, TRUE, TRUE, FALSE);
      end;

      // enable seat blink timer, if it's not enabled already
      if (FTable.Renderer.TableStatus.CurrentSeat <> -1) and
         (not tiActiveFrameBlink.Enabled) and
         (not FTable.Renderer.TableStatus.Locked) and
         (not FTable.Renderer.TableStatus.LockTimerEnabled) then
      begin
        tiActiveFrameBlink.Tag := 1;
        tiActiveFrameBlink.Enabled := TRUE;
      end;

      lbvHandStrength.Top := Round(FTable.Renderer.GetDXButton(FDXBRaisePresets[High(FDXBRaisePresets)]).Bounds[0].y - lbvHandStrength.Height - 5);
      UpdateHandHistoryLabel;
    end;

    ttHandPlayback: begin
      rvChat.Color := $00262626;
      pbHandPlaybackProgress.BoundsRect := FTable.Renderer.Metrics.HandPlaybackProgress;
      btPlayPause.BoundsRect := FTable.Renderer.Metrics.HandPlaybackPlay;
      btStepForward.BoundsRect := FTable.Renderer.Metrics.HandPlaybackForward;
      btStepBackwards.BoundsRect := FTable.Renderer.Metrics.HandPlaybackBack;
    end;
  end;

  UpdateHandStrength;
  UpdateTableCaption;
end;

procedure TfrmTable.tiSeatClearCaptionTimer(Sender: TObject);
var
  seat: TSeatInfo;
begin
  if (FTable.Renderer.TableStatus.GetSeatInfo(tiSeatCaptionClear.Tag, seat)) and
     (seat.LowerCaption <> '') then
  begin
    seat.LowerCaption := '';
    FTable.Renderer.Render;
  end;

  tiSeatCaptionClear.Enabled := FALSE;
end;

function TfrmTable.ConfirmLeaveTable: Boolean;
begin
  result := TRUE;
  if (FTable.TableType = ttLiveGame) and
     (FTable.IsSitting) then
    result := MessageDlg('Are you sure you want to leave the table? This will automatically fold your current hand and get you up from the seat.', mtWarning, mbYesNo, 0) = mrYes;
end;

function TfrmTable.ConfirmStandUp: Boolean;
var
  seat: TSeatInfo;
begin
  result := TRUE;
  if (FTable.TableType = ttLiveGame) and
     (FTable.IsSitting) and
     (FTable.Renderer.TableStatus.GetSeatInfo(FTable.SeatIndex, seat)) and
     (seat.Status in [psInHand, psFolded, psAllIn]) then
    result := MessageDlg('Are you sure you want to stand up? This will automatically fold your current hand and any chips that you commited to current pot.', mtWarning, mbYesNo, 0) = mrYes;
end;

procedure TfrmTable.CSRETableStatus(const AMethodId: Integer; const AObject: TObject);
var
  pbtablestatus: TPB_TableStatus;
  C1: Integer;
  seat_index: Integer;
  player: TPlayerInfo;
  query_users: TArray<TBytes>;
  empty_array: TBytes;
  seat: TSeatInfo;
  winning: Boolean;
  {$IFDEF DEBUG}
  pbevent: TPB_TableEvent;
  events: String;
  tmp: String;
  tb: UINT32;
  tstatusdbg: String;
  csdbg: String;
  seatdbg: TSeatInfo;
  playerdbg: TPlayerInfo;
  {$ENDIF}
begin
  pbtablestatus := AObject as TPB_TableStatus;
  if not CompareBytes(pbtablestatus.TableMongoId, FTable.Game.MongoId) then
    Exit;

  // update local objects with new table status
  FTable.Renderer.TableStatus.Assign(pbtablestatus);

  // ActionManager is initially in suspended state, to make sure no actions can be executed while table contains no data
  // this block is executed when first tablestatus is received, and it also enables ActionManager
  if ActionManager.State = asSuspended then
  begin
    ActionManager.State := asNormal;
    for C1 := 0 to FTable.Renderer.TableStatus.Seats.Count - 1 do
      FTable.Renderer.TableStatus.Seats[C1].FillDealtCards;

    if FTable.Renderer.TableStatus.State in [tsFlop, tsTurn, tsRiver, tsWinning, tsWinning2] then
      FTable.Renderer.FlopAnimated := TRUE;
    if FTable.Renderer.TableStatus.State in [tsTurn, tsRiver, tsWinning, tsWinning2] then
      FTable.Renderer.TurnAnimated := TRUE;
    if FTable.Renderer.TableStatus.State in [tsRiver, tsWinning, tsWinning2] then
      FTable.Renderer.RiverAnimated := TRUE;
  end;

  // iterate through table status seats and find our seat index
  seat_index := -1;
  for C1 := 0 to pbtablestatus.Seats.Count - 1 do
    if CompareBytes(pbtablestatus.Seats[C1].PlayerMongoId, dmMain.SelfInfo.Id) then
    begin
      seat_index := pbtablestatus.Seats[C1].Seat;
      Break;
    end;
  FTable.SeatIndex := seat_index;

  // reset animation delays
  FTable.Renderer.WinningFlopAniDelay := 0;
  FTable.Renderer.WinningTurnAniDelay := 0;
  FTable.Renderer.WinningRiverAniDelay := 0;
  FTable.Renderer.WinningAniDelay := 0;

  // check if its winning phase
  winning := FALSE;
  for C1 := 0 to pbtablestatus.Events.Count - 1 do
    if pbtablestatus.Events[C1].Event = teWinning then
    begin
      winning := TRUE;
      Break;
    end;

  // ...and if it is, make animation delays
  // this is required if everyone goes all in pre-flop for example, so it shows cards one by one (flop > turn > river), with proper delays
  if winning then
    for C1 := 0 to pbtablestatus.Events.Count - 1 do
      case pbtablestatus.Events[C1].Event of
        teFlop: FTable.Renderer.WinningFlopAniDelay := 0.2;
        teTurn: FTable.Renderer.WinningTurnAniDelay := FTable.Renderer.WinningFlopAniDelay + 1;
        teRiver: FTable.Renderer.WinningRiverAniDelay := FTable.Renderer.WinningFlopAniDelay + FTable.Renderer.WinningTurnAniDelay + 1;
        teWinning: FTable.Renderer.WinningAniDelay := FTable.Renderer.WinningFlopAniDelay + FTable.Renderer.WinningTurnAniDelay + FTable.Renderer.WinningRiverAniDelay + 0.2;
      end;

  // process table events
  for C1 := 0 to pbtablestatus.Events.Count - 1 do
    ProcessTableEvent(pbtablestatus.Events[C1]);

  // get user infos that we dont have
  SetLength(query_users, 0);
  for seat in FTable.Renderer.TableStatus.Seats do
    if not Players.FindPlayerById(seat.PlayerMongoId, player) then
    begin
      SetLength(query_users, Length(query_users) + 1);
      query_users[Length(query_users) - 1] := seat.PlayerMongoId;
    end;

  if Length(query_users) > 0 then
  begin
    SetLength(empty_array, 0);
    for C1 := 0 to Length(query_users) - 1 do
      Players.AddPlayer(query_users[C1], 'Retrieving...', '', 0, empty_array);
    ServerSocket.GetUserInfos(query_users);
  end;

  // update self info
  dmMain.SelfInfo.Balance := pbtablestatus.TotalBalance;
  dmMain.UpdateSelfInfoInPlayers;

  {$IFDEF DEBUG}
  tmp := GetEnumName(TypeInfo(TTableState), Integer(FTable.Renderer.TableStatus.State));
  if pbtablestatus.Locked then
    tmp := tmp + ', LOCKED';
  seatdbg := nil;
  playerdbg := nil;
  tb := 0;
  csdbg := IntToStr(FTable.Renderer.TableStatus.CurrentSeat);
  if FTable.Renderer.TableStatus.GetSeatInfo(FTable.Renderer.TableStatus.CurrentSeat, seatdbg) then
  begin
    if Players.FindPlayerById(seatdbg.PlayerMongoId, playerdbg) then
      csdbg := csdbg + ' - ' + playerdbg.Nick;
    tb := seatdbg.Timebank;
  end;

  tstatusdbg := Format('[#%d] %s, D: %d, E: %d | #%s, %.2fs/%.2fs',
    [pbtablestatus.Seq, tmp, FTable.Renderer.TableStatus.Dealer, pbtablestatus.Events.Count, csdbg, FTable.Renderer.TableStatus.CurrentPlaytime / 1000, tb / 100]);

  events := '';
  for C1 := 0 to pbtablestatus.Events.Count - 1 do
  begin
    pbevent := pbtablestatus.Events[C1];
    if events <> '' then
      events := events + #10;

    seatdbg := nil;
    playerdbg := nil;
    if FTable.Renderer.TableStatus.GetSeatInfo(pbevent.Seat, seatdbg) then
      Players.FindPlayerById(seatdbg.PlayerMongoId, playerdbg);

    case pbevent.Event of
      teFold: if Assigned(seatdbg) then
        events := events + Format('FOLD [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FTable.Renderer.TableStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)])
      else
        events := events + Format('FOLD [#%d]', [pbevent.Seat]);
      teSit: events := events + Format('SIT [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FTable.Renderer.TableStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teStandUp: events := events + Format('STAND UP [#%d]', [pbevent.Seat]);
      teWinning: events := events + 'WINNING';
      teDealing: events := events + 'DEALING';
      teCheck: events := events + Format('CHECK [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FTable.Renderer.TableStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teCall: events := events + Format('CALL [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FTable.Renderer.TableStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teRaise: events := events + Format('RAISE [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FTable.Renderer.TableStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teAllIn: events := events + Format('ALL-IN [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FTable.Renderer.TableStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
      teFlop: events := events + Format('FLOP [%s]', [FTable.Renderer.TableStatus.FlopCards.AsString]);
      teTurn: events := events + Format('TURN [%s]', [FTable.Renderer.TableStatus.TurnCard.AsString]);
      teRiver: events := events + Format('RIVER [%s]', [FTable.Renderer.TableStatus.RiverCard.AsString]);
      tePostRiver: events := events + 'POST RIVER';
      tePreWin: events := events + 'PRE WIN';
      teExistingCards: events := events + Format('EXISTING CARDS [%s]', [TCards.BytesToString(pbevent.Cards)]);
      teDisconnect: events := events + Format('DISCONNECTED [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FTable.Renderer.TableStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
    else
      events := events + Format('UNHANDLED EVENT RECEIVED: %s', [GetEnumName(TypeInfo(TTableEventType), Integer(pbevent.Event))]);
    end;
  end;

  DebugLn(tstatusdbg, ditApplication, events);
  {$ENDIF}

  RefreshAll;
end;

procedure TfrmTable.CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
begin
  RefreshAll;
end;

procedure TfrmTable.DefocusControls;
begin
  if edChat.Focused then
    DefocusControl(edChat, FALSE);

  if seRaiseAmount.Focused then
    DefocusControl(seRaiseAmount, FALSE);
end;

procedure TfrmTable.ProcessTableEvent(const ATableEvent: TPB_TableEvent);
var
  seat_caption: String;
  seat: TSeatInfo;
  flop: TBytes;
begin
  seat_caption := '';
  case ATableEvent.Event of
    teExistingCards: begin
      if Length(ATableEvent.Cards) >= 3 then
      begin
        flop := Copy(ATableEvent.Cards, 0, 3);
        FTable.Renderer.TableStatus.FlopCards.Assign(flop);
      end;
      if Length(ATableEvent.Cards) >= 4 then
        FTable.Renderer.TableStatus.TurnCard.Assign(ATableEvent.Cards[3]);
      if Length(ATableEvent.Cards) >= 5 then
        FTable.Renderer.TableStatus.RiverCard.Assign(ATableEvent.Cards[4]);
    end;

    teFold: begin
      tiActiveFrameBlink.Enabled := FALSE;
      seat_caption := 'FOLD';
    end;

    teSit: begin
    end;

    teStandUp: begin
      FTable.Renderer.AnimateBets(Handle, FTable.Renderer.TableStatus.PreviousBets, ATableEvent.Seat);
    end;

    tePostRiver: begin
      FTable.Renderer.TableStatus.PreviousBets.Clear;
      FTable.Renderer.TableStatus.PreviousBets.AddRange(ATableEvent.Bets);
    end;

    teWinning: begin
      EnableGameLockTimer(2 + ATableEvent.Pots.Count * 0.5);

      FTable.Renderer.TableStatus.Pots.Assign(ATableEvent.Pots);

      if FTable.Renderer.AnimateBets(Handle, FTable.Renderer.TableStatus.PreviousBets) then
        TablePlaySound(Sounds.SOUND_MOVE_CHIPS);

      FTable.Renderer.AnimatePots(Handle, ATableEvent.Pots);
    end;

    teDealing: begin
      FTable.Renderer.ClearAnimations;
      FTable.Renderer.ChipStackMaker.Clear;

      FTable.Renderer.TableStatus.NewHandCleanup;

      FTable.Renderer.AnimateBlinds(Handle);
      FTable.Renderer.AnimateDealingCards(Handle);

      EnableGameLockTimer(1.5 + FTable.Renderer.DealAnimations.Count * 0.075);
    end;

    teCheck: begin
      tiActiveFrameBlink.Enabled := FALSE;
      seat_caption := 'CHECK';

      TablePlaySound(Sounds.SOUND_CHECK);
    end;

    teCall: begin
      tiActiveFrameBlink.Enabled := FALSE;
      seat_caption := 'CALL';

      TablePlaySound(Sounds.SOUND_PUTCHIPS_SMALL);
    end;

    teRaise: begin
      tiActiveFrameBlink.Enabled := FALSE;
      seat_caption := 'RAISE';

      TablePlaySound(Sounds.SOUND_PUTCHIPS_SMALL);
    end;

    teAllIn: begin
      tiActiveFrameBlink.Enabled := FALSE;
      seat_caption := 'ALL-IN';
    end;

    teFlop: begin
      FTable.Renderer.TableStatus.FlopCards.Assign(ATableEvent.Cards);

      tiActiveFrameBlink.Enabled := FALSE;
      EnableGameLockTimer(1.5 + FTable.Renderer.WinningFlopAniDelay);
      if FTable.Renderer.AnimateBets(Handle, ATableEvent.Bets) then
        TablePlaySound(Sounds.SOUND_MOVE_CHIPS);
    end;

    teTurn: begin
      FTable.Renderer.TableStatus.TurnCard.Assign(ATableEvent.Cards);

      tiActiveFrameBlink.Enabled := FALSE;
      EnableGameLockTimer(1.5 + FTable.Renderer.WinningTurnAniDelay);
      if FTable.Renderer.AnimateBets(Handle, ATableEvent.Bets) then
        TablePlaySound(Sounds.SOUND_MOVE_CHIPS);
    end;

    teRiver: begin
      FTable.Renderer.TableStatus.RiverCard.Assign(ATableEvent.Cards);

      tiActiveFrameBlink.Enabled := FALSE;
      EnableGameLockTimer(1.5 + FTable.Renderer.WinningRiverAniDelay);
      if FTable.Renderer.AnimateBets(Handle, ATableEvent.Bets) then
        TablePlaySound(Sounds.SOUND_MOVE_CHIPS);
    end;

    teDisconnect: begin
{
      if FTable.Renderer.TableStatus.GetSeatInfo(ATableEvent.Seat, seat) then
        seat_caption := 'DISCONNECTED';}
    end;
  end;

  if seat_caption <> '' then
  begin
    FTable.Renderer.TableStatus.Seats.ClearCaptions;
    if FTable.Renderer.TableStatus.GetSeatInfo(ATableEvent.Seat, seat) then
    begin
      seat.LowerCaption := seat_caption;
      if tiSeatCaptionClear.Enabled then
        tiSeatCaptionClear.OnTimer(tiSeatCaptionClear);
      tiSeatCaptionClear.Enabled := FALSE;
      tiSeatCaptionClear.Tag := seat.SeatIndex;
      tiSeatCaptionClear.Enabled := TRUE;
    end;
  end;
end;

procedure TfrmTable.acCallExecute(Sender: TObject);
var
  seat_info: TSeatInfo;
  seat_bet: UINT32;
  call_amount: Integer;
begin
  Assert(FTable.Renderer.TableStatus.GetSeatInfo(FTable.SeatIndex, seat_info));
  seat_bet := FTable.Renderer.TableStatus.GetBet(seat_info.SeatIndex);
  if seat_bet + seat_info.Chips < FTable.Renderer.TableStatus.MinimumBet then
    call_amount := seat_bet + seat_info.Chips
  else
    call_amount := FTable.Renderer.TableStatus.MinimumBet;

  ServerSocket.PutChips(FTable.Game.MongoId, call_amount, FTable.Renderer.TableStatus.State);
end;

procedure TfrmTable.acCheckExecute(Sender: TObject);
begin
  ServerSocket.PutChips(FTable.Game.MongoId, FTable.Renderer.TableStatus.GetBet(FTable.SeatIndex), FTable.Renderer.TableStatus.State);
end;

procedure TfrmTable.acFoldExecute(Sender: TObject);
begin
  if (acCheck.Enabled) and
     (Settings.FoldChecks) then
    acCheck.Execute
  else
    ServerSocket.Fold(FTable.Game.MongoId);
end;

procedure TfrmTable.acPlayNowExecute(Sender: TObject);
var
  seat: TSeatInfo;
  sindex: Integer;
begin
  if (FTable.IsSitting) and
     (FTable.Renderer.TableStatus.GetSeatInfo(FTable.SeatIndex, seat)) and
     (seat.Chips = 0) then
  begin
    sindex := seat.SeatIndex;
    FormsContainer.Add(RunModalForm(TfrmTableSit, self, [FTable, FTable.Renderer.TableStatus, @sindex], ModalFormClose));
    Exit;
  end;

  ServerSocket.TablePlayNow(FTable.Game.MongoId);
end;

procedure TfrmTable.acRaise3BBExecute(Sender: TObject);
var
  val: UINT32;
begin
  val := FTable.Renderer.TableStatus.MinimumBet;
  if val = 0 then
    val := FTable.Game.BigBlind;

  SetRaiseValue(val * 3);
end;

procedure TfrmTable.acRaiseMaxExecute(Sender: TObject);
begin
  SetRaiseValue(FTable.Renderer.TableStatus.MaximumRaise);
end;

procedure TfrmTable.acRaiseMinExecute(Sender: TObject);
begin
  SetRaiseValue(FTable.Renderer.TableStatus.MinimumRaise);
end;

procedure TfrmTable.acRaiseExecute(Sender: TObject);
begin
  ServerSocket.PutChips(FTable.Game.MongoId, FRaiseValue, FTable.Renderer.TableStatus.State);
end;

procedure TfrmTable.acRaisePotExecute(Sender: TObject);
var
  C1: Integer;
  raise_value: UINT32;
  seat_bet: UINT32;
begin
  seat_bet := FTable.Renderer.TableStatus.GetBet(FTable.SeatIndex);

  raise_value := FTable.Renderer.TableStatus.MinimumBet - seat_bet;
  for C1 := 0 to FTable.Renderer.TableStatus.Pots.Count - 1 do
    Inc(raise_value, FTable.Renderer.TableStatus.Pots[C1].ValueWithoutRake);
  for C1 := 0 to FTable.Renderer.TableStatus.Bets.Count - 1 do
    Inc(raise_value, FTable.Renderer.TableStatus.Bets[C1]);
  raise_value := raise_value + FTable.Renderer.TableStatus.MinimumBet;

  SetRaiseValue(raise_value);
end;

procedure TfrmTable.SetTableStatus(const ATableStatus: TPB_TableStatus; const AClearAnimations: Boolean);
begin
  if AClearAnimations then
    FTable.Renderer.ClearAnimations;

  CSRETableStatus(0, ATableStatus);
  if FTable.TableType = ttHandPlayback then
    pbHandPlaybackProgress.Position := FTable.HandHistoryPlayback.CurrentStateIndex;
end;

procedure TfrmTable.SetRaiseActionCaption;
var
  seat_info: TSeatInfo;
begin
  if FTable.Renderer.TableStatus.GetSeatInfo(FTable.SeatIndex, seat_info) then
  begin
    if FTable.Renderer.TableStatus.ActionRaise then
    begin
      if FRaiseValue = seat_info.Chips + FTable.Renderer.TableStatus.GetBet(FTable.SeatIndex) then
         acRaise.Caption := 'RAISE (ALL-IN)'
      else
         acRaise.Caption := Format('RAISE (%s)', [ChipsToStr(FRaiseValue)])
    end
    else
      if FTable.Renderer.TableStatus.ActionBet then
      begin
        if FRaiseValue = seat_info.Chips then
          acRaise.Caption := 'BET (ALL-IN)'
        else
          acRaise.Caption := Format('BET (%s)', [ChipsToStr(FRaiseValue)]);
      end
      else
        acRaise.Caption := '';
  end;
end;

procedure TfrmTable.SetRaiseValue(const AValue: UINT32; const ASetSpinEditValue: Boolean = TRUE; const AAbsoluteJump: Boolean = TRUE; const AConfigureGUI: Boolean = TRUE);
var
  val: UINT32;
  oldval: UINT32;
begin
  oldval := FRaiseValue;

  val := AValue;
  if not AAbsoluteJump then
  begin
    if val > oldval then
      val := oldval + FTable.Game.BigBlind
    else
      if val < oldval then
        val := oldval - FTable.Game.BigBlind;
  end;

  if val > FTable.Renderer.TableStatus.MaximumRaise then
    val := FTable.Renderer.TableStatus.MaximumRaise
  else
    if val < FTable.Renderer.TableStatus.MinimumRaise then
      val := FTable.Renderer.TableStatus.MinimumRaise;

  FRaiseValue := val;

  if FTable.Renderer.TableStatus.MaximumRaise = FTable.Renderer.TableStatus.MinimumRaise then
    FTable.Renderer.RaiseThumbPosition := 1
  else
    FTable.Renderer.RaiseThumbPosition := (FRaiseValue - FTable.Renderer.TableStatus.MinimumRaise) /
                                          (FTable.Renderer.TableStatus.MaximumRaise - FTable.Renderer.TableStatus.MinimumRaise);

  if ASetSpinEditValue then
    seRaiseAmount.Value := val / 100;

  SetRaiseActionCaption;

  if FRaiseValue <> oldval then
  begin
    FTable.Renderer.Render;
    if AConfigureGUI then
      ConfigureGUI;
  end;
end;

procedure TfrmTable.TablePlaySound(const ASound: String);
begin
  if (GetForegroundWindow = Handle) and
     (Settings.Sounds) then
    Sounds.Play(ASound);
end;

procedure TfrmTable.RefreshAll;
var
  focus_window: Boolean;
begin
  ConfigureActions(focus_window);
  if focus_window then
    FocusWindow;

  FTable.Renderer.Render;
  ConfigureGUI;

  if (FTable.Renderer.TableStatus.ActionFoldToAny) and
     (cbFoldToAnyBet.Checked) then
    if acCheck.Enabled then
      acCheck.Execute
    else
      acFold.Execute;
end;

procedure TfrmTable.RendererDealerChatMessage(const AMessage: String);
begin
  AddDealerChatMessage(AMessage);
end;

procedure TfrmTable.RendererSoundPlay(const ASound: String);
begin
  TablePlaySound(ASound);
end;

procedure TfrmTable.RendererTimebankStarted(Sender: TObject);
begin
  if FTable.Renderer.TableStatus.CurrentSeat = FTable.SeatIndex then
    TablePlaySound(Sounds.SOUND_TIMEBANK);
end;

procedure TfrmTable.CSRHandHistoryMsg(const AMethodId: Integer; const AObject: TObject);
begin
  ConfigureGUI;
end;

procedure TfrmTable.acHandHistoryExecute(Sender: TObject);
var
  form: TForm;
  handid: UINT32;
  hhis: THandHistoryItems;
begin
  if not HandHistory.FindGame(FTable.GameId, hhis) then
    handid := 0
  else
    handid := hhis.LastHandId;

  if FormsContainer.Find(TfrmHandHistory, form) then
  begin
    (form as TfrmHandHistory).SetSelectedHandId(FTable.Game.MongoId, handid);
    form.SetFocus;
  end
  else
    FormsContainer.RunForm(TfrmHandHistory, frmChipUpMain, [FTable.Game, @handid], FALSE)
end;

procedure TfrmTable.acHandPlaybackPauseExecute(Sender: TObject);
begin
  tiHandPlayback.Enabled := FALSE;
  btPlayPause.Action := acHandPlaybackPlay;
end;

procedure TfrmTable.acHandPlaybackPlayExecute(Sender: TObject);
begin
  tiHandPlayback.Enabled := TRUE;
  if FTable.HandHistoryPlayback.CurrentStateIndex = FTable.HandHistoryPlayback.States.Count - 1 then
  begin
    FTable.HandHistoryPlayback.CurrentStateIndex := 0;
    SetTableStatus(FTable.HandHistoryPlayback.CurrentState, TRUE);
  end;
  btPlayPause.Action := acHandPlaybackPause;
end;

procedure TfrmTable.acHandPlaybackStepBackwardsExecute(Sender: TObject);
begin
  acHandPlaybackPause.Execute;
  if FTable.HandHistoryPlayback.CurrentStateIndex > 0 then
    SetTableStatus(FTable.HandHistoryPlayback.PrevState, TRUE);
end;

procedure TfrmTable.acHandPlaybackStepForwardExecute(Sender: TObject);
begin
  acHandPlaybackPause.Execute;
  if FTable.HandHistoryPlayback.CurrentStateIndex < FTable.HandHistoryPlayback.States.Count - 1 then
    SetTableStatus(FTable.HandHistoryPlayback.NextState, TRUE);
end;

end.

