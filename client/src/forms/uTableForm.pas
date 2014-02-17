unit uTableForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, cxMemo, uMessageItem, Vcl.Menus, cxButtons, uTableStatus,
  Vcl.ActnList, cxLabel, uTables, cxTextEdit, dxsChipUpDark, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, dxsChipUpDarkTabs, JPEG,
  GR32_Backends, GR32, GR32_Png, GR32_Resamplers, GR32_Image, dxsChipUpRedButton, cxRichEdit, cxMaskEdit, cxSpinEdit, cxTrackBar, cxCheckBox;

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

    procedure Redraw(const APaintboxRepaint: Boolean = FALSE);
    procedure AddUserChatMessage(const AUser, AMessage: String);
    procedure DrawDealerButton(const ASeatIndex: Integer);

    function ConfirmLeaveTable: Boolean;
    function ConfirmStandUp: Boolean;

    procedure DrawSeats;
    function GetSeatOrientation(const APoint: TPoint): TSeatOrientation;
    function GetSeatPoint(const ASeatIndex: Integer): TPoint;
    function GetDealerPoint(const ASeatIndex: Integer): TPoint;

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
  uSocketClient, uCommon, uTableSitForm, uMainDataModule, uPlayerInfo, uAvatars, uPB_TableStatus, uPB_TableEvent, uCards;


constructor TfrmTable.Create(const ATable: TTable);
begin
  inherited Create(nil);

  ActionManager.State := asSuspended;

  FTable := ATable;
end;

procedure TfrmTable.FormCreate(Sender: TObject);
begin
  FTableStatus := TTableStatus.Create;

  reChat.Lines.Clear;

  FFormAspectRatio := Width / Height;
  PaintBox.BufferOversize := 0;

  if not TTableResources.IsInitialized then
    TTableResources.Initialize;

  FTableWidth := TTableResources.TableImage.Width;
  FTableHeight := TTableResources.TableImage.Height;

  Caption := Format('%s - %s (%d/%d %s)', [FTable.Club.Name, FTable.Game.Name, Trunc(FTable.Game.SmallBlind / 100), Trunc(FTable.Game.BigBlind / 100), FTable.Game.GameTypeStrFull]);
  Redraw;
end;

procedure TfrmTable.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);

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
  C1          : Integer;
  seat_point  : TPoint;
  seat_info   : TSeatInfo;
  chat_width  : Integer;
  cards       : String;
  tblx, tbly  : Integer;
  tblw, tblh  : Integer;
  add         : String;
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

  PaintBox.Buffer.BeginUpdate;
  try
    // draw background
    PaintBox.Buffer.Draw(PaintBox.Buffer.BoundsRect, TTableResources.BackgroundImage.BoundsRect, TTableResources.BackgroundImage);

    // calculate table size and draw it
    FTableWidth := Round(0.65 * PaintBox.Buffer.Width);
    FTableHeight := Round(FTableWidth / TTableResources.TableAspectRatio);
    FTableResizeRatio := FTableWidth / TTableResources.TableWidth;
    FTableXOffset := Round(FTableResizeRatio * TTableResources.TableXOffset);
    FTableYOffset := Round(FTableResizeRatio * TTableResources.TableYOffset);
    tblw := Round(FTableResizeRatio * TTableResources.TableImage.Width);
    tblh := Round(FTableResizeRatio * TTableResources.TableImage.Height);
    tblx := (PaintBox.Buffer.Width - tblw) div 2;
    tbly := (PaintBox.Buffer.Height - tblh) div 2 + 50;
    FTableCenter.X := tblx + FTableXOffset + FTableWidth div 2;
    FTableCenter.Y := tbly + FTableYOffset + FTableHeight div 2;
    PaintBox.Buffer.Draw(Rect(tblx, tbly, tblx + tblw, tbly + tblh), TTableResources.TableImage.BoundsRect, TTableResources.TableImage);

