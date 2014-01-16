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

    function AddTable(const ATableId: String): Boolean;

    procedure NotifyClose(const ATableId: String);
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

function TTables.AddTable(const ATableId: String): Boolean;
var
  table: TTable;
begin
  table := TTable.Create(self, ATableId);
  table.Form.Show;
  FTables.Add(table);
  result := TRUE;
end;

procedure TTables.NotifyClose(const ATableId: String);
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
