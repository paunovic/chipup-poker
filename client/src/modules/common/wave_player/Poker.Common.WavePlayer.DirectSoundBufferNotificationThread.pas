unit Poker.Common.WavePlayer.DirectSoundBufferNotificationThread;

interface

uses
  Winapi.Windows, System.Classes, System.Generics.Collections, Poker.Common.WavePlayer.DirectSoundBuffer;

type
  TDirectSoundBufferDoneEvent = procedure(const ADirectSoundBuffer: TDirectSoundBuffer) of object;

  TDirectSoundBufferNotificationThread = class(TThread)
  private
    FOnBufferDone: TDirectSoundBufferDoneEvent;
    FWaitHandles: TList<NativeUInt>;
    FWaitResult: Integer;
    FBuffers: TObjectList<TDirectSoundBuffer>;

    procedure syncBufferDone;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const ADirectSoundBuffer: TDirectSoundBuffer; const AHandle: NativeUInt);
    procedure Signal;

    property OnBufferDone: TDirectSoundBufferDoneEvent read FOnBufferDone write FOnBufferDone;
  end;

implementation

{ TDirectSoundBufferNotificationThread }

constructor TDirectSoundBufferNotificationThread.Create;
begin
  inherited Create(TRUE);
  FWaitHandles := TList<NativeUInt>.Create;
  FBuffers := TObjectList<TDirectSoundBuffer>.Create(FALSE);
  FWaitHandles.Add(CreateEvent(nil, FALSE, FALSE, nil));
  FBuffers.Add(nil); // add one dummy element to align indexes with WaitHandles list
end;

destructor TDirectSoundBufferNotificationThread.Destroy;
begin
  CloseHandle(FWaitHandles[0]);
  FBuffers.Free;
  FWaitHandles.Free;
  inherited;
end;

procedure TDirectSoundBufferNotificationThread.Add(const ADirectSoundBuffer: TDirectSoundBuffer; const AHandle: NativeUInt);
begin
  FWaitHandles.Add(AHandle);
  FBuffers.Add(ADirectSoundBuffer);
  Signal;
end;

procedure TDirectSoundBufferNotificationThread.Signal;
begin
  SetEvent(FWaitHandles[0]);
end;

procedure TDirectSoundBufferNotificationThread.syncBufferDone;
begin
  FOnBufferDone(FBuffers[FWaitResult]);
end;

procedure TDirectSoundBufferNotificationThread.Execute;
begin
  while not Terminated do
  begin
    FWaitResult := WaitForMultipleObjects(FWaitHandles.Count, @FWaitHandles.ToArray[0], FALSE, INFINITE);
    if FWaitResult in [WAIT_OBJECT_0..WAIT_OBJECT_0 + FWaitHandles.Count] then // no -1 here, because WAIT_OBJECT_0 is internal handle used by this thread
      if FWaitResult > WAIT_OBJECT_0 then
      begin
        if Assigned(FOnBufferDone) then
          Synchronize(syncBufferDone);
        FWaitHandles.Delete(FWaitResult);
        FBuffers.Delete(FWaitResult);
      end;
  end;
end;

end.
