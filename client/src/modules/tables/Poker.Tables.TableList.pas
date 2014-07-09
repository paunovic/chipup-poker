unit Poker.Tables.TableList;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, Poker.Games.Game, Poker.HandHistory.Playback,
  Poker.Clubs.Club, Vcl.Forms, Poker.Avatars.AvatarList, Poker.HandHistory.Items, Poker.Tables.Renderer,
  Poker.Avatars.Avatar, Poker.Tables.Table, System.SyncObjs;

type
  TTableList = class(TObjectDictionary<Integer, TTable>)
  private
    {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}
    FLock: TCriticalSection;
    FNextTableInternalId: Integer;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    procedure DisableAll;
    procedure EnableAll;

    procedure Remove(const AId: Integer);
    procedure Add(const AId: Integer; const ATable: TTable);

    procedure Lock;
    procedure Unlock;

    function GetAndLockTable(const AId: Integer; out ATable: TTable): Boolean;

    procedure ClearWithoutNotification;

    function FindTable(const AMongoId: TBytes; const ATableType: TTableType; out ATable: TTable): Boolean;

    function AddTable(const AGameId: TBytes; const AShow: Boolean; const ASendJoinCommand: Boolean): TTable;
    function AddHandPlaybackTable(const AGameId: TBytes; const AHandId: UINT): TTable;
    function SittingCount: Integer;
    procedure CloseTablesForClub(const AClubId: TBytes);
  end;

var
  Tables: TTableList;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Vcl.Controls, Poker.Forms.Table, Poker.Common.Misc, Poker.Server.Socket.Commands, Poker.DirectX.Core, Vectors2px, Poker.DataModule,
  Poker.HandHistory.Core, Poker.Tables.Status;

{ TTableList }

class procedure TTableList.Initialize;
begin
  Tables := TTableList.Create;
end;

class procedure TTableList.Deinitialize;
begin
  FreeAndNil(Tables);
end;

constructor TTableList.Create;
begin
  {$IFDEF DEBUG} FDebugId := RegisterDebugObject('Tables'); {$ENDIF}

  FLock := TCriticalSection.Create;
  FNextTableInternalId := 0;

  inherited Create([doOwnsValues]);
end;

destructor TTableList.Destroy;
begin
  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}

  FreeAndNil(FLock);
  inherited;
end;

procedure TTableList.Lock;
begin
  FLock.Enter;
end;

procedure TTableList.Unlock;
begin
  FLock.Leave;
end;

procedure TTableList.Remove(const AId: Integer);
begin
  FLock.Enter;
  try
    inherited Remove(AId);
  finally
    FLock.Leave;
  end;
end;

procedure TTableList.Add(const AId: Integer; const ATable: TTable);
begin
  FLock.Enter;
  try
    inherited Add(AId, ATable);
  finally
    FLock.Leave;
  end;
end;

function TTableList.AddTable(const AGameId: TBytes; const AShow: Boolean; const ASendJoinCommand: Boolean): TTable;
var
  table: TTable;
begin
  if FindTable(AGameId, ttLiveGame, table) then
  begin
    if AShow then
      table.BringToFront;
    Exit(table);
  end;

  table := TTable.Create(FNextTableInternalId);
  if not table.AcquireSwapChainElement then
  begin
    FreeAndNil(table);
    Exit(nil);
  end;

  Add(FNextTableInternalId, table);
  Inc(FNextTableInternalId);

  if table.SetupLiveTable(AGameId, ASendJoinCommand) then
  begin
    if AShow then
      table.BringToFront;

    result := table;
  end
  else
  begin
    {$IFDEF DEBUG} DebugLn(FDebugId, 'Failed to setup live table', ditException); {$ENDIF}
    Remove(FNextTableInternalId);
    result := nil;
  end;
end;

function TTableList.AddHandPlaybackTable(const AGameId: TBytes; const AHandId: UINT): TTable;
var
  table: TTable;
  hhis: THandHistoryItems;
  hhi: THandHistoryItem;
begin
  if (not HandHistory.TryGetValue(AGameId, hhis)) or
     (not hhis.FindHand(AHandId, hhi)) then
    Exit(nil);

  table := TTable.Create(FNextTableInternalId);
  if not table.AcquireSwapChainElement then
  begin
    FreeAndNil(table);
    Exit(nil);
  end;

  Add(FNextTableInternalId, table);
  Inc(FNextTableInternalId);

  table.SetupHandHistoryTable(hhis, hhi);
  table.BringToFront;

  result := table;
end;

function TTableList.SittingCount: Integer;
var
  table: TTable;
begin
  result := 0;
  FLock.Enter;
  try
    for table in Values do
      if table.IsSitting then
        Inc(result);
  finally
    FLock.Leave;
  end;
end;

procedure TTableList.ClearWithoutNotification;
var
  table: TTable;
begin
  FLock.Enter;
  try
    for table in Values do
      table.LeaveNotify := FALSE;
    Clear;
  finally
    FLock.Leave;
  end;
end;

procedure TTableList.CloseTablesForClub(const AClubId: TBytes);
var
  table: TTable;
  to_remove: TList<Integer>;
  id: Integer;
begin
  to_remove := TList<Integer>.Create;
  try
    FLock.Enter;
    try
      for table in Values do
        if CompareBytes(table.ClubId, AClubId) then
          to_remove.Add(table.InternalId);
    finally
      FLock.Leave;
    end;

    for id in to_remove do
      Remove(id);
  finally
    to_remove.Free;
  end;
end;

procedure TTableList.DisableAll;
var
  table: TTable;
begin
  FLock.Enter;
  try
    for table in Values do
      EnableWindow(table.Form.Handle, FALSE);
  finally
    FLock.Leave;
  end;
end;

procedure TTableList.EnableAll;
var
  table: TTable;
begin
  FLock.Enter;
  try
    for table in Values do
      EnableWindow(table.Form.Handle, TRUE);
  finally
    FLock.Leave;
  end;
end;

function TTableList.FindTable(const AMongoId: TBytes; const ATableType: TTableType; out ATable: TTable): Boolean;
var
  table: TTable;
begin
  FLock.Enter;
  try
    for table in Values do
      if (CompareBytes(table.GameId, AMongoId)) and
         (table.TableType = ATableType) then
      begin
        ATable := table;
        Exit(TRUE);
      end;
    Exit(FALSE);
  finally
    FLock.Leave;
  end;
end;

function TTableList.GetAndLockTable(const AId: Integer; out ATable: TTable): Boolean;
begin
  result := TryGetValue(AId, ATable);
  if result then
    Lock
  else
  begin
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('Cannot find table with internal id: %d', [AId]), ditException); {$ENDIF}
  end;
end;

end.
