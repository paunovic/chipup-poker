unit Poker.WavePlayer.Reader;

interface

uses
  Winapi.Windows, Winapi.MMSystem;

type
  TWaveSoundReader = class
  private
    FMMIO: HMMIO;
    FWFX: PWaveFormatEx;
    FWFXSize: DWORD;
    FCKIn: TMMCKinfo;
    FCKInRiff: TMMCKInfo;

    function MMIORead(const AHMMIOIn: HMMIO; var ACKInRiff: TMMCKInfo; var AWFXInfo: PWaveFormatEx; var AWFXSize: DWORD): HRESULT;
    procedure WaveFreeWFX(var AWFXInfo: PWaveFormatEx; var AWFXSize: DWORD);
    function WaveOpen(const AName: String; var AHMMIOIn: HMMIO; var ACKInRiff: TMMCKInfo; var AWFXInfo: PWaveFormatEx; var AWFXSize: DWORD): HRESULT;
    function WaveReadFile(var AHHMIOIn: HMMIO; const ARead: DWORD; const ADest: pointer; var ACKIn: TMMCKInfo; var AActualRead: DWORD): HRESULT;
    function WaveStartDataRead(var AHMMIOIn: HMMIO; var ACKIn, ACKInRiff: TMMCKINFO): HRESULT;
  public
    constructor Create;
    destructor Destroy; override;

    function Open(const AName: String): Boolean;
    function Reset: Boolean;
    function Read(const ABytes: DWORD; const ADestination: pointer; var ARead: DWORD): Boolean;
    procedure Close;

    property WFX: PWaveFormatEx read FWFX;
    property CKIn: TMMCKInfo read FCKIn;
    property CKInRiff: TMMCKInfo read FCKInRiff;
  end;

implementation

uses
  System.Classes;

{ TWaveSoundReader }

constructor TWaveSoundReader.Create;
begin
  FMMIO := 0;
  FWFX := nil;
  FWFXSize := 0;
  FillChar(FCKIn, SizeOf(FCKIn), 0);
  FillChar(FCKInRiff, SizeOf(FCKInRiff), 0);
end;

destructor TWaveSoundReader.Destroy;
begin
  Close;
  inherited;
end;

function TWaveSoundReader.MMIORead(const AHMMIOIn: HMMIO; var ACKInRiff: TMMCKInfo; var AWFXInfo: PWaveFormatEx; var AWFXSize: DWORD): HRESULT;
var
  ckIn: TMMCKInfo;
  pcm_wave_format: TPCMWaveFormat;
  extra_bytes: Word;
begin
  result := E_FAIL;
  AWFXInfo := nil;
  AWFXSize := 0;

  if (mmioDescend(AHMMIOIn, @ACKInRiff, nil, 0) <> 0) or
     (ACKInRiff.ckid <> FOURCC_RIFF) or
     (ACKInRiff.fccType <> mmioStringToFOURCC('WAVE', 0)) then
    Exit;

  ckIn.ckid := mmioStringToFOURCC('fmt ', 0);

  if (mmioDescend(AHMMIOIn, @ckIn, @ACKInRiff, MMIO_FINDCHUNK) <> 0) or
     (ckIn.cksize < SizeOf(pcm_wave_format)) or
     (Winapi.MMSystem.mmioRead(AHMMIOIn, @pcm_wave_format, SizeOf(pcm_wave_format)) <> SizeOf(pcm_wave_format)) then
    Exit;

  if pcm_wave_format.wf.wFormatTag = WAVE_FORMAT_PCM then
  begin
    AWFXSize := SizeOf(TWaveFormatEx);
    GetMem(AWFXInfo, AWFXSize);
    Move(pcm_wave_format, AWFXInfo^, SizeOf(pcm_wave_format));
    AWFXInfo^.cbSize := 0;
  end
  else
  begin
    extra_bytes := 0;
    if Winapi.MMSystem.mmioRead(AHMMIOIn, @extra_bytes, 2) <> 2 then
      Exit;
    AWFXSize := SizeOf(pcm_wave_format) + extra_bytes;
    GetMem(AWFXInfo, AWFXSize);
    Move(pcm_wave_format, AWFXInfo^, SizeOf(pcm_wave_format));
    AWFXInfo^.cbSize := extra_bytes;
    if Winapi.MMSystem.mmioRead(AHMMIOIn, Ptr(DWORD(AWFXInfo) + AWFXInfo^.cbSize), extra_bytes) <> extra_bytes then
    begin
      FreeMem(AWFXInfo, SizeOf(pcm_wave_format) + extra_bytes);
      AWFXInfo := nil;
      Exit;
    end;
  end;

  if mmioAscend(AHMMIOIn, @ckIn, 0) <> 0 then
  begin
    FreeMem(AWFXInfo, SizeOf(pcm_wave_format) + extra_bytes);
    AWFXInfo := nil;
    AWFXSize := 0;
    Exit;
  end;

  result := S_OK;
