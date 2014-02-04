unit uTableForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, SynGdiPlus, Vcl.ComCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, cxMemo, uMessageItem, Vcl.Menus, cxButtons, uTableStatus,
  Vcl.ActnList, cxLabel, uTables, cxTextEdit, dxsChipUpDark, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, dxsChipUpDarkTabs, JPEG,
  GR32_Backends, GR32, GR32_Png, GR32_Resamplers, GR32_Image;

type
  TfrmTable = class(TForm)
    paBottom: TPanel;
    paChat: TPanel;
    edChat: TcxTextEdit;
    reChat: TRichEdit;
    ActionManager: TActionManager;
    acStandUp: TAction;
    acFold: TAction;
    acCall: TAction;
    acCheck: TAction;
    acRaise: TAction;
    PaintBox: TPaintBox32;
    paButtons: TPanel;
    btCallCheck: TcxButton;
    btFold: TcxButton;
    btRaise: TcxButton;
    btStandUp: TcxButton;
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
  private
    FFormAspectRatio: Double;
    FTable          : TTable;
    FTableStatus    : TTableStatus;
    FSeatPoints     : array[2..10, 0..9] of TPoint;

    FOrigTableW     : Integer;
    FOrigTableH     : Integer;
    FTableWidth     : Integer;
    FTableHeight    : Integer;
    FTableXOffset   : Integer;
    FTableYOffset   : Integer;

    FImg_TableBitmap: TBitmap32;
    FImg_Background : TBitmap32;

    procedure ConfigureSeatPoints;

    procedure Redraw(const APaintboxRepaint: Boolean = FALSE);

    procedure DrawSeat(const ASeatIndex: Integer);
    function GetSeatPoint(const ASeatIndex: Integer): TPoint;

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
  System.Types,
  uMessageContainer, uServerMessageCallback, uServerCodes, uPB_ChatEvent, uPB_ChatMessage, uPB_SeatInfo,
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uSocketClient, uCommon, uTableSitForm, uMainDataModule, uPlayerInfo, uAvatars, uPB_TableStatus, uPB_TableEvent;


constructor TfrmTable.Create(const ATable: TTable);
begin
  inherited Create(nil);

  ActionManager.State := asSuspended;

  if not Assigned(Gdip) then
    Gdip := TGDIPlusFull.Create('gdiplus.dll');

  FTable := ATable;
end;

procedure TfrmTable.FormCreate(Sender: TObject);
var
  rstream: TResourceStream;
  jpg    : TJPEGImage;
  png    : TPortableNetworkGraphic32;
begin
  FTableStatus := TTableStatus.Create;

  reChat.Lines.Clear;

  FFormAspectRatio := Width / Height;
  PaintBox.BufferOversize := 0;

  // load table image
  png := TPortableNetworkGraphic32.Create;
  try
    rstream := TResourceStream.Create(HInstance, 'Table', RT_RCDATA);
    try
      png.LoadFromStream(rstream);
      FImg_TableBitmap := TBitmap32.Create;
      FImg_TableBitmap.DrawMode := dmBlend;
      FImg_TableBitmap.Assign(png);
      FTableWidth := FImg_TableBitmap.Width;
      FTableHeight := FImg_TableBitmap.Height;
      FOrigTableW := FTableWidth;
      FOrigTableH := FTableHeight;
      ConfigureSeatPoints;

      FImg_TableBitmap.Resampler := TDraftResampler.Create;

      // Alternative is KernelResampler. Slower, but slightly higher quality resample. Code below:
  {
      FImg_TableBitmap.Resampler := TKernelResampler.Create;
      (FImg_TableBitmap.Resampler as TKernelResampler).Kernel := TLanczosKernel.Create;
  }
    finally
      rstream.Free;
    end;
  finally
    png.Free;
  end;

  // load background image
  FImg_Background := TBitmap32.Create;
  jpg := TJPEGImage.Create;
  try
    rstream := TResourceStream.Create(HInstance, 'TableBackground', RT_RCDATA);
    try
      jpg.LoadFromStream(rstream);
      FImg_Background.Assign(jpg);
    finally
      rstream.Free;
    end;
  finally
    jpg.Free;
  end;

  Caption := Format('%s - %s (%d/%d %s)', [FTable.Club.Name, FTable.Game.Name, FTable.Game.SmallBlind, FTable.Game.BigBlind, FTable.Game.GameTypeStrFull]);
  Redraw;
