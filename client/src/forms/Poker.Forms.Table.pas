unit Poker.Forms.Table;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, cxContainer, cxEdit, Poker.Table.Status, Poker.DirectX.Animation, Vectors2,
  Vcl.ActnList, cxLabel, Poker.Table.Tables, cxTextEdit, Vcl.ActnMan, cxSpinEdit, cxCheckBox, Poker.Protobufs.Objects.TableStatus,
  Vectors2px, Poker.Protobufs.Objects.TableEvent, System.Types, RVStyle, RVScroll, RichView, AsphyreImages, IdSync,
  Poker.HandHistory.Items, cxButtons, cxProgressBar, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  ChipUpPokerDarkSkin, Vcl.Menus, Vcl.ImgList, Vcl.PlatformDefaultStyleActnCtrls, Vcl.StdCtrls, cxMaskEdit, dxSkinsCore;

type
  TMouseDownObject = (mdoNone, mdoRaiseSliderButton, mdoActionButton1, mdoActionButton2, mdoActionButton3,
      mdoRaisePresetButton1, mdoRaisePresetButton2, mdoRaisePresetButton3, mdoRaisePresetButton4,
      mdoStandUpButton, mdoPlayNowButton);

  TfrmTable = class;

  TTableSyncRender = class(TIdSync)
  private
    FTable: TfrmTable;
  protected
    procedure DoSynchronize; override;
  public
    class procedure Render(const ATable: TfrmTable);
  end;

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
    tiRender: TTimer;
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
    procedure tiRenderTimer(Sender: TObject);
    procedure seRaiseAmountKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure acHandHistoryExecute(Sender: TObject);
    procedure lbvHandHistoryClick(Sender: TObject);
    procedure tiHandPlaybackTimer(Sender: TObject);
    procedure acHandPlaybackPlayExecute(Sender: TObject);
    procedure acHandPlaybackPauseExecute(Sender: TObject);
    procedure acHandPlaybackStepForwardExecute(Sender: TObject);
    procedure acHandPlaybackStepBackwardsExecute(Sender: TObject);
  private
    const
      FORM_ASPECT_RATIO = 1.35;

    type
      TUIButton = record
        Image: TAsphyreImage;
        Point: TPoint2;
        Action: TAction;
      end;

    var
      FCallbacksId: Integer;
      FTable: TTable;
      FTableStatus: TTableStatus;
      FRaiseValue: UINT32;
      FForceFocused: Boolean;

      FRaisePresetButtonWidth: Single;
      FRaisePresetButtonHeight: Single;
      FPlayNowButtonWidth: Single;
      FPlayNowButtonHeight: Single;
      FActionButtonWidth: Single;
      FActionButtonHeight: Single;
      FActionButtons: TArray<TUIButton>;
      FRaisePresetButtons: TArray<TUIButton>;
      FStandUpButton: TUIButton;
      FPlayNowButton: TUIButton;
      FMouseDownObject: TMouseDownObject;

    procedure SetRaiseSliderValue(const AValue: UINT32; const ASetSpinEditValue: Boolean = TRUE; const AAbsoluteJump: Boolean = TRUE; const AConfigureGUI: Boolean = TRUE);

    procedure EnableGameLockTimer(const ASeconds: Single);
    procedure SetMaxConstraints;
    procedure DisableMaxConstraints;

    procedure AddUserChatMessage(const AUser, AMessage: String);
    procedure AddDealerChatMessage(const AMessage: String);
    procedure ModalFormClose(Sender: TObject);
    procedure CheckChatScrollbackLimit;
    procedure RendererDealerChatMessage(const AMessage: String);
    procedure RendererSoundPlay(const ASound: String);
    procedure RendererTimebankStarted(Sender: TObject);

    function RoundToBB(const AValue: Single): UINT32;

    function AnimateBets(const ABets: TList<UINT32>): Boolean;
    procedure AnimateBlinds;

    procedure UpdateTableCaption;
    procedure UpdateHandHistoryLabel;
    procedure UpdateHandStrength;

    function ConfirmLeaveTable: Boolean;
    function ConfirmStandUp: Boolean;

    function IsPointInUIButtons(const AX, AY: Integer; const AButtons: TArray<TUIButton>; const AButtonWidth, AButtonHeight: Single; out AIndex: Integer): Boolean;

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

    procedure AnimationCallback(const AAnimationPointer: pointer);

  protected
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure WMSizing(var AMessage: TMessage); message WM_SIZING;
    procedure WndProc(var AMessage: TMessage); override;
    procedure WMSysCommand(var Msg: TWMSysCommand); message WM_SYSCOMMAND;

  public
    constructor Create(const ATable: TTable); reintroduce;

    procedure SetTableStatus(const ATableStatus: TPB_TableStatus; const AClearAnimations: Boolean);

    property TableStatus: TTableStatus read FTableStatus;
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, System.TypInfo, {$ENDIF}
  Poker.Server.MessageContainer, Poker.Server.Settings, Poker.Table.Renderer, Poker.DirectX.Timer,
  Poker.Server.MessageCallbacks, Poker.Protobufs.Enum.ServerCodes, Poker.Protobufs.Objects.ChatEvent,
  Poker.Protobufs.Objects.ChatMessage, Poker.Protobufs.Objects.SeatInfo, Poker.Table.Resources, Poker.WindowMessages,
  Poker.DirectX.Core, Poker.Common.FormsContainer, Poker.Server.Socket, Poker.Common.Misc, Poker.Settings,
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
var
  C1: Integer;
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
      rvChat.Visible := FALSE;
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

  SetLength(FActionButtons, 3);
  SetLength(FRaisePresetButtons, 4);
  FStandUpButton.Action := acStandUp;
  FPlayNowButton.Action := acPlayNow;

  for C1 := Low(FActionButtons) to High(FActionButtons) do
    FActionButtons[C1].Image := TableResources.ActionButtonNormalImage;
  for C1 := Low(FRaisePresetButtons) to High(FRaisePresetButtons) do
    FRaisePresetButtons[C1].Image := TableResources.RaisePresetButtonNormalImage;
  FStandUpButton.Image := TableResources.StandUpButtonNormalImage;
  FPlayNowButton.IMage := TableResources.PlayNowButtonNormalImage;

  FMouseDownObject := mdoNone;

  FTableStatus := TTableStatus.Create;

  SetMaxConstraints;

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

  FreeAndNil(FTableStatus);
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

procedure TfrmTable.WMSysCommand(var Msg: TWMSysCommand);
const
  SC_MAXIMIZE2 = $F032;
begin
  case Msg.CmdType of
    SC_RESTORE: SetMaxConstraints;
    SC_MAXIMIZE,
    SC_MAXIMIZE2: DisableMaxConstraints;
  end;

  inherited;
end;

procedure TfrmTable.WndProc(var AMessage: TMessage);
begin
  // prevent ALT key from switching between forms
  if (AMessage.Msg = WM_SYSCOMMAND) and
     (AMessage.WParam = SC_KEYMENU) then
    Exit;

  if AMessage.Msg = WM_DIRECTX_ANIMATION then
    AnimationCallback(pointer(AMessage.WParam));

  inherited;
end;

procedure TfrmTable.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FTable.NotifyClose;
  FTable := nil;
end;

procedure TfrmTable.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmLeaveTable;
end;

