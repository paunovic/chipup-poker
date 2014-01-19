unit uTables;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections, uGameInfo,
  uClubInfo, Vcl.Forms;

type
  TTable = class
  private
    FForm        : TForm;
    FSeatIndex   : Integer;
    FGame        : TGameInfo;
    FClub        : TClubInfo;
    FTablesObject: TObject;

  public
    constructor Create(const ATablesObject: TObject; const AClub: TClubInfo; const AGame: TGameInfo);
    destructor Destroy; override;

    procedure NotifyClose;
    function IsSitting: Boolean;

    property Game     : TGameInfo read FGame;
    property Club     : TClubInfo read FClub;
    property Form     : TForm read FForm;
    property SeatIndex: Integer read FSeatIndex write FSeatIndex;
  end;

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
  Vcl.Controls, uTableForm, uCommon;


constructor TTable.Create(const ATablesObject: TObject; const AClub: TClubInfo; const AGame: TGameInfo);
begin
  FSeatIndex := -1;
  FGame := AGame;
  FClub := AClub;
  FTablesObject := ATablesObject;
  FForm := TfrmTable.Create(self);
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
  (FTablesObject as TTables).NotifyClose(FGame.MongoId);
end;



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
