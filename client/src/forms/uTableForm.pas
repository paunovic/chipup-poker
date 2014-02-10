unit uTableForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, cxMemo, uMessageItem, Vcl.Menus, cxButtons, uTableStatus,
  Vcl.ActnList, cxLabel, uTables, cxTextEdit, dxsChipUpDark, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, dxsChipUpDarkTabs, JPEG,
  GR32_Backends, GR32, GR32_Png, GR32_Resamplers, GR32_Image, dxsChipUpRedButton, cxRichEdit;

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
    btCallCheck: TcxButton;
    btFold: TcxButton;
    btRaise: TcxButton;
    btStandUp: TcxButton;
    lbsInfo: TcxLabel;
    reChat: TcxRichEdit;
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

    FTableWidth     : Integer;
    FTableHeight    : Integer;
    FTableXOffset   : Integer;
    FTableYOffset   : Integer;

    procedure Redraw(const APaintboxRepaint: Boolean = FALSE);
    procedure AddUserChatMessage(const AUser, AMessage: String);

    function ConfirmLeaveTable: Boolean;
    function ConfirmStandUp: Boolean;

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
  System.Types, cxClasses,
  uMessageContainer, uServerMessageCallback, uServerCodes, uPB_ChatEvent, uPB_ChatMessage, uPB_SeatInfo, uTableResources,
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  uSocketClient, uCommon, uTableSitForm, uMainDataModule, uPlayerInfo, uAvatars, uPB_TableStatus, uPB_TableEvent;


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

  Caption := Format('%s - %s (%d/%d %s)', [FTable.Club.Name, FTable.Game.Name, FTable.Game.SmallBlind, FTable.Game.BigBlind, FTable.Game.GameTypeStrFull]);
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

//  AParams.ExStyle := AParams.ExStyle + WS_CLIPCHILDREN;
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
  chat_width : Integer;
  cards      : String;
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
    FTableWidth := Round(0.85 * PaintBox.Buffer.Width);
    FTableHeight := Round(FTableWidth / (TTableResources.TableImage.Width / TTableResources.TableImage.Height));
    FTableXOffset := (PaintBox.Buffer.Width - FTableWidth) div 2;
    FTableYOffset := Round(PaintBox.Buffer.Height / 7);
    PaintBox.Buffer.Draw(Rect(FTableXOffset, FTableYOffset, FTableXOffset + FTableWidth, FTableYOffset + FTableHeight),
                         TTableResources.TableImage.BoundsRect,
                         TTableResources.TableImage);

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

    case FTableStatus.State of
      tsFlop: cards := FTableStatus.FlopCards.AsString;
      tsTurn: cards := FTableStatus.FlopCards.AsString + ' '  + FTableStatus.TurnCard.AsString;
      tsRiver,
      tsWinning,
      tsWinning2: cards := FTableStatus.FlopCards.AsString + ' '  + FTableStatus.TurnCard.AsString + ' ' + FTableStatus.RiverCard.AsString;
    end;

    PaintBox.Buffer.TextOut((PaintBox.Buffer.Width - FTableWidth) div 2 + FTableWidth div 2 - 50, FTableYOffset + FTableHeight div 2 + 30, cards);
    PaintBox.Buffer.Font.Style := [];

    // draw player cards
    PaintBox.Buffer.Font.Color := clWhite;
    PaintBox.Buffer.Font.Style := [fsBold];
    for C1 := 0 to FTableStatus.Seats.Count - 1 do
      if FTableStatus.GetSeatInfo(FTableStatus.Seats[C1].SeatIndex, seat_info) then
      begin
        seat_point := GetSeatPoint(seat_info.SeatIndex);
        PaintBox.Buffer.TextOut(seat_point.X - 15, seat_point.Y - 45, seat_info.Cards.AsString);
      end;
    PaintBox.Buffer.Font.Style := [];

    // draw player balances
    PaintBox.Buffer.Font.Color := clLime;
    PaintBox.Buffer.Font.Style := [fsBold];
    for C1 := 0 to FTableStatus.Seats.Count - 1 do
      if FTableStatus.GetSeatInfo(FTableStatus.Seats[C1].SeatIndex, seat_info) then
      begin
        seat_point := GetSeatPoint(seat_info.SeatIndex);
        PaintBox.Buffer.TextOut(seat_point.X - 15, seat_point.Y - 30, IntToStr(seat_info.Chips));
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

function TfrmTable.GetSeatPoint(const ASeatIndex: Integer): TPoint;
begin
  result := GR32.Point(FTableXOffset + Round(TTableResources.SeatPoints[FTable.Game.Seats, ASeatIndex].X * (FTableWidth / TTableResources.TableOriginalWidth)),
                       FTableYOffset + Round(TTableResources.SeatPoints[FTable.Game.Seats, ASeatIndex].Y * (FTableHeight / TTableResources.TableOriginalHeight)));
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
      tmp := tmp + IntToStr(pbtablestatus.Pots[C1])
    else
      tmp := tmp + IntToStr(pbtablestatus.Pots[C1]) + ', ';

  lbsInfo.Caption := Format('Pots: %s', [tmp]);

  {$IFDEF DEBUG}
  tmp := '';
  DebugLn(Format('Dealer: %d; CurrentSeat: %d; TableState: %d', [pbtablestatus.Dealer, pbtablestatus.CurrentSeat, Integer(pbtablestatus.State)]), ditApplication);
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
    teCheck: event := 'CHECK';
    teCall: event := 'CALL';
    teRaise: event := 'RAISE';
  end;

  {$IFDEF DEBUG}
  if Length(pbtevent.Seats) > 0 then
  begin
    for C1 := 0 to Length(pbtevent.Seats) - 1 do
      AddUserChatMessage(Format('TBLEVENT [%d]', [pbtevent.Seats[C1]]), event);
  end
  else
    AddUserChatMessage('TBLEVENT', event);
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
  SocketClient.PutChips(FTable.Game.MongoId, FTableStatus.HighestBet + FTable.Game.BigBlind);
end;

end.


