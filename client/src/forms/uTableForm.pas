unit uTableForm;

{
  ISSUES:
    - teSit happens before player receives TableStatus. Means, if any processing is done in teSit, there would be no info for new player in seat
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, cxMemo,  Vcl.Menus, cxButtons, uTableStatus, uDXTimer, uDXAnimation, Vectors2,
  Vcl.ActnList, cxLabel, uTables, cxTextEdit, dxsChipUpDark, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, dxsChipUpDarkTabs, dxsChipUpRedButton,
  cxMaskEdit, cxSpinEdit, cxTrackBar, cxCheckBox, Vectors2px, uPB_TableEvent, uCards, System.Types, uChipsStackMaker, AsphyreTypes,
  cxCurrencyEdit, RVStyle, RVScroll, RichView, RVEdit, AsphyreImages;

type
  TMouseDownObject = (mdoNone, mdoRaiseSliderButton, mdoActionButton1, mdoActionButton2, mdoActionButton3);

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
    acShowLosingCards: TAction;
    edChat: TcxTextEdit;
    cbFoldToAnyBet: TcxCheckBox;
    cbSitOutNextHand: TcxCheckBox;
    btStandUp: TcxButton;
    cbSitOutNextBB: TcxCheckBox;
    btPlayNow: TcxButton;
    seRaiseAmount: TcxSpinEdit;
    btAction1: TcxButton;
    btAction2: TcxButton;
    btAction3: TcxButton;
    btRaiseMin: TcxButton;
    btRaise3BB: TcxButton;
    btRaisePot: TcxButton;
    btRaiseMax: TcxButton;
    RVStyle: TRVStyle;
    rvChat: TRichView;
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
    procedure acShowLosingCardsExecute(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
  private
    const
      ANIID_FLOP1  = 1;
      ANIID_FLOP2  = 2;
      ANIID_FLOP3  = 3;
      ANIID_FLOP4  = 4;
      ANIID_FLOP5  = 5;
      ANIID_FLOP6  = 6;
      ANIID_TURN   = 7;
      ANIID_RIVER  = 8;

      ANIID_DEALING = 100; // numbers from 100 to 199 are reserved, for dealing cards

      ANIID_BETS    = 200; // numbers from 200 to 219 are reserved, for bets

      CARD_OPEN_PERC   = 0.55;
      CARD_HIDDEN_PERC = 0.35;

    type
      TTableSector = (tsTopLeft, tsTop, tsTopRight, tsRight, tsBottomRight, tsBottom, tsBottomLeft, tsLeft, tsMid);

    var
      FCallbacksId            : Integer;
      FFormAspectRatio        : Single;
      FTableResizeRatio       : Single;
      FRawTableWidth          : Single;
      FRawTableHeight         : Single;
      FRawTableXOffset        : Single;
      FRawTableYOffset        : Single;
      FTableWidth             : Single;
      FTableHeight            : Single;
      FTableXOffset           : Single;
      FTableYOffset           : Single;
      FTableCenter            : TPoint2;
      FDealerPoint            : TPoint2;
      FTableCenterYOffset     : Single;
      FSeatSizeMultiplier     : Single;
      FSeatWidth              : Single;
      FSeatHeight             : Single;
      FSeatCardsMaxWidth      : Single;
      FCardWidth              : Single;
      FCardHeight             : Single;
      FCardArtworkWidth       : Single;
      FCardArtworkHeight      : Single;
      FChipWidth              : Single;
      FChipHeight             : Single;
      FDealerWidth            : Single;
      FDealerHeight           : Single;
      FTimebarWidth           : Single;
      FTimebarHeight          : Single;
      FLowerIntfBorder        : Integer;
      FRaiseSliderWidth       : Single;
      FRaiseSliderHeight      : Single;
      FRaiseSliderPoint       : TPoint2;
      FRaiseSliderResizeRatio : Single;
      FRaiseSliderButtonBounds: TRect;
      FRaiseSliderButtonPoint : TPoint2;
      FRaiseSliderButtonWidth : Single;
      FRaiseSliderButtonHeight: Single;
      FRaiseSliderPosition    : Single;

      FActionButtonWidth      : Single;
      FActionButtonHeight     : Single;
      FActionButton1Point     : TPoint2;
      FActionButton2Point     : TPoint2;
      FActionButton3Point     : TPoint2;

      FActionButton1Image     : TAsphyreImage;
      FActionButton2Image     : TAsphyreImage;
      FActionButton3Image     : TAsphyreImage;
      FActionButton1Action    : TAction;
      FActionButton2Action    : TAction;
      FActionButton3Action    : TAction;

      FDXAreaSize        : TPoint2px;

      FTable             : TTable;
      FTableStatus       : TTableStatus;
      FChipsStackMaker   : TChipsStackMaker;

      FGoalTime          : UINT32;
      FCurrentPlaytime   : Integer;

      FFlopAnimations    : Integer;
      FTurnAnimations    : Integer;
      FRiverAnimations   : Integer;
      FDealAnimations    : Integer;
      FBetAnimations     : Integer;
      FBetAniStacks      : array[0..19] of UINT32;

      FMouseDownObject   : TMouseDownObject;

      FRaiseMin          : UINT32;
      FRaiseMax          : UINT32;
      FRaiseValue        : UINT32;

    procedure SetDXObjectSizes;
    procedure SetRaiseSliderValue(const AValue: UINT32; const ASetSpinEditValue: Boolean = TRUE);

    procedure Render;
    procedure RenderEvent(Sender: TObject);
    procedure RenderBackground;
    procedure RenderTable;
    procedure RenderSeats;
    procedure RenderSeat(const ASeatIndex: Integer);
    procedure RenderCard(const APoint: TPoint2; const ACard: TCard; const APercentage: Single);
    procedure RenderTableCards;
    procedure RenderDealingCardsAni;
    procedure RenderDealerButton;
    procedure RenderBets;
    procedure RenderPots;
    procedure RenderChipStack(const APoint: TPoint2; const AChipStack: TChipsStack);
    procedure RenderTimebar;
    procedure RenderValue(const APoint: TPoint2; const AValue: Single; const AColor: TColor2; const APot: Boolean);
    procedure RenderLowerInterface;

    procedure AddUserChatMessage(const AUser, AMessage: String);
    procedure ModalFormClose(Sender: TObject);

    function RoundToBB(const AValue: Single): UINT32;

    procedure AnimateBets(const ABets: TArray<UINT32>);

    function ConfirmLeaveTable: Boolean;
    function ConfirmStandUp: Boolean;

    function IsPointInActionButtons(const AX, AY: Integer): Integer;

    function GetTableSector(const APoint: TPoint2): TTableSector;
    function GetSeatPoint(const ASeatIndex: Integer): TPoint2;
    function GetCardPoint(const ASeatInfo: TSeatInfo; const ACardIndex: Integer): TPoint2;
    function GetDealerPoint(const ASeatIndex: Integer): TPoint2;
    function GetBetPoint(const ASeatIndex: Integer): TPoint2;
    function GetPotPoint(const APotIndex: Integer): TPoint2;

    procedure CSRChatEvent(const AMethodId: Integer; const AObject: TObject);
    procedure CSRETableStatus(const AMethodId: Integer; const AObject: TObject);
    procedure ProcessTableEvent(const ATableEvent: TPB_TableEvent);

    procedure ConfigureGUI;

    procedure AnimationCallback(const AAnimationPointer: pointer);

  protected
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure WMSizing(var AMessage: TMessage); message WM_SIZING;
    procedure WndProc(var AMessage: TMessage); override;

  public
    constructor Create(const ATable: TTable); reintroduce;
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  cxClasses, System.Math, AsphyreBitmaps, AsphyreJPG, uMessageContainer, uServerSettings, uMessageCallbacks, uServerCodes,
  uPB_ChatEvent, uPB_ChatMessage, uPB_SeatInfo, uTableResources, NativeConnectors, uDXCore, AsphyreFonts, uFormsContainer,
  uSocketClient, uCommon, uTableSitForm, uMainDataModule, uPlayerInfo, uAvatars, uPB_TableStatus, uPB_PotInfo, RVTable;


constructor TfrmTable.Create(const ATable: TTable);
begin
  if not Assigned(TableResources) then
    TTableResources.Initialize(DXCore.Canvas);

  inherited Create(nil);

  ActionManager.State := asSuspended;

  FTable := ATable;
end;

procedure TfrmTable.FormCreate(Sender: TObject);
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(seChat, CSRChatEvent),
                      TServerMessageCallback.Create(seTableStatus, CSRETableStatus),
                      TServerMessageCallback.Create(srTableSitOk, CSRETableStatus),
                      TServerMessageCallback.Create(srTableAddonOk, CSRETableStatus),
                      TServerMessageCallback.Create(srTableStandUpOk, CSRETableStatus)
                  ]);

  FFlopAnimations := -1;
  FTurnAnimations := -1;
  FRiverAnimations := -1;
  FDealAnimations := 0;
  FBetAnimations := 0;
  FillChar(FBetAniStacks[0], Length(FBetAniStacks) * SizeOf(UINT32), 0);

  FMouseDownObject := mdoNone;

  FTableStatus := TTableStatus.Create;
  FChipsStackMaker := TChipsStackMaker.Create;

  FFormAspectRatio := ClientWidth / ClientHeight;

  Constraints.MaxHeight := 910 + (Height - ClientHeight);
  Constraints.MaxWidth := Round(Constraints.MaxHeight * FFormAspectRatio);

  Constraints.MinWidth := 600;
  Constraints.MinHeight := Round(Constraints.MinWidth / FFormAspectRatio);

  rvChat.ClearAll;
  rvChat.Format;

  Caption := Format('%s - %s (%d/%d %s)', [FTable.Club.Name, FTable.Game.Name, Round(FTable.Game.SmallBlind / 100), Round(FTable.Game.BigBlind / 100), FTable.Game.GameTypeStrFull]);
end;

procedure TfrmTable.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);

  DXTimer.RemoveAnimations(Handle);

  FChipsStackMaker.Free;
  FTableStatus.Free;
end;

