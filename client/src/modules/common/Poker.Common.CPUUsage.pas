unit Poker.Common.CPUUsage;

interface

uses
  Winapi.Windows;

type
  TCPUUsageData = record
    PID, Handle: DWORD;
    oldUser, oldKernel: Int64;
    LastUpdateTime: DWORD;
    LastUsage: Single;
  end;
  PCPUUsageData = ^TCPUUsageData;

  TCPUUsage = class
  public
    class function CreateCounter(const APID: DWORD): PCPUUsageData;
    class procedure DestroyCounter(const ACounter: PCPUUsageData);
    class function Get(const ACounter: PCPUUsageData): Single;
  end;

implementation

{ TCPUUsage }

class function TCPUUsage.CreateCounter(const APID: DWORD): PCPUUsageData;
var
  p: PCPUUsageData;
  mCreationTime, mExitTime, mKernelTime, mUserTime: _FILETIME;
  h: DWORD;
begin
  result := nil;
  h := OpenProcess(PROCESS_QUERY_INFORMATION, FALSE, APID);
  if h = 0 then
    Exit;

  New(p);
  p^.PID := APID;
  p^.Handle := h;
  p^.LastUpdateTime := GetTickCount;
  p^.LastUsage := 0;
  if GetProcessTimes(p^.Handle, mCreationTime, mExitTime, mKernelTime, mUserTime) then
  begin
    p^.oldKernel := Int64(mKernelTime.dwLowDateTime or (mKernelTime.dwHighDateTime shr 32));
    p^.oldUser := Int64(mUserTime.dwLowDateTime or (mUserTime.dwHighDateTime shr 32));
    result := p;
  end
  else
    Dispose(p);
end;

class procedure TCPUUsage.DestroyCounter(const ACounter: PCPUUsageData);
begin
  CloseHandle(ACounter^.Handle);
  Dispose(ACounter);
end;

class function TCPUUsage.Get(const ACounter: PCPUUsageData): Single;
var
  mCreationTime, mExitTime, mKernelTime, mUserTime: _FILETIME;
  DeltaMs, ThisTime: DWORD;
  mKernel, mUser, mDelta: Int64;
begin
  ThisTime := GetTickCount;
  DeltaMs := ThisTime - ACounter.LastUpdateTime;
  ACounter.LastUpdateTime := ThisTime;
  GetProcessTimes(ACounter.Handle, mCreationTime, mExitTime, mKernelTime, mUserTime);
  mKernel := Int64(mKernelTime.dwLowDateTime or (mKernelTime.dwHighDateTime shr 32));
  mUser := Int64(mUserTime.dwLowDateTime or (mUserTime.dwHighDateTime shr 32));
  mDelta := mUser + mKernel - ACounter.oldUser - ACounter.oldKernel;
  ACounter.oldUser := mUser;
  ACounter.oldKernel := mKernel;
  ACounter.LastUsage := ((mDelta / DeltaMs) / 100) / CPUCount;
  result := ACounter.LastUsage;
end;

end.
