unit Poker.Forms.Table;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, cxContainer, cxEdit, Poker.Tables.Status, Poker.DirectX.Animation, Vectors2,
  Vcl.ActnList, cxLabel, Poker.Tables.Table, cxTextEdit, Vcl.ActnMan, cxSpinEdit, cxCheckBox, Poker.Protobufs.Objects.TableStatus,
  Vectors2px, Poker.Protobufs.Objects.TableEvent, System.Types, RVStyle, RVScroll, RichView, AsphyreImages, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore, ChipUpPokerDarkSkin, Vcl.Menus, Vcl.ImgList, Vcl.PlatformDefaultStyleActnCtrls,
  cxProgressBar, Vcl.StdCtrls, cxButtons, cxMaskEdit;

type
  TfrmTable = class(TForm)
    ActionManager: TActionManager;
    acStandUp: TAction;
    acFold: TAction;
    acCall: TAction;
    acCheck: TAction;
    acRaise: TAction;
    acPlayNow: TAction;
    tiSitOutNextHand: TTimer;
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
    procedure acPlayNowExecute(Sender: TObject);
    procedure cbSitOutNextHandPropertiesChange(Sender: TObject);
    procedure tiSitOutNextHandTimer(Sender: TObject);
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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    const
      FORM_ASPECT_RATIO = 1.35;

    var
      FInternalId: Integer;
      FCallbacksId: Integer;
      FRaiseValue: UINT32;
      FWindowFocused: Boolean;
      FGameId: TBytes;
      FTableType: TTableType;

      FDXBFold: Integer;
      FDXBShowCards: Integer;
      FDXBCheck: Integer;
      FDXBCall: Integer;
      FDXBRaise: Integer;
      FDXBRaisePresets: array[0..3] of Integer;
      {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}

    procedure SetRaiseActionCaption;
    procedure SetRaiseValue(const AValue: UINT32; const ASetSpinEditValue: Boolean = TRUE; const AAbsoluteJump: Boolean = TRUE; const AConfigureGUI: Boolean = TRUE);

    procedure AddUserChatMessage(const AUser, AMessage: String);
    procedure AddDealerChatMessage(const AMessage: String);
    procedure ModalFormClose(Sender: TObject);
    procedure CheckChatScrollbackLimit;
    procedure RendererDealerChatMessage(const AMessage: String);
    procedure RendererSoundPlay(const ASound: String);
    procedure RendererTimebankStarted(Sender: TObject);
    procedure ConfigureActions(out AFocusWindow: Boolean);
    procedure AddChatMessage(const AUser: String; const AUserStyle, AUserParagraph: Integer; const AMessage: String; const AMessageStyle, AMessageParagraph: Integer);

    function GetTableCaption: String;
    procedure UpdateTableCaption;
    procedure UpdateHandHistoryLabel;
    procedure UpdateHandStrength;
    procedure FocusWindow;

    function ConfirmLeaveTable: Boolean;
    function ConfirmStandUp: Boolean;

    procedure CSRChatEvent(const AMethodId: Integer; const AObject: TObject);
    procedure CSRETableStatus(const AMethodId: Integer; const AObject: TObject);
    procedure CSEUserChange(const AMethodId: Integer; const AObject: TObject);
    procedure CSEGameChange(const AMethodId: Integer; const AObject: TObject);
    procedure CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
    procedure CSRHandHistoryMsg(const AMethodId: Integer; const AObject: TObject);

    procedure ConfigureGUI;
    procedure DefocusControls;
    procedure RefreshAll;
    procedure TableStatusUpdate;

  protected
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure WMSizing(var AMessage: TMessage); message WM_SIZING;
    procedure WndProc(var AMessage: TMessage); override;
  public
    constructor Create(const AInternalId: Integer); reintroduce;
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, System.TypInfo, {$ENDIF}
  Poker.Server.MessageContainer, Poker.Server.Settings, Poker.DirectX.Timer, Poker.Server.MessageCallbacks,
  Poker.Protobufs.Enum.ServerCodes, Poker.Protobufs.Objects.ChatEvent, Poker.Protobufs.Objects.ChatMessage, Poker.Protobufs.Objects.SeatInfo,
  Poker.Tables.Resources, Poker.WindowMessages, Poker.DirectX.Core, Poker.Common.FormsContainer, Poker.Server.Socket.Commands,
  Poker.Common.Misc, Poker.Settings, Poker.Forms.TableSit, Poker.DataModule, Poker.Players.PlayerList, Poker.Protobufs.Objects.Game,
  Poker.Games.Game, Poker.Sounds, Poker.Protobufs.Objects.WinnerData, Poker.HandStrengthCalculator, Poker.Forms.HandHistory, Poker.Forms.Main,
  Poker.HandHistory.Core, Poker.Pots.Pot, Poker.Seats.Seat, Poker.Cards, Poker.Players.Player, Poker.Tables.TableList, Poker.Clubs.Club,
  Poker.HandHistory.Items;


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
  game: TGameInfo;
