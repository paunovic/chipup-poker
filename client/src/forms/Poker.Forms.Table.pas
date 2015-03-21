unit Poker.Forms.Table;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, System.Generics.Collections, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, cxContainer, cxEdit, Poker.Tables.Status, Poker.DirectX.Animation,
  Asphyre.Math, Vcl.ActnList, cxLabel, Poker.Tables.Table, cxTextEdit, Vcl.ActnMan,
  cxSpinEdit, cxCheckBox, Poker.Protobufs.Objects.TableStatus,
  Poker.Protobufs.Objects.TableEvent, System.Types, RVStyle, RVScroll, RichView,
  Asphyre.Images, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  dxSkinsCore, ChipUpPokerDarkSkin, Vcl.Menus, Vcl.ImgList,
  Vcl.PlatformDefaultStyleActnCtrls, cxProgressBar, Vcl.StdCtrls, cxButtons, cxMaskEdit,
  dxScreenTip, dxCustomHint, cxHint, cxImage, Poker.Types, cxRadioGroup;

type
  TfrmTable = class(TForm)
    ActionManager: TActionManager;
    acStandUp: TAction;
    acFold: TAction;
    acCall: TAction;
    acCheck: TAction;
    acRaise: TAction;
    acPlayNow: TAction;
    acRaiseMin: TAction;
    acRaise3BB: TAction;
    acRaisePot: TAction;
    acRaiseMax: TAction;
    acShowCards: TAction;
    edChat: TcxTextEdit;
    cbFoldToAnyBet: TcxCheckBox;
    cbSitOutNextHand: TcxCheckBox;
    cbSitOutNextBB: TcxCheckBox;
    seRaiseAmount: TcxSpinEdit;
    RVStyle: TRVStyle;
    rvChat: TRichView;
    lbvHandStrength: TcxLabel;
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
    acTableStats: TAction;
    paTopLeftHeader: TPanel;
    lbvHandHistory: TcxLabel;
    lbsTableStats: TcxLabel;
    beTopLeftHeaderSpacer: TBevel;
    btNextHand: TcxButton;
    btPreviousHand: TcxButton;
    acNextHand: TAction;
    acPreviousHand: TAction;
    cbAutoCheck: TcxCheckBox;
    cbAutoCheckFold: TcxCheckBox;
    cbAutoCall: TcxCheckBox;
    cbAutoCallAny: TcxCheckBox;
    cbSplitTableCards: TcxCheckBox;
    acJoinWaitingList: TAction;
    acLeaveWaitingList: TAction;
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
    procedure seRaiseAmountPropertiesChange(Sender: TObject);
    procedure acRaiseMinExecute(Sender: TObject);
    procedure acRaise3BBExecute(Sender: TObject);
    procedure acRaisePotExecute(Sender: TObject);
    procedure acRaiseMaxExecute(Sender: TObject);
    procedure cbSitOutNextBBPropertiesChange(Sender: TObject);
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
    procedure acTableStatsExecute(Sender: TObject);
    procedure lbsTableStatsClick(Sender: TObject);
    procedure acNextHandExecute(Sender: TObject);
    procedure acPreviousHandExecute(Sender: TObject);
    procedure cbAutoCheckPropertiesChange(Sender: TObject);
    procedure cbSplitTableCardsPropertiesChange(Sender: TObject);
    procedure acJoinWaitingListExecute(Sender: TObject);
    procedure acLeaveWaitingListExecute(Sender: TObject);
  private
    const
      FORM_ASPECT_RATIO = 1.35;

    var
      FInternalId: Integer;
      FCallbacksId: Integer;
      FRaiseValue: UINT32;
      FWindowFocused: Boolean;
      FGameId: TMongoId;
      FTableType: TTableType;

      FDXBFold: Integer;
      FDXBShowCards: Integer;
      FDXBCheck: Integer;
      FDXBCall: Integer;
      FDXBRaise: Integer;
      FDXBRaisePresets: array[0..3] of Integer;

      FBuyinForm: TForm;

    procedure SetActionCaptions;
    procedure SetRaiseValue(const AValue: UINT32; const ASetSpinEditValue: Boolean = TRUE; const AConfigureGUI: Boolean = TRUE);

    procedure AddUserChatMessage(const AUser, AMessage: String);
    procedure AddDealerChatMessage(const AMessage: String);
    procedure AddSystemChatMessage(const AMessage: String);
    procedure ModalFormClose(Sender: TObject);
    procedure CheckChatScrollbackLimit;
    procedure RendererDealerChatMessage(const AMessage: String);
    procedure RendererSoundPlay(const ASound: String; const AIgnoreFocus: Boolean = FALSE);
    procedure RendererTimebankStarted(Sender: TObject);
    procedure RendererUpdateHandStrength(Sender: TObject);
    procedure ConfigureActions;
    procedure ConfigureAutoPlayOptions;
    procedure AddChatMessage(const AUser: String; const AUserStyle, AUserParagraph: Integer; const AMessage: String; const AMessageStyle, AMessageParagraph: Integer);

    procedure UpdateTableCaption;
    procedure UpdateHandHistoryLabel;
    procedure UpdateHandStrength;
    procedure FocusWindow;
    procedure UncheckAutoplayOptions;

    function ConfirmLeaveTable: Boolean;
    function ConfirmStandUp: Boolean;

    procedure CSRChatEvent(const AMethodId: Integer; const AObject: TObject);
    procedure CSRETableStatus(const AMethodId: Integer; const AObject: TObject);
    procedure CSEUserChange(const AMethodId: Integer; const AObject: TObject);
    procedure CSEGameChange(const AMethodId: Integer; const AObject: TObject);
    procedure CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
    procedure CSRHandHistoryMsg(const AMethodId: Integer; const AObject: TObject);
    procedure CSEClubChange(const AMethodId: Integer; const AObject: TObject);
    procedure CSEReservedSeatFree(const AMethodId: Integer; const AObject: TObject);

    procedure DefocusControls;
    procedure RefreshAll;
    procedure TableStatusUpdate;
    procedure ChangeHandPlaybackHandId(const AOffset: Integer);
  protected
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure WMSizing(var AMessage: TMessage); message WM_SIZING;
    procedure WndProc(var AMessage: TMessage); override;
  public
    constructor Create(const AInternalId: Integer); reintroduce;
    procedure ChangeGameId(const AGameId: TMongoId);
    procedure ConfigureGUI;
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, System.TypInfo, {$ENDIF}
  Poker.Server.MessageContainer, Poker.Server.Settings, Poker.DirectX.Timer, Poker.Server.MessageCallbacks, Poker.Protobufs.Enum.ServerCodes,
  Poker.Protobufs.Objects.ChatEvent, Poker.Protobufs.Objects.ChatMessage, Poker.Protobufs.Objects.SeatInfo, Poker.Tables.Resources,
  Poker.WindowMessages, Poker.DirectX.Core, Poker.Common.FormsContainer, Poker.Server.Socket, Poker.Common.Misc, Poker.Settings,
  Poker.Forms.TableSit, Poker.DataModule, Poker.Players.PlayerList, Poker.Protobufs.Objects.Game, Poker.Games.Game, Poker.Sounds,
  Poker.Protobufs.Objects.WinnerData, Poker.HandStrengthCalculator, Poker.Forms.HandHistory, Poker.Forms.Main, Poker.HandHistory.Core,
  Poker.Seats.Seat, Poker.Cards, Poker.Players.Player, Poker.Tables.TableList, Poker.Clubs.Club, Poker.HandHistory.Items, Poker.Helpers.PB_Pot,
  Poker.Forms.ClubLobby, Poker.Protobufs.Objects.ClubMember, Poker.Protobufs.Objects.Club, Poker.Common.ModalDialogs,
  Poker.Protobufs.Objects.ReservedSeatFree;


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
  ActionManager.State := asSuspended;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    FTableType := table.TableType;
    FGameId := table.GameId;
  finally
    Tables.Unlock;
  end;

  FCallbacksId := -1;
  case FTableType of
    ttLive, ttTournament: begin
      FCallbacksId := MessageContainer.AddCallbacks([
                          TServerMessageCallback.Create(seChat, CSRChatEvent),
                          TServerMessageCallback.Create(seClubChange, CSEClubChange),
                          TServerMessageCallback.Create(seUserChange, CSEUserChange),
                          TServerMessageCallback.Create(seGameChange, CSEGameChange),
                          TServerMessageCallback.Create(srGetPlayers, CSRGetUsers),
                          TServerMessageCallback.Create(srHandHistoryMsg, CSRHandHistoryMsg),
                          TServerMessageCallback.Create(seReservedSeatFree, CSEReservedSeatFree),
                          TServerMessageCallback.Create([seTableStatus, srTableSitOk,
                            srTableAddonOk, srTableStandUpOk, seReservedSeatTimeout], CSRETableStatus)
                      ]);
    end;

    ttHandReplay: begin
      edChat.Visible := FALSE;
      lbvHandHistory.Visible := FALSE;
      lbvHandStrength.Visible := FALSE;
      lbsTableStats.Visible := FALSE;

      pbHandPlaybackProgress.Properties.Min := 0;
      pbHandPlaybackProgress.Visible := TRUE;
      btPlayPause.Visible := TRUE;
      btStepForward.Visible := TRUE;
      btStepBackwards.Visible := TRUE;
      btNextHand.Visible := TRUE;
      btPreviousHand.Visible := TRUE;
    end;
  end;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.Renderer.UpdateDXAreaSize;

    table.Renderer.OnDealerChatMessage := RendererDealerChatMessage;
    table.Renderer.OnSoundPlay := RendererSoundPlay;
    table.Renderer.OnTimebankStarted := RendererTimebankStarted;
    table.Renderer.OnUpdateHandStrength := RendererUpdateHandStrength;

    table.Renderer.AddDXButton(acStandUp, @table.Renderer.Metrics.StandUpButtonBounds, TableResources.StandUpButtonNormalImage, TableResources.StandUpButtonPressedImage, nil);
    table.Renderer.AddDXButton(acPlayNow, @table.Renderer.Metrics.PlayNowButtonBounds, TableResources.PlayNowButtonNormalImage, TableResources.PlayNowButtonPressedImage, nil);
    table.Renderer.AddDXButton(acJoinWaitingList, @table.Renderer.Metrics.JoinWaitingListButtonBounds, TableResources.JoinWaitingListNormal, TableResources.JoinWaitingListPressed, nil);
    table.Renderer.AddDXButton(acLeaveWaitingList, @table.Renderer.Metrics.LeaveWaitingListButtonBounds, TableResources.LeaveWaitingListNormal, TableResources.LeaveWaitingListPressed, nil, FALSE, 0.15);

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
var
  table: TTable;
  close_table: Boolean;
