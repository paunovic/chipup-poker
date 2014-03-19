unit PokerClient.Common.Misc;

interface

uses
  Winapi.ShellApi, Winapi.Windows, System.Classes, System.SysUtils, Vcl.Forms, System.Generics.Collections,
  PokerClient.Protobufs.Objects.Game, PokerClient.Protobufs.Objects.User, cxImage;

var
  SelfPath          : String;
  AppDataLocalPath  : String;
  AppDataRoamingPath: String;


function IsValidString(const AString, AAllowedChars: String): Boolean;
function ShellOpen(const AFileName: PChar; const AExecInfo: PShellExecuteInfo = nil; const AParams: PChar = nil; const ADirectory: PChar = nil;
                   const AShowCmd: Integer = SW_SHOWNORMAL; const AVerb: String = 'open'; const AMask: DWORD = SEE_MASK_FLAG_NO_UI; const AHWND: HWND = 0): Boolean;
procedure Split(const ADelimiter: Char; const AInput: String; const AStrings: TStrings;
                const ATrim: Boolean = FALSE; const AStrictDelimiter: Boolean = TRUE);
function RunModalForm(const AClassType: TFormClass; const AOwner: TForm; const AParams: array of pointer; const ACloseCallback: TNotifyEvent): TForm;
function RunForm(const AClassType: TFormClass; const AOwner: TForm; const AParams: array of pointer): TForm;
function CompressStream(const AStream: TMemoryStream): Boolean;
function DecompressStream(const AStream: TMemoryStream): Boolean;
function GetFileSize(const AFile: String): DWORD;
function GetThreadsCount(const APID: DWORD): Integer;
function GetWorkingSetSize: DWORD;
function EncodeURL(const ASrc: String): String;
function GetBlinds(const AString: String; out ASmallBlind, ABigBlind: Integer): Boolean;
function IsJPEGStream(const AStream: TStream): Boolean;
function CompareBytes(const A1, A2: TBytes; A1Len: Integer = -1; A2Len: Integer = -1): Boolean;
function GetSpecialFolderPath(const ACSIDL: Integer): String;
procedure LoadImageFromResource(const AImage: TcxImage; const AResourceName: String);
function IsPointInsideCircle(const AX, AY, ACircleX, ACircleY: Single; ARadius: Single): Boolean;

type
  TPB_Games = TObjectList<TPB_Game>;
  TPB_Users = TObjectList<TPB_User>;

implementation

uses
  System.ZLib, Winapi.PsApi, Winapi.TlHelp32, Winapi.ShlObj, dxGDIPlusClasses, PokerClient.Interfaces.ModalForm,
  PokerClient.Interfaces.FormParams;


function IsValidString(const AString, AAllowedChars: String): Boolean;
var
  C1     : Integer;
  str, ac: String;
begin
  str := LowerCase(AString);
  ac := LowerCase(AAllowedChars);
  for C1 := 1 to Length(str) do
    if Pos(str[C1], ac) = 0 then
      Exit(FALSE);
  Exit(TRUE);
end;

function ShellOpen(const AFileName: PChar; const AExecInfo: PShellExecuteInfo = nil; const AParams: PChar = nil; const ADirectory: PChar = nil;
                   const AShowCmd: Integer = SW_SHOWNORMAL; const AVerb: String = 'open'; const AMask: DWORD = SEE_MASK_FLAG_NO_UI; const AHWND: HWND = 0): Boolean;
var
  exec_info: TShellExecuteInfo;
begin
  FillChar(exec_info, SizeOf(TShellExecuteInfo), 0);
  with exec_info do
  begin
    cbSize := SizeOf(TShellExecuteInfo);
    fMask := AMask;
    Wnd := AHWND;
    lpVerb := PChar(AVerb);
    lpFile := AFileName;
    lpParameters := APArams;
    lpDirectory := ADirectory;
    nShow := AShowCmd;
  end;

  result := ShellExecuteEx(@exec_info);
  if Assigned(AExecInfo) then
    AExecInfo^ := exec_info;
end;

procedure Split(const ADelimiter: Char; const AInput: String; const AStrings: TStrings;
                const ATrim: Boolean = FALSE; const AStrictDelimiter: Boolean = TRUE);
var
  C1: Integer;
begin
  AStrings.Clear;
  AStrings.StrictDelimiter := AStrictDelimiter;
  AStrings.Delimiter := ADelimiter;
  AStrings.DelimitedText := AInput;

  if ATrim then
    for C1 := 0 to AStrings.Count - 1 do
      AStrings[C1] := Trim(AStrings[C1]);
end;

function RunModalForm(const AClassType: TFormClass; const AOwner: TForm; const AParams: array of pointer; const ACloseCallback: TNotifyEvent): TForm;
var
  form: TForm;
begin
  form := AClassType.Create(AOwner);

  if Assigned(AOwner) then
  begin
    form.PopupParent := AOwner;
    EnableWindow(AOwner.Handle, FALSE);
  end;

  if Length(AParams) > 0 then
    (form as IFormParams).SetParams(AParams);

  if Assigned(ACloseCallback) then
    (form as IModalForm).SetCloseCallback(ACloseCallback);

  form.Show;

  result := form;
