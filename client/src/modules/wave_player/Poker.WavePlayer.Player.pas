unit Poker.WavePlayer.Player;

interface

uses
  Winapi.Windows, Winapi.MMSystem, Winapi.DirectSound, Poker.WavePlayer.Reader;

type
  TDSBufferStatus = (dsbsNone, dsbsPlay);

  TWavePlayer = class
  private
    FDirectSound: IDirectSound;
    FDirectSoundBuffer: IDirectSoundBuffer;
    FBufferSize: DWORD;
    FWaveSoundReader: TWaveSoundReader;
    FFreeOnDone: Boolean;

    function InitDirectSound(const AHandle: HWND): Boolean;
    procedure FreeDirectSound;
    function CreateStaticBuffer(const AName: String): Boolean;
    function FillBuffer: Boolean;
    function RestoreBuffers: Boolean;
  public
    constructor Create(const AHandle: HWND);
    destructor Destroy; override;

    function Load(const AName: String): Boolean;

    function IsBufferPlaying: TDSBufferStatus;
    function PlayBuffer(const ALooped: Boolean): Boolean;
    procedure StopBuffer(const AResetPosition: Boolean);

    property FreeOnDone: Boolean read FFreeOnDone write FFreeOnDone;
  end;

implementation

uses
  System.SysUtils;

constructor TWavePlayer.Create(const AHandle: HWND);
begin
  InitDirectSound(AHandle);
end;

destructor TWavePlayer.Destroy;
begin
  StopBuffer(TRUE);
  FreeDirectSound;
  inherited;
end;

function TWavePlayer.InitDirectSound(const AHandle: HWND): Boolean;
var
  dsbd: TDSBufferDesc;
  dsbprimary: IDirectSoundBuffer;
  wfx: TWaveFormatEx;
begin
  if Failed(DirectSoundCreate(nil, FDirectSound, nil)) then
    Exit(FALSE);

  if Failed(FDirectSound.SetCooperativeLevel(AHandle, DSSCL_PRIORITY)) then
    Exit(FALSE);

  FillChar(dsbd, SizeOf(dsbd), 0);
  dsbd.dwSize  := SizeOf(dsbd);
  dsbd.dwFlags := DSBCAPS_PRIMARYBUFFER;
  if Failed(FDirectSound.CreateSoundBuffer(dsbd, dsbprimary, nil)) then
    Exit(FALSE);

  FillChar(wfx, SizeOf(wfx), 0);
  wfx.wFormatTag := WAVE_FORMAT_PCM;
  wfx.nChannels := 1;
  wfx.nSamplesPerSec := 44050;
  wfx.wBitsPerSample := 16;
  wfx.nBlockAlign := (wfx.wBitsPerSample shr 3) * wfx.nChannels;
  wfx.nAvgBytesPerSec := wfx.nSamplesPerSec * wfx.nBlockAlign;

  result := Succeeded(dsbprimary.SetFormat(@wfx));
  dsbprimary := nil;
end;

procedure TWavePlayer.FreeDirectSound;
begin
  if Assigned(FWaveSoundReader) then
    FreeAndNil(FWaveSoundReader);
  FDirectSoundBuffer := nil;
  FDirectSound := nil;
end;

function TWavePlayer.CreateStaticBuffer(const AName: String): Boolean;
var
  dsbd: TDSBufferDesc;
begin
  if Assigned(FWaveSoundReader) then
    FreeAndNil(FWaveSoundReader);

  FDirectSoundBuffer := nil;

  FWaveSoundReader := TWaveSoundReader.Create;
  if not FWaveSoundReader.Open(AName) then
  begin
    FreeAndNil(FWaveSoundReader);
    Exit(FALSE);
  end;

  FillChar(dsbd, SizeOf(dsbd), 0);
  dsbd.dwSize := SizeOf(dsbd);
  dsbd.dwFlags := DSBCAPS_STATIC;
  dsbd.dwBufferBytes := FWaveSoundReader.CKIn.cksize;
  dsbd.lpwfxFormat := FWaveSoundReader.WFX;

  result := Succeeded(FDirectSound.CreateSoundBuffer(dsbd, FDirectSoundBuffer, nil));
  if result then
    FBufferSize := dsbd.dwBufferBytes;
end;

function TWavePlayer.FillBuffer: Boolean;
var
  wav_size: DWORD;
  wav_file_size: DWORD;
  wav_data: pointer;
  audiop: pointer;
  audiosize: DWORD;
begin
  wav_file_size := FWaveSoundReader.ckIn.cksize;
  GetMem(wav_data, wav_file_size);
  try
    if (not FWaveSoundReader.Read(wav_file_size, wav_data, wav_size)) or
       (not FWaveSoundReader.Reset) then
      Exit(FALSE);

    if Failed(FDirectSoundBuffer.Lock(0, 0, @audiop, @audiosize, nil, nil, DSBLOCK_ENTIREBUFFER)) then
      Exit(FALSE);
    try
      Move(wav_data^, audiop^, audiosize);
    finally
      FDirectSoundBuffer.Unlock(audiop, audiosize, nil, 0);
    end;
  finally
    FreeMem(wav_data, wav_file_size);
  end;
  Exit(TRUE);
end;

function TWavePlayer.RestoreBuffers: Boolean;
var
  hr: HRESULT;
  status: DWORD;
begin
  if not Assigned(FDirectSoundBuffer) then
    Exit(FALSE);

  hr := FDirectSoundBuffer.GetStatus(status);
  if Failed(hr) then
    Exit(FALSE);

  if status and DSBSTATUS_BUFFERLOST = DSBSTATUS_BUFFERLOST then
  begin
    repeat
      hr := FDirectSoundBuffer.Restore;
      if hr = DSERR_BUFFERLOST then
        Sleep(10);
    until Succeeded(hr);

    if not FillBuffer then
      Exit(FALSE);
  end;

  Exit(TRUE);
end;

function TWavePlayer.Load(const AName: String): Boolean;
begin
  result := (CreateStaticBuffer(AName)) and
            (FillBuffer);
end;

function TWavePlayer.IsBufferPlaying: TDSBufferStatus;
var
  status: DWORD;
begin
  result := dsbsNone;
  if not Assigned(FDirectSoundBuffer) then
    Exit;

  if Succeeded(FDirectSoundBuffer.GetStatus(status)) then
    if status and DSBSTATUS_PLAYING = DSBSTATUS_PLAYING then
      result := dsbsPlay
    else
      result := dsbsNone;
end;

function TWavePlayer.PlayBuffer(const ALooped: Boolean): Boolean;
var
  flags: DWORD;
begin
  if (not Assigned(FDirectSoundBuffer)) or
     (not RestoreBuffers) then
    Exit(FALSE);

  if ALooped then
    flags := DSBPLAY_LOOPING
  else
    flags := 0;

  result := Succeeded(FDirectSoundBuffer.Play(0, 0, flags));
end;

procedure TWavePlayer.StopBuffer(const AResetPosition: Boolean);
begin
  if not Assigned(FDirectSoundBuffer) then
    Exit;

  FDirectSoundBuffer.Stop;
  if AResetPosition then
    FDirectSoundBuffer.SetCurrentPosition(0)
end;

end.