begin
  close_table := TRUE;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.TableType = ttTournament) and
       (table.Status.IsSitting) then
    begin
      close_table := FALSE;
      table.Hidden := TRUE;
    end;
  finally
    Tables.Unlock;
  end;

  if close_table then
    Tables.Remove(FInternalId)
  else
    ServerSocket.TableSitOutNextHand(FGameId, TRUE);
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
      table.PlaySound(Sounds.SOUND_TIMEBAR, TRUE);
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
  if FTableType = ttHandReplay then
    acHandPlaybackPlay.Execute;

  RefreshAll;
end;

procedure TfrmTable.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  set_raise_amount: Boolean;
  raise_value: DWORD;
  table: TTable;
begin
  DefocusControls;

  if Button = mbLeft then
  begin
    if Tables.GetAndLockTable(FInternalId, table) then
    try
      table.Renderer.MouseDown(Button, Shift, X, Y, set_raise_amount);

      if set_raise_amount then
      begin
        raise_value := RoundToNearestBB(Round(table.Status.MinimumRaise +
                               (table.Status.MaximumRaise - table.Status.MinimumRaise) *
                               table.Renderer.RaiseThumbPosition), table.game.BigBlind);

        if raise_value > FRaiseValue then
          raise_value := FRaiseValue + table.game.BigBlind
        else
          if raise_value < FRaiseValue then
            raise_value := FRaiseValue - table.game.BigBlind
          else
            raise_value := FRaiseValue;

        SetRaiseValue(raise_value, TRUE, FALSE);
      end;

      table.Renderer.Render;
    finally
      Tables.Unlock;
    end;
  end;
