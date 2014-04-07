unit Poker.Forms.Table;

{
  ISSUES:
    - teSit happens before player receives TableStatus. Means, if any processing is done in teSit, there would be no info for new player in seat
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, cxMemo,  Poker.Table.Status, Poker.DirectX.Timer,
  Poker.DirectX.Animation, Vectors2, Vcl.ActnList, cxLabel, Poker.Table.Tables, cxTextEdit, dxsChipUpDark,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, dxsChipUpDarkTabs, dxsChipUpRedButton, cxMaskEdit, cxSpinEdit, cxTrackBar, cxCheckBox,
  Vectors2px, Poker.Protobufs.Objects.TableEvent, System.Types, Poker.ChipStackMaker, AsphyreTypes, cxCurrencyEdit, RVStyle,
  RVScroll, RichView, AsphyreImages, Poker.Cards, Vcl.StdCtrls, AsphyreFonts;

type
  TMouseDownObject = (mdoNone, mdoRaiseSliderButton, mdoActionButton1, mdoActionButton2, mdoActionButton3,
      mdoRaisePresetButton1, mdoRaisePresetButton2, mdoRaisePresetButton3, mdoRaisePresetButton4,
      mdoStandUpButton, mdoPlayNowButton);

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
    Button1: TButton;
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
    procedure Button1Click(Sender: TObject);
  private
    const
      FORM_ASPECT_RATIO = 1.35;
      CARD_OPEN_PERC    = 0.55;
      CARD_HIDDEN_PERC  = 0.35;

    type
      TTableSector = (tsTopLeft, tsTop, tsTopRight, tsRight, tsBottomRight, tsBottom, tsBottomLeft, tsLeft, tsMid);

      TUIButton = record
        Image : TAsphyreImage;
        Point : TPoint2;
        Action: TAction;
      end;

    var
      FCallbacksId            : Integer;
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
      FSeatWidth              : Single;
      FSeatHeight             : Single;
      FSeatResizeRatio        : Single;
      FSeatActionResizeRatio  : Single;
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
      FSeatActionFrameWidth   : Single;
      FSeatActionFrameHeight  : Single;
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
      FRaisePresetButtonWidth : Single;
      FRaisePresetButtonHeight: Single;
      FStandUpButtonWidth     : Single;
      FStandUpButtonHeight    : Single;
      FStandUpResizeRatio     : Single;
      FPlayNowButtonWidth     : Single;
      FPlayNowButtonHeight    : Single;
      FPlayNowResizeRatio     : Single;
      FClosingTime            : DWORD;

      FActionButtonWidth      : Single;
      FActionButtonHeight     : Single;

      FActionButtons          : TArray<TUIButton>;
      FRaisePresetButtons     : TArray<TUIButton>;
      FStandUpButton          : TUIButton;
      FPlayNowButton          : TUIButton;

      FDXAreaSize        : TPoint2px;

      FTable             : TTable;
      FTableStatus       : TTableStatus;
      FChipStackMaker    : TChipStackMaker;

      FGoalTime          : UINT32;
      FCurrentPlaytime   : Integer;

      FFlopAnimations    : TList<Integer>;
      FFlopAnimated      : Boolean;
      FTurnAnimations    : TList<Integer>;
      FTurnAnimated      : Boolean;
      FRiverAnimations   : TList<Integer>;
      FRiverAnimated     : Boolean;
      FDealAnimations    : TList<Integer>;
      FBetAnimations     : TList<Integer>;
      FPotWinAnimations  : TList<Integer>;

      FTurnAniDelay      : Single;
      FRiverAniDelay     : Single;
      FWinningAniDelay   : Single;

      FMouseDownObject   : TMouseDownObject;

      FRaiseMin          : UINT32;
      FRaiseMax          : UINT32;
      FRaiseValue        : UINT32;

      FForceFocused      : Boolean;

      FEventBuffer       : TObjectList<TPB_TableEvent>;

    procedure SetDXObjectSizes;
    procedure SetRaiseSliderValue(const AValue: UINT32; const ASetSpinEditValue: Boolean = TRUE);

    procedure Render;
    procedure RenderEvent(Sender: TObject);
    procedure RenderBackground;
    procedure RenderTable;
    procedure RenderSeats;
    procedure RenderSeat(const ASeatIndex: Integer);
    procedure RenderCard(const APoint: TPoint2; const ACard: TCard; const APercentage: Single);
    procedure RenderClosingText;
    procedure RenderTableCards;
    procedure RenderDealingCardsAni;
    procedure RenderDealerButton;
    procedure RenderBets;
    procedure RenderPots;
    procedure RenderChipStack(const APoint: TPoint2; const AChipStack: TChipsStack);
    procedure RenderTimebar;
    procedure RenderValue(const APoint: TPoint2; const AValue: Single; const AColor: TColor2; const APot: Boolean);
    procedure RenderLowerInterface;

    procedure EnableGameLockTimer(const ASeconds: Single);

    procedure AddUserChatMessage(const AUser, AMessage: String);
    procedure AddDealerChatMessage(const AMessage: String);
    procedure ModalFormClose(Sender: TObject);
    procedure CheckChatScrollbackLimit;

    function RoundToBB(const AValue: Single): UINT32;

    procedure AnimateBets(const ABets: TArray<UINT32>);
    procedure AnimateBlinds;

    function ConfirmLeaveTable: Boolean;
    function ConfirmStandUp: Boolean;

    function IsPointInUIButtons(const AX, AY: Integer; const AButtons: TArray<TUIButton>; const AButtonWidth, AButtonHeight: Single; out AIndex: Integer): Boolean;
    function IsPointInStandUpButton(const AX, AY: Integer): Boolean;

    function GetTableSector(const APoint: TPoint2): TTableSector;
    function GetSeatPoint(const ASeatIndex: Integer): TPoint2;
    function GetCardPoint(const ASeatInfo: TSeatInfo; const ACardIndex: Integer): TPoint2;
    function GetDealerPoint(const ASeatIndex: Integer): TPoint2;
    function GetBetPoint(const ASeatIndex: Integer): TPoint2;
    function GetPotPoint(const APotIndex: Integer): TPoint2;

    procedure UpdateClosingTime;

    procedure CSRChatEvent(const AMethodId: Integer; const AObject: TObject);
    procedure CSRETableStatus(const AMethodId: Integer; const AObject: TObject);
    procedure CSEUserChange(const AMethodId: Integer; const AObject: TObject);
    procedure CSEGameChange(const AMethodId: Integer; const AObject: TObject);

    procedure RenderScaleFont(const AText: String; const AColor: TColor2; const AMidPoint: TPoint2; const AFonts: array of TAsphyreFont; const ALowBound, AMinIndex, AMaxIndex, AKerning: Integer; const AMaxHeight, AMaxWidth: Single);

    procedure TablePlaySound(const ASound: String);

    procedure ProcessTableEvent(const ATableEvent: TPB_TableEvent);

    procedure ConfigureGUI;
    procedure DefocusControls;

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
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  cxClasses, System.Math, AsphyreBitmaps, AsphyreJPG, Poker.Server.MessageContainer, Poker.Server.Settings,
  Poker.Server.MessageCallbacks, Poker.Protobufs.Enum.ServerCodes, Poker.Protobufs.Objects.ChatEvent,
  Poker.Protobufs.Objects.ChatMessage, Poker.Protobufs.Objects.SeatInfo, Poker.Table.Resources,
  Poker.DirectX.Core, Poker.Common.FormsContainer, Poker.Server.Socket, Poker.Common.Misc,
  Poker.Forms.TableSit, Poker.DataModule, Poker.Objects.PlayerInfo, Poker.Avatars, Poker.Protobufs.Objects.Game,
  Poker.Protobufs.Objects.TableStatus, Poker.Protobufs.Objects.PotInfo, RVTable, Poker.Sounds;


constructor TfrmTable.Create(const ATable: TTable);
begin
  if not Assigned(TableResources) then
    TTableResources.Initialize(DXCore.Canvas);

  inherited Create(nil);

  ActionManager.State := asSuspended;

  FTable := ATable;

  OnResize := nil;
  ClientWidth := Round(Screen.Monitors[0].Width / 2.3);
  ClientHeight := Round(ClientWidth / FORM_ASPECT_RATIO);
  OnResize := FormResize;
end;

procedure TfrmTable.FormCreate(Sender: TObject);
var
  C1: Integer;
begin
  FCallbacksId := MessageContainer.AddCallbacks([
                      TServerMessageCallback.Create(seChat, CSRChatEvent),
                      TServerMessageCallback.Create(seTableStatus, CSRETableStatus),
                      TServerMessageCallback.Create(srTableSitOk, CSRETableStatus),
                      TServerMessageCallback.Create(srTableAddonOk, CSRETableStatus),
                      TServerMessageCallback.Create(srTableStandUpOk, CSRETableStatus),
                      TServerMessageCallback.Create(seUserChange, CSEUserChange),
                      TServerMessageCallback.Create(seGameChange, CSEGameChange)
                  ]);

  FFlopAnimations := TList<Integer>.Create;
  FFlopAnimated := FALSE;

  FTurnAnimations := TList<Integer>.Create;
  FTurnAnimated := FALSE;

  FRiverAnimations := TList<Integer>.Create;
  FRiverAnimated := FALSE;

  FDealAnimations := TList<Integer>.Create;
  FBetAnimations := TList<Integer>.Create;
  FPotWinAnimations := TList<Integer>.Create;

  SetLength(FActionButtons, 3);
  SetLength(FRaisePresetButtons, 4);
  FStandUpButton.Action := acStandUp;
  FPlayNowButton.Action := acPlayNow;

  FEventBuffer := TObjectList<TPB_TableEvent>.Create;

  for C1 := Low(FActionButtons) to High(FActionButtons) do
    FActionButtons[C1].Image := TableResources.ActionButtonNormalImage;
  for C1 := Low(FRaisePresetButtons) to High(FRaisePresetButtons) do
    FRaisePresetButtons[C1].Image := TableResources.RaisePresetButtonNormalImage;
  FStandUpButton.Image := TableResources.StandUpButtonNormalImage;
  FPlayNowButton.IMage := TableResources.PlayNowButtonNormalImage;

  FMouseDownObject := mdoNone;

  FTableStatus := TTableStatus.Create;
  FChipStackMaker := TChipStackMaker.Create;

  Constraints.MaxHeight := 910 + (Height - ClientHeight);
  Constraints.MaxWidth := Round(Constraints.MaxHeight * FORM_ASPECT_RATIO);

  Constraints.MinWidth := 600;
  Constraints.MinHeight := Round(Constraints.MinWidth / FORM_ASPECT_RATIO);

  rvChat.ClearAll;
  rvChat.Format;

  Caption := Format('%s - %s (%d/%d %s)', [FTable.Club.Name, FTable.Game.Name, Round(FTable.Game.SmallBlind / 100), Round(FTable.Game.BigBlind / 100), FTable.Game.GameTypeStrFull]);
end;

procedure TfrmTable.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);

  DXTimer.RemoveAnimations(Handle);

  FDealAnimations.Free;
  FFlopAnimations.Free;
  FTurnAnimations.Free;
  FRiverAnimations.Free;
  FBetAnimations.Free;
  FPotWinAnimations.Free;

  FEventBuffer.Free;

  FChipStackMaker.Free;
  FTableStatus.Free;