procedure TfrmTable.FormResize(Sender: TObject);
begin
  FTable.Renderer.UpdateDXAreaSize;
  ConfigureGUI;
end;

procedure TfrmTable.FormActivate(Sender: TObject);
begin
  DefocusControls;
end;

procedure TfrmTable.FormShow(Sender: TObject);
begin
  FTable.Renderer.OnDealerChatMessage := RendererDealerChatMessage;
  FTable.Renderer.OnSoundPlay := RendererSoundPlay;
  FTable.Renderer.OnTimebankStarted := RendererTimebankStarted;

  FTable.Renderer.UpdateDXAreaSize;

  if FTable.TableType = ttHandPlayback then
  begin
    SetTableStatus(FTable.HandHistoryPlayback.CurrentState, FALSE);
    tiHandPlayback.Enabled := TRUE;
  end
  else
  begin
    ConfigureGUI;
    FTable.Renderer.Render;
  end;
end;

procedure TfrmTable.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  renderit: Boolean;
  index: Integer;
  perc: Single;
  C1: Integer;
begin
  renderit := FALSE;

  DefocusControls;

  if Button = mbLeft then
  begin
    if FMouseDownObject <> mdoNone then
      Exit;

    if (acRaise.Enabled) and
       (FTable.Renderer.Metrics.IsPointInRaiseThumb(X, Y)) then
      FMouseDownObject := mdoRaiseSliderButton
    else
    begin
      if (IsPointInUIButtons(X, Y, FActionButtons, FActionButtonWidth, FActionButtonHeight, index)) and
         (Assigned(FActionButtons[index].Action)) then
      begin
        FMouseDownObject := TMouseDownObject(Integer(mdoActionButton1) + index);
        for C1 := Low(FActionButtons) to High(FActionButtons) do
          if C1 = index then
            FActionButtons[C1].Image := TableResources.ActionButtonPressedImage
          else
            FActionButtons[C1].Image := TableResources.ActionButtonNormalImage;
        renderit := TRUE;
      end
      else
        if (acRaise.Enabled) and
           (IsPointInUIButtons(X, Y, FRaisePresetButtons, FRaisePresetButtonWidth, FRaisePresetButtonHeight, index)) and
           (Assigned(FActionButtons[index].Action)) then
        begin
          FMouseDownObject := TMouseDownObject(Integer(mdoRaisePresetButton1) + index);
          for C1 := Low(FRaisePresetButtons) to High(FRaisePresetButtons) do
            if C1 = index then
              FRaisePresetButtons[C1].Image := TableResources.RaisePresetButtonPressedImage
            else
              FRaisePresetButtons[C1].Image := TableResources.RaisePresetButtonNormalImage;
          renderit := TRUE;
        end
        else
          if (acRaise.Enabled) and
             (FTable.Renderer.Metrics.IsPointInRaiseTrack(X, Y, perc)) then
          begin
            SetRaiseSliderValue(RoundToBB(FTableStatus.MinimumRaise + perc * (FTableStatus.MaximumRaise - FTableStatus.MinimumRaise)), TRUE, FALSE);
            renderit := TRUE;
          end
          else
            if (acStandUp.Enabled) and
               (FTable.Renderer.Metrics.IsPointInStandUpButton(X, Y)) then
            begin
              FStandUpButton.Image := TableResources.StandUpButtonPressedImage;
              FMouseDownObject := mdoStandUpButton;
              renderit := TRUE;
            end
            else
              if (acPlayNow.Enabled) and
                 (PtInRect(Rect(Round(FPlayNowButton.Point.x), Round(FPlayNowButton.Point.y),
                                Round(FPlayNowButton.Point.x + FPlayNowButtonWidth), Round(FPlayNowButton.Point.y + FPlayNowButtonHeight)),
                                Point(X, Y))) then
              begin
                FPlayNowButton.Image := TableResources.PlayNowButtonPressedImage;
                FMouseDownObject := mdoPlayNowButton;
                renderit := TRUE;
              end
    end;
  end;

  if renderit then
    FTable.Renderer.Render;
end;

procedure TfrmTable.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  renderit: Boolean;
  index, C1: Integer;
begin
  renderit := FALSE;
  case FMouseDownObject of
    mdoNone: begin
      if (IsPointInUIButtons(X, Y, FActionButtons, FActionButtonWidth, FActionButtonHeight, index)) and
         (Assigned(FActionButtons[index].Action)) then
      begin
        for C1 := Low(FActionButtons) to High(FActionButtons) do
          if FActionButtons[C1].Image <> TableResources.ActionButtonNormalImage then
          begin
            FActionButtons[C1].Image := TableResources.ActionButtonNormalImage;
            renderit := TRUE;
          end;
      end
      else
        for C1 := Low(FActionButtons) to High(FActionButtons) do
          if FActionButtons[C1].Image <> TableResources.ActionButtonNormalImage then
          begin
            FActionButtons[C1].Image := TableResources.ActionButtonNormalImage;
            renderit := TRUE;
          end;

      if (acRaise.Enabled) and
         (IsPointInUIButtons(X, Y, FRaisePresetButtons, FRaisePresetButtonWidth, FRaisePresetButtonHeight, index)) and
         (Assigned(FRaisePresetButtons[index].Action)) then
      begin
        for C1 := Low(FRaisePresetButtons) to High(FRaisePresetButtons) do
          if FRaisePresetButtons[C1].Image <> TableResources.RaisePresetButtonNormalImage then
          begin
            FRaisePresetButtons[C1].Image := TableResources.RaisePresetButtonNormalImage;
            renderit := TRUE;
          end;
      end
      else
        for C1 := Low(FRaisePresetButtons) to High(FRaisePresetButtons) do
          if FRaisePresetButtons[C1].Image <> TableResources.RaisePresetButtonNormalImage then
          begin
            FRaisePresetButtons[C1].Image := TableResources.RaisePresetButtonNormalImage;
            renderit := TRUE;
          end;

      if (acStandUp.Enabled) and
         (FTable.Renderer.Metrics.IsPointInStandUpButton(X, Y)) then
      begin
//        FStandUpButton.Image := TableResources.StandUpButtonPressedImage;
//        renderit := TRUE;
      end
      else
        if FStandUpButton.Image <> TableResources.StandUpButtonNormalImage then
        begin
          FStandUpButton.Image := TableResources.StandUpButtonNormalImage;
          renderit := TRUE;
        end;

      if (acPlayNow.Enabled) and
         (PtInRect(Rect(Round(FPlayNowButton.Point.x), Round(FPlayNowButton.Point.y),
                        Round(FPlayNowButton.Point.x + FPlayNowButtonWidth), Round(FPlayNowButton.Point.y + FPlayNowButtonHeight)),
                        Point(X, Y))) then
      begin
//        renderit := TRUE;
      end
      else
        if FPlayNowButton.Image <> TableResources.PlayNowButtonNormalImage then
        begin
          FPlayNowButton.Image := TableResources.PlayNowButtonNormalImage;
          renderit := TRUE;
        end;
    end;

    mdoRaiseSliderButton: begin
      if X < FTable.Renderer.Metrics.RaiseTrackBounds.Left then
        SetRaiseSliderValue(FTableStatus.MinimumRaise)
      else
        if X > FTable.Renderer.Metrics.RaiseTrackBounds.Right then
         SetRaiseSliderValue(FTableStatus.MaximumRaise)
        else
          SetRaiseSliderValue(RoundToBB(FTableStatus.MinimumRaise +
              ((X - FTable.Renderer.Metrics.RaiseTrackBounds.Left) / FTable.Renderer.Metrics.RaiseTrackBounds.Width) *
               (FTableStatus.MaximumRaise - FTableStatus.MinimumRaise)));
      renderit := TRUE;
    end;
  end;

  if renderit then
    FTable.Renderer.Render;
