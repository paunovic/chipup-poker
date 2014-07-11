unit Poker.WavePlayer.Player;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.DirectSound, System.SyncObjs, System.Generics.Collections, Poker.WavePlayer.DirectSoundBuffer;

type
  TWavePlayer = class
  private
    FInternalHWND: HWND;
    FLock: TCriticalSection;
    FDirectSound: IDirectSound;
    FBuffers: TObjectList<TDirectSoundBuffer>;

    procedure WndProc(var AMessage: TMessage);

    function InitDirectSound(const AHandle: HWND): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    function Load(const AName: String; out ADirectSoundBuffer: TDirectSoundBuffer): Boolean;
    procedure CleanupFinishedBuffers;

    property Buffers: TObjectList<TDirectSoundBuffer> read FBuffers;
  end;

implementation

uses
  System.SysUtils, System.Classes;

constructor TWavePlayer.Create;
begin
  FLock := TCriticalSection.Create;
  FInternalHWND := AllocateHWnd(WndProc);
  InitDirectSound(FInternalHWND);
  FBuffers := TObjectList<TDirectSoundBuffer>.Create;
end;

destructor TWavePlayer.Destroy;
begin
  FBuffers.Free;
  FDirectSound := nil;
  DeallocateHWnd(FInternalHWND);
  FreeAndNil(FLock);
  inherited;
end;

procedure TWavePlayer.WndProc(var AMessage: TMessage);
begin
  inherited;
end;

function TWavePlayer.InitDirectSound(const AHandle: HWND): Boolean;
var
  dsbd: TDSBufferDesc;
  dsbprimary: IDirectSoundBuffer;
begin
  if Failed(DirectSoundCreate(nil, FDirectSound, nil)) then
    Exit(FALSE);

  if Failed(FDirectSound.SetCooperativeLevel(AHandle, DSSCL_NORMAL)) then
  begin
    FDirectSound := nil;
    Exit(FALSE);
  end;

  FillChar(dsbd, SizeOf(dsbd), 0);
  dsbd.dwSize := SizeOf(dsbd);
  dsbd.dwFlags := DSBCAPS_PRIMARYBUFFER;
  if Failed(FDirectSound.CreateSoundBuffer(dsbd, dsbprimary, nil)) then
  begin
    FDirectSound := nil;
    Exit(FALSE);
  end;

  dsbprimary := nil;
  Exit(TRUE);
end;

function TWavePlayer.Load(const AName: String; out ADirectSoundBuffer: TDirectSoundBuffer): Boolean;
var
  buffer: TDirectSoundBuffer;
begin
  buffer := TDirectSoundBuffer.Create;
  if (buffer.CreateBuffer(FDirectSound, AName)) and
     (buffer.FillBuffer) then
  begin
    FLock.Enter;
    try
      FBuffers.Add(buffer);
    finally
      FLock.Leave;
    end;
    ADirectSoundBuffer := buffer;
    Exit(TRUE)
  end
  else
  begin
    buffer.Free;
    Exit(FALSE);
  end;
end;

procedure TWavePlayer.CleanupFinishedBuffers;
var
  C1: Integer;
begin
  FLock.Enter;
  try
    for C1 := FBuffers.Count - 1 downto 0 do
      if not FBuffers[C1].IsPlaying then
        FBuffers.Delete(C1);
  finally
    FLock.Leave;
  end;
end;

end.