end;

procedure TfrmTable.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  renderit: Boolean;
  index   : Integer;
  C1      : Integer;
begin
  renderit := FALSE;

  DefocusControls;

  if Button = mbLeft then
  begin
    if FMouseDownObject <> mdoNone then
      Exit;

    if (acRaise.Enabled) and
       (IsPointInsideCircle(X, Y, FRaiseSliderButtonPoint.x, FRaiseSliderButtonPoint.y, FRaiseSliderButtonWidth / 2)) then
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
             (PtInRect(FRaiseSliderButtonBounds, Point(X, Y))) then
          begin
            SetRaiseSliderValue(RoundToBB(FRaiseMin + ((X - FRaiseSliderButtonBounds.Left) / FRaiseSliderButtonBounds.Width) * (FRaiseMax - FRaiseMin)));
            FMouseDownObject := mdoRaiseSliderButton;
            renderit := TRUE;
          end
          else
            if (acStandUp.Enabled) and
               (IsPointInStandUpButton(X, Y)) then
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
    Render;
end;

procedure TfrmTable.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  renderit : Boolean;
  index, C1: Integer;
begin
  renderit := FALSE;
  case FMouseDownObject of
    mdoNone: begin
      if (IsPointInUIButtons(X, Y, FActionButtons, FActionButtonWidth, FActionButtonHeight, index)) and
         (Assigned(FActionButtons[index].Action)) then
      begin
        for C1 := Low(FActionButtons) to High(FActionButtons) do
       {   if C1 = index then
            FActionButtons[C1].Image := TableResources.ActionButtonHotImage
          else     }
            FActionButtons[C1].Image := TableResources.ActionButtonNormalImage;
        renderit := TRUE;
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
       {   if C1 = index then
            FRaisePresetButtons[C1].Image := TableResources.RaisePresetButtonHotImage
          else   }
            FRaisePresetButtons[C1].Image := TableResources.RaisePresetButtonNormalImage;
        renderit := TRUE;
      end
      else
        for C1 := Low(FRaisePresetButtons) to High(FRaisePresetButtons) do
          if FRaisePresetButtons[C1].Image <> TableResources.RaisePresetButtonNormalImage then
          begin
            FRaisePresetButtons[C1].Image := TableResources.RaisePresetButtonNormalImage;
            renderit := TRUE;
          end;

      if (acStandUp.Enabled) and
         (IsPointInStandUpButton(X, Y)) then
      begin
//        FStandUpButton.Image := TableResources.StandUpButtonPressedImage;
        renderit := TRUE;
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
        renderit := TRUE;
      end
      else
        if FPlayNowButton.Image <> TableResources.PlayNowButtonNormalImage then
        begin
          FPlayNowButton.Image := TableResources.PlayNowButtonNormalImage;
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
      if IsPointInStandUpButton(X, Y) then
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
  DefocusControls;
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

  DefocusControls;

  if FTable.Game.State <> gsClosed then
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
var
  hround: Integer;
begin
  hround := Round(Width / FORM_ASPECT_RATIO);
  if Height <> hround then
    Height := hround;

  rvChat.Height := ClientHeight div 7;
  rvChat.Width := Round(ClientWidth / 3.15);
  rvChat.Top := ClientHeight - FLowerIntfBorder - rvChat.Height;
  rvChat.Left := FLowerIntfBorder;

  edChat.Width := rvChat.Width;
  edChat.Top := rvChat.Top - edChat.Height;
  edChat.Left := rvChat.Left;

  cbSitOutNextBB.Top := rvChat.Top + rvChat.Height - cbSitOutNextBB.Height;
  cbSitOutNextHand.Top := cbSitOutNextBB.Top - cbSitOutNextHand.Height;
  cbFoldToAnyBet.Top := cbSitOutNextHand.Top - cbFoldToAnyBet.Height;

  cbFoldToAnyBet.Left := rvChat.Left + rvChat.Width + FLowerIntfBorder;
  cbSitOutNextHand.Left := cbFoldToAnyBet.Left;
  cbSitOutNextBB.Left := cbFoldToAnyBet.Left;

  if Assigned(DXCore.Device) then
  begin
    FDXAreaSize := Point2px(ClientWidth, ClientHeight);
    DXCore.Device.Resize(FTable.SwapChainIndex, FDXAreaSize);
    Render;
  end;

  seRaiseAmount.Width := Round(TableResources.RAISE_VALUEBOX_WIDTH * FRaiseSliderResizeRatio);
  seRaiseAmount.Height := Round(TableResources.RAISE_VALUEBOX_HEIGHT * FRaiseSliderResizeRatio);
  seRaiseAmount.Left := Round(FRaiseSliderPoint.x + TableResources.RAISE_VALUEBOX_X * FRaiseSliderResizeRatio);
  seRaiseAmount.Top := Round(FRaiseSliderPoint.y + TableResources.RAISE_VALUEBOX_Y * FRaiseSliderResizeRatio);
end;

procedure TfrmTable.WMSizing(var AMessage: TMessage);
begin
  inherited;

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

procedure TfrmTable.tiGameLockTimer(Sender: TObject);
begin
  tiGameLock.Enabled := FALSE;
  ConfigureGUI;
  Render;
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

