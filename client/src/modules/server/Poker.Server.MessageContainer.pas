unit Poker.Server.MessageContainer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Generics.Collections, OverbyteIcsWSocket, System.SyncObjs,
  Poker.Server.MessageCallbacks;

type
  TMessageContainer = class
  private
    FCallbackSets: TObjectList<TCallbackSet>;
    FLock: TCriticalSection;

    function GetCallbackSetsCount: Integer;

  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    function AddCallbacks(const ACallbacks: array of TObject; const APriority: Boolean = FALSE): Integer;
    procedure RemoveCallbacks(var AId: Integer);

    procedure ProcessSocketReply(const AMethodId: Integer; const AObject: TObject);
    procedure ProcessSocketStateChange(const AOldState, ANewState: TSocketState);

    property CallbackSetsCount: Integer read GetCallbackSetsCount;
  end;

var
  MessageContainer: TMessageContainer;


implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
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
  FCallbackSets := TObjectList<TCallbackSet>.Create;
end;

destructor TMessageContainer.Destroy;
begin
  FLock.Enter;
  try
    FreeAndNil(FCallbackSets);
  finally
    FLock.Leave;
  end;
  FreeAndNil(FLock);

  inherited;
end;

function TMessageContainer.GetCallbackSetsCount: Integer;
begin
  FLock.Enter;
  try
    result := FCallbackSets.Count;
  finally
    FLock.Leave;
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
    FLock.Enter;
    try
      for callback_set in FCallbackSets do
        if callback_set.Id = id then
        begin
          Inc(id);
          found := TRUE;
          Break;
        end;
    finally
      FLock.Leave;
    end;
  until not found;

  callback_set := TCallbackSet.Create(id, ACallbacks);
  FLock.Enter;
  try
    if not APriority then
      FCallbackSets.Add(callback_set)
    else
      FCallbackSets.Insert(0, callback_set);
  finally
    FLock.Leave;
  end;
  result := id;

  {$IFDEF DEBUG} RefreshDebugForm([dfiCallbacks]); {$ENDIF}
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
        FCallbackSets.Remove(callback);
        Break;
      end;
  finally
    FLock.Leave;
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
  FLock.Enter;
  try
    for callback_set in FCallbackSets do
      for obj in callback_set do
        if obj is TServerMessageCallback then
        begin
          callback_servermsg := obj as TServerMessageCallback;
          if Integer(callback_servermsg.Code) = AMethodId then
            callback_servermsg.Callback(AMethodId, AObject)
        end;
  finally
    FLock.Leave;
  end;
end;

procedure TMessageContainer.ProcessSocketStateChange(const AOldState, ANewState: TSocketState);
var
  callback_set: TCallbackSet;
  callback_socketstatechange: TSocketStateChangeCallback;
  obj: TObject;
begin
  FLock.Enter;
  try
    for callback_set in FCallbackSets do
      for obj in callback_set do
        if obj is TSocketStateChangeCallback then
        begin
          callback_socketstatechange := obj as TSocketStateChangeCallback;
          callback_socketstatechange.Callback(AOldState, ANewState);
        end;
  finally
    FLock.Leave;
  end;
end;

end.
