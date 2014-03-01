unit uTableForm;

{.$DEFINE SHOW_DEBUG_INFO}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, cxMemo, uMessageItem, Vcl.Menus, cxButtons, uTableStatus, uChipsStackMaker,
  Vcl.ActnList, cxLabel, uTables, cxTextEdit, dxsChipUpDark, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, dxsChipUpDarkTabs, JPEG, uCards,
  GR32_Backends, GR32, GR32_Png, GR32_Resamplers, GR32_Image, dxsChipUpRedButton, cxRichEdit, cxMaskEdit, cxSpinEdit, cxTrackBar, cxCheckBox,
  cxProgressBar;

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
    PaintBox: TPaintBox32;
    paButtons: TPanel;
    btCall: TcxButton;
    btCheckFold: TcxButton;
    btRaise: TcxButton;
    btStandUp: TcxButton;
    lbsInfo: TcxLabel;
    reChat: TcxRichEdit;
    seRaiseAmount: TcxSpinEdit;
    tbRaise: TcxTrackBar;
    tiActiveFrameBlink: TTimer;
    btPlayNow: TcxButton;
    acPlayNow: TAction;
    cbSitOutNextHand: TcxCheckBox;
    tiSitOutNextHand: TTimer;
    tiSeatCaptionClear: TTimer;
    lbsHandId: TcxLabel;
    pbTime: TcxProgressBar;
    tiPlayTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure acStandUpExecute(Sender: TObject);
    procedure PaintBoxClick(Sender: TObject);
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
    procedure tiPlayTimerTimer(Sender: TObject);
  private
    type
      TSeatOrientation = (soLeft, soRight);

    var
      FFormAspectRatio : Double;
      FTable           : TTable;
      FTableStatus     : TTableStatus;
      FTableResizeRatio: Double;
      FTableWidth      : Integer;
      FTableHeight     : Integer;
      FTableXOffset    : Integer;
      FTableYOffset    : Integer;
      FTableCenter     : TPoint;
      FSeatWidth       : Integer;
      FSeatHeight      : Integer;
      FSeatMultiplier  : Double;
      FCardWidth       : Integer;
      FCardHeight      : Integer;
      FArtWidth        : Integer;
      FArtHeight       : Integer;
      FChipWidth       : Integer;
      FChipHeight      : Integer;
      FChipsStack      : TChipsStackMaker;
      FGoalTime        : UINT32;
      FCurrentPlaytime : Integer;

    procedure Redraw(const APaintboxRepaint: Boolean = FALSE);
    procedure AddUserChatMessage(const AUser, AMessage: String);
    procedure DrawDealerButton;

    function ConfirmLeaveTable: Boolean;
    function ConfirmStandUp: Boolean;

    procedure DrawSeats;
    procedure DrawTableCards;
    procedure DrawCard(const ACard: TCard; const ACardRect: TRect);
    procedure DrawPlayerBets;
    procedure DrawPots;
    procedure DrawTopChipValue(const AChipStack: TChipsStack; const ARect: TRect);
    procedure DrawStackValue(const AChipStack: TChipsStack; const ARect: TRect; const AValue: Double; const AIsPot: Boolean);
    {$IFDEF SHOW_DEBUG_INFO}
    procedure ShowDebugInfo;
    {$ENDIF}

    function GetSeatOrientation(const APoint: TPoint): TSeatOrientation;
    function GetSeatPoint(const ASeatIndex: Integer): TPoint;
    function GetDealerPoint(const ASeatIndex: Integer): TPoint;
    function GetChipsPoint(const ASeatIndex: Integer): TPoint;
    function GetPotPoint(const APotIndex: Integer): TPoint;

    procedure CSRChatEvent(const AMessage: TMessageItem);
    procedure CSRETableStatus(const AMessage: TMessageItem);
    procedure CSETableEvent(const AMessage: TMessageItem);

    procedure ConfigureGUI;

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
  System.Types, cxClasses, System.Math,
  uMessageContainer, uServerMessageCallback, uServerCodes, uPB_ChatEvent, uPB_ChatMessage, uPB_SeatInfo, uTableResources,
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uSocketClient, uCommon, uTableSitForm, uMainDataModule, uPlayerInfo, uAvatars, uPB_TableStatus, uPB_TableEvent, uPB_PotInfo;


constructor TfrmTable.Create(const ATable: TTable);
begin
  inherited Create(nil);

  ActionManager.State := asSuspended;

  FTable := ATable;
end;

procedure TfrmTable.FormCreate(Sender: TObject);
begin
  FTableStatus := TTableStatus.Create;
  FChipsStack := TChipsStackMaker.Create;

  reChat.Lines.Clear;

  FFormAspectRatio := Width / Height;
  PaintBox.BufferOversize := 0;

  if not TTableResources.IsInitialized then
    TTableResources.Initialize;

  FTableWidth := TTableResources.TableImage.Width;
  FTableHeight := TTableResources.TableImage.Height;

  Caption := Format('%s - %s (%d/%d %s)', [FTable.Club.Name, FTable.Game.Name, Round(FTable.Game.SmallBlind / 100), Round(FTable.Game.BigBlind / 100), FTable.Game.GameTypeStrFull]);
  Redraw;
