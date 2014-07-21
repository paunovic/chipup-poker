unit Poker.Common.Misc;

interface

uses
  Winapi.ShellApi, Winapi.Windows, System.Classes, System.SysUtils, Vcl.Forms, cxImage, Vcl.Imaging.JPEG, Asphyre.Types, Vcl.Controls;

{$IFDEF DEBUG}
function SerializeObject(const AObject: TObject): String;
{$ENDIF}
function IsValidString(const AString, AAllowedChars: String): Boolean;
function ShellOpen(const AFileName: PChar; const AExecInfo: PShellExecuteInfo = nil; const AParams: PChar = nil; const ADirectory: PChar = nil;
                   const AShowCmd: Integer = SW_SHOWNORMAL; const AVerb: String = 'open'; const AMask: DWORD = SEE_MASK_FLAG_NO_UI; const AHWND: HWND = 0): Boolean;
procedure Split(const ADelimiter: Char; const AInput: String; const AStrings: TStrings; const ATrim: Boolean = FALSE; const AStrictDelimiter: Boolean = TRUE);
function CompressStream(const AStream: TMemoryStream): Boolean;
function DecompressStream(const AStream: TMemoryStream): Boolean;
function GetFileSize(const AFile: String): DWORD;
function GetThreadsCount(const APID: DWORD): Integer;
function GetWorkingSetSize: DWORD;
function EncodeURL(const ASrc: String): String;
function GetBlinds(const AString: String; out ASmallBlind, ABigBlind: Integer): Boolean;
function IsJPEGStream(const AStream: TStream): Boolean;
procedure LoadJPGFromResource(const AImage: TJPEGImage; const AResourceName: String);
function GetSpecialFolderPath(const ACSIDL: Integer): String;
procedure LoadImageFromResource(const AImage: TcxImage; const AResourceName: String);
function PtInCircle(const AX, AY, ACircleX, ACircleY: Single; ARadius: Single): Boolean;
function SecondsToTimeStr(ASeconds: DWORD): String;
function SecondsToTime(ASeconds: DWORD): TTime;
function ChipsToStr(const AValue: UINT32): String;
procedure GetAllCombinations(const AInput: TArray<String>; const ALength: Integer; out ACombinations: TArray<String>);
function GetTaskbarHeight: Integer;
function IsDirectoryWriteable(const APath: String): Boolean;
procedure RoundControl(const AControl: TWinControl; const AAmount: Integer);
function PtInBounds(const APoint: TPoint; const ABounds: TPoint4): Boolean;
function RoundToNearestBB(const AChips, ABigBlind: UINT32): UINT32;
function TempPath: String;
function IsValidRegex(const ARegex: String): Boolean;


implementation

uses
  {$IFDEF DEBUG} System.Rtti, System.TypInfo, {$ENDIF}
  System.ZLib, Winapi.PsApi, Winapi.TlHelp32, Winapi.ShlObj, dxGDIPlusClasses, System.Generics.Collections, System.RegularExpressionsAPI;


{$IFDEF DEBUG}
function ValueToStr(const AProperty: TRttiProperty; const AValue: TValue): String;
var
  C1: Integer;
  byteval: Byte;
  convert_to_hex: Boolean;
  method: TRttiMethod;
  val2: TValue;