{
    PaintBox.Buffer.Draw(Rect(FTableCenter.X - 5, FTableCenter.Y - 5, FTableCenter.X + 5, FTableCenter.Y + 5),
                         TTableResources.DealerButtonImage.BoundsRect,
                         TTableResources.DealerButtonImage);
}
    // draw seats
    DrawSeats;

    // dealer button
    DrawDealerButton(FTableStatus.Dealer);

    // draw table cards
    PaintBox.Buffer.Font.Name := 'Arial';
    PaintBox.Buffer.Font.Size := 10;
    PaintBox.Buffer.Font.Color := clWhite;
    PaintBox.Buffer.Font.Style := [fsBold];
    case FTableStatus.State of
      tsFlop: cards := FTableStatus.FlopCards.AsString;
      tsTurn: cards := FTableStatus.FlopCards.AsString + ' '  + FTableStatus.TurnCard.AsString;
      tsRiver: cards := FTableStatus.FlopCards.AsString + ' '  + FTableStatus.TurnCard.AsString + ' ' + FTableStatus.RiverCard.AsString;
      tsWinning,
      tsWinning2: begin
        cards := '';
        if FTableStatus.FlopCards.Count = 3 then
          cards := FTableStatus.FlopCards.AsString + ' ';
        if FTableStatus.TurnCard.Value <> cvUnknown then
          cards := cards + FTableStatus.TurnCard.AsString + ' ';
        if FTableStatus.RiverCard.Value <> cvUnknown then
          cards := cards + FTableStatus.RiverCard.AsString;
        cards := Trim(cards);
      end;
    end;
    PaintBox.Buffer.TextOut(FTableCenter.X - 50, FTableCenter.Y + 30, cards);
    PaintBox.Buffer.Font.Style := [];

    // draw player cards and blinds
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
        PaintBox.Buffer.TextOut(seat_point.X - 35, Round(seat_point.Y + 45 * FTableResizeRatio), Format('[#%d] [%d] %s %s', [seat_info.SeatIndex, Integer(seat_info.Status), add, seat_info.Cards.AsString]));
      end;
    PaintBox.Buffer.Font.Style := [];
  finally
    PaintBox.Buffer.EndUpdate;
  end;

  if APaintboxRepaint then
    PaintBox.Flush;
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

procedure TfrmTable.tiSitOutNextHandTimer(Sender: TObject);
var
  seat_info: TSeatInfo;
begin
  if FTable.IsSitting then
  begin
    Assert(FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info));
    if cbSitOutNextHand.Checked then
      SocketClient.TableSitOut(FTable.Game.MongoId)
    else
      SocketClient.TablePlayNow(FTable.Game.MongoId);
  end;

  tiSitOutNextHand.Enabled := FALSE;
end;

procedure TfrmTable.DrawDealerButton(const ASeatIndex: Integer);
var
  dealer_point: TPoint;
  dealerw     : Integer;
  dealerh     : Integer;
begin
  if ASeatIndex = -1 then
    Exit;

  dealer_point := GetDealerPoint(ASeatIndex);
  dealerw := Round(TTableResources.DealerButtonWidth * FTableResizeRatio);
  dealerh := Round(dealerw / TTableResources.DealerButtonAspectRatio);

  PaintBox.Buffer.Draw(Rect(dealer_point.X - dealerw div 2, dealer_point.Y - dealerh div 2, dealer_point.X + dealerw div 2, dealer_point.Y + dealerh div 2),
                       TTableResources.DealerButtonImage.BoundsRect,
                       TTableResources.DealerButtonImage);
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
      PaintBox.Buffer.Pixel[FTableCenter.X + Round(((FTableWidth + 105 * FTableResizeRatio) / 2) * Cos(x)),
                            FTableCenter.Y + Round(((FTableHeight + 40 * FTableResizeRatio) / 2) * Sin(x))] := clRed; // BLUE!
}

  seat_radians := (2 * pi) / (FTable.Game.Seats / (ASeatIndex + 1));
  x := FTableCenter.X + Round(((FTableWidth + 105 * FTableResizeRatio) / 2) * Cos(seat_radians));
  y := FTableCenter.Y + Round(((FTableHeight + 50 * FTableResizeRatio) / 2) * Sin(seat_radians));

  result := GR32.Point(x, y);
