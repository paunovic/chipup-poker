unit Poker.Forms.Table;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, cxContainer, cxEdit, Poker.Tables.Status, Poker.DirectX.Animation, Vectors2,
  Vcl.ActnList, cxLabel, Poker.Tables.Table, cxTextEdit, Vcl.ActnMan, cxSpinEdit, cxCheckBox, Poker.Protobufs.Objects.TableStatus,
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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    const
      FORM_ASPECT_RATIO = 1.35;

    var
      FInternalId: Integer;
      FCallbacksId: Integer;
      FRaiseValue: UINT32;
      FWindowFocused: Boolean;

      FDXBFold: Integer;
      FDXBShowCards: Integer;
      FDXBCheck: Integer;
      FDXBCall: Integer;
      FDXBRaise: Integer;
      FDXBRaisePresets: array[0..3] of Integer;
      {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}

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

    function GetTableCaption: String;
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
    constructor Create(const AInternalId: Integer); reintroduce;

    procedure SetTableStatus(const ATableStatus: TPB_TableStatus; const AClearAnimations: Boolean);
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, System.TypInfo, {$ENDIF}
  Poker.Server.MessageContainer, Poker.Server.Settings, Poker.DirectX.Timer, Poker.Tables.Renderer, Poker.Server.MessageCallbacks,
  Poker.Protobufs.Enum.ServerCodes, Poker.Protobufs.Objects.ChatEvent, Poker.Protobufs.Objects.ChatMessage, Poker.Protobufs.Objects.SeatInfo,
  Poker.Tables.Resources, Poker.WindowMessages, Poker.DirectX.Core, Poker.Common.FormsContainer, Poker.Server.Socket.Commands,
  Poker.Common.Misc, Poker.Settings, Poker.Forms.TableSit, Poker.DataModule, Poker.Players.PlayerList, Poker.Protobufs.Objects.Game,
  Poker.Games.Game, Poker.Sounds, Poker.Protobufs.Objects.WinnerData, Poker.HandStrengthCalculator, Poker.Forms.HandHistory, Poker.Forms.Main,
  Poker.HandHistory.Core, Poker.Pots.Pot, Poker.Seats.Seat, Poker.Cards, Poker.Players.Player, Poker.Tables.TableList, Poker.Clubs.Club;


constructor TfrmTable.Create(const AInternalId: Integer);
begin
  FInternalId := AInternalId;
  inherited Create(nil);

  OnResize := nil;
  ClientWidth := Round(Screen.Monitors[0].Width / 2.5);
  ClientHeight := Round(ClientWidth / FORM_ASPECT_RATIO);
  OnResize := FormResize;
end;

procedure TfrmTable.FormCreate(Sender: TObject);
var
  table: TTable;
begin
  {$IFDEF DEBUG} FDebugId := RegisterDebugObject(Format('TABLE: %s', [GetTableCaption])); {$ENDIF}

  ActionManager.State := asSuspended;

  FCallbacksId := -1;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    case table.TableType of
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
        pbHandPlaybackProgress.Properties.Max := table.HandHistoryPlayback.States.Count - 1;
        pbHandPlaybackProgress.Visible := TRUE;
        btPlayPause.Visible := TRUE;
        btStepForward.Visible := TRUE;
        btStepBackwards.Visible := TRUE;
      end;
    end;

    table.Renderer.UpdateDXAreaSize;

    table.Renderer.OnDealerChatMessage := RendererDealerChatMessage;
    table.Renderer.OnSoundPlay := RendererSoundPlay;
    table.Renderer.OnTimebankStarted := RendererTimebankStarted;

    table.Renderer.AddDXButton(acStandUp, @table.Renderer.Metrics.StandUpButtonBounds, TableResources.StandUpButtonNormalImage, TableResources.StandUpButtonPressedImage, nil);
    table.Renderer.AddDXButton(acPlayNow, @table.Renderer.Metrics.PlayNowButtonBounds, TableResources.PlayNowButtonNormalImage, TableResources.PlayNowButtonPressedImage, nil);

    FDXBFold := table.Renderer.AddDXButton(acFold, @table.Renderer.Metrics.ActionButtonsBounds[0],
         TableResources.ActionButtonNormalImage, TableResources.ActionButtonPressedImage, nil, TRUE, 0.9);
    FDXBShowCards := table.Renderer.AddDXButton(acShowCards, @table.Renderer.Metrics.ActionButtonsBounds[0],
         TableResources.ActionButtonNormalImage, TableResources.ActionButtonPressedImage, nil, TRUE, 0.9);
    FDXBCheck := table.Renderer.AddDXButton(acCheck, @table.Renderer.Metrics.ActionButtonsBounds[1],
         TableResources.ActionButtonNormalImage, TableResources.ActionButtonPressedImage, nil, TRUE, 0.9);
    FDXBCall := table.Renderer.AddDXButton(acCall, @table.Renderer.Metrics.ActionButtonsBounds[1],
         TableResources.ActionButtonNormalImage, TableResources.ActionButtonPressedImage, nil, TRUE, 0.9);
    FDXBRaise := table.Renderer.AddDXButton(acRaise, @table.Renderer.Metrics.ActionButtonsBounds[2],
         TableResources.ActionButtonNormalImage, TableResources.ActionButtonPressedImage, nil, TRUE, 0.9);

    FDXBRaisePresets[0] := table.Renderer.AddDXButton(acRaiseMin, @table.Renderer.Metrics.RaisePresetButtonsBounds[0],
         TableResources.RaisePresetButtonNormalImage, TableResources.RaisePresetButtonPressedImage, nil, TRUE, 0.75);
    FDXBRaisePresets[1] := table.Renderer.AddDXButton(acRaise3BB, @table.Renderer.Metrics.RaisePresetButtonsBounds[1],
         TableResources.RaisePresetButtonNormalImage, TableResources.RaisePresetButtonPressedImage, nil, TRUE, 0.75);
    FDXBRaisePresets[2] := table.Renderer.AddDXButton(acRaisePot, @table.Renderer.Metrics.RaisePresetButtonsBounds[2],
         TableResources.RaisePresetButtonNormalImage, TableResources.RaisePresetButtonPressedImage, nil, TRUE, 0.75);
    FDXBRaisePresets[3] := table.Renderer.AddDXButton(acRaiseMax, @table.Renderer.Metrics.RaisePresetButtonsBounds[3],
         TableResources.RaisePresetButtonNormalImage, TableResources.RaisePresetButtonPressedImage, nil, TRUE, 0.75);
  finally
    Tables.Unlock;
  end;

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

  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}