procedure TfrmTable.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  renderit: Boolean;
begin
  if FMouseDownObject <> mdoNone then
    Exit;

  renderit := FALSE;
  if (acRaise.Enabled) and
     (IsPointInsideCircle(X, Y, FRaiseSliderButtonPoint.x, FRaiseSliderButtonPoint.y, FRaiseSliderButtonWidth / 2)) then
    FMouseDownObject := mdoRaiseSliderButton
  else
    case IsPointInActionButtons(X, Y) of
      1: if Assigned(FActionButton1Action) then
      begin
        FMouseDownObject := mdoActionButton1;
        FActionButton1Image := TableResources.ActionButtonPressedImage;
        FActionButton2Image := TableResources.ActionButtonNormalImage;
        FActionButton3Image := TableResources.ActionButtonNormalImage;
        renderit := TRUE;
      end;

      2: if Assigned(FActionButton2Action) then
      begin
        FMouseDownObject := mdoActionButton2;
        FActionButton1Image := TableResources.ActionButtonNormalImage;
        FActionButton2Image := TableResources.ActionButtonPressedImage;
        FActionButton3Image := TableResources.ActionButtonNormalImage;
        renderit := TRUE;
      end;

      3: if Assigned(FActionButton3Action) then
      begin
        FMouseDownObject := mdoActionButton3;
        FActionButton1Image := TableResources.ActionButtonNormalImage;
        FActionButton2Image := TableResources.ActionButtonNormalImage;
        FActionButton3Image := TableResources.ActionButtonPressedImage;
        renderit := TRUE;
      end;
    end;

  if renderit then
    Render;
end;

procedure TfrmTable.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  renderit: Boolean;
begin
  renderit := FALSE;
  case FMouseDownObject of
    mdoNone: case IsPointInActionButtons(X, Y) of
      1: begin
        FActionButton1Image := TableResources.ActionButtonHotImage;
        FActionButton2Image := TableResources.ActionButtonNormalImage;
        FActionButton3Image := TableResources.ActionButtonNormalImage;
        renderit := TRUE;
      end;

      2: begin
        FActionButton1Image := TableResources.ActionButtonNormalImage;
        FActionButton2Image := TableResources.ActionButtonHotImage;
        FActionButton3Image := TableResources.ActionButtonNormalImage;
        renderit := TRUE;
      end;

      3: begin
        FActionButton1Image := TableResources.ActionButtonNormalImage;
        FActionButton2Image := TableResources.ActionButtonNormalImage;
        FActionButton3Image := TableResources.ActionButtonHotImage;
        renderit := TRUE;
      end;
    else
      if (FActionButton1Image <> TableResources.ActionButtonNormalImage) or
         (FActionButton2Image <> TableResources.ActionButtonNormalImage) or
         (FActionButton3Image <> TableResources.ActionButtonNormalImage) then
      begin
        FActionButton1Image := TableResources.ActionButtonNormalImage;
        FActionButton2Image := TableResources.ActionButtonNormalImage;
        FActionButton3Image := TableResources.ActionButtonNormalImage;
        renderit := TRUE;
      end;
    end;

    mdoRaiseSliderButton: begin
      if X < FRaiseSliderButtonBounds.Left then
        SetRaiseSliderValue(FRaiseMin)
      else
        if X > FRaiseSliderButtonBounds.Right then
         SetRaiseSliderValue(FRaiseMax)
        else
          SetRaiseSliderValue(RoundToBB(FRaiseMin + ((X - FRaiseSliderButtonBounds.Left) / FRaiseSliderButtonBounds.Width) * (FRaiseMax - FRaiseMin)));
      renderit := TRUE;
    end;
  end;

  if renderit then
    Render;
end;

procedure TfrmTable.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  actbt: Integer;
begin
  if FMouseDownObject = mdoNone then
    Exit;

  actbt := -1;
  if FMouseDownObject in [mdoActionButton1, mdoActionButton2, mdoActionButton3] then
    actbt := IsPointInActionButtons(X, Y);

  case FMouseDownObject of
    mdoActionButton1: if actbt = 1 then
    begin
      FActionButton1Image := TableResources.ActionButtonNormalImage;
      if Assigned(FActionButton1Action) then
        FActionButton1Action.Execute;
    end;
    mdoActionButton2: if actbt = 2 then
    begin
      FActionButton2Image := TableResources.ActionButtonNormalImage;
      if Assigned(FActionButton2Action) then
        FActionButton2Action.Execute;
    end;
    mdoActionButton3: if actbt = 3 then
    begin
      FActionButton3Image := TableResources.ActionButtonNormalImage;
      if Assigned(FActionButton3Action) then
        FActionButton3Action.Execute;
    end;
  end;

  FMouseDownObject := mdoNone;

  Render;
end;

procedure TfrmTable.FormPaint(Sender: TObject);
begin
  Render;
end;

procedure TfrmTable.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.ExStyle := AParams.ExStyle or WS_EX_APPWINDOW;
  AParams.WndParent := 0;
end;

procedure TfrmTable.FormActivate(Sender: TObject);
begin
  DefocusControl(edChat, FALSE);
end;

procedure TfrmTable.FormClick(Sender: TObject);
var
  C1               : Integer;
  seat_info        : TSeatInfo;
  client_cursor_pos: TPoint;
  seat_point       : TPoint2;
  seat_rect        : TRectF;
begin
  client_cursor_pos := ScreenToClient(Mouse.CursorPos);

  if edChat.Focused then
    DefocusControl(edChat, FALSE);

  for C1 := 0 to FTable.Game.Seats - 1 do
  begin
    seat_point := GetSeatPoint(C1);
    seat_rect := TRectF.Create(seat_point.X - FSeatWidth / 2, seat_point.Y - FSeatHeight / 2, seat_point.X + FSeatWidth / 2, seat_point.Y + FSeatHeight / 2);
    if (client_cursor_pos.X >= seat_rect.Left) and (client_cursor_pos.X <= seat_rect.Right) and
       (client_cursor_pos.Y >= seat_rect.Top) and (client_cursor_pos.Y <= seat_rect.Bottom) then
    begin
      if ((not FTable.IsSitting) and
          (not FTableStatus.IsSeatTaken(C1))) or
         ((FTable.IsSitting) and
          (FTable.SeatIndex = C1) and
          (FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info)) and
          (seat_info.Status in [psOutOfPlay, psOutOfHand, psFolded])) then
      begin
        FormsContainer.Add(RunModalForm(TfrmTableSit, self, [FTable, FTableStatus, @C1], ModalFormClose));
        Break;
      end;
    end;
  end;
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
  if Height <> Round(Width / FFormAspectRatio) then
    Height := Round(Width / FFormAspectRatio);

  rvChat.Height := ClientHeight div 7;
  rvChat.Width := ClientWidth div 3;
  rvChat.Top := ClientHeight - FLowerIntfBorder - rvChat.Height;
  rvChat.Left := FLowerIntfBorder;

  edChat.Width := rvChat.Width;
  edChat.Top := rvChat.Top - edChat.Height;
  edChat.Left := rvChat.Left;

  btStandUp.Left := rvChat.Left + rvChat.Width + FLowerIntfBorder;
  btStandUp.Top := rvChat.Top + rvChat.Height - btStandUp.Height;

  btAction3.Height := (rvChat.Height + edChat.Height) div 2;
  btAction2.Height := btAction3.Height;
  btAction1.Height := btAction3.Height;

  btAction3.Width := Round((ClientWidth - rvChat.Left - rvChat.Width) / 4.5);
  btAction2.Width := btAction3.Width;
  btAction1.Width := btAction3.Width;

  btAction1.Top := ClientHeight - FLowerIntfBorder - btAction1.Height;
  btAction2.Top := ClientHeight - FLowerIntfBorder - btAction2.Height;
  btAction3.Top := ClientHeight - FLowerIntfBorder - btAction3.Height;

  btAction3.Left := ClientWidth - FLowerIntfBorder - btAction3.Width;
  btAction2.Left := btAction3.Left - FLowerIntfBorder - btAction2.Width;
  btAction1.Left := btAction2.Left - FLowerIntfBorder - btAction1.Width;

  if Assigned(DXCore.Device) then
  begin
    FDXAreaSize := Point2px(ClientWidth, ClientHeight);
    DXCore.Device.Resize(FTable.SwapChainIndex, FDXAreaSize);
    Render;
  end;

  btRaiseMin.Width := Round(FRaiseSliderWidth / 6.5);
  btRaise3BB.Width := btRaiseMin.Width;
  btRaisePot.Width := btRaiseMin.Width;
  btRaiseMax.Width := btRaiseMin.Width;

  btRaiseMin.Height := ClientHeight div 24;
  btRaise3BB.Height := btRaiseMin.Height;
  btRaisePot.Height := btRaiseMin.Height;
  btRaiseMax.Height := btRaiseMin.Height;

  btRaiseMin.Top := Round(FRaiseSliderPoint.y - btRaiseMin.Height - FLowerIntfBorder / 2);
  btRaise3BB.Top := btRaiseMin.Top;
  btRaisePot.Top := btRaiseMin.Top;
  btRaiseMax.Top := btRaiseMin.Top;

  btRaiseMax.Left := Round(FRaiseSliderPoint.x + FRaiseSliderWidth - btRaiseMax.Width);
  btRaisePot.Left := Round(btRaiseMax.Left - FLowerIntfBorder / 2 - btRaisePot.Width);
  btRaise3BB.Left := Round(btRaisePot.Left - FLowerIntfBorder / 2 - btRaise3BB.Width);
  btRaiseMIn.Left := Round(btRaise3BB.Left - FLowerIntfBorder / 2 - btRaiseMin.Width);

  seRaiseAmount.Width := Round(TableResources.RAISE_VALUEBOX_WIDTH * FRaiseSliderResizeRatio);
  seRaiseAmount.Height := Round(TableResources.RAISE_VALUEBOX_HEIGHT * FRaiseSliderResizeRatio);
  seRaiseAmount.Left := Round(FRaiseSliderPoint.x + TableResources.RAISE_VALUEBOX_X * FRaiseSliderResizeRatio);
  seRaiseAmount.Top := Round(FRaiseSliderPoint.y + TableResources.RAISE_VALUEBOX_Y * FRaiseSliderResizeRatio);

  cbFoldToAnyBet.Height := Round(FTableResizeRatio * 28);
  if cbFoldToAnyBet.Height > 18 then
    cbFoldToAnyBet.Height := 18;
  if cbFoldToAnyBet.Height < 14 then
    cbFoldToAnyBet.Height := 14;

  cbSitOutNextHand.Height := cbFoldToAnyBet.Height;
  cbSitOutNextBB.Height := cbFoldToAnyBet.Height;

  cbFoldToAnyBet.Top := edChat.Top;
  cbSitOutNextHand.Top := cbFoldToAnyBet.Top + cbFoldToAnyBet.Height;
  cbSitOutNextBB.Top := cbSitOutNextHand.Top + cbSitOutNextHand.Height;

  cbFoldToAnyBet.Left := btStandUp.Left;
  cbSitOutNextHand.Left := btStandUp.Left;
  cbSitOutNextBB.Left := btStandUp.Left;

  btPlayNow.Top := edChat.Top;
  btPlayNow.Left := btStandUp.Left;
end;

