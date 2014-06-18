unit Poker.Table.Tables;

interface

uses
  Winapi.Windows, System.SysUtils, System.Generics.Collections, Poker.Objects.GameInfo, Poker.HandHistory.Playback,
  Poker.Objects.ClubInfo, Vcl.Forms, Poker.Avatars, Poker.HandHistory.Items, Poker.Table.Renderer;

type
  TTable = class
  private
    FTableType: TTableType;
    FForm: TForm;
    FSeatIndex: Integer;
    FGameId: TBytes;
    FClubId: TBytes;
    FHandId: UINT;
    FClubSeq: Integer;
    FGame: TGameInfo;
    FClub: TClubInfo;
    FHandHistoryPlayback: THandHistoryPlayback;
    FSwapChainIndex: Integer;
    FRenderer: TTableRenderer;

    function AcquireSwapChainElement: Boolean;

  public
    procedure SetupLiveTable(const AClub: TClubInfo; const AGame: TGameInfo; const ASendJoinCommand: Boolean);
    procedure SetupHandHistoryTable(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);
    procedure SetupSettingsPreviewTable(const AHandle: THandle);

    destructor Destroy; override;

    function IsSitting: Boolean;

    procedure UpdateAvatars(const AAvatar: TAvatar);

    function ReassignObjects(const AGameId: TBytes): Boolean; overload;
    procedure ReassignObjects(const AClub: TClubInfo; const AGame: TGameInfo); overload;

    procedure BringToFront;

    property Game: TGameInfo read FGame;
    property Club: TClubInfo read FClub;
    property GameId: TBytes read FGameId;
    property ClubId: TBytes read FClubId;
    property ClubSeq: Integer read FClubSeq;
    property HandId: UINT read FHandId;
    property Form: TForm read FForm;
    property SeatIndex: Integer read FSeatIndex write FSeatIndex;
    property SwapChainIndex: Integer read FSwapChainIndex;
    property TableType: TTableType read FTableType;
    property Renderer: TTableRenderer read FRenderer;
    property HandHistoryPlayback: THandHistoryPlayback read FHandHistoryPlayback;
  end;

  TTables = class(TObjectList<TTable>)
  public
    class procedure Initialize;
    class procedure Deinitialize;

    procedure DisableAll;
    procedure EnableAll;

    procedure ReassignObjects;

    function AddTable(const AClub: TClubInfo; const AGame: TGameInfo; const AShow: Boolean; const ASendJoinCommand: Boolean): TTable;
    function AddHandPlaybackTable(const AGameId: TBytes; const AHandId: UINT): TTable;
    function AddSettingsPreviewTable(const AHandle: THandle): TTable;
    function SittingCount: Integer;
    function IndexOf(const AGameId: TBytes): Integer;
    function FindTable(const AGameId: TBytes; var ATable: TTable): Boolean;
    procedure CloseTablesForClub(const AClubId: TBytes);
  end;

var
  Tables: TTables;


implementation

uses
  Vcl.Controls, Poker.Forms.Table, Poker.Common.Misc, Poker.Server.Socket, Poker.DirectX.Core, Vectors2px, Poker.DataModule,
  Poker.HandHistory.Core, Poker.Objects.TableStatus;

{ TTable }

destructor TTable.Destroy;
var
  ts: TTableStatus;
begin
  if FTableType = ttLiveGame then
    ServerSocket.LeaveTable(FGameId);

  FreeAndNil(FForm);

  ts := nil;
  if Assigned(FRenderer) then
  begin
    ts := FRenderer.TableStatus;
    FreeAndNil(FRenderer);
  end;

  if FTableType = ttSettingsPreview then
  begin
    FreeAndNil(FClub);
    FreeAndNil(ts);
  end;

  FreeAndNil(FHandHistoryPlayback);

  DXCore.ReleaseSwapChainElement(FSwapChainIndex);

  inherited;
end;

function TTable.AcquireSwapChainElement: Boolean;
begin
  result := DXCore.AcquireSwapChainElement(0, FSwapChainIndex);
end;

procedure TTable.SetupLiveTable(const AClub: TClubInfo; const AGame: TGameInfo; const ASendJoinCommand: Boolean);
var
  form: TfrmTable;
begin
  FTableType := ttLiveGame;
  FSeatIndex := -1;
  FGameId := AGame.MongoId;
  FClubId := AClub.MongoId;
  FClubSeq := AClub.Id;
  FGame := AGame;
  FClub := AClub;
  FRenderer := TTableRenderer.Create(FSwapChainIndex, FGame, ttLiveGame);
  form := TfrmTable.Create(self);
  FRenderer.SetRenderTarget(form.Handle);
  FForm := form;
  DXCore.ModifySwapChainElement(FSwapChainIndex, FForm.Handle);
  if ASendJoinCommand then
    ServerSocket.JoinTable(FGame.MongoId);
  FRenderer.UpdateDXAreaSize;
end;

procedure TTable.SetupHandHistoryTable(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);
var
  form: TfrmTable;
begin
  FTableType := ttHandPlayback;
  FSeatIndex := -1;
  FGameId := AHandHistoryItems.FGameId;
  FHandId := AHandHistoryItem.HandId;
  FGame := AHandHistoryItems.Game;
  FClub := AHandHistoryItems.Club;
  FHandHistoryPlayback := THandHistoryPlayback.Create(AHandHistoryItems, AHandHistoryItem);
  FRenderer := TTableRenderer.Create(FSwapChainIndex, FGame, ttHandPlayback);
  form := TfrmTable.Create(self);
  FRenderer.SetRenderTarget(form.Handle);
  FForm := form;
  DXCore.ModifySwapChainElement(FSwapChainIndex, FForm.Handle);
  FRenderer.UpdateDXAreaSize;
