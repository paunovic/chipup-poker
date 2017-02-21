unit Poker.Database.Core;

interface

uses
  System.SysUtils, System.Classes, SynCommons, SynDB, SynSQLite3, SynDBSQLite3;

type
  TDatabase = class
  private
    const
      BLOB_ID_SETTINGS = 1;

    var
      FDatabasePath: String;
      FDatabasePassword: String;
      FConnection: TSQLDBSQLite3ConnectionProperties;

    procedure Connect;
  public
    class procedure Initialize(const ADatabasePath, ADatabasePassword: String);
    class procedure Deinitialize;

    constructor Create(const ADatabasePath, ADatabasePassword: String);
    destructor Destroy; override;

    function Execute(const AQuery: String): ISQLDBRows;
    procedure ExecuteNoResult(const AQuery: String);
    procedure InsertAvatar(const AId: TBytes; const AData: TMemoryStream);
    function RetrieveAvatar(const AId: TBytes): RawByteString;
    procedure SaveBlob(const ABlobId: Integer; const ABlob: RawByteString);
    procedure SaveSettings(const ASettingsBlob: RawByteString);
    function GetBlob(const ABlobId: Integer): RawByteString;
    function GetSettingsBlob: RawByteString;
  end;

var
  Database: TDatabase;

implementation

class procedure TDatabase.Initialize(const ADatabasePath, ADatabasePassword: String);
begin
  Database := TDatabase.Create(ADatabasePath, ADatabasePassword);
end;

class procedure TDatabase.Deinitialize;
begin
  FreeAndNil(Database);
end;

constructor TDatabase.Create(const ADatabasePath, ADatabasePassword: String);
begin
  FDatabasePath := ADatabasePath;
  FDatabasePassword := ADatabasePassword;
  Connect;
end;

destructor TDatabase.Destroy;
begin
  FreeAndNil(FConnection);
  inherited;
end;

procedure TDatabase.Connect;
begin
  FConnection := TSQLDBSQLite3ConnectionProperties.Create(StringToUTF8(FDatabasePath), '', '', StringToUTF8(FDatabasePassword));
  FConnection.MainSQLite3DB.Synchronous := smNormal;
  FConnection.MainSQLite3DB.LockingMode := lmExclusive;
  FConnection.MainSQLite3DB.PageSize := 4096;

  ExecuteNoResult('CREATE TABLE IF NOT EXISTS blobs (id INTEGER PRIMARY KEY, data BLOB)');
  ExecuteNoResult('CREATE UNIQUE INDEX IF NOT EXISTS id_idx ON blobs(id)');

  ExecuteNoResult('CREATE TABLE IF NOT EXISTS avatars (id BLOB, data BLOB)');
  ExecuteNoResult('CREATE UNIQUE INDEX IF NOT EXISTS id_idx ON avatars(id)');

  ExecuteNoResult('CREATE TABLE IF NOT EXISTS hands (id INTEGER PRIMARY KEY, clubid BLOB, gameid BLOB, timestamp INTEGER, data BLOB)');
  ExecuteNoResult('CREATE INDEX IF NOT EXISTS gameid_idx ON hands(gameid)');
  ExecuteNoResult('CREATE INDEX IF NOT EXISTS clubid_idx ON hands(clubid, gameid)');
end;

procedure TDatabase.ExecuteNoResult(const AQuery: String);
begin
  FConnection.ExecuteNoResult(StringToUTF8(AQuery), []);
end;

function TDatabase.Execute(const AQuery: String): ISQLDBRows;
begin
  result := FConnection.Execute(StringToUTF8(AQuery), []);
end;

procedure TDatabase.InsertAvatar(const AId: TBytes; const AData: TMemoryStream);
var
  query: TSQLDBStatement;
begin
  query := FConnection.NewThreadSafeStatement;
  try
    query.Prepare('INSERT OR REPLACE INTO avatars (id, data) VALUES (?, ?)', FALSE);
    query.BindBlob(1, @AId[0], Length(AId) * SizeOf(Byte));
    query.BindBlob(2, AData.Memory, AData.Size);
    query.ExecutePrepared;
  finally
    query.Free;
  end;
end;

function TDatabase.RetrieveAvatar(const AId: TBytes): RawByteString;
var
  query: TSQLDBStatement;
begin
  result := '';
  query := FConnection.NewThreadSafeStatement;
  try
    query.Prepare('SELECT data FROM avatars WHERE id = ?', TRUE);
    query.BindBlob(1, @AId[0], Length(AId) * SizeOf(Byte));
    query.ExecutePrepared;
    if query.Step then
      result := query.ColumnBlob(0);
  finally
    query.Free;
  end;
end;

procedure TDatabase.SaveBlob(const ABlobId: Integer; const ABlob: RawByteString);
var
  query: TSQLDBStatement;
begin
  query := FConnection.NewThreadSafeStatement;
  try
    query.Prepare('INSERT OR REPLACE INTO blobs (id, data) VALUES (?, ?)', FALSE);
    query.Bind(1, ABlobId);
    if ABlob <> '' then
      query.BindBlob(2, @ABlob[1], Length(ABlob))
    else
      query.BindNull(2);
    query.ExecutePrepared;
  finally
    query.Free;
  end;
end;

function TDatabase.GetBlob(const ABlobId: Integer): RawByteString;
var
  query: TSQLDBStatement;
begin
  result := '';
  query := FConnection.NewThreadSafeStatement;
  try
    query.Prepare('SELECT data FROM blobs WHERE id = ?', TRUE);
    query.Bind(1, ABlobId);
    query.ExecutePrepared;
    if query.Step then
      result := query.ColumnBlob(0);
  finally
    query.Free;
  end;
end;

function TDatabase.GetSettingsBlob: RawByteString;
begin
  result := GetBlob(BLOB_ID_SETTINGS);
end;

procedure TDatabase.SaveSettings(const ASettingsBlob: RawByteString);
begin
  SaveBlob(BLOB_ID_SETTINGS, ASettingsBlob);
end;

end.