function TfrmTable.GetSeatPoint(const ASeatIndex: Integer): TPoint2;
var
  seat_radians: Double;
  x, y        : Single;
  pf          : TPointF;
begin
  seat_radians := TTableResources.SEAT_POINTS[FTable.Game.Seats, ASeatIndex];

  x := FTableCenter.X + (FTableWidth * 0.9 / 2) * Cos(seat_radians);
  y := FTableCenter.Y - FTableCenterYOffset + (FTableHeight * 0.95 / 2) * Sin(seat_radians) - 8 * FTableResizeRatio;

  pf := PointF(x, y);

  case GetTableSector(Point2(x, y)) of
    tsTopLeft: pf.Offset(-FSeatWidth / 2.35, -FSeatHeight / 2);
    tsLeft: pf.Offset(-FSeatWidth / 2.35, 0);
    tsBottomLeft: pf.Offset(-FSeatWidth / 2.35, FSeatHeight / 2);
    tsBottom: pf.Offset(0, FSeatHeight / 1.55);
    tsBottomRight: pf.Offset(FSeatWidth / 2.35, FSeatHeight / 2);
    tsRight: pf.Offset(FSeatWidth / 2.35, 0);
    tsTopRight: pf.Offset(FSeatWidth / 2.35, -FSeatHeight / 2);
    tsTop: pf.Offset(0, -FSeatHeight / 2);
  end;

  result := Point2(pf.x, pf.y);
end;

function TfrmTable.GetTableSector(const APoint: TPoint2): TTableSector;
var
  points: array[0..3] of TPoint2;
begin
  points[0] := Point2(FTableCenter.X - FSeatWidth / 4, FTableCenter.Y - FSeatHeight / 2.5);
  points[1] := Point2(FTableCenter.X + FSeatWidth / 4, FTableCenter.Y - FSeatHeight / 2.5);
  points[2] := Point2(FTableCenter.X - FSeatWidth / 4, FTableCenter.Y + FSeatHeight / 2.5);
  points[3] := Point2(FTableCenter.X + FSeatWidth / 4, FTableCenter.Y + FSeatHeight / 2.5);

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

function TfrmTable.IsPointInStandUpButton(const AX, AY: Integer): Boolean;
begin
  if (AY < FStandUpButton.Point.y) or
     (AY > FStandUpButton.Point.y + FStandupButtonHeight) or
     (AX > FStandUpButton.Point.x + FStandUpButtonWidth) or
     (AX < FStandUpButton.Point.x) then
    Exit(FALSE);

  // triangle test
  if FStandUpButtonHeight * (AX - FStandUpButton.Point.x) - TableResources.STANDUP_BUTTON_TRIANGLE_W * FTableResizeRatio * (AY - FStandUpButton.Point.y) < 0 then
    Exit(FALSE);

  Exit(TRUE);
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
  xr := FTableWidth / 1.25;
  yr := FTableHeight / 1.45;

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
    xr := FTableWidth / 1.51;
    yr := FTableHeight / 2;
  end
  else
  begin
    xr := FTableWidth / 1.26;
    yr := FTableHeight / 1.45;
  end;

  seat_radians := TTableResources.SEAT_POINTS[FTable.Game.Seats, ASeatIndex];
  x := FTableCenter.X + (xr / 2) * Cos(seat_radians);
  y := FTableCenter.Y - FTableCenterYOffset + (yr / 2) * Sin(seat_radians) - 40 * FTableResizeRatio;
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
end;

procedure TfrmTable.acShowCardsExecute(Sender: TObject);
begin
  ServerSocket.ShowCards(FTable.Game.MongoId);
  acShowCards.Enabled := FALSE;
  ConfigureGUI;
  Render;
end;

procedure TfrmTable.acStandUpExecute(Sender: TObject);
begin
  if not ConfirmStandUp then
    Exit;

  ServerSocket.TableStandUp(FTable.Game.MongoId);
  acStandUp.Enabled := FALSE;
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
  Render;
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

procedure TfrmTable.UpdateClosingTime;
var
  gtc: DWORD;
  ct : DWORD;
begin
  if FTable.Game.State = gsClosing then
  begin
    gtc := GetTickCount;
    ct := FTable.Game.ClosingTime - ServerSocket.TimeOffset;
    if gtc > ct then
      FClosingTime := 0
    else
      FClosingTime := ct - gtc;
  end
  else
    FClosingTime := 0;
end;

procedure TfrmTable.CSEGameChange(const AMethodId: Integer; const AObject: TObject);
begin
  UpdateClosingTime;
  ConfigureGUI;
  Render;
end;

procedure TfrmTable.CSEUserChange(const AMethodId: Integer; const AObject: TObject);
begin
  ConfigureGUI;
  Render;
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
  sitout   : Boolean;
  foldtoany: Boolean;
  seat_bet : UINT32
  ;
  event    : TNotifyEvent;
  C1       : Integer;
  nofocus  : Boolean;
begin
  acStandUp.Enabled := FALSE;
  acFold.Enabled := FALSE;
  acCall.Enabled := FALSE;
  acCheck.Enabled := FALSE;
  acRaise.Enabled := FALSE;
  acPlayNow.Enabled := FALSE;
  acShowCards.Enabled := FALSE;
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
      psInHand, psAllIn: begin
        sitout := TRUE;
        foldtoany := TRUE;
        if (FTableStatus.CurrentSeat = FTable.SeatIndex) and
           (not FTableStatus.Locked) and
           (not tiGameLock.Enabled) then
        begin
          case FTableStatus.State of
            tsIdle: ;
            tsPreFlop,
            tsFlop,
            tsTurn,
            tsRiver: begin
              nofocus := FALSE;
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
                begin
                  nofocus := TRUE;
                  acFold.Execute;
                end;
              end
              else
              begin
                acCheck.Enabled := TRUE;
                acRaise.Caption := 'BET';
                acRaise.Enabled := TRUE;

                if cbFoldToAnyBet.Checked then
                begin
                  nofocus := TRUE;
                  acCheck.Execute;
                end;
              end;

              if not nofocus then
              begin
                for C1 := 0 to Tables.Count - 1 do
                  if tables[C1].Form.Focused then
                  begin
                    nofocus := TRUE;
                    Break;
                  end;

                if (not nofocus) and
                   (not FForceFocused) then
                begin
                  if IsIconic(Handle) then
                    ShowWindow(Handle, SW_RESTORE);
                  BringToFront;
                  SetForegroundWindow(Handle);
                  SetFocus;
                  FForceFocused := TRUE;
                end;
              end;
            end;
            tsWinning,
            tsWinning2: ;
          end;
        end
        else
          FForceFocused := FALSE;

        if (FTableStatus.State in [tsWinning, tsWinning2]) and
           (FTable.SeatIndex = seat_info.SeatIndex) and
           (seat_info.Status in [psInHand, psAllIn]) then
          acShowCards.Enabled := TRUE;
      end;
      psFolded: begin
        sitout := TRUE;
      end;
    end;
  end;

  if (FTableStatus.CurrentSeat <> -1) and
     (not tiActiveFrameBlink.Enabled) and
     (not FTableStatus.Locked) and
     (not tiGameLock.Enabled) then
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
    Assert(FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info));

    FRaiseMin := FTableStatus.MinimumBet + FTable.Game.BigBlind;
    FRaiseMax := FTableStatus.MaximumBet;

    FRaisePresetButtons[0].Action := acRaiseMin;
    FRaisePresetButtons[1].Action := acRaise3BB;
    FRaisePresetButtons[2].Action := acRaisePot;
    FRaisePresetButtons[3].Action := acRaiseMax;

    seRaiseAmount.Properties.MaxValue := FRaiseMax / 100;

    SetRaiseSliderValue(FRaiseMin);
  end
  else
    for C1 := Low(FRaisePresetButtons) to High(FRaisePresetButtons) do
      FRaisePresetButtons[C1].Action := nil;
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
     (seat.Status in [psInHand, psFolded, psAllIn]) then
    result := MessageDlg('Are you sure you want to stand up? This will automatically fold your current hand and any chips that are in the pot.', mtWarning, mbYesNo, 0) = mrYes;
end;