end;

procedure TfrmTable.FormPaint(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.Renderer.Render;
  finally
    Tables.Unlock;
  end;
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
var
  table: TTable;
begin
  // prevent ALT key from switching between forms
  if (AMessage.Msg = WM_SYSCOMMAND) and
     (AMessage.WParam = SC_KEYMENU) then
    Exit;

  if AMessage.Msg = WM_DIRECTX_ANIMATION then
  begin
    if Tables.GetAndLockTable(FInternalId, table) then
    try
      table.Renderer.AnimationCallback(pointer(AMessage.WParam));
    finally
      Tables.Unlock;
    end;
  end;

  inherited;
end;

procedure TfrmTable.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Tables.Remove(FInternalId);
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
  table: TTable;
begin
  // check if table is currently in focus
  fgwin := GetForegroundWindow;
  for table in Tables.Values do
    if table.Form.Handle = fgwin then
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
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.TableType = ttHandPlayback then
    begin
      SetTableStatus(table.HandHistoryPlayback.CurrentState, FALSE);
      tiHandPlayback.Enabled := TRUE;
    end
    else
      RefreshAll;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  set_raise_amount: Boolean;
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      DefocusControls;
      table.Renderer.MouseDown(Button, Shift, X, Y, set_raise_amount);

      if set_raise_amount then
        SetRaiseValue(RoundToNearestBB(Round(table.Renderer.TableStatus.MinimumRaise +
            (table.Renderer.TableStatus.MaximumRaise - table.Renderer.TableStatus.MinimumRaise) * table.Renderer.RaiseThumbPosition), game.BigBlind), TRUE, FALSE);

      table.Renderer.Render;
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  set_raise_amount: Boolean;
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      table.Renderer.MouseMove(Shift, X, Y, set_raise_amount);

      if set_raise_amount then
        SetRaiseValue(RoundToNearestBB(Round(table.Renderer.TableStatus.MinimumRaise +
            (table.Renderer.TableStatus.MaximumRaise - table.Renderer.TableStatus.MinimumRaise) * table.Renderer.RaiseThumbPosition), game.BigBlind), TRUE, FALSE);
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.Renderer.MouseUp(Button, Shift, X, Y);
    table.Renderer.Render;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.FormClick(Sender: TObject);
var
  seat_info: TSeatInfo;
  client_cursor_pos: TPoint;
  seat_index: Integer;
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      client_cursor_pos := ScreenToClient(Mouse.CursorPos);

      DefocusControls;

      if (table.TableType = ttLiveGame) and
         (game.State <> gsClosed) and
         (table.Renderer.Metrics.IsPointInSeat(game, client_cursor_pos.X, client_cursor_pos.Y, seat_index)) and
         (((not table.IsSitting) and
           (not table.Renderer.TableStatus.IsSeatTaken(seat_index))) or
          ((table.IsSitting) and
           (table.SeatIndex = seat_index) and
           (table.Renderer.TableStatus.GetSeatInfo(table.SeatIndex, seat_info)) and
           (seat_info.Status in [psOutOfPlay, psOutOfHand]))) then
        FormsContainer.Add(RunModalForm(TfrmTableSit, self, [@FInternalId, table.Renderer.TableStatus, @seat_index], ModalFormClose));
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
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
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if TryStrToFloat(seRaiseAmount.Text, val) then
    begin
      valuint := Round(val * 100);
      if valuint > table.Renderer.TableStatus.MaximumRaise then
        valuint := table.Renderer.TableStatus.MaximumRaise;
      SetRaiseValue(valuint, FALSE);
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.tiActiveFrameBlinkTimer(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.Renderer.TableStatus.CurrentSeat = -1 then
    begin
      tiActiveFrameBlink.Enabled := FALSE;
      Exit;
    end;

    if tiActiveFrameBlink.Tag = 0 then
      tiActiveFrameBlink.Tag := 1
    else
      tiActiveFrameBlink.Tag := 0;

    table.Renderer.Render;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.tiGameLockTimer(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    tiGameLock.Enabled := FALSE;
    table.Renderer.TableStatus.LockTimerEnabled := tiGameLock.Enabled;
    RefreshAll;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.tiHandPlaybackTimer(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    SetTableStatus(table.HandHistoryPlayback.NextState, TRUE);

    if table.Renderer.TableStatus.LockTimerEnabled then
      tiHandPlayback.Interval := tiGameLock.Interval
    else
      tiHandPlayback.Interval := 1000;

    if table.HandHistoryPlayback.CurrentStateIndex = table.HandHistoryPlayback.States.Count - 1 then
    begin
      tiHandPlayback.Enabled := FALSE;
      btPlayPause.Action := acHandPlaybackPlay;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.tiRenderTimer(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.Renderer.Render;
    UpdateHandStrength;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.tiSitOutNextBBTimer(Sender: TObject);
var
  seat_info: TSeatInfo;
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      if (table.Renderer.TableStatus.GetSeatInfo(table.SeatIndex, seat_info)) and
         (seat_info.Status <> psOutOfPlay) then
        ServerSocket.TableSitOutNextBB(game.MongoId, cbSitOutNextBB.Checked);

      tiSitOutNextBB.Enabled := FALSE;
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.tiSitOutNextHandTimer(Sender: TObject);
var
  seat_info: TSeatInfo;
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      if (table.Renderer.TableStatus.GetSeatInfo(table.SeatIndex, seat_info)) and
         (seat_info.Status <> psOutOfPlay) then
        ServerSocket.TableSitOutNextHand(game.MongoId, cbSitOutNextHand.Checked);

      tiSitOutNextHand.Enabled := FALSE;
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.UpdateHandHistoryLabel;
var
  hhis: THandHistoryItems;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.TableType = ttLiveGame) and
       (HandHistory.TryGetValue(table.GameId, hhis)) and
       (hhis.LastHandId > 0) then
    begin
      lbvHandHistory.Caption := Format('Previous Hand (#%d)', [hhis.LastHandId]);
      lbvHandHistory.Visible := TRUE;
    end
    else
      lbvHandHistory.Visible := FALSE
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.UpdateHandStrength;
var
  seat_info: TSeatInfo;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.IsSitting) and
       (table.Renderer.TableStatus.GetSeatInfo(table.SeatIndex, seat_info)) and
       (seat_info.Status in [psAllIn, psFolded, psInHand]) and
       (seat_info.CardCount > 0) and
       (seat_info.DealtCards = seat_info.CardCount) then
    begin
      if (table.Renderer.FlopAnimations.Count = 0) and
         (table.Renderer.TurnAnimations.Count = 0) and
         (table.Renderer.RiverAnimations.Count = 0) then
        lbvHandStrength.Caption := THandStrengthCalculator.GetHandStrength(seat_info.Cards.AsString,
              table.Renderer.TableStatus.FlopCards.AsString + table.Renderer.TableStatus.TurnCard.AsString + table.Renderer.TableStatus.RiverCard.AsString,
              table.Renderer.TableStatus.CurrentGame, TRUE)
    end
    else
      lbvHandStrength.Caption := '';
  finally
    Tables.Unlock;
  end;
end;

function TfrmTable.GetTableCaption: String;
var
  currentgame: String;
  rot_index: Integer;
  hhi: THandHistoryItem;
  table: TTable;
  club: TClubInfo;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(club, game) then
    try
      case table.TableType of
        ttLiveGame: begin
          if game.GameType = gtRotationNLHPLO then
          begin
            case table.Renderer.TableStatus.CurrentGame of
              gtHoldem: currentgame := 'NLH';
              gtOmaha: currentgame := 'PLO';
            end;
            rot_index := table.Renderer.TableStatus.RotationHand;
            if rot_index = 0 then
              rot_index := 1;
            result := Format('%s (%s/%s %s) (%d/%d %s) - %s', [game.Name, ChipsToStr(game.SmallBlind), ChipsToStr(game.BigBlind), game.AsString(TRUE), (rot_index - 1) mod game.Seats + 1, game.Seats, currentgame, club.Name])
          end
          else
            result := Format('%s (%s/%s %s) - %s', [game.Name, ChipsToStr(game.SmallBlind), ChipsToStr(game.BigBlind), game.AsString(TRUE), club.Name]);
        end;

        ttHandPlayback: if GetHandHistoryItem(hhi) then
          result := Format('Hand #%d: %s (%s/%s) - %s', [hhi.HandId, TGameInfo.GameTypeToStr(hhi.CurrentGame, hhi.ParentItems.Game.Limit, FALSE),
                     ChipsToStr(hhi.ParentItems.Game.SmallBlind), ChipsToStr(hhi.ParentItems.Game.BigBlind), hhi.StartTimeStr]);
      end;
    finally
      club.Free;
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.UpdateTableCaption;
var
  cap: String;
begin
  cap := GetTableCaption;
  if cap <> Caption then
    Caption := cap;
end;

function TfrmTable.GetHandHistoryItem(out AHandHistoryItem: THandHistoryItem): Boolean;
var
  hhis: THandHistoryItems;
  table: TTable;
begin
  result := FALSE;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.TableType <> ttHandPlayback) or
       (not HandHistory.TryGetValue(table.GameId, hhis)) or
       (not hhis.FindHand(table.HandId, AHandHistoryItem)) then
      Exit(FALSE);

    Exit(TRUE);
  finally
    Tables.Unlock;
  end;
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
var
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      case Ord(Key) of
        VK_RETURN: begin
          if edChat.Text <> '' then
          begin
            if Trim(edChat.Text) <> '' then
              ServerSocket.SendTableChatLine(game.MongoId, Trim(edChat.Text));
            edChat.Clear;
          end;
          Key := #0;
        end;
      end;
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.EnableGameLockTimer(const ASeconds: Single);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    tiGameLock.Enabled := FALSE;
    tiGameLock.Interval := Round(ASeconds * 1000);
    tiGameLock.Enabled := TRUE;
    table.Renderer.TableStatus.LockTimerEnabled := tiGameLock.Enabled;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acShowCardsExecute(Sender: TObject);
var
  seat: TSeatInfo;
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      ServerSocket.ShowCards(game.MongoId);
      acShowCards.Enabled := FALSE;
      if table.Renderer.TableStatus.GetSeatInfo(table.SeatIndex, seat) then
        seat.CardsVisible := TRUE;
      RefreshAll;
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acStandUpExecute(Sender: TObject);
var
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      if not ConfirmStandUp then
        Exit;

      ServerSocket.TableStandUp(game.MongoId);
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
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
var
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      table.Renderer.TableStatus.UpdateClosingTime(game);
      RefreshAll;
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.CSEUserChange(const AMethodId: Integer; const AObject: TObject);
begin
  RefreshAll;
end;

procedure TfrmTable.CSRChatEvent(const AMethodId: Integer; const AObject: TObject);
var
  chat_event: TPB_ChatEvent;
  chat_message: TPB_ChatMessage;
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      chat_event := AObject as TPB_ChatEvent;

      case chat_event.Event of
        ceUserMessage: begin
          chat_message := chat_event.Msg;
          if CompareBytes(chat_event.TableId, game.MongoId) then
            AddUserChatMessage(chat_message.Username, chat_message.Msg);
        end;
        ceServerMessage: ;
      end;
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
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
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      AFocusWindow := FALSE;
      raise_en := table.Renderer.TableStatus.ActionRaise;
      table.Renderer.TableStatus.ActionStandUp := FALSE;
      table.Renderer.TableStatus.ActionFold := FALSE;
      table.Renderer.TableStatus.ActionCall := FALSE;
      table.Renderer.TableStatus.ActionCheck := FALSE;
      table.Renderer.TableStatus.ActionRaise := FALSE;
      table.Renderer.TableStatus.ActionBet := FALSE;
      table.Renderer.TableStatus.ActionPlayNow := FALSE;
      table.Renderer.TableStatus.ActionSitOut := FALSE;
      table.Renderer.TableStatus.ActionFoldToAny := FALSE;
      table.Renderer.TableStatus.ActionSitOutNextBB := FALSE;
      table.Renderer.TableStatus.ActionShowCards := FALSE;

      seat_info := nil;
      if (table.TableType = ttLiveGame) and
         (table.Renderer.TableStatus.GetSeatInfo(table.SeatIndex, seat_info)) then
      begin
        table.Renderer.TableStatus.ActionStandUp := TRUE;

        if game.State <> gsClosed then
          case seat_info.Status of
            psOutOfPlay: begin
              table.Renderer.TableStatus.ActionPlayNow := TRUE;
              table.Renderer.TableStatus.ActionFoldToAny := FALSE;
              table.Renderer.TableStatus.ActionSitOut := FALSE;
              table.Renderer.TableStatus.ActionSitOutNextBB := FALSE;
            end;

            psOutOfHand: begin
              table.Renderer.TableStatus.ActionFoldToAny := FALSE;
              table.Renderer.TableStatus.ActionSitOut := TRUE;
              table.Renderer.TableStatus.ActionSitOutNextBB := TRUE;
            end;

            psInHand, psAllIn: begin
              table.Renderer.TableStatus.ActionSitOut := TRUE;
              table.Renderer.TableStatus.ActionSitOutNextBB := TRUE;
              if (seat_info.Status = psInHand) and
                 (table.Renderer.TableStatus.State in [tsPreFlop, tsFlop, tsTurn, tsRiver]) then
                table.Renderer.TableStatus.ActionFoldToAny := TRUE;

              if (table.Renderer.TableStatus.CurrentSeat = table.SeatIndex) and
                 (not table.Renderer.TableStatus.Locked) and
                 (not table.Renderer.TableStatus.LockTimerEnabled) then
                case table.Renderer.TableStatus.State of
                  tsIdle: begin
                    table.Renderer.TableStatus.ActionFoldToAny := FALSE;
                  end;

                  tsPreFlop, tsFlop, tsTurn, tsRiver: begin
                    table.Renderer.TableStatus.ActionFold := TRUE;
                    // check if our current bet is smaller than minimumbet (call/raise situation)
                    if table.Renderer.TableStatus.GetBet(seat_info.SeatIndex) < table.Renderer.TableStatus.MinimumBet then
                    begin
                      if seat_info.Chips <= table.Renderer.TableStatus.MinimumBet then
                        acCall.Caption := 'CALL (ALL-IN)'
                      else
                        acCall.Caption := Format('CALL (%s)', [ChipsToStr(table.Renderer.TableStatus.MinimumBet{ - table.Renderer.TableStatus.GetBet(seat_info.SeatIndex)})]);
                      table.Renderer.TableStatus.ActionCall := TRUE;

                      // if we can call, there is a possibility that we can raise too - we check if we can raise here
                      if (seat_info.Chips > table.Renderer.TableStatus.MinimumBet) and
                         (table.Renderer.TableStatus.MinimumBet < table.Renderer.TableStatus.MinimumRaise) then
                        table.Renderer.TableStatus.ActionRaise := TRUE;
                    end
                    else // if our current bet isnt smaller than minimum bet, that means its check/raise situation
                    begin
                      table.Renderer.TableStatus.ActionCheck := TRUE;
                      table.Renderer.TableStatus.ActionBet := TRUE;
                    end;

                    AFocusWindow := TRUE;
                  end;

                  tsWinning, tsWinning2: begin
                    table.Renderer.TableStatus.ActionFoldToAny := FALSE;
                  end;
                end
              else
                FWindowFocused := FALSE;
            end;

            psFolded: begin
              table.Renderer.TableStatus.ActionFoldToAny := FALSE;
              table.Renderer.TableStatus.ActionSitOut := TRUE;
              table.Renderer.TableStatus.ActionSitOutNextBB := TRUE;
            end;
          end;
      end;

      // if raise slider was not enabled, set it to minimum value
      if not raise_en then
        FRaiseValue := table.Renderer.TableStatus.MinimumRaise;
      SetRaiseValue(FRaiseValue, TRUE, TRUE, FALSE);

      // check if SHOW CARDS button is enabled
      table.Renderer.TableStatus.ActionShowCards := (table.Renderer.TableStatus.State in [tsWinning, tsWinning2]) and
                                      (Assigned(seat_info)) and
                                      (seat_info.CanShow) and
                                      (not seat_info.CardsVisible) and
                                      (seat_info.Status in [psFolded, psAllIn, psInHand]);

      // enable actions
      acStandUp.Enabled := table.Renderer.TableStatus.ActionStandUp;
      acFold.Enabled := table.Renderer.TableStatus.ActionFold;
      acCall.Enabled := table.Renderer.TableStatus.ActionCall;
      acCheck.Enabled := table.Renderer.TableStatus.ActionCheck;
      acRaise.Enabled := table.Renderer.TableStatus.ActionRaise;
      acRaise.Enabled := (table.Renderer.TableStatus.ActionBet) or (table.Renderer.TableStatus.ActionRaise);
      acRaiseMin.Enabled := acRaise.Enabled;
      acRaise3BB.Enabled := acRaise.Enabled;
      acRaisePot.Enabled := acRaise.Enabled;
      acRaiseMax.Enabled := acRaise.Enabled;
      acPlayNow.Enabled := table.Renderer.TableStatus.ActionPlayNow;
      acShowCards.Enabled := table.Renderer.TableStatus.ActionShowCards;
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.ConfigureGUI;
var
  hround: Integer;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if WindowState <> wsMaximized then
    begin
      hround := Round(Width / FORM_ASPECT_RATIO);
      if Height <> hround then
        Height := hround;
    end;

    rvChat.BoundsRect := table.Renderer.Metrics.ChatBoxBounds;

    case table.TableType of
      ttLiveGame: begin
        edChat.BoundsRect := table.Renderer.Metrics.ChatEditBounds;
        seRaiseAmount.BoundsRect := table.Renderer.Metrics.RaiseAmountBoxBounds;
        seRaiseAmount.Style.Font.Size := table.Renderer.Metrics.RaiseAmountBoxFontSize;

        cbSitOutNextBB.Top := rvChat.Top + rvChat.Height - cbSitOutNextBB.Height;
        cbSitOutNextHand.Top := cbSitOutNextBB.Top - cbSitOutNextHand.Height;
        cbFoldToAnyBet.Top := cbSitOutNextHand.Top - cbFoldToAnyBet.Height;

        cbFoldToAnyBet.Left := table.Renderer.Metrics.CheckboxesLeft;
        cbSitOutNextHand.Left := table.Renderer.Metrics.CheckboxesLeft;
        cbSitOutNextBB.Left := table.Renderer.Metrics.CheckboxesLeft;

        if table.Renderer.TableStatus.ActionSitOut then
        begin
          cbSitOutNextHand.Visible := TRUE;
          cbSitOutNextBB.Visible := TRUE;
          cbFoldToAnyBet.Visible := TRUE;

          cbSitOutNextBB.Enabled := table.Renderer.TableStatus.ActionSitOutNextBB;
          cbFoldToAnyBet.Enabled := table.Renderer.TableStatus.ActionFoldToAny;

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
          if table.Renderer.TableStatus.CurrentLimit = glPotLimit then
          begin
            table.Renderer.GetDXButton(FDXBRaisePresets[0]).Action := nil;
            table.Renderer.GetDXButton(FDXBRaisePresets[1]).Action := acRaiseMin;
            table.Renderer.GetDXButton(FDXBRaisePresets[2]).Action := acRaise3BB;
            table.Renderer.GetDXButton(FDXBRaisePresets[3]).Action := acRaisePot;
          end
          else
          begin
            table.Renderer.GetDXButton(FDXBRaisePresets[0]).Action := acRaiseMin;
            table.Renderer.GetDXButton(FDXBRaisePresets[1]).Action := acRaise3BB;
            table.Renderer.GetDXButton(FDXBRaisePresets[2]).Action := acRaisePot;
            table.Renderer.GetDXButton(FDXBRaisePresets[3]).Action := acRaiseMax;
          end;

          SetRaiseValue(FRaiseValue, TRUE, TRUE, FALSE);
        end;

        // enable seat blink timer, if it's not enabled already
        if (table.Renderer.TableStatus.CurrentSeat <> -1) and
           (not tiActiveFrameBlink.Enabled) and
           (not table.Renderer.TableStatus.Locked) and
           (not table.Renderer.TableStatus.LockTimerEnabled) then
        begin
          tiActiveFrameBlink.Tag := 1;
          tiActiveFrameBlink.Enabled := TRUE;
        end;

        lbvHandStrength.Top := Round(table.Renderer.GetDXButton(FDXBRaisePresets[High(FDXBRaisePresets)]).Bounds^[0].y - lbvHandStrength.Height - 5);
        UpdateHandHistoryLabel;
      end;

      ttHandPlayback: begin
        rvChat.Color := $00262626;
        pbHandPlaybackProgress.BoundsRect := table.Renderer.Metrics.HandPlaybackProgress;
        btPlayPause.BoundsRect := table.Renderer.Metrics.HandPlaybackPlay;
        btStepForward.BoundsRect := table.Renderer.Metrics.HandPlaybackForward;
        btStepBackwards.BoundsRect := table.Renderer.Metrics.HandPlaybackBack;
      end;
    end;

    UpdateHandStrength;
    UpdateTableCaption;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.tiSeatClearCaptionTimer(Sender: TObject);
var
  seat: TSeatInfo;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.Renderer.TableStatus.GetSeatInfo(tiSeatCaptionClear.Tag, seat)) and
       (seat.LowerCaption <> '') then
    begin
      seat.LowerCaption := '';
      table.Renderer.Render;
    end;

    tiSeatCaptionClear.Enabled := FALSE;
  finally
    Tables.Unlock;
  end;
end;

function TfrmTable.ConfirmLeaveTable: Boolean;
var
  table: TTable;
begin
  result := TRUE;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.TableType = ttLiveGame) and
       (table.IsSitting) then
      result := MessageDlg('Are you sure you want to leave the table? This will automatically fold your current hand and get you up from the seat.', mtWarning, mbYesNo, 0) = mrYes;
  finally
    Tables.Unlock;
  end;
