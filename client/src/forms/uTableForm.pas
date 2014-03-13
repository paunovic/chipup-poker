unit uTableForm;

{
  ISSUES:
    - teSit happens before player receives TableStatus. Means, if any processing is done in teSit, there would be no info for new player in seat
}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, cxGraphics, cxControls, cxLookAndFeels,  uPaintPanel,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, cxMemo,  Vcl.Menus, cxButtons, uTableStatus, uDXTimer, uDXAnimation, Vectors2,
  Vcl.ActnList, cxLabel, uTables, cxTextEdit, dxsChipUpDark, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, dxsChipUpDarkTabs, dxsChipUpRedButton,
  cxRichEdit, cxMaskEdit, cxSpinEdit, cxTrackBar, cxCheckBox, Vectors2px, uPB_TableEvent, uCards, System.Types, uChipsStackMaker;

type
  TfrmTable = class(TForm)
    paBottom: TPanel;
    paChat: TPanel;
    edChat: TcxTextEdit;
    ActionManager: TActionManager;
    acStandUp: TAction;
    acFold: TAction;
    acCall: TAction;
    acCheck: TAction;
    acRaise: TAction;
    paButtons: TPanel;
    btAction1: TcxButton;
    btAction2: TcxButton;
    btAction3: TcxButton;
    btStandUp: TcxButton;
    reChat: TcxRichEdit;
    seRaiseAmount: TcxSpinEdit;
    tbRaise: TcxTrackBar;
    tiActiveFrameBlink: TTimer;
    btPlayNow: TcxButton;
    acPlayNow: TAction;
    tiSitOutNextHand: TTimer;
    tiSeatCaptionClear: TTimer;
    acRaiseMin: TAction;
    acRaise3BB: TAction;
    acRaisePot: TAction;
    acRaiseMax: TAction;
    cbFoldToAnyBet: TcxCheckBox;
    cbSitOutNextHand: TcxCheckBox;
    cbSitOutNextBB: TcxCheckBox;
    btRaiseMin: TcxButton;
    btRaise3BB: TcxButton;
    btRaisePot: TcxButton;
    btRaiseMax: TcxButton;
    tiSitOutNextBB: TTimer;
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
    procedure tbRaisePropertiesChange(Sender: TObject);
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

      CARD_OPEN_PERC   = 0.55;
      CARD_HIDDEN_PERC = 0.35;

    type
      TTableSector = (tsTopLeft, tsTop, tsTopRight, tsRight, tsBottomRight, tsBottom, tsBottomLeft, tsLeft, tsMid);

    var
      FCallbacksId       : Integer;
      FFormAspectRatio   : Single;
      FTableResizeRatio  : Single;
      FRawTableWidth     : Single;
      FRawTableHeight    : Single;
      FRawTableXOffset   : Single;
      FRawTableYOffset   : Single;
      FTableWidth        : Single;
      FTableHeight       : Single;
      FTableXOffset      : Single;
      FTableYOffset      : Single;
      FTableCenter       : TPoint2;
      FDealerPoint       : TPoint2;
      FTableCenterYOffset: Single;
      FSeatSizeMultiplier: Single;
      FSeatWidth         : Single;
      FSeatHeight        : Single;
      FSeatCardsMaxWidth : Single;
      FCardWidth         : Single;
      FCardHeight        : Single;
      FCardArtworkWidth  : Single;
      FCardArtworkHeight : Single;
      FChipWidth         : Single;
      FChipHeight        : Single;
      FDealerWidth       : Single;
      FDealerHeight      : Single;
      FTimebarWidth      : Single;
      FTimebarHeight     : Single;

      FDXAreaSize        : TPoint2px;

      FPaintPanel        : TPaintPanel;

      FTable             : TTable;
      FTableStatus       : TTableStatus;
      FChipsStackMaker   : TChipsStackMaker;

      FGoalTime          : UINT32;
      FCurrentPlaytime   : Integer;

      FFlopAnimations    : Integer;
      FTurnAnimations    : Integer;
      FRiverAnimations   : Integer;
      FDealAnimations    : Integer;

    procedure PaintPanelPaint(Sender: TObject);
    procedure PaintPanelClick(Sender: TObject);
    procedure CalculateFormElementsSize;

    procedure DoCalculations;

    procedure Render;
    procedure RenderEvent(Sender: TObject);
    procedure RenderBackground;
    procedure RenderTable;
    procedure RenderSeats;
    procedure RenderSeat(const ASeatIndex: Integer);
    procedure RenderCard(const APoint: TPoint2; const ACard: TCard; const APercentage: Single);
    procedure RenderTableCards;
    procedure RenderDealingCards;
    procedure RenderDealerButton;
    procedure RenderPlayerBets;
    procedure RenderPots;
    procedure RenderChipStack(const APoint: TPointF; const AChipStack: TChipsStack; const AValue: Single);
    procedure RenderTimebar;

    procedure AddUserChatMessage(const AUser, AMessage: String);
    procedure ModalFormClose(Sender: TObject);

    function ConfirmLeaveTable: Boolean;
    function ConfirmStandUp: Boolean;

    function GetTableSector(const APoint: TPointF): TTableSector;
    function GetSeatPoint(const ASeatIndex: Integer): TPointF;
    function GetCardPoint(const ASeatInfo: TSeatInfo; const ACardIndex: Integer): TPoint2;
    function GetDealerPoint(const ASeatIndex: Integer): TPointF;
    function GetBetPoint(const ASeatIndex: Integer): TPointF;
    function GetPotPoint(const APotIndex: Integer): TPointF;

    procedure CSRChatEvent(const AMethodId: Integer; const AObject: TObject);
    procedure CSRETableStatus(const AMethodId: Integer; const AObject: TObject);
    procedure ProcessTableEvent(const ATableEvent: TPB_TableEvent);

    procedure ConfigureGUI;

    procedure AnimationCallback(const AAnimation: TDXAnimation);

  protected
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure WMSizing(var AMessage: TMessage); message WM_SIZING;
    procedure WndProc(var AMessage: TMessage); override;

  public
    constructor Create(const ATable: TTable); reintroduce;

    property PaintPanel: TPaintPanel read FPaintPanel;
  end;

