unit Poker.Table.Tables;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections, Poker.Objects.GameInfo, Poker.Protobufs.Objects.TableStatus,
  Poker.Objects.ClubInfo, Vcl.Forms, Poker.Avatars;

type
  TTable = class
  private
    FForm: TForm;
    FSeatIndex: Integer;
    FGame: TGameInfo;
    FClub: TClubInfo;
    FSwapChainIndex: Integer;

  public
    constructor Create(const AClub: TClubInfo; const AGame: TGameInfo; const ASwapChainIndex: Integer; const ASendJoinCommand: Boolean);
    destructor Destroy; override;

    procedure NotifyClose;
    function IsSitting: Boolean;

    procedure UpdateAvatars(const AAvatar: TAvatar);

    function ReassignObjects(const AGameId: TBytes): Boolean;

    procedure BringToFront;

    property Game          : TGameInfo read FGame;
    property Club          : TClubInfo read FClub;
    property Form          : TForm read FForm;
    property SeatIndex     : Integer read FSeatIndex write FSeatIndex;
    property SwapChainIndex: Integer read FSwapChainIndex;
  end;

  TTables = class(TObjectList<TTable>)
  var
    FNotifyServer: Boolean;
  public
    class procedure Initialize;
    class procedure Deinitialize;

    constructor Create;

    procedure DisableAll;
    procedure EnableAll;

    function AddTable(const AClub: TClubInfo; const AGame: TGameInfo; const AShow: Boolean; const ASendJoinCommand: Boolean): TTable;
    procedure NotifyClose(const AGameId: TBytes);
    function SittingCount: Integer;
    function IndexOf(const AGameId: TBytes): Integer;
    function FindTable(const AGameId: TBytes; var ATable: TTable): Boolean;
    procedure ClearWithoutNotification;
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
  FSeatIndex := -1;
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

destructor TTable.Destroy;
begin
  FForm.Free;

  inherited;
end;

function TTable.IsSitting: Boolean;
begin
  result := FSeatIndex <> -1;
end;

procedure TTable.NotifyClose;
begin
  Tables.NotifyClose(FGame.MongoId);
end;

procedure TTable.BringToFront;
begin
  if IsIconic(FForm.Handle) then
    ShowWindow(FForm.Handle, SW_RESTORE);
  FForm.Show;
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
  FNotifyServer := TRUE;
end;


function TTables.AddTable(const AClub: TClubInfo; const AGame: TGameInfo; const AShow: Boolean; const ASendJoinCommand: Boolean): TTable;
var
  table: TTable;
  sci  : Integer;
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

procedure TTables.NotifyClose(const AGameId: TBytes);
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    if ToArray[C1].Game.MongoId = AGameId then
    begin
      if FNotifyServer then
        ServerSocket.LeaveTable(AGameId);
      DXCore.ReleaseSwapChain(ToArray[C1].SwapChainIndex);
      Delete(C1);
      Exit;
    end;
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

procedure TTables.ClearWithoutNotification;
begin
  FNotifyServer := FALSE;
  Clear;
  FNotifyServer := TRUE;
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