procedure TfrmTable.CSRETableStatus(const AMethodId: Integer; const AObject: TObject);
var
  pbtablestatus  : TPB_TableStatus;
  C1             : Integer;
  seat_index     : Integer;
  cardshow_events: Integer;
  {$IFDEF DEBUG}
  tmp          : String;
  seat         : TSeatInfo;
  tb           : UINT32;
  {$ENDIF}
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

    if FTableStatus.State in [tsFlop, tsTurn, tsRiver, tsWinning, tsWinning2] then
      FFlopAnimated := TRUE;
    if FTableStatus.State in [tsTurn, tsRiver, tsWinning, tsWinning2] then
      FTurnAnimated := TRUE;
    if FTableStatus.State in [tsRiver, tsWinning, tsWinning2] then
      FRiverAnimated := TRUE;
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
    FGoalTime := FTableStatus.Time - ServerSocket.TimeOffset
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

  DebugLn(Format('D: %d; TS: %d; CS: %d; TIME: %d; TB: %d; SEQ: %d; LOCKED: %s', [FTableStatus.Dealer, Integer(FTableStatus.State), FTableStatus.CurrentSeat, FTableStatus.Time, tb, pbtablestatus.Seq, tmp]), ditApplication);
  {$ENDIF}

  FTurnAniDelay := 0;
  FRiverAniDelay := 0;
  FWinningAniDelay := 0;

  cardshow_events := 0;
  for C1 := 0 to pbtablestatus.Events.Count - 1 do
    if pbtablestatus.Events[C1].Event in [teFlop, teTurn, teRiver, teWinning] then
      Inc(cardshow_events);

  if cardshow_events > 1 then
    FTurnAniDelay := 2;

  if cardshow_events > 2 then
    FRiverAniDelay := 3.25;

  if cardshow_events > 3 then
    FWinningAniDelay := 4.25;

  for C1 := 0 to pbtablestatus.Events.Count - 1 do
    ProcessTableEvent(pbtablestatus.Events[C1]);

  ConfigureGUI;
  Render;
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
  event       : String;
  seat_caption: String;
  seat        : TSeatInfo;
  seat_point  : TPoint2;
  seat_index  : Integer;
  pot         : TPB_PotInfo;
  player      : TPlayerInfo;
  C1, C2      : Integer;
  card_index  : Integer;
  iterate     : Boolean;
  nick        : String;
  animation   : TDXAnimation;
  nicks       : String;
  winmsg      : String;
  suffix      : String;
  chips_val   : Single;
  chips_plural: String;
  cc          : Integer;
  flop        : TBytes;
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
      event := 'FOLD';
      seat_caption := 'FOLD';
    end;

    teSit: event := 'SIT';

    teStandUp: begin
      // fixme: animate bet > pot here
      event := 'STAND UP';
    end;

    tePostRiver: begin
      event := 'POST RIVER';

      FTableStatus.PreviousBets := ATableEvent.Bets;
    end;

    teWinning: begin
      EnableGameLockTimer(2 + ATableEvent.Pots.Count * 0.5);

      event := 'WINNING';

      FTableStatus.Pots.Assign(ATableEvent.Pots);

      AnimateBets(FTableStatus.PreviousBets);

      for C1 := 0 to ATableEvent.Pots.Count - 1 do
      begin
        pot := ATableEvent.Pots[C1];

        if (pot.Sum = 0) or (pot.WinnerData.Count = 0) then
          Continue;

        chips_val := (pot.Sum / 100) / pot.WinnerData.Count;

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

          animation := DXTimer.AddAnimation(Handle, GetPotPoint(C1), GetBetPoint(pot.WinnerData[C2].Seat), 0.2, FWinningAniDelay + 1.5 + C1 * 0.5, 0.5);
          animation.Tag := C1;
          animation.TagSingle := chips_val;
          FPotWinAnimations.Add(animation.Id);
        end;
        Delete(nicks, Length(nicks) - 1, 2);

        chips_plural := '';
        if chips_val <> 1 then
          chips_plural := 's';

        suffix := '';
        if pot.WinnerData.Count > 1 then
          suffix := 'each ';

        winmsg := pot.WinnerData[0].Msg;
        if winmsg = 'default' then
          winmsg := ''
        else
          winmsg := Format('(%s)', [pot.WinnerData[0].Msg]);

        Assert(Assigned(animation));
        animation.TagString := Format('%s won %s chip%s %s%s', [nicks, FormatFloat('0.##', chips_val), chips_plural, suffix, winmsg]);
      end;
    end;

    teDealing: begin
      event := 'DEALING';

      FFlopAnimations.Clear;
      FTurnAnimations.Clear;
      FRiverAnimations.Clear;
      FDealAnimations.Clear;
      FBetAnimations.Clear;
      FPotWinAnimations.Clear;

      FFlopAnimated := FALSE;
      FTurnAnimated := FALSE;
      FRiverAnimated := FALSE;

      FChipStackMaker.Clear;

      FTableStatus.FlopCards.Clear;
      FTableStatus.TurnCard.Clear;
      FTableStatus.RiverCard.Clear;

      AnimateBlinds;

      cc := 0;
      card_index := 0;
      repeat
        iterate := FALSE;
        C1 := FTableStatus.SmallBlindSeat;
        repeat
          if FTableStatus.GetSeatInfo(C1, seat) then
          begin
            seat.ResetDealtCards;
            if seat.CardCount > card_index then
            begin
              seat_point := GetSeatPoint(seat.SeatIndex);
              animation := DXTimer.AddAnimation(Handle, Point2(FTableCenter.x - FCardWidth / 2, FTableYOffset),
                                                GetCardPoint(seat, card_index), 0.15, 1.5 + FDealAnimations.Count * 0.05, 0);
              animation.Tag := seat.SeatIndex;
              Inc(cc);
              if cc mod 2 = 0 then
                animation.TagUINT := 1;
              FDealAnimations.Add(animation.Id);
              iterate := TRUE;
            end;
          end;

          Inc(C1);
          if C1 >= FTable.Game.Seats then
            C1 := 0;
        until C1 = FTableStatus.SmallBlindSeat;
        Inc(card_index);
      until not iterate;

      EnableGameLockTimer(1.5 + FDealAnimations.Count * 0.05);
    end;

    teCheck: begin
      tiActiveFrameBlink.Enabled := FALSE;
      event := 'CHECK';
      seat_caption := 'CHECK';

      TablePlaySound(Sounds.SOUND_CHECK);
    end;

    teCall: begin
      tiActiveFrameBlink.Enabled := FALSE;
      event := 'CALL';
      seat_caption := 'CALL';

      TablePlaySound(Sounds.SOUND_PUTCHIPS_SMALL);
    end;

    teRaise: begin
      tiActiveFrameBlink.Enabled := FALSE;
      event := 'RAISE';
      seat_caption := 'RAISE';

      TablePlaySound(Sounds.SOUND_PUTCHIPS_SMALL);
    end;

    teAllIn: begin
      tiActiveFrameBlink.Enabled := FALSE;
      event := 'ALL-IN';
      seat_caption := 'ALL-IN';

      TablePlaySound(Sounds.SOUND_ALLIN);
    end;

    teFlop: begin
      FTableStatus.FlopCards.Assign(ATableEvent.Cards);

      tiActiveFrameBlink.Enabled := FALSE;
      event := 'FLOP';
      EnableGameLockTimer(1.5);
      AnimateBets(ATableEvent.Bets);
    end;

    teTurn: begin
      FTableStatus.TurnCard.Assign(ATableEvent.Cards);

      tiActiveFrameBlink.Enabled := FALSE;
      event := 'TURN';
      EnableGameLockTimer(FTurnAniDelay + 1.5);
      AnimateBets(ATableEvent.Bets);
    end;

    teRiver: begin
      FTableStatus.RiverCard.Assign(ATableEvent.Cards);

      tiActiveFrameBlink.Enabled := FALSE;
      event := 'RIVER';
      EnableGameLockTimer(FRiverAniDelay + 1.5);
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
  seat_bet   : UINT32;
  call_amount: Integer;
begin
  Assert(FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info));
  seat_bet := FTableStatus.GetBet(seat_info.SeatIndex);
  if seat_bet + seat_info.Chips < FTableStatus.MinimumBet then
    call_amount := seat_bet + seat_info.Chips
  else
    call_amount := FTableStatus.MinimumBet;

  ServerSocket.PutChips(FTable.Game.MongoId, call_amount);
end;

