unit uTables;

interface

uses
  Winapi.Windows, System.Generics.Collections, System.Classes, System.SysUtils,
  uTable, uGameInfo, uClubInfo;

type
  TTables = class(TObjectList<TTable>)
  public
    function AddTable(const AClub: TClubInfo; const AGame: TGameInfo): Boolean;
    procedure NotifyClose(const AGameId: TBytes);
    function SittingCount: Integer;
    function IndexOf(const AGameId: TBytes): Integer;
    function FindTable(const AGameId: TBytes; var ATable: TTable): Boolean;
  end;

implementation

uses
  uCommon;


function TTables.AddTable(const AClub: TClubInfo; const AGame: TGameInfo): Boolean;
var
  table: TTable;
begin
  if not FindTable(AGame.MongoId, table) then
  begin
    table := TTable.Create(self, AClub, AGame);
    table.Form.Show;
    Add(table);
  end
  else
    table.Form.BringToFront;
  result := TRUE;
end;

procedure TTables.NotifyClose(const AGameId: TBytes);
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    if ToArray[C1].Game.MongoId = AGameId then
    begin
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
