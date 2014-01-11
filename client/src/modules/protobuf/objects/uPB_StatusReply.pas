unit uPB_StatusReply;

interface

uses
  Winapi.Windows, System.Classes, pbOutput, uProtobufBaseObject, uProtobufReader,
  uPB_Club, uPB_User, uPB_Game;

type
  TPB_StatusReply = class(TProtobufBaseObject)
  private
    const
      FN_CLUBS = 1;
      FN_USERS = 2;
      FN_SELF = 3;
      FN_GAMES = 4;

    var
      FClubs: TPB_Clubs;
      FUsers: TPB_Users;
      FSelf: TPB_User;
      FGames: TPB_Games;

  public
    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    destructor Destroy; override;

    property Clubs: TPB_Clubs read FClubs;
    property Users: TPB_Users read Fusers;
    property Self: TPB_User read Fself;
    property Games: TPB_Games read FGames;
  end;

implementation

uses
  System.SysUtils, pbPublic;


destructor TPB_StatusReply.Destroy;
begin
  FClubs.Free;
  FUsers.Free;
  FSelf.Free;
  FGames.Free;

  inherited;
end;

procedure TPB_StatusReply.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag         : Integer;
  wire_type   : Integer;
  field_number: Integer;
  endpos      : Integer;
begin
  if not Assigned(FClubs) then
    FClubs := TPB_Clubs.Create;
  if not Assigned(FUsers) then
    FUsers := TPB_Users.Create;
  if not Assigned(FSelf) then
    FSelf := TPB_User.Create;
  if not Assigned(FGames) then
    FGames := TPB_Games.Create;
  FClubs.Clear;
  FUsers.Clear;
  FGames.Clear;

  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_CLUBS: FClubs.Add(TPB_Club.Create(AProtobufReader, AProtobufReader.readInt32));
      FN_USERS: FUsers.Add(TPB_User.Create(AProtobufReader, AProtobufReader.readInt32));
      FN_SELF: FSelf.LoadFromProtobufReader(AProtobufReader, AProtobufReader.readInt32);
      FN_GAMES: FGames.Add(TPB_Game.Create(AProtobufReader, AProtobufReader.readInt32));
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_StatusReply.GetProtobuf: TProtoBufOutput;
var
  pboutput: TProtoBufOutput;
begin
  pboutput := TProtoBufOutput.Create;
  result := pboutput;
end;

end.