end;

procedure TfrmTable.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  set_raise_amount: Boolean;
  table: TTable;
  seat_index: Integer;
  seat: TSeatInfo;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.Renderer.MouseMove(Shift, X, Y, set_raise_amount);

    if (table.Status.TotalRake > 0) and
       (PtInRect(RectF(table.Renderer.Metrics.TotalRakePoint.x - table.Renderer.Metrics.ChipWidth / 2, 0,
                       table.Renderer.Metrics.TotalRakePoint.x + table.Renderer.Metrics.ChipWidth / 2,
                       table.Renderer.Metrics.TotalRakePoint.y + table.Renderer.Metrics.ChipHeight), PointF(X, Y))) then
    begin
      Hint := Format('Rake: %s', [ChipsToStr(table.Status.TotalRake)]);
      ShowHint := TRUE;
    end
    else
      if (table.Renderer.Metrics.IsPointInSeat(table.game, X, Y, seat_index)) and
         (table.Status.GetSeatInfo(seat_index, seat)) then
      begin
        Hint := Format('Chips: %s', [ChipsToStr(seat.Chips)]);
        ShowHint := TRUE;
      end
      else
      begin
        Hint := '';
        ShowHint := FALSE;
      end;

    if set_raise_amount then
      SetRaiseValue(RoundToNearestBB(Round(table.Status.MinimumRaise +
          (table.Status.MaximumRaise - table.Status.MinimumRaise) * table.Renderer.RaiseThumbPosition), table.game.BigBlind), TRUE, FALSE);

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
  member: TPB_ClubMember;
