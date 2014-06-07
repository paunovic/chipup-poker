unit Poker.Server.MessageContainer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Generics.Collections, OverbyteIcsWSocket, System.SyncObjs,
  Poker.Server.MessageCallbacks;

type
  TMessageContainer = class
  private
    FReceiverWnd: HWND;
    FCallbackSets: TObjectList<TCallbackSet>;
    FLock: TCriticalSection;

    procedure ReceiverWndProc(var AMessage: TMessage);
    procedure ProcessMessage(const AMessage: TMessage);
    function GetCallbackSetsCount: Integer;

  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    function AddCallbacks(const ACallbacks: array of TObject; const APriority: Boolean = FALSE): Integer;
    procedure RemoveCallbacks(var AId: Integer);

    property CallbackSetsCount: Integer read GetCallbackSetsCount;
    property ReceiverWnd: HWND read FReceiverWnd;
  end;

var
  MessageContainer: TMessageContainer;


implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, Poker.Protobufs.Enum.ServerCodes, {$ENDIF}
  System.SysUtils, System.Classes, Poker.WindowMessages;


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

function TMessageContainer.AddCallbacks(const ACallbacks: array of TObject; const APriority: Boolean = FALSE): Integer;
var
  callback_set: TCallbackSet;
  id: Integer;
  found: Boolean;
begin
  FLock.Enter;
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
    if not APriority then
      FCallbackSets.Add(callback_set)
    else
      FCallbackSets.Insert(0, callback_set);
    result := id;
  finally
    FLock.Leave;
  end;
end;

procedure TMessageContainer.RemoveCallbacks(var AId: Integer);
var
  callback: TCallbackSet;
begin
  FLock.Enter;
  try
    for callback in FCallbackSets do
      if callback.Id = AId then
      begin
        callback.Removed := TRUE;
        Break;
      end;
    AId := -1;
  finally
    FLock.Leave;
  end;
end;

procedure TMessageContainer.ProcessMessage(const AMessage: TMessage);
var
  callback_set: TCallbackSet;
  obj, data_obj: TObject;
  callback_servermsg: TServerMessageCallback;
  C1: Integer;
begin
  data_obj := nil;
  if AMessage.Msg = WM_SOCKET_SERVER_REPLY then
    data_obj := pointer(AMessage.WParam);

  FLock.Enter;
  try
    for callback_set in FCallbackSets do
      if (Assigned(callback_set)) and
         (not callback_set.Removed) then
        for obj in callback_set do
          if (AMessage.Msg = WM_SOCKET_SERVER_REPLY) and
             (obj is TServerMessageCallback) then
          begin
            callback_servermsg := obj as TServerMessageCallback;
            if Integer(callback_servermsg.Code) = AMessage.LParam then
              callback_servermsg.Callback(AMessage.LParam, data_obj)
          end
          else
            if (AMessage.Msg = WM_SOCKET_STATE_CHANGE) and
               (obj is TSocketStateChangeCallback) then
              (obj as TSocketStateChangeCallback).Callback(TSocketState(AMessage.WParam), TSocketState(AMessage.LParam));

    C1 := FCallbackSets.Count - 1;
    while (C1 >= 0) and
          (C1 < FCallbackSets.Count) do
      if FCallbackSets[C1].Removed then
        FCallbackSets.Delete(C1)
      else
        Dec(C1);
  finally
    FLock.Leave;
  end;

  if Assigned(data_obj) then
    data_obj.Free;
end;

procedure TMessageContainer.ReceiverWndProc(var AMessage: TMessage);
begin
  if (AMessage.Msg = WM_SOCKET_SERVER_REPLY) or
     (AMessage.Msg = WM_SOCKET_STATE_CHANGE) then
    ProcessMessage(AMessage);
end;


end.
