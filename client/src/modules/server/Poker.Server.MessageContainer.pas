unit Poker.Server.MessageContainer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Generics.Collections, OverbyteIcsWSocket, System.SyncObjs,
  Poker.Server.MessageCallbacks;

type
  TMessageContainer = class
  private
    FReceiverWnd         : HWND;
    FServerReplyMsg      : UINT;
    FSocketStateChangeMsg: UINT;
    FCallbackSets        : TObjectList<TCallbackSet>;
    FLock                : TCriticalSection;
    FLockCount           : Integer;

    procedure ReceiverWndProc(var AMessage: TMessage);
    procedure ProcessMessage(const AMessage: TMessage);
    function GetCallbackSetsCount: Integer;

  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    function AddCallbacks(const ACallbacks: array of TObject): Integer;
    procedure RemoveCallbacks(var AId: Integer);

    property CallbackSetsCount: Integer read GetCallbackSetsCount;
    property ReceiverWnd: HWND read FReceiverWnd;
    property ServerReplyMsg: UINT read FServerReplyMsg;
    property SocketStateChangeMsg: UINT read FSocketStateChangeMsg;
  end;

var
  MessageContainer: TMessageContainer;


implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, Poker.Protobufs.Enum.ServerCodes, {$ENDIF}
  System.SysUtils, System.Classes;


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
  FLock := TCriticalSection.Create;
  FLockCount := 0;

  FServerReplyMsg := RegisterWindowMessage('CUPMCSRMSG');
  FSocketStateChangeMsg := RegisterWindowMessage('CUPMCSSCMMSG');

  FReceiverWnd := AllocateHwnd(ReceiverWndProc);

  FCallbackSets := TObjectList<TCallbackSet>.Create;
end;

destructor TMessageContainer.Destroy;
begin
  FCallbackSets.Free;

  DeallocateHWnd(FReceiverWnd);

  FLock.Free;

  inherited;
end;

function TMessageContainer.GetCallbackSetsCount: Integer;
begin
  result := FCallbackSets.Count;
end;

function TMessageContainer.AddCallbacks(const ACallbacks: array of TObject): Integer;
var
  callback_set: TCallbackSet;
  id          : Integer;
  found       : Boolean;
begin
  FLock.Acquire;
  try
    id := 0;
    repeat
      found := FALSE;
      for callback_set in FCallbackSets do
        if callback_set.Id = id then
        begin
          Inc(id);
          found := TRUE;
          Break;
        end;
    until not found;

    callback_set := TCallbackSet.Create(id, ACallbacks);
    FCallbackSets.Add(callback_set);
    result := id;
  finally
    FLock.Release;
  end;
end;

procedure TMessageContainer.RemoveCallbacks(var AId: Integer);
var
  callback: TCallbackSet;
begin
  FLock.Acquire;
  try
    for callback in FCallbackSets do
      if callback.Id = AId then
      begin
        callback.Removed := TRUE;
        Break;
      end;
    AId := -1;
  finally
    FLock.Release;
  end;
end;

procedure TMessageContainer.ProcessMessage(const AMessage: TMessage);
var
  callback_set: TCallbackSet;
  obj, data_obj: TObject;
  callback_servermsg: TServerMessageCallback;
begin
  FLock.Acquire;
  try
    Inc(FLockCount);

    data_obj := nil;
    if AMessage.Msg = FServerReplyMsg then
      data_obj := pointer(AMessage.WParam);

    for callback_set in FCallbackSets do
      if (not Assigned(callback_set)) or
         (callback_set.Removed) then
        Continue
      else
        for obj in callback_set do
        begin
          if callback_set.Removed then
            Break;

          if (AMessage.Msg = FServerReplyMsg) and
             (obj is TServerMessageCallback) then
          begin
            callback_servermsg := obj as TServerMessageCallback;
            if Integer(callback_servermsg.Code) = AMessage.LParam then
              callback_servermsg.Callback(AMessage.LParam, data_obj)
          end
          else
            if (AMessage.Msg = FSocketStateChangeMsg) and (obj is TSocketStateChangeCallback) then
              (obj as TSocketStateChangeCallback).Callback(TSocketState(AMessage.WParam), TSocketState(AMessage.LParam));
        end;

    if Assigned(data_obj) then
      data_obj.Free;
    Dec(FLockCount);
  finally
    FLock.Release;
  end;
end;


procedure TMessageContainer.ReceiverWndProc(var AMessage: TMessage);
var
  C1: Integer;
begin
  if (AMessage.Msg = FServerReplyMsg) or (AMessage.Msg = FSocketStateChangeMsg) then
    ProcessMessage(AMessage);

  if FLockCount = 0 then
  begin
    C1 := 0;
    while C1 < FCallbackSets.Count do
      if FCallbackSets[C1].Removed then
        FCallbackSets.Delete(C1)
      else
        Inc(C1);
  end;
end;


end.