begin
  {$IFDEF DEBUG} FDebugId := RegisterDebugObject(Format('frmTable: %s', [GetTableCaption])); {$ENDIF}

  ActionManager.State := asSuspended;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    FTableType := table.TableType;
    if table.GetObjectCopy(game) then
    try
      FGameId := game.MongoId;
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;

  FCallbacksId := -1;
  case FTableType of
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
      if Tables.GetAndLockTable(FInternalId, table) then
      try
        pbHandPlaybackProgress.Properties.Max := table.HandHistoryPlayback.States.Count - 1;
      finally
        Tables.Unlock;
      end;
      pbHandPlaybackProgress.Visible := TRUE;
      btPlayPause.Visible := TRUE;
      btStepForward.Visible := TRUE;
      btStepBackwards.Visible := TRUE;
    end;
  end;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
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
begin
  // prevent ALT key from switching between forms
  if (AMessage.Msg = WM_SYSCOMMAND) and
     (AMessage.WParam = SC_KEYMENU) then
    Exit;

  // this message is broadcasted to render handle when TTable updates TableStatus object
  if AMessage.Msg = WM_TABLESTATUS_REFRESH then
    TableStatusUpdate;

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
  Tables.Lock;
  try
    for table in Tables.Values do
      if table.Form.Handle = fgwin then
        Exit;
  finally
    Tables.Unlock;
  end;

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

    if Tables.GetAndLockTable(FInternalId, table) then
    try
      table.PlaySound(Sounds.SOUND_TIMEBAR);
    finally
      Tables.Unlock;
    end;
  end;
end;

procedure TfrmTable.FormActivate(Sender: TObject);
begin
  DefocusControls;
end;

procedure TfrmTable.FormShow(Sender: TObject);
begin
  if FTableType = ttHandPlayback then
    acHandPlaybackPlay.Execute;

  RefreshAll;
end;

procedure TfrmTable.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  set_raise_amount: Boolean;
  table: TTable;
  game: TGameInfo;
begin
  DefocusControls;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.Renderer.MouseDown(Button, Shift, X, Y, set_raise_amount);

    if (set_raise_amount) and
       (table.GetObjectCopy(game)) then
    try
      SetRaiseValue(RoundToNearestBB(Round(table.Status.MinimumRaise +
          (table.Status.MaximumRaise - table.Status.MinimumRaise) * table.Renderer.RaiseThumbPosition), game.BigBlind), TRUE, FALSE);
    finally
      game.Free;
    end;

    table.Renderer.Render;
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
    table.Renderer.MouseMove(Shift, X, Y, set_raise_amount);

    if (set_raise_amount) and
       (table.GetObjectCopy(game)) then
    try
      SetRaiseValue(RoundToNearestBB(Round(table.Status.MinimumRaise +
          (table.Status.MaximumRaise - table.Status.MinimumRaise) * table.Renderer.RaiseThumbPosition), game.BigBlind), TRUE, FALSE);
    finally
      game.Free;
    end;

    table.Renderer.Render;
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
  client_cursor_pos := ScreenToClient(Mouse.CursorPos);
  DefocusControls;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      if (table.TableType = ttLiveGame) and
         (game.State <> gsClosed) and
         (table.Renderer.Metrics.IsPointInSeat(game, client_cursor_pos.X, client_cursor_pos.Y, seat_index)) and
         (((not table.Status.IsSitting) and
           (not table.Status.IsSeatTaken(seat_index))) or
          ((table.Status.IsSitting) and
           (table.Status.SelfSeatIndex = seat_index) and
           (table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat_info)) and
           (seat_info.Status in [psOutOfPlay, psOutOfHand]))) then
        FormsContainer.Add(RunModalForm(TfrmTableSit, self, [@FInternalId, table.Status, @seat_index], ModalFormClose));
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
  if TryStrToFloat(seRaiseAmount.Text, val) then
  begin
    valuint := Round(val * 100);
    if Tables.GetAndLockTable(FInternalId, table) then
    try
      if valuint > table.Status.MaximumRaise then
        valuint := table.Status.MaximumRaise;
    finally
      Tables.Unlock;
    end;
    SetRaiseValue(valuint, FALSE);
  end;