end;

function RunForm(const AClassType: TFormClass; const AOwner: TForm; const AParams: array of pointer): TForm;
var
  form: TForm;
begin
  form := AClassType.Create(AOwner);

  if Assigned(AOwner) then
    form.PopupParent := AOwner;

  if Length(AParams) > 0 then
    (form as IFormParams).SetParams(AParams);

  form.Show;
  result := form;
end;

function MyZCompressStream(inStream, outStream: TStream; level: TZCompressionLevel): Boolean;
const
  bufferSize = 32768;
var
  zstream: TZStreamRec;
  zresult: Integer;
  inBuffer: array[0..bufferSize - 1] of Byte;
  outBuffer: array[0..bufferSize - 1] of Byte;
  inSize: Integer;
  outSize: Integer;
begin
  result := FALSE;

  FillChar(zstream, SizeOf(TZStreamRec), 0);
  if DeflateInit(zstream, ZLevels[level]) < 0 then
    Exit;

  try
    inSize := inStream.Read(inBuffer, bufferSize);

    while inSize > 0 do
    begin
      zstream.next_in := @inBuffer[0];
      zstream.avail_in := inSize;

      repeat
        zstream.next_out := @outBuffer[0];
        zstream.avail_out := bufferSize;

        if deflate(zstream, Z_NO_FLUSH) < 0 then
          Exit;

        // outSize := zstream.next_out - outBuffer;
        outSize := bufferSize - zstream.avail_out;

        outStream.Write(outBuffer, outSize);
      until (zstream.avail_in = 0) and (zstream.avail_out > 0);

      inSize := inStream.Read(inBuffer, bufferSize);
    end;

    repeat
      zstream.next_out := @outBuffer[0];
      zstream.avail_out := bufferSize;

      zresult := deflate(zstream, Z_FINISH);
      if zresult < 0 then
        Exit;

      // outSize := zstream.next_out - outBuffer;
      outSize := bufferSize - zstream.avail_out;

      outStream.Write(outBuffer, outSize);
    until (zresult = Z_STREAM_END) and (zstream.avail_out > 0);

    result := TRUE;
  finally
    deflateEnd(zstream);
  end;
end;

function MyZDecompressStream(inStream, outStream: TStream): Boolean;
const
  bufferSize = 32768;
var
  zstream: TZStreamRec;
  zresult: Integer;
  inBuffer: array[0..bufferSize - 1] of Byte;
  outBuffer: array[0..bufferSize - 1] of Byte;
  inSize: Integer;
  outSize: Integer;
begin
  result := FALSE;

  FillChar(zstream, SizeOf(TZStreamRec), 0);
  if InflateInit(zstream) < 0 then
    Exit;

  try
    inSize := inStream.Read(inBuffer, bufferSize);

    while inSize > 0 do
    begin
      zstream.next_in := @inBuffer;
      zstream.avail_in := inSize;

      repeat
        zstream.next_out := @outBuffer;
        zstream.avail_out := bufferSize;

        if inflate(zstream, Z_NO_FLUSH) < 0 then
          Exit;

        // outSize := zstream.next_out - outBuffer;
        outSize := bufferSize - zstream.avail_out;

        outStream.Write(outBuffer, outSize);
      until (zstream.avail_in = 0) and (zstream.avail_out > 0);

      inSize := inStream.Read(inBuffer, bufferSize);
    end;

    repeat
      zstream.next_out := @outBuffer;
      zstream.avail_out := bufferSize;

      zresult := inflate(zstream, Z_FINISH);
      if zresult < 0 then
        Exit;

      // outSize := zstream.next_out - outBuffer;
      outSize := bufferSize - zstream.avail_out;

      outStream.Write(outBuffer, outSize);
    until (zresult = Z_STREAM_END) and (zstream.avail_out > 0);

    result := TRUE;
  finally
    inflateEnd(zstream);
  end;
end;

function CompressStream(const AStream: TMemoryStream): Boolean;
var
  ostream: TMemoryStream;
begin
  result := FALSE;
  ostream := TMemoryStream.Create;
  try
    AStream.Position := 0;
    if MyZCompressStream(AStream, ostream, zcMax) then
    begin
      AStream.Clear;
      ostream.Position := 0;
      AStream.CopyFrom(ostream, ostream.Size);
      result := TRUE;
    end;
  finally
    ostream.Free;
  end;
end;

function DecompressStream(const AStream: TMemoryStream): Boolean;
var
  ostream: TMemoryStream;
begin
  result := FALSE;
  ostream := TMemoryStream.Create;
  try
    AStream.Position := 0;

    if MyZDecompressStream(AStream, ostream) then
    begin
      AStream.Clear;
      ostream.Position := 0;
      AStream.CopyFrom(ostream, ostream.Size);
      result := TRUE;
    end;
  finally
    ostream.Free;
  end;
end;

function GetFileSize(const AFile: String): DWORD;
var
  fHandle: THandle;
