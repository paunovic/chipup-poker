unit uTableForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, SynGdiPlus, Vcl.ComCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinDarkRoom, cxMemo, uMessageItem, Vcl.Menus, cxButtons,
  Vcl.ActnList, cxLabel, uTables, cxTextEdit, uPB_TableStatus;

type
  TfrmTable = class(TForm)
    PaintBox: TPaintBox;
    paBottom: TPanel;
    paChat: TPanel;
    edChat: TcxTextEdit;
    reChat: TRichEdit;
    btStandUp: TcxButton;
    alTable: TActionList;
    acStandUp: TAction;
    lbsInfo: TcxLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PaintBoxPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure acStandUpExecute(Sender: TObject);
    procedure PaintBoxClick(Sender: TObject);
    procedure edChatKeyPress(Sender: TObject; var Key: Char);
  private
    FFormAspectRatio: Double;
    FTable          : TTable;
    FLastTableStatus: TPB_TableStatus;

    FPaintBoxBitmap : TBitmap;

    FMF_Table       : TMetaFile;
    FImg_Background : TPngImage;
    FMFP_Table      : Double;

    function CreateMetafile(const AResourceName: String; var AProportions: Double): TMetaFile;
    procedure Redraw(const APaintboxRepaint: Boolean = FALSE);
    procedure AssignTableStatus(const ASource, ATarget: TPB_TableStatus);

    procedure DrawSeat(const ASeatIndex: Integer);
    function GetSeatPoint(const ASeatIndex: Integer): TPoint;

    procedure CSRChatEvent(const AMessage: TMessageItem);
    procedure CSRTableStatus(const AMessage: TMessageItem);

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
  uMessageContainer, uServerMessageCallback, uServerCodes, uPB_ChatEvent, uPB_ChatMessage, uPB_SeatInfo,
  uSocketClient, uCommon, uTableSitForm, uMainDataModule, uPlayerInfo, uAvatars
  {$IFDEF DEBUG}, uDebugForm {$ENDIF};


constructor TfrmTable.Create(const ATable: TTable);
begin
  inherited Create(nil);

  alTable.State := asSuspended;

  if not Assigned(Gdip) then
    Gdip := TGDIPlusFull.Create('gdiplus.dll');

  FTable := ATable;
end;

procedure TfrmTable.FormCreate(Sender: TObject);
begin
  FLastTableStatus := TPB_TableStatus.Create;

  reChat.Lines.Clear;

  FFormAspectRatio := Width / Height;

  FPaintBoxBitmap := TBitmap.Create;

  FMF_Table := CreateMetafile('GameTable', FMFP_Table);
  FImg_Background := TPngImage.Create;
  FImg_Background.LoadFromResourceName(HInstance, 'GameCarpet');

  Caption := Format('%s - %s (%d/%d %s)', [FTable.Club.Name, FTable.Game.Name, FTable.Game.SmallBlind, FTable.Game.BigBlind, FTable.Game.GameTypeStrFull]);

  Redraw;
end;

procedure TfrmTable.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);

  FMF_Table.Free;
  FImg_Background.Free;
  FPaintBoxBitmap.Free;

  FLastTableStatus.Free;
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

procedure TfrmTable.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0, 0, FPaintBoxBitmap);
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
                            TServerMessageCallback.Create(srTableStatus, CSRTableStatus),
                            TServerMessageCallback.Create(srTableSitOk, CSRTableStatus),
                            TServerMessageCallback.Create(srTableStandUpOk, CSRTableStatus)
                          ]
                        );
    end;

    msg.IncReadCount;
  end;
end;

function TfrmTable.CreateMetafile(const AResourceName: String; var AProportions: Double): TMetaFile;
var
  rstream: TResourceStream;
begin
  result := TMetafile.Create;

  rstream := TResourceStream.Create(HInstance, AResourceName, RT_RCDATA);
  try
    result.LoadFromStream(rstream);
  finally
    rstream.Free;
  end;

  AProportions := result.Width / result.Height;
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
      if not FTable.IsSitting then // not sitting, show table sit form then
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
  w, h: Integer;
  R   : TRect;
  X, Y: Integer;
  C1  : Integer;
  player_info: TPlayerInfo;
  avatar     : TAvatar;
  seat_point : TPoint;
  avatar_rect: TRect;
begin
  R := TRect.Create(0, 0, PaintBox.Width, PaintBox.Height);

  FPaintBoxBitmap.SetSize(R.Width, R.Height);

  // tile background
  Y := 0;
  while Y < FPaintBoxBitmap.Height do
  begin
    X := 0;
    while X < FPaintBoxBitmap.Width do
    begin
      FPaintBoxBitmap.Canvas.Draw(X, Y, FImg_Background);
      Inc(X, FImg_Background.Width);
    end;
    Inc(Y, FImg_Background.Height);
  end;

  // calculate table size and draw it
  w := Round(0.75 * ClientWidth); // 75% of form width
  h := Round(w / FMFP_Table);
  FMF_Table.SetSize(w, h);
  Gdip.DrawAntiAliased(FMF_Table, FPaintBoxBitmap.Canvas.Handle, TRect.Create(Point((FPaintBoxBitmap.Width - FMF_Table.Width) div 2, 50), w, h));

  // draw seats
  for C1 := 0 to FTable.Game.Seats - 1 do
    DrawSeat(C1);

  // draw avatars
  if Assigned(FLastTableStatus) then
    if Assigned(FLastTableStatus.Seats) then
      for C1 := 0 to FLastTableStatus.Seats.Count - 1 do
      begin
        if dmMain.Players.FindPlayerById(FLastTableStatus.Seats[C1].PlayerMongoId, player_info) then
        begin
          if dmMain.Avatars.Find(player_info.AvatarId, avatar) then // if avatar is found, draw it
          begin
            seat_point := GetSeatPoint(FLastTableStatus.Seats[C1].Seat);
            avatar_rect := TRect.Create(Point(seat_point.X - 25, seat_point.Y - 70), Point(seat_point.X + 25, seat_point.Y - 20));
            FPaintBoxBitmap.Canvas.StretchDraw(avatar_rect, avatar.Image);
          end
          else // if avatar is not found, add it to avatar list, which will download it automatically
            dmMain.Avatars.AddAvatar(player_info.AvatarId);
        end;
      end;

  // repaint paintbox if needed
  if APaintboxRepaint then
    PaintBox.Repaint;
