unit uTables;

interface

uses
  Winapi.Windows, System.Generics.Collections, System.Classes,
  uTable, uGameInfo, uClubInfo;

type
  TTables = class(TObjectList<TTable>)
  public
    function AddTable(const AClub: TClubInfo; const AGame: TGameInfo): Boolean;
    procedure NotifyClose(const ATableId: String);
    function SittingCount: Integer;
  end;

implementation


function TTables.AddTable(const AClub: TClubInfo; const AGame: TGameInfo): Boolean;
var
  table: TTable;
begin
  table := TTable.Create(self, AClub, AGame);
  table.Form.Show;
  Add(table);
  result := TRUE;
end;

procedure TTables.NotifyClose(const ATableId: String);
var
  C1: Integer;
begin
  for C1 := 0 to Length(ToArray) - 1 do
    if ToArray[C1].Game.MongoId = ATableId then
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

end.