procedure TfrmTable.WMSizing(var AMessage: TMessage);
begin
  inherited;

  case AMessage.wParam of
    WMSZ_LEFT, WMSZ_RIGHT, WMSZ_BOTTOMLEFT: with PRect(AMessage.LParam)^ do Bottom := Top + Round((Right - Left) / FFormAspectRatio);
    WMSZ_TOP, WMSZ_BOTTOM, WMSZ_TOPRIGHT, WMSZ_BOTTOMRIGHT: with PRect(AMessage.LParam)^ do Right := Left + Round((Bottom - Top) * FFormAspectRatio);
    WMSZ_TOPLEFT: with PRect(AMessage.LParam)^ do Top := Bottom - Round((Right - Left) / FFormAspectRatio);
  end;
end;

procedure TfrmTable.WndProc(var AMessage: TMessage);
begin
  // prevent ALT key from switching between forms
  if (AMessage.Msg = WM_SYSCOMMAND) and
     (AMessage.WParam = SC_KEYMENU) then
    Exit;

  if AMessage.Msg = DXTimer.AnimationMessage then
    AnimationCallback(pointer(AMessage.WParam));

  inherited;
end;

procedure TfrmTable.seRaiseAmountPropertiesChange(Sender: TObject);
var
  val    : Single;
  valuint: UINT32;
begin
  if TryStrToFloat(seRaiseAmount.Text, val) then
  begin
    valuint := Round(val * 100);
    if valuint > FRaiseMax then
      valuint := FRaiseMax
    else
      if valuint < FRaiseMin then
        valuint := FRaiseMin;

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

  Render;
end;

procedure TfrmTable.tiSitOutNextBBTimer(Sender: TObject);
var
  seat_info: TSeatInfo;
begin
  if (FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info)) and
     (seat_info.Status <> psOutOfPlay) then
    SocketClient.TableSitOutNextBB(FTable.Game.MongoId, cbSitOutNextBB.Checked);

  tiSitOutNextBB.Enabled := FALSE;
end;

procedure TfrmTable.tiSitOutNextHandTimer(Sender: TObject);
var
  seat_info: TSeatInfo;
begin
  if (FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info)) and
     (seat_info.Status <> psOutOfPlay) then
    SocketClient.TableSitOutNextHand(FTable.Game.MongoId, cbSitOutNextHand.Checked);

  tiSitOutNextHand.Enabled := FALSE;
end;

function TfrmTable.GetSeatPoint(const ASeatIndex: Integer): TPoint2;
var
  seat_radians: Double;
  x, y        : Single;
  pf          : TPointF;
begin
  seat_radians := TTableResources.SEAT_POINTS[FTable.Game.Seats, ASeatIndex];

  x := FTableCenter.X + (FTableWidth / 2) * Cos(seat_radians);
  y := FTableCenter.Y - FTableCenterYOffset + (FTableHeight / 2) * Sin(seat_radians);

  pf := PointF(x, y);

  case GetTableSector(Point2(x, y)) of
    tsTopLeft: pf.Offset(-FSeatWidth / 2.3, -FSeatHeight / 4.5);
    tsLeft: pf.Offset(-FSeatWidth / 2.5, 0);
    tsBottomLeft: pf.Offset(-FSeatWidth / 2.3, -FSeatHeight / 5);
    tsBottom: pf.Offset(0, 0);
    tsBottomRight: pf.Offset(FSeatWidth / 2.3, -FSeatHeight / 5);
    tsRight: pf.Offset(FSeatWidth / 2.5, 0);
    tsTopRight: pf.Offset(FSeatWidth / 2.3, -FSeatHeight / 4.5);
    tsTop: pf.Offset(0, 0);
  end;

  result.x := pf.x;
  result.y := pf.y;
end;

function TfrmTable.GetTableSector(const APoint: TPoint2): TTableSector;
var
  points: array[0..3] of TPoint2;
begin
  points[0] := Point2(FTableCenter.X - FSeatWidth / 2, FTableCenter.Y - FSeatHeight / 2);
  points[1] := Point2(FTableCenter.X + FSeatWidth / 2, FTableCenter.Y - FSeatHeight / 2);
  points[2] := Point2(FTableCenter.X - FSeatWidth / 2, FTableCenter.Y + FSeatHeight / 2);
  points[3] := Point2(FTableCenter.X + FSeatWidth / 2, FTableCenter.Y + FSeatHeight / 2);

  if APoint.X < points[0].X then
  begin
    if APoint.Y < points[0].y then
      result := tsTopLeft
    else
      if APoint.Y > points[2].y then
        result := tsBottomLeft
      else
        result := tsLeft
  end
  else
    if APoint.X > points[1].X then
    begin
      if APoint.Y < points[0].y then
        result := tsTopRight
      else
        if APoint.Y > points[2].y then
          result := tsBottomRight
        else
          result := tsRight
    end
    else
      if APoint.Y < points[0].y then
        result := tsTop
      else
        if APoint.Y > points[2].y then
          result := tsBottom
        else
          result := tsMid;
end;

function TfrmTable.IsPointInActionButtons(const AX, AY: Integer): Integer;
begin
  if (AY < FActionButton1Point.y) or (AY > FActionButton1Point.y + FActionButtonHeight) then
    Exit(-1);
  if (AX >= FActionButton1Point.x) and (AX <= FActionButton1Point.x + FActionButtonWidth) then
    Exit(1);
  if (AX >= FActionButton2Point.x) and (AX <= FActionButton2Point.x + FActionButtonWidth) then
    Exit(2);
  if (AX >= FActionButton3Point.x) and (AX <= FActionButton3Point.x + FActionButtonWidth) then
    Exit(3);
  Exit(-1);
end;

procedure TfrmTable.ModalFormClose(Sender: TObject);
begin
  EnableWindow(Handle, TRUE);
end;

function TfrmTable.GetDealerPoint(const ASeatIndex: Integer): TPoint2;
var
  seat_radians: Double;
  x, y        : Single;
  xr, yr      : Single;
begin
  xr := FTableWidth / 1.19;
  yr := FTableHeight / 1.35;

  seat_radians := TTableResources.SEAT_POINTS[FTable.Game.Seats, ASeatIndex];
  x := FTableCenter.X + (xr / 2) * Cos(seat_radians);
  y := FTableCenter.Y - FTableCenterYOffset + (yr / 2) * Sin(seat_radians) - 17 * FTableResizeRatio;
  result := Point2(x, y);
end;

function TfrmTable.GetBetPoint(const ASeatIndex: Integer): TPoint2;
var
  seat_radians: Double;
  x, y        : Single;
  xr, yr      : Single;
begin
  if FTableStatus.Dealer = ASeatIndex then
  begin
    xr := FTableWidth / 1.45;
    yr := FTableHeight / 1.90;
  end
  else
  begin
    xr := FTableWidth / 1.2;
    yr := FTableHeight / 1.5;
  end;

  seat_radians := TTableResources.SEAT_POINTS[FTable.Game.Seats, ASeatIndex];
  x := FTableCenter.X + (xr / 2) * Cos(seat_radians);
  y := FTableCenter.Y - FTableCenterYOffset + (yr / 2) * Sin(seat_radians) - 27 * FTableResizeRatio;
  result := Point2(x, y);
end;


function TfrmTable.GetCardPoint(const ASeatInfo: TSeatInfo; const ACardIndex: Integer): TPoint2;
var
  seat_point         : TPoint2;
  cards_width        : Single;
  cards_overlap_width: Single;
  cards_starting_x   : Single;
  perc               : Single;
begin
  seat_point := GetSeatPoint(ASeatInfo.SeatIndex);
  cards_width := ASeatInfo.CardCount * FCardWidth;
  if (cards_width > FSeatCardsMaxWidth) and
     (ASeatInfo.CardCount > 1) then
  begin
    cards_overlap_width := (cards_width - FSeatCardsMaxWidth) / (ASeatInfo.CardCount - 1);
    cards_starting_x := seat_point.X - FSeatCardsMaxWidth / 2;
  end
  else
  begin
    cards_overlap_width := 1;
    cards_starting_x := seat_point.X - (ASeatInfo.CardCount * (FCardWidth + cards_overlap_width) - 1) / 2;
  end;

  if (ACardIndex >= 0) and (ACardIndex < ASeatInfo.Cards.Count) then
    perc := CARD_OPEN_PERC
  else
    perc := CARD_HIDDEN_PERC;

  result := Point2(cards_starting_x + ACardIndex * (FCardWidth - cards_overlap_width), seat_point.Y - FSeatHeight / 2 - FCardHeight * perc);
end;

function TfrmTable.GetPotPoint(const APotIndex: Integer): TPoint2;
var
  topy, bottomy: Integer;
begin
  topy := Round(FTableCenter.Y - FCardHeight - FTableResizeRatio * 10);
  bottomy := Round(FTableCenter.Y + FCardHeight + FTableResizeRatio * 16);
  case APotIndex of
    0: result := Point2(FTableCenter.X, topy);
    1: result := Point2(FTableCenter.X + 40, topy);
    2: result := Point2(FTableCenter.X - 40, topy);
    3: result := Point2(FTableCenter.X - 40, bottomy);
    4: result := Point2(FTableCenter.X + 40, bottomy);
  else
    result := Point2(-1, -1);
  end;
end;

procedure TfrmTable.edChatKeyPress(Sender: TObject; var Key: Char);
begin
  case Ord(Key) of
    VK_RETURN: begin
      if edChat.Text <> '' then
      begin
        if Trim(edChat.Text) <> '' then
          SocketClient.SendTableChatLine(FTable.Game.MongoId, Trim(edChat.Text));
        edChat.Clear;
      end;
      Key := #0;
    end;
  end;
end;

procedure TfrmTable.acShowLosingCardsExecute(Sender: TObject);
begin
  SocketClient.ShowLosingCards(FTable.Game.MongoId);
end;

procedure TfrmTable.acStandUpExecute(Sender: TObject);
begin
  if not ConfirmStandUp then
    Exit;

  SocketClient.TableStandUp(FTable.Game.MongoId);
  acStandUp.Enabled := FALSE;
end;

procedure TfrmTable.AddUserChatMessage(const AUser, AMessage: String);
begin
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

procedure TfrmTable.CSRChatEvent(const AMethodId: Integer; const AObject: TObject);
var
  chat_event  : TPB_ChatEvent;
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

procedure TfrmTable.ConfigureGUI;
var
  seat_info: TSeatInfo;
  sitout : Boolean;
  foldtoany: Boolean;
  seat_bet : Integer;
  event    : TNotifyEvent;