procedure TfrmTable.acCheckExecute(Sender: TObject);
begin
  ServerSocket.PutChips(FTable.Game.MongoId, FTableStatus.GetBet(FTable.SeatIndex));
end;

procedure TfrmTable.acFoldExecute(Sender: TObject);
begin
  ServerSocket.Fold(FTable.Game.MongoId);
end;

procedure TfrmTable.acPlayNowExecute(Sender: TObject);
var
  seat  : TSeatInfo;
  sindex: Integer;
begin
  if (FTable.SeatIndex <> -1) and
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
  ServerSocket.PutChips(FTable.Game.MongoId, FRaiseValue);
end;


procedure TfrmTable.acRaisePotExecute(Sender: TObject);
var
  C1         : Integer;
  raise_value: UINT32;
  seat_bet   : UINT32;
begin
  seat_bet := FTableStatus.GetBet(FTable.SeatIndex);

  raise_value := FTableStatus.MinimumBet - seat_bet;
  for C1 := Low(FTableStatus.Bets) to High(FTableStatus.Bets) do
    raise_value := raise_value + FTableStatus.Bets[C1];
  raise_value := raise_value + FTableStatus.MinimumBet;

  SetRaiseSliderValue(raise_value);
end;

procedure TfrmTable.Render;
begin
  DXCore.Device.Render(FTable.SwapChainIndex, RenderEvent, 0);
end;

procedure TfrmTable.SetDXObjectSizes;
const
  TABLE_X_LEFT        = 64;
  TABLE_X_RIGHT       = 64;
  TABLE_Y_TOP         = 66;
  TABLE_Y_BOTTOM      = 133;
  TABLE_Y_OFFSET      = -20;
  TABLE_WIDTH_OF_FORM = 0.8;
var
  C1: Integer;
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

  // calculate seat size
  FSeatWidth := (FDXAreaSize.x - FTableWidth) / 1.5;
  if FTable.Game.Seats = 10 then
    FSeatWidth := FSeatWidth * 0.85;

  FSeatHeight := FSeatWidth / TableResources.SeatAspectRatio;
  FSeatResizeRatio := FSeatWidth / TableResources.SeatLeftImage.Texture[0].Width;
  FSeatActionResizeRatio := FSeatResizeRatio * 1.1;

  // calculate card size
  FCardWidth := TableResources.CardBackgroundImage.Texture[0].Width * FTableResizeRatio;
  FCardHeight := FCardWidth / TableResources.CardAspectRatio;
  FCardArtworkWidth := FCardWidth * (0.48 + FTableResizeRatio / 5);
  FCardArtworkHeight := FCardHeight * 0.85;
  FSeatCardsMaxWidth := FSeatWidth * 0.8;

  // calculate dealer size
  FDealerWidth := TableResources.DealerButtonImage.Texture[0].Width * FTableResizeRatio;
  FDealerHeight := FDealerWidth / TableResources.DealerButtonAspectRatio;

  // calculate chip size
  FChipWidth := TableResources.Chip1Image.Texture[0].Width * FTableResizeRatio;
  FChipHeight := FChipWidth / TableResources.ChipAspectRatio;

  // calculate timebar/timebank size
  FTimebarWidth := TableResources.TimebarImage.Texture[0].Width * FSeatActionResizeRatio;
  FTimebarHeight := FTimebarWidth / TableResources.TimebarAspectRatio;

  // calculate seat frame size
  FSeatActionFrameWidth := TableResources.SeatActionCheck.Texture[0].Width * FSeatActionResizeRatio;
  FSeatActionFrameHeight := FSeatActionFrameWidth / TableResources.SeatActionFrameAspectRatio;

  // calculate lower interface sizes
  FLowerIntfBorder := Round(10 * FTableResizeRatio);

  FActionButtonWidth := TableResources.ActionButtonNormalImage.Texture[0].Width * FTableResizeRatio;
  FActionButtonHeight := FActionButtonWidth / TableResources.ActionButtonAspectRatio;

  FActionButtons[High(FActionButtons)].Point := Point2(FDXAreaSize.x - FLowerIntfBorder * 1.5 - FActionButtonWidth, FDXAreaSize.y - FLowerIntfBorder - FActionButtonHeight);
  for C1 := High(FActionButtons) - 1 downto Low(FActionButtons) do
    FActionButtons[C1].Point := Point2(FActionButtons[C1 + 1].Point.x - FLowerIntfBorder * 2 - FActionButtonWidth, FActionButtons[C1 + 1].Point.y);

  FRaiseSliderWidth := FActionButtons[High(FActionButtons)].Point.x + FActionButtonWidth - FActionButtons[Low(FActionButtons)].Point.x;
  FRaiseSliderHeight := FRaiseSliderWidth / TableResources.RaiseSliderAspectRatio;
  FRaiseSliderResizeRatio := FRaiseSliderWidth / TableResources.RaiseSliderBackgroundImage.Texture[0].Width;

  FRaiseSliderPoint := Point2(FActionButtons[Low(FActionButtons)].Point.x, FActionButtons[Low(FActionButtons)].Point.y - FLowerIntfBorder - FRaiseSliderHeight);

  FRaiseSliderButtonWidth := TableResources.RaiseSliderButtonImage.Texture[0].Width * FRaiseSliderResizeRatio;
  FRaiseSliderButtonHeight := FRaiseSliderButtonWidth * TableResources.RaiseSliderButtonAspectRatio;

  FRaiseSliderButtonBounds.Left := Round(FRaiseSliderPoint.x + TableResources.RAISE_SLIDER_X * FRaiseSliderResizeRatio);
  FRaiseSliderButtonBounds.Top := Round(FRaiseSliderPoint.y + TableResources.RAISE_SLIDER_Y * FRaiseSliderResizeRatio);
  FRaiseSliderButtonBounds.Width := Round(TableResources.RAISE_SLIDER_WIDTH * FRaiseSliderResizeRatio);
  FRaiseSliderButtonBounds.Height := Round(TableResources.RAISE_SLIDER_HEIGHT * FRaiseSliderResizeRatio);

  FRaiseSliderButtonPoint := Point2(FRaiseSliderButtonBounds.Left + FRaiseSliderButtonBounds.Width * FRaiseSliderPosition,
                                    FRaiseSliderButtonBounds.Top + FRaiseSliderButtonBounds.Height / 2);

  FRaisePresetButtonWidth := TableResources.RaisePresetButtonNormalImage.Texture[0].Width * FTableResizeRatio;
  FRaisePresetButtonHeight := FRaisePresetButtonWidth / TableResources.RaisePresetButtonAspectRatio;
  FRaisePresetButtons[High(FRaisePresetButtons)].Point := Point2(FRaiseSliderPoint.x + FRaiseSliderWidth - FRaisePresetButtonWidth,
                                                                 FRaiseSliderPoint.y - FLowerIntfBorder / 2.5 - FRaisePresetButtonHeight);
  for C1 := High(FRaisePresetButtons) - 1 downto Low(FRaisePresetButtons) do
    FRaisePresetButtons[C1].Point := Point2(FRaisePresetButtons[C1 + 1].Point.x - FLowerIntfBorder - FRaisePresetButtonWidth, FRaisePresetButtons[C1 + 1].Point.y);

  FStandUpResizeRatio := FTableResizeRatio * 1.5;
  if FStandUpResizeRatio > 1 then
    FStandUpResizeRatio := 1;

  FStandUpButtonWidth := TableResources.StandUpButtonNormalImage.Texture[0].Width * FStandUpResizeRatio;
  FStandUpButtonHeight := FStandUpButtonWidth / TableResources.StandUpButtonAspectRatio;

  FStandUpButton.Point.x := ClientWidth - FStandUpButtonWidth + 1;
  FStandUpButton.Point.y := -1;

  FPlayNowResizeRatio := FTableResizeRatio * 1.38;
  if FPlayNowResizeRatio > 1 then
    FPlayNowResizeRatio := 1;

  FPlayNowButtonWidth := TableResources.PlayNowButtonNormalImage.Texture[0].Width * FPlayNowResizeRatio;
  FPlayNowButtonHeight := FPlayNowButtonWidth / TableResources.PlayNowButtonAspectRatio;

  FPlayNowButton.Point.x := rvChat.Left + rvChat.Width + (ClientWidth - (rvChat.Left + rvChat.Width)) / 2 - FPlayNowButtonWidth / 2;
  FPlayNowButton.Point.y := rvChat.Top + (ClientHeight - rvChat.Top) / 2.5 - FPlayNowButtonHeight / 2;

  if seRaiseAmount.Height < 19 then
    seRaiseAmount.Style.Font.Size := 7
  else
    if seRaiseAmount.Height < 22 then
      seRaiseAmount.Style.Font.Size := 9
    else
      seRaiseAmount.Style.Font.Size := 10
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