implementation

{$R *.dfm}

uses
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  cxClasses, System.Math, AsphyreBitmaps, AsphyreJPG, uMessageContainer, uServerSettings,
  uMessageCallbacks, uServerCodes, uPB_ChatEvent, uPB_ChatMessage, uPB_SeatInfo, uTableResources,
  AsphyreTypes, AsphyreImages, NativeConnectors, uDXCore, AsphyreFonts, uFormsContainer,
  uSocketClient, uCommon, uTableSitForm, uMainDataModule, uPlayerInfo, uAvatars, uPB_TableStatus, uPB_PotInfo;


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

  FTableStatus := TTableStatus.Create;
  FChipsStackMaker := TChipsStackMaker.Create;

  FPaintPanel := TPaintPanel.Create(self, PaintPanelPaint);
  FPaintPanel.SendToBack;
  FPaintPanel.OnClick := PaintPanelClick;

  FFormAspectRatio := ClientWidth / ClientHeight;
  Constraints.MinHeight := Round(Constraints.MinWidth / FFormAspectRatio);

  reChat.Lines.Clear;
  Caption := Format('%s - %s (%d/%d %s)', [FTable.Club.Name, FTable.Game.Name, Round(FTable.Game.SmallBlind / 100), Round(FTable.Game.BigBlind / 100), FTable.Game.GameTypeStrFull]);
end;

procedure TfrmTable.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveCallbacks(FCallbacksId);

  DXTimer.RemoveAnimations(Handle);

  FPaintPanel.Free;
  FChipsStackMaker.Free;
  FTableStatus.Free;
end;

procedure TfrmTable.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.ExStyle := AParams.ExStyle or WS_EX_APPWINDOW;
  AParams.WndParent := 0;
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

  if Assigned(DXCore.Device) then
  begin
    CalculateFormElementsSize;
    DXCore.Device.Resize(FTable.SwapChainIndex, FDXAreaSize);
    Render;
  end;
end;

procedure TfrmTable.CalculateFormElementsSize;
begin
  paBottom.Height := Round(ClientHeight / 5);
  paChat.Width := Round(paBottom.Width / 2.75);

  FDXAreaSize := Point2px(FPaintPanel.Width, FPaintPanel.Height);
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

  inherited;