end;

function TfrmTable.GetDealerPoint(const ASeatIndex: Integer): TPoint;
var
  seat_radians: Double;
  x, y        : Integer;
  xr, yr      : Double;
begin
  xr := FTableWidth / 1.6;
  yr := FTableHeight / 1.6;

{
  for x := 0 to Round((2 * pi) * 10000) do
    PaintBox.Buffer.Pixel[FTableCenter.X + Round((xr / 2) * Cos(x)),
                          FTableCenter.Y + Round((yr / 2) * Sin(x) - 8 * FTableResizeRatio)] := $FFFF0000;
}

  seat_radians := (2 * pi) / (FTable.Game.Seats / (ASeatIndex + 1));
  x := FTableCenter.X + Round((xr / 2) * Cos(seat_radians));
  y := FTableCenter.Y + Round((yr / 2) * Sin(seat_radians) - 8 * FTableResizeRatio);
  result := GR32.Point(x, y);
end;

procedure TfrmTable.DrawSeats;
var
  seat_point      : TPoint;
  seat_info       : TSeatInfo;
  C1              : Integer;
  upl, upr        : Integer;
  upt, upb        : Integer;
  btt, btb        : Integer;
  tw, th          : Integer;
  player_info     : TPlayerInfo;
  chipsstr        : WideString;
  avatar          : TAvatar;
  avatar_radius   : Integer;
  avatar_rect     : TRect;
  avatar_point    : TPoint;
  seat_orientation: TSeatOrientation;
  seat_empty_image: TBitmap32;
  seat_back_dimage: TBitmap32;
  seat_back_limage: TBitmap32;
  seat_image      : TBitmap32;
