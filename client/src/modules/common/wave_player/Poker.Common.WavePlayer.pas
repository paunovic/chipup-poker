unit Poker.Common.WavePlayer;

interface

uses
  Winapi.Windows, Winapi.DirectSound, System.Generics.Collections, Poker.Common.WavePlayer.DirectSoundBuffer,
  Poker.Common.WavePlayer.DirectSoundBufferNotificationThread, Poker.Common.SafeMutex;

type
  TWavePlayer = class
  private
    FLock: TSafeMutex;
    FDirectSound: IDirectSound;
    FBuffers: TObjectList<TDirectSoundBuffer>;
    FBufferNotificationThread: TDirectSoundBufferNotificationThread;

    procedure BufferDoneEvent(const ABuffer: TDirectSoundBuffer);
    function InitDirectSound(const AHandle: HWND): Boolean;
  public
    constructor Create(const AHandle: HWND);
    destructor Destroy; override;

    function Load(const AName: String; out ADirectSoundBuffer: TDirectSoundBuffer): Boolean;

    property Buffers: TObjectList<TDirectSoundBuffer> read FBuffers;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  System.SysUtils;

constructor TWavePlayer.Create(const AHandle: HWND);
begin
  FLock := TSafeMutex.Create;
  InitDirectSound(AHandle);
  FBuffers := TObjectList<TDirectSoundBuffer>.Create;
  FBufferNotificationThread := TDirectSoundBufferNotificationThread.Create;
  FBufferNotificationThread.OnBufferDone := BufferDoneEvent;
  FBufferNotificationThread.Start;
end;

destructor TWavePlayer.Destroy;
begin
  FBufferNotificationThread.Terminate;
  FBufferNotificationThread.Signal;
  FBufferNotificationThread.WaitFor;
  FBufferNotificationThread.Free;
  FLock.Acquire;
  try
    FBuffers.Free;
  finally
    FLock.Release;
  end;
  FDirectSound := nil;
  FreeAndNil(FLock);
  inherited;
end;

function TWavePlayer.InitDirectSound(const AHandle: HWND): Boolean;
var
  ds_buffer_desc: TDSBufferDesc;
  ds_buffer: IDirectSoundBuffer;
begin
  if Failed(DirectSoundCreate(nil, FDirectSound, nil)) then
    Exit(FALSE);

  if Failed(FDirectSound.SetCooperativeLevel(AHandle, DSSCL_NORMAL)) then
  begin
    FDirectSound := nil;
    Exit(FALSE);
  end;

  FillChar(ds_buffer_desc, SizeOf(ds_buffer_desc), 0);
  ds_buffer_desc.dwSize := SizeOf(ds_buffer_desc);
  ds_buffer_desc.dwFlags := DSBCAPS_PRIMARYBUFFER;
  if Succeeded(FDirectSound.CreateSoundBuffer(ds_buffer_desc, ds_buffer, nil)) then
  begin
    ds_buffer := nil;
    Exit(TRUE);
  end
  else
  begin
    FDirectSound := nil;
    Exit(FALSE);
  end;
end;

function TWavePlayer.Load(const AName: String; out ADirectSoundBuffer: TDirectSoundBuffer): Boolean;
var
  ds_buffer: TDirectSoundBuffer;
begin
  if not Assigned(FDirectSound) then
    Exit(FALSE);

  ds_buffer := TDirectSoundBuffer.Create;
  if (ds_buffer.CreateBuffer(FDirectSound, AName)) and
     (ds_buffer.FillBuffer) then
  begin
    FBufferNotificationThread.Add(ds_buffer, ds_buffer.PositionNotify.hEventNotify);
    FLock.Acquire;
    try
      FBuffers.Add(ds_buffer);
    finally
      FLock.Release;
    end;
    ADirectSoundBuffer := ds_buffer;
    {$IFDEF DEBUG} RefreshDebugForm([dfiSoundBuffers]); {$ENDIF}
    Exit(TRUE);
  end
  else
  begin
    ds_buffer.Free;
    Exit(FALSE);
  end;
end;

procedure TWavePlayer.BufferDoneEvent(const ABuffer: TDirectSoundBuffer);
begin
  FLock.Acquire;
  try
    FBuffers.Remove(ABuffer);
  finally
    FLock.Release;
  end;

  {$IFDEF DEBUG} RefreshDebugForm([dfiSoundBuffers]); {$ENDIF}
end;

end.
