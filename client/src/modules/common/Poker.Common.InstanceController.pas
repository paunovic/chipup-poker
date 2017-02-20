unit Poker.Common.InstanceController;

interface

uses
  Winapi.Windows;

type
  TInstanceControllerScope = (icsSystem, icsDesktop, icsSession, icsTrustee);

  TInstanceController = class
  private
    class var
      FMutexHandle: THandle;
      FInstanceName: String;

    class function GetExclusionName(const AType: TInstanceControllerScope): String;
  public
    class function AcquireInstance(const AGUID: String; const AScope: TInstanceControllerScope; out AExistingProcessId: DWORD): Boolean;
    class function ReleaseInstance: Boolean;

    class property InstanceName: String read FInstanceName;
  end;


implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  System.SysUtils, Vcl.Controls, Winapi.TlHelp32;


class function TInstanceController.AcquireInstance(const AGUID: String; const AScope: TInstanceControllerScope; out AExistingProcessId: DWORD): Boolean;
var
  mutex_handle: THandle;
  instance_name_without_pid: String;
  tl_snapshot: THandle;
  process_entry: TProcessEntry32;
begin
  result := FALSE;
  instance_name_without_pid := AGUID + ':' + GetExclusionName(AScope);

  // iterate through processes and find out if there is existing mutex
  tl_snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
  try
    process_entry.dwSize := SizeOf(process_entry);
    if Process32First(tl_snapshot, process_entry) then
      while Process32Next(tl_snapshot, process_entry) do
      begin
        mutex_handle := OpenMutex(SYNCHRONIZE, FALSE, PChar(instance_name_without_pid + ':' + IntToStr(process_entry.th32ProcessID)));
        if mutex_handle <> 0 then
        begin
          {$IFDEF DEBUG} DebugLn(Format('InstanceController: instance already exists [%s]', [FInstanceName]), ditApplication); {$ENDIF}
          CloseHandle(mutex_handle);
          AExistingProcessId := process_entry.th32ProcessID;
          Exit(FALSE);
        end;
      end;
  finally
    CloseHandle(tl_snapshot);
  end;

  // attempt to create mutex
  FInstanceName := instance_name_without_pid + ':' + IntToStr(GetCurrentProcessId);
  mutex_handle := CreateMutex(nil, FALSE, PChar(FInstanceName));
  if mutex_handle <> 0 then
  begin
    if GetLastError = ERROR_ALREADY_EXISTS then
    begin
      result := FALSE;
      {$IFDEF DEBUG} DebugLn(Format('InstanceController: instance already exists [%s]', [FInstanceName]), ditApplication); {$ENDIF}
    end
    else
    begin
      FMutexHandle := mutex_handle;
      result := TRUE;
      {$IFDEF DEBUG} DebugLn(Format('InstanceController: instance acquired [%s]', [FInstanceName]), ditApplication); {$ENDIF}
    end;
  end
  else
  begin
    {$IFDEF DEBUG} DebugLn(Format('InstanceController: CreateMutex() call failed [GLE: %d]', [GetLastError]), ditException); {$ENDIF}
  end;
end;

class function TInstanceController.ReleaseInstance: Boolean;
begin
  if FMutexHandle > 0 then
  begin
    result := CloseHandle(FMutexHandle);
    FMutexHandle := 0;
    {$IFDEF DEBUG} DebugLn('InstanceController: instance released', ditApplication); {$ENDIF}
  end
  else
    result := TRUE;
end;

class function TInstanceController.GetExclusionName(const AType: TInstanceControllerScope): String;
var
  desk: HDESK;
  res: BOOL;
  token: THandle;
  uid: LUID;
  data: pointer;
  dlen, ulen, len: Cardinal;
  domain, username: array of Char;
begin
  case AType of
    icsSystem: result := 'systemwide';

    icsDesktop: begin
      desk := GetThreadDesktop(GetCurrentThreadId);
      res := GetUserObjectInformation(desk, UOI_NAME, nil, 0, len);
      if (not res) and
         (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
      begin
        data := AllocMem(len);
        if GetUserObjectInformation(desk, UOI_NAME, data, len, len) then
        begin
          SetString(result, PChar(data), len div 2);
          result := TrimRight(result);
        end;
        FreeMem(data);
      end;
    end;

    icsSession: begin
      res := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, token);
      if res then
      begin
        res := GetTokenInformation(token, TokenStatistics, nil, 0, len);
        if (not res) and
           (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
        begin
          data := AllocMem(len);
          if GetTokenInformation(token, TokenStatistics, data, len, len) then
          begin
            uid := PTokenStatistics(data)^.AuthenticationId;
            result := Format('%.8x%.8x', [uid.LowPart, uid.HighPart]);
          end;
          FreeMem(data);
        end;
      end;
    end;

    icsTrustee: begin
      ulen := 0;
      res := GetUserName(nil, ulen);
      if (not res) and
         (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
      begin
        SetLength(username, ulen);
        if GetUsername(@username[0], ulen) then
        begin
          dlen := ExpandEnvironmentStrings('%userdomain%', nil, 0);
          SetLength(domain, dlen);
          dlen := ExpandEnvironmentStrings('%userdomain%', @domain[0], dlen);
          SetLength(result, (ulen - 1) + (dlen - 1) + 1);
          Move(username[0], result[1], (ulen - 1) * 2);
          Move(domain[0], result[ulen + 1], (dlen - 1) * 2);
          result[ulen] := '-';
        end;
      end;
    end;
  end;
end;

end.

