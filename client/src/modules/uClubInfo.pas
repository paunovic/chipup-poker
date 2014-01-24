unit uClubInfo;

interface

uses
  System.Generics.Collections, System.SysUtils,
  uGameInfo, uPB_Club;


type
  TClubInfo = class
  private
    FId              : Integer;
    FMongoId         : TBytes;
    FOwnerId         : TBytes;
    FName            : String;
    FInvCode         : String;
    FBalance         : Integer;
    FPrivate         : Boolean;
    FPlayers         : TArray<TBytes>;
    FSuspendedPlayers: TArray<TBytes>;
    FGames           : TGamesInfo;
  public
    constructor Create(const AProtobufObject: TPB_Club); overload;
    constructor Create(const AMongoId, AOwnerId: TBytes; const AId: Integer; const AName: String; const ABalance: Integer; const APrivate: Boolean; const AInvCode: String); overload;
    destructor Destroy; override;

    procedure UpdateFromProtobufObject(const AProtobufObject: TPB_Club);

    procedure AddPlayer(const AMongoId: TBytes; const ASuspended: Boolean);
    function IsSuspendedPlayer(const AMongoId: TBytes): Boolean;
    function IsPlayerInTheClub(const AMongoId: TBytes): Boolean;

    property Id              : Integer read FId;
    property MongoId         : TBytes read FMongoId;
    property OwnerId         : TBytes read FOwnerId;
    property Name            : String read FName;
    property InvCode         : String read FInvCode;
    property Balance         : Integer read FBalance;
    property IsPrivate       : Boolean read FPrivate;
    property Players         : TArray<TBytes> read FPlayers;
    property SuspendedPlayers: TArray<TBytes> read FSuspendedPlayers;
    property Games           : TGamesInfo read FGames;
  end;

  TClubsInfo = class(TObjectList<TClubInfo>)
  public
    function AddClub(const AProtobufObject: TPB_Club): TClubInfo;
    function FindClub(const AId: Integer; var AClubInfo: TClubInfo): Boolean;
    function IndexOf(const AId: Integer): Integer;
  end;

implementation

uses
  uCommon;

{ TClubInfo }

constructor TClubInfo.Create(const AProtobufObject: TPB_Club);
begin
  FGames := TGamesInfo.Create;
  UpdateFromProtobufObject(AProtobufObject);
end;

constructor TClubInfo.Create(const AMongoId, AOwnerId: TBytes; const AId: Integer; const AName: String; const ABalance: Integer; const APrivate: Boolean; const AInvCode: String);
begin
  FId := AId;
  FMongoId := AMongoId;
  FOwnerId := AOwnerId;
  FName := AName;
  FInvCode := AInvCode;
  FBalance := ABalance;
  FPrivate := APrivate;
  FGames := TGamesInfo.Create;
end;

destructor TClubInfo.Destroy;
begin
  FGames.Free;

  inherited;
end;

function TClubInfo.IsPlayerInTheClub(const AMongoId: TBytes): Boolean;
var
  C1, a1len: Integer;
begin
  a1len := Length(AMongoId);
  for C1 := 0 to Length(FPlayers) - 1 do
    if CompareBytes(AMongoId, FPlayers[C1], a1len) then
      Exit(TRUE);
  for C1 := 0 to Length(FSuspendedPlayers) - 1 do
    if CompareBytes(AMongoId, FSuspendedPlayers[C1], a1len) then
      Exit(TRUE);
  Exit(FALSE);
end;

function TClubInfo.IsSuspendedPlayer(const AMongoId: TBytes): Boolean;
var
  C1, a1len: Integer;
begin
  a1len := Length(AMongoId);
  for C1 := 0 to Length(FSuspendedPlayers) - 1 do
    if CompareBytes(AMongoId, FSuspendedPlayers[C1], a1len) then
      Exit(TRUE);
  Exit(FALSE);
end;

procedure TClubInfo.UpdateFromProtobufObject(const AProtobufObject: TPB_Club);
var
  C1: Integer;
begin
  FMongoId := AProtobufObject.MongoId;
  FOwnerId := AProtobufObject.Owner;
  FId := AProtobufObject.Seq;
  FName := AProtobufObject.Name;
  FBalance := AProtobufObject.Chips;
  FPrivate := AProtobufObject.IsPrivate;
  FInvCode := AProtobufObject.Password;
  SetLength(FPlayers, 0);
  SetLength(FSuspendedPlayers, 0);
  AddPlayer(AProtobufObject.Owner, FALSE);
  for C1 := 0 to Length(AProtobufObject.Members) - 1 do
    AddPlayer(AProtobufObject.Members[C1], FALSE);
  for C1 := 0 to Length(AProtobufObject.SuspendedMembers) - 1 do
    AddPlayer(AProtobufObject.SuspendedMembers[C1], TRUE);
end;

procedure TClubInfo.AddPlayer(const AMongoId: TBytes; const ASuspended: Boolean);
begin
  if not ASuspended then
  begin
    SetLength(FPlayers, Length(FPlayers) + 1);
    FPlayers[Length(FPlayers) - 1] := AMongoId;
  end
  else
  begin
    SetLength(FSuspendedPlayers, Length(FSuspendedPlayers) + 1);
    FSuspendedPlayers[Length(FSuspendedPlayers) - 1] := AMongoId;
  end;
end;


{ TPlayerClubsInfo }

function TClubsInfo.AddClub(const AProtobufObject: TPB_Club): TClubInfo;
var
  index: Integer;
begin
  index := IndexOf(AProtobufObject.Seq);
  if index = -1 then
    index := Add(TClubInfo.Create(AProtobufObject))
  else
    Items[index].UpdateFromProtobufObject(AProtobufObject);

  result := Items[index];
end;

function TClubsInfo.FindClub(const AId: Integer; var AClubInfo: TClubInfo): Boolean;
var
  clubinfo: TClubInfo;
begin
  for clubinfo in self.ToArray do
    if clubinfo.Id = AId then
    begin
      AClubInfo := clubinfo;
      Exit(TRUE);
    end;

  Exit(FALSE);
end;

function TClubsInfo.IndexOf(const AId: Integer): Integer;
var
  C1: Integer;
begin
  for C1 := 0 to Length(self.ToArray) - 1 do
    if self.ToArray[C1].Id = AId then
      Exit(C1);

  Exit(-1);
end;

end.
