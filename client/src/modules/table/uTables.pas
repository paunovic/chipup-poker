unit uTables;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections, uGameInfo,
  uClubInfo, Vcl.Forms;

type
  TTable = class
  private
    FForm          : TForm;
    FSeatIndex     : Integer;
    FGame          : TGameInfo;
    FClub          : TClubInfo;
    FSwapChainIndex: Integer;

  public
    constructor Create(const AClub: TClubInfo; const AGame: TGameInfo; const ASwapChainIndex: Integer);
    destructor Destroy; override;

    procedure NotifyClose;
    function IsSitting: Boolean;

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

    function AddTable(const AClub: TClubInfo; const AGame: TGameInfo): Boolean;
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
  Vcl.Controls, uTableForm, uCommon, uSocketClient, uDXCore, Vectors2px;


constructor TTable.Create(const AClub: TClubInfo; const AGame: TGameInfo; const ASwapChainIndex: Integer);
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
  SocketClient.JoinTable(FGame.MongoId);
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

function TTables.AddTable(const AClub: TClubInfo; const AGame: TGameInfo): Boolean;
var
  table: TTable;
  sci  : Integer;
begin
  if not FindTable(AGame.MongoId, table) then
  begin
    sci := DXCore.GetFreeSwapChain;
    if sci = -1 then
      Exit(FALSE);

    table := TTable.Create(AClub, AGame, sci);
    table.Form.Show;
    Add(table);
  end
  else
  begin
    if IsIconic(table.Form.Handle) then
      ShowWindow(table.Form.Handle, SW_RESTORE);
    table.Form.BringToFront;
  end;
  result := TRUE;
end;

procedure TTables.NotifyClose(const AGameId: TBytes);
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    if ToArray[C1].Game.MongoId = AGameId then
    begin
      if FNotifyServer then
        SocketClient.LeaveTable(AGameId);
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
  C1      : Integer;
  game_len: Integer;
begin
  game_len := Length(AGameId);
  for C1 := 0 to Length(ToArray) - 1 do
    if CompareBytes(AGameId, ToArray[C1].Game.MongoId, game_len) then
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



end.