begin
  acStandUp.Enabled := FALSE;
  acFold.Enabled := FALSE;
  acCall.Enabled := FALSE;
  acCheck.Enabled := FALSE;
  acRaise.Enabled := FALSE;
  acPlayNow.Enabled := FALSE;
  acShowLosingCards.Enabled := FALSE;
  sitout := FALSE;
  foldtoany := FALSE;

  if FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info) then
  begin
    acStandUp.Enabled := TRUE;
    seat_bet := FTableStatus.GetBet(FTable.SeatIndex);

    case seat_info.Status of
      psOutOfPlay: begin
        acPlayNow.Enabled := TRUE;
      end;
      psOutOfHand: begin
        sitout := TRUE;
      end;
      psInHand: begin
        sitout := TRUE;
        foldtoany := TRUE;
        if (FTableStatus.CurrentSeat = FTable.SeatIndex) and
           (not FTableStatus.Locked) then
          case FTableStatus.State of
            tsIdle: ;
            tsPreFlop,
            tsFlopping,
            tsFlop,
            tsTurning,
            tsTurn,
            tsRiverTime,
            tsRiver: begin
              acFold.Enabled := TRUE;
              if seat_bet < FTableStatus.MinimumBet then
              begin
                if seat_info.Chips + seat_bet <= FTableStatus.MinimumBet then
                  acCall.Caption := 'CALL (ALL-IN)'
                else
                  acCall.Caption := Format('CALL (%s)', [FormatFloat('0.##', (FTableStatus.MinimumBet - seat_bet) / 100)]);
                acCall.Enabled := TRUE;

                if seat_info.Chips + seat_bet > FTableStatus.MinimumBet then
                begin
                  acRaise.Caption := 'RAISE';
                  acRaise.Enabled := TRUE;
                end;

                if cbFoldToAnyBet.Checked then
                  acFold.Execute;
              end
              else
              begin
                acCheck.Enabled := TRUE;
                acRaise.Caption := 'BET';
                acRaise.Enabled := TRUE;

                if cbFoldToAnyBet.Checked then
                  acCheck.Execute;
              end;
            end;
            tsWinning,
            tsWinning2: ;
          end;

        if (FtableStatus.State in [tsWinning, tsWinning2]) and
           (FTable.SeatIndex = seat_info.SeatIndex) and
           (seat_info.Status in [psInHand, psAllIn]) then
          acShowLosingCards.Enabled := TRUE;
      end;
      psFolded: begin
        sitout := TRUE;
      end;
      psAllIn: begin
        sitout := TRUE;
      end;
    end;
  end;

  if (FTableStatus.CurrentSeat <> -1) and
     (not tiActiveFrameBlink.Enabled) and
     (not FTableStatus.Locked) then
  begin
    tiActiveFrameBlink.Tag := 1;
    tiActiveFrameBlink.Enabled := TRUE;
  end;

  if sitout then
  begin
    if not cbFoldToAnyBet.Visible then
    begin
      event := cbFoldToAnyBet.Properties.OnChange;
      cbFoldToAnyBet.Properties.OnChange := nil;
      cbFoldToAnyBet.Checked := FALSE;
      cbFoldToAnyBet.Properties.OnChange := event;
    end;

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
  if cbFoldToAnyBet.Visible then
    cbFoldToAnyBet.Enabled := foldtoany;

  cbSitOutNextHand.Visible := sitout;
  cbSitOutNextBB.Visible := sitout;

  if btStandUp.Visible <> acStandUp.Enabled then
    btStandUp.Visible := acStandUp.Enabled;
  if btPlayNow.Visible <> acPlayNow.Enabled then
    btPlayNow.Visible := acPlayNow.Enabled;

  if acFold.Enabled then
    FActionButton1Action := acFold
  else
    if acShowLosingCards.Enabled then
      FActionButton1Action := acShowLosingCards
    else
      FActionButton1Action := nil;

  if (acCall.Enabled) or (acCheck.Enabled) then
  begin
    if acCall.Enabled then
      FActionButton2Action := acCall
    else
      FActionButton2Action := acCheck;
  end
  else
    FActionButton2Action := nil;

  if acRaise.Enabled then
    FActionButton3Action := acRaise
  else
    FActionButton3Action := nil;

  seRaiseAmount.Visible := acRaise.Enabled;
  btRaiseMin.Visible := acRaise.Enabled;
  btRaise3BB.Visible := acRaise.Enabled;
  btRaisePot.Visible := acRaise.Enabled;
  btRaiseMax.Visible := acRaise.Enabled;

  if acRaise.Enabled then
  begin
    Assert(FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info));

    FRaiseMin := FTableStatus.MinimumBet + FTable.Game.BigBlind;
    FRaiseMax := FTableStatus.MaximumBet;

    seRaiseAmount.Properties.MaxValue := FRaiseMax / 100;

    SetRaiseSliderValue(FRaiseMin);
  end;
end;

procedure TfrmTable.tiSeatClearCaptionTimer(Sender: TObject);
var
  seat: TSeatInfo;
begin
  if FTableStatus.GetSeatInfo(tiSeatCaptionClear.Tag, seat) then
    seat.Caption := '';

  tiSeatCaptionClear.Enabled := FALSE;
end;

function TfrmTable.ConfirmLeaveTable: Boolean;
begin
  result := TRUE;
  if FTable.IsSitting then
    result := MessageDlg('Are you sure you want to leave the table? This will automatically fold your current hand and any chips that are in the pot.', mtWarning, mbYesNo, 0) = mrYes;
end;

function TfrmTable.ConfirmStandUp: Boolean;
var
  seat: TSeatInfo;
begin
  result := TRUE;
  if (FTable.IsSitting) and
     (FTableStatus.GetSeatInfo(FTable.SeatIndex, seat)) and
     (seat.Status in [psOutOfHand, psInHand, psFolded, psAllIn]) then
    result := MessageDlg('Are you sure you want to stand up? This will automatically fold your current hand and any chips that are in the pot.', mtWarning, mbYesNo, 0) = mrYes;
end;

procedure TfrmTable.CSRETableStatus(const AMethodId: Integer; const AObject: TObject);
var
  pbtablestatus: TPB_TableStatus;
  C1           : Integer;
  tmp          : String;
  seat_index   : Integer;
  seat         : TSeatInfo;
  tb           : UINT32;
begin
  pbtablestatus := AObject as TPB_TableStatus;
  if not CompareBytes(pbtablestatus.TableMongoId, FTable.Game.MongoId) then
    Exit;

  FTableStatus.Assign(pbtablestatus);

  if ActionManager.State = asSuspended then
  begin
    ActionManager.State := asNormal;
    for C1 := 0 to FTableStatus.Seats.Count - 1 do
      FTableStatus.Seats[C1].FillDealtCards;

    if FTableStatus.State in [tsFlop, tsTurning, tsTurn, tsRiverTime, tsRiver, tsWinning, tsWinning2] then
      FFlopAnimations := 6;
    if FTableStatus.State in [tsTurn, tsRiverTime, tsRiver, tsWinning, tsWinning2] then
      FTurnAnimations := 1;
    if FTableStatus.State in [tsRiver, tsWinning, tsWinning2] then
      FRiverAnimations := 1;
  end;

  case AMethodId of
    Integer(srTableStandUpOk): FTable.SeatIndex := -1;
  end;

  seat_index := -1;
  for C1 := 0 to pbtablestatus.Seats.Count - 1 do
    if CompareBytes(pbtablestatus.Seats[C1].PlayerMongoId, dmMain.SelfInfo.Id) then
    begin
      seat_index := pbtablestatus.Seats[C1].Seat;
      Break;
    end;
  FTable.SeatIndex := seat_index;

  if FTableStatus.Time > 0 then
    FGoalTime := FTableStatus.Time - SocketClient.TimeOffset
  else
    FGoalTime := 0;

  {$IFDEF DEBUG}
  tmp := '';
  if pbtablestatus.Locked then
  begin
    tmp := 'YES';
  end
  else tmp := 'NO';

  tb := 0;
  if FTableStatus.GetSeatInfo(FTableStatus.CurrentSeat, seat) then
    tb := seat.Timebank;

  DebugLn(Format('D: %d; TS: %d; CS: %d; TIME: %d; TB: %d; SEQ:%d; LOCKED: %s', [FTableStatus.Dealer, Integer(FTableStatus.State), FTableStatus.CurrentSeat, FTableStatus.Time, tb, pbtablestatus.Seq, tmp]), ditApplication);
  {$ENDIF}

  for C1 := 0 to pbtablestatus.Events.Count - 1 do
    ProcessTableEvent(pbtablestatus.Events[C1]);

  ConfigureGUI;
  Render;
end;

procedure TfrmTable.ProcessTableEvent(const ATableEvent: TPB_TableEvent);
var
  event       : String;
  seat_caption: String;
  seat        : TSeatInfo;
  seat_point  : TPoint2;
  seat_index  : Integer;
  pot         : TPB_PotInfo;
  player      : TPlayerInfo;
  C1, C2      : Integer;
  tmpstr      : String;
  card_index  : Integer;
  iterate     : Boolean;
