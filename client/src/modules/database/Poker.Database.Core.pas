unit Poker.Database.Core;

interface

uses
  System.SysUtils, System.Classes, SynSQLite3Static, SynCommons, SynDB, SynDBSQLite3, Poker.Protobufs.Objects.Game,
  System.Generics.Collections;

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

    procedure InsertTable(const AConnection: TSQLDBSQLite3ConnectionProperties; const AGame: TPB_Game);

    procedure InsertAvatar(const AConnection: TSQLDBSQLite3ConnectionProperties; const AId: TBytes; const AData: TMemoryStream);
    function RetrieveAvatarData(const AConnection: TSQLDBSQLite3ConnectionProperties; const AId: TBytes; const AData: TMemoryStream): Boolean;

    procedure RetrieveTableList(const AConnection: TSQLDBSQLite3ConnectionProperties; const AClubId: TBytes; const ATables: TList<RawByteString>);
  end;

var
  Database: TDatabase;

implementation

uses
  Poker.Common.Misc;


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
  ExecuteNoResult(AConnection, 'CREATE INDEX IF NOT EXISTS clubid_idx ON hands(clubid)');

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

procedure TDatabase.InsertTable(const AConnection: TSQLDBSQLite3ConnectionProperties; const AGame: TPB_Game);
var
  query  : TSQLDBStatement;
  mstream: TMemoryStream;
begin
  query := AConnection.NewThreadSafeStatement;
  try
    query.Prepare('INSERT OR REPLACE INTO tables (id, data) VALUES (?, ?)', FALSE);
    query.BindBlob(1, @AGame.MongoId[0], Length(AGame.MongoId) * SizeOf(Byte));
    mstream := TMemoryStream.Create;
    try
      AGame.ProtobufOutput.SaveToStream(mstream);
      query.BindBlob(2, mstream.Memory, mstream.Size);
      query.ExecutePrepared;
    finally
      mstream.Free;
    end;
  finally
    query.Free;
  end;
end;

procedure TDatabase.RetrieveTableList(const AConnection: TSQLDBSQLite3ConnectionProperties; const AClubId: TBytes; const ATables: TList<RawByteString>);
var
  query: TSQLDBStatement;
begin
  query := AConnection.NewThreadSafeStatement;
  try
    query.Prepare('SELECT DISTINCT gameid FROM hands WHERE clubid = ?', TRUE);
    query.BindBlob(1, @AClubId[0], Length(AClubId) * SizeOf(Byte));
    query.ExecutePrepared;
    while query.Step do
      ATables.Add(query.ColumnBlob(0));
  finally
    query.Free;
  end;
end;

end.