end;

procedure TWaveSoundReader.WaveFreeWFX(var AWFXInfo: PWaveFormatEx; var AWFXSize: DWORD);
begin
  if (Assigned(AWFXInfo)) and
     (AWFXSize > 0) then
    FreeMem(AWFXInfo, AWFXSize);
  AWFXInfo := nil;
  AWFXSize := 0;
end;

function TWaveSoundReader.WaveOpen(const AName: String; var AHMMIOIn: HMMIO; var ACKInRiff: TMMCKInfo; var AWFXInfo: PWaveFormatEx; var AWFXSize: DWORD): HRESULT;
var
  rstream: TResourceStream;
  mmio_info: TMMIOInfo;
begin
  AHMMIOIn := mmioOpen(PChar(AName), nil, MMIO_ALLOCBUF or MMIO_READ);
  if AHMMIOIn = 0 then // opening it as file failed, so try it as a resource
  begin
    rstream := TResourceStream.Create(HInstance, AName, 'WAVE');
    try
      FillChar(mmio_info, SizeOf(TMMIOInfo), 0);
      mmio_info.fccIOProc := FOURCC_MEM;
      mmio_info.cchBuffer := rstream.Size;
      mmio_info.pchBuffer := rstream.Memory;
      AHMMIOIn := mmioOpen(nil, @mmio_info, MMIO_ALLOCBUF or MMIO_READ);
      if AHMMIOIn = 0 then
        Exit(E_FAIL);
    finally
      rstream.Free;
    end;
  end;

  result := MMIORead(AHMMIOIn, ACKInRiff, AWFXInfo, AWFXSize);
  if Failed(result) then
  begin
    WaveFreeWFX(AWFXInfo, AWFXSize);
    mmioClose(AHMMIOIn, 0);
  end
end;

function TWaveSoundReader.WaveReadFile(var AHHMIOIn: HMMIO; const ARead: DWORD; const ADest: pointer; var ACKIn: TMMCKInfo; var AActualRead: DWORD): HRESULT;
var
  mmio_info: TMMIOInfo;
  data_in: DWORD;
  C1: DWORD;
begin
  AActualRead := 0;
  if mmioGetInfo(AHHMIOIn, @mmio_info, 0) <> 0 then
    Exit(E_FAIL);

  data_in := ARead;
  if data_in > ACKIn.cksize then
    data_in := ACKIn.cksize;
  ACKIn.cksize := ACKIn.cksize - data_in;

  for C1 := 0 to data_in - 1 do
  begin
    if mmio_info.pchNext = mmio_info.pchEndRead then
    begin
      if (mmioAdvance(AHHMIOIn, @mmio_info, MMIO_READ) <> 0) or
         (mmio_info.pchNext = mmio_info.pchEndRead) then
        Exit(E_FAIL);
    end;
    Byte(pointer(DWORD(ADest) + C1)^) := Byte(mmio_info.pchNext^);
    Inc(DWORD(mmio_info.pchNext));
  end;

  if mmioSetInfo(AHHMIOIn, @mmio_info, 0) <> 0 then
    Exit(E_FAIL);
  AActualRead := data_in;
  result := S_OK;
end;

function TWaveSoundReader.WaveStartDataRead(var AHMMIOIn: HMMIO; var ACKIn, ACKInRiff: TMMCKINFO): HRESULT;
begin
  result := E_FAIL;
  if mmioSeek(AHMMIOIn, ACKInRiff.dwDataOffset + SizeOf(FOURCC), SEEK_SET) = -1 then
    Exit;
  ACKin.ckid := mmioStringToFOURCC('data', 0);
  if mmioDescend(AHMMIOIn, @ACKIn, @ACKInRiff, MMIO_FINDCHUNK) <> 0 then
    Exit;
  result := S_OK;
end;

function TWaveSoundReader.Open(const AName: String): Boolean;
begin
  result := (Succeeded(WaveOpen(AName, FMMIO, FCKInRiff, FWFX, FWFXSize))) and
            (Reset);
end;

procedure TWaveSoundReader.Close;
begin
  if FMMIO <> 0 then
    MMIOClose(FMMIO, 0);
  FillChar(FCKIn, SizeOf(FCKIn), 0);
  FillChar(FCKInRiff, SizeOf(FCKInRiff), 0);
  WaveFreeWFX(FWFX, FWFXSize);
end;

function TWaveSoundReader.Read(const ABytes: DWORD; const ADestination: pointer; var ARead: DWORD): Boolean;
begin
  result := Succeeded(WaveReadFile(FMMIO, ABytes, ADestination, FCKIn, ARead));
end;

function TWaveSoundReader.Reset: Boolean;
begin
  result := Succeeded(WaveStartDataRead(FMMIO, FCKIn, FCKInRiff));
end;


end.