begin
  fHandle := CreateFile(PChar(AFile), GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if fHandle <> INVALID_HANDLE_VALUE then
  begin
    result := Winapi.Windows.GetFileSize(fHandle, nil);
    CloseHandle(fHandle);
  end
  else
    result := 0;
end;

function GetThreadsCount(const APID: DWORD): Integer;
var
  snap_handle : THandle;
  thread_entry: TThreadEntry32;
begin
  result := 0;

  snap_handle := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  if snap_handle <> INVALID_HANDLE_VALUE then
  try
    thread_entry.dwSize := SizeOf(thread_entry);
    if Thread32First(snap_handle, thread_entry) then
      repeat
        if thread_entry.th32OwnerProcessID = APID then
          Inc(result);
      until not Thread32Next(snap_handle, thread_entry);
  finally
    CloseHandle(snap_handle);
  end;
end;

function GetWorkingSetSize: DWORD;
var
  pmc: TProcessMemoryCounters;
begin
  pmc.cb := SizeOf(pmc);
  if GetProcessMemoryInfo(GetCurrentProcess, @pmc, SizeOf(pmc)) then
    result := pmc.WorkingSetSize
  else
    result := 0;
end;

function EncodeURL(const ASrc: String): String;
const
  HexMap     : String = '0123456789ABCDEF';
  SAFE_CHARS = [33, 39..42, 45, 46, 48..57, 65..90, 95, 97..122, 126];
var
  I, J: Integer;
begin
  result := '';

  I := 1; J := 1;
  SetLength(result, Length(ASrc) * 3);
  while I <= Length(ASrc) do
  begin
    if Ord(ASrc[I]) in SAFE_CHARS then
    begin
      Result[J] := ASrc[I];
      Inc(J);
    end
    else
      if ASrc[I] = ' ' then
      begin
        result[J] := '+';
        Inc(J);
      end
      else
      begin
        result[J + 0] := '%';
        result[J + 1] := HexMap[(Ord(ASrc[I]) shr 4) + 1];
        result[J + 2] := HexMap[(Ord(ASrc[I]) and 15) + 1];
        Inc(J, 3);
      end;
    Inc(I);
  end;

  SetLength(Result, J-1);
end;

function GetBlinds(const AString: String; out ASmallBlind, ABigBlind: Integer): Boolean;
var
  slash_pos: Integer;
begin
  slash_pos := Pos('/', AString);
  if slash_pos = 0 then
    Exit(FALSE);

  ASmallBlind := StrToIntDef(Copy(AString, 1, slash_pos - 1), -1);
  if ASmallBlind = -1 then
    Exit(FALSE);

  ABigBlind := StrToIntDef(Copy(AString, slash_pos + 1, Length(AString) - slash_pos), -1);
  if ABigBlind = -1 then
    Exit(FALSE);

  Exit(TRUE);
end;

function IsJPEGStream(const AStream: TStream): Boolean;
const
  JPG_HEADER: array[0..2] of Byte = ($FF, $D8, $FF);
var
  ms: TMemoryStream;
begin
  if AStream.Size < 3 then
    Exit(FALSE);

  ms := TMemoryStream.Create;
  try
    ms.CopyFrom(AStream, 3);
    if ms.Size = SizeOf(JPG_HEADER) then
      result := CompareMem(ms.Memory, @JPG_HEADER, SizeOf(JPG_HEADER))
    else
      Exit(FALSE);
  finally
    ms.Free;
  end;
end;

function CompareBytes(const A1, A2: TBytes; A1Len: Integer = -1; A2Len: Integer = -1): Boolean;
begin
  if A1Len = -1 then
    A1Len := Length(A1);
  if A2Len = -1 then
    A2Len := Length(A2);

  result := (A1Len = A2Len) and (CompareMem(A1, A2, A1Len));
end;

function GetSpecialFolderPath(const ACSIDL: Integer): String;
var
  RecPath: PWideChar;
begin
  RecPath := StrAlloc(MAX_PATH);
  try
    FillChar(RecPath^, MAX_PATH, 0);
    if SHGetSpecialFolderPath(0, RecPath, ACSIDL, FALSE) then
      result := RecPath
    else
      result := '';
  finally
    StrDispose(RecPath);
  end;
end;

procedure LoadImageFromResource(const AImage: TcxImage; const AResourceName: String);
var
  png: TdxPNGImage;
begin
  png := TdxPNGImage.Create;
  try
    png.LoadFromResource(HInstance, AResourceName, RT_RCDATA);
    AImage.Picture.Assign(png);
  finally
    png.Free;
  end;
end;

function IsPointInsideCircle(const AX, AY, ACircleX, ACircleY: Single; ARadius: Single): Boolean;
begin
  result := (AX - ACircleX) * (AX - ACircleX) + (AY - ACircleY) * (AY - ACircleY) < ARadius * ARadius;
end;


initialization
  SelfPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  AppDataLocalPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetSpecialFolderPath(CSIDL_LOCAL_APPDATA)) + 'ChipUP Poker');
  AppDataRoamingPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(GetSpecialFolderPath(CSIDL_APPDATA)) + 'ChipUP Poker');
  ForceDirectories(AppDataLocalPath);
  ForceDirectories(AppDataRoamingPath);

finalization


end.