end;

procedure TfrmTable.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);

  FChipsStack.Free;
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
end;

procedure TfrmTable.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmLeaveTable;
end;

procedure TfrmTable.FormResize(Sender: TObject);
begin
  if Width / Height <> FFormAspectRatio then
    Height := Round(Width / FFormAspectRatio);

  Redraw;
end;

procedure TfrmTable.FormShow(Sender: TObject);
begin
  MessageContainer.AddMessageHandler(Handle);
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
var
  msg: TMessageItem;
begin
  // prevent ALT key from tabbing between forms
  if (AMessage.Msg = WM_SYSCOMMAND) and
     (AMessage.WParam = SC_KEYMENU) then
    Exit;

  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(seChat, CSRChatEvent),
                            TServerMessageCallback.Create(seTableStatus, CSRETableStatus),
                            TServerMessageCallback.Create(srTableSitOk, CSRETableStatus),
                            TServerMessageCallback.Create(srTableAddonOk, CSRETableStatus),
                            TServerMessageCallback.Create(srTableStandUpOk, CSRETableStatus),
                            TServerMessageCallback.Create(seTableEvent, CSETableEvent)
                          ]
                        );
    end;

    MessageContainer.RemoveMessageReader(AMessage.WParam, Handle);
  end;
end;

procedure TfrmTable.PaintBoxClick(Sender: TObject);
var
  C1               : Integer;
  seat_info        : TSeatInfo;
  client_cursor_pos: TPoint;
  seat_point       : TPoint;
  seat_rect        : TRect;
begin
  client_cursor_pos := ScreenToClient(Mouse.CursorPos);

  for C1 := 0 to FTable.Game.Seats - 1 do
  begin
    seat_point := GetSeatPoint(C1);
    seat_rect := TRect.Create(seat_point.X - FSeatWidth div 2, seat_point.Y - FSeatHeight div 2, seat_point.X + FSeatWidth div 2, seat_point.Y + FSeatHeight div 2);
    if (client_cursor_pos.X >= seat_rect.Left) and (client_cursor_pos.X <= seat_rect.Right) and
       (client_cursor_pos.Y >= seat_rect.Top) and (client_cursor_pos.Y <= seat_rect.Bottom) then
    begin
      if (not FTable.IsSitting) and
         (not FTableStatus.IsSeatTaken(C1)) then
      begin
        if RunModalForm(TfrmTableSit, self, [FTable, FTableStatus, @C1]) = mrOk then
        begin
          acStandUp.Enabled := TRUE;
          btStandUp.Visible := TRUE;
        end;
        Break;
      end;

      if (FTable.IsSitting) and
         (FTable.SeatIndex = C1) and
         (FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info)) and
         (seat_info.Status in [psOutOfPlay, psOutOfHand, psFolded]) then
      begin
        RunModalForm(TfrmTableSit, self, [FTable, FTableStatus, @C1]);
        Break;
      end;
    end;
  end;
end;

procedure TfrmTable.Redraw(const APaintboxRepaint: Boolean = FALSE);
var
  chat_width: Integer;
  tblx, tbly: Integer;
  tblw, tblh: Integer;
begin
  paBottom.Height := Round(Height / 5);
  chat_width := Round(Width / 2.5);

  // dirty hack to resize chat box controls, we have to make them 1px wider than panel, to hide ugly white border on RichEdit
  // FIXME! find a way to hide white border without this hack
  if paChat.Width <> chat_width then
  begin
    if edChat.Width > chat_width then
      paChat.Width := chat_width;
    edChat.Width := chat_width + 1;
    reChat.Width := chat_width + 1;
    reChat.Height := paChat.Height - reChat.Top + 1;
    paChat.Width := chat_width;
  end;

  // calculate table size and table positions
  FTableWidth := Round(0.63 * PaintBox.Buffer.Width);
  FTableHeight := Round(FTableWidth / TTableResources.TableAspectRatio);
  FTableResizeRatio := FTableWidth / TTableResources.TableWidth;
  tblw := Round(FTableResizeRatio * TTableResources.TableImage.Width);
  tblh := Round(FTableResizeRatio * TTableResources.TableImage.Height);
  tblx := (PaintBox.Buffer.Width - tblw) div 2;
  tbly := (PaintBox.Buffer.Height - tblh) div 2 + 54;
  FTableXOffset := tblx + Round(FTableResizeRatio * TTableResources.TableXOffset);
  FTableYOffset := tbly + Round(FTableResizeRatio * TTableResources.TableYOffset);
  FTableCenter.X := FTableXOffset + FTableWidth div 2;
  FTableCenter.Y := FTableYOffset + FTableHeight div 2;

  // calculate seats size
  FSeatMultiplier := 1 + (10 - FTable.Game.Seats) / 23;
  if FSeatMultiplier > 1.3 then
    FSeatMultiplier := 1.3;
  FSeatWidth := Round(TTableResources.SeatWidth * FTableResizeRatio * FSeatMultiplier);
  FSeatHeight := Round(FSeatWidth / TTableResources.SeatAspectRatio);

  // calculate cards size
  FCardWidth := Round(TTableResources.CardWidth * FTableResizeRatio);
  FCardHeight := Round(FCardWidth / TTableResources.CardAspectRatio);
  FArtWidth := Round(FCardWidth * (0.48 + FTableResizeRatio / 5));
  FArtHeight := Round(FCardHeight * 0.85);

  // calculate chips size
  FChipWidth := Round(TTableResources.ChipWidth * FTableResizeRatio);
  FChipHeight := Round(FChipWidth / TTableResources.ChipAspectRatio);

  // draw background
  PaintBox.Buffer.Draw(PaintBox.Buffer.BoundsRect, TTableResources.BackgroundImage.BoundsRect, TTableResources.BackgroundImage);

  // draw table
  PaintBox.Buffer.Draw(Rect(tblx, tbly, tblx + tblw, tbly + tblh), TTableResources.TableImage.BoundsRect, TTableResources.TableImage);

  // draw various stuff
  DrawSeats;
  DrawDealerButton;
  DrawTableCards;
  DrawPlayerBets;
  DrawPots;

  {$IFDEF SHOW_DEBUG_INFO}
  ShowDebugInfo;
  {$ENDIF}

  if APaintboxRepaint then
    PaintBox.Flush;