end;

procedure TTable.SetupSettingsPreviewTable(const AHandle: THandle);
var
  tablestatus: TTableStatus;
begin
  FTableType := ttSettingsPreview;
  FSeatIndex := -1;
  FClub := TClubInfo.Create;
  FClub.InitToDemoValues;
  FGame := TGameInfo.Create;
  FGame.InitToDemoValues(FClub.Id);
  FClub.Games.Add(FGame);
  tablestatus := TTableStatus.Create;
  tablestatus.InitToDemoValues;
  FRenderer := TTableRenderer.Create(FSwapChainIndex, FGame, ttSettingsPreview);
  FRenderer.SetRenderTarget(AHandle);
  FRenderer.UpdateTableStatus(tablestatus);
  FRenderer.FlopAnimated := TRUE;
  DXCore.ModifySwapChainElement(FSwapChainIndex, AHandle);
  FRenderer.UpdateDXAreaSize;
end;

function TTable.IsSitting: Boolean;
begin
  result := FSeatIndex <> -1;
end;

procedure TTable.BringToFront;
begin
  if IsIconic(FForm.Handle) then
    ShowWindow(FForm.Handle, SW_RESTORE);
  FForm.Show;
end;

procedure TTable.ReassignObjects(const AClub: TClubInfo; const AGame: TGameInfo);
begin
  FClub := AClub;
  FGame := AGame;
  FRenderer.Game := FGame;
end;

function TTable.ReassignObjects(const AGameId: TBytes): Boolean;
var
  club: TClubInfo;
  game: TGameInfo;
begin
  for club in dmMain.SelfInfo.Clubs do
    for game in club.Games do
      if CompareBytes(game.MongoId, AGameId) then
      begin
        ReassignObjects(club, game);
        Exit(TRUE);
      end;
  Exit(FALSE);
end;

procedure TTable.UpdateAvatars(const AAvatar: TAvatar);
begin
  TSyncRenderer.Render(FRenderer);
end;

{ TTables }

class procedure TTables.Initialize;
begin
  Tables := TTables.Create;
end;

class procedure TTables.Deinitialize;
begin
  FreeAndNil(Tables);
end;

function TTables.AddTable(const AClub: TClubInfo; const AGame: TGameInfo; const AShow: Boolean; const ASendJoinCommand: Boolean): TTable;
var
  table: TTable;
begin
  if FindTable(AGame.MongoId, table) then
  begin
    if AShow then
      table.BringToFront;
    Exit(table);
  end;

  table := TTable.Create;
  if not table.AcquireSwapChainElement then
  begin
    FreeAndNil(table);
    Exit(nil);
  end;

  Add(table);

  table.SetupLiveTable(AClub, AGame, ASendJoinCommand);
  if AShow then
    table.BringToFront;

  result := table;
end;

function TTables.AddHandPlaybackTable(const AGameId: TBytes; const AHandId: UINT): TTable;
var
  table: TTable;
  hhis: THandHistoryItems;
  hhi: THandHistoryItem;
begin
  if (not HandHistory.FindGame(AGameId, hhis)) or
     (not hhis.FindHand(AHandId, hhi)) then
    Exit(nil);

  table := TTable.Create;
  if not table.AcquireSwapChainElement then
  begin
    FreeAndNil(table);
    Exit(nil);
  end;

  Add(table);

  table.SetupHandHistoryTable(hhis, hhi);
  table.BringToFront;

  result := table;
end;

function TTables.AddSettingsPreviewTable(const AHandle: THandle): TTable;
var
  table: TTable;
begin
  table := TTable.Create;
  if not table.AcquireSwapChainElement then
  begin
    FreeAndNil(table);
    Exit(nil);
  end;

  Add(table);
  table.SetupSettingsPreviewTable(AHandle);

  result := table;
end;

procedure TTables.ReassignObjects;
var
  table: TTable;
  club: TClubInfo;
  game: TGameInfo;
begin
  for table in ToArray do
    if (dmMain.SelfInfo.Clubs.FindClub(table.ClubSeq, club)) and
       (club.Games.FindGame(table.GameId, game)) then
      table.ReassignObjects(game.MongoId)
end;

function TTables.SittingCount: Integer;
var
  C1: Integer;
begin
  result := 0;
  for C1 := 0 to Length(ToArray) - 1 do
    if ToArray[C1].IsSitting then
      Inc(result);
end;

function TTables.IndexOf(const AGameId: TBytes): Integer;
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    if CompareBytes(AGameId, ToArray[C1].Game.MongoId) then
      Exit(C1);
  Exit(-1);
end;

procedure TTables.CloseTablesForClub(const AClubId: TBytes);
var
  C1: Integer;
begin
 for C1 := Length(ToArray) - 1 downto 0 do
   if CompareBytes(ToArray[C1].Club.MongoId, AClubId)  then
   begin
     Delete(C1);
     Break;
   end;
end;

function TTables.FindTable(const AGameId: TBytes; var ATable: TTable): Boolean;
var
  index: Integer;
begin
  index := IndexOf(AGameId);
  if index = -1 then
    Exit(FALSE);
  ATable := ToArray[index];
  Exit(TRUE);
end;

procedure TTables.DisableAll;
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    EnableWindow(ToArray[C1].Form.Handle, FALSE);
end;

procedure TTables.EnableAll;
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    EnableWindow(ToArray[C1].Form.Handle, TRUE);
end;

end.