end;

function TfrmTable.GetSeatPoint(const ASeatIndex: Integer): TPoint;
begin
  case FTable.Game.Seats of
    2: begin
      case ASeatIndex of
        0: result := TPoint.Create((FPaintBoxBitmap.Width - FMF_Table.Width) div 2, 50 + FMF_Table.Height div 2);
        1: result := TPoint.Create((FPaintBoxBitmap.Width - FMF_Table.Width) div 2 + FMF_Table.Width, 50 + FMF_Table.Height div 2);
      end;
    end;

    6: begin
      case ASeatIndex of
        0: result := TPoint.Create((FPaintBoxBitmap.Width - FMF_Table.Width) div 2, 50 + FMF_Table.Height div 2 - 40);
        1: result := TPoint.Create((FPaintBoxBitmap.Width - FMF_Table.Width) div 2, 50 + FMF_Table.Height div 2 + 40);
        2: result := TPoint.Create(FPaintBoxBitmap.Width div 2 - 120, 50 + FMF_Table.Height);
        3: result := TPoint.Create(FPaintBoxBitmap.Width div 2 + 120, 50 + FMF_Table.Height);
        4: result := TPoint.Create((FPaintBoxBitmap.Width - FMF_Table.Width) div 2 + FMF_Table.Width, 50 + FMF_Table.Height div 2 + 40);
        5: result := TPoint.Create((FPaintBoxBitmap.Width - FMF_Table.Width) div 2 + FMF_Table.Width, 50 + FMF_Table.Height div 2 - 40);
      end;
    end;
  end;
end;

procedure TfrmTable.DrawSeat(const ASeatIndex: Integer);
var
  C1        : Integer;
  seat_point: TPoint;
begin
  seat_point := GetSeatPoint(ASeatIndex);

  FPaintBoxBitmap.Canvas.Brush.Color := clWhite;
  if Assigned(FLastTableStatus.Seats) then
    for C1 := 0 to FLastTableStatus.Seats.Count - 1 do
      if FLastTableStatus.Seats[C1].Seat = ASeatIndex then
      begin
        FPaintBoxBitmap.Canvas.Brush.Color := clRed;
        Break;
      end;

  FPaintBoxBitmap.Canvas.Ellipse(seat_point.X - 15, seat_point.Y - 15, seat_point.X + 15, seat_point.Y + 15);
  FPaintBoxBitmap.Canvas.TextOut(seat_point.X - 3, seat_point.Y - 7, IntToStr(ASeatIndex));
end;

procedure TfrmTable.AssignTableStatus(const ASource, ATarget: TPB_TableStatus);
var
  C1  : Integer;
  seat: TPB_SeatInfo;
begin
  ATarget.TableMongoId := ASource.TableMongoId;

  if not Assigned(ATarget.Seats) then
    ATarget.Seats := TPB_SeatInfos.Create;
  ATarget.Seats.Clear;

  if Assigned(ASource.Seats) then
    for C1 := 0 to ASource.Seats.Count - 1 do
    begin
      seat := TPB_SeatInfo.Create;
      seat.PlayerMongoId := ASource.Seats[C1].PlayerMongoId;
      seat.Seat := ASource.Seats[C1].Seat;
      seat.Chips := ASource.Seats[C1].Chips;
      seat.Cards := ASource.Seats[C1].Cards;
      seat.CardCount := ASource.Seats[C1].CardCount;
      ATarget.Seats.Add(seat);
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

procedure TfrmTable.CSRTableStatus(const AMessage: TMessageItem);
var
  pbtablestatus: TPB_TableStatus;
  C1: Integer;
begin
  pbtablestatus := AMessage.Object_ as TPB_TableStatus;
  if not CompareBytes(pbtablestatus.TableMongoId, FTable.Game.MongoId) then
    Exit;

  AssignTableStatus(pbtablestatus, FLastTableStatus);

  Redraw(TRUE);

  if alTable.State = asSuspended then
    alTable.State := asNormal;

  case AMessage.MethodId of
    Integer(srTableStandUpOk): begin
      FTable.SeatIndex := -1;
      acStandUp.Enabled := FALSE;
      btStandUp.Visible := FALSE;
    end;
  end;

  lbsInfo.Caption := 'Taken seats: ';
  for C1 := 0 to pbtablestatus.Seats.Count - 1 do
  begin
    lbsInfo.Caption := lbsInfo.Caption + IntToStr(pbtablestatus.Seats[C1].Seat);
    if CompareBytes(pbtablestatus.Seats[C1].PlayerMongoId, dmMain.SelfInfo.Id) then
    begin
      FTable.SeatIndex := pbtablestatus.Seats[C1].Seat;
      lbsInfo.Caption := lbsInfo.Caption + ' (you)';
      {$IFDEF DEBUG} DebugLn(Format('your cards:%s',[pbtablestatus.Seats[C1].Cards]),ditSocket); {$ENDIF}
    end;
    lbsInfo.Caption := lbsInfo.Caption + ',';
  end;
end;


end.