begin
  FSeatWidth := Round(TTableResources.SeatWidth * FTableResizeRatio);
  FSeatHeight := Round(FSeatWidth / TTableResources.SeatAspectRatio);

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
      avatar_point := GR32.Point(Round(seat_point.X + FSeatWidth / 2 - 42 * FTableResizeRatio), seat_point.Y);
    end
    else
    begin
      seat_empty_image := TTableResources.SeatEmptyRightImage;
      seat_back_dimage := TTableResources.SeatDarkRightImage;
      seat_back_limage := TTableResources.SeatLightRightImage;
      upl := Round(seat_point.X - FSeatWidth / 2 + FSeatWidth / 3.5);
      upr := Round(seat_point.X + FSeatWidth div 2 - FSeatWidth / 14);
      avatar_point := GR32.Point(Round(seat_point.X - FSeatWidth / 2 + 42 * FTableResizeRatio), seat_point.Y);
    end;

    avatar_radius := Round(30 * FTableResizeRatio);
    avatar_rect := Rect(avatar_point.X - avatar_radius, avatar_point.Y - avatar_radius, avatar_point.X + avatar_radius, avatar_point.Y + avatar_radius);
    upt := Round(seat_point.Y - FSeatHeight / 2 + FSeatHeight / 10);
    upb := seat_point.Y - 3;
    btt := seat_point.Y + 3;
    btb := Round(seat_point.Y + FSeatHeight div 2 - FSeatHeight / 10);

    if FTableStatus.GetSeatInfo(C1, seat_info) then // seat taken
    begin
      dmMain.Players.FindPlayerById(seat_info.PlayerMongoId, player_info);

      if Assigned(player_info) then
      begin
        // draw avatar first, so it is drawn below player frame
        // if avatar is not found, add it to avatar list, which will download it automatically
        avatar := dmMain.Avatars.AddAvatar(player_info.AvatarId);
        if Assigned(avatar.ImageCircle) then
          PaintBox.Buffer.Draw(avatar_rect, avatar.ImageCircle.BoundsRect, avatar.ImageCircle)
      end;

      // draw player frame
      if FTableStatus.CurrentSeat = seat_info.SeatIndex then
      begin
        if (tiActiveFrameBlink.Tag = 1) and
           (not FTableStatus.Locked) then
          seat_image := seat_back_limage
        else
          seat_image := seat_back_dimage;
      end
      else
        seat_image := seat_back_dimage;

      PaintBox.Buffer.Draw(Rect(seat_point.X - FSeatWidth div 2, seat_point.Y - FSeatHeight div 2, seat_point.X + FSeatWidth div 2, seat_point.Y + FSeatHeight div 2),
                           seat_image.BoundsRect,
                           seat_image);

      // set font for drawing player info
      PaintBox.Buffer.Font.Name := 'Barmeno';
      PaintBox.Buffer.Font.Size := Trunc(19 * FTableResizeRatio);
      PaintBox.Buffer.Font.Style := [];

      // draw player nick
      if Assigned(player_info) then
      begin
        tw := PaintBox.Buffer.TextWidthW(player_info.Nick);
        th := PaintBox.Buffer.TextHeightW(player_info.Nick);
        PaintBox.Buffer.RenderTextW(upl + (upr - upl - tw) div 2, Round(upt + (upb - upt) / 2 - th / 1.75), player_info.Nick, 4, $FFCCCCCC);
      end;

      // draw chips
      chipsstr := FloatToStr(seat_info.Chips / 100);
      tw := PaintBox.Buffer.TextWidthW(chipsstr);
      th := PaintBox.Buffer.TextHeightW(chipsstr);
      PaintBox.Buffer.RenderTextW(upl + (upr - upl - tw) div 2, Round(btt + (btb - btt) / 2 - th / 1.75), chipsstr, 4, $FF8DC63F);
    end
    else // empty seat
    begin
      PaintBox.Buffer.Draw(Rect(seat_point.X - FSeatWidth div 2, seat_point.Y - FSeatHeight div 2, seat_point.X + FSeatWidth div 2, seat_point.Y + FSeatHeight div 2),
                           seat_empty_image.BoundsRect,
                           seat_empty_image);
    end;
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
begin
  acStandUp.Enabled := FALSE;
  acFold.Enabled := FALSE;
  acCall.Enabled := FALSE;
  acCheck.Enabled := FALSE;
  acRaise.Enabled := FALSE;
  acPlayNow.Enabled := FALSE;
  sitout := FALSE;

  if FTable.IsSitting then
  begin
    Assert(FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info));

    acStandUp.Enabled := TRUE;

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
              if FTableStatus.GetBet(FTable.SeatIndex) < FTableStatus.HighestBet then
              begin
                if seat_info.Chips < FTableStatus.HighestBet then
                  acCall.Caption := 'CALL (ALL-IN)'
                else
                  acCall.Caption := Format('CALL (%.2f)', [(FTableStatus.HighestBet - FTableStatus.GetBet(FTable.SeatIndex)) / 100]);
                acCall.Enabled := TRUE;
                acFold.Enabled := TRUE;

                if seat_info.Chips > FTableStatus.HighestBet then
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

  if not sitout then
    cbSitOutNextHand.Checked := FALSE;
  cbSitOutNextHand.Visible := sitout;

  btStandUp.Visible := acStandUp.Enabled;
  btPlayNow.Visible := acPlayNow.Enabled;

  btCall.Visible := acCall.Enabled;
  btRaise.Visible := acRaise.Enabled;
  seRaiseAmount.Visible := acRaise.Enabled;
  tbRaise.Visible := acRaise.Enabled;

  if tbRaise.Visible then
  begin
    seRaiseAmount.Properties.MinValue := (FTableStatus.HighestBet + FTable.Game.BigBlind) / 100;
    seRaiseAmount.Value := seRaiseAmount.Properties.MinValue;
    tbRaise.Properties.Min := Trunc(seRaiseAmount.Properties.MinValue * 100);
    Assert(FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info));
    tbRaise.Properties.Max := FTableStatus.GetBet(seat_info.SeatIndex) + seat_info.Chips;
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