end;

procedure TfrmTable.seRaiseAmountPropertiesChange(Sender: TObject);
var
  val: Double;
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

  Redraw(TRUE);
end;

procedure TfrmTable.tiPlayTimerTimer(Sender: TObject);
begin
  FCurrentPlaytime := FGoalTime - GetTickCount;

  pbTime.Position := Round(FCurrentPlaytime / 10000);
  if FCurrentPlaytime <= 0 then
  begin
    tiPlayTimer.Enabled := FALSE;
  end;

  {$IFDEF DEBUG}
  DebugLn(Format('FCurrentPlaytime: %d', [FCurrentPlaytime]), ditApplication);
  {$ENDIF}
end;

procedure TfrmTable.tiSitOutNextHandTimer(Sender: TObject);
var
  seat_info: TSeatInfo;
begin
  if FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info) then
  begin
    if cbSitOutNextHand.Checked then
      SocketClient.TableSitOut(FTable.Game.MongoId)
    else
      SocketClient.TablePlayNow(FTable.Game.MongoId);
  end;

  tiSitOutNextHand.Enabled := FALSE;
end;

{$IFDEF SHOW_DEBUG_INFO}
procedure TfrmTable.ShowDebugInfo;
var
  C1        : Integer;
  seat_point: TPoint;
  seat_info : TSeatInfo;
  add       : String;
begin
  // textout seatpos/cards/blinds
  PaintBox.Buffer.Font.Name := 'Arial';
  PaintBox.Buffer.Font.Size := 10;
  PaintBox.Buffer.Font.Color := clWhite;
  PaintBox.Buffer.Font.Style := [fsBold];
  for C1 := 0 to FTableStatus.Seats.Count - 1 do
    if FTableStatus.GetSeatInfo(FTableStatus.Seats[C1].SeatIndex, seat_info) then
    begin
      seat_point := GetSeatPoint(seat_info.SeatIndex);
      add := '';
      if seat_info.SeatIndex = FTableStatus.SmallBlindSeat then
        add := add + 'SB';
      if seat_info.SeatIndex = FTableStatus.BigBlindSeat then
        add := add + 'BB';

      PaintBox.Buffer.TextOut(seat_point.X - FSeatWidth div 2, Round(seat_point.Y + FSeatHeight / 2), Format('[#%d] [%s] %s %s', [seat_info.SeatIndex, seat_info.StatusAsStr, add, seat_info.Cards.AsString]));
    end;
end;
{$ENDIF}

procedure TfrmTable.DrawDealerButton;
var
  dealer_point: TPoint;
  dealerw     : Integer;
  dealerh     : Integer;
begin
  if FTableStatus.Dealer = -1 then
    Exit;

  dealer_point := GetDealerPoint(FTableStatus.Dealer);
  dealerw := Round(TTableResources.DealerButtonWidth * FTableResizeRatio);
  dealerh := Round(dealerw / TTableResources.DealerButtonAspectRatio);

  PaintBox.Buffer.Draw(Rect(dealer_point.X - dealerw div 2, dealer_point.Y - dealerh div 2, dealer_point.X + dealerw div 2, dealer_point.Y + dealerh div 2),
                       TTableResources.DealerButtonImage.BoundsRect,
                       TTableResources.DealerButtonImage);
end;

procedure TfrmTable.DrawPlayerBets;
var
  C1         : Integer;
  seat_info  : TSeatInfo;
  chips_point: TPoint;
  chips_stack: TChipsStack;
  chips_rect : TRect;