end;

procedure TfrmTable.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);

  FImg_Background.Free;
  FImg_TableBitmap.Free;

  FTableStatus.Free;
end;

procedure TfrmTable.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.WndParent := 0;
end;

procedure TfrmTable.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FTable.NotifyClose;
end;

procedure TfrmTable.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := TRUE;
  if FTable.IsSitting then
    CanClose := MessageDlg('Are you sure you want to leave the table? This will automatically fold your current hand and any chips that are in pot.', mtWarning, mbYesNo, 0) = mrYes;
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
  inherited;

  if MessageContainer.IsNewMessage(AMessage, msg) then
  begin
    case msg.MessageType of
      mtServerResponse: ProcessServerMessage(msg,
                          [
                            TServerMessageCallback.Create(seChat, CSRChatEvent),
                            TServerMessageCallback.Create(seTableStatus, CSRETableStatus),
                            TServerMessageCallback.Create(srTableSitOk, CSRETableStatus),
                            TServerMessageCallback.Create(srTableStandUpOk, CSRETableStatus),
                            TServerMessageCallback.Create(seTableEvent, CSETableEvent)
                          ]
                        );
    end;

    msg.IncReadCount;
  end;
end;

procedure TfrmTable.PaintBoxClick(Sender: TObject);
var
  C1               : Integer;
  client_cursor_pos: TPoint;
  seat_point       : TPoint;
  seat_rect        : TRect;
begin
  client_cursor_pos := ScreenToClient(Mouse.CursorPos);

  for C1 := 0 to FTable.Game.Seats - 1 do
  begin
    seat_point := GetSeatPoint(C1);
    seat_rect := TRect.Create(seat_point.X - 15, seat_point.Y - 15, seat_point.X + 15, seat_point.Y + 15);
    if (client_cursor_pos.X >= seat_rect.Left) and (client_cursor_pos.X <= seat_rect.Right) and
       (client_cursor_pos.Y >= seat_rect.Top) and (client_cursor_pos.Y <= seat_rect.Bottom) then
    begin
      if (not FTable.IsSitting) and
         (not FTableStatus.IsSeatTaken(C1)) then
      begin
        if RunModalForm(TfrmTableSit, self, [FTable.Game, @C1]) = mrOk then
        begin
          acStandUp.Enabled := TRUE;
          btStandUp.Visible := TRUE;
        end;
        Break;
      end;
    end;
  end;
end;

procedure TfrmTable.Redraw(const APaintboxRepaint: Boolean = FALSE);
var
  C1         : Integer;
  player_info: TPlayerInfo;
  avatar     : TAvatar;
  seat_point : TPoint;
  avatar_rect: TRect;
  seat_info  : TSeatInfo;