begin
  FTableStatus.Assign(ATableEvent);

  seat_caption := '';
  case ATableEvent.Event of
    teFold: begin
      tiActiveFrameBlink.Enabled := FALSE;
      event := 'FOLD';
      seat_caption := 'Fold';
    end;
    teSit: event := 'SIT';
    teStandUp: event := 'STAND UP';
    teWinning: begin
      event := 'WINNING';
      for C1 := 0 to ATableEvent.Pots.Count - 1 do
      begin
        pot := ATableEvent.Pots[C1];

        if (pot.Sum = 0) or (pot.WinnerData.Count = 0) then
          Continue;

        tmpstr := Format('[%.2f chips, %.2f each], won by: ', [pot.Sum / 100, (pot.Sum / 100) / pot.WinnerData.Count]);

        for C2 := 0 to pot.WinnerData.Count - 1 do
        begin
          if FTableStatus.GetSeatInfo(pot.WinnerData[C2].Seat, seat) then
          begin
            if dmMain.Players.FindPlayerById(seat.PlayerMongoId, player) then
              tmpstr := tmpstr + player.Nick
            else
              tmpstr := tmpstr + '#' + IntToStr(seat.SeatIndex)
          end
          else
            tmpstr := tmpstr + 'UNKNOWN';

          tmpstr := tmpstr + Format(' (%s)', [pot.WinnerData[C2].Msg]);

          if C2 < pot.WinnerData.Count - 1 then
            tmpstr := tmpstr + ', ';
        end;

        AddUserChatMessage(Format('POT [%d]', [C1]), tmpstr);
      end;
    end;
    teDealing: begin
      event := 'DEALING';
      FFlopAnimations := -1;
      FTurnAnimations := -1;
      FRiverAnimations := -1;
      FDealAnimations := 0;
      FBetAnimations := 0;
      FillChar(FBetAniStacks[0], Length(FBetAniStacks) * SizeOf(UINT32), 0);
      FChipsStackMaker.Clear;

      card_index := 0;
      repeat
        iterate := FALSE;
        for C1 := 0 to FTableStatus.Seats.Count - 1 do
        begin
          seat := FTableStatus.Seats[C1];
          seat.ResetDealtCards;
          if seat.CardCount > card_index then
          begin
            seat_point := GetSeatPoint(seat.SeatIndex);
            DXTimer.AddAnimation(Handle, ANIID_DEALING + seat.SeatIndex * 10 + card_index,
                 Point2(FTableCenter.x - FCardWidth / 2, FTableYOffset),
                 GetCardPoint(seat, card_index), 0.15, FDealAnimations * 0.05);
            Inc(FDealAnimations);
            iterate := TRUE;
          end;
        end;
        Inc(card_index);
      until not iterate;
    end;
    teCheck: begin
      tiActiveFrameBlink.Enabled := FALSE;
      event := 'CHECK';
      seat_caption := 'Check';
    end;
    teCall: begin
      tiActiveFrameBlink.Enabled := FALSE;
      event := 'CALL';
      seat_caption := 'Call';
    end;
    teRaise: begin
      tiActiveFrameBlink.Enabled := FALSE;
      event := 'RAISE';
      seat_caption := 'Raise';
    end;
    teAllIn: begin
      tiActiveFrameBlink.Enabled := FALSE;
      event := 'ALL-IN';
      seat_caption := 'All-In';
    end;
    teFlop: begin
      tiActiveFrameBlink.Enabled := FALSE;
      event := 'FLOP';
      AnimateBets(ATableEvent.Bets);
    end;
    teTurn: begin
      tiActiveFrameBlink.Enabled := FALSE;
      event := 'TURN';
      AnimateBets(ATableEvent.Bets);
    end;
    teRiver: begin
      tiActiveFrameBlink.Enabled := FALSE;
      event := 'RIVER';
      AnimateBets(ATableEvent.Bets);
    end;
  end;

  if seat_caption <> '' then
  begin
    FTableStatus.Seats.ClearCaptions;
    seat_index := ATableEvent.Seat;
    if FTableStatus.GetSeatInfo(seat_index, seat) then
    begin
      seat.Caption := seat_caption;
      tiSeatCaptionClear.Enabled := FALSE;
      tiSeatCaptionClear.Tag := seat.SeatIndex;
      tiSeatCaptionClear.Enabled := TRUE;
    end;
  end;

  {$IFDEF DEBUG}
  DebugLn('Event received: ' + event, ditApplication);
  {$ENDIF}
end;

procedure TfrmTable.acCallExecute(Sender: TObject);
var
  seat_info  : TSeatInfo;
  seat_bet   : Integer;
  call_amount: Integer;
begin
  Assert(FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info));
  seat_bet := FTableStatus.GetBet(seat_info.SeatIndex);
  if seat_bet + seat_info.Chips < FTableStatus.MinimumBet then
    call_amount := seat_bet + seat_info.Chips
  else
    call_amount := FTableStatus.MinimumBet;

  SocketClient.PutChips(FTable.Game.MongoId, call_amount);
end;

procedure TfrmTable.acCheckExecute(Sender: TObject);
begin
  SocketClient.PutChips(FTable.Game.MongoId, FTableStatus.GetBet(FTable.SeatIndex));
end;

procedure TfrmTable.acFoldExecute(Sender: TObject);
begin
  SocketClient.Fold(FTable.Game.MongoId);
end;

procedure TfrmTable.acPlayNowExecute(Sender: TObject);
begin
  SocketClient.TablePlayNow(FTable.Game.MongoId);
end;

procedure TfrmTable.acRaise3BBExecute(Sender: TObject);
begin
  SetRaiseSliderValue(FTable.Game.BigBlind * 3);
end;

procedure TfrmTable.acRaiseMaxExecute(Sender: TObject);
begin
  SetRaiseSliderValue(FRaiseMax);
end;

procedure TfrmTable.acRaiseMinExecute(Sender: TObject);
begin
  SetRaiseSliderValue(FRaiseMin);
end;

procedure TfrmTable.acRaiseExecute(Sender: TObject);
begin
  SocketClient.PutChips(FTable.Game.MongoId, FRaiseValue);
end;


procedure TfrmTable.acRaisePotExecute(Sender: TObject);
var
  C1         : Integer;
  raise_value: UINT32;
begin
  raise_value := 0;
  for C1 := 0 to FTableStatus.Pots.Count - 1 do
    raise_value := raise_value + FTableStatus.Pots[C1].Value;

  SetRaiseSliderValue(raise_value);
end;

procedure TfrmTable.Render;
begin
  if not NativeAsphyreConnect.Init() then
    Exit;

  if (Assigned(DXCore.Device)) and
     (DXCore.Device.IsAtFault()) then
  begin
    Close;
    Exit;
  end;

  if (not Assigned(DXCore.Device)) or
     (not DXCore.Device.Connect()) then
    Exit;

  DXCore.Device.Render(FTable.SwapChainIndex, RenderEvent, 0);
end;

procedure TfrmTable.SetDXObjectSizes;
const
  TABLE_X_LEFT        = 64;
  TABLE_X_RIGHT       = 64;
  TABLE_Y_TOP         = 66;
  TABLE_Y_BOTTOM      = 133;
  TABLE_Y_OFFSET      = 30;
  TABLE_WIDTH_OF_FORM = 0.715;
begin
  // calculate table resize ratio
  FTableResizeRatio := (FDXAreaSize.x * TABLE_WIDTH_OF_FORM) / TableResources.TableImage.Texture[0].Width;

  // calculate raw dimensions, the ones that include table shadow
  FRawTableWidth := TableResources.TableImage.Texture[0].Width * FTableResizeRatio;
  FRawTableHeight := TableResources.TableImage.Texture[0].Height * FTableResizeRatio;

  FRawTableXOffset := (FDXAreaSize.x - FRawTableWidth) / 2;
  FRawTableYOffset := (FDXAreaSize.y - FRawTableHeight) / 2 + TABLE_Y_OFFSET * FTableResizeRatio;

  // now calculate real dimensions of table
  FTableXOffset := FRawTableXOffset + TABLE_X_LEFT * FTableResizeRatio;
  FTableYOffset := FRawTableYOffset + TABLE_Y_TOP * FTableResizeRatio;

  FTableWidth := FRawTableWidth - (TABLE_X_LEFT + TABLE_X_RIGHT) * FTableResizeRatio;
  FTableHeight := FRawTableHeight - (TABLE_Y_TOP + TABLE_Y_BOTTOM) * FTableResizeRatio;

  // calculate table center
  FTableCenterYOffset := -28 * FTableResizeRatio;
  FTableCenter.X := FTableXOffset + FTableWidth / 2;
  FTableCenter.Y := FTableYOffset + FTableHeight / 2 + FTableCenterYOffset;

  // calculate dealer point
  FDealerPoint.X := FTableCenter.X;
  FDealerPoint.Y := FTableYOffset;

  // calculate seat size multiplier
  FSeatSizeMultiplier := 1 + (10 - FTable.Game.Seats) / 23;
  if FSeatSizeMultiplier > 1.3 then
    FSeatSizeMultiplier := 1.3;

  // calculate seat size
  FSeatWidth := TableResources.SeatEmptyLeftImage.Texture[0].Width * FTableResizeRatio * FSeatSizeMultiplier;
  FSeatHeight := FSeatWidth / TableResources.SeatAspectRatio;

  // calculate card size
  FCardWidth := TableResources.CardBackgroundImage.Texture[0].Width * FTableResizeRatio;
  FCardHeight := FCardWidth / TableResources.CardAspectRatio;
  FCardArtworkWidth := FCardWidth * (0.48 + FTableResizeRatio / 5);
  FCardArtworkHeight := FCardHeight * 0.85;
  FSeatCardsMaxWidth := FSeatWidth * 0.55;

  // calculate dealer size
  FDealerWidth := TableResources.DealerButtonImage.Texture[0].Width * FTableResizeRatio;
  FDealerHeight := FDealerWidth / TableResources.DealerButtonAspectRatio;

  // calculate chip size
  FChipWidth := TableResources.Chip1Image.Texture[0].Width * FTableResizeRatio;
  FChipHeight := FChipWidth / TableResources.ChipAspectRatio;

  // calculate timebar/timebank size
  FTimebarWidth := TableResources.TimebarImage.Texture[0].Width * FTableResizeRatio;
  FTimebarHeight := FTimebarWidth / TableResources.TimebarAspectRatio;

  // calculate lower interface sizes
  FLowerIntfBorder := Round(10 * FTableResizeRatio);

  FActionButtonWidth := TableResources.ActionButtonNormalImage.Texture[0].Width * FTableResizeRatio;
  FActionButtonHeight := FActionButtonWidth / TableResources.ActionButtonAspectRatio;

  FActionButton3Point := Point2(FDXAreaSize.x - FLowerIntfBorder * 1.5 - FActionButtonWidth, FDXAreaSize.y - FLowerIntfBorder * 1.5 - FActionButtonHeight);
  FActionButton2Point := Point2(FActionButton3Point.x - FLowerIntfBorder * 2 - FActionButtonWidth, FActionButton3Point.y);
  FActionButton1Point := Point2(FActionButton2Point.x - FLowerIntfBorder * 2 - FActionButtonWidth, FActionButton2Point.y);

  FRaiseSliderWidth := FActionButton3Point.x + FActionButtonWidth - FActionButton1Point.x;
  FRaiseSliderHeight := FRaiseSliderWidth / TableResources.RaiseSliderAspectRatio;
  FRaiseSliderResizeRatio := FRaiseSliderWidth / TableResources.RaiseSliderBackgroundImage.Texture[0].Width;

  FRaiseSliderPoint := Point2(FActionButton1Point.x, FActionButton1Point.y - FLowerIntfBorder - FRaiseSliderHeight);

  FRaiseSliderButtonWidth := TableResources.RaiseSliderButtonImage.Texture[0].Width * FRaiseSliderResizeRatio;
  FRaiseSliderButtonHeight := FRaiseSliderButtonWidth * TableResources.RaiseSliderButtonAspectRatio;

  FRaiseSliderButtonBounds.Left := Round(FRaiseSliderPoint.x + TableResources.RAISE_SLIDER_X * FRaiseSliderResizeRatio);
  FRaiseSliderButtonBounds.Top := Round(FRaiseSliderPoint.y + TableResources.RAISE_SLIDER_Y * FRaiseSliderResizeRatio);
  FRaiseSliderButtonBounds.Width := Round(TableResources.RAISE_SLIDER_WIDTH * FRaiseSliderResizeRatio);
  FRaiseSliderButtonBounds.Height := Round(TableResources.RAISE_SLIDER_HEIGHT * FRaiseSliderResizeRatio);

  FRaiseSliderButtonPoint := Point2(FRaiseSliderButtonBounds.Left + FRaiseSliderButtonBounds.Width * FRaiseSliderPosition,
                                    FRaiseSliderButtonBounds.Top + FRaiseSliderButtonBounds.Height / 2);