begin
  for C1 := 0 to FTableStatus.Seats.Count - 1 do
    if FTableStatus.GetSeatInfo(FTableStatus.Seats[C1].SeatIndex, seat_info) then
    begin
      if (Length(FTableStatus.Bets) > seat_info.SeatIndex) and
         (FTableStatus.Bets[seat_info.SeatIndex] > 0) then
      begin
        chips_point := GetChipsPoint(seat_info.SeatIndex);
        chips_stack := FChipsStack.MakeStack(FTableStatus.Bets[seat_info.SeatIndex] div 100);
        chips_rect := Rect(chips_point.X - FChipWidth div 2, chips_point.Y - Round(chips_stack.Image.Height * FTableResizeRatio), chips_point.X + FChipWidth div 2, chips_point.Y);
        PaintBox.Buffer.Draw(chips_rect, chips_stack.Image.BoundsRect, chips_stack.Image);
        DrawTopChipValue(chips_stack, chips_rect);
        DrawStackValue(chips_stack, chips_rect, FTableStatus.Bets[seat_info.SeatIndex] / 100, FALSE);
      end;
    end;
end;

procedure TfrmTable.DrawPots;
var
  C1         : Integer;
  pot        : Double;
  chips_stack: TChipsStack;
  chips_rect : TRect;
  pot_point  : TPoint;
begin
  for C1 := Low(FTableStatus.Pots) to High(FTableStatus.Pots) do
  begin
    pot_point := GetPotPoint(C1);
    if (pot_point.X <> -1) and (pot_point.Y <> -1) then
    begin
      pot := FTableStatus.Pots[C1] / 100;
      chips_stack := FChipsStack.MakeStack(Trunc(pot));
      chips_rect := Rect(pot_point.X - FChipWidth div 2, pot_point.Y - Round(chips_stack.Image.Height * FTableResizeRatio), pot_point.X + FChipWidth div 2, pot_point.Y);
      PaintBox.Buffer.Draw(chips_rect, chips_stack.Image.BoundsRect, chips_stack.Image);
      DrawTopChipValue(chips_stack, chips_rect);
      DrawStackValue(chips_stack, chips_rect, pot, TRUE);
    end;
  end;
end;

function TfrmTable.GetSeatOrientation(const APoint: TPoint): TSeatOrientation;
begin
  if APoint.X < FTableXOffset + FTableWidth div 2 then
    result := soLeft
  else
    result := soRight;
end;

function TfrmTable.GetSeatPoint(const ASeatIndex: Integer): TPoint;
var
  seat_radians: Double;
  x, y        : Integer;
begin
               {
    for x := 0 to Round((2 * pi) * 10000) do
      PaintBox.Buffer.Pixel[FTableCenter.X + Round(((FTableWidth + 125 * FTableResizeRatio) / 2) * Cos(x)),
                            FTableCenter.Y + Round(((FTableHeight + 50 * FTableResizeRatio) / 2) * Sin(x)) + 10] := clRed; // BLUE!
                         }

  seat_radians := TTableResources.SEAT_POINTS[FTable.Game.Seats, ASeatIndex];
  x := FTableCenter.X + Round(((FTableWidth + 190 * FTableResizeRatio) / 2) * Cos(seat_radians));
  y := FTableCenter.Y + Round(((FTableHeight + 90 * FTableResizeRatio) / 2) * Sin(seat_radians)) + 10;

  result := GR32.Point(x, y);
end;

function TfrmTable.GetDealerPoint(const ASeatIndex: Integer): TPoint;
var
  seat_radians: Double;
  x, y        : Integer;
  xr, yr      : Double;
begin
  xr := FTableWidth / 1.3;
  yr := FTableHeight / 1.45;
                                {
  for x := 0 to Round((2 * pi) * 10000) do
    PaintBox.Buffer.Pixel[FTableCenter.X + Round((xr / 2) * Cos(x)),
                          FTableCenter.Y + Round((yr / 2) * Sin(x))] := $FFFF0000;
                                      }

  seat_radians := TTableResources.SEAT_POINTS[FTable.Game.Seats, ASeatIndex];
  x := FTableCenter.X + Round((xr / 2) * Cos(seat_radians));
  y := FTableCenter.Y + Round((yr / 2) * Sin(seat_radians));
  result := GR32.Point(x, y);
end;

function TfrmTable.GetPotPoint(const APotIndex: Integer): TPoint;
var
  topy, bottomy: Integer;
begin
  topy := Round(FTableCenter.Y - FCardHeight / 2 - FTableResizeRatio * 37);
  bottomy := Round(FTableCenter.Y + FCardHeight / 2 + FTableResizeRatio * 37 + 10);
  case APotIndex of
    0: result := GR32.Point(FTableCenter.X, topy);
    1: result := GR32.Point(FTableCenter.X + 40, topy);
    2: result := GR32.Point(FTableCenter.X - 40, topy);
    3: result := GR32.Point(FTableCenter.X - 40, bottomy);
    4: result := GR32.Point(FTableCenter.X + 40, bottomy);
  else
    result := GR32.Point(-1, -1);
  end;
end;

function TfrmTable.GetChipsPoint(const ASeatIndex: Integer): TPoint;
var
  seat_radians: Double;
  x, y        : Integer;
  xr, yr      : Double;