begin
  client_cursor_pos := ScreenToClient(Mouse.CursorPos);
  DefocusControls;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    // if table is not live game or its closed, abort
    if (table.TableType <> ttLive) or
       (table.game.State = gsClosed) then
      Exit;

    // if user is suspended, abort
    if (table.Club.GetMemberInfo(dmMain.SelfInfo.MongoId, member)) and
       (member.Suspended) then
      Exit;

    // if cursor is in some seat..
    if table.Renderer.Metrics.IsPointInSeat(table.game, client_cursor_pos.X, client_cursor_pos.Y, seat_index) then
    begin
      // if we are sitting at that seat, and we are out of play or out of hand
      if (table.Status.IsSitting) and
         (table.Status.SelfSeatIndex = seat_index) and
         (table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat_info)) and
         (seat_info.Status in [psOutOfPlay, psOutOfHand]) then
        FormsContainer.Add(RunModalForm(TfrmTableSit, self, [@FInternalId, @seat_index], ModalFormClose))
      else // if we are not sitting and seat is free
        if (not table.Status.IsSitting) and
           (not table.Status.IsSeatFree(seat_index)) then
          FormsContainer.Add(RunModalForm(TfrmTableSit, self, [@FInternalId, @seat_index], ModalFormClose));
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
    SetRaiseValue(valuint, FALSE, FALSE);
  end;
end;

procedure TfrmTable.UncheckAutoplayOptions;
begin
  cbAutoCheck.Checked := FALSE;
  cbAutoCheckFold.Checked := FALSE;
  cbAutoCall.Checked := FALSE;
  cbAutoCallAny.Checked := FALSE;
end;

procedure TfrmTable.UpdateHandHistoryLabel;
var
  hhis: THandHistoryItems;
  lbl: String;
begin
  lbl := '';
  if FTableType in [ttTournament, ttLive] then
  begin
    HandHistory.Lock;
    try
      if (HandHistory.TryGetValue(FGameId, hhis)) and
         (hhis.LastHandId > 0) then
        lbl := Format('Previous Hand (#%d)', [hhis.LastHandId]);
    finally
      HandHistory.Unlock;
    end;
  end;

  lbvHandHistory.Caption := lbl;
  lbvHandHistory.Visible := lbl <> '';
  lbvHandHistory.Refresh;
end;

procedure TfrmTable.UpdateHandStrength;
var
  seat_info: TSeatInfo;
  table: TTable;
  hs: String;
  C1: Integer;
  tcards: TList<String>;
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
      begin
        hs := '';
        tcards := TList<String>.Create;
        try
          tcards.Add('');
          while tcards.Count < table.Status.RiverCard.Count do
            tcards.Add('');
          while tcards.Count < table.Status.TurnCard.Count do
            tcards.Add('');
          while tcards.Count < table.Status.FlopCards.Count do
            tcards.Add('');

          for C1 := table.Status.RiverCard.Count - 1 downto 0 do
            tcards[C1] := table.Status.RiverCard[C1].AsString;
          for C1 := table.Status.TurnCard.Count - 1 downto 0 do
            tcards[C1] := table.Status.TurnCard[C1].AsString + tcards[C1];
          for C1 := table.Status.FlopCards.Count - 1 downto 0 do
            tcards[C1] := table.Status.FlopCards[C1].AsString + tcards[C1];

          for C1 := 0 to tcards.Count - 1 do
          begin
            hs := hs + THandStrengthCalculator.GetHandStrength(seat_info.Cards.AsString,
                tcards[C1], table.Status.CurrentGame, TRUE);
            if C1 < tcards.Count - 1 then
              hs := hs + #10;
          end;
        finally
          tcards.Free;
        end;
        lbvHandStrength.Caption := hs;
      end;
    end
    else
      lbvHandStrength.Caption := '';
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.UpdateTableCaption;
var
  cap: String;
  table: TTable;
begin
  cap := '';
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    cap := table.GetTableCaption;
  finally
    Tables.Unlock;
  end;

  if cap <> Caption then
    Caption := cap;
end;

procedure TfrmTable.lbsTableStatsClick(Sender: TObject);
begin
  acTableStats.Execute;
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