begin
  paBottom.Height := Round(Height / 5);
  paChat.Width := Round(Width / 2.5);

  PaintBox.Buffer.BeginUpdate;
  try
    // draw background
    PaintBox.Buffer.Draw(PaintBox.Buffer.BoundsRect, FImg_Background.BoundsRect, FImg_Background);

    // calculate table size and draw it
    FTableWidth := Round(0.85 * PaintBox.Buffer.Width);
    FTableHeight := Round(FTableWidth / (FImg_TableBitmap.Width / FImg_TableBitmap.Height));
    FTableXOffset := (PaintBox.Buffer.Width - FTableWidth) div 2;
    FTableYOffset := Round(PaintBox.Buffer.Height / 7);
    PaintBox.Buffer.Draw(Rect(FTableXOffset, FTableYOffset, FTableXOffset + FTableWidth, FTableYOffset + FTableHeight),
                         FImg_TableBitmap.BoundsRect,
                         FImg_TableBitmap);

    // draw seats
    for C1 := 0 to FTable.Game.Seats - 1 do
      DrawSeat(C1);

    // dealer button
    if FTableStatus.Dealer > -1 then
    begin
      seat_point := GetSeatPoint(FTableStatus.Dealer);
      PaintBox.Buffer.Font.Color := clYellow;
      PaintBox.Buffer.TextOut(seat_point.X + 17, seat_point.Y, 'D');
    end;

    // sb/bb
    if FTableStatus.SmallBlindSeat > -1 then
    begin
      seat_point := GetSeatPoint(FTableStatus.SmallBlindSeat);
      PaintBox.Buffer.Font.Color := clMoneyGreen;
      PaintBox.Buffer.TextOut(seat_point.X - 4, seat_point.Y + 17, 'SB');
      seat_point := GetSeatPoint(FTableStatus.BigBlindSeat);
      PaintBox.Buffer.Font.Color := clLime;
      PaintBox.Buffer.TextOut(seat_point.X - 4, seat_point.Y + 17, 'BB');
    end;

    // draw table cards
    PaintBox.Buffer.Font.Color := clWhite;
    PaintBox.Buffer.Font.Style := [fsBold];
    PaintBox.Buffer.TextOut((PaintBox.Buffer.Width - FTableWidth) div 2 + FTableWidth div 2 - 50, FTableYOffset + FTableHeight div 2 + 30, FTableStatus.FlopCards + ' ' + FTableStatus.TurnCard + ' ' + FTableStatus.RiverCard);
    PaintBox.Buffer.Font.Style := [];

    // draw player cards
    PaintBox.Buffer.Font.Color := clWhite;
    PaintBox.Buffer.Font.Style := [fsBold];
    for C1 := 0 to FTableStatus.Seats.Count - 1 do
      if FTableStatus.GetSeatInfo(FTableStatus.Seats[C1].SeatIndex, seat_info) then
      begin
        seat_point := GetSeatPoint(seat_info.SeatIndex);
        PaintBox.Buffer.TextOut(seat_point.X - 5, seat_point.Y - 40, seat_info.Cards);
      end;
    PaintBox.Buffer.Font.Style := [];

    // draw avatars
    for C1 := 0 to FTableStatus.Seats.Count - 1 do
    begin
      if dmMain.Players.FindPlayerById(FTableStatus.Seats[C1].PlayerMongoId, player_info) then
      begin
        if dmMain.Avatars.Find(player_info.AvatarId, avatar) then // if avatar is found, draw it
        begin
          seat_point := GetSeatPoint(FTableStatus.Seats[C1].SeatIndex);
          avatar_rect := TRect.Create(GR32.Point(seat_point.X - 25, seat_point.Y - 100), GR32.Point(seat_point.X + 25, seat_point.Y - 50));
          PaintBox.Buffer.Draw(avatar_rect, avatar.ImageBitmap.BoundsRect, avatar.ImageBitmap);
        end
        else // if avatar is not found, add it to avatar list, which will download it automatically
          dmMain.Avatars.AddAvatar(player_info.AvatarId);
      end;
    end;
  finally
    PaintBox.Buffer.EndUpdate;
  end;

  if APaintboxRepaint then
    PaintBox.Flush;
end;

procedure TfrmTable.ConfigureSeatPoints;
var
  y_center_point: Integer;
  x_center_point: Integer;
