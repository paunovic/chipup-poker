unit Poker.Common.WavePlayer.DirectSoundBuffer;

interface

uses
  System.Generics.Collections, Winapi.DirectSound, Poker.Common.WavePlayer.Reader;

type
  TDirectSoundBuffer = class
  private
    FBuffer: IDirectSoundBuffer;
    FSize: Integer;
    FReader: TWaveSoundReader;
    FPositionNotify: TDSBPositionNotify;
  public
    destructor Destroy; override;

    function CreateBuffer(const ADirectSound: IDirectSound; const AName: String): Boolean;
    function FillBuffer: Boolean;
    function RestoreBuffer: Boolean;
    function IsPlaying: Boolean;
    function PlayBuffer(const ALooped: Boolean = FALSE): Boolean;
    procedure StopBuffer(const AResetPosition: Boolean);

    property Buffer: IDirectSoundBuffer read FBuffer;
    property Size: Integer read FSize;
    property PositionNotify: TDSBPositionNotify read FPositionNotify;
  end;

implementation

uses
  Winapi.Windows, System.SysUtils, Poker.Common.WavePlayer.DirectSoundBufferNotificationThread;

{ TDirectSoundBuffer }

destructor TDirectSoundBuffer.Destroy;
begin
  FBuffer := nil;
  if Assigned(FReader) then
    FreeAndNil(FReader);

  inherited;
end;

function TDirectSoundBuffer.CreateBuffer(const ADirectSound: IDirectSound; const AName: String): Boolean;
var
  dsbd: TDSBufferDesc;
  dsnotify: IDirectSoundNotify;
begin
  FReader := TWaveSoundReader.Create;
  if not FReader.Open(AName) then
  begin
    FreeAndNil(FReader);
    Exit(FALSE);
  end;

  FillChar(dsbd, SizeOf(dsbd), 0);
  dsbd.dwSize := SizeOf(dsbd);
  dsbd.dwFlags := DSBCAPS_STATIC or DSBCAPS_CTRLPOSITIONNOTIFY;
  dsbd.dwBufferBytes := FReader.CKIn.cksize;
  dsbd.lpwfxFormat := FReader.WFX;

  if Failed(ADirectSound.CreateSoundBuffer(dsbd, FBuffer, nil)) then
  begin
    FreeAndNil(FReader);
    Exit(FALSE);
  end;

  if Failed(FBuffer.QueryInterface(IID_IDirectSoundNotify8, dsnotify)) then
  begin
    FreeAndNil(FReader);
    FBuffer := nil;
    Exit(FALSE);
  end;

  FPositionNotify.dwOffset := DSBPN_OFFSETSTOP;
  FPositionNotify.hEventNotify := CreateEvent(nil, FALSE, FALSE, nil);
  if Failed(dsnotify.SetNotificationPositions(1, @FPositionNotify)) then
  begin
    CloseHandle(FPositionNotify.hEventNotify);
    FreeAndNil(FReader);
    dsnotify := nil;
    FBuffer := nil;
    Exit(FALSE);
  end;

  dsnotify := nil;
  FSize := dsbd.dwBufferBytes;
  Exit(TRUE);
end;

function TDirectSoundBuffer.FillBuffer: Boolean;
var
  wav_size: DWORD;
  wav_file_size: DWORD;
  wav_data: pointer;
  audiop: pointer;
  audiosize: DWORD;
begin
  wav_file_size := FReader.ckIn.cksize;
  GetMem(wav_data, wav_file_size);
  try
    if (not FReader.Read(wav_file_size, wav_data, wav_size)) or
       (not FReader.Reset) then
      Exit(FALSE);

    if Failed(FBuffer.Lock(0, 0, @audiop, @audiosize, nil, nil, DSBLOCK_ENTIREBUFFER)) then
      Exit(FALSE);
    try
      Move(wav_data^, audiop^, audiosize);
    finally
      FBuffer.Unlock(audiop, audiosize, nil, 0);
    end;
  finally
    FreeMem(wav_data, wav_file_size);
  end;
  Exit(TRUE);
end;

function TDirectSoundBuffer.RestoreBuffer: Boolean;
var
  hr: HRESULT;
  status: DWORD;
begin
  if not Assigned(FBuffer) then
    Exit(FALSE);

  if Failed(FBuffer.GetStatus(status)) then
    Exit(FALSE);

  if status and DSBSTATUS_BUFFERLOST = DSBSTATUS_BUFFERLOST then
  begin
    repeat
      hr := FBuffer.Restore;
      if hr = DSERR_BUFFERLOST then
        Sleep(10);
    until Succeeded(hr);

    if not FillBuffer then
      Exit(FALSE);
  end;

  Exit(TRUE);
end;

function TDirectSoundBuffer.IsPlaying: Boolean;
var
  status: DWORD;
begin
  result := (Assigned(FBuffer)) and
            (Succeeded(FBuffer.GetStatus(status))) and
            (status and DSBSTATUS_PLAYING = DSBSTATUS_PLAYING);
end;

function TDirectSoundBuffer.PlayBuffer(const ALooped: Boolean = FALSE): Boolean;
var
  flags: DWORD;
begin
  if not RestoreBuffer then
    Exit(FALSE);

  if ALooped then
    flags := DSBPLAY_LOOPING
  else
    flags := 0;

  result := Succeeded(FBuffer.Play(0, 0, flags));
end;

procedure TDirectSoundBuffer.StopBuffer(const AResetPosition: Boolean);
begin
  FBuffer.Stop;
  if AResetPosition then
    FBuffer.SetCurrentPosition(0);
end;

end.