end;

function TfrmTable.ConfirmStandUp: Boolean;
var
  seat: TSeatInfo;
  table: TTable;
begin
  result := TRUE;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.TableType = ttLiveGame) and
       (table.IsSitting) and
       (table.Renderer.TableStatus.GetSeatInfo(table.SeatIndex, seat)) and
       (seat.Status in [psInHand, psFolded, psAllIn]) then
      result := MessageDlg('Are you sure you want to stand up? This will automatically fold your current hand and any chips that you commited to current pot.', mtWarning, mbYesNo, 0) = mrYes;
  finally
    Tables.Unlock;
  end;
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
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      pbtablestatus := AObject as TPB_TableStatus;
      if not CompareBytes(pbtablestatus.TableMongoId, game.MongoId) then
        Exit;

      // update local objects with new table status
      table.Renderer.TableStatus.Assign(pbtablestatus);

      // ActionManager is initially in suspended state, to make sure no actions can be executed while table contains no data
      // this block is executed when first tablestatus is received, and it also enables ActionManager
      if ActionManager.State = asSuspended then
      begin
        ActionManager.State := asNormal;
        for C1 := 0 to table.Renderer.TableStatus.Seats.Count - 1 do
          table.Renderer.TableStatus.Seats[C1].FillDealtCards;

        if table.Renderer.TableStatus.State in [tsFlop, tsTurn, tsRiver, tsWinning, tsWinning2] then
          table.Renderer.FlopAnimated := TRUE;
        if table.Renderer.TableStatus.State in [tsTurn, tsRiver, tsWinning, tsWinning2] then
          table.Renderer.TurnAnimated := TRUE;
        if table.Renderer.TableStatus.State in [tsRiver, tsWinning, tsWinning2] then
          table.Renderer.RiverAnimated := TRUE;
      end;

      // iterate through table status seats and find our seat index
      seat_index := -1;
      for C1 := 0 to pbtablestatus.Seats.Count - 1 do
        if CompareBytes(pbtablestatus.Seats[C1].PlayerMongoId, dmMain.SelfInfo.Id) then
        begin
          seat_index := pbtablestatus.Seats[C1].Seat;
          Break;
        end;
      table.SeatIndex := seat_index;

      // reset animation delays
      table.Renderer.WinningFlopAniDelay := 0;
      table.Renderer.WinningTurnAniDelay := 0;
      table.Renderer.WinningRiverAniDelay := 0;
      table.Renderer.WinningAniDelay := 0;

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
            teFlop: table.Renderer.WinningFlopAniDelay := 0.2;
            teTurn: table.Renderer.WinningTurnAniDelay := table.Renderer.WinningFlopAniDelay + 1;
            teRiver: table.Renderer.WinningRiverAniDelay := table.Renderer.WinningFlopAniDelay + table.Renderer.WinningTurnAniDelay + 1;
            teWinning: table.Renderer.WinningAniDelay := table.Renderer.WinningFlopAniDelay + table.Renderer.WinningTurnAniDelay + table.Renderer.WinningRiverAniDelay + 0.2;
          end;

      // process table events
      for C1 := 0 to pbtablestatus.Events.Count - 1 do
        ProcessTableEvent(pbtablestatus.Events[C1]);

      // get user infos that we dont have
      SetLength(query_users, 0);
      for seat in table.Renderer.TableStatus.Seats do
        if not Players.TryGetValue(seat.PlayerMongoId, player) then
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
      tmp := GetEnumName(TypeInfo(TTableState), Integer(table.Renderer.TableStatus.State));
      if pbtablestatus.Locked then
        tmp := tmp + ', LOCKED';
      seatdbg := nil;
      playerdbg := nil;
      tb := 0;
      csdbg := IntToStr(table.Renderer.TableStatus.CurrentSeat);
      if table.Renderer.TableStatus.GetSeatInfo(table.Renderer.TableStatus.CurrentSeat, seatdbg) then
      begin
        if Players.TryGetValue(seatdbg.PlayerMongoId, playerdbg) then
          csdbg := csdbg + ' - ' + playerdbg.Nick;
        tb := seatdbg.Timebank;
      end;

      tstatusdbg := Format('[#%d] %s, D: %d, E: %d | #%s, %.2fs/%.2fs',
        [pbtablestatus.Seq, tmp, table.Renderer.TableStatus.Dealer, pbtablestatus.Events.Count, csdbg, table.Renderer.TableStatus.CurrentPlaytime / 1000, tb / 100]);

      events := '';
      for C1 := 0 to pbtablestatus.Events.Count - 1 do
      begin
        pbevent := pbtablestatus.Events[C1];
        if events <> '' then
          events := events + #10;

        seatdbg := nil;
        playerdbg := nil;
        if table.Renderer.TableStatus.GetSeatInfo(pbevent.Seat, seatdbg) then
          Players.TryGetValue(seatdbg.PlayerMongoId, playerdbg);

        case pbevent.Event of
          teFold: if Assigned(seatdbg) then
            events := events + Format('FOLD [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(table.Renderer.TableStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)])
          else
            events := events + Format('FOLD [#%d]', [pbevent.Seat]);
          teSit: events := events + Format('SIT [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(table.Renderer.TableStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
          teStandUp: events := events + Format('STAND UP [#%d]', [pbevent.Seat]);
          teWinning: events := events + 'WINNING';
          teDealing: events := events + 'DEALING';
          teCheck: events := events + Format('CHECK [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(table.Renderer.TableStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
          teCall: events := events + Format('CALL [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(table.Renderer.TableStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
          teRaise: events := events + Format('RAISE [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(table.Renderer.TableStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
          teAllIn: events := events + Format('ALL-IN [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(table.Renderer.TableStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
          teFlop: events := events + Format('FLOP [%s]', [table.Renderer.TableStatus.FlopCards.AsString]);
          teTurn: events := events + Format('TURN [%s]', [table.Renderer.TableStatus.TurnCard.AsString]);
          teRiver: events := events + Format('RIVER [%s]', [table.Renderer.TableStatus.RiverCard.AsString]);
          tePostRiver: events := events + 'POST RIVER';
          tePreWin: events := events + 'PRE WIN';
          teExistingCards: events := events + Format('EXISTING CARDS [%s]', [TCards.BytesToString(pbevent.Cards)]);
          teDisconnect: events := events + Format('DISCONNECTED [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(table.Renderer.TableStatus.GetBet(seatdbg.SeatIndex)), ChipsToStr(seatdbg.Chips)]);
        else
          events := events + Format('UNHANDLED EVENT RECEIVED: %s', [GetEnumName(TypeInfo(TTableEventType), Integer(pbevent.Event))]);
        end;
      end;

      DebugLn(FDebugId, tstatusdbg, ditApplication, events);
      {$ENDIF}

      RefreshAll;
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
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
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    seat_caption := '';
    case ATableEvent.Event of
      teExistingCards: begin
        if Length(ATableEvent.Cards) >= 3 then
        begin
          flop := Copy(ATableEvent.Cards, 0, 3);
          table.Renderer.TableStatus.FlopCards.Assign(flop);
        end;
        if Length(ATableEvent.Cards) >= 4 then
          table.Renderer.TableStatus.TurnCard.Assign(ATableEvent.Cards[3]);
        if Length(ATableEvent.Cards) >= 5 then
          table.Renderer.TableStatus.RiverCard.Assign(ATableEvent.Cards[4]);
      end;

      teFold: begin
        tiActiveFrameBlink.Enabled := FALSE;
        seat_caption := 'FOLD';
      end;

      teSit: begin
      end;

      teStandUp: begin
        if table.Renderer.PotWinAnimations.Count = 0 then
          table.Renderer.AnimateBets(Handle, table.Renderer.TableStatus.PreviousBets, ATableEvent.Seat);
      end;

      tePostRiver: begin
        table.Renderer.TableStatus.PreviousBets.Clear;
        table.Renderer.TableStatus.PreviousBets.AddRange(ATableEvent.Bets);
      end;

      teWinning: begin
        EnableGameLockTimer(2 + ATableEvent.Pots.Count * 0.5);

        table.Renderer.TableStatus.Pots.Assign(ATableEvent.Pots);

        if table.Renderer.AnimateBets(Handle, table.Renderer.TableStatus.PreviousBets) then
          TablePlaySound(Sounds.SOUND_MOVE_CHIPS);

        table.Renderer.AnimateWinnerPots(Handle, ATableEvent.Pots);
      end;

      teDealing: begin
        table.Renderer.ClearAnimations;
        table.Renderer.ChipStackMaker.Clear;

        table.Renderer.TableStatus.NewHandCleanup;

        table.Renderer.AnimateBlinds(Handle);
        table.Renderer.AnimateDealingCards(Handle);

        EnableGameLockTimer(0.1 + Settings.Hardcoded.ANIMATION_METRICS.DEALING_INITIAL_DELAY +
            table.Renderer.DealAnimations.Count * Settings.Hardcoded.ANIMATION_METRICS.DEALING_CARD_DELAY);
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
        table.Renderer.TableStatus.FlopCards.Assign(ATableEvent.Cards);

        tiActiveFrameBlink.Enabled := FALSE;
        EnableGameLockTimer(1.5 + table.Renderer.WinningFlopAniDelay);
        if table.Renderer.AnimateBets(Handle, ATableEvent.Bets) then
          TablePlaySound(Sounds.SOUND_MOVE_CHIPS);
      end;

      teTurn: begin
        table.Renderer.TableStatus.TurnCard.Assign(ATableEvent.Cards);

        tiActiveFrameBlink.Enabled := FALSE;
        EnableGameLockTimer(1.5 + table.Renderer.WinningTurnAniDelay);
        if table.Renderer.AnimateBets(Handle, ATableEvent.Bets) then
          TablePlaySound(Sounds.SOUND_MOVE_CHIPS);
      end;

      teRiver: begin
        table.Renderer.TableStatus.RiverCard.Assign(ATableEvent.Cards);

        tiActiveFrameBlink.Enabled := FALSE;
        EnableGameLockTimer(1.5 + table.Renderer.WinningRiverAniDelay);
        if table.Renderer.AnimateBets(Handle, ATableEvent.Bets) then
          TablePlaySound(Sounds.SOUND_MOVE_CHIPS);
      end;

      teDisconnect: begin
  {
        if table.Renderer.TableStatus.GetSeatInfo(ATableEvent.Seat, seat) then
          seat_caption := 'DISCONNECTED';}
      end;
    end;

    if seat_caption <> '' then
    begin
      table.Renderer.TableStatus.Seats.ClearCaptions;
      if table.Renderer.TableStatus.GetSeatInfo(ATableEvent.Seat, seat) then
      begin
        seat.LowerCaption := seat_caption;
        if tiSeatCaptionClear.Enabled then
          tiSeatCaptionClear.OnTimer(tiSeatCaptionClear);
        tiSeatCaptionClear.Enabled := FALSE;
        tiSeatCaptionClear.Tag := seat.SeatIndex;
        tiSeatCaptionClear.Enabled := TRUE;
      end;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acCallExecute(Sender: TObject);
var
  seat_info: TSeatInfo;
  seat_bet: UINT32;
  call_amount: Integer;
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      Assert(table.Renderer.TableStatus.GetSeatInfo(table.SeatIndex, seat_info));
      seat_bet := table.Renderer.TableStatus.GetBet(seat_info.SeatIndex);
      if seat_bet + seat_info.Chips < table.Renderer.TableStatus.MinimumBet then
        call_amount := seat_bet + seat_info.Chips
      else
        call_amount := table.Renderer.TableStatus.MinimumBet;

      ServerSocket.PutChips(game.MongoId, call_amount, table.Renderer.TableStatus.State);
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acCheckExecute(Sender: TObject);
var
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      ServerSocket.PutChips(game.MongoId, table.Renderer.TableStatus.GetBet(table.SeatIndex), table.Renderer.TableStatus.State);
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acFoldExecute(Sender: TObject);
var
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      if (acCheck.Enabled) and
         (Settings.FoldChecks) then
        acCheck.Execute
      else
        ServerSocket.Fold(game.MongoId);
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acPlayNowExecute(Sender: TObject);
var
  seat: TSeatInfo;
  sindex: Integer;
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      if (table.IsSitting) and
         (table.Renderer.TableStatus.GetSeatInfo(table.SeatIndex, seat)) and
         (seat.Chips = 0) then
      begin
        sindex := seat.SeatIndex;
        FormsContainer.Add(RunModalForm(TfrmTableSit, self, [@FInternalId, table.Renderer.TableStatus, @sindex], ModalFormClose));
        Exit;
      end;

      ServerSocket.TablePlayNow(game.MongoId);
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acRaise3BBExecute(Sender: TObject);
var
  val: UINT32;
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      val := table.Renderer.TableStatus.MinimumBet;
      if val = 0 then
        val := game.BigBlind;

      SetRaiseValue(val * 3);
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acRaiseMaxExecute(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    SetRaiseValue(table.Renderer.TableStatus.MaximumRaise);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acRaiseMinExecute(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    SetRaiseValue(table.Renderer.TableStatus.MinimumRaise);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acRaiseExecute(Sender: TObject);
var
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      ServerSocket.PutChips(game.MongoId, FRaiseValue, table.Renderer.TableStatus.State);
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acRaisePotExecute(Sender: TObject);
var
  C1: Integer;
  raise_value: UINT32;
  seat_bet: UINT32;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    seat_bet := table.Renderer.TableStatus.GetBet(table.SeatIndex);

    raise_value := table.Renderer.TableStatus.MinimumBet - seat_bet;
    for C1 := 0 to table.Renderer.TableStatus.Pots.Count - 1 do
      Inc(raise_value, table.Renderer.TableStatus.Pots[C1].ValueWithoutRake);
    for C1 := 0 to table.Renderer.TableStatus.Bets.Count - 1 do
      Inc(raise_value, table.Renderer.TableStatus.Bets[C1]);
    raise_value := raise_value + table.Renderer.TableStatus.MinimumBet;

    SetRaiseValue(raise_value);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.SetTableStatus(const ATableStatus: TPB_TableStatus; const AClearAnimations: Boolean);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if AClearAnimations then
      table.Renderer.ClearAnimations;

    CSRETableStatus(0, ATableStatus);
    if table.TableType = ttHandPlayback then
      pbHandPlaybackProgress.Position := table.HandHistoryPlayback.CurrentStateIndex;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.SetRaiseActionCaption;
var
  seat_info: TSeatInfo;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.Renderer.TableStatus.GetSeatInfo(table.SeatIndex, seat_info) then
    begin
      if table.Renderer.TableStatus.ActionRaise then
      begin
        if FRaiseValue = seat_info.Chips + table.Renderer.TableStatus.GetBet(table.SeatIndex) then
           acRaise.Caption := 'RAISE (ALL-IN)'
        else
           acRaise.Caption := Format('RAISE (%s)', [ChipsToStr(FRaiseValue)])
      end
      else
        if table.Renderer.TableStatus.ActionBet then
        begin
          if FRaiseValue = seat_info.Chips + table.Renderer.TableStatus.GetBet(table.SeatIndex) then
            acRaise.Caption := 'BET (ALL-IN)'
          else
            acRaise.Caption := Format('BET (%s)', [ChipsToStr(FRaiseValue)]);
        end
        else
          acRaise.Caption := '';
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.SetRaiseValue(const AValue: UINT32; const ASetSpinEditValue: Boolean = TRUE; const AAbsoluteJump: Boolean = TRUE; const AConfigureGUI: Boolean = TRUE);
var
  val: UINT32;
  oldval: UINT32;
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      oldval := FRaiseValue;

      val := AValue;
      if not AAbsoluteJump then
      begin
        if val > oldval then
          val := oldval + game.BigBlind
        else
          if val < oldval then
            val := oldval - game.BigBlind;
      end;

      if val > table.Renderer.TableStatus.MaximumRaise then
        val := table.Renderer.TableStatus.MaximumRaise
      else
        if val < table.Renderer.TableStatus.MinimumRaise then
          val := table.Renderer.TableStatus.MinimumRaise;

      FRaiseValue := val;

      if table.Renderer.TableStatus.MaximumRaise = table.Renderer.TableStatus.MinimumRaise then
        table.Renderer.RaiseThumbPosition := 1
      else
        table.Renderer.RaiseThumbPosition := (FRaiseValue - table.Renderer.TableStatus.MinimumRaise) /
                                              (table.Renderer.TableStatus.MaximumRaise - table.Renderer.TableStatus.MinimumRaise);

      if ASetSpinEditValue then
        seRaiseAmount.Value := val / 100;

      SetRaiseActionCaption;

      if FRaiseValue <> oldval then
      begin
        table.Renderer.Render;
        if AConfigureGUI then
          ConfigureGUI;
      end;
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.TablePlaySound(const ASound: String);
begin
  if (GetForegroundWindow = Handle) and
     (Settings.Sounds) then
    Sounds.Play(Handle, ASound);
end;

procedure TfrmTable.RefreshAll;
var
  focus_window: Boolean;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    ConfigureActions(focus_window);
    if focus_window then
      FocusWindow;

    ConfigureGUI;
    table.Renderer.Render;

    if (table.Renderer.TableStatus.ActionFoldToAny) and
       (cbFoldToAnyBet.Checked) then
      if acCheck.Enabled then
        acCheck.Execute
      else
        acFold.Execute;
  finally
    Tables.Unlock;
  end;
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
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.Renderer.TableStatus.CurrentSeat = table.SeatIndex then
      TablePlaySound(Sounds.SOUND_TIMEBANK);
  finally
    Tables.Unlock;
  end;
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
  table: TTable;
  game: TGameInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      if not HandHistory.TryGetValue(table.GameId, hhis) then
        handid := 0
      else
        handid := hhis.LastHandId;

      if FormsContainer.Find(TfrmHandHistory, form) then
      begin
        (form as TfrmHandHistory).SetSelectedHandId(game.MongoId, handid);
        form.SetFocus;
      end
      else
        FormsContainer.RunForm(TfrmHandHistory, frmChipUpMain, [game, @handid], FALSE)
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acHandPlaybackPauseExecute(Sender: TObject);
begin
  tiHandPlayback.Enabled := FALSE;
  btPlayPause.Action := acHandPlaybackPlay;
end;

procedure TfrmTable.acHandPlaybackPlayExecute(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    tiHandPlayback.Enabled := TRUE;
    if table.HandHistoryPlayback.CurrentStateIndex = table.HandHistoryPlayback.States.Count - 1 then
    begin
      table.HandHistoryPlayback.CurrentStateIndex := 0;
      SetTableStatus(table.HandHistoryPlayback.CurrentState, TRUE);
    end;
    btPlayPause.Action := acHandPlaybackPause;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acHandPlaybackStepBackwardsExecute(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    acHandPlaybackPause.Execute;
    if table.HandHistoryPlayback.CurrentStateIndex > 0 then
      SetTableStatus(table.HandHistoryPlayback.PrevState, TRUE);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acHandPlaybackStepForwardExecute(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    acHandPlaybackPause.Execute;
    if table.HandHistoryPlayback.CurrentStateIndex < table.HandHistoryPlayback.States.Count - 1 then
      SetTableStatus(table.HandHistoryPlayback.NextState, TRUE);
  finally
    Tables.Unlock;
  end;
end;

end.

