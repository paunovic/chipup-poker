unit uClubInfo;

interface

uses
  System.Generics.Collections, System.Classes,
  uGameInfo;


type
  TClubInfo = class
  private
    FId     : Integer;
    FMongoId: String;
    FOwnerId: String;
    FName   : String;
    FInvCode: String;
    FBalance: Integer;
    FPrivate: Boolean;
    FPlayers: TStringList;
    FGames  : TGamesInfo;
  public
    constructor Create(const AMongoId, AOwnerId: String; const AId: Integer; const AName: String; const ABalance: Integer; const APrivate: Boolean; const AInvCode: String);
    destructor Destroy; override;

    property Id       : Integer read FId;
    property MongoId  : String read FMongoId;
    property OwnerId  : String read FOwnerId;
    property Name     : String read FName;
    property InvCode  : String read FInvCode;
    property Balance  : Integer read FBalance;
    property IsPrivate: Boolean read FPrivate;
    property Players  : TStringList read FPlayers;
    property Games    : TGamesInfo read FGames;
  end;

  TClubsInfo = class(TObjectList<TClubInfo>)
  public
    function AddClub(const AMongoId, AOwnerId: String; const AId: Integer; const AName: String; const ABalance: Integer; const APrivate: Boolean; const AInvCode: String): TClubInfo;
    function FindClub(const AId: Integer; var AClubInfo: TClubInfo): Boolean;
    function IndexOf(const AId: Integer): Integer;
  end;

implementation

{ TClubInfo }

constructor TClubInfo.Create(const AMongoId, AOwnerId: String; const AId: Integer; const AName: String; const ABalance: Integer; const APrivate: Boolean; const AInvCode: String);
begin
  FId := AId;
  FOwnerId := AOwnerId;
  FName := AName;
  FInvCode := AInvCode;
  FBalance := ABalance;
  FPrivate := APrivate;
  FPlayers := TStringList.Create;
  FPlayers.Sorted := TRUE;
  FPlayers.Duplicates := dupIgnore;
  FPlayers.CaseSensitive := FALSE;
  FGames := TGamesInfo.Create;
end;

destructor TClubInfo.Destroy;
begin
  FGames.Free;
  FPlayers.Free;

  inherited;
end;

{ TPlayerClubsInfo }

function TClubsInfo.AddClub(const AMongoId, AOwnerId: String; const AId: Integer; const AName: String; const ABalance: Integer; const APrivate: Boolean; const AInvCode: String): TClubInfo;
var
  index: Integer;
begin
  index := IndexOf(AId);
  if index = -1 then
    index := Add(TClubInfo.Create(AMongoId, AOwnerId, AId, AName, ABalance, APrivate, AInvCode))
  else
  begin
    Items[index].FMongoId := AMongoId;
    Items[index].FOwnerId := AOwnerId;
    Items[index].FName := AName;
    Items[index].FInvCode := AInvCode;
    Items[index].FBalance := ABalance;
    Items[index].FPrivate := APrivate;
  end;
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