end;

procedure TfrmTable.PaintPanelClick(Sender: TObject);
var
  C1               : Integer;
  seat_info        : TSeatInfo;
  client_cursor_pos: TPoint;
  seat_point       : TPointF;
  seat_rect        : TRectF;
begin
  client_cursor_pos := ScreenToClient(Mouse.CursorPos);

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

procedure TfrmTable.PaintPanelPaint(Sender: TObject);
begin
  Render;
end;

procedure TfrmTable.seRaiseAmountPropertiesChange(Sender: TObject);
var
  val: Single;
begin
  if (TryStrToFloat(seRaiseAmount.Text, val)) and
     (val >= tbRaise.Properties.Min / 100) and
     (val <= tbRaise.Properties.Max / 100) then
  begin
    tbRaise.Properties.OnChange := nil;
    tbRaise.Position := Round(val * 100);
    tbRaise.Properties.OnChange := tbRaisePropertiesChange;
  end;
end;

procedure TfrmTable.tbRaisePropertiesChange(Sender: TObject);
begin
  seRaiseAmount.Value := tbRaise.Position / 100;
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

function TfrmTable.GetSeatPoint(const ASeatIndex: Integer): TPointF;
var
  seat_radians: Double;
  x, y        : Single;
begin
  seat_radians := TTableResources.SEAT_POINTS[FTable.Game.Seats, ASeatIndex];

  x := FTableCenter.X + (FTableWidth / 2) * Cos(seat_radians);
  y := FTableCenter.Y - FTableCenterYOffset + (FTableHeight / 2) * Sin(seat_radians);

  result := PointF(x, y);

  case GetTableSector(result) of
    tsTopLeft: result.Offset(-FSeatWidth / 2.3, -FSeatHeight / 4.5);
    tsLeft: result.Offset(-FSeatWidth / 2.5, 0);
    tsBottomLeft: result.Offset(-FSeatWidth / 2.3, -FSeatHeight / 5);
    tsBottom: result.Offset(0, 0);
    tsBottomRight: result.Offset(FSeatWidth / 2.3, -FSeatHeight / 5);
    tsRight: result.Offset(FSeatWidth / 2.5, 0);
    tsTopRight: result.Offset(FSeatWidth / 2.3, -FSeatHeight / 4.5);
    tsTop: result.Offset(0, 0);
  end;
end;

function TfrmTable.GetTableSector(const APoint: TPointF): TTableSector;
var
  points: array[0..3] of TPointF;
begin
  points[0] := PointF(FTableCenter.X - FSeatWidth / 2, FTableCenter.Y - FSeatHeight / 2);
  points[1] := PointF(FTableCenter.X + FSeatWidth / 2, FTableCenter.Y - FSeatHeight / 2);
  points[2] := PointF(FTableCenter.X - FSeatWidth / 2, FTableCenter.Y + FSeatHeight / 2);
  points[3] := PointF(FTableCenter.X + FSeatWidth / 2, FTableCenter.Y + FSeatHeight / 2);

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

procedure TfrmTable.ModalFormClose(Sender: TObject);
begin
  EnableWindow(Handle, TRUE);
end;

function TfrmTable.GetDealerPoint(const ASeatIndex: Integer): TPointF;
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
  result := PointF(x, y);
end;

function TfrmTable.GetBetPoint(const ASeatIndex: Integer): TPointF;
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
  result := PointF(x, y);
end;


function TfrmTable.GetCardPoint(const ASeatInfo: TSeatInfo; const ACardIndex: Integer): TPoint2;
var
  seat_point         : TPointF;
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

function TfrmTable.GetPotPoint(const APotIndex: Integer): TPointF;
var
  topy, bottomy: Integer;
begin
  topy := Round(FTableCenter.Y - FCardHeight - FTableResizeRatio * 4);
  bottomy := Round(FTableCenter.Y + FCardHeight + FTableResizeRatio * 16);
  case APotIndex of
    0: result := PointF(FTableCenter.X, topy);
    1: result := PointF(FTableCenter.X + 40, topy);
    2: result := PointF(FTableCenter.X - 40, topy);
    3: result := PointF(FTableCenter.X - 40, bottomy);
    4: result := PointF(FTableCenter.X + 40, bottomy);
  else
    result := PointF(-1, -1);
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