begin
  result := '';
  if AValue.IsEmpty then
    Exit;

  case AValue.TypeInfo^.Kind of
    tkClass: begin
      result := '{';
      method := nil;
      if Assigned(AProperty) then
        method := AProperty.PropertyType.GetMethod('ToArray');
      if Assigned(method) then
      begin
        val2 := method.Invoke(AValue, []);
        for C1 := 0 to val2.GetArrayLength - 1 do
          result := result + Format('%s, ', [ValueToStr(nil, val2.GetArrayElement(C1))]);
      end
      else
        result := result + SerializeObject(AValue.AsObject);

      if result[Length(result)] = ' ' then
        Delete(result, Length(result) - 1, 2);
      result := result + '}';
    end;

    tkArray, tkDynArray: begin
      convert_to_hex := (AValue.GetArrayLength > 0) and
                        (AValue.GetArrayElement(0).TryAsType<Byte>(byteval));
      if not convert_to_hex then
        result := '[';
      for C1 := 0 to AValue.GetArrayLength - 1 do
        if convert_to_hex then
          result := result + LowerCase(IntToHex(AValue.GetArrayElement(C1).AsInteger, 2))
        else
          result := result + Format('%s, ', [ValueToStr(AProperty, AValue.GetArrayElement(C1))]);
      if not convert_to_hex then
      begin
        if result[Length(result)] = ' ' then
          Delete(result, Length(result) - 1, 2);
        result := result + ']';
      end;
    end;

    tkString, tkWString, tkLString, tkUString: result := Format('"%s"', [AValue.ToString]);

    tkRecord: begin
      method := nil;
      if Assigned(AProperty) then
        method := AProperty.PropertyType.GetMethod('ToString');
      if Assigned(method) then
        result := method.Invoke(AValue, []).AsString
      else
        result := AValue.ToString;
    end;
  else
    result := AValue.ToString;
  end;
end;

function SerializeObject(const AObject: TObject): String;
var
  t: TRttiType;
  p: TRttiProperty;
  method: TRttiMethod;
  print_it: Boolean;
begin
  result := '';
  if not Assigned(AObject) then
    Exit;

  t := TRttiContext.Create.GetType(AObject.ClassType);
  for p in t.GetProperties do
  begin
    print_it := FALSE;

    method := t.GetMethod(Format('has_%s', [p.Name]));
    if Assigned(method) then
      print_it := method.Invoke(AObject, []).AsBoolean;

    if print_it then
    begin
      result := result + Format('%s: %s; ', [p.Name, ValueToStr(p, p.GetValue(AObject))]);

      if p.PropertyType.TypeKind = tkClass then
        result := result + #10;
    end;
  end;

  if result <> '' then
    if result[Length(result)] = #10 then
      Delete(result, Length(result) - 2, 3)
    else
      Delete(result, Length(result) - 1, 2);
end;
{$ENDIF}

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

procedure Split(const ADelimiter: Char; const AInput: String; const AStrings: TStrings; const ATrim: Boolean = FALSE; const AStrictDelimiter: Boolean = TRUE);
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
  HEXMAP     : String = '0123456789ABCDEF';
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
      result[J] := ASrc[I];
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
        result[J + 1] := HEXMAP[(Ord(ASrc[I]) shr 4) + 1];
        result[J + 2] := HEXMAP[(Ord(ASrc[I]) and 15) + 1];
        Inc(J, 3);
      end;
    Inc(I);
  end;

  SetLength(result, J - 1);
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

procedure LoadJPGFromResource(const AImage: TJPEGImage; const AResourceName: String);
var
  rstream: TResourceStream;
begin
  rstream := TResourceStream.Create(HInstance, AResourceName, RT_RCDATA);
  try
    AImage.LoadFromStream(rstream);
  finally
    rstream.Free;
  end;
end;

function PtInCircle(const AX, AY, ACircleX, ACircleY: Single; ARadius: Single): Boolean;
begin
  result := (AX - ACircleX) * (AX - ACircleX) + (AY - ACircleY) * (AY - ACircleY) <= ARadius * ARadius;
end;

function SecondsToTimeStr(ASeconds: DWORD): String;
var
  s, m, h: DWORD;
begin
  h := ASeconds div 3600;
  ASeconds := ASeconds mod 3600;

  m := ASeconds div 60;
  s := ASeconds mod 60;

  if h = 0 then
    result := Format('%.2dm %.2ds', [m, s])
  else
    result := Format('%.2dh %.2dm %.2ds', [h, m, s]);
end;

function SecondsToTime(ASeconds: DWORD): TTime;
var
  s, m, h: Integer;
begin
  h := ASeconds div 3600;
  ASeconds := ASeconds mod 3600;
  m := ASeconds div 60;
  s := ASeconds mod 60;
  h := h mod 24; // prevent H from going above 23. this is kinda dirty fix, since function will be able to encode only max one day of seconds

  result := EncodeTime(h, m, s, 0)
end;