begin
  xr := FTableWidth / 1.4;
  yr := FTableHeight / 1.45;
                                            {
  for x := 0 to Round((2 * pi) * 10000) do
    PaintBox.Buffer.Pixel[FTableCenter.X + Round((xr / 2) * Cos(x)),
                          FTableCenter.Y + Round((yr / 2) * Sin(x) + FTableResizeRatio * 12)] := $FFFF0000;
                                                     }

  seat_radians := TTableResources.SEAT_POINTS[FTable.Game.Seats, ASeatIndex] + pi / 12;
  x := FTableCenter.X + Round((xr / 2) * Cos(seat_radians));
  y := FTableCenter.Y + Round((yr / 2) * Sin(seat_radians) + FTableResizeRatio * 12);
  result := GR32.Point(x, y);
end;

procedure TfrmTable.DrawCard(const ACard: TCard; const ACardRect: TRect);
var
  suit_point: TPoint;
  art_rect  : TRect;
  art_img   : TBitmap32;
  card_val  : String;
  text_color: TColor32;
  suit_text : String;
begin
  // draw card rect
  PaintBox.Buffer.Draw(ACardRect, TTableResources.CardFrontBackgroundImage.BoundsRect, TTableResources.CardFrontBackgroundImage);

  suit_point.X := ACardRect.Left + Round(2.5 * FTableResizeRatio);
  suit_point.Y := ACardRect.Top + Round(7 + FTableResizeRatio * 16);

  art_rect.Left := ACardRect.Right - FArtWidth - 3;
  art_rect.Top := ACardRect.Top + Round(10 * FTableResizeRatio);
  art_rect.Width := FArtWidth;
  art_rect.Height := FArtHeight;

  case ACard.Suit of
    csHeart: begin
      suit_text := '{';
      text_color := $FFFF0000;
    end;
    csDiamond: begin
      suit_text := '[';
      text_color := $FFFF0000;
    end;
    csClub: begin
      suit_text := ']';
      text_color := $FF000000;
    end;
    csSpade: begin
      suit_text := '}';
      text_color := $FF000000;
    end;
  else
    text_color := $FF00FF00;
  end;

  PaintBox.Buffer.Font.Name := 'Card Characters';
  PaintBox.Buffer.Font.Style := [];
  PaintBox.Buffer.Font.Size := Round(5 + FTableResizeRatio * 13);

  card_val := ACard.ValueAsString(ACard.Value);
  if card_val = 'T' then
    card_val := '=';

  // draw card value
  PaintBox.Buffer.RenderTextW(ACardRect.Left + Round(5 * FTableResizeRatio), ACardRect.Top, card_val, 4, text_color);

  // draw card suit
  PaintBox.Buffer.Font.Size := Round(5 + FTableResizeRatio * 10);
  PaintBox.Buffer.RenderTextW(suit_point.X, suit_point.Y, suit_text, 4, text_color);

  // draw card artwork
  art_img := TTableResources.GetCardArtwork(ACard);
  PaintBox.Buffer.Draw(art_rect, art_img.BoundsRect, art_img);

  // draw artwork rectangle
  PaintBox.Buffer.Canvas.Pen.Style := psSolid;
  PaintBox.Buffer.Canvas.Pen.Color := $CFCFCF;
  PaintBox.Buffer.Canvas.Brush.Style := bsClear;
  PaintBox.Buffer.Canvas.Rectangle(art_rect);
end;

procedure TfrmTable.DrawTopChipValue(const AChipStack: TChipsStack; const ARect: TRect);
{var
  tw, th, tx, ty: Integer; }
begin
 { PaintBox.Buffer.Font.Name := 'Arial';
  PaintBox.Buffer.Font.Size := 3 + Round(5 * FTableResizeRatio);
  PaintBox.Buffer.Font.Style := [];

  tw := PaintBox.Buffer.TextWidthW(AChipStack.TopChipVal);
  th := PaintBox.Buffer.TextHeightW(AChipStack.TopChipVal);

  tx := Round(ARect.Left + ARect.Width / 2 - tw / 2);
  ty := Round(ARect.Top + (TTableResources.ChipHeight * FTableResizeRatio) / 2 - th / 2 - 1);

  PaintBox.Buffer.RenderTextW(tx, ty, AChipStack.TopChipVal, 4, $FF000000);  }
end;

procedure TfrmTable.DrawStackValue(const AChipStack: TChipsStack; const ARect: TRect; const AValue: Double; const AIsPot: Boolean);
var
  tw, th, tx, ty: Integer;
  ctext         : String;
begin
  ctext := FloatToStr(AValue);

  tw := PaintBox.Buffer.TextWidthW(ctext);
  th := PaintBox.Buffer.TextHeightW(ctext);

  if AIsPot then
  begin
    ty := Round(ARect.Top + ARect.Height + 4 * FTableResizeRatio);
    tx := Round(ARect.Left + ARect.Width / 2 - tw / 2);
  end
  else
  begin
    ty := Round(ARect.Top + ARect.Height - th + 4 * FTableResizeRatio);
    if ARect.Left < FTableCenter.X then
      tx := Round(ARect.Left + ARect.Width + 5 * FTableResizeRatio)
    else
      tx := Round(ARect.Left - tw - 5 * FTableResizeRatio);
  end;

  PaintBox.Buffer.Font.Name := 'Arial';
  PaintBox.Buffer.Font.Size := 5 + Round(7 * FTableResizeRatio);
  PaintBox.Buffer.Font.Style := [fsBold];
  PaintBox.Buffer.RenderTextW(tx, ty, ctext, 4, $FFFFFFFF);