end;

procedure TfrmTable.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  index: Integer;
begin
  if FMouseDownObject = mdoNone then
    Exit;

  case FMouseDownObject of
    mdoActionButton1..mdoActionButton3: begin
      if (IsPointInUIButtons(X, Y, FActionButtons, FActionButtonWidth, FActionButtonHeight, index)) and
         (Integer(FMouseDownObject) - Integer(mdoActionButton1) = index) then
      begin
        FActionButtons[index].Image := TableResources.ActionButtonNormalImage;
        if Assigned(FActionButtons[index].Action) then
          FActionButtons[index].Action.Execute;
      end;
    end;

    mdoRaisePresetButton1..mdoRaisePresetButton4: begin
      if (IsPointInUIButtons(X, Y, FRaisePresetButtons, FRaisePresetButtonWidth, FRaisePresetButtonHeight, index)) and
         (Integer(FMouseDownObject) - Integer(mdoRaisePresetButton1) = index) then
      begin
        FRaisePresetButtons[index].Image := TableResources.RaisePresetButtonNormalImage;
        if Assigned(FRaisePresetButtons[index].Action) then
          FRaisePresetButtons[index].Action.Execute;
      end;
    end;

    mdoStandUpButton: begin
      if FTable.Renderer.Metrics.IsPointInStandUpButton(X, Y) then
      begin
        FStandUpButton.Image := TableResources.StandUpButtonNormalImage;
        if acStandUp.Enabled then
          acStandUp.Execute;
      end;
    end;

    mdoPlayNowButton: begin
      if (PtInRect(Rect(Round(FPlayNowButton.Point.x), Round(FPlayNowButton.Point.y),
                        Round(FPlayNowButton.Point.x + FPlayNowButtonWidth), Round(FPlayNowButton.Point.y + FPlayNowButtonHeight)),
                        Point(X, Y))) then
      begin
        FPlayNowButton.Image := TableResources.PlayNowButtonNormalImage;
        if acPlayNow.Enabled then
          acPlayNow.Execute;
      end;
    end;
  end;

  FMouseDownObject := mdoNone;

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
       (not FTableStatus.IsSeatTaken(seat_index))) or
      ((FTable.IsSitting) and
       (FTable.SeatIndex = seat_index) and
       (FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info)) and
       (seat_info.Status in [psOutOfPlay, psOutOfHand]))) then
    FormsContainer.Add(RunModalForm(TfrmTableSit, self, [FTable, FTableStatus, @seat_index], ModalFormClose));
end;

procedure TfrmTable.seRaiseAmountKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = vk_RETURN then
    acRaise.Execute;
end;

procedure TfrmTable.seRaiseAmountPropertiesChange(Sender: TObject);
var
  val    : Single;
  valuint: UINT32;
begin
  if TryStrToFloat(seRaiseAmount.Text, val) then
  begin
    valuint := Round(val * 100);
    if valuint > FTableStatus.MaximumRaise then
      valuint := FTableStatus.MaximumRaise
    else
      if valuint < FTableStatus.MinimumRaise then
        valuint := FTableStatus.MinimumRaise;

    SetRaiseSliderValue(valuint, FALSE);
  end;
end;

procedure TfrmTable.tiActiveFrameBlinkTimer(Sender: TObject);
begin
  if FTableStatus.CurrentSeat = -1 then
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
  FTableStatus.LockTimerEnabled := tiGameLock.Enabled;
  ConfigureGUI;
  FTable.Renderer.Render;
end;

procedure TfrmTable.tiHandPlaybackTimer(Sender: TObject);
begin
  SetTableStatus(FTable.HandHistoryPlayback.NextState, TRUE);

  if FTableStatus.LockTimerEnabled then
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
  if not IsIconic(Handle) then
    FTable.Renderer.Render;
end;

procedure TfrmTable.tiSitOutNextBBTimer(Sender: TObject);
var
  seat_info: TSeatInfo;
begin
  if (FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info)) and
     (seat_info.Status <> psOutOfPlay) then
    ServerSocket.TableSitOutNextBB(FTable.Game.MongoId, cbSitOutNextBB.Checked);

  tiSitOutNextBB.Enabled := FALSE;
end;

procedure TfrmTable.tiSitOutNextHandTimer(Sender: TObject);
var
  seat_info: TSeatInfo;
begin
  if (FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info)) and
     (seat_info.Status <> psOutOfPlay) then
    ServerSocket.TableSitOutNextHand(FTable.Game.MongoId, cbSitOutNextHand.Checked);

  tiSitOutNextHand.Enabled := FALSE;
end;

procedure TfrmTable.UpdateHandHistoryLabel;
var
  hhis: THandHistoryItems;
begin
  if (FTable.TableType <> ttLiveGame) or
     (not HandHistory.FindGame(FTable.GameId, hhis)) or
     (hhis.LastHandId = 0) then
    lbvHandHistory.Visible := FALSE
  else
  begin
    lbvHandHistory.Caption := Format('Previous Hand (#%d)', [hhis.LastHandId]);
    lbvHandHistory.Visible := TRUE;
  end;
end;

procedure TfrmTable.UpdateHandStrength;
var
  seat_info: TSeatInfo;
begin
  if (FTable.IsSitting) and
     (FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info)) and
     (seat_info.Status in [psAllIn, psFolded, psInHand]) and
     (seat_info.CardCount > 0) and
     (seat_info.DealtCards = seat_info.CardCount) then
  begin
    lbvHandStrength.Top := Round(FRaisePresetButtons[High(FRaisePresetButtons)].Point.y - lbvHandStrength.Height - 5);
    if (FTable.Renderer.FlopAnimations.Count = 0) and
       (FTable.Renderer.TurnAnimations.Count = 0) and
       (FTable.Renderer.RiverAnimations.Count = 0) then
      lbvHandStrength.Caption := THandStrengthCalculator.GetHandStrength(seat_info.Cards.AsString, FTableStatus.FlopCards.AsString + FTableStatus.TurnCard.AsString + FTableStatus.RiverCard.AsString, FTableStatus.CurrentGame, TRUE)
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
  if FTable.TableType = ttLiveGame then
  begin
    if FTable.Game.GameType = gtRotationNLHPLO then
    begin
      case FTableStatus.CurrentGame of
        gtHoldem: currentgame := 'NLH';
        gtOmaha: currentgame := 'PLO';
      end;
      rot_index := FTableStatus.RotationHand;
      if rot_index = 0 then
        rot_index := 1;
      cap := Format('%s (%s/%s %s) (%d/%d %s) - %s', [FTable.Game.Name, ChipsToStr(FTable.Game.SmallBlind), ChipsToStr(FTable.Game.BigBlind), FTable.Game.AsString(TRUE), (rot_index - 1) mod FTable.Game.Seats + 1, FTable.Game.Seats, currentgame, FTable.Club.Name])
    end
    else
      cap := Format('%s (%s/%s %s) - %s', [FTable.Game.Name, ChipsToStr(FTable.Game.SmallBlind), ChipsToStr(FTable.Game.BigBlind), FTable.Game.AsString(TRUE), FTable.Club.Name]);
  end
  else
  begin
    if GetHandHistoryItem(hhi) then
    begin
      cap := Format('Hand #%d: %s (%s/%s) - %s', [hhi.HandId, TGameInfo.GameTypeToStr(hhi.CurrentGame, hhi.ParentItems.Game.Limit, FALSE),
               ChipsToStr(hhi.ParentItems.Game.SmallBlind), ChipsToStr(hhi.ParentItems.Game.BigBlind), hhi.StartTimeStr]);
    end
    else
      cap := 'Unknown hand';
  end;

  if cap <> Caption then
    Caption := cap;