function TfrmTable.ConfirmLeaveTable: Boolean;
begin
  result := TRUE;
  if FTable.IsSitting then
    result := MessageDlg('Are you sure you want to leave the table? This will automatically fold your current hand and any chips that are in the pot.', mtWarning, mbYesNo, 0) = mrYes;
end;

function TfrmTable.ConfirmStandUp: Boolean;
begin
  result := TRUE;
  if FTable.IsSitting then
    result := MessageDlg('Are you sure you want to stand up? This will automatically fold your current hand and any chips that are in the pot.', mtWarning, mbYesNo, 0) = mrYes;
end;

procedure TfrmTable.CSRETableStatus(const AMessage: TMessageItem);
var
  pbtablestatus: TPB_TableStatus;
  C1           : Integer;
  tmp          : String;
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

  for C1 := 0 to pbtablestatus.Seats.Count - 1 do
    if CompareBytes(pbtablestatus.Seats[C1].PlayerMongoId, dmMain.SelfInfo.Id) then
    begin
      FTable.SeatIndex := pbtablestatus.Seats[C1].Seat;
      Break;
    end;

  tmp := '';
  for C1 := Low(pbtablestatus.Pots) to High(pbtablestatus.Pots) do
    if C1 = High(pbtablestatus.Pots) then
      tmp := tmp + FloatToStr(pbtablestatus.Pots[C1] / 100)
    else
      tmp := tmp + FloatToStr(pbtablestatus.Pots[C1] / 100) + ', ';

  lbsInfo.Caption := '';
  if FTableStatus.Locked then
    lbsInfo.Caption := '[LOCKED] ';

  lbsInfo.Caption := lbsInfo.Caption + Format('Pots: %s', [tmp]);

  {$IFDEF DEBUG}
  tmp := '';
  if pbtablestatus.Locked then
  begin
    tmp := 'YES';
  end
  else tmp := 'NO';

  DebugLn(Format('Dealer: %d; CurrentSeat: %d; TableState: %d; Seq:%d; Locked: %s', [pbtablestatus.Dealer, pbtablestatus.CurrentSeat, Integer(pbtablestatus.State), pbtablestatus.Seq, tmp]), ditApplication);
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
  pbtevent  : TPB_TableEvent;
  event     : String;
  C1        : Integer;
begin
  pbtevent := AMessage.Object_ as TPB_TableEvent;
  if not CompareBytes(pbtevent.TableMongoId, FTable.Game.MongoId) then
    Exit;

  case pbtevent.Event of
    teFold: event := 'FOLD';
    teSit: event := 'SIT';
    teStandUp: event := 'STAND UP';
    teWinning: event := 'WINNING';
    teDealing: event := 'DEALING';
    teCheck: event := 'CHECK';
    teCall: event := 'CALL';
    teRaise: event := 'RAISE';
    teAllIn: event := 'ALL IN';
  end;

  {$IFDEF DEBUG}
  if Length(pbtevent.Seats) > 0 then
  begin
    for C1 := 0 to Length(pbtevent.Seats) - 1 do
      if Length(pbtevent.Msgs) > C1 then
        AddUserChatMessage(Format('TBLEVENT [%d]', [pbtevent.Seats[C1]]), Format('%s %s', [event, pbtevent.msgs[C1]]))
      else
        AddUserChatMessage(Format('TBLEVENT [%d]', [pbtevent.Seats[C1]]), event);
  end
  else
    AddUserChatMessage('TBLEVENT', event);
  {$ENDIF}
end;

procedure TfrmTable.acCallExecute(Sender: TObject);
var
  seat_info  : TSeatInfo;
  call_amount: Integer;
begin
  Assert(FTableStatus.GetSeatInfo(FTable.SeatIndex, seat_info));
  if seat_info.Chips < FTableStatus.HighestBet then
    call_amount := seat_info.Chips
  else
    call_amount := FTableStatus.HighestBet;

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
  SocketClient.PutChips(FTable.Game.MongoId, seRaiseAmount.Value * 100);
end;

end.