end;

procedure TfrmTable.tiSitOutNextBBTimer(Sender: TObject);
var
  seat_info: TSeatInfo;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat_info)) and
       (seat_info.Status <> psOutOfPlay) then
      ServerSocket.TableSitOutNextBB(FGameId, cbSitOutNextBB.Checked);
  finally
    Tables.Unlock;
  end;
  tiSitOutNextBB.Enabled := FALSE;
end;

procedure TfrmTable.tiSitOutNextHandTimer(Sender: TObject);
var
  seat_info: TSeatInfo;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat_info)) and
       (seat_info.Status <> psOutOfPlay) then
      ServerSocket.TableSitOutNextHand(FGameId, cbSitOutNextHand.Checked);
  finally
    Tables.Unlock;
  end;
  tiSitOutNextHand.Enabled := FALSE;
end;

procedure TfrmTable.UpdateHandHistoryLabel;
var
  hhis: THandHistoryItems;
begin
  if (FTableType = ttLiveGame) and
     (HandHistory.TryGetValue(FGameId, hhis)) and
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
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.Status.IsSitting) and
       (table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat_info)) and
       (seat_info.Status in [psAllIn, psFolded, psInHand]) and
       (seat_info.CardCount > 0) and
       (seat_info.DealtCards = seat_info.CardCount) then
    begin
      if (table.Renderer.FlopAnimations.Count = 0) and
         (table.Renderer.TurnAnimations.Count = 0) and
         (table.Renderer.RiverAnimations.Count = 0) then
        lbvHandStrength.Caption := THandStrengthCalculator.GetHandStrength(seat_info.Cards.AsString,
              table.Status.FlopCards.AsString + table.Status.TurnCard.AsString + table.Status.RiverCard.AsString,
              table.Status.CurrentGame, TRUE)
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
    case FTableType of
      ttLiveGame: begin
        if table.GetObjectCopy(club, game) then
        try
          if game.GameType = gtRotationNLHPLO then
          begin
            case table.Status.CurrentGame of
              gtHoldem: currentgame := 'NLH';
              gtOmaha: currentgame := 'PLO';
            end;
            rot_index := table.Status.RotationHand;
            if rot_index = 0 then
              rot_index := 1;
            result := Format('%s (%s/%s %s) (%d/%d %s) - %s', [game.Name, ChipsToStr(game.SmallBlind), ChipsToStr(game.BigBlind), game.AsString(TRUE), (rot_index - 1) mod game.Seats + 1, game.Seats, currentgame, club.Name])
          end
          else
            result := Format('%s (%s/%s %s) - %s', [game.Name, ChipsToStr(game.SmallBlind), ChipsToStr(game.BigBlind), game.AsString(TRUE), club.Name]);
        finally
          club.Free;
          game.Free;
        end;
      end;

      ttHandPlayback: if table.GetHandHistoryItem(hhi) then
        result := Format('Hand #%d: %s (%s/%s) - %s', [hhi.HandId, TGameInfo.GameTypeToStr(hhi.CurrentGame, hhi.ParentItems.Game.Limit, FALSE),
                   ChipsToStr(hhi.ParentItems.Game.SmallBlind), ChipsToStr(hhi.ParentItems.Game.BigBlind), hhi.StartTimeStr]);
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
          ServerSocket.SendTableChatLine(FGameId, Trim(edChat.Text));
        edChat.Clear;
      end;
      Key := #0;
    end;
  end;
end;

procedure TfrmTable.acShowCardsExecute(Sender: TObject);
var
  seat: TSeatInfo;
  table: TTable;
begin
  ServerSocket.ShowCards(FGameId);
  acShowCards.Enabled := FALSE;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat) then
      seat.CardsVisible := TRUE;
  finally
    Tables.Unlock;
  end;
  RefreshAll;
end;

procedure TfrmTable.acStandUpExecute(Sender: TObject);
begin
  if not ConfirmStandUp then
    Exit;

  ServerSocket.TableStandUp(FGameId);