end;

function TfrmTable.IsPointInUIButtons(const AX, AY: Integer; const AButtons: TArray<TUIButton>; const AButtonWidth, AButtonHeight: Single; out AIndex: Integer): Boolean;
var
  C1: Integer;
begin
  for C1 := Low(AButtons) to High(AButtons) do
    if (AY >= AButtons[C1].Point.y) and (AY <= AButtons[C1].Point.y + AButtonHeight) and
       (AX >= AButtons[C1].Point.x) and (AX <= AButtons[C1].Point.x + AButtonWidth) then
    begin
      AIndex := C1;
      Exit(TRUE);
    end;
  Exit(FALSE);
end;

procedure TfrmTable.lbvHandHistoryClick(Sender: TObject);
begin
  acHandHistory.Execute;
end;

procedure TfrmTable.ModalFormClose(Sender: TObject);
begin
  EnableWindow(Handle, TRUE);
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
  FTableStatus.LockTimerEnabled := tiGameLock.Enabled;
end;

procedure TfrmTable.acShowCardsExecute(Sender: TObject);
var
  seat: TSeatInfo;
begin
  ServerSocket.ShowCards(FTable.Game.MongoId);
  acShowCards.Enabled := FALSE;
  if FTableStatus.GetSeatInfo(FTable.SeatIndex, seat) then
    seat.CardsVisible := TRUE;
  ConfigureGUI;
  FTable.Renderer.Render;
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
  ConfigureGUI;
  FTable.Renderer.Render;
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
  FTableStatus.UpdateClosingTime(FTable.Game);
  ConfigureGUI;
  FTable.Renderer.Render;
end;

procedure TfrmTable.CSEUserChange(const AMethodId: Integer; const AObject: TObject);
begin
  ConfigureGUI;
  FTable.Renderer.Render;
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
const
  SCROLLBACK_LINES = 100;
begin
  if rvChat.ItemCount >= SCROLLBACK_LINES then
    rvChat.DeleteParas(0, rvChat.ItemCount - SCROLLBACK_LINES + 1);
end;

procedure TfrmTable.ConfigureGUI;
var
  seat_info: TSeatInfo;
  sitout: Boolean;
  foldtoany: Boolean;
  raise_en: Boolean;
  event: TNotifyEvent;
  C1: Integer;
  focus: Boolean;
  fgwin: HWND;
  hround: Integer;