end;


procedure TfrmTable.DrawTableCards;
var
  C1        : Integer;
  card_rects: array of TRect;
begin
  SetLength(card_rects, 5);
  for C1 := Low(card_rects) to High(card_rects) do
  begin
    card_rects[C1].Left := Round(FTableCenter.X - (FCardWidth * 5) / 2) - 4 * 3 + (C1 * FCardWidth) + (C1 * 3);
    card_rects[C1].Top := Round(FTableCenter.Y - FCardHeight / 2);
    card_rects[C1].Width := FCardWidth;
    card_rects[C1].Height := FCardHeight;
  end;

  if FTableStatus.FlopCards.Count > 0 then
    for C1 := 0 to FTableStatus.FlopCards.Count - 1 do
      DrawCard(FTableStatus.FlopCards[C1], card_rects[C1]);

  if FTableStatus.TurnCard.Value <> cvUnknown then
    DrawCard(FTableStatus.TurnCard, card_rects[3]);

  if FTableStatus.RiverCard.Value <> cvUnknown then
    DrawCard(FTableStatus.RiverCard, card_rects[4]);
end;

procedure TfrmTable.DrawSeats;
const
  CARD_OPEN_PERC   = 0.55;
  CARD_HIDDEN_PERC = 0.35;
var
  seat_point      : TPoint;
  seat_info       : TSeatInfo;
  C1, C2          : Integer;
  upl, upr        : Integer;
  upt, upb        : Integer;
  btt, btb        : Integer;
  tw, th          : Integer;
  player_info     : TPlayerInfo;
  avatar          : TAvatar;
  avatar_radius   : Integer;
  avatar_rect     : TRect;
  avatar_point    : TPoint;
  card_rect       : TRect;
  seat_orientation: TSeatOrientation;
  seat_empty_image: TBitmap32;
  seat_back_dimage: TBitmap32;
  seat_back_limage: TBitmap32;
  seat_image      : TBitmap32;
  tmpstr          : WideString;
  color           : TColor32;
  tmpint          : Integer;
  time_visible    : Boolean;
begin
  time_visible := FALSE;
  for C1 := 0 to FTable.Game.Seats - 1 do
  begin
    seat_point := GetSeatPoint(C1);
    seat_orientation := GetSeatOrientation(seat_point);
    if seat_orientation = soLeft then
    begin
      seat_empty_image := TTableResources.SeatEmptyLeftImage;
      seat_back_dimage := TTableResources.SeatDarkLeftImage;
      seat_back_limage := TTableResources.SeatLightLeftImage;
      upl := Round(seat_point.X - FSeatWidth / 2 + FSeatWidth / 12);
      upr := Round(seat_point.X + FSeatWidth div 2 - FSeatWidth / 3.5);
      avatar_point := GR32.Point(Round(seat_point.X + FSeatWidth / 2 - 46 * FTableResizeRatio * FSeatMultiplier), seat_point.Y);
    end
    else
    begin
      seat_empty_image := TTableResources.SeatEmptyRightImage;
      seat_back_dimage := TTableResources.SeatDarkRightImage;
      seat_back_limage := TTableResources.SeatLightRightImage;
      upl := Round(seat_point.X - FSeatWidth / 2 + FSeatWidth / 4);
      upr := Round(seat_point.X + FSeatWidth div 2 - FSeatWidth / 14);
      avatar_point := GR32.Point(Round(seat_point.X - FSeatWidth / 2 + 46 * FTableResizeRatio * FSeatMultiplier), seat_point.Y);
    end;

    avatar_radius := Round(34 * FTableResizeRatio * FSeatMultiplier);
    avatar_rect := Rect(avatar_point.X - avatar_radius, avatar_point.Y - avatar_radius, avatar_point.X + avatar_radius, avatar_point.Y + avatar_radius);
    upt := Round(seat_point.Y - FSeatHeight / 2 + FSeatHeight / 10);
    upb := seat_point.Y - 3;
    btt := seat_point.Y + 3;
    btb := Round(seat_point.Y + FSeatHeight div 2 - FSeatHeight / 10);

    if (FTableStatus.GetSeatInfo(C1, seat_info)) and
       (seat_info.Status <> psStandingUp) then // seat taken and its not in psStandingUp state
    begin
      dmMain.Players.FindPlayerById(seat_info.PlayerMongoId, player_info);

      // draw cards first
      if seat_info.Status in [psInHand, psAllIn] then
      begin
        tmpint := seat_info.CardCount * FCardWidth;
        for C2 := 0 to seat_info.CardCount - 1 do
          if (C2 >= 0) and (C2 < seat_info.Cards.Count) then
          begin
            card_rect := Rect(Round(seat_point.X - tmpint / 2 + C2 * FCardWidth - C2),
                              Round(seat_point.Y - FSeatHeight / 2 - FCardHeight * CARD_OPEN_PERC),
                              Round(seat_point.X - tmpint / 2 + C2 * FCardWidth - C2 + FCardWidth),
                              Round(seat_point.Y - FSeatHeight / 2 - FCardHeight * CARD_OPEN_PERC + FCardHeight));
            DrawCard(seat_info.Cards[C2], card_rect);
          end
          else
          begin
            card_rect := Rect(Round(seat_point.X - tmpint / 2 + C2 * FCardWidth - C2),
                              Round(seat_point.Y - FSeatHeight / 2 - FCardHeight * CARD_HIDDEN_PERC),
                              Round(seat_point.X - tmpint / 2 + C2 * FCardWidth - C2 + FCardWidth),
                              Round(seat_point.Y - FSeatHeight / 2 - FCardHeight * CARD_HIDDEN_PERC + FCardHeight));
            PaintBox.Buffer.Draw(card_rect, TTableResources.CardBackgroundImage.BoundsRect, TTableResources.CardBackgroundImage);
          end;
      end;

      if Assigned(player_info) then
      begin
        // draw avatar, so it is drawn below player frame
        // if avatar is not found, add it to avatar list, which will download it automatically
        avatar := dmMain.Avatars.AddAvatar(player_info.AvatarId);
        if Assigned(avatar.ImageCircle) then
          PaintBox.Buffer.Draw(avatar_rect, avatar.ImageCircle.BoundsRect, avatar.ImageCircle)