procedure TfrmTable.acTableStatsExecute(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    FormsContainer.RunForm(TfrmClubLobby, self, [table.ClubId.Memory, table.GameId.Memory], TRUE);
  finally
    Tables.Unlock;
  end;
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

procedure TfrmTable.AddSystemChatMessage(const AMessage: String);
begin
  AddChatMessage('Administrator: ', 5, 0, AMessage, 6, -1);
end;

procedure TfrmTable.AddUserChatMessage(const AUser, AMessage: String);
var
  msg_style: Integer;
begin
  if AUser = dmMain.SelfInfo.Displayname then
    msg_style := 4
  else
    msg_style := 1;

  AddChatMessage(Format('%s: ', [AUser]), 0, 0, AMessage, msg_style, -1);
end;

procedure TfrmTable.cbAutoCheckPropertiesChange(Sender: TObject);
var
  checkbox_list: TObjectList<TcxCheckBox>;
  C1, sender_index, checked_index: Integer;
begin
  checkbox_list := TObjectList<TcxCheckBox>.Create(FALSE);
  try
    checkbox_list.Add(cbAutoCheck);
    checkbox_list.Add(cbAutoCheckFold);
    checkbox_list.Add(cbAutoCall);
    checkbox_list.Add(cbAutoCallAny);

    // put sender as first element in list, so it doesnt get unchecked
    sender_index := checkbox_list.IndexOf(Sender as TcxCheckBox);
    if sender_index > 0 then
      checkbox_list.Exchange(0, sender_index);
    checked_index := -1;

    // find checked index
    for C1 := 0 to checkbox_list.Count - 1 do
      if checkbox_list[C1].Checked then
      begin
        checked_index := C1;
        Break;
      end;

    // uncheck the others
    for C1 := 0 to checkbox_list.Count - 1 do
      if C1 <> checked_index then
      begin
        checkbox_list[C1].Properties.OnChange := nil;
        checkbox_list[C1].Checked := FALSE;
        checkbox_list[C1].Properties.OnChange := cbAutoCheckPropertiesChange;
      end;
  finally
    checkbox_list.Free;
  end;
end;

procedure TfrmTable.cbFoldToAnyBetPropertiesChange(Sender: TObject);
begin
  RefreshAll;
end;

procedure TfrmTable.cbSitOutNextBBPropertiesChange(Sender: TObject);
var
  seat_info: TSeatInfo;
  table: TTable;
begin
  if not cbSitOutNextBB.Enabled then
    Exit;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat_info)) and
       (seat_info.Status <> psOutOfPlay) then
      ServerSocket.TableSitOutNextBB(FGameId, cbSitOutNextBB.Checked);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.cbSitOutNextHandPropertiesChange(Sender: TObject);
var
  seat_info: TSeatInfo;
  table: TTable;
begin
  if not cbSitOutNextHand.Enabled then
    Exit;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat_info)) and
       (seat_info.Status <> psOutOfPlay) then
      ServerSocket.TableSitOutNextHand(FGameId, cbSitOutNextHand.Checked);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.cbSplitTableCardsPropertiesChange(Sender: TObject);
begin
  if not cbSplitTableCards.Enabled then
    Exit;

  ServerSocket.SplitTableCards(FGameId, cbSplitTableCards.Checked);
end;

procedure TfrmTable.CSEClubChange(const AMethodId: Integer; const AObject: TObject);
var
  pbclub: TPB_Club;
  table: TTable;
  refresh_all: Boolean;
begin
  if not TTypes.TryCast<TPB_Club>(AObject, pbclub) then
    Exit;

  refresh_all := FALSE;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    refresh_all := pbclub.MongoId = table.ClubId;
  finally
    Tables.Unlock;
  end;

  if refresh_all then
    RefreshAll;
end;