procedure TfrmTable.acStandUpExecute(Sender: TObject);
begin
  if not ConfirmStandUp then
    Exit;

  SocketClient.TableStandUp(FTable.Game.MongoId);
  acStandUp.Enabled := FALSE;
end;

procedure TfrmTable.AddUserChatMessage(const AUser, AMessage: String);
begin
  reChat.SelStart := reChat.GetTextLen;
  reChat.SelAttributes.Color := clLime;
  if reChat.SelStart = 0 then
    reChat.SelText := AUser
  else
    reChat.SelText := sLineBreak + AUser;

  reChat.SelStart := reChat.GetTextLen;
  reChat.SelAttributes.Color := clSilver;
  reChat.SelText := Format(': %s', [AMessage]);

  reChat.ScrollContent(dirDown); reChat.ScrollContent(dirDown); // FIXME! yuck
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
  sitout   : Boolean;
  seat_bet : Integer;
  event    : TNotifyEvent;
begin
  acStandUp.Enabled := FALSE;
  acFold.Enabled := FALSE;
  acCall.Enabled := FALSE;
  acCheck.Enabled := FALSE;
  acRaise.Enabled := FALSE;
  acPlayNow.Enabled := FALSE;
  sitout := FALSE;

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
        if (FTableStatus.CurrentSeat = FTable.SeatIndex) and
           (not FTableStatus.Locked) then
          case FTableStatus.State of
            tsIdle: ;
            tsPreFlop,
            tsFlop,
            tsTurn,
            tsRiver: begin
              acFold.Enabled := TRUE;
              if seat_bet < FTableStatus.MinimumBet then
              begin
                if seat_info.Chips + seat_bet <= FTableStatus.MinimumBet then
                  acCall.Caption := 'CALL (ALL-IN)'
                else
                  acCall.Caption := Format('CALL (%.2f)', [(FTableStatus.MinimumBet - seat_bet) / 100]);
                acCall.Enabled := TRUE;

                if seat_info.Chips + seat_bet > FTableStatus.MinimumBet then
                begin
                  acRaise.Caption := 'RAISE';
                  acRaise.Enabled := TRUE;
                end;
              end
              else
              begin
                acCheck.Enabled := TRUE;
                acRaise.Caption := 'BET';
                acRaise.Enabled := TRUE;
              end;

              if cbFoldToAnyBet.Checked then
                acFold.Execute;
            end;
            tsWinning,
            tsWinning2: ;
          end;
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
  cbSitOutNextHand.Visible := sitout;
  cbSitOutNextBB.Visible := sitout;

  if btStandUp.Visible <> acStandUp.Enabled then
    btStandUp.Visible := acStandUp.Enabled;
  if btPlayNow.Visible <> acPlayNow.Enabled then
    btPlayNow.Visible := acPlayNow.Enabled;

  if acFold.Enabled then
    btAction1.Action := acFold
  else
    btAction1.Action := nil;

  if (acCall.Enabled) or (acCheck.Enabled) then
  begin
    if acCall.Enabled then
      btAction2.Action := acCall
    else
      btAction2.Action := acCheck;
  end
  else
    btAction2.Action := nil;

  if acRaise.Enabled then
    btAction3.Action := acRaise
  else
    btAction3.Action := nil;

  btAction1.Visible := Assigned(btAction1.Action);
  btAction2.Visible := Assigned(btAction2.Action);
  btAction3.Visible := Assigned(btAction3.Action);

  tbRaise.Visible := acRaise.Enabled;
  seRaiseAmount.Visible := acRaise.Enabled;
  btRaiseMin.Visible := acRaise.Enabled;
  btRaise3BB.Visible := acRaise.Enabled;
  btRaisePot.Visible := acRaise.Enabled;
  btRaiseMax.Visible := acRaise.Enabled;

  if tbRaise.Visible then
  begin
    Assert(FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info));

    tbRaise.Properties.Min := FTableStatus.MinimumBet + FTable.Game.BigBlind;
    tbRaise.Properties.Max := FTableStatus.MaximumBet;

    seRaiseAmount.Properties.MaxValue := tbRaise.Properties.Max / 100;
    seRaiseAmount.Value := tbRaise.Properties.Min / 100;

    tbRaise.Position := tbRaise.Properties.Min;
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

    if FTableStatus.State in [tsFlop, tsTurn, tsRiver, tsWinning, tsWinning2] then
      FFlopAnimations := 6;
    if FTableStatus.State in [tsTurn, tsRiver, tsWinning, tsWinning2] then
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

  tmp := '';
  for C1 := Low(pbtablestatus.Pots) to High(pbtablestatus.Pots) do
    if C1 = High(pbtablestatus.Pots) then
      tmp := tmp + FloatToStr(pbtablestatus.Pots[C1] / 100)
    else
      tmp := tmp + FloatToStr(pbtablestatus.Pots[C1] / 100) + ', ';

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
{  tmp := '';
  for C1 := 0 to Length(pbtablestatus.Bets) - 1 do
    tmp := tmp + Format('%d:%d ', [C1, pbtablestatus.Bets[C1]]);
  tmp := Trim(tmp);
  if tmp <> '' then
    DebugLn('BETS: ' + tmp, ditApplication);}
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
  seat_point  : TPointF;
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
            DXTimer.AddAnimation(Handle, ANIID_DEALING + seat.SeatIndex * 10 + card_index, AnimationCallback,
                 Point2(FTableCenter.x - FCardWidth / 2, FTableYOffset),
                 GetCardPoint(seat, card_index), 0.15, FDealAnimations * 0.03);
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
  tbRaise.Position := FTable.Game.BigBlind * 3;