procedure TfrmTable.TablePlaySound(const ASound: String);
begin
  if GetForegroundWindow = Handle then
    Sounds.Play(ASound);
end;

procedure TfrmTable.RenderEvent(Sender: TObject);
begin
  SetDXObjectSizes;

  RenderBackground;
  RenderTable;
  RenderClosingText;
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

procedure TfrmTable.RenderScaleFont(const AText: String; const AColor: TColor2; const AMidPoint: TPoint2; const AFonts: array of TAsphyreFont; const ALowBound, AMinIndex, AMaxIndex, AKerning: Integer; const AMaxHeight, AMaxWidth: Single);
var
  index : Integer;
  font  : TAsphyreFont;
  lb, hb: Integer;
begin
  lb := AMinIndex - ALowBound;
  hb := AMaxIndex - ALowBound;
  index := hb;
  font := AFonts[index];
  font.Kerning := AKerning;
  font.Scale := 1;
  while ((AMaxHeight <> 0) and (font.TextHeight(AText) > AMaxHeight)) or
        ((AMaxWidth <> 0) and (font.TextWidth(AText) > AMaxWidth)) do
  begin
    if index > lb then
    begin
      Dec(index);
      font := AFonts[index];
      font.Kerning := AKerning;
      font.Scale := 1;
    end
    else
      font.Scale := font.Scale - 0.01;
  end;

  font.TextMidF(AMidPoint, AText, AColor);
end;

procedure TfrmTable.RenderSeat(const ASeatIndex: Integer);
var
  seat_point             : TPoint2;
  seat_info              : TSeatInfo;
  player_info            : TPlayerInfo;
  seat_image             : TAsphyreImage;
  seat_empty_image       : TAsphyreImage;
  seat_inactive_image    : TAsphyreImage;
  seat_active_image      : TAsphyreImage;
  action_image           : TAsphyreImage;
//  seat_light_image       : TAsphyreImage;
  avatar                 : TAvatar;
  avatar_point           : TPoint2;
  avatar_width           : Single;
  avatar_height          : Single;
  seat_upper_text        : String;
  seat_lower_text        : String;
  seat_upper_text_color  : TColor2;
  seat_lower_text_color  : TColor2;
  seat_upper_text_point  : TPoint2;
  seat_lower_text_point  : TPoint2;
  seat_text_x_center     : Single;
  card_point             : TPoint2;
  seat_action_frame_point: TPoint2;
  C1                     : Integer;
begin
  // get seat point
  seat_point := GetSeatPoint(ASeatIndex);

  // calculate seat elements positions & dimensions
  avatar_width := TableResources.SEAT_AVATAR_WIDTH * FSeatResizeRatio;
  avatar_height := TTableResources.SEAT_AVATAR_HEIGHT * FSeatResizeRatio;

  if GetTableSector(seat_point) in [tsLeft, tsTopLeft, tsBottomLeft] then
  begin
    seat_empty_image := TableResources.SeatLeftEmptyImage;
    seat_inactive_image := TableResources.SeatLeftImage;
    seat_active_image := TableResources.SeatLeftActiveImage;

    avatar_point := Point2(seat_point.X - FSeatWidth / 2 + TableResources.SEAT_LEFT_AVATAR_X * FSeatResizeRatio, seat_point.Y);
    seat_text_x_center := seat_point.X - (seat_point.X + FSeatWidth / 2 - avatar_point.X) / 2 - 10 * FSeatResizeRatio;
  end
  else
  begin
    seat_empty_image := TableResources.SeatRightEmptyImage;
    seat_inactive_image := TableResources.SeatRightImage;
    seat_active_image := TableResources.SeatRightActiveImage;

    avatar_point := Point2(seat_point.X - FSeatWidth / 2 + TableResources.SEAT_RIGHT_AVATAR_X * FSeatResizeRatio, seat_point.Y);
    seat_text_x_center := seat_point.X + (avatar_point.X - (seat_point.X - FSeatWidth / 2) - 10 * FSeatResizeRatio);
  end;
  seat_upper_text_point := Point2(seat_text_x_center, seat_point.Y - FSeatHeight / 4.5);
  seat_lower_text_point := Point2(seat_text_x_center, seat_point.Y + FSeatHeight / 5);
  seat_action_frame_point := Point2(seat_point.x, seat_point.Y + FSeatHeight / 2 + FSeatActionFrameHeight / 2.15);

  // seat taken and its not in psStandingUp state
  if (FTableStatus.GetSeatInfo(ASeatIndex, seat_info)) and
     (seat_info.Status <> psStandingUp) then
  begin
    // find player info
    Players.FindPlayerById(seat_info.PlayerMongoId, player_info);

    // set seat image that we should render
    if (FTableStatus.CurrentSeat = seat_info.SeatIndex) and
       (not FTableStatus.Locked) and
       (not tiGameLock.Enabled) then
    begin
{      if tiActiveFrameBlink.Tag = 1 then
        seat_image := active_seat_light_image
      else
        seat_image := active_seat_dark_image;}
      seat_image := seat_active_image;
    end
    else
      seat_image := seat_inactive_image;

    if Assigned(player_info) then
    begin
      // set avatar
      avatar := Avatars.Add(player_info.AvatarId, nil);

      // set seat upper text
      seat_upper_text := player_info.Nick;
      seat_upper_text_color := cColor2($FFCCCCCC);
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

    // set seat action
    action_image := nil;
    if seat_info.Caption = 'CALL' then
      action_image := TableResources.SeatActionCall;
    if seat_info.Caption = 'CHECK' then
      action_image := TableResources.SeatActionCheck;
    if seat_info.Caption = 'RAISE' then
      action_image := TableResources.SeatActionRaise;
    if seat_info.Caption = 'FOLD' then
      action_image := TableResources.SeatActionFold;
    if seat_info.Caption = 'DISCONNECTED' then
      action_image := TableResources.SeatActionDisconnected;

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
      DXCore.Canvas.TexMap(pBounds4(avatar_point.X - avatar_width / 2, avatar_point.Y - avatar_height / 2, avatar_width, avatar_height), clWhite4);
    end;

    // render seat
    DXCore.Canvas.UseImage(seat_image, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(seat_point.X - FSeatWidth / 2, seat_point.Y - FSeatHeight / 2, FSeatWidth, FSeatHeight), clWhite4);

    // render upper seat text
    RenderScaleFont(seat_upper_text, seat_upper_text_color, seat_upper_text_point, TableResources.BarmenoFonts, Low(TableResources.BarmenoFonts),
                    Low(TableResources.BarmenoFonts), 16, 0, FSeatHeight * 0.36, FSeatWidth * 0.75);

    // render lower seat text
    RenderScaleFont(seat_lower_text, seat_lower_text_color, seat_lower_text_point, TableResources.BarmenoFonts, Low(TableResources.BarmenoFonts),
                    Low(TableResources.BarmenoFonts), High(TableResources.BarmenoFonts), 0, FSeatHeight * 0.37, FSeatWidth * 0.75);

    // render seat action frame/text
    if Assigned(action_image) then
    begin
      // render seat action frame
      DXCore.Canvas.UseImage(action_image, TexFull4);
      DXCore.Canvas.TexMap(pBounds4(seat_action_frame_point.X - FSeatActionFrameWidth / 2,
           seat_action_frame_point.Y - FSeatActionFrameHeight / 2, FSeatActionFrameWidth, FSeatActionFrameHeight), clWhite4);
{
      // render seat action text
      RenderScaleFont(seat_action_text, seat_action_text_color, seat_action_frame_point, TableResources.SintonyFonts, Low(TableResources.SintonyFonts),
                      10, 16, 2, FSeatActionFrameHeight * 0.75, FSeatActionFrameWidth * 0.9);
}
    end;
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

  procedure RenderSingleCard(const ACard: TCard; const AAnimationsList: TList<Integer>; var AIsAnimated: Boolean; var ACurrentCardPoint: TPoint2; var AShowCard: Integer; const AAnimateFrom, AAnimateTo: TPoint2; const ADelay: Single);
  var
    animation: TDXAnimation;
    C1       : Integer;
  begin
    if ACard.Value <> cvUnknown then
    begin
      if not AIsAnimated then
      begin
        AAnimationsList.Clear;
        animation := DXTimer.AddAnimation(Handle, AAnimateFrom, AAnimateTo, 0.15, ADelay, 0); AAnimationsList.Add(animation.Id);
        AIsAnimated := TRUE;
      end;

      if AAnimationsList.Count > 0 then
      begin
        for C1 := 0 to AAnimationsList.Count - 1 do
          if DXTimer.Find(Handle, AAnimationsList[C1], animation) then
          begin
            ACurrentCardPoint := animation.CurrPoint;
            if animation.Status = asAnimating then
              AShowCard := 1;
          end;
      end
      else
        AShowCard := 1;

      case AShowCard of
        -1: ;
         0: RenderCard(ACurrentCardPoint, nil, 1);
         1: RenderCard(ACurrentCardPoint, ACard, 1);
      end;
    end;
  end;