procedure TfrmTable.CSEGameChange(const AMethodId: Integer; const AObject: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.Status.UpdateClosingTime(table.game);
  finally
    Tables.Unlock;
  end;
  RefreshAll;
end;

procedure TfrmTable.CSEReservedSeatFree(const AMethodId: Integer; const AObject: TObject);
var
  seat_index: Integer;
  pbreservedseatfree: TPB_ReservedSeatFree;
begin
  if not TTypes.TryCast<TPB_ReservedSeatFree>(AObject, pbreservedseatfree) then
    Exit;
  if pbreservedseatfree.Ts.TableMongoId <> FGameId then
    Exit;

  seat_index := pbreservedseatfree.SeatIndex;
  FBuyinForm := RunModalForm(TfrmTableSit, self, [@FInternalId, @seat_index], ModalFormClose);
  FormsContainer.Add(FBuyinForm);
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
  if not TTypes.TryCast<TPB_ChatEvent>(AObject, chat_event) then
    Exit;

  case chat_event.Event of
    ceUserMessage: begin
      chat_message := chat_event.Msg;
      if chat_event.TableId = FGameId then
        AddUserChatMessage(chat_message.Username, chat_message.Msg);
    end;
    ceServerMessage: AddSystemChatMessage(chat_event.Msg.Msg);
  end;
end;

procedure TfrmTable.ChangeGameId(const AGameId: TMongoId);
begin
  FGameId := AGameId;
end;

procedure TfrmTable.CheckChatScrollbackLimit;
begin
  if rvChat.ItemCount >= Settings.Hardcoded.TABLE_CHAT_SCROLLBACK_LINES then
    rvChat.DeleteParas(0, rvChat.ItemCount - Settings.Hardcoded.TABLE_CHAT_SCROLLBACK_LINES + 1);
end;

procedure TfrmTable.ConfigureActions;
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
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
    acJoinWaitingList.Enabled := table.Status.ActionJoinWaitingList;
    acLeaveWaitingList.Enabled := table.Status.ActionLeaveWaitingList;
    acShowCards.Enabled := table.Status.ActionShowCards;
    acTableStats.Enabled := table.Status.ActionShowStats;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.ConfigureAutoPlayOptions;
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    cbAutoCheck.Visible := table.Status.AutoCheckVisible;
    if table.Status.AutoCheckFoldVisible then
    begin
      cbAutoCheckFold.Visible := TRUE;
      cbAutoCheckFold.Caption := 'Check/Fold';
    end
    else
      if table.Status.AutoFoldVisible then
      begin
        cbAutoCheckFold.Visible := TRUE;
        cbAutoCheckFold.Caption := 'Fold';
      end
      else
        cbAutoCheckFold.Visible := FALSE;

    cbAutoCall.Caption := table.Status.AutoCallCaption;
    cbAutoCall.Visible := table.Status.AutoCallVisible;
    cbAutoCallAny.Visible := table.Status.AutoCallAnyVisible;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.ConfigureGUI;
var
  hround: Integer;
  table: TTable;
  member: TPB_ClubMember;
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
      ttLive, ttTournament: begin
        edChat.BoundsRect := table.Renderer.Metrics.ChatEditBounds;
        seRaiseAmount.BoundsRect := table.Renderer.Metrics.RaiseAmountBoxBounds;
        seRaiseAmount.Style.Font.Size := table.Renderer.Metrics.RaiseAmountBoxFontSize;

        cbSplitTableCards.Top := edChat.Top + edChat.Height - cbSitOutNextBB.Height;
        cbSitOutNextBB.Top := cbSplitTableCards.Top - cbSitOutNextBB.Height;
        cbSitOutNextHand.Top := cbSitOutNextBB.Top - cbSitOutNextHand.Height;
        cbFoldToAnyBet.Top := cbSitOutNextHand.Top - cbFoldToAnyBet.Height;

        cbFoldToAnyBet.Left := table.Renderer.Metrics.CheckboxesLeft;
        cbSitOutNextHand.Left := table.Renderer.Metrics.CheckboxesLeft;
        cbSitOutNextBB.Left := table.Renderer.Metrics.CheckboxesLeft;
        cbSplitTableCards.Left := table.Renderer.Metrics.CheckboxesLeft;

        cbAutoCheckFold.Top := cbSitOutNextHand.Top;
        cbAutoCheck.Top := cbAutoCheckFold.Top;
        cbAutoCall.Top := cbAutoCheckFold.Top;
        cbAutoCallAny.Top := cbAutoCheckFold.Top;
        cbAutoCheckFold.Left := Round(table.Renderer.Metrics.PlayNowButtonBounds[0].x);
        cbAutoCheck.Left := cbAutoCheckFold.Left + cbAutoCheckFold.Width + 2;
        if cbAutoCheck.Visible then
          cbAutoCall.Left := cbAutoCheck.Left + cbAutoCheck.Width + 2
        else
          cbAutoCall.Left := cbAutoCheckFold.Left + cbAutoCheckFold.Width + 2;
        cbAutoCallAny.Left := cbAutoCall.Left + cbAutoCall.Width + 2;

        lbsTableStats.Visible := acTableStats.Enabled;

        if table.Status.ActionSitOut then
        begin
          cbSitOutNextHand.Visible := TRUE;
          cbSitOutNextBB.Visible := TRUE;
          cbFoldToAnyBet.Visible := TRUE;
          cbSplitTableCards.Visible := TRUE;

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
          cbSplitTableCards.Visible := FALSE;
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

          SetRaiseValue(FRaiseValue, TRUE, FALSE);
        end;

        lbvHandStrength.Top := Round(table.Renderer.GetDXButton(FDXBRaisePresets[High(FDXBRaisePresets)]).Bounds^[0].y - lbvHandStrength.Height - 5);

        if table.Club.GetMemberInfo(dmMain.SelfInfo.MongoId, member) then
        begin
          if member.Muted then
          begin
            edChat.Text := 'You have been muted';
            edChat.Enabled := FALSE;
          end
          else
            if not edChat.Enabled then
            begin
              edChat.Enabled := TRUE;
              edChat.Text := '';
              edChat.OnExit(nil);
            end;
        end;
      end;

      ttHandReplay: begin
        pbHandPlaybackProgress.Properties.Max := table.HandHistoryPlayback.States.Count - 1;
        rvChat.Color := $00262626;
        pbHandPlaybackProgress.BoundsRect := table.Renderer.Metrics.HandPlaybackProgress;
        btPlayPause.BoundsRect := table.Renderer.Metrics.HandPlaybackPlay;
        btStepForward.BoundsRect := table.Renderer.Metrics.HandPlaybackForward;
        btStepBackwards.BoundsRect := table.Renderer.Metrics.HandPlaybackBack;
        btPreviousHand.BoundsRect := table.Renderer.Metrics.HandPlaybackPreviousHand;
        btNextHand.BoundsRect := table.Renderer.Metrics.HandPlaybackNextHand;
        pbHandPlaybackProgress.Position := table.HandHistoryPlayback.CurrentStateIndex;
      end;
    end;
  finally
    Tables.Unlock;
  end;

  UpdateHandStrength;
  UpdateHandHistoryLabel;
  UpdateTableCaption;
end;

function TfrmTable.ConfirmLeaveTable: Boolean;
var
  table: TTable;
  tt: TTableType;
  is_sitting: Boolean;
begin
  tt := ttLive;
  is_sitting := FALSE;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    tt := table.TableType;
    is_sitting := table.Status.IsSitting;
  finally
    Tables.Unlock;
  end;

  result := TRUE;
  if (tt = ttLive) and
     (is_sitting) then
    result := ModalDialogs.ShowConfirmation('Are you sure you want to leave the table? This will automatically fold your current hand and get you up from the seat.') = mrYes;
end;

function TfrmTable.ConfirmStandUp: Boolean;
var
  seat: TSeatInfo;
  table: TTable;
  tt: TTableType;
  is_sitting: Boolean;
  player_status: TPlayerStatus;
begin
  tt := ttLive;
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
  if (tt = ttLive) and
     (is_sitting) and
     (player_status in [psInHand, psFolded, psAllIn]) then
    result := ModalDialogs.ShowConfirmation('Are you sure you want to stand up? This will automatically fold your current hand and any chips that you commited to current pot.') = mrYes;
end;

procedure TfrmTable.CSRETableStatus(const AMethodId: Integer; const AObject: TObject);
var
  pbtablestatus: TPB_TableStatus;
  table: TTable;
begin
  if not TTypes.TryCast<TPB_TableStatus>(AObject, pbtablestatus) then
    Exit;
  if pbtablestatus.TableMongoId <> FGameId then
    Exit;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.SetTableStatus(pbtablestatus, FALSE);
    if table.Status.State in [tsIdle, tsWinning, tsWinning2] then
      UncheckAutoplayOptions;
    if AMethodId = Integer(srTableSitOk) then
      cbSplitTableCards.Checked := Settings.AlwaysRunItTwice; // reset doing business checkbox
    if AMethodId = Integer(seReservedSeatTimeout) then
      FormsContainer.Close(FBuyinForm);
    if (not table.Form.Visible) and
       (not table.Hidden) then
      table.Show;
  finally
    Tables.Unlock;
  end;

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

procedure TfrmTable.acCallExecute(Sender: TObject);
var
  table_state: TTableState;
  call_amount: UINT32;
  table: TTable;
begin
  call_amount := 0;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    call_amount := table.Status.GetCallAmount(table_state);;
  finally
    Tables.Unlock;
  end;
  ServerSocket.PutChips(FGameId, call_amount, table_state);
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
  begin
    if (Settings.FoldConfirmation) and
       (ModalDialogs.ShowConfirmation('You are folding, while you can free check. Proceed?') = mrNo) then
      Exit;

    ServerSocket.Fold(FGameId);
  end;
end;

procedure TfrmTable.acPlayNowExecute(Sender: TObject);
var
  seat: TSeatInfo;
  sindex: Integer;
  table: TTable;
  member: TPB_ClubMember;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.Club.GetMemberInfo(dmMain.SelfInfo.MongoId, member)) and
       (member.Suspended) then
      Exit;

    if (table.TableType = ttLive) and
       (table.Status.IsSitting) and
       (table.Status.GetSeatInfo(table.Status.SelfSeatIndex, seat)) and
       (seat.Chips = 0) then
    begin
      sindex := seat.SeatIndex;
      FormsContainer.Add(RunModalForm(TfrmTableSit, self, [@FInternalId, @sindex], ModalFormClose));
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
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    val := table.Status.MinimumBet;
    if val = 0 then
      val := table.game.BigBlind;
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