end;

procedure TfrmTable.acRaiseExecute(Sender: TObject);
begin
  SocketClient.PutChips(FTable.Game.MongoId, tbRaise.Position);
end;

procedure TfrmTable.acRaiseMaxExecute(Sender: TObject);
begin
  tbRaise.Position := tbRaise.Properties.Max;
end;

procedure TfrmTable.acRaiseMinExecute(Sender: TObject);
begin
  tbRaise.Position := tbRaise.Properties.Min;
end;

procedure TfrmTable.acRaisePotExecute(Sender: TObject);
var
  C1 : Integer;
  pot: Single;
begin
  pot := 0;
  for C1 := Low(FTableStatus.Pots) to High(FTableStatus.Pots) do
    pot := pot + FTableStatus.Pots[C1];

  tbRaise.Position := Round(pot * 100);
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

procedure TfrmTable.DoCalculations;
const
  TABLE_X_LEFT        = 64;
  TABLE_X_RIGHT       = 64;
  TABLE_Y_TOP         = 66;
  TABLE_Y_BOTTOM      = 133;
  TABLE_Y_OFFSET      = 55;
  TABLE_WIDTH_OF_FORM = 0.715;
begin
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

  // calculate table resize ratio
  FTableResizeRatio := (FDXAreaSize.x * TABLE_WIDTH_OF_FORM) / TableResources.TableImage.Texture[0].Width;

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
  FSeatCardsMaxWidth := FSeatWidth * 0.6;

  // calculate dealer size
  FDealerWidth := TableResources.DealerButtonImage.Texture[0].Width * FTableResizeRatio;
  FDealerHeight := FDealerWidth / TableResources.DealerButtonAspectRatio;

  // calculate chip size
  FChipWidth := TableResources.Chip1Image.Texture[0].Width * FTableResizeRatio;
  FChipHeight := FChipWidth / TableResources.ChipAspectRatio;

  // calculate timebar/timebank size
  FTimebarWidth := TableResources.TimebarImage.Texture[0].Width * FTableResizeRatio;
  FTimebarHeight := FTimebarWidth / TableResources.TimebarAspectRatio;
end;

procedure TfrmTable.RenderEvent(Sender: TObject);
begin
  DoCalculations;
  RenderBackground;
  RenderTable;
  RenderTableCards;
  RenderDealerButton;
  RenderDealingCards;
  RenderSeats;
  RenderPlayerBets;
  RenderPots;
  RenderTimebar;
end;