function ChipsToStr(const AValue: UINT32): String;
begin
  result := IntToStr(AValue);
  if AValue mod 100 = 0 then
    Delete(result, Length(result) - 1, 2)
  else
    Insert('.', result, Length(result) - 1);
  if AValue < 100 then
    result := '0' + result;
end;

procedure GetAllCombinations(const AInput: TArray<String>; const ALength: Integer; out ACombinations: TArray<String>);
var
  data: TArray<String>;

  procedure AddComb;
  var
    C1: Integer;
  begin
    SetLength(ACombinations, Length(ACombinations) + 1);
    ACombinations[Length(ACombinations) - 1] := '';
    for C1 := Low(data) to High(data) do
      ACombinations[Length(ACombinations) - 1] := ACombinations[Length(ACombinations) - 1] + data[C1];
  end;

  procedure GetCombination(const AStart, AEnd, AIndex: Integer);
  var
    C1: Integer;
  begin
    if AIndex = ALength then
    begin
      AddComb;
      Exit;
    end;

    for C1 := AStart to AEnd do
    begin
      if AEnd - C1 + 1 < ALength - AIndex then
        Break;

      data[AIndex] := AInput[C1];
      GetCombination(C1 + 1, AEnd, AIndex + 1);
    end;
  end;

begin
  SetLength(data, ALength);
  GetCombination(0, Length(AInput) - 1, 0);
end;

function GetTaskbarHeight: Integer;
var
  taskbar_hwnd: HWND;
  taskbar_rect: TRect;
begin
  taskbar_hwnd := FindWindow('Shell_TrayWnd', '');
  if taskbar_hwnd = 0 then
    Exit(0)
  else
  begin
    GetWindowRect(taskbar_hwnd, taskbar_rect);
    Exit(taskbar_rect.Height);
  end;
end;

function IsDirectoryWriteable(const APath: String): Boolean;
var
  fname: String;
  fhandle: THandle;
begin
  fname := IncludeTrailingPathDelimiter(APath) + 'isdirwrtchk.tmp';
  fhandle := CreateFile(PChar(fname), GENERIC_READ or GENERIC_WRITE, 0, nil, CREATE_NEW, FILE_ATTRIBUTE_TEMPORARY or FILE_FLAG_DELETE_ON_CLOSE, 0);
  result := fhandle <> INVALID_HANDLE_VALUE;
  if result then
  begin
    CloseHandle(fhandle);
    DeleteFile(fname);
  end;
end;

procedure RoundControl(const AControl: TWinControl; const AAmount: Integer);
begin
  SetWindowRgn(AControl.Handle, CreateRoundRectRgn(0, 0, AControl.ClientWidth, AControl.ClientHeight, AAmount, AAmount), TRUE);
end;

function PtInBounds(const APoint: TPoint; const ABounds: TPoint4): Boolean;
begin
  result := (APoint.X >= ABounds[0].x) and (APoint.X <= ABounds[1].x) and
            (APoint.Y >= ABounds[0].y) and (APoint.Y <= ABounds[2].y);
end;

function RoundToNearestBB(const AChips, ABigBlind: UINT32): UINT32;
begin
  result := Round(AChips / ABigBlind) * ABigBlind;
end;

function TempPath: String;
var
  buffer: TArray<Char>;
  bufsize: Integer;
  chars: Integer;
begin
  chars := 128;
  repeat
    bufsize := chars;
    SetLength(buffer, bufsize);
    chars := GetTempPath(bufsize, @buffer[0]);
  until chars <= bufsize;
  SetString(result, PChar(@buffer[0]), chars - 1);
  result := IncludeTrailingPathDelimiter(result);
end;

function IsValidRegex(const ARegex: String): Boolean;
var
  pcre_error: PAnsiChar;
  pcre_error_offset: Integer;
  char_table: pointer;
  pattern: pointer;
begin
  pattern := nil;
  char_table := pcre_maketables;
  try
    pattern := pcre_compile(PAnsiChar(AnsiString(ARegex)), 0, @pcre_error, @pcre_error_offset, char_table);
    result := Assigned(pattern);
  finally
    pcre_dispose(pattern, nil, char_table);
  end;
end;


end.