procedure TfrmTable.SetActionCaptions;
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

      acCall.Caption := table.Status.CallCaption;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.SetRaiseValue(const AValue: UINT32; const ASetSpinEditValue: Boolean = TRUE; const AConfigureGUI: Boolean = TRUE);
var
  val: UINT32;
  oldval: UINT32;
  table: TTable;
begin
  oldval := FRaiseValue;
  val := AValue;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
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

    SetActionCaptions;

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
  focus_window: Boolean;
begin
  focus_window := FALSE;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.Status.ResetRaiseValue then
      FRaiseValue := table.Status.MinimumRaise;
    focus_window := table.Status.FocusWindow;
    table.Status.FocusWindow := FALSE;
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
    if FTableType = ttHandReplay then
      acHandPlaybackPlay.Execute;
  end;

  SetRaiseValue(FRaiseValue, TRUE, FALSE);

  RefreshAll;

  if focus_window then
  begin
    FocusWindow;
    FWindowFocused := TRUE;
  end
  else
    FWindowFocused := FALSE;
end;

procedure TfrmTable.RefreshAll;
var
  table: TTable;
  state: TTableState;
  call_amount: UINT32;
begin
  ConfigureActions;
  ConfigureAutoPlayOptions;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.Renderer.UpdateDXAreaSize;
    ConfigureGUI;
    SetActionCaptions;
    table.Renderer.Render(FALSE);

    if (cbAutoCheck.Checked) and
       (acCheck.Enabled) then
    begin
      acCheck.Execute;
      table.Status.FocusWindow := FALSE;
      UncheckAutoplayOptions;
    end;

    if ((cbAutoCall.Checked) or
        (cbAutoCallAny.Checked)) and
       (acCall.Enabled) then
    begin
      call_amount := table.Status.GetCallAmount(state);
      if (call_amount = table.Status.AutoCallAmount) or
         (cbAutoCallAny.Checked) then
        acCall.Execute;
      table.Status.FocusWindow := FALSE;
      UncheckAutoplayOptions;
    end;

    if (cbAutoCheckFold.Checked) or
       (cbFoldToAnyBet.Checked) then
    begin
      if acCheck.Enabled then
      begin
        acCheck.Execute;
        table.Status.FocusWindow := FALSE;
        UncheckAutoplayOptions;
      end
      else
        if acFold.Enabled then
        begin
          acFold.Execute;
          table.Status.FocusWindow := FALSE;
          UncheckAutoplayOptions;
        end;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.RendererDealerChatMessage(const AMessage: String);