begin
  y_center_point := FTableHeight div 2 - 60;
  x_center_point := FTableWidth div 2;

  FSeatPoints[2, 0] := GR32.Point(FTableWidth - 75, y_center_point);
  FSeatPoints[2, 1] := GR32.Point(75, y_center_point);

  FSeatPoints[3, 0] := GR32.Point(FTableWidth - 75, y_center_point);
  FSeatPoints[3, 1] := GR32.Point(x_center_point, FTableHeight - 170);
  FSeatPoints[3, 2] := GR32.Point(75, y_center_point);

  FSeatPoints[4, 0] := GR32.Point(FTableWidth - 175, FTableHeight div 2 - 218);
  FSeatPoints[4, 1] := GR32.Point(FTableWidth - 175, FTableHeight div 2 + 100);
  FSeatPoints[4, 2] := GR32.Point(175, FTableHeight div 2 + 100);
  FSeatPoints[4, 3] := GR32.Point(175, FTableHeight div 2 - 218);

  FSeatPoints[5, 0] := GR32.Point(FTableWidth - 175, FTableHeight div 2 - 218);
  FSeatPoints[5, 1] := GR32.Point(FTableWidth - 175, FTableHeight div 2 + 100);
  FSeatPoints[5, 2] := GR32.Point(x_center_point, FTableHeight - 170);
  FSeatPoints[5, 3] := GR32.Point(175, FTableHeight div 2 + 100);
  FSeatPoints[5, 4] := GR32.Point(175, FTableHeight div 2 - 218);

  FSeatPoints[6, 0] := GR32.Point(FTableWidth - 285, FTableHeight div 2 - 263);
  FSeatPoints[6, 1] := GR32.Point(FTableWidth - 75, y_center_point);
  FSeatPoints[6, 2] := GR32.Point(FTableWidth - 285, FTableHeight div 2 + 145);
  FSeatPoints[6, 3] := GR32.Point(285, FTableHeight div 2 + 145);
  FSeatPoints[6, 4] := GR32.Point(75, y_center_point);
  FSeatPoints[6, 5] := GR32.Point(285, FTableHeight div 2 - 263);

  FSeatPoints[7, 0] := GR32.Point(FTableWidth - 285, FTableHeight div 2 - 263);
  FSeatPoints[7, 1] := GR32.Point(FTableWidth - 75, y_center_point);
  FSeatPoints[7, 2] := GR32.Point(FTableWidth - 285, FTableHeight div 2 + 155);
  FSeatPoints[7, 3] := GR32.Point(x_center_point, FTableHeight - 170);
  FSeatPoints[7, 4] := GR32.Point(285, FTableHeight div 2 + 155);
  FSeatPoints[7, 5] := GR32.Point(75, y_center_point);
  FSeatPoints[7, 6] := GR32.Point(285, FTableHeight div 2 - 263);

  // FIXME
end;

function TfrmTable.GetSeatPoint(const ASeatIndex: Integer): TPoint;
begin
  result := GR32.Point(FTableXOffset + Round(FSeatPoints[FTable.Game.Seats, ASeatIndex].X * (FTableWidth / FOrigTableW)),
                       FTableYOffset + Round(FSeatPoints[FTable.Game.Seats, ASeatIndex].Y * (FTableHeight / FOrigTableH)));
end;

procedure TfrmTable.DrawSeat(const ASeatIndex: Integer);
var
  seat_point: TPoint;
  seat_info : TSeatInfo;
begin
  seat_point := GetSeatPoint(ASeatIndex);

  PaintBox.Buffer.Canvas.Brush.Color := clWhite;
  if FTableStatus.GetSeatInfo(ASeatIndex, seat_info) then
  begin
    PaintBox.Buffer.Canvas.Brush.Color := clSkyBlue;
    if FTableStatus.CurrentSeat = ASeatIndex then
      PaintBox.Buffer.Canvas.Brush.Color := clRed;
  end;

  PaintBox.Buffer.Canvas.Ellipse(seat_point.X - 15, seat_point.Y - 15, seat_point.X + 15, seat_point.Y + 15);

  PaintBox.Buffer.Font.Color := clBlack;
  PaintBox.Buffer.TextOut(seat_point.X - 3, seat_point.Y - 7, IntToStr(ASeatIndex));
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
  SocketClient.TableStandUp(FTable.Game.MongoId);
  acStandUp.Enabled := FALSE;
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
      begin
        reChat.SelStart := reChat.GetTextLen;
        reChat.SelAttributes.Color := clLime;
        if reChat.SelStart = 0 then
          reChat.SelText := chat_message.Username
        else
          reChat.SelText := sLineBreak + chat_message.Username;

        reChat.SelStart := reChat.GetTextLen;
        reChat.SelAttributes.Color := clSilver;
        reChat.SelText := Format(': %s', [chat_message.Msg]);

        SendMessage(reChat.Handle, WM_VSCROLL, SB_BOTTOM, 0);
      end;
    end;
    ceServerMessage: ;
  end;
