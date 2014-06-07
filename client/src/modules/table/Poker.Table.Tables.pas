unit Poker.Table.Tables;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections, Poker.Objects.GameInfo, Poker.Protobufs.Objects.TableStatus,
  Poker.Objects.ClubInfo, Vcl.Forms, Poker.Avatars, Poker.HandHistory.HandHistoryItem;

type
  TTableType = (ttLiveGame, ttHandPlayback);

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
    FSwapChainIndex: Integer;

  public
    constructor Create(const AClub: TClubInfo; const AGame: TGameInfo; const ASwapChainIndex: Integer; const ASendJoinCommand: Boolean); overload;
    constructor Create(const AGameId: TBytes; const AHandId: UINT; const ASwapChainIndex: Integer); overload;
    destructor Destroy; override;

    procedure NotifyClose(const ANotifyServer: Boolean);
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
  end;

  TTables = class(TObjectList<TTable>)
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;

    procedure DisableAll;
    procedure EnableAll;

    procedure ReassignObjects;

    function AddTable(const AClub: TClubInfo; const AGame: TGameInfo; const AShow: Boolean; const ASendJoinCommand: Boolean): TTable;
    function AddHandPlaybackTable(const AGameId: TBytes; const AHandId: UINT): TTable;
    procedure NotifyClose(const AGameId: TBytes; const ANotifyServer: Boolean);
    function SittingCount: Integer;
    function IndexOf(const AGameId: TBytes): Integer;
    function FindTable(const AGameId: TBytes; var ATable: TTable): Boolean;
    procedure CloseTablesForClub(const AClubId: TBytes);
  end;

var
  Tables: TTables;


implementation

uses
  Vcl.Controls, Poker.Forms.Table, Poker.Common.Misc, Poker.Server.Socket, Poker.DirectX.Core, Vectors2px, Poker.DataModule;

{ TTable }

constructor TTable.Create(const AClub: TClubInfo; const AGame: TGameInfo; const ASwapChainIndex: Integer; const ASendJoinCommand: Boolean);
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
  FSwapChainIndex := ASwapChainIndex;
  form := TfrmTable.Create(self);
  FForm := form;
  DXCore.AcquireSwapChain(FSwapChainIndex, form.Handle);
  DXCore.Device.Resize(FSwapChainIndex, Point2px(form.ClientWidth, form.ClientHeight));

  if ASendJoinCommand then
    ServerSocket.JoinTable(FGame.MongoId);
end;

constructor TTable.Create(const AGameId: TBytes; const AHandId: UINT; const ASwapChainIndex: Integer);
var
  form: TfrmTable;
begin
  FTableType := ttHandPlayback;
  FSeatIndex := -1;
  FSwapChainIndex := ASwapChainIndex;
  FGameId := AGameId;
  FHandId := AHandId;
  form := TfrmTable.Create(self);
  FForm := form;
  DXCore.AcquireSwapChain(FSwapChainIndex, form.Handle);
  DXCore.Device.Resize(FSwapChainIndex, Point2px(form.ClientWidth, form.ClientHeight));
end;

destructor TTable.Destroy;
begin
  FForm.Free;
  inherited;
end;

function TTable.IsSitting: Boolean;
begin
  result := FSeatIndex <> -1;
end;

procedure TTable.NotifyClose(const ANotifyServer: Boolean);
begin
  Tables.NotifyClose(FGame.MongoId, ANotifyServer);
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
        FClub := club;
        FGame := game;
        Exit(TRUE);
      end;
  Exit(FALSE);
end;

procedure TTable.UpdateAvatars(const AAvatar: TAvatar);
begin
  TTableSyncRender.Render(FForm as TfrmTable);
end;

{ TTables }

class procedure TTables.Initialize;
begin
  Tables := TTables.Create;
end;

class procedure TTables.Deinitialize;
begin
  Tables.Free;
end;

constructor TTables.Create;
begin
  inherited Create;
end;

function TTables.AddTable(const AClub: TClubInfo; const AGame: TGameInfo; const AShow: Boolean; const ASendJoinCommand: Boolean): TTable;
var
  table: TTable;
  sci: Integer;
begin
  if not FindTable(AGame.MongoId, table) then
  begin
    sci := DXCore.GetFreeSwapChain;
    if sci = -1 then
      Exit(nil);

    table := TTable.Create(AClub, AGame, sci, ASendJoinCommand);
    if AShow then
      table.Form.Show;
    Add(table);
  end
  else
    if AShow then
      table.BringToFront;

  result := table;
end;

function TTables.AddHandPlaybackTable(const AGameId: TBytes; const AHandId: UINT): TTable;
var
  table: TTable;
  sci: Integer;
begin
  sci := DXCore.GetFreeSwapChain;
  if sci = -1 then
    Exit(nil);

  table := TTable.Create(AGameId, AHandId, sci);
  table.Form.Show;
  Add(table);
  table.BringToFront;

  result := table;
end;


procedure TTables.NotifyClose(const AGameId: TBytes; const ANotifyServer: Boolean);
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    if ToArray[C1].Game.MongoId = AGameId then
    begin
      if ANotifyServer then
        ServerSocket.LeaveTable(AGameId);
      DXCore.ReleaseSwapChain(ToArray[C1].SwapChainIndex);
      Delete(C1);
      Exit;
    end;
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
