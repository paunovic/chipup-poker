unit uTableForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, SynGdiPlus, Vcl.ComCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinDarkRoom, cxTextEdit, cxMemo, uMessageItem, Vcl.Menus, cxButtons,
  Vcl.ActnList, cxLabel, uTable;

type
  TfrmTable = class(TForm)
    PaintBox: TPaintBox;
    paBottom: TPanel;
    paChat: TPanel;
    edChat: TcxTextEdit;
    reChat: TRichEdit;
    btSitStandUp: TcxButton;
    alTable: TActionList;
    acShowTableSitForm: TAction;
    acStandUp: TAction;
    lbsInfo: TcxLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PaintBoxPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edChatKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure acShowTableSitFormExecute(Sender: TObject);
    procedure acStandUpExecute(Sender: TObject);
  private
    FFormAspectRatio: Double;
    FTable          : TTable;

    FPaintBoxBitmap : TBitmap;

    FMF_Table       : TMetaFile;
    FImg_Background : TPngImage;
    FMFP_Table      : Double;

    function CreateMetafile(const AResourceName: String; var AProportions: Double): TMetaFile;
    procedure ResizeControls;

    procedure TCChatEvent(const AMessage: TMessageItem);
    procedure TCTableStatus(const AMessage: TMessageItem);

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
  uMessageContainer, uServerMessageCallback, uServerCodes, uPB_ChatEvent, uPB_ChatMessage, uPB_TableStatus,
  uSocketClient, uCommon, uTableSitForm, uMainDataModule;


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
  SocketClient.JoinTable(FTable.Game.MongoId);

  reChat.Lines.Clear;

  FFormAspectRatio := Width / Height;

  FPaintBoxBitmap := TBitmap.Create;

  FMF_Table := CreateMetafile('GameTable', FMFP_Table);
  FImg_Background := TPngImage.Create;
  FImg_Background.LoadFromResourceName(HInstance, 'GameCarpet');

  Caption := Format('%s - %s (%d/%d %s)', [FTable.Club.Name, FTable.Game.Name, FTable.Game.SmallBlind, FTable.Game.BigBlind, FTable.Game.GameTypeStrFull]);

  ResizeControls;
end;

procedure TfrmTable.FormDestroy(Sender: TObject);
begin
  MessageContainer.RemoveMessageHandler(Handle);

  FMF_Table.Free;
  FImg_Background.Free;
  FPaintBoxBitmap.Free;

  SocketClient.LeaveTable(FTable.Game.MongoId);
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

  ResizeControls;
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
                            TServerMessageCallback.Create(EVENT_CHAT, TCChatEvent),
                            TServerMessageCallback.Create(SR_TABLE_STATUS, TCTableStatus),
                            TServerMessageCallback.Create(SR_TABLE_SIT_OK, TCTableStatus),
                            TServerMessageCallback.Create(SR_TABLE_STAND_UP_OK, TCTableStatus)
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

procedure TfrmTable.ResizeControls;
var
  w, h: Integer;
  R   : TRect;
  X, Y: Integer;
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
end;

procedure TfrmTable.edChatKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = vk_RETURN then
  begin
    SocketClient.SendTableChatLine(FTable.Game.MongoId, edChat.Text);
    edChat.Clear;
  end;
end;

procedure TfrmTable.acShowTableSitFormExecute(Sender: TObject);
begin
  if RunModalForm(TfrmTableSit, self, [FTable.Game]) = mrOk then
  begin
    acStandUp.Enabled := TRUE;
    btSitStandUp.Action := acStandUp;
  end;
end;

procedure TfrmTable.acStandUpExecute(Sender: TObject);
begin
  SocketClient.TableStandUp(FTable.Game.MongoId);
  acStandUp.Enabled := FALSE;
end;

procedure TfrmTable.TCChatEvent(const AMessage: TMessageItem);
var
  chat_event  : TPB_ChatEvent;
  chat_message: TPB_ChatMessage;
begin
  chat_event := AMessage.Object_ as TPB_ChatEvent;

  case chat_event.Event of
    ceUserMessage: begin
      chat_message := chat_event.Msg;
      if chat_event.TableId = FTable.Game.MongoId then
      begin
        reChat.SelStart := reChat.GetTextLen;
        reChat.SelAttributes.Color := clLime;
        reChat.SelText := String(chat_message.Username);

        reChat.SelStart := reChat.GetTextLen;
        reChat.SelAttributes.Color := clSilver;
        reChat.SelText := Format(': %s', [chat_message.Msg]) + sLineBreak;

        SendMessage(reChat.Handle, WM_VSCROLL, SB_BOTTOM, 0);
      end;
    end;
    ceServerMessage: ;
  end;
end;

procedure TfrmTable.TCTableStatus(const AMessage: TMessageItem);
var
  pbtablestatus: TPB_TableStatus;
  C1: Integer;
begin
  pbtablestatus := AMessage.Object_ as TPB_TableStatus;
  if pbtablestatus.TableMongoId <> FTable.Game.MongoId then
    Exit;

  if alTable.State = asSuspended then
    alTable.State := asNormal;

  case AMessage.MethodId of
    SR_TABLE_STAND_UP_OK: begin
      btSitStandUp.Action := acShowTableSitForm;
      acShowTableSitForm.Enabled := TRUE;
    end;
  end;

  lbsInfo.Caption := 'Taken seats: ';
  for C1 := 0 to pbtablestatus.Seats.Count - 1 do
  begin
    lbsInfo.Caption := lbsInfo.Caption + IntToStr(pbtablestatus.Seats[C1].Seat);
    if LowerCase(String(pbtablestatus.Seats[C1].PlayerMongoIdHex)) = LowerCase(dmMain.SelfInfo.Id) then
      lbsInfo.Caption := lbsInfo.Caption + ' (you)';
    lbsInfo.Caption := lbsInfo.Caption + ',';
  end;
end;


end.


