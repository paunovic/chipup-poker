unit Poker.Tables.TableList;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, Poker.Games.Game, Poker.HandHistory.Playback,
  Poker.Clubs.Club, Vcl.Forms, Poker.Avatars.AvatarList, Poker.HandHistory.Items, Poker.Tables.Renderer,
  Poker.Avatars.Avatar, Poker.Tables.Table;

type
  TTableList = class(TObjectDictionary<Integer, TTable>)
  private
    {$IFDEF DEBUG} FDebugId: Integer; {$ENDIF}
    FNextTableInternalId: Integer;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;
    destructor Destroy; override;

    procedure DisableAll;
    procedure EnableAll;

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

  FNextTableInternalId := 0;

  inherited Create([doOwnsValues]);
end;

destructor TTableList.Destroy;
begin
  {$IFDEF DEBUG} UnregisterDebugObject(FDebugId); {$ENDIF}

  inherited;
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

  inherited Add(FNextTableInternalId, table);
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
     (not hhis.TryGetValue(AHandId, hhi)) then
    Exit(nil);

  table := TTable.Create(FNextTableInternalId);
  if not table.AcquireSwapChainElement then
  begin
    FreeAndNil(table);
    Exit(nil);
  end;

  inherited Add(FNextTableInternalId, table);
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
  for table in Values do
    if table.IsSitting then
      Inc(result);
end;

procedure TTableList.ClearWithoutNotification;
var
  table: TTable;
begin
  for table in Values do
    table.LeaveNotify := FALSE;
  Clear;
end;

procedure TTableList.CloseTablesForClub(const AClubId: TBytes);
var
  table: TTable;
  to_remove: TList<Integer>;
  id: Integer;
begin
  to_remove := TList<Integer>.Create;
  try
    for table in Values do
      if CompareBytes(table.ClubId, AClubId) then
        to_remove.Add(table.InternalId);
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
  for table in Values do
    EnableWindow(table.Form.Handle, FALSE);
end;

procedure TTableList.EnableAll;
var
  table: TTable;
begin
  for table in Values do
    EnableWindow(table.Form.Handle, TRUE);
end;

function TTableList.FindTable(const AMongoId: TBytes; const ATableType: TTableType; out ATable: TTable): Boolean;
var
  table: TTable;
begin
  for table in Values do
    if (CompareBytes(table.GameId, AMongoId)) and
       (table.TableType = ATableType) then
    begin
      ATable := table;
      Exit(TRUE);
    end;
  Exit(FALSE);
end;

end.