end;

procedure TfrmTable.SetRaiseSliderValue(const AValue: UINT32; const ASetSpinEditValue: Boolean = TRUE);
var
  val: UINT32;
begin
  val := AValue;
  if val > FRaiseMax then
    val := FRaiseMax
  else
    if val < FRaiseMin then
      val := FRaiseMin;

  FRaiseValue := val;

  FRaiseSliderPosition := (val - FRaiseMin) / (FRaiseMax - FRaiseMin);

  if ASetSpinEditValue then
    seRaiseAmount.Value := val / 100;
end;

procedure TfrmTable.RenderEvent(Sender: TObject);
begin
  SetDXObjectSizes;

  RenderBackground;
  RenderTable;
  RenderTableCards;
  RenderDealerButton;
  RenderDealingCardsAni;
  RenderSeats;
  RenderBets;
  RenderPots;
  RenderTimebar;
  RenderLowerInterface;
end;

procedure TfrmTable.RenderBackground;
begin
  DXCore.Canvas.UseImage(TableResources.RoomBackgroundImage, TexFull4);
  DXCore.Canvas.TexMap(pBounds4(0, 0, FDXAreaSize.x, FDXAreaSize.y), clWhite4);
end;

procedure TfrmTable.RenderTable;
begin
  DXCore.Canvas.UseImage(TableResources.TableImage, TexFull4);
  DXCore.Canvas.TexMap(pBounds4(FRawTableXOffset, FRawTableYOffset, FRawTableWidth, FRawTableHeight), clWhite4);
end;

procedure TfrmTable.RenderSeats;
var
  C1: Integer;
begin
  for C1 := 0 to FTable.Game.Seats - 1 do
    RenderSeat(C1);
end;

procedure TfrmTable.RenderSeat(const ASeatIndex: Integer);
var
  seat_point             : TPoint2;
  seat_info              : TSeatInfo;
  player_info            : TPlayerInfo;
  seat_image             : TAsphyreImage;
  seat_empty_image       : TAsphyreImage;
  seat_dark_image        : TAsphyreImage;
//  seat_light_image       : TAsphyreImage;
  active_seat_dark_image : TAsphyreImage;
  active_seat_light_image: TAsphyreImage;
  avatar                 : TAvatar;
  avatar_point           : TPoint2;
  avatar_radius          : Single;
  seat_upper_text        : String;
  seat_lower_text        : String;
  seat_upper_text_color  : TColor2;
  seat_lower_text_color  : TColor2;
  seat_font              : TAsphyreFont;
  seat_upper_text_point  : TPoint2;
  seat_lower_text_point  : TPoint2;
  seat_text_x_center     : Single;
  card_point             : TPoint2;
  C1                     : Integer;
begin
  // get seat point
  seat_point := GetSeatPoint(ASeatIndex);

  // calculate seat elements positions & dimensions
  avatar_radius := Round(34 * FTableResizeRatio * FSeatSizeMultiplier);
  if GetTableSector(seat_point) in [tsLeft, tsTopLeft, tsBottomLeft] then
  begin
    seat_empty_image := TableResources.SeatEmptyLeftImage;
    seat_dark_image := TableResources.SeatDarkLeftImage;
//    seat_light_image := TableResources.SeatLightLeftImage;
    active_seat_dark_image := TableResources.ActiveSeatDarkLeftImage;
    active_seat_light_image := TableResources.ActiveSeatLightLeftImage;
    avatar_point := Point2(seat_point.X + FSeatWidth / 2 - 46 * FTableResizeRatio * FSeatSizeMultiplier, seat_point.Y);
    seat_text_x_center := seat_point.X - (seat_point.X + FSeatWidth / 2 - avatar_point.X) / 2;
  end
  else
  begin
    seat_empty_image := TableResources.SeatEmptyRightImage;
    seat_dark_image := TableResources.SeatDarkRightImage;
//    seat_light_image := TableResources.SeatLightRightImage;
    active_seat_dark_image := TableResources.ActiveSeatDarkRightImage;
    active_seat_light_image := TableResources.ActiveSeatLightRightImage;
    avatar_point := Point2(seat_point.X - FSeatWidth / 2 + 46 * FTableResizeRatio * FSeatSizeMultiplier, seat_point.Y);
    seat_text_x_center := seat_point.X + (avatar_point.X - (seat_point.X - FSeatWidth / 2)) / 2;
  end;
  seat_upper_text_point := Point2(seat_text_x_center, seat_point.Y - FSeatHeight / 4.5);
  seat_lower_text_point := Point2(seat_text_x_center, seat_point.Y + FSeatHeight / 5);

  // seat taken and its not in psStandingUp state
  if (FTableStatus.GetSeatInfo(ASeatIndex, seat_info)) and
     (seat_info.Status <> psStandingUp) then
  begin
    // find player info
    dmMain.Players.FindPlayerById(seat_info.PlayerMongoId, player_info);

    // set seat image that we should render
    if FTableStatus.CurrentSeat = seat_info.SeatIndex then
    begin
      if (tiActiveFrameBlink.Tag = 1) and
         (not FTableStatus.Locked) then
        seat_image := active_seat_light_image
      else
        seat_image := active_seat_dark_image;
    end
    else
      seat_image := seat_dark_image;

    if Assigned(player_info) then
    begin
      // set avatar
      avatar := Avatars.AddAvatar(player_info.AvatarId);

      // set seat upper text
      if seat_info.Caption <> '' then
      begin
        seat_upper_text := seat_info.Caption;
        seat_upper_text_color := cColor2($FF00A2FF);
      end
      else
      begin
        seat_upper_text := player_info.Nick;
        seat_upper_text_color := cColor2($FFCCCCCC);
      end;
    end
    else
    begin
      // set seat upper text
      seat_upper_text := '';
      seat_upper_text_color := cColor2($FFFFFFFF);

      avatar := Avatars.DefaultAvatar;
    end;

    // set seat lower text
    if seat_info.Status = psOutOfPlay then
      seat_lower_text := 'Sitting Out'
    else
      seat_lower_text := FloatToStr(seat_info.Chips / 100);
    seat_lower_text_color := cColor2($FF8DC63F);

    // render seat cards
    if (FTableStatus.State <> tsIdle) and
       (seat_info.Status in [psInHand, psAllIn]) then
    begin
      for C1 := 0 to seat_info.DealtCards - 1 do
      begin
        card_point := GetCardPoint(seat_info, C1);
        if (C1 >= 0) and (C1 < seat_info.Cards.Count) then
          RenderCard(card_point, seat_info.Cards[C1], CARD_OPEN_PERC)
        else
          RenderCard(card_point, nil, CARD_HIDDEN_PERC);
      end;
    end;

    // render avatar
    if avatar.DXImage.TextureCount > 0 then
    begin
      DXCore.Canvas.UseImage(avatar.DXImage, TexFull4);
      DXCore.Canvas.TexMap(
        pBounds4(avatar_point.X - avatar_radius,
                 avatar_point.Y - avatar_radius,
                 avatar_radius * 2,
                 avatar_radius * 2), clWhite4);
    end;

    // render seat
    DXCore.Canvas.UseImage(seat_image, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(seat_point.X - FSeatWidth / 2, seat_point.Y - FSeatHeight / 2, FSeatWidth, FSeatHeight), clWhite4);

    // render upper seat text
    C1 := High(TableResources.BarmenoFonts);
    seat_font := TableResources.BarmenoFonts[C1];
    seat_font.Kerning := 0;
    seat_font.Scale := 1;
    while ((seat_font.TextHeight(seat_upper_text) > FSeatHeight * 0.36) or
           (seat_font.TextWidth(seat_upper_text) > FSeatWidth * 0.75)) do
    begin
      if C1 > Low(TableResources.BarmenoFonts) then
      begin
        Dec(C1);
        seat_font := TableResources.BarmenoFonts[C1];
        seat_font.Kerning := 0;
        seat_font.Scale := 1;
      end
      else
        seat_font.Scale := seat_font.Scale - 0.01;
    end;

    seat_font.TextMidF(seat_upper_text_point, seat_upper_text, seat_upper_text_color);

    // render lower seat text
    C1 := High(TableResources.BarmenoFonts);
    seat_font := TableResources.BarmenoFonts[C1];
    seat_font.Kerning := 0;
    seat_font.Scale := 1;
    while ((seat_font.TextHeight(seat_lower_text) > FSeatHeight * 0.32) or
           (seat_font.TextWidth(seat_lower_text) > FSeatWidth * 0.75)) do
    begin
      if C1 > Low(TableResources.BarmenoFonts) then
      begin
        Dec(C1);
        seat_font := TableResources.BarmenoFonts[C1];
        seat_font.Kerning := 0;
        seat_font.Scale := 1;
      end
      else
        seat_font.Scale := seat_font.Scale - 0.01;
    end;

    seat_font.TextMidF(seat_lower_text_point, seat_lower_text, seat_lower_text_color);
  end
  else
  begin
    // empty seat
    DXCore.Canvas.UseImage(seat_empty_image, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(seat_point.X - FSeatWidth / 2, seat_point.Y - FSeatHeight / 2, FSeatWidth, FSeatHeight), clWhite4);
  end;
end;

procedure TfrmTable.RenderCard(const APoint: TPoint2; const ACard: TCard; const APercentage: Single);
var
  card_artwork     : TAsphyreImage;
  artwork_points   : TPoint4;
  card_value_point : TPoint2;
  card_suit_point  : TPoint2;
  card_value_text  : String;
  card_suit_text   : String;
  card_value_extent: TPoint2;
  card_suit_extent : TPoint2;
  card_text_width  : Single;
  text_color       : TColor2;
  card_font        : TAsphyreFont;