end;

procedure TfrmTable.AddChatMessage(const AUser: String; const AUserStyle, AUserParagraph: Integer; const AMessage: String; const AMessageStyle, AMessageParagraph: Integer);
begin
  CheckChatScrollbackLimit;

  rvChat.AddNL(AUser, AUserStyle, AUserParagraph);
  rvChat.AddNL(AMessage, AMessageStyle, AMessageParagraph);

  if rvChat.VScrollPos < rvChat.VScrollMax then
    rvChat.Format
  else
    rvChat.FormatTail;
  rvChat.Refresh;
end;

procedure TfrmTable.AddDealerChatMessage(const AMessage: String);
begin
  AddChatMessage('Dealer: ', 2, 0, AMessage, 3, -1);
end;

procedure TfrmTable.AddUserChatMessage(const AUser, AMessage: String);
begin
  AddChatMessage(Format('%s: ', [AUser]), 0, 0, AMessage, 1, -1);
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
      table.Status.UpdateClosingTime(game);
    finally
      game.Free;
    end;
  finally
    Tables.Unlock;
  end;
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
      if CompareBytes(chat_event.TableId, FGameId) then
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
  table: TTable;
  game: TGameInfo;
begin
  AFocusWindow := FALSE;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.GetObjectCopy(game) then
    try
      raise_en := table.Status.ActionRaise;
      table.Status.ActionStandUp := FALSE;
      table.Status.ActionFold := FALSE;
      table.Status.ActionCall := FALSE;
      table.Status.ActionCheck := FALSE;
      table.Status.ActionRaise := FALSE;
      table.Status.ActionBet := FALSE;
      table.Status.ActionPlayNow := FALSE;
      table.Status.ActionSitOut := FALSE;
      table.Status.ActionFoldToAny := FALSE;
      table.Status.ActionSitOutNextBB := FALSE;
      table.Status.ActionShowCards := FALSE;

      seat_info := nil;
      if (table.TableType = ttLiveGame) and
         (table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat_info)) then
      begin
        table.Status.ActionStandUp := TRUE;

        if game.State <> gsClosed then
          case seat_info.Status of
            psOutOfPlay: begin
              table.Status.ActionPlayNow := TRUE;
              table.Status.ActionFoldToAny := FALSE;
              table.Status.ActionSitOut := FALSE;
              table.Status.ActionSitOutNextBB := FALSE;
            end;

            psOutOfHand: begin
              table.Status.ActionFoldToAny := FALSE;
              table.Status.ActionSitOut := TRUE;
              table.Status.ActionSitOutNextBB := TRUE;
            end;

            psInHand, psAllIn: begin
              table.Status.ActionSitOut := TRUE;
              table.Status.ActionSitOutNextBB := TRUE;
              if (seat_info.Status = psInHand) and
                 (table.Status.State in [tsPreFlop, tsFlop, tsTurn, tsRiver]) then
                table.Status.ActionFoldToAny := TRUE;

              if (table.Status.CurrentSeat = table.Status.SelfSeatIndex) and
                 (not table.Status.Locked) and
                 (not table.GameplayLocked) then
                case table.Status.State of
                  tsIdle: begin
                    table.Status.ActionFoldToAny := FALSE;
                  end;

                  tsPreFlop, tsFlop, tsTurn, tsRiver: begin
                    table.Status.ActionFold := TRUE;
                    // check if our current bet is smaller than minimumbet (call/raise situation)
                    if table.Status.GetBet(seat_info.SeatIndex) < table.Status.MinimumBet then
                    begin
                      if seat_info.Chips <= table.Status.MinimumBet then
                        acCall.Caption := 'CALL (ALL-IN)'
                      else
                        acCall.Caption := Format('CALL (%s)', [ChipsToStr(table.Status.MinimumBet{ - table.Status.GetBet(seat_info.SeatIndex)})]);
                      table.Status.ActionCall := TRUE;

                      // if we can call, there is a possibility that we can raise too - we check if we can raise here
                      if (seat_info.Chips > table.Status.MinimumBet) and
                         (table.Status.MinimumBet < table.Status.MinimumRaise) then
                        table.Status.ActionRaise := TRUE;
                    end
                    else // if our current bet isnt smaller than minimum bet, that means its check/raise situation
                    begin
                      table.Status.ActionCheck := TRUE;
                      table.Status.ActionBet := TRUE;
                    end;

                    AFocusWindow := TRUE;
                  end;

                  tsWinning, tsWinning2: begin
                    table.Status.ActionFoldToAny := FALSE;
                  end;
                end
              else
                FWindowFocused := FALSE;
            end;

            psFolded: begin
              table.Status.ActionFoldToAny := FALSE;
              table.Status.ActionSitOut := TRUE;
              table.Status.ActionSitOutNextBB := TRUE;
            end;
          end;
      end;

      // if raise slider was not enabled, set it to minimum value
      if not raise_en then
        FRaiseValue := table.Status.MinimumRaise;
      SetRaiseValue(FRaiseValue, TRUE, TRUE, FALSE);

      // check if SHOW CARDS button is enabled
      table.Status.ActionShowCards := (table.Status.State in [tsWinning, tsWinning2]) and
                                      (Assigned(seat_info)) and
                                      (seat_info.CanShow) and
                                      (not seat_info.CardsVisible) and
                                      (seat_info.Status in [psFolded, psAllIn, psInHand]);

      // enable actions
      acStandUp.Enabled := table.Status.ActionStandUp;
      acFold.Enabled := table.Status.ActionFold;
      acCall.Enabled := table.Status.ActionCall;
      acCheck.Enabled := table.Status.ActionCheck;
      acRaise.Enabled := table.Status.ActionRaise;
      acRaise.Enabled := (table.Status.ActionBet) or (table.Status.ActionRaise);
      acRaiseMin.Enabled := acRaise.Enabled;
      acRaise3BB.Enabled := acRaise.Enabled;
      acRaisePot.Enabled := acRaise.Enabled;
      acRaiseMax.Enabled := acRaise.Enabled;
      acPlayNow.Enabled := table.Status.ActionPlayNow;
      acShowCards.Enabled := table.Status.ActionShowCards;
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
  if WindowState <> wsMaximized then
  begin
    hround := Round(Width / FORM_ASPECT_RATIO);
    if Height <> hround then
      Height := hround;
  end;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
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

        if table.Status.ActionSitOut then
        begin
          cbSitOutNextHand.Visible := TRUE;
          cbSitOutNextBB.Visible := TRUE;
          cbFoldToAnyBet.Visible := TRUE;

          cbSitOutNextBB.Enabled := table.Status.ActionSitOutNextBB;
          cbFoldToAnyBet.Enabled := table.Status.ActionFoldToAny;

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
          if table.Status.CurrentLimit = glPotLimit then
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

        lbvHandStrength.Top := Round(table.Renderer.GetDXButton(FDXBRaisePresets[High(FDXBRaisePresets)]).Bounds^[0].y - lbvHandStrength.Height - 5);
        UpdateHandHistoryLabel;
      end;

      ttHandPlayback: begin
        rvChat.Color := $00262626;
        pbHandPlaybackProgress.BoundsRect := table.Renderer.Metrics.HandPlaybackProgress;
        btPlayPause.BoundsRect := table.Renderer.Metrics.HandPlaybackPlay;
        btStepForward.BoundsRect := table.Renderer.Metrics.HandPlaybackForward;
        btStepBackwards.BoundsRect := table.Renderer.Metrics.HandPlaybackBack;
        pbHandPlaybackProgress.Position := table.HandHistoryPlayback.CurrentStateIndex;
      end;
    end;
  finally
    Tables.Unlock;
  end;

  UpdateHandStrength;
  UpdateTableCaption;