begin
  AddDealerChatMessage(AMessage);
end;

procedure TfrmTable.RendererSoundPlay(const ASound: String; const AIgnoreFocus: Boolean = FALSE);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    table.PlaySound(ASound, AIgnoreFocus);
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
    FocusWindow;
    if table.Status.CurrentSeat = table.Status.SelfSeatIndex then
      table.PlaySound(Sounds.SOUND_TIMEBANK, TRUE);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.RendererUpdateHandStrength(Sender: TObject);
begin
  UpdateHandStrength;
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
  handid := 0;
  HandHistory.Lock;
  try
    if HandHistory.TryGetValue(FGameId, hhis) then
      handid := hhis.LastHandId;
  finally
    HandHistory.Unlock;
  end;

  if FormsContainer.Find(TfrmHandHistory, form) then
  begin
    (form as TfrmHandHistory).SetSelectedHandId(FGameId, handid);
    form.SetFocus;
  end
  else
    FormsContainer.RunForm(TfrmHandHistory, frmChipUpMain, [FGameId.Memory, @handid], FALSE)
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

procedure TfrmTable.acJoinWaitingListExecute(Sender: TObject);
var
  table: TTable;
  member: TPB_ClubMember;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.Club.GetMemberInfo(dmMain.SelfInfo.MongoId, member)) and
       (member.Suspended) then
      Exit;

    ServerSocket.TableSit(FGameId, -1, 0);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acLeaveWaitingListExecute(Sender: TObject);
var
  table: TTable;
  member: TPB_ClubMember;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.Club.GetMemberInfo(dmMain.SelfInfo.MongoId, member)) and
       (member.Suspended) then
      Exit;

    ServerSocket.TableStandUp(FGameId);
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.ChangeHandPlaybackHandId(const AOffset: Integer);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.HandHistoryPlayback_GetHand(AOffset) then
    begin
      tiHandPlayback.Enabled := TRUE;
      ConfigureGUI;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TfrmTable.acNextHandExecute(Sender: TObject);
begin
  ChangeHandPlaybackHandId(+1);
end;

procedure TfrmTable.acPreviousHandExecute(Sender: TObject);
begin
  ChangeHandPlaybackHandId(-1);
end;


end.