end;

procedure TfrmTable.ConfigureGUI;
begin
  acStandUp.Enabled := FALSE;
  acFold.Enabled := FALSE;
  acCall.Enabled := FALSE;
  acCheck.Enabled := FALSE;
  acRaise.Enabled := FALSE;

  if FTable.IsSitting then
  begin
    acStandUp.Enabled := TRUE;
    case FTableStatus.State of
      tsIdle: ;
      tsPreFlop,
      tsFlop,
      tsTurn,
      tsRiver: begin
        if FTableStatus.CurrentSeat = FTable.SeatIndex then
        begin
          if FTableStatus.GetBet(FTable.SeatIndex) < FTableStatus.HighestBet then
            acCall.Enabled := TRUE
          else
            acCheck.Enabled := TRUE;
          acFold.Enabled := TRUE;
          acRaise.Enabled := TRUE;
        end;
      end;
      tsWinning: ;
    end;
  end;

  btStandUp.Visible := acStandUp.Enabled;
  btFold.Visible := acFold.Enabled;
  btRaise.Visible := acRaise.Enabled;

  if (acCall.Enabled) or (acCheck.Enabled) then
  begin
    if acCall.Enabled then
      btCallCheck.Action := acCall
    else
      btCallCheck.Action := acCheck;
    btCallCheck.Visible := TRUE;
  end
  else
    btCallCheck.Visible := FALSE;  
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

  {$IFDEF DEBUG}
  tmp := '';
  DebugLn(Format('Dealer: %d; CurrentSeat: %d; TableState: %d', [pbtablestatus.Dealer, pbtablestatus.CurrentSeat, Integer(pbtablestatus.State)]), ditApplication);
  for C1 := 0 to Length(pbtablestatus.Bets) - 1 do
    tmp := tmp + Format('%d:%d ', [C1, pbtablestatus.Bets[C1]]);
  tmp := Trim(tmp);
  if tmp <> '' then
    DebugLn('BETS: ' + tmp, ditApplication);
  case pbtablestatus.State of
    tsFlop: DebugLn(Format('FLOP: %s', [pbtablestatus.Flop]), ditApplication);
    tsTurn: DebugLn(Format('TURN: %s', [pbtablestatus.Turn]), ditApplication);
    tsRiver: DebugLn(Format('RIVER: %s', [pbtablestatus.River]), ditApplication);
  end;
  {$ENDIF}

  ConfigureGUI;

  Redraw(TRUE);
end;

procedure TfrmTable.CSETableEvent(const AMessage: TMessageItem);
var
  pbtevent: TPB_TableEvent;
  event   : String;
  C1      : Integer;
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
  end;

  {$IFDEF DEBUG}
  if Length(pbtevent.Seats) > 0 then
  begin
    for C1 := 0 to Length(pbtevent.Seats) - 1 do
      DebugLn(Format('Player %d: %s', [pbtevent.Seats[C1], event]), ditApplication);
  end
  else
    DebugLn(Format('TABLE EVENT: %s', [event]), ditApplication);
  {$ENDIF}
end;

procedure TfrmTable.acCallExecute(Sender: TObject);
begin
  SocketClient.PutChips(FTable.Game.MongoId, FTableStatus.HighestBet);
end;

procedure TfrmTable.acCheckExecute(Sender: TObject);
begin
  SocketClient.PutChips(FTable.Game.MongoId, FTableStatus.GetBet(FTable.SeatIndex));
end;

procedure TfrmTable.acFoldExecute(Sender: TObject);
begin
  SocketClient.Fold(FTable.Game.MongoId);
end;

procedure TfrmTable.acRaiseExecute(Sender: TObject);
begin
  SocketClient.PutChips(FTable.Game.MongoId, FTableStatus.HighestBet * 2);
end;

end.