end;

function TfrmTable.ConfirmLeaveTable: Boolean;
var
  table: TTable;
  tt: TTableType;
  is_sitting: Boolean;
begin
  tt := ttLiveGame;
  is_sitting := FALSE;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    tt := table.TableType;
    is_sitting := table.Status.IsSitting;
  finally
    Tables.Unlock;
  end;

  result := TRUE;
  if (tt = ttLiveGame) and
     (is_sitting) then
    result := MessageDlg('Are you sure you want to leave the table? This will automatically fold your current hand and get you up from the seat.', mtWarning, mbYesNo, 0) = mrYes;
end;

function TfrmTable.ConfirmStandUp: Boolean;
var
  seat: TSeatInfo;
  table: TTable;
  tt: TTableType;
  is_sitting: Boolean;
  player_status: TPlayerStatus;
begin
  tt := ttLiveGame;
  is_sitting := FALSE;
  player_status := psOutOfPlay;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    tt := table.TableType;
    is_sitting := table.Status.IsSitting;
    if table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat) then
      player_status := seat.Status;
  finally
    Tables.Unlock;
  end;

  result := TRUE;
  if (tt = ttLiveGame) and
     (is_sitting) and
     (player_status in [psInHand, psFolded, psAllIn]) then
    result := MessageDlg('Are you sure you want to stand up? This will automatically fold your current hand and any chips that you commited to current pot.', mtWarning, mbYesNo, 0) = mrYes;