var
  C1               : Integer;
  card_points_curr : array of TPoint2;
  card_points_mid  : array of TPoint2;
  card_points_final: array of TPoint2;
  show_cards       : array of Integer; // -1 - hide completely, 0 - card face down, 1 - card face up
  animation        : TDXAnimation;
begin
  SetLength(card_points_final, 5);
  SetLength(card_points_curr, 5);
  SetLength(card_points_mid, 5);
  SetLength(show_cards, 5);
  for C1 := Low(card_points_final) to High(card_points_final) do
  begin
    card_points_final[C1].x := FTableCenter.X - (FCardWidth * 5) / 2 - 4 * 3 + (C1 * FCardWidth) + (C1 * 3);
    card_points_final[C1].y := FTableCenter.Y - FCardHeight / 2;
    card_points_curr[C1] := card_points_final[C1];
    card_points_mid[C1] := card_points_final[C1];
    show_cards[C1] := -1;
  end;
  card_points_mid[0].x := card_points_final[0].x - 5;
  card_points_mid[1].x := card_points_final[0].x - 0;
  card_points_mid[2].x := card_points_final[0].x + 5;
//  card_points_mid[3].x := card_points_final[3].x + FCardWidth / 2;
//  card_points_mid[4].x := card_points_final[4].x + FCardWidth / 2;

  if FTableStatus.FlopCards.Count > 0 then
  begin
    if not FFlopAnimated then
    begin
      FFlopAnimations.Clear;

      animation := DXTimer.AddAnimation(Handle, FDealerPoint, card_points_mid[0], 0.15, 0.9, 0); animation.Tag := 0; FFlopAnimations.Add(animation.Id);
      animation := DXTimer.AddAnimation(Handle, FDealerPoint, card_points_mid[1], 0.15, 0.9, 0); animation.Tag := 1; FFlopAnimations.Add(animation.Id);
      animation := DXTimer.AddAnimation(Handle, FDealerPoint, card_points_mid[2], 0.15, 0.9, 0); animation.Tag := 2; FFlopAnimations.Add(animation.Id);

      animation := DXTimer.AddAnimation(Handle, card_points_mid[0], card_points_final[0], 0.2, 1.1, 0); animation.Tag := 0; FFlopAnimations.Add(animation.Id);
      animation := DXTimer.AddAnimation(Handle, card_points_mid[1], card_points_final[1], 0.2, 1.1, 0); animation.Tag := 1; FFlopAnimations.Add(animation.Id);
      animation := DXTimer.AddAnimation(Handle, card_points_mid[2], card_points_final[2], 0.2, 1.1, 0); animation.Tag := 2; FFlopAnimations.Add(animation.Id);

      FFlopAnimated := TRUE;
    end;

    if FFlopAnimations.Count > 0 then
    begin
      for C1 := 0 to FFlopAnimations.Count - 1 do
        if (DXTimer.Find(Handle, FFlopAnimations[C1], animation)) and
           (animation.Status = asAnimating) then
        begin
          card_points_curr[animation.Tag] := animation.CurrPoint;
          if FFlopAnimations.Count > 3 then
            show_cards[animation.Tag] := 0
          else
            show_cards[animation.Tag] := 1;
        end;
    end
    else
    begin
      show_cards[0] := 1;
      show_cards[1] := 1;
      show_cards[2] := 1;
    end;

    for C1 := 0 to FTableStatus.FlopCards.Count - 1 do
      case show_cards[C1] of
        -1: Continue;
         0: RenderCard(card_points_curr[C1], nil, 1);
         1: RenderCard(card_points_curr[C1], FTableStatus.FlopCards[C1], 1);
      end;
  end;

  RenderSingleCard(FTableStatus.TurnCard, FTurnAnimations, FTurnAnimated, card_points_curr[3], show_cards[3], FDealerPoint, card_points_final[3], 0.75 + FTurnAniDelay);
  RenderSingleCard(FTableStatus.RiverCard, FRiverAnimations, FRiverAnimated, card_points_curr[4], show_cards[4], FDealerPoint, card_points_final[4], 0.75 + FRiverAniDelay);
end;

procedure TfrmTable.RenderDealingCardsAni;
var
  C1       : Integer;
  animation: TDXAnimation;
begin
  for C1 := 0 to FDealAnimations.Count - 1 do
    if (DXTimer.Find(Handle, FDealAnimations[C1], animation)) and
       (animation.Status = asAnimating) then
    begin
      RenderCard(animation.CurrPoint, nil, 1);
      if animation.TagUINT = 1 then
      begin
        TablePlaySound(Sounds.SOUND_DEALING);
        animation.TagUINT := 0;
      end;
    end;
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
  animation  : TDXAnimation;
begin
  if FBetAnimations.Count > 0 then
  begin
    for C1 := 0 to FBetAnimations.Count - 1 do
      if DXTimer.Find(Handle, FBetAnimations[C1], animation) then
      begin
        if (animation.Tag = 1) or (animation.Status = asAnimating) then
        begin
          chips_stack := FChipStackMaker.MakeStack(Trunc(animation.TagUINT / 100));
          RenderChipStack(animation.CurrPoint, chips_stack);

          if animation.Tag = 0 then
            RenderValue(animation.CurrPoint, animation.TagUINT / 100, clWhite2, FALSE);

          if animation.TagSingle = 1 then
          begin
            animation.TagSingle := 0;
            TablePlaySound(Sounds.SOUND_PUTCHIPS_SMALL);
          end;
        end;
      end;
  end
  else
    for C1 := 0 to FTableStatus.Seats.Count - 1 do
      if FTableStatus.GetSeatInfo(FTableStatus.Seats[C1].SeatIndex, seat_info) then
      begin
        if (Length(FTableStatus.Bets) > seat_info.SeatIndex) and
           (FTableStatus.Bets[seat_info.SeatIndex] > 0) then
        begin
          stack_value := FTableStatus.Bets[seat_info.SeatIndex] / 100;
          chips_point := GetBetPoint(seat_info.SeatIndex);
          chips_stack := FChipStackMaker.MakeStack(Trunc(stack_value));
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
  pots := FTableStatus.Pots;

  if FPotWinAnimations.Count > 0 then
  begin
    for C1 := 0 to FPotWinAnimations.Count - 1 do
      if (DXTimer.Find(Handle, FPotWinAnimations[C1], animation)) and
         (animation.Status = asAnimating) then
      begin
        chips_stack := FChipStackMaker.MakeStack(Trunc(animation.TagSingle));
        RenderChipStack(animation.CurrPoint, chips_stack);

        if animation.TagString <> '' then
        begin
          AddDealerChatMessage(animation.TagString);
          animation.TagString := '';
        end;

        if (animation.Tag < 0) or (animation.Tag >= FTableStatus.Pots.Count) then
        begin
          // pots changed in meantime, due to too fast play probably
          {$IFDEF DEBUG} DebugLn(Format('Nasty bug - animation.Tag = %d, Length(FTableStatus.Pots) = %d', [animation.Tag, FTableStatus.Pots.Count]), ditException); {$ENDIF}
        end
        else
          if animation.TagSingle * 100 > FTableStatus.Pots[animation.Tag].Value then
            FTableStatus.Pots[animation.Tag].Value := 0
          else
            FTableStatus.Pots[animation.Tag].Value := FTableStatus.Pots[animation.Tag].Value - Trunc(animation.TagSingle * 100);
      end;
  end;

  if FBetAnimations.Count > 0 then
    pots := FTableStatus.PreviousPots;

  for C1 := 0 to pots.Count - 1 do
  begin
    pot := pots[C1].Value / 100;
    if pot = 0 then
      Continue;

    pot_point := GetPotPoint(C1);
    if (pot_point.X > 0) and (pot_point.Y > 0) then
    begin
      chips_stack := FChipStackMaker.MakeStack(Trunc(pot));
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
  if Length(AChipStack.Images) = 0 then
    Exit;

  for C1 := Low(AChipStack.Images) to High(AChipStack.Images) do
  begin
    DXCore.Canvas.UseImage(AChipStack.Images[C1], TexFull4);
    DXCore.Canvas.TexMap(pBounds4(APoint.X - FChipWidth / 2,
        APoint.Y - C1 * 5 * FTableResizeRatio, FChipWidth, FChipHeight), clWhite4);
  end;
