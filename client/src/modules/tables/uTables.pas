unit uTables;

interface

uses
  Winapi.Windows, System.Generics.Collections, System.Classes,
  uTable;

type
  TTables = class
  private
    FTables: TObjectList<TTable>;

  public
    constructor Create;
    destructor Destroy; override;

    function AddTable(const ATableId: DWORD): Boolean;

    procedure NotifyClose(const ATableId: DWORD);
  end;

implementation


constructor TTables.Create;
begin

  FTables := TObjectList<TTable>.Create;
end;

destructor TTables.Destroy;
begin
  FTables.Free;

  inherited;
end;

function TTables.AddTable(const ATableId: DWORD): Boolean;
var
  table: TTable;
begin
  table := TTable.Create(self, ATableId);
  table.Form.Show;
  FTables.Add(table);
  result := TRUE;
end;

procedure TTables.NotifyClose(const ATableId: DWORD);
var
  C1: Integer;
begin
  for C1 := 0 to FTables.Count - 1 do
    if FTables[C1].Id = ATableId then
    begin
      FTables.Delete(C1);
      Exit;
    end;
end;


end.