begin
  if not Assigned(ACard) then
  begin
    // render card background
    DXCore.Canvas.UseImagePx(TableResources.CardBackgroundImage,
      pBounds4(0, 0,
        TableResources.CardBackgroundImage.Texture[0].Width,
        TableResources.CardBackgroundImage.Texture[0].Height * APercentage));
    DXCore.Canvas.TexMap(pBounds4(APoint.x, APoint.y + 2, FCardWidth, FCardHeight * APercentage), clWhite4);
  end
  else
  begin
    // render card front background
    DXCore.Canvas.UseImagePx(TableResources.CardFrontBackgroundImage,
      pBounds4(0, 0,
        TableResources.CardFrontBackgroundImage.Texture[0].Width,
        TableResources.CardFrontBackgroundImage.Texture[0].Height * APercentage));
    DXCore.Canvas.TexMap(pBounds4(APoint.x, APoint.y + 2, FCardWidth, FCardHeight * APercentage), clWhite4);

    // render card value & suit
    card_value_text := ACard.ValueAsString(ACard.Value);
    if card_value_text = 'T' then
      card_value_text := '=';

    case ACard.Suit of
      csHeart: begin
        card_suit_text := '{';
        text_color := cColor2($FFFF0000);
      end;
      csDiamond: begin
        card_suit_text := '[';
        text_color := cColor2($FFFF0000);
      end;
      csClub: begin
        card_suit_text := ']';
        text_color := cColor2($FF000000);
      end;
      csSpade: begin
        card_suit_text := '}';
        text_color := cColor2($FF000000);
      end;
    else
      text_color := cColor2($FF00FF00);
    end;

    card_font := TableResources.CardCharactersFont_19px;
    card_font.Kerning := 1;
    if ((FCardWidth > 29) and (APercentage > 0.95)) or
       ((FCardWidth > 33) and (APercentage < 1)) then
    begin
      // render card with artwork
      card_text_width := FCardWidth / 2.6;

      card_font.Scale := FTableResizeRatio * 1.2;
      if card_font.Scale < 0.6 then
        card_font.Scale := 0.6;

      card_value_extent := card_font.TextExtent(card_value_text);
      card_value_point.x := APoint.x + card_text_width / 2;
      card_value_point.y := APoint.y + FCardHeight / 14 + card_value_extent.y / 2;

      card_font.TextMidFF(card_value_point, card_value_text, text_color);

      card_font.Scale := FTableResizeRatio;
      if card_font.Scale < 0.43 then
        card_font.Scale := 0.43;

      card_suit_extent := card_font.TextExtent(card_suit_text);
      card_suit_point := Point2(APoint.x + card_text_width / 2, card_value_point.y + card_value_extent.y / 2 + 4 * FTableResizeRatio + card_suit_extent.y / 2);

      card_font.TextMidFF(card_suit_point, card_suit_text, text_color);

      // render card artwork
      card_artwork := TableResources.GetCardArtwork(ACard);
      artwork_points := pBounds4(APoint.x + card_text_width, APoint.y + 10 * FTableResizeRatio,
              FCardWidth - card_text_width - 8 * FTableResizeRatio, FCardHeight - 12 * FTableResizeRatio);

      DXCore.Canvas.UseImagePx(card_artwork, pBounds4(0, 0,
          card_artwork.Texture[0].Width,
          card_artwork.Texture[0].Height));
      DXCore.Canvas.TexMap(artwork_points, clWhite4);

      // render rectangle frame around artwork
      DXCore.Canvas.FrameRect(artwork_points, cColor4($FFCFCFCF));
    end
    else
    begin
      // render simple card
      card_font.Kerning := 1;
      card_font.Scale := FTableResizeRatio * 1.1;
      if card_font.Scale < 0.70 then
        card_font.Scale := 0.70;

      card_value_extent := card_font.TextExtent(card_value_text);
      card_value_point := Point2(APoint.x + FCardHeight / 14, APoint.y + FCardHeight / 14);
      card_font.TextOut(card_value_point, card_value_text, text_color);

      card_font.Scale := FTableResizeRatio * 1.2;
      if card_font.Scale < 0.65 then
        card_font.Scale := 0.65;

      if APercentage < 1 then
      begin
        card_font.Scale := card_font.Scale - 0.15;
        card_suit_extent := card_font.TextExtent(card_suit_text);
        card_suit_point := Point2(APoint.x + FCardWidth - 5 * FTableResizeRatio - card_suit_extent.x, card_value_point.y)
      end
      else
      begin
        card_suit_extent := card_font.TextExtent(card_suit_text);
        card_suit_point := Point2(APoint.x + FCardWidth - 5 * FTableResizeRatio - card_suit_extent.x, APoint.y + FCardHeight - 5 * FTableResizeRatio - card_suit_extent.y);
      end;

      card_font.TextOut(card_suit_point, card_suit_text, text_color);
    end;
  end;
end;

procedure TfrmTable.RenderTableCards;
var
  C1               : Integer;
  card_points_curr : array of TPoint2;
  card_points_mid  : array of TPoint2;
  card_points_final: array of TPoint2;
  ani_count        : Integer;
  hide_card        : Boolean;
  animation        : TDXAnimation;
begin
  SetLength(card_points_final, 5);
  SetLength(card_points_curr, 5);
  SetLength(card_points_mid, 5);
  for C1 := Low(card_points_final) to High(card_points_final) do
  begin
    card_points_final[C1].x := FTableCenter.X - (FCardWidth * 5) / 2 - 4 * 3 + (C1 * FCardWidth) + (C1 * 3);
    card_points_final[C1].y := FTableCenter.Y - FCardHeight / 2;
    card_points_curr[C1] := card_points_final[C1];
    card_points_mid[C1] := card_points_final[C1];
  end;
  card_points_mid[0].x := card_points_final[0].x - 5;
  card_points_mid[1].x := card_points_final[0].x - 0;
  card_points_mid[2].x := card_points_final[0].x + 5;
//  card_points_mid[3].x := card_points_final[3].x + FCardWidth / 2;
//  card_points_mid[4].x := card_points_final[4].x + FCardWidth / 2;

  if FTableStatus.FlopCards.Count > 0 then
  begin
    hide_card := FFlopAnimations < 6;
    if FFlopAnimations = -1 then
    begin
      card_points_curr[0] := FDealerPoint;
      card_points_curr[1] := FDealerPoint;
      card_points_curr[2] := FDealerPoint;

      DXTimer.AddAnimation(Handle, ANIID_FLOP1, FDealerPoint, card_points_mid[0], 0.15, 0);
      DXTimer.AddAnimation(Handle, ANIID_FLOP2, FDealerPoint, card_points_mid[1], 0.15, 0);
      DXTimer.AddAnimation(Handle, ANIID_FLOP3, FDealerPoint, card_points_mid[2], 0.15, 0);

      DXTimer.AddAnimation(Handle, ANIID_FLOP4, card_points_mid[0], card_points_final[0], 0.2, 0.2);
      DXTimer.AddAnimation(Handle, ANIID_FLOP5, card_points_mid[1], card_points_final[1], 0.2, 0.2);
      DXTimer.AddAnimation(Handle, ANIID_FLOP6, card_points_mid[2], card_points_final[2], 0.2, 0.2);

      FFlopAnimations := 0;
    end;

    if FFlopAnimations in [0, 1, 2] then
    begin
      if DXTimer.Find(Handle, ANIID_FLOP1, animation) then
        card_points_curr[0] := animation.CurrPoint;
      if DXTimer.Find(Handle, ANIID_FLOP2, animation) then
        card_points_curr[1] := animation.CurrPoint;
      if DXTimer.Find(Handle, ANIID_FLOP3, animation) then
        card_points_curr[2] := animation.CurrPoint;
    end;

    if FFlopAnimations in [3, 4, 5] then
    begin
      ani_count := 0;
      if DXTimer.Find(Handle, ANIID_FLOP4, animation) then
      begin
        card_points_curr[0] := animation.CurrPoint;
        if animation.Status = asAnimating then
          Inc(ani_count);
      end;
      if DXTimer.Find(Handle, ANIID_FLOP5, animation) then
      begin
        card_points_curr[1] := animation.CurrPoint;
        if animation.Status = asAnimating then
          Inc(ani_count);
      end;
      if DXTimer.Find(Handle, ANIID_FLOP6, animation) then
      begin
        card_points_curr[2] := animation.CurrPoint;
        if animation.Status = asAnimating then
          Inc(ani_count);
      end;
      hide_card := ani_count = 0;
    end;

    for C1 := 0 to FTableStatus.FlopCards.Count - 1 do
      if hide_card then
        RenderCard(card_points_curr[C1], nil, 1)
      else
        RenderCard(card_points_curr[C1], FTableStatus.FlopCards[C1], 1);
  end;

  if FTableStatus.TurnCard.Value <> cvUnknown then
  begin
    hide_card := FTurnAnimations < 1;
    if FTurnAnimations = -1 then
    begin
      card_points_curr[3] := FDealerPoint;
      DXTimer.AddAnimation(Handle, ANIID_TURN, FDealerPoint, card_points_final[3], 0.15, 0);
      FTurnAnimations := 0;
    end;

    if FTurnAnimations = 0 then
      if DXTimer.Find(Handle, ANIID_TURN, animation) then
        card_points_curr[3] := animation.CurrPoint;

    if hide_card then
      RenderCard(card_points_curr[3], nil, 1)
    else
      RenderCard(card_points_curr[3], FTableStatus.TurnCard, 1);
  end;

  if FTableStatus.RiverCard.Value <> cvUnknown then
  begin
    hide_card := FRiverAnimations < 1;
    if FRiverAnimations = -1 then
    begin
      card_points_curr[4] := FDealerPoint;
      DXTimer.AddAnimation(Handle, ANIID_RIVER, FDealerPoint, card_points_final[4], 0.15, 0);
      FRiverAnimations := 0;
    end;

    if FRiverAnimations = 0 then
      if DXTimer.Find(Handle, ANIID_RIVER, animation) then
        card_points_curr[4] := animation.CurrPoint;

    if hide_card then
      RenderCard(card_points_curr[4], nil, 1)
    else
      RenderCard(card_points_curr[4], FTableStatus.RiverCard, 1);
  end;
end;

procedure TfrmTable.RenderDealingCardsAni;
var
  C1       : Integer;
  animation: TDXAnimation;
begin
  for C1 := ANIID_DEALING to ANIID_DEALING + (FTable.Game.Seats - 1) * 10 do
    if (DXTimer.Find(Handle, C1, animation)) and
       (animation.Status = asAnimating) then
      RenderCard(animation.CurrPoint, nil, 1);
end;

procedure TfrmTable.RenderDealerButton;
var
  dealer_point: TPoint2;
begin
  if FTableStatus.Dealer = -1 then
    Exit;

  dealer_point := GetDealerPoint(FTableStatus.Dealer);

  DXCore.Canvas.UseImage(TableResources.DealerButtonImage, TexFull4);
  DXCore.Canvas.TexMap(pBounds4(dealer_point.X - FDealerWidth / 2, dealer_point.Y - FDealerHeight / 2, FDealerWidth, FDealerHeight), clWhite4);
end;

procedure TfrmTable.RenderBets;
var
  C1         : Integer;
  seat_info  : TSeatInfo;
  chips_point: TPoint2;
  chips_stack: TChipsStack;
  stack_value: Single;
