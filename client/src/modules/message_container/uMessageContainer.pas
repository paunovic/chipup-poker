unit uMessageContainer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Generics.Collections, OverbyteIcsWSocket,
  uMessageItem;

type
  TMessageContainer = class
  private
    FMsg_NewMessage : DWORD;
    FItems          : TMessageItems;
    FMessageHandlers: TList<HWND>;
    FNextId         : Integer;

    procedure AddMessage(const AMessage: TMessageItem);
    procedure CleanupMessages;

  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    procedure AddMessageHandler(const AHWND: HWND);
    procedure RemoveMessageHandler(const AHWND: HWND);
    procedure RemoveMessageReader(const AMessageId: Integer; const AReaderHandle: HWND);

    function IsNewMessage(const AMessage: TMessage; out AMessageItem: TMessageItem): Boolean;

    procedure AddServerMessage(const AMethodId: Integer; const AObject: TObject);
    procedure AddSocketChangeMessage(const AOldState, ANewState: TSocketState);

    function GetMessage(const AId: Integer; out AMessage: TMessageItem): Boolean;

    property MessageHandlers: TList<HWND> read FMessageHandlers;
    property NewMessage     : DWORD read FMsg_NewMessage;
    property Items          : TMessageItems read FItems;
  end;

var
  MessageContainer: TMessageContainer;


implementation

uses
  {$IFDEF DEBUG} uDebugForm, {$ENDIF}
  System.SysUtils;


class procedure TMessageContainer.Initialize;
begin
  MessageContainer := TMessageContainer.Create;
end;

class procedure TMessageContainer.Deinitialize;
begin
  FreeAndNil(MessageContainer);
end;


constructor TMessageContainer.Create;
begin
  FMsg_NewMessage := RegisterWindowMessage('chipupclientmcmsg');

  FMessageHandlers := TList<HWND>.Create;

  FItems := TMessageItems.Create;
  FNextId := 1;
end;

destructor TMessageContainer.Destroy;
begin
  FItems.Free;
  FMessageHandlers.Free;

  inherited;
end;

procedure TMessageContainer.AddMessageHandler(const AHWND: HWND);
var
  C1: Integer;
begin
  {$IFDEF DEBUG} DebugLn(Format('New message handler [%d]', [AHWND]), ditForm); {$ENDIF}

  for C1 := 0 to FMessageHandlers.Count - 1 do
    if FMessageHandlers[C1] = AHWND then
      Exit;

  FMessageHandlers.Add(AHWND);
end;

procedure TMessageContainer.RemoveMessageHandler(const AHWND: HWND);
var
  C1: Integer;
begin
  {$IFDEF DEBUG} DebugLn(Format('Remove message handler [%d]', [AHWND]), ditForm); {$ENDIF}

  for C1 := 0 to FItems.Count - 1 do
    FItems[C1].RemoveReader(AHWND);
  CleanupMessages;

  C1 := 0;
  while C1 < FMessageHandlers.Count do
  begin
    if FMessageHandlers[C1] = AHWND then
      FMessageHandlers.Delete(C1)
    else
      Inc(C1);
  end;
end;

procedure TMessageContainer.RemoveMessageReader(const AMessageId: Integer; const AReaderHandle: HWND);
var
  msg: TMessageItem;
begin
  if GetMessage(AMessageId, msg) then
  begin
    msg.RemoveReader(AReaderHandle);
    CleanupMessages;
  end;
end;

procedure TMessageContainer.CleanupMessages;
var
  C1: Integer;
begin
  C1 := 0;
  while C1 < FItems.Count do
    if FItems[C1].ReaderCount = 0 then
      FItems.Delete(C1)
    else
      Inc(C1);

  if FItems.Count = 0 then
    FNextId := 0;
end;

function TMessageContainer.IsNewMessage(const AMessage: TMessage; out AMessageItem: TMessageItem): Boolean;
begin
  if AMessage.Msg <> FMsg_NewMessage then
    Exit(FALSE);

  result := (AMessage.Msg = FMsg_NewMessage) and (GetMessage(AMessage.WParam, AMessageItem));
end;

procedure TMessageContainer.AddMessage(const AMessage: TMessageItem);
begin
  Inc(FNextId);
  FItems.Add(AMessage);

  AMessage.NotifyHandlers(FMsg_NewMessage);
end;

procedure TMessageContainer.AddServerMessage(const AMethodId: Integer; const AObject: TObject);
var
  srv_message: TMessageItem;
begin
  srv_message := TMessageItem.Create(FNextId, mtServerResponse, FMessageHandlers);
  srv_message.SetServerResponseParams(AMethodId, AObject);
  AddMessage(srv_message);
end;

procedure TMessageContainer.AddSocketChangeMessage(const AOldState, ANewState: TSocketState);
var
  sc_message: TMessageItem;
begin
  sc_message := TMessageItem.Create(FNextId, mtSocketChangeState, FMessageHandlers);
  sc_message.SetSocketChangeStateParams(AOldState, ANewState);
  AddMessage(sc_message);
end;

function TMessageContainer.GetMessage(const AId: Integer; out AMessage: TMessageItem): Boolean;
var
  C1: Integer;
begin
  for C1 := 0 to FItems.Count - 1 do
    if FItems[C1].Id = AId then
    begin
      AMessage := FItems[C1];
      Exit(TRUE);
    end;

  Exit(FALSE);
end;


end.
