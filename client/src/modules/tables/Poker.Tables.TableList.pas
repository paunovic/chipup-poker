unit Poker.Tables.TableList;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, Poker.Games.Game, Poker.HandHistory.Playback, Poker.Clubs.Club, Vcl.Forms,
  Poker.Avatars.AvatarList, Poker.HandHistory.Items, Poker.Tables.Status, Poker.Avatars.Avatar, Poker.Tables.Table, System.SyncObjs,
  Poker.Types;

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

    function GetAndLockTable(const AId: Integer; out ATable: TTable): Boolean; overload;
    function GetAndLockTable(const AMongoId: TMongoId; const ATableType: TTableType; out ATable: TTable): Boolean; overload;
    procedure UpdateGameObject(const AGameId: TMongoId);
    procedure UpdateClubObject(const AClubId: TMongoId);

    procedure ClearWithoutNotification;

    function AddLiveTable(const AGameId: TMongoId; const AShow: Boolean; const ASendJoinCommand: Boolean): Boolean;
    function AddHandPlaybackTable(const AGameId: TMongoId; const AHandId: UINT): Boolean;
    function SittingCount: Integer;
    procedure CloseTablesForClub(const AClubId: TMongoId);
  end;

var
  Tables: TTableList;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Vcl.Controls, Poker.Forms.Table, Poker.Common.Misc, Poker.Server.Socket, Poker.DirectX.Core, Asphyre.Math, Poker.DataModule,
  Poker.HandHistory.Core;

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
  FLock.Enter;
  try
    Clear;
  finally
    FLock.Leave;
  end;
  inherited;
  FreeAndNil(FLock);
  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}
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

function TTableList.AddLiveTable(const AGameId: TMongoId; const AShow: Boolean; const ASendJoinCommand: Boolean): Boolean;
var
  table: TTable;
begin
  result := FALSE;
  if GetAndLockTable(AGameId, ttLiveGame, table) then
  begin
    if AShow then
      table.BringToFront;
    Unlock;
    Exit(TRUE);
  end;

  table := TTable.Create(FNextTableInternalId);
  Add(FNextTableInternalId, table);
  if table.SetupLiveTable(AGameId, ASendJoinCommand) then
  begin
    Inc(FNextTableInternalId);
    if AShow then
      table.BringToFront;
    result := TRUE;
  end
  else
  begin
    {$IFDEF DEBUG} DebugLn(FDebugId, 'Failed to setup live table', ditException); {$ENDIF}
    Remove(FNextTableInternalId);
  end;
end;

function TTableList.AddHandPlaybackTable(const AGameId: TMongoId; const AHandId: UINT): Boolean;
var
  table: TTable;
  hhis: THandHistoryItems;
  hhi: THandHistoryItem;
begin
  result := FALSE;
  HandHistory.Lock;
  try
    if not HandHistory.TryGetValue(AGameId, hhis) then
      Exit;

    if hhis.GetAndLockHand(AHandId, hhi) then
    try
      table := TTable.Create(FNextTableInternalId);
      Add(FNextTableInternalId, table);
      if table.SetupHandHistoryTable(hhis, hhi) then
      begin
        Inc(FNextTableInternalId);
        table.BringToFront;
        result := TRUE;
      end
      else
        Remove(FNextTableInternalId);
    finally
      hhis.Unlock;
    end;
  finally
    HandHistory.Unlock;
  end;
end;

function TTableList.SittingCount: Integer;
var
  table: TTable;
begin
  result := 0;
  FLock.Enter;
  try
    for table in Values do
      if (table.TableType = ttLiveGame) and
         (table.Status.IsSitting) then
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

procedure TTableList.CloseTablesForClub(const AClubId: TMongoId);
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
        if table.ClubId = AClubId then
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

function TTableList.GetAndLockTable(const AMongoId: TMongoId; const ATableType: TTableType; out ATable: TTable): Boolean;
var
  table: TTable;
begin
  FLock.Enter;
  for table in Values do
    if (table.TableType = ATableType) and
       (table.GameId = AMongoId) then
    begin
      ATable := table;
      Exit(TRUE);
    end;
  FLock.Leave;
  Exit(FALSE);
end;

function TTableList.GetAndLockTable(const AId: Integer; out ATable: TTable): Boolean;
begin
  FLock.Enter;
  result := TryGetValue(AId, ATable);
  if not result then
  begin
    FLock.Leave;
    {$IFDEF DEBUG} DebugLn(FDebugId, Format('Cannot find table with internal id: %d', [AId]), ditException); {$ENDIF}
  end;
end;

procedure TTableList.UpdateClubObject(const AClubId: TMongoId);
var
  table: TTable;
begin
  FLock.Enter;
  try
    for table in Values do
      if table.ClubId = AClubId then
        table.UpdateObjects;
  finally
    FLock.Leave;
  end;
end;

procedure TTableList.UpdateGameObject(const AGameId: TMongoId);
var
  table: TTable;
begin
  if GetAndLockTable(AGameId, ttLiveGame, table) then
  try
    table.UpdateObjects;
  finally
    Unlock;
  end;
end;

end.