procedure TfrmTable.RenderBackground;
begin
  DXCore.Canvas.UseImage(TableResources.BackgroundImage, TexFull4);
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
  seat_point           : TPointF;
  seat_info            : TSeatInfo;
  player_info          : TPlayerInfo;
  seat_image           : TAsphyreImage;
  seat_empty_image     : TAsphyreImage;
  seat_dark_image      : TAsphyreImage;
  seat_light_image     : TAsphyreImage;
  avatar               : TAvatar;
  avatar_point         : TPoint2;
  avatar_radius        : Single;
  seat_upper_text      : String;
  seat_lower_text      : String;
  seat_upper_text_color: TColor2;
  seat_lower_text_color: TColor2;
  seat_upper_font      : TAsphyreFont;
  seat_lower_font      : TAsphyreFont;
  seat_upper_text_point: TPoint2;
  seat_lower_text_point: TPoint2;
  seat_text_x_center   : Single;
  card_point           : TPoint2;
  C1                   : Integer;
begin
  // get seat point
  seat_point := GetSeatPoint(ASeatIndex);

  // calculate seat elements positions & dimensions
  avatar_radius := Round(34 * FTableResizeRatio * FSeatSizeMultiplier);
  if GetTableSector(seat_point) in [tsLeft, tsTopLeft, tsBottomLeft] then
  begin
    seat_empty_image := TableResources.SeatEmptyLeftImage;
    seat_dark_image := TableResources.SeatDarkLeftImage;
    seat_light_image := TableResources.SeatLightLeftImage;
    avatar_point := Point2(seat_point.X + FSeatWidth / 2 - 46 * FTableResizeRatio * FSeatSizeMultiplier, seat_point.Y);
    seat_text_x_center := seat_point.X - (seat_point.X + FSeatWidth / 2 - avatar_point.X) / 2;
  end
  else
  begin
    seat_empty_image := TableResources.SeatEmptyRightImage;
    seat_dark_image := TableResources.SeatDarkRightImage;
    seat_light_image := TableResources.SeatLightRightImage;
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
    if (FTableStatus.CurrentSeat = seat_info.SeatIndex) and
       (tiActiveFrameBlink.Tag = 1) and
       (not FTableStatus.Locked) then
      seat_image := seat_light_image
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

    seat_upper_font := TableResources.BarmenoFont_19px;
    seat_upper_font.Kerning := 1;
    seat_upper_font.Scale := FTableResizeRatio;
    while (seat_upper_font.TextWidth(seat_upper_text) < FSeatWidth / 3) and
          (seat_upper_font.Scale < 1) do
      seat_upper_font.Scale := seat_upper_font.Scale + 0.01;
    while ((seat_upper_font.TextWidth(seat_upper_text) > FSeatWidth / 2.5) or
           (seat_upper_font.TextHeight(seat_upper_text) > FSeatHeight / 2.5)) and
          (seat_upper_font.Scale > 0.4) do
      seat_upper_font.Scale := seat_upper_font.Scale - 0.01;

    seat_lower_font := TableResources.BarmenoFont_19px;
    seat_lower_font.Kerning := 1;
    seat_lower_font.Scale := FTableResizeRatio;
    while (seat_lower_font.TextWidth(seat_lower_text) < FSeatWidth / 5) and
          (seat_lower_font.Scale < 1) do
      seat_lower_font.Scale := seat_lower_font.Scale + 0.01;
    while ((seat_lower_font.TextWidth(seat_lower_text) > FSeatWidth / 2.5) or
           (seat_lower_font.TextHeight(seat_lower_text) > FSeatHeight / 3)) and
          (seat_lower_font.Scale > 0.4) do
      seat_lower_font.Scale := seat_lower_font.Scale - 0.01;

    // set seat lower text
    if seat_info.Status = psOutOfPlay then
      seat_lower_text := 'Sitting Out'
    else
      seat_lower_text := FloatToStr(seat_info.Chips / 100);
    seat_lower_text_color := cColor2($FF8DC63F);

    // render seat cards
    if seat_info.Status in [psInHand, psAllIn] then
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
    seat_upper_font.TextMidF(seat_upper_text_point, seat_upper_text, seat_upper_text_color);

    // render lower seat text
    seat_lower_font.TextMidF(seat_lower_text_point, seat_lower_text, seat_lower_text_color);
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

      DXTimer.AddAnimation(Handle, ANIID_FLOP1, AnimationCallback, FDealerPoint, card_points_mid[0], 0.15, 0);
      DXTimer.AddAnimation(Handle, ANIID_FLOP2, AnimationCallback, FDealerPoint, card_points_mid[1], 0.15, 0);
      DXTimer.AddAnimation(Handle, ANIID_FLOP3, AnimationCallback, FDealerPoint, card_points_mid[2], 0.15, 0);

      DXTimer.AddAnimation(Handle, ANIID_FLOP4, AnimationCallback, card_points_mid[0], card_points_final[0], 0.2, 0.25);
      DXTimer.AddAnimation(Handle, ANIID_FLOP5, AnimationCallback, card_points_mid[1], card_points_final[1], 0.2, 0.25);
      DXTimer.AddAnimation(Handle, ANIID_FLOP6, AnimationCallback, card_points_mid[2], card_points_final[2], 0.2, 0.25);

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
      DXTimer.AddAnimation(Handle, ANIID_TURN, AnimationCallback, FDealerPoint, card_points_final[3], 0.15, 0);
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
      DXTimer.AddAnimation(Handle, ANIID_RIVER, AnimationCallback, FDealerPoint, card_points_final[4], 0.15, 0);
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

