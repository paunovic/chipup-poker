unit Poker.Database.Core;

interface

uses
  System.SysUtils, System.Classes, SynCommons, SynDB, SynDBSQLite3;

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

    function LastHandId(const AConnection: TSQLDBSQLite3ConnectionProperties; const AGameId: TBytes): UINT32;
    procedure InsertHand(const AConnection: TSQLDBSQLite3ConnectionProperties; const AId: UINT32; const AClubId, AGameId: TBytes; const ATimestamp: UINT32; const AData: TMemoryStream);

    procedure InsertAvatar(const AConnection: TSQLDBSQLite3ConnectionProperties; const AId: TBytes; const AData: TMemoryStream);
    function RetrieveAvatarData(const AConnection: TSQLDBSQLite3ConnectionProperties; const AId: TBytes; const AData: TMemoryStream): Boolean;
  end;

var
  Database: TDatabase;

implementation

uses
  Poker.Common.Misc, SQLite3Commons;


class procedure TDatabase.Initialize(const ADatabasePath: String);
begin
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
    CreateTables(conn);;
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
  ExecuteNoResult(AConnection, 'CREATE TABLE IF NOT EXISTS hands (id INTEGER PRIMARY KEY, clubid BLOB, gameid BLOB, timestamp INTEGER, data BLOB)');
  ExecuteNoResult(AConnection, 'CREATE INDEX IF NOT EXISTS gameid_idx ON hands(gameid)');

  ExecuteNoResult(AConnection, 'CREATE TABLE IF NOT EXISTS avatars (id BLOB, data BLOB)');
  ExecuteNoResult(AConnection, 'CREATE UNIQUE INDEX IF NOT EXISTS id_idx ON avatars(id)');
end;

function TDatabase.LastHandId(const AConnection: TSQLDBSQLite3ConnectionProperties; const AGameId: TBytes): UINT32;
var
  query: TSQLDBStatement;
begin
  result := 0;
  query := AConnection.NewThreadSafeStatement;
  try
    query.Prepare('SELECT MAX(id) FROM hands WHERE gameid = ?', TRUE);
    query.BindBlob(1, @AGameId[0], Length(AGameId) * SizeOf(Byte));
    query.ExecutePrepared;
    if query.Step then
      result := query.ColumnInt(0);
  finally
    query.Free;
  end;
end;

procedure TDatabase.InsertHand(const AConnection: TSQLDBSQLite3ConnectionProperties; const AId: UINT32; const AClubId, AGameId: TBytes; const ATimestamp: UINT32; const AData: TMemoryStream);
var
  query: TSQLDBStatement;
begin
  query := AConnection.NewThreadSafeStatement;
  try
    query.Prepare('INSERT OR REPLACE INTO hands (id, clubid, gameid, timestamp, data) VALUES (?, ?, ?, ?, ?)', FALSE);
    query.Bind(1, AId);
    query.BindBlob(2, @AClubId[0], Length(AClubId) * SizeOf(Byte));
    query.BindBlob(3, @AGameId[0], Length(AGameId) * SizeOf(Byte));
    query.Bind(4, ATimestamp);
    query.BindBlob(5, AData.Memory, AData.Size);
    query.ExecutePrepared;
  finally
    query.Free;
  end;
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
    query.Prepare('SELECT id, data FROM avatars WHERE id = ?', TRUE);
    query.BindBlob(1, @AId[0], Length(AId) * SizeOf(Byte));
    query.ExecutePrepared;
    if query.Step then
    begin
      rbs := query.ColumnBlob('data');
      AData.Clear;
      AData.WriteBuffer(rbs[1], Length(rbs));
      result := TRUE;
    end;
  finally
    query.Free;
  end;
end;



end.