end;

procedure TfrmTable.RenderClosingText;
var
  mins       : Integer;
  minute_text: String;
  txt        : String;
begin
  case FTable.Game.State of
    gsClosing: begin
      UpdateClosingTime;

      if FClosingTime = 0 then
        txt := 'Table is closing after curent hand'
      else
      begin
        mins := FClosingTime div 60000;
        if mins = 1 then
          minute_text := 'minute'
        else
          minute_text := 'minutes';
        txt := Format('Table is closing in %d %s', [mins, minute_text]);
      end;

      RenderScaleFont(txt, clWhite2, Point2(FTableCenter.x, FTableCenter.Y + FCardHeight / 3), TableResources.SintonyFonts,
                      Low(TableResources.SintonyFonts), 12, 16, 2, 8 + 8 * FTableResizeRatio, 0);
    end;

    gsClosed: RenderScaleFont('Table is closed', clWhite2, Point2(FTableCenter.x, FTableCenter.Y + FCardHeight / 3), TableResources.SintonyFonts,
                        Low(TableResources.SintonyFonts), 12, 16, 2, 8 + 8 * FTableResizeRatio, 0);

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
     (FGoalTime = 0) or
     (tiGameLock.Enabled) then
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
  C1      : Integer;
  button  : TUIButton;
  font    : TAsphyreFont;
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

    // render raise thumb
    DXCore.Canvas.UseImage(TableResources.RaiseSliderButtonImage, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(FRaiseSliderButtonPoint.x - FRaiseSliderButtonWidth / 2,
                                  FRaiseSliderButtonPoint.y - FRaiseSliderButtonHeight / 2,
                                  FRaiseSliderButtonWidth, FRaiseSliderButtonHeight), clWhite4);

    // render raise preset buttons
    for C1 := Low(FRaisePresetButtons) to High(FRaisePresetButtons) do
    begin
      button := FRaisePresetButtons[C1];
      if not Assigned(button.Action) then
        Continue;

      DXCore.Canvas.UseImage(button.Image, TexFull4);
      DXCore.Canvas.TexMap(pBounds4(button.Point.x, button.Point.y, FRaisePresetButtonWidth, FRaisePresetButtonHeight), clWhite4);

      font := TableResources.SintonyFonts[High(TableResources.SintonyFonts)];
      font.Kerning := 0;
      if Integer(FMouseDownObject) - Integer(mdoRaisePresetButton1) = C1 then
        font.Scale := FTableResizeRatio * 0.65
      else
        font.Scale := FTableResizeRatio * 0.75;
      font.TextMidF(Point2(button.Point.x + FRaisePresetButtonWidth / 2, button.Point.y + FRaisePresetButtonHeight / 2), button.Action.Caption, cColor2($FFAAAAAA));
    end;
  end;

  // render action buttons
  for C1 := Low(FActionButtons) to High(FActionButtons) do
  begin
    button := FActionButtons[C1];
    if not Assigned(button.Action) then
      Continue;

    DXCore.Canvas.UseImage(button.Image, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(button.Point.x, button.Point.y, FActionButtonWidth, FActionButtonHeight), clWhite4);

    font := TableResources.SintonyFonts[High(TableResources.SintonyFonts)];
    font.Kerning := 0;
    if Integer(FMouseDownObject) - Integer(mdoActionButton1) = C1 then
      font.Scale := FTableResizeRatio * 0.80
    else
      font.Scale := FTableResizeRatio * 0.90;
    font.TextMidF(Point2(button.Point.x + FActionButtonWidth / 2, button.Point.y + FActionButtonHeight / 2), button.Action.Caption, clWhite2);
  end;

  // render standup button
  if acStandup.Enabled then
  begin
    DXCore.Canvas.UseImage(FStandUpButton.Image, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(FStandUpButton.Point.x, FStandUpButton.Point.y, FStandUpButtonWidth, FStandUpButtonHeight), clWhite4);
  end;

  // render playnow button
  if acPlayNow.Enabled then
  begin
    DXCore.Canvas.UseImage(FPlayNowButton.Image, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(FPlayNowButton.Point.x, FPlayNowButton.Point.y, FPlayNowButtonWidth, FPlayNowButtonHeight), clWhite4);
  end;
end;


procedure TfrmTable.AnimateBets(const ABets: TArray<UINT32>);
var
  C1       : UINT32;
  bet_point: TPoint2;
  pot_point: TPoint2;
  animation: TDXAnimation;
begin
  if Length(ABets) = 0 then
    Exit;

  for C1 := Low(ABets) to High(ABets) do
    if ABets[C1] > 0 then
    begin
      bet_point := GetBetPoint(C1);

      pot_point := GetPotPoint(0);
      animation := DXTimer.AddAnimation(Handle, bet_point, pot_point, 0.25, 0.2, 0);
      animation.Tag := 1;
      animation.TagUINT := ABets[C1];
      FBetAnimations.Add(animation.Id);
    end;
end;

procedure TfrmTable.AnimateBlinds;
var
  bet_point: TPoint2;
  animation: TDXAnimation;
begin
  if (FTableStatus.SmallBlindSeat < 0) or (FTableStatus.SmallBlindSeat > Length(FTableStatus.Bets) - 1) or
     (FTableStatus.BigBlindSeat < 0) or (FTableStatus.BigBlindSeat > Length(FTableStatus.Bets) - 1) then
    Exit;

  bet_point := GetBetPoint(FTableStatus.SmallBlindSeat);
  animation := DXTimer.AddAnimation(Handle, bet_point, bet_point, 0.1, 0.1, 0.9);
  animation.TagUINT := FTableStatus.Bets[FTableStatus.SmallBlindSeat];
  animation.TagSingle := 1;
  FBetAnimations.Add(animation.Id);

  bet_point := GetBetPoint(FTableStatus.BigBlindSeat);
  animation := DXTimer.AddAnimation(Handle, bet_point, bet_point, 0.1, 0.5, 0.5);
  animation.TagUINT := FTableStatus.Bets[FTableStatus.BigBlindSeat];
  animation.TagSingle := 1;
  FBetAnimations.Add(animation.Id);
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

  if animation.Status = asDone then
  begin
    if FFlopAnimations.Contains(animation.Id) then
      FFlopAnimations.Remove(animation.Id);
    if FTurnAnimations.Contains(animation.Id) then
      FTurnAnimations.Remove(animation.Id);
    if FRiverAnimations.Contains(animation.Id) then
      FRiverAnimations.Remove(animation.Id);
    if FBetAnimations.Contains(animation.Id) then
      FBetAnimations.Remove(animation.Id);
    if FPotWinAnimations.Contains(animation.Id) then
      FPotWinAnimations.Remove(animation.Id);
    if FDealAnimations.Contains(animation.Id) then
    begin
      seat_index := animation.Tag;
      if FTableStatus.GetSeatInfo(seat_index, seat) then
        seat.IncDealtCards;
      FDealAnimations.Remove(animation.Id);
    end;
  end;
end;

procedure TfrmTable.Button1Click(Sender: TObject);
begin
  ServerSocket.QueryTableStats([FTable.Game.MongoId]);
end;

end.

