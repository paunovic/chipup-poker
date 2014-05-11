unit Poker.Database.Core;

interface

uses
  System.SysUtils, System.Classes, SynCommons, SynDB, SynSQLite3, SynDBSQLite3, System.Generics.Collections;

type
  TDatabase = class
  private
    FDatabasePath: RawUTF8;

    procedure CreateTables(const AConnection: TSQLDBSQLite3ConnectionProperties);

  public
    class procedure Initialize(const ADatabasePath: String);
    class procedure Deinitialize;

    constructor Create(const ADatabasePath: String);
    destructor Destroy; override;

    function NewConnection: TSQLDBSQLite3ConnectionProperties;

    function Execute(const AConnection: TSQLDBSQLite3ConnectionProperties; const AQuery: String): ISQLDBRows;
    procedure ExecuteNoResult(const AConnection: TSQLDBSQLite3ConnectionProperties; const AQuery: String);

    procedure InsertAvatar(const AConnection: TSQLDBSQLite3ConnectionProperties; const AId: TBytes; const AData: TMemoryStream);
    function RetrieveAvatarData(const AConnection: TSQLDBSQLite3ConnectionProperties; const AId: TBytes; const AData: TMemoryStream): Boolean;
  end;

var
  Database: TDatabase;

implementation

uses
  Poker.Common.Misc;


class procedure TDatabase.Initialize(const ADatabasePath: String);
begin
  sqlite3 := TSQLite3LibraryDynamic.Create;

  Database := TDatabase.Create(ADatabasePath);
end;

class procedure TDatabase.Deinitialize;
begin
  FreeAndNil(Database);
end;

constructor TDatabase.Create(const ADatabasePath: String);
var
  conn: TSQLDBSQLite3ConnectionProperties;
begin
  FDatabasePath := StringToUTF8(ADatabasePath);

  conn := NewConnection;
  try
    CreateTables(conn);
  finally
    conn.Free;
  end;
end;

destructor TDatabase.Destroy;
begin
  inherited;
end;

function TDatabase.NewConnection: TSQLDBSQLite3ConnectionProperties;
begin
  result := TSQLDBSQLite3ConnectionProperties.Create(FDatabasePath, '', '', '');
end;

procedure TDatabase.ExecuteNoResult(const AConnection: TSQLDBSQLite3ConnectionProperties; const AQuery: String);
begin
  AConnection.ExecuteNoResult(StringToUTF8(AQuery), []);
end;

function TDatabase.Execute(const AConnection: TSQLDBSQLite3ConnectionProperties; const AQuery: String): ISQLDBRows;
begin
  result := AConnection.Execute(StringToUTF8(AQuery), []);
end;

procedure TDatabase.CreateTables(const AConnection: TSQLDBSQLite3ConnectionProperties);
begin
  ExecuteNoResult(AConnection, 'PRAGMA page_size = 4096');

  ExecuteNoResult(AConnection, 'CREATE TABLE IF NOT EXISTS hands (id INTEGER PRIMARY KEY, clubid BLOB, gameid BLOB, timestamp INTEGER, data BLOB)');
  ExecuteNoResult(AConnection, 'CREATE INDEX IF NOT EXISTS gameid_idx ON hands(gameid)');
  ExecuteNoResult(AConnection, 'CREATE INDEX IF NOT EXISTS clubid_idx ON hands(clubid, gameid)');

  ExecuteNoResult(AConnection, 'CREATE TABLE IF NOT EXISTS avatars (id BLOB, data BLOB)');
  ExecuteNoResult(AConnection, 'CREATE UNIQUE INDEX IF NOT EXISTS id_idx ON avatars(id)');
end;

procedure TDatabase.InsertAvatar(const AConnection: TSQLDBSQLite3ConnectionProperties; const AId: TBytes; const AData: TMemoryStream);
var
  query: TSQLDBStatement;
begin
  query := AConnection.NewThreadSafeStatement;
  try
    query.Prepare('INSERT OR REPLACE INTO avatars (id, data) VALUES (?, ?)', FALSE);
    query.BindBlob(1, @AId[0], Length(AId) * SizeOf(Byte));
    query.BindBlob(2, AData.Memory, AData.Size);
    query.ExecutePrepared;
  finally
    query.Free;
  end;
end;

function TDatabase.RetrieveAvatarData(const AConnection: TSQLDBSQLite3ConnectionProperties; const AId: TBytes; const AData: TMemoryStream): Boolean;
var
  query: TSQLDBStatement;
  rbs  : RawByteString;
begin
  result := FALSE;
  query := AConnection.NewThreadSafeStatement;
  try
    query.Prepare('SELECT data FROM avatars WHERE id = ?', TRUE);
    query.BindBlob(1, @AId[0], Length(AId) * SizeOf(Byte));
    query.ExecutePrepared;
    if query.Step then
    begin
      rbs := query.ColumnBlob(0);
      AData.Clear;
      AData.WriteBuffer(rbs[1], Length(rbs));
      result := TRUE;
    end;
  finally
    query.Free;
  end;
end;

end.