//        PaintBox.Buffer.Pixels[avatar_point.X, avatar_point.Y] := $FFFFFFFF;
      end;

      // draw player frame
      if FTableStatus.CurrentSeat = seat_info.SeatIndex then
      begin
        if (tiActiveFrameBlink.Tag = 1) and
           (not FTableStatus.Locked) then
          seat_image := seat_back_limage
        else
          seat_image := seat_back_dimage;
        time_visible := TRUE;
        pbTime.Width := Round(FSeatWidth * 0.68);
        pbTime.Top := Round(seat_point.Y + FSeatHeight / 2 - 5 * FTableResizeRatio);
        pbTime.Left := Round(seat_point.X - pbTime.Width / 2);
      end
      else
        seat_image := seat_back_dimage;

      PaintBox.Buffer.Draw(Rect(seat_point.X - FSeatWidth div 2, seat_point.Y - FSeatHeight div 2, seat_point.X + FSeatWidth div 2, seat_point.Y + FSeatHeight div 2),
                           seat_image.BoundsRect,
                           seat_image);

      // set font for drawing player info
      PaintBox.Buffer.Font.Name := 'Barmeno';
      PaintBox.Buffer.Font.Size := Round(19 * FTableResizeRatio);
      PaintBox.Buffer.Font.Style := [];

      // draw player nick or played action
      if Assigned(player_info) then
      begin
        if seat_info.Caption <> '' then
        begin
          tmpstr := seat_info.Caption;
          color := $FF00A2FF;
        end
        else
        begin
          tmpstr := player_info.Nick;
          color := $FFCCCCCC;
        end;

        tw := PaintBox.Buffer.TextWidthW(tmpstr);
        th := PaintBox.Buffer.TextHeightW(tmpstr);
        PaintBox.Buffer.RenderTextW(upl + (upr - upl - tw) div 2, Round(upt + (upb - upt) / 2 - th / 1.95), tmpstr, 4, color);
      end;

      // draw chips or current state
      if seat_info.Status = psOutOfPlay then
        tmpstr := 'Sitting Out'
      else
        tmpstr := FloatToStr(seat_info.Chips / 100);
      tw := PaintBox.Buffer.TextWidthW(tmpstr);
      th := PaintBox.Buffer.TextHeightW(tmpstr);
      PaintBox.Buffer.RenderTextW(upl + (upr - upl - tw) div 2, Round(btt + (btb - btt) / 2 - th / 1.75), tmpstr, 4, $FF8DC63F);
    end
    else // empty seat
    begin
      PaintBox.Buffer.Draw(Rect(seat_point.X - FSeatWidth div 2, seat_point.Y - FSeatHeight div 2, seat_point.X + FSeatWidth div 2, seat_point.Y + FSeatHeight div 2),
                           seat_empty_image.BoundsRect,
                           seat_empty_image);
    end;
  end;

  pbTime.Visible := time_visible;
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

procedure TfrmTable.cbSitOutNextHandPropertiesChange(Sender: TObject);
begin
  tiSitOutNextHand.Enabled := FALSE;
  tiSitOutNextHand.Enabled := TRUE;
end;

procedure TfrmTable.CSRChatEvent(const AMessage: TMessageItem);
var
  chat_event  : TPB_ChatEvent;
  chat_message: TPB_ChatMessage;
