unit Poker.WavePlayer.DirectSoundBuffer;

interface

uses
  System.Generics.Collections, Winapi.DirectSound, Poker.WavePlayer.Reader;

type
  TDirectSoundBuffer = class
  private
    FBuffer: IDirectSoundBuffer;
    FSize: Integer;
    FReader: TWaveSoundReader;
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
  end;

implementation

uses
  Winapi.Windows, System.SysUtils;

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
begin
  FReader := TWaveSoundReader.Create;
  if not FReader.Open(AName) then
  begin
    FreeAndNil(FReader);
    Exit(FALSE);
  end;

  FillChar(dsbd, SizeOf(dsbd), 0);
  dsbd.dwSize := SizeOf(dsbd);
  dsbd.dwFlags := DSBCAPS_STATIC;
  dsbd.dwBufferBytes := FReader.CKIn.cksize;
  dsbd.lpwfxFormat := FReader.WFX;

  if Succeeded(ADirectSound.CreateSoundBuffer(dsbd, FBuffer, nil)) then
  begin
    FSize := dsbd.dwBufferBytes;
    Exit(TRUE);
  end
  else
  begin
    FreeAndNil(FReader);
    Exit(FALSE);
  end;
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
