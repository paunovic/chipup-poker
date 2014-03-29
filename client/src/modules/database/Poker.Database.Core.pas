unit Poker.Database.Core;

interface

uses
  System.SysUtils, SynCommons, SynDB, SynDBSQLite3;

type
  TDatabase = class
  private
    FDatabasePath: RawUTF8;
    FConnection  : TSQLDBSQLite3ConnectionProperties;

    procedure CreateTables;

  public
    class procedure Initialize(const ADatabasePath: String);
    class procedure Deinitialize;

    constructor Create(const ADatabasePath: String);
    destructor Destroy; override;

    function Connect: Boolean;
    procedure Disconnect;

    function Execute(const AQuery: String; const AParams: array of const): ISQLDBRows;
    procedure ExecuteNoResult(const AQuery: String; const AParams: array of const);

    function LastHandId(const AClubId: TBytes): UINT32;
  end;

var
  Database: TDatabase;

implementation


class procedure TDatabase.Initialize(const ADatabasePath: String);
begin
  Database := TDatabase.Create(ADatabasePath);
end;

class procedure TDatabase.Deinitialize;
begin
  FreeAndNil(Database);
end;

constructor TDatabase.Create(const ADatabasePath: String);
begin
  FDatabasePath := StringToUTF8(ADatabasePath);

  CreateTables;
end;

destructor TDatabase.Destroy;
begin

  inherited;
end;

function TDatabase.Connect: Boolean;
begin
  FConnection := TSQLDBSQLite3ConnectionProperties.Create(FDatabasePath, '', '', '');
  result := TRUE;
end;

procedure TDatabase.Disconnect;
begin
  FreeAndNil(FConnection);
end;

procedure TDatabase.ExecuteNoResult(const AQuery: String; const AParams: array of const);
begin
  FConnection.ExecuteNoResult(StringToUTF8(AQuery), AParams);
end;

function TDatabase.Execute(const AQuery: String; const AParams: array of const): ISQLDBRows;
begin
  result := FConnection.Execute(StringToUTF8(AQuery), []);
end;

procedure TDatabase.CreateTables;
begin
  if Connect then
    try
      ExecuteNoResult('CREATE TABLE IF NOT EXISTS hands (id INTEGER PRIMARY KEY, clubid BLOB, gameid BLOB, timestamp INTEGER, data BLOB)', []);
    finally
      Disconnect;
    end;
end;

function TDatabase.LastHandId(const AClubId: TBytes): UINT32;
var
  rows: ISQLDBRows;
begin
  result := 0;
  rows := Execute('SELECT MAX(id) FROM hands WHERE clubid = ?', [AClubId]);
  while rows.Step do
    result := rows.ColumnInt('MAX(id)');
end;


end.