begin
  for C1 := 0 to FTableStatus.Seats.Count - 1 do
    if FTableStatus.GetSeatInfo(FTableStatus.Seats[C1].SeatIndex, seat_info) then
    begin
      if (Length(FTableStatus.Bets) > seat_info.SeatIndex) and
         (FTableStatus.Bets[seat_info.SeatIndex] > 0) then
      begin
        stack_value := FTableStatus.Bets[seat_info.SeatIndex] / 100;
        chips_point := GetBetPoint(seat_info.SeatIndex);
        chips_stack := FChipsStackMaker.MakeStack(Trunc(stack_value));
        RenderChipStack(chips_point, chips_stack);
        RenderValue(chips_point, stack_value, clWhite2, FALSE);
      end;
    end;
end;

procedure TfrmTable.RenderPots;
var
  C1         : Integer;
  pot        : Single;
  chips_stack: TChipsStack;
  pot_point  : TPoint2;
  animation  : TDXAnimation;
  pots       : TPotInfos;
begin
  if FBetAnimations > 0 then
  begin
    pots := FTableStatus.PreviousPots;
    for C1 := ANIID_BETS to ANIID_BETS + 19 do
      if DXTimer.Find(Handle, C1, animation) then
      begin
        chips_stack := FChipsStackMaker.MakeStack(Trunc(FBetAniStacks[C1 - ANIID_BETS] / 100));
        RenderChipStack(animation.CurrPoint, chips_stack);
      end;
  end
  else
    pots := FTableStatus.Pots;

  for C1 := 0 to pots.Count - 1 do
  begin
    pot := pots[C1].Value / 100;
    if pot = 0 then
      Continue;

    pot_point := GetPotPoint(C1);
    if (pot_point.X > 0) and (pot_point.Y > 0) then
    begin
      chips_stack := FChipsStackMaker.MakeStack(Trunc(pot));
      RenderChipStack(pot_point, chips_stack);
      RenderValue(pot_point, pot, clWhite2, TRUE);
    end;
  end;
end;

procedure TfrmTable.RenderValue(const APoint: TPoint2; const AValue: Single; const AColor: TColor2; const APot: Boolean);
var
  font: TAsphyreFont;
  text: String;
  p   : TPoint2;
begin
  text := FormatFloat('0.##', AValue);

  font := TableResources.BarmenoFonts[High(TableResources.BarmenoFonts)];
  font.Scale := FTableResizeRatio;
  font.Kerning := 2;

  p := APoint;
  if APot then
    p.y := p.y + FChipHeight + 15 * FTableResizeRatio
  else
  begin
    if GetTableSector(APoint) in [tsTopRight, tsRight, tsBottomRight] then
      p.x := p.x - FChipWidth / 2 - 10 * FTableResizeRatio - font.TextWidth(text) / 2
    else
      p.x := p.x + FChipWidth / 2 + 10 * FTableResizeRatio + font.TextWidth(text) / 2;

    p.y := p.y + FChipHeight / 1.70;
  end;
  font.TextMidF(p, text, AColor);
end;

function TfrmTable.RoundToBB(const AValue: Single): UINT32;
begin
  result := Trunc(AValue / FTable.Game.BigBlind) * FTable.Game.BigBlind;
end;

procedure TfrmTable.RenderChipStack(const APoint: TPoint2; const AChipStack: TChipsStack);
var
  C1: Integer;
begin
  for C1 := Low(AChipStack.Images) to High(AChipStack.Images) do
  begin
    DXCore.Canvas.UseImage(AChipStack.Images[C1], TexFull4);
    DXCore.Canvas.TexMap(pBounds4(APoint.X - FChipWidth / 2,
        APoint.Y - C1 * 5 * FTableResizeRatio, FChipWidth, FChipHeight), clWhite4);
  end;
end;

procedure TfrmTable.RenderTimebar;
var
  seat        : TSeatInfo;
  seat_point  : TPoint2;
  time_image  : TAsphyreImage;
  time_percent: Single;
begin
  if (FTableStatus.Locked) or
     (FTableStatus.Time = 0) or
     (FGoalTime = 0) then
    Exit;

  if FTableStatus.GetSeatInfo(FTableStatus.CurrentSeat, seat) then
  begin
    seat_point := GetSeatPoint(seat.SeatIndex);

    FCurrentPlaytime := FGoalTime - GetTickCount;

    if FCurrentPlaytime > 0 then
    begin
      time_image := TableResources.TimebarImage;
      time_percent := (FCurrentPlaytime / (ServerSettings.Playtime * 1000)) * 1.5;
    end
    else
    begin
      // using timebank..
      time_image := TableResources.TimebankImage;
      time_percent := (Integer(seat.Timebank) + FCurrentPlaytime) / (ServerSettings.Timebank * 1000);
    end;

    if time_percent > 1 then
      time_percent := 1;

    DXCore.Canvas.UseImagePx(time_image, pBounds4(0, 0, time_percent * time_image.Texture[0].Width, time_image.Texture[0].Height));
    DXCore.Canvas.TexMap(pBounds4(seat_point.X - FTimebarWidth / 2,
       seat_point.Y + FSeatHeight / 2 - 3 * FTableResizeRatio, FTimebarWidth * time_percent, FTimebarHeight),
       clWhite4);
  end;
end;

procedure TfrmTable.RenderLowerInterface;
var
  red_quad: TPoint4;
begin
  if acRaise.Enabled then
  begin
    // render raise slider background
    DXCore.Canvas.UseImage(TableResources.RaiseSliderBackgroundImage, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(FRaiseSliderPoint.x, FRaiseSliderPoint.y, FRaiseSliderWidth, FRaiseSliderHeight), clWhite4);

    // render raise red fill
    red_quad := pBounds4(FRaiseSliderButtonBounds.Left + 1.5 * FRaiseSliderResizeRatio,
                         FRaiseSliderButtonBounds.Top + 1.5 * FRaiseSliderResizeRatio,
                         FRaiseSliderButtonPoint.x - FRaiseSliderButtonBounds.Left - 1.5 * FRaiseSliderResizeRatio,
                         FRaiseSliderButtonBounds.Height - 3 * FRaiseSliderResizeRatio);
    DXCore.Canvas.FillQuad(red_quad, cColor4($FFB40004));

    // render raise button
    DXCore.Canvas.UseImage(TableResources.RaiseSliderButtonImage, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(FRaiseSliderButtonPoint.x - FRaiseSliderButtonWidth / 2,
                                  FRaiseSliderButtonPoint.y - FRaiseSliderButtonHeight / 2,
                                  FRaiseSliderButtonWidth, FRaiseSliderButtonHeight), clWhite4);
  end;

  if Assigned(FActionButton1Action) then
  begin
    DXCore.Canvas.UseImage(FActionButton1Image, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(FActionButton1Point.x, FActionButton1Point.y, FActionButtonWidth, FActionButtonHeight), clWhite4);

    TableResources.Sintony_19px.Kerning := 0;

    if FMouseDownObject = mdoActionButton1 then
      TableResources.Sintony_19px.Scale := FTableResizeRatio * 0.9
    else
      TableResources.Sintony_19px.Scale := FTableResizeRatio;

    TableResources.Sintony_19px.TextMidF(Point2(FActionButton1Point.x + FActionButtonWidth / 2, FActionButton1Point.y + FActionButtonHeight / 2), FActionButton1Action.Caption, clWhite2);
  end;

  if Assigned(FActionButton2Action) then
  begin
    DXCore.Canvas.UseImage(FActionButton2Image, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(FActionButton2Point.x, FActionButton2Point.y, FActionButtonWidth, FActionButtonHeight), clWhite4);

    TableResources.Sintony_19px.Kerning := 0;

    if FMouseDownObject = mdoActionButton2 then
      TableResources.Sintony_19px.Scale := FTableResizeRatio * 0.9
    else
      TableResources.Sintony_19px.Scale := FTableResizeRatio;

    TableResources.Sintony_19px.TextMidF(Point2(FActionButton2Point.x + FActionButtonWidth / 2, FActionButton2Point.y + FActionButtonHeight / 2), FActionButton2Action.Caption, clWhite2);
  end;

  if Assigned(FActionButton3Action) then
  begin
    DXCore.Canvas.UseImage(FActionButton3Image, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(FActionButton3Point.x, FActionButton3Point.y, FActionButtonWidth, FActionButtonHeight), clWhite4);

    TableResources.Sintony_19px.Kerning := 0;

    if FMouseDownObject = mdoActionButton3 then
      TableResources.Sintony_19px.Scale := FTableResizeRatio * 0.9
    else
      TableResources.Sintony_19px.Scale := FTableResizeRatio;

    TableResources.Sintony_19px.TextMidF(Point2(FActionButton3Point.x + FActionButtonWidth / 2, FActionButton3Point.y + FActionButtonHeight / 2), FActionButton3Action.Caption, clWhite2);
  end;
end;


procedure TfrmTable.AnimateBets(const ABets: TArray<UINT32>);
var
  C1       : UINT32;
  bet_point: TPoint2;
  pot_point: TPoint2;
begin
  for C1 := Low(ABets) to High(ABets) do
    if ABets[C1] > 0 then
    begin
      FBetAniStacks[FBetAnimations] := ABets[C1];
      bet_point := GetBetPoint(C1);
      pot_point := GetPotPoint(0);
      DXTimer.AddAnimation(HANDLE, ANIID_BETS + FBetAnimations, bet_point, pot_point, 0.25, 0.4);
      Inc(FBetAnimations);
    end;
end;

procedure TfrmTable.AnimationCallback(const AAnimationPointer: pointer);
var
  seat_index: Integer;
  seat      : TSeatInfo;
  animation : TDXAnimation;
begin
  if not Assigned(AAnimationPointer) then
  begin
    Render;
    Exit;
  end;

  animation := TDXAnimation(AAnimationPointer);

  case animation.ID of
    ANIID_FLOP1, ANIID_FLOP2, ANIID_FLOP3, ANIID_FLOP4, ANIID_FLOP5, ANIID_FLOP6: begin
      if animation.Status = asDone then
        Inc(FFlopAnimations);
    end;

    ANIID_TURN: begin
      if animation.Status = asDone then
        Inc(FTurnAnimations);
    end;

    ANIID_RIVER: begin
      if animation.Status = asDone then
        Inc(FRiverAnimations);
    end;

    ANIID_DEALING..ANIID_DEALING + 99: begin
      if animation.Status = asDone then
      begin
        seat_index := (animation.ID - ANIID_DEALING) div 10;
        if FTableStatus.GetSeatInfo(seat_index, seat) then
          seat.IncDealtCards;

        Dec(FDealAnimations);
      end;
    end;

    ANIID_BETS..ANIID_BETS + 19: begin
      if animation.Status = asDone then
        Dec(FBetAnimations);
    end;
  end;
end;



end.