begin
  if WindowState <> wsMaximized then
  begin
    hround := Round(Width / FORM_ASPECT_RATIO);
    if Height <> hround then
      Height := hround;
  end;

  case FTable.TableType of
    ttLiveGame: begin
      rvChat.BoundsRect := FTable.Renderer.Metrics.ChatBoxBounds;
      edChat.BoundsRect := FTable.Renderer.Metrics.ChatEditBounds;
      seRaiseAmount.BoundsRect := FTable.Renderer.Metrics.RaiseAmountBoxBounds;

      cbSitOutNextBB.Top := rvChat.Top + rvChat.Height - cbSitOutNextBB.Height;
      cbSitOutNextHand.Top := cbSitOutNextBB.Top - cbSitOutNextHand.Height;
      cbFoldToAnyBet.Top := cbSitOutNextHand.Top - cbFoldToAnyBet.Height;

      cbFoldToAnyBet.Left := FTable.Renderer.Metrics.CheckboxesLeft;
      cbSitOutNextHand.Left := FTable.Renderer.Metrics.CheckboxesLeft;
      cbSitOutNextBB.Left := FTable.Renderer.Metrics.CheckboxesLeft;

      raise_en := acRaise.Enabled;

      acStandUp.Enabled := FALSE;
      acFold.Enabled := FALSE;
      acCall.Enabled := FALSE;
      acCheck.Enabled := FALSE;
      acRaise.Enabled := FALSE;
      acPlayNow.Enabled := FALSE;
      sitout := FALSE;
      foldtoany := FALSE;

      seat_info := nil;
      if FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info) then
      begin
        acStandUp.Enabled := TRUE;

        case seat_info.Status of
          psOutOfPlay: begin
            acPlayNow.Enabled := TRUE;
            sitout := FALSE;
            foldtoany := FALSE;
          end;

          psOutOfHand: begin
            sitout := TRUE;
            foldtoany := FALSE;
          end;

          psInHand, psAllIn: begin
            sitout := TRUE;
            if (seat_info.Status = psInHand) and
               (FTableStatus.State in [tsPreFlop, tsFlop, tsTurn, tsRiver]) then
              foldtoany := TRUE;

            if (FTableStatus.CurrentSeat = FTable.SeatIndex) and
               (not FTableStatus.Locked) and
               (not FTableStatus.LockTimerEnabled) then
              case FTableStatus.State of
                tsIdle: begin
                  foldtoany := FALSE;
                end;

                tsPreFlop, tsFlop, tsTurn, tsRiver: begin
                  focus := TRUE;
                  acFold.Enabled := TRUE;
                  // check if our current bet is smaller than minimumbet (call/raise situation)
                  if FTableStatus.GetBet(seat_info.SeatIndex) < FTableStatus.MinimumBet then
                  begin
                    // if fold to any bet is checked, fold
                    if cbFoldToAnyBet.Checked then
                    begin
                      focus := FALSE;
                      acFold.Execute;
                    end
                    else // else, configure call/raise options
                    begin
                      if seat_info.Chips <= FTableStatus.MinimumBet then
                        acCall.Caption := 'CALL (ALL-IN)'
                      else
                        acCall.Caption := Format('CALL (%s)', [ChipsToStr(FTableStatus.MinimumBet - FTableStatus.GetBet(seat_info.SeatIndex))]);
                      acCall.Enabled := TRUE;

                      // if we can call, there is a possibility that we can raise too - we check if we can raise here
                      if (seat_info.Chips > FTableStatus.MinimumBet) and
                         (FTableStatus.MinimumBet < FTableStatus.MinimumRaise) then
                      begin
                        acRaise.Tag := 0; // tag 0 = raise
                        acRaise.Enabled := TRUE;
                      end;
                    end;
                  end
                  else // if our current bet isnt smaller than minimum bet, that means its check/raise situation
                  begin
                    acRaise.Tag := 1; // tag 1 = bet
                    acCheck.Enabled := TRUE;
                    acRaise.Enabled := TRUE;

                    if cbFoldToAnyBet.Checked then
                    begin
                      focus := FALSE;
                      acCheck.Execute;
                    end;
                  end;

                  // check if we should focus table
                  if focus then
                  begin
                    // check if table is currently in focus
                    fgwin := GetForegroundWindow;
                    for C1 := 0 to Tables.Count - 1 do
                      if tables[C1].Form.Handle = fgwin then
                      begin
                        focus := FALSE;
                        Break;
                      end;

                    // if its not in focus, focus it
                    // we set FForceFocused to true once table is auto-focused, so we dont refocus it on each ConfigureGUI() call
                    // we reset FForceFocused flag once seatindex changes
                    if (focus) and
                       (not FForceFocused) then
                    begin
                      if IsIconic(Handle) then
                        ShowWindow(Handle, SW_RESTORE);
                      BringToFront;
                      SetForegroundWindow(Handle);
                      SetFocus;
                      FForceFocused := TRUE;

                      // if chat is not focused, focus raise box, otherwise keep chatbox focus
                      if (not edChat.Focused) and
                         (seRaiseAmount.Visible) then
                        seRaiseAmount.SetFocus;

                      TablePlaySound(Sounds.SOUND_TIMEBAR);
                    end;
                  end;
                end;

                tsWinning, tsWinning2: foldtoany := FALSE;
              end
            else
              FForceFocused := FALSE;
          end;

          psFolded: begin
            sitout := TRUE;
            foldtoany := FALSE;
          end;
        end;
      end;

      // check if SHOW CARDS button is enabled
      acShowCards.Enabled := (FTableStatus.State in [tsWinning, tsWinning2]) and
                             (Assigned(seat_info)) and
                             (seat_info.CanShow) and
                             (not seat_info.CardsVisible) and
                             (seat_info.Status in [psFolded, psAllIn, psInHand]);

      if not cbFoldToAnyBet.Visible then
      begin
        event := cbFoldToAnyBet.Properties.OnChange;
        cbFoldToAnyBet.Properties.OnChange := nil;
        cbFoldToAnyBet.Checked := FALSE;
        cbFoldToAnyBet.Properties.OnChange := event;
      end;

      if sitout then
      begin
        cbFoldToAnyBet.Visible := sitout;
        if cbFoldToAnyBet.Visible then
        begin
          cbFoldToAnyBet.Enabled := foldtoany;
          if not cbFoldToAnyBet.Enabled then
            cbFoldToAnyBet.Checked := FALSE;
        end
        else
          cbFoldToAnyBet.Checked := FALSE;

        if not cbSitOutNextHand.Visible then
        begin
          event := cbSitOutNextHand.Properties.OnChange;
          cbSitOutNextHand.Properties.OnChange := nil;
          cbSitOutNextHand.Checked := FALSE;
          cbSitOutNextHand.Properties.OnChange := event;
        end;

        if not cbSitOutNextBB.Visible then
        begin
          event := cbSitOutNextBB.Properties.OnChange;
          cbSitOutNextBB.Properties.OnChange := nil;
          cbSitOutNextBB.Checked := FALSE;
          cbSitOutNextBB.Properties.OnChange := event;
        end;
      end;

      cbFoldToAnyBet.Visible := sitout;
      cbSitOutNextHand.Visible := sitout;
      cbSitOutNextBB.Visible := sitout;

      if acFold.Enabled then
        FActionButtons[0].Action := acFold
      else
        if acShowCards.Enabled then
          FActionButtons[0].Action := acShowCards
        else
          FActionButtons[0].Action := nil;

      if (acCall.Enabled) or (acCheck.Enabled) then
      begin
        if acCall.Enabled then
          FActionButtons[1].Action := acCall
        else
          FActionButtons[1].Action := acCheck;
      end
      else
        FActionButtons[1].Action := nil;

      if acRaise.Enabled then
        FActionButtons[2].Action := acRaise
      else
        FActionButtons[2].Action := nil;

      seRaiseAmount.Visible := acRaise.Enabled;
      acRaiseMin.Enabled := acRaise.Enabled;
      acRaise3BB.Enabled := acRaise.Enabled;
      acRaisePot.Enabled := acRaise.Enabled;
      acRaiseMax.Enabled := acRaise.Enabled;

      if acRaise.Enabled then
      begin
        // if game is pot limit, we dont have to show MAX button, since POT = MAX
        if FTableStatus.CurrentLimit = glPotLimit then
        begin
          FRaisePresetButtons[0].Action := nil;
          FRaisePresetButtons[1].Action := acRaiseMin;
          FRaisePresetButtons[2].Action := acRaise3BB;
          FRaisePresetButtons[3].Action := acRaisePot;
        end
        else
        begin
          FRaisePresetButtons[0].Action := acRaiseMin;
          FRaisePresetButtons[1].Action := acRaise3BB;
          FRaisePresetButtons[2].Action := acRaisePot;
          FRaisePresetButtons[3].Action := acRaiseMax;
        end;

        // if this is first time we enable raise slider, set it to minimum value
        if not raise_en then
          FRaiseValue := FTableStatus.MinimumRaise;

        SetRaiseSliderValue(FRaiseValue, TRUE, TRUE, FALSE);

        // set raise button text
        case acRaise.Tag of
          0: begin
            if FRaiseValue = seat_info.Chips + FTableStatus.GetBet(FTable.SeatIndex) then
               acRaise.Caption := 'RAISE (ALL-IN)'
            else
               acRaise.Caption := Format('RAISE (%s)', [ChipsToStr(FRaiseValue)])
          end;
          1: begin
            if FRaiseValue = seat_info.Chips then
              acRaise.Caption := 'BET (ALL-IN)'
            else
              acRaise.Caption := Format('BET (%s)', [ChipsToStr(FRaiseValue)]);
          end;
        end;
      end
      else
        for C1 := Low(FRaisePresetButtons) to High(FRaisePresetButtons) do
          FRaisePresetButtons[C1].Action := nil;

      // enable seat blink timer, if it's not enabled already
      if (FTableStatus.CurrentSeat <> -1) and
         (not tiActiveFrameBlink.Enabled) and
         (not FTableStatus.Locked) and
         (not FTableStatus.LockTimerEnabled) then
      begin
        tiActiveFrameBlink.Tag := 1;
        tiActiveFrameBlink.Enabled := TRUE;
      end;

      UpdateHandHistoryLabel;
      UpdateHandStrength;
    end;

    ttHandPlayback: begin
      pbHandPlaybackProgress.BoundsRect := FTable.Renderer.Metrics.HandPlaybackProgress;
      btPlayPause.BoundsRect := FTable.Renderer.Metrics.HandPlaybackPlay;
      btStepForward.BoundsRect := FTable.Renderer.Metrics.HandPlaybackForward;
      btStepBackwards.BoundsRect := FTable.Renderer.Metrics.HandPlaybackBack;
    end;
  end;

  UpdateTableCaption;
end;

procedure TfrmTable.tiSeatClearCaptionTimer(Sender: TObject);
var
  seat: TSeatInfo;
