unit Poker.Server.MessageContainer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Generics.Collections, OverbyteIcsWSocket,
  Poker.Common.SafeMutex, Poker.Server.MessageCallbacks;

type
  TMessageContainer = class
  private
    FCallbackSets: TObjectList<TCallbackSet>;
    FInternalHWND: HWND;
    FLock: TSafeMutex;

    function GetCallbackSetsCount: Integer;
    procedure WndProc(var AMessage: TMessage);
    procedure ProcessSocketReply(const AMethodId: Integer; const AObject: TObject);
    procedure ProcessSocketStateChange(const AOldState, ANewState: TSocketState);

  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    function AddCallbacks(const ACallbacks: array of TObject; const APriority: Boolean = FALSE): Integer;
    procedure RemoveCallbacks(var AId: Integer);

    property CallbackSetsCount: Integer read GetCallbackSetsCount;
    property HWND: HWND read FInternalHWND;
  end;

var
  MessageContainer: TMessageContainer;


implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  System.SysUtils, System.Classes, Poker.WindowMessages, Poker.Protobufs.Enum.ServerCodes;


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
  FLock := TSafeMutex.Create;
  FInternalHWND := AllocateHWND(WndProc);
  FCallbackSets := TObjectList<TCallbackSet>.Create;
end;

destructor TMessageContainer.Destroy;
begin
  FLock.Acquire;
  try
    FreeAndNil(FCallbackSets);
    DeallocateHWnd(FInternalHWND);
  finally
    FLock.Release;
  end;
  FreeAndNil(FLock);

  inherited;
end;

function TMessageContainer.GetCallbackSetsCount: Integer;
begin
  FLock.Acquire;
  try
    result := FCallbackSets.Count;
  finally
    FLock.Release;
  end;
end;

function TMessageContainer.AddCallbacks(const ACallbacks: array of TObject; const APriority: Boolean = FALSE): Integer;
var
  callback_set: TCallbackSet;
  id: Integer;
  found: Boolean;
begin
  id := 0;
  repeat
    found := FALSE;
    FLock.Acquire;
    try
      for callback_set in FCallbackSets do
        if callback_set.Id = id then
        begin
          Inc(id);
          found := TRUE;
          Break;
        end;
    finally
      FLock.Release;
    end;
  until not found;

  callback_set := TCallbackSet.Create(id, ACallbacks);
  FLock.Acquire;
  try
    if not APriority then
      FCallbackSets.Add(callback_set)
    else
      FCallbackSets.Insert(0, callback_set);
  finally
    FLock.Release;
  end;
  result := id;

  {$IFDEF DEBUG} RefreshDebugForm([dfiCallbacks]); {$ENDIF}
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
        FCallbackSets.Remove(callback);
        Break;
      end;
  finally
    FLock.Release;
  end;
  AId := -1;
  {$IFDEF DEBUG} RefreshDebugForm([dfiCallbacks]); {$ENDIF}
end;

procedure TMessageContainer.ProcessSocketReply(const AMethodId: Integer; const AObject: TObject);
var
  callback_set: TCallbackSet;
  callback_servermsg: TServerMessageCallback;
  obj: TObject;
begin
  FLock.Acquire;
  try
    for callback_set in FCallbackSets do
      for obj in callback_set do
        if obj is TServerMessageCallback then
        begin
          callback_servermsg := obj as TServerMessageCallback;
          if TServerCodes(AMethodId) in callback_servermsg.Codes then
            callback_servermsg.Callback(AMethodId, AObject)
        end;
  finally
    FLock.Release;
  end;

  if Assigned(AObject) then
    AObject.Free;
end;

procedure TMessageContainer.ProcessSocketStateChange(const AOldState, ANewState: TSocketState);
var
  callback_set: TCallbackSet;
  callback_socketstatechange: TSocketStateChangeCallback;
  obj: TObject;
begin
  {$IFDEF DEBUG} RefreshDebugForm([dfiServer, dfiSocket]); {$ENDIF}

  FLock.Acquire;
  try
    for callback_set in FCallbackSets do
      for obj in callback_set do
        if obj is TSocketStateChangeCallback then
        begin
          callback_socketstatechange := obj as TSocketStateChangeCallback;
          callback_socketstatechange.Callback(AOldState, ANewState);
        end;
  finally
    FLock.Release;
  end;
end;

procedure TMessageContainer.WndProc(var AMessage: TMessage);
begin
  case AMessage.Msg of
    WM_MESSAGE_CALLBACK_PROTO: ProcessSocketReply(AMessage.LParam, pointer(AMessage.WParam));
    WM_MESSAGE_CALLBACK_SOCKET_STATE: ProcessSocketStateChange(TSocketState(AMessage.WParam), TSocketState(AMessage.LParam));
  end;

  inherited;
end;

end.