procedure TfrmTable.RenderDealingCards;
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
  dealer_point: TPointF;
begin
  if FTableStatus.Dealer = -1 then
    Exit;

  dealer_point := GetDealerPoint(FTableStatus.Dealer);

  DXCore.Canvas.UseImage(TableResources.DealerButtonImage, TexFull4);
  DXCore.Canvas.TexMap(pBounds4(dealer_point.X - FDealerWidth / 2, dealer_point.Y - FDealerHeight / 2, FDealerWidth, FDealerHeight), clWhite4);
end;

procedure TfrmTable.RenderPlayerBets;
var
  C1         : Integer;
  seat_info  : TSeatInfo;
  chips_point: TPointF;
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
        RenderChipStack(chips_point, chips_stack, stack_value);
      end;
    end;
end;

procedure TfrmTable.RenderPots;
var
  C1         : Integer;
  pot        : Single;
  chips_stack: TChipsStack;
  pot_point  : TPointF;
begin
  for C1 := Low(FTableStatus.Pots) to High(FTableStatus.Pots) do
  begin
    pot_point := GetPotPoint(C1);
    if (pot_point.X > 0) and (pot_point.Y > 0) then
    begin
      pot := FTableStatus.Pots[C1] / 100;
      chips_stack := FChipsStackMaker.MakeStack(Trunc(pot));
      RenderChipStack(pot_point, chips_stack, pot);
    end;
  end;
end;

procedure TfrmTable.RenderChipStack(const APoint: TPointF; const AChipStack: TChipsStack; const AValue: Single);
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
  seat_point  : TPointF;
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

procedure TfrmTable.AnimationCallback(const AAnimation: TDXAnimation);
var
  seat_index: Integer;
  seat      : TSeatInfo;
begin
  if not Assigned(AAnimation) then
  begin
    Render;
    Exit;
  end;

  case AAnimation.ID of
    ANIID_FLOP1, ANIID_FLOP2, ANIID_FLOP3, ANIID_FLOP4, ANIID_FLOP5, ANIID_FLOP6: begin
      if AAnimation.Status = asDone then
        Inc(FFlopAnimations);
    end;

    ANIID_TURN: begin
      if AAnimation.Status = asDone then
        Inc(FTurnAnimations);
    end;

    ANIID_RIVER: begin
      if AAnimation.Status = asDone then
        Inc(FRiverAnimations);
    end;

    ANIID_DEALING..ANIID_DEALING + 99: begin
      if AAnimation.Status = asDone then
      begin
        seat_index := (AAnimation.ID - ANIID_DEALING) div 10;
        if FTableStatus.GetSeatInfo(seat_index, seat) then
          seat.IncDealtCards;

        Dec(FDealAnimations);
      end;
    end;
  end;
end;



end.