end;

procedure TfrmTable.CSRETableStatus(const AMethodId: Integer; const AObject: TObject);
var
  pbtablestatus: TPB_TableStatus;
  table: TTable;
begin
  pbtablestatus := AObject as TPB_TableStatus;
  if not CompareBytes(pbtablestatus.TableMongoId, FGameId) then
    Exit;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.SetTableStatus(pbtablestatus, FALSE);
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

procedure TfrmTable.acCallExecute(Sender: TObject);
var
  seat_info: TSeatInfo;
  seat_bet: UINT32;
  call_amount: Integer;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    Assert(table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat_info));
    seat_bet := table.Status.GetBet(seat_info.SeatIndex);
    if seat_bet + seat_info.Chips < table.Status.MinimumBet then
      call_amount := seat_bet + seat_info.Chips
    else
      call_amount := table.Status.MinimumBet;
    ServerSocket.PutChips(FGameId, call_amount, table.Status.State);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acCheckExecute(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    ServerSocket.PutChips(FGameId, table.Status.GetBet(table.Status.SelfSeatIndex), table.Status.State);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acFoldExecute(Sender: TObject);
begin
  if (acCheck.Enabled) and
     (Settings.FoldChecks) then
    acCheck.Execute
  else
    ServerSocket.Fold(FGameId);
end;

procedure TfrmTable.acPlayNowExecute(Sender: TObject);
var
  seat: TSeatInfo;
  sindex: Integer;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.Status.IsSitting) and
       (table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat)) and
       (seat.Chips = 0) then
    begin
      sindex := seat.SeatIndex;
      FormsContainer.Add(RunModalForm(TfrmTableSit, self, [@FInternalId, table.Status, @sindex], ModalFormClose));
      Exit;
    end;

    ServerSocket.TablePlayNow(FGameId);
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
    val := table.Status.MinimumBet;
    if (val = 0) and
       (table.GetObjectCopy(game)) then
    try
      val := game.BigBlind;
    finally
      game.Free;
    end;
    SetRaiseValue(val * 3);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acRaiseMaxExecute(Sender: TObject);
var
  table: TTable;
  maxraise: UINT32;
begin
  maxraise := 0;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    maxraise := table.Status.MaximumRaise;
  finally
    Tables.Unlock;
  end;

  SetRaiseValue(maxraise);
end;

procedure TfrmTable.acRaiseMinExecute(Sender: TObject);
var
  table: TTable;
  minraise: UINT32;
begin
  minraise := 0;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    minraise := table.Status.MinimumRaise;
  finally
    Tables.Unlock;
  end;

  SetRaiseValue(minraise);
end;