begin
  chat_event := AMessage.Object_ as TPB_ChatEvent;

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
              if seat_bet < FTableStatus.MinimumBet then
              begin
                if seat_info.Chips + seat_bet <= FTableStatus.MinimumBet then
                  acCall.Caption := 'CALL (ALL-IN)'
                else
                  acCall.Caption := Format('CALL (%.2f)', [(FTableStatus.MinimumBet - seat_bet) / 100]);
                acCall.Enabled := TRUE;
                acFold.Enabled := TRUE;

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

  if (not cbSitOutNextHand.Visible) and
     (sitout) then
  begin
    cbSitOutNextHand.Properties.OnChange := nil;
    cbSitOutNextHand.Checked := FALSE;
    cbSitOutNextHand.Properties.OnChange := cbSitOutNextHandPropertiesChange;
  end;
  cbSitOutNextHand.Visible := sitout;

  btStandUp.Visible := acStandUp.Enabled;
  btPlayNow.Visible := acPlayNow.Enabled;

  btCall.Visible := acCall.Enabled;
  btRaise.Visible := acRaise.Enabled;
  seRaiseAmount.Visible := acRaise.Enabled;
  tbRaise.Visible := acRaise.Enabled;

  if tbRaise.Visible then
  begin
    Assert(FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info));

    tbRaise.Properties.Min := FTableStatus.MinimumBet + FTable.Game.BigBlind;
    tbRaise.Properties.Max := FTableStatus.MaximumBet;

    seRaiseAmount.Properties.MaxValue := tbRaise.Properties.Max / 100;
    seRaiseAmount.Value := tbRaise.Properties.Min / 100;

    tbRaise.Position := tbRaise.Properties.Min;
  end;

  if (acCheck.Enabled) or (acFold.Enabled) then
  begin
    if acCheck.Enabled then
      btCheckFold.Action := acCheck
    else
      btCheckFold.Action := acFold;
    btCheckFold.Visible := TRUE;
  end
  else
    btCheckFold.Visible := FALSE;
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

procedure TfrmTable.CSRETableStatus(const AMessage: TMessageItem);
var
  pbtablestatus: TPB_TableStatus;
  C1           : Integer;
  tmp          : String;
  seat_index   : Integer;
  seat         : TSeatInfo;
  tb           : UINT32;
begin
  pbtablestatus := AMessage.Object_ as TPB_TableStatus;
  if not CompareBytes(pbtablestatus.TableMongoId, FTable.Game.MongoId) then
    Exit;

  FTableStatus.Assign(pbtablestatus);

  if ActionManager.State = asSuspended then
    ActionManager.State := asNormal;

  case AMessage.MethodId of
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

  lbsInfo.Caption := Format('Pots: %s', [tmp]);
  if FTableStatus.Locked then
    lbsInfo.Caption := lbsInfo.Caption + ' [LOCKED] ';
  lbsInfo.Refresh;

  lbsHandId.Caption := Format('Hand: #%d', [FTableStatus.HandId]);

  if FTableStatus.Time > 0 then
  begin
    FGoalTime := FTableStatus.Time - SocketClient.TimeOffset;
    tiPlayTimer.Enabled := TRUE;
  end
  else
  begin
    tiPlayTimer.Enabled := FALSE;
    FGoalTime := 0;
  end;

  {$IFDEF DEBUG}
  DebugLn(Format('FGoalTime: %d', [FGoalTime]), ditApplication);
  {$ENDIF}


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
  tmp := '';
  for C1 := 0 to Length(pbtablestatus.Bets) - 1 do
    tmp := tmp + Format('%d:%d ', [C1, pbtablestatus.Bets[C1]]);
  tmp := Trim(tmp);
  if tmp <> '' then
    DebugLn('BETS: ' + tmp, ditApplication);
  {$ENDIF}

  ConfigureGUI;

  Redraw(TRUE);
end;

procedure TfrmTable.CSETableEvent(const AMessage: TMessageItem);
var
  pbtevent    : TPB_TableEvent;
  event       : String;
  seat_caption: String;
  seat        : TSeatInfo;
  seat_index  : Integer;
  pot         : TPB_PotInfo;
  player      : TPlayerInfo;
  C1, C2      : Integer;
  tmpstr      : String;
begin
  pbtevent := AMessage.Object_ as TPB_TableEvent;
  if not CompareBytes(pbtevent.TableMongoId, FTable.Game.MongoId) then
    Exit;

  FTableStatus.Assign(pbtevent);

  seat_caption := '';
  case pbtevent.Event of
    teFold: begin
      tiActiveFrameBlink.Enabled := FALSE;
      event := 'FOLD';
      seat_caption := 'Fold';
    end;
    teSit: event := 'SIT';
    teStandUp: event := 'STAND UP';
    teWinning: begin
      event := 'WINNING';
      for C1 := 0 to pbtevent.Pots.Count - 1 do
      begin
        pot := pbtevent.Pots[C1];

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
      FChipsStack.Clear;
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
    seat_index := pbtevent.Seat;
    if FTableStatus.GetSeatInfo(seat_index, seat) then
    begin
      seat.Caption := seat_caption;
      tiSeatCaptionClear.Enabled := FALSE;
      tiSeatCaptionClear.Tag := seat.SeatIndex;
      tiSeatCaptionClear.Enabled := TRUE;
    end;
  end;
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

procedure TfrmTable.acRaiseExecute(Sender: TObject);
begin
  SocketClient.PutChips(FTable.Game.MongoId, tbRaise.Position);
end;

end.