begin
  if (FTableStatus.GetSeatInfo(tiSeatCaptionClear.Tag, seat)) and
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
     (FTableStatus.GetSeatInfo(FTable.SeatIndex, seat)) and
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
  FTableStatus.Assign(pbtablestatus);
  FTable.Renderer.UpdateTableStatus(FTableStatus);

  // ActionManager is initially in suspended state, to make sure no actions can be executed while table contains no data
  // this block is executed when first tablestatus is received, and it also enables ActionManager
  if ActionManager.State = asSuspended then
  begin
    ActionManager.State := asNormal;
    for C1 := 0 to FTableStatus.Seats.Count - 1 do
      FTableStatus.Seats[C1].FillDealtCards;

    if FTableStatus.State in [tsFlop, tsTurn, tsRiver, tsWinning, tsWinning2] then
      FTable.Renderer.FlopAnimated := TRUE;
    if FTableStatus.State in [tsTurn, tsRiver, tsWinning, tsWinning2] then
      FTable.Renderer.TurnAnimated := TRUE;
    if FTableStatus.State in [tsRiver, tsWinning, tsWinning2] then
      FTable.Renderer.RiverAnimated := TRUE;
  end;

  // set our SeatIndex to -1 if we stood up OBSOLETE???? FIXME
//  if AMethodId = Integer(srTableStandUpOk) then
//    FTable.SeatIndex := -1;

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
  for seat in FTableStatus.Seats do
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
  tmp := GetEnumName(TypeInfo(TTableState), Integer(FTableStatus.State));
  if pbtablestatus.Locked then
    tmp := tmp + ', LOCKED';
  seatdbg := nil;
  playerdbg := nil;
  tb := 0;
  csdbg := IntToStr(FTableStatus.CurrentSeat);
  if FTableStatus.GetSeatInfo(FTableStatus.CurrentSeat, seatdbg) then
  begin
    if Players.FindPlayerById(seatdbg.PlayerMongoId, playerdbg) then
      csdbg := csdbg + ' - ' + playerdbg.Nick;
    tb := seatdbg.Timebank;
  end;

  tstatusdbg := Format('[#%d] %s, D: %d, E: %d | #%s, %.2fs/%.2fs',
    [pbtablestatus.Seq, tmp, FTableStatus.Dealer, pbtablestatus.Events.Count, csdbg, FTableStatus.Time / 100, tb / 100]);

  events := '';
  for C1 := 0 to pbtablestatus.Events.Count - 1 do
  begin
    pbevent := pbtablestatus.Events[C1];
    if events <> '' then
      events := events + #10;

    seatdbg := nil;
    playerdbg := nil;
    if FTableStatus.GetSeatInfo(pbevent.Seat, seatdbg) then
      Players.FindPlayerById(seatdbg.PlayerMongoId, playerdbg);

    case pbevent.Event of
      teFold: if Assigned(seatdbg) then
        events := events + Format('FOLD [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FTableStatus.Bets[seatdbg.SeatIndex]), ChipsToStr(seatdbg.Chips)])
      else
        events := events + Format('FOLD [#%d]', [pbevent.Seat]);
      teSit: events := events + Format('SIT [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FTableStatus.Bets[seatdbg.SeatIndex]), ChipsToStr(seatdbg.Chips)]);
      teStandUp: events := events + Format('STAND UP [#%d]', [pbevent.Seat]);
      teWinning: events := events + 'WINNING';
      teDealing: events := events + 'DEALING';
      teCheck: events := events + Format('CHECK [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FTableStatus.Bets[seatdbg.SeatIndex]), ChipsToStr(seatdbg.Chips)]);
      teCall: events := events + Format('CALL [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FTableStatus.Bets[seatdbg.SeatIndex]), ChipsToStr(seatdbg.Chips)]);
      teRaise: events := events + Format('RAISE [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FTableStatus.Bets[seatdbg.SeatIndex]), ChipsToStr(seatdbg.Chips)]);
      teAllIn: events := events + Format('ALL-IN [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FTableStatus.Bets[seatdbg.SeatIndex]), ChipsToStr(seatdbg.Chips)]);
      teFlop: events := events + Format('FLOP [%s]', [FTableStatus.FlopCards.AsString]);
      teTurn: events := events + Format('TURN [%s]', [FTableStatus.TurnCard.AsString]);
      teRiver: events := events + Format('RIVER [%s]', [FTableStatus.RiverCard.AsString]);
      tePostRiver: events := events + 'POST RIVER';
      tePreWin: events := events + 'PRE WIN';
      teExistingCards: events := events + Format('EXISTING CARDS [%s]', [TCards.BytesToString(pbevent.Cards)]);
      teDisconnect: events := events + Format('DISCONNECTED [#%d] %s (%s, %s)', [seatdbg.SeatIndex, playerdbg.Nick, ChipsToStr(FTableStatus.Bets[seatdbg.SeatIndex]), ChipsToStr(seatdbg.Chips)]);
    else
      events := events + Format('UNHANDLED EVENT RECEIVED: %s', [GetEnumName(TypeInfo(TTableEventType), Integer(pbevent.Event))]);
    end;
  end;

  DebugLn(tstatusdbg, ditApplication, events);
  {$ENDIF}

  ConfigureGUI;
  FTable.Renderer.Render;
end;

procedure TfrmTable.CSRGetUsers(const AMethodId: Integer; const AObject: TObject);
begin
  ConfigureGUI;
  FTable.Renderer.Render;
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
  seat_point: TPoint2;
  pot: TPB_WinnerPotInfo;
  player: TPlayerInfo;
  C1, C2: Integer;
  card_index: Integer;
  iterate: Boolean;
  nick: String;
  animation: TDXAnimation;
  nicks: String;
  winmsg: String;
  suffix: String;
  total_chips_val: UINT32;
  chips_plural: String;
  cc: Integer;
  flop: TBytes;
begin
  seat_caption := '';
  case ATableEvent.Event of
    teExistingCards: begin
      if Length(ATableEvent.Cards) >= 3 then
      begin
        SetLength(flop, 3);
        for C1 := 0 to 2 do
          flop[C1] := ATableEvent.Cards[C1];
        FTableStatus.FlopCards.Assign(flop);
      end;
      if Length(ATableEvent.Cards) >= 4 then
        FTableStatus.TurnCard.Assign(ATableEvent.Cards[3]);
      if Length(ATableEvent.Cards) >= 5 then
        FTableStatus.RiverCard.Assign(ATableEvent.Cards[4]);
    end;

    teFold: begin
      tiActiveFrameBlink.Enabled := FALSE;
      seat_caption := 'FOLD';
    end;

    teSit: begin
    end;

    teStandUp: begin
      // fixme: animate bet > pot here
    end;

    tePostRiver: begin
      FTableStatus.PreviousBets.Clear;
      FTableStatus.PreviousBets.AddRange(ATableEvent.Bets);
    end;

    teWinning: begin
      EnableGameLockTimer(2 + ATableEvent.Pots.Count * 0.5);

      FTableStatus.Pots.Assign(ATableEvent.Pots);

      if AnimateBets(FTableStatus.PreviousBets) then
        TablePlaySound(Sounds.SOUND_MOVE_CHIPS);

      for C1 := 0 to ATableEvent.Pots.Count - 1 do
      begin
        pot := ATableEvent.Pots[C1];

        if (pot.Sum = 0) or (pot.WinnerData.Count = 0) then
          Continue;

        total_chips_val := pot.Sum - pot.Rake;

        nicks := '';
        animation := nil;
        for C2 := 0 to pot.WinnerData.Count - 1 do
        begin
          if FTableStatus.GetSeatInfo(pot.WinnerData[C2].Seat, seat) then
          begin
            if Players.FindPlayerById(seat.PlayerMongoId, player) then
              nick := player.Nick
            else
              nick := Format('Seat #%d', [seat.SeatIndex]);
          end
          else
            nick := 'Unknown';

          nicks := nicks + Format('%s, ', [nick]);

          animation := DXTimer.AddAnimation(Handle, FTable.Renderer.Metrics.GetPotPoint(C1),
               FTable.Renderer.Metrics.GetBetPoint(pot.WinnerData[C2].Seat, FTableStatus.Dealer), 0.2, FTable.Renderer.WinningAniDelay + 1.5 + C1 * 0.5, 0.5);
          animation.Tag := C1;
          animation.TagUINT := total_chips_val div UINT32(pot.WinnerData.Count);
          FTable.Renderer.PotWinAnimations.Add(animation.Id);
        end;
        Delete(nicks, Length(nicks) - 1, 2);

        chips_plural := '';
        if total_chips_val <> 100 then
          chips_plural := 's';

        suffix := '';
        if pot.WinnerData.Count > 1 then
          suffix := 'each ';

        winmsg := pot.WinnerData[0].Msg;
        if winmsg = 'default' then
          winmsg := ''
        else
          if FTableStatus.GetSeatInfo(pot.WinnerData[0].Seat, seat) then
            winmsg := THandStrengthCalculator.GetHandStrength(seat.Cards.AsString, FTableStatus.FlopCards.AsString + FTableStatus.TurnCard.AsString + FTableStatus.RiverCard.AsString, FTableStatus.CurrentGame, FALSE)
          else
            winmsg := pot.WinnerData[0].Msg;

        if winmsg <> '' then
          winmsg := Format('(%s)', [winmsg]);

        Assert(Assigned(animation));
        animation.TagString := Format('%s won %s chip%s %s%s', [nicks, ChipsToStr(total_chips_val div UINT32(pot.WinnerData.Count)), chips_plural, suffix, winmsg]);
      end;
    end;

    teDealing: begin
      acShowCards.Enabled := FALSE;

      FTable.Renderer.ClearAnimations;
      FTable.Renderer.ChipStackMaker.Clear;

      FTableStatus.FlopCards.Clear;
      FTableStatus.TurnCard.Clear;
      FTableStatus.RiverCard.Clear;

      AnimateBlinds;

      cc := 0;
      card_index := 0;
      repeat
        iterate := FALSE;
        C1 := FTableStatus.SmallBlindSeat;
        if C1 < 0 then
          Break;
        repeat
          if FTableStatus.GetSeatInfo(C1, seat) then
          begin
            seat.ResetDealtCards;
            if seat.CardCount > card_index then
            begin
              seat_point := FTable.Renderer.Metrics.GetSeatPoint(seat.SeatIndex);
              animation := DXTimer.AddAnimation(Handle, Point2(FTable.Renderer.Metrics.TableCenter.x - FTable.Renderer.Metrics.CardWidth / 2, FTable.Renderer.Metrics.TableBounds[0].y),
                                                FTable.Renderer.Metrics.GetCardPoint(seat, card_index), 0.15, 1.5 + FTable.Renderer.DealAnimations.Count * 0.05, 0);
              animation.Tag := seat.SeatIndex;
              Inc(cc);
              if cc mod 2 = 0 then
                animation.TagUINT := 1;
              FTable.Renderer.DealAnimations.Add(animation.Id);
              iterate := TRUE;
            end;
          end;

          Inc(C1);
          if C1 >= FTable.Game.Seats then
            C1 := 0;
        until C1 = FTableStatus.SmallBlindSeat;
        Inc(card_index);
      until not iterate;

      EnableGameLockTimer(1.5 + FTable.Renderer.DealAnimations.Count * 0.05);
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
      FTableStatus.FlopCards.Assign(ATableEvent.Cards);

      tiActiveFrameBlink.Enabled := FALSE;
      EnableGameLockTimer(1.5 + FTable.Renderer.WinningFlopAniDelay);
      if AnimateBets(ATableEvent.Bets) then
        TablePlaySound(Sounds.SOUND_MOVE_CHIPS);
    end;

    teTurn: begin
      FTableStatus.TurnCard.Assign(ATableEvent.Cards);

      tiActiveFrameBlink.Enabled := FALSE;
      EnableGameLockTimer(1.5 + FTable.Renderer.WinningTurnAniDelay);
      if AnimateBets(ATableEvent.Bets) then
        TablePlaySound(Sounds.SOUND_MOVE_CHIPS);
    end;

    teRiver: begin
      FTableStatus.RiverCard.Assign(ATableEvent.Cards);

      tiActiveFrameBlink.Enabled := FALSE;
      EnableGameLockTimer(1.5 + FTable.Renderer.WinningRiverAniDelay);
      if AnimateBets(ATableEvent.Bets) then
        TablePlaySound(Sounds.SOUND_MOVE_CHIPS);
    end;

    teDisconnect: begin
{
      if FTableStatus.GetSeatInfo(ATableEvent.Seat, seat) then
        seat_caption := 'DISCONNECTED';}
    end;
  end;

  if seat_caption <> '' then
  begin
    FTableStatus.Seats.ClearCaptions;
    if FTableStatus.GetSeatInfo(ATableEvent.Seat, seat) then
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
  seat_info  : TSeatInfo;
  seat_bet   : UINT32;
  call_amount: Integer;
begin
  Assert(FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info));
  seat_bet := FTableStatus.GetBet(seat_info.SeatIndex);
  if seat_bet + seat_info.Chips < FTableStatus.MinimumBet then
    call_amount := seat_bet + seat_info.Chips
  else
    call_amount := FTableStatus.MinimumBet;

  ServerSocket.PutChips(FTable.Game.MongoId, call_amount, FTableStatus.State);
end;

procedure TfrmTable.acCheckExecute(Sender: TObject);
begin
  ServerSocket.PutChips(FTable.Game.MongoId, FTableStatus.GetBet(FTable.SeatIndex), FTableStatus.State);
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
  seat  : TSeatInfo;
  sindex: Integer;
begin
  if (FTable.IsSitting) and
     (FTableStatus.GetSeatInfo(FTable.SeatIndex, seat)) and
     (seat.Chips = 0) then
  begin
    sindex := seat.SeatIndex;
    FormsContainer.Add(RunModalForm(TfrmTableSit, self, [FTable, FTableStatus, @sindex], ModalFormClose));
    Exit;
  end;

  ServerSocket.TablePlayNow(FTable.Game.MongoId);
end;

procedure TfrmTable.acRaise3BBExecute(Sender: TObject);
var
  val: UINT32;
begin
  val := FTableStatus.MinimumBet;
  if val = 0 then
    val := FTable.Game.BigBlind;

  SetRaiseSliderValue(val * 3);
end;

procedure TfrmTable.acRaiseMaxExecute(Sender: TObject);
begin
  SetRaiseSliderValue(FTableStatus.MaximumRaise);
end;

procedure TfrmTable.acRaiseMinExecute(Sender: TObject);
begin
  SetRaiseSliderValue(FTableStatus.MinimumRaise);
end;

procedure TfrmTable.acRaiseExecute(Sender: TObject);
begin
  ServerSocket.PutChips(FTable.Game.MongoId, FRaiseValue, FTableStatus.State);
end;

procedure TfrmTable.acRaisePotExecute(Sender: TObject);
var
  C1: Integer;
  raise_value: UINT32;
  seat_bet: UINT32;
begin
  seat_bet := FTableStatus.GetBet(FTable.SeatIndex);

  raise_value := FTableStatus.MinimumBet - seat_bet;
  for C1 := 0 to FTableStatus.Pots.Count - 1 do
    Inc(raise_value, FTableStatus.Pots[C1].ValueWithoutRake);
  for C1 := 0 to FTableStatus.Bets.Count - 1 do
    Inc(raise_value, FTableStatus.Bets[C1]);
  raise_value := raise_value + FTableStatus.MinimumBet;

  SetRaiseSliderValue(raise_value);
end;

procedure TfrmTable.SetTableStatus(const ATableStatus: TPB_TableStatus; const AClearAnimations: Boolean);
begin
  if AClearAnimations then
    FTable.Renderer.ClearAnimations;

  CSRETableStatus(0, ATableStatus);
  if FTable.TableType = ttHandPlayback then
    pbHandPlaybackProgress.Position := FTable.HandHistoryPlayback.CurrentStateIndex;
end;

procedure TfrmTable.SetMaxConstraints;
begin
  Constraints.MaxHeight := 910 + (Height - ClientHeight);
  Constraints.MaxWidth := Round(Constraints.MaxHeight * FORM_ASPECT_RATIO);
end;

procedure TfrmTable.DisableMaxConstraints;
begin
  Constraints.MaxHeight := 0;
  Constraints.MaxWidth := 0;
end;

procedure TfrmTable.SetRaiseSliderValue(const AValue: UINT32; const ASetSpinEditValue: Boolean = TRUE; const AAbsoluteJump: Boolean = TRUE; const AConfigureGUI: Boolean = TRUE);
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
        val := oldval - FTable.Game.SmallBlind;
  end;

  if val > FTableStatus.MaximumRaise then
    val := FTableStatus.MaximumRaise
  else
    if val < FTableStatus.MaximumRaise then
      val := FTableStatus.MaximumRaise;

  FRaiseValue := val;

  if FTableStatus.MaximumRaise = FTableStatus.MinimumRaise then
    FTable.Renderer.RaiseThumbPosition := 1
  else
    FTable.Renderer.RaiseThumbPosition := (val - FTableStatus.MinimumRaise) / (FTableStatus.MaximumRaise - FTableStatus.MinimumRaise);

  if ASetSpinEditValue then
    seRaiseAmount.Value := val / 100;

  if FRaiseValue <> oldval then
  begin
    if AConfigureGUI then
      ConfigureGUI;
    FTable.Renderer.Render;
  end;
end;

procedure TfrmTable.TablePlaySound(const ASound: String);
begin
  if (GetForegroundWindow = Handle) and
     (Settings.Sounds) then
    Sounds.Play(ASound);
end;

function TfrmTable.AnimateBets(const ABets: TList<UINT32>): Boolean;
var
  C1: UINT32;
  bet_point: TPoint2;
  pot_point: TPoint2;
  animation: TDXAnimation;
begin
  result := FALSE;
  if ABets.Count = 0 then
    Exit;

  for C1 := 0 to ABets.Count - 1 do
    if ABets[C1] > 0 then
    begin
      bet_point := FTable.Renderer.Metrics.GetBetPoint(C1, FTableStatus.Dealer);

      pot_point := FTable.Renderer.Metrics.GetPotPoint(0);
      animation := DXTimer.AddAnimation(Handle, bet_point, pot_point, 0.25, 0.2, 0);
      animation.Tag := 1;
      animation.TagUINT := ABets[C1];
      FTable.Renderer.BetAnimations.Add(animation.Id);
      result := TRUE;
    end;
end;

procedure TfrmTable.AnimateBlinds;
var
  bet_point: TPoint2;
  animation: TDXAnimation;
begin
  if (FTableStatus.SmallBlindSeat < 0) or (FTableStatus.SmallBlindSeat > FTableStatus.Bets.Count - 1) or
     (FTableStatus.BigBlindSeat < 0) or (FTableStatus.BigBlindSeat > FTableStatus.Bets.Count - 1) then
    Exit;

  bet_point := FTable.Renderer.Metrics.GetBetPoint(FTableStatus.SmallBlindSeat, FTableStatus.Dealer);
  animation := DXTimer.AddAnimation(Handle, bet_point, bet_point, 0.1, 0.1, 0.9);
  animation.TagUINT := FTableStatus.Bets[FTableStatus.SmallBlindSeat];
  animation.TagSingle := 1;
  FTable.Renderer.BetAnimations.Add(animation.Id);

  bet_point := FTable.Renderer.Metrics.GetBetPoint(FTableStatus.BigBlindSeat, FTableStatus.Dealer);
  animation := DXTimer.AddAnimation(Handle, bet_point, bet_point, 0.1, 0.5, 0.5);
  animation.TagUINT := FTableStatus.Bets[FTableStatus.BigBlindSeat];
  animation.TagSingle := 1;
  FTable.Renderer.BetAnimations.Add(animation.Id);
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
  if FTableStatus.CurrentSeat = FTable.SeatIndex then
    TablePlaySound(Sounds.SOUND_TIMEBANK);
end;

function TfrmTable.RoundToBB(const AValue: Single): UINT32;
begin
  result := Round(AValue / FTable.Game.BigBlind) * FTable.Game.BigBlind;
end;

procedure TfrmTable.AnimationCallback(const AAnimationPointer: pointer);
var
  seat_index: Integer;
  seat: TSeatInfo;
  animation: TDXAnimation;
begin
  if not Assigned(AAnimationPointer) then
  begin
    FTable.Renderer.Render;
    Exit;
  end;

  animation := TDXAnimation(AAnimationPointer);

  if animation.Status = asDone then
  begin
    if FTable.Renderer.FlopAnimations.Contains(animation.Id) then
      FTable.Renderer.FlopAnimations.Remove(animation.Id);
    if FTable.Renderer.TurnAnimations.Contains(animation.Id) then
      FTable.Renderer.TurnAnimations.Remove(animation.Id);
    if FTable.Renderer.RiverAnimations.Contains(animation.Id) then
      FTable.Renderer.RiverAnimations.Remove(animation.Id);
    if FTable.Renderer.BetAnimations.Contains(animation.Id) then
      FTable.Renderer.BetAnimations.Remove(animation.Id);
    if FTable.Renderer.PotWinAnimations.Contains(animation.Id) then
      FTable.Renderer.PotWinAnimations.Remove(animation.Id);
    if FTable.Renderer.DealAnimations.Contains(animation.Id) then
    begin
      seat_index := animation.Tag;
      if FTableStatus.GetSeatInfo(seat_index, seat) then
        seat.IncDealtCards;
      FTable.Renderer.DealAnimations.Remove(animation.Id);
    end;
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

{ TTableSyncRender }

procedure TTableSyncRender.DoSynchronize;
begin
  FTable.FTable.Renderer.Render;
end;

class procedure TTableSyncRender.Render(const ATable: TfrmTable);
begin
  with TTableSyncRender.Create do
  try
    FTable := ATable;
    Synchronize;
  finally
    Free;
  end;
end;

end.