procedure TfrmTable.acRaiseExecute(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    ServerSocket.PutChips(FGameId, FRaiseValue, table.Status.State);
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
  raise_value := 0;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    seat_bet := table.Status.GetBet(table.Status.SelfSeatIndex);

    raise_value := table.Status.MinimumBet - seat_bet;
    for C1 := 0 to table.Status.Pots.Count - 1 do
      Inc(raise_value, table.Status.Pots[C1].ValueWithoutRake);
    for C1 := 0 to table.Status.Bets.Count - 1 do
      Inc(raise_value, table.Status.Bets[C1]);
    raise_value := raise_value + table.Status.MinimumBet;
  finally
    Tables.Unlock;
  end;

  SetRaiseValue(raise_value);
end;

procedure TfrmTable.SetRaiseActionCaption;
var
  seat_info: TSeatInfo;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat_info) then
    begin
      if table.Status.ActionRaise then
      begin
        if FRaiseValue = seat_info.Chips + table.Status.GetBet(table.Status.SelfSeatIndex) then
          acRaise.Caption := 'RAISE (ALL-IN)'
        else
          acRaise.Caption := Format('RAISE (%s)', [ChipsToStr(FRaiseValue)])
      end
      else
        if table.Status.ActionBet then
        begin
          if FRaiseValue = seat_info.Chips + table.Status.GetBet(table.Status.SelfSeatIndex) then
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
  oldval := FRaiseValue;
  val := AValue;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (not AAbsoluteJump) and
       (table.GetObjectCopy(game)) then
    try
      if val > oldval then
        val := oldval + game.BigBlind
      else
        if val < oldval then
          val := oldval - game.BigBlind;
    finally
      game.Free;
    end;

    if val > table.Status.MaximumRaise then
      val := table.Status.MaximumRaise
    else
      if val < table.Status.MinimumRaise then
        val := table.Status.MinimumRaise;

    FRaiseValue := val;

    if table.Status.MaximumRaise = table.Status.MinimumRaise then
      table.Renderer.RaiseThumbPosition := 1
    else
      table.Renderer.RaiseThumbPosition := (FRaiseValue - table.Status.MinimumRaise) /
                                            (table.Status.MaximumRaise - table.Status.MinimumRaise);

    if ASetSpinEditValue then
      seRaiseAmount.Value := val / 100;

    SetRaiseActionCaption;

    if FRaiseValue <> oldval then
      table.Renderer.Render;
  finally
    Tables.Unlock;
  end;

  if (FRaiseValue <> oldval) and
     (AConfigureGUI) then
    ConfigureGUI;
end;

procedure TfrmTable.TableStatusUpdate;
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.Renderer.Enable;
  finally
    Tables.Unlock;
  end;

  // ActionManager is initially in suspended state, to make sure no actions can be executed while table contains no data
  // this block is executed when first tablestatus is received, and it also enables ActionManager
  // also start playback of the hand, if table is in ttHandPlayback mode
  if ActionManager.State = asSuspended then
  begin
    ActionManager.State := asNormal;
    if FTableType = ttHandPlayback then
      acHandPlaybackPlay.Execute;
  end;

  RefreshAll;
end;

procedure TfrmTable.RefreshAll;
var
  focus_window: Boolean;
  table: TTable;
begin
  ConfigureActions(focus_window);
  if focus_window then
    FocusWindow;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.Renderer.UpdateDXAreaSize;
    ConfigureGUI;
    table.Renderer.Render;

    if (table.Status.ActionFoldToAny) and
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
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.PlaySound(ASound);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.RendererTimebankStarted(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.Status.CurrentSeat = table.Status.SelfSeatIndex then
      table.PlaySound(Sounds.SOUND_TIMEBANK);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.CSRHandHistoryMsg(const AMethodId: Integer; const AObject: TObject);
begin
  RefreshAll;
end;

procedure TfrmTable.tiHandPlaybackTimer(Sender: TObject);
var
  table: TTable;
  gtc: DWORD;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.SetTableStatus(table.HandHistoryPlayback.NextState, TRUE);

    tiHandPlayback.Interval := 1000;
    if table.GameplayLocked then
    begin
      gtc := GetTickCount;
      if gtc < table.GameplayLockedEndTime then
        tiHandPlayback.Interval := table.GameplayLockedEndTime - GetTickCount;
    end;

    if table.HandHistoryPlayback.CurrentStateIndex = table.HandHistoryPlayback.States.Count - 1 then
    begin
      tiHandPlayback.Enabled := FALSE;
      btPlayPause.Action := acHandPlaybackPlay;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acHandHistoryExecute(Sender: TObject);
var
  form: TForm;
  handid: UINT32;
  hhis: THandHistoryItems;
begin
  if not HandHistory.TryGetValue(FGameId, hhis) then
    handid := 0
  else
    handid := hhis.LastHandId;

  if FormsContainer.Find(TfrmHandHistory, form) then
  begin
    (form as TfrmHandHistory).SetSelectedHandId(FGameId, handid);
    form.SetFocus;
  end
  else
    FormsContainer.RunForm(TfrmHandHistory, frmChipUpMain, [@FGameId[0], @handid], FALSE)
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
      table.SetTableStatus(table.HandHistoryPlayback.CurrentState, TRUE);
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
      table.SetTableStatus(table.HandHistoryPlayback.PrevState, TRUE);
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
      table.SetTableStatus(table.HandHistoryPlayback.NextState, TRUE);
  finally
    Tables.Unlock;
  end;
end;

end.

