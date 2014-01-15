unit uPB_StatusReply;

interface

uses
  Winapi.Windows, pbOutput, uProtobufBaseObject, uProtobufReader, uPB_Club, uPB_User, uPB_Game;

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
    destructor Destroy; override;

    procedure LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer); override;
    function GetProtobuf: TProtoBufOutput; override;

    property Clubs: TPB_Clubs read FClubs;
    property Users: TPB_Users read FUsers;
    property Self: TPB_User read FSelf;
    property Games: TPB_Games read FGames;
  end;


implementation

uses
  pbPublic;


destructor TPB_StatusReply.Destroy;
begin
  if Assigned(FClubs) then
    FClubs.Free;
  if Assigned(FUsers) then
    FUsers.Free;
  if Assigned(FSelf) then
    FSelf.Free;
  if Assigned(FGames) then
    FGames.Free;

  inherited;
end;

procedure TPB_StatusReply.LoadFromProtobufReader(const AProtobufReader: TProtobufReader; const ASize: Integer);
var
  tag, wire_type, field_number, endpos: Integer;
begin
  endpos := AProtobufReader.getPos + ASize;
  while (AProtobufReader.getPos < endpos) and
        (AProtobufReader.GetNext(tag, wire_type, field_number)) do
    case field_number of
      FN_CLUBS: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        if not Assigned(FClubs) then
          FClubs := TPB_Clubs.Create;
        FClubs.Add(TPB_Club.Create(AProtobufReader, AProtobufReader.readInt32));
		AddModifiedField(FN_CLUBS);
      end;
      FN_USERS: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        if not Assigned(FUsers) then
          FUsers := TPB_Users.Create;
        FUsers.Add(TPB_User.Create(AProtobufReader, AProtobufReader.readInt32));
      end;
      FN_SELF: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        if not Assigned(FSelf) then
          FSelf := TPB_User.Create;
		FSelf.LoadFromProtobufReader(AProtobufReader, AProtobufReader.readInt32);
	  end;
      FN_GAMES: begin
        Assert(wire_type = WIRETYPE_LENGTH_DELIMITED);
        if not Assigned(FGames) then
          FGames := TPB_Games.Create;
		FGames.Add(TPB_Game.Create(AProtobufReader, AProtobufReader.readInt32));
      end;
    else
      AProtobufReader.skipField(tag);
    end;
end;

function TPB_StatusReply.GetProtobuf: TProtoBufOutput;
var
  pbout: TProtoBufOutput;
begin
  pbout := TProtoBufOutput.Create;
//  if IsModifiedField(FN_CLUBS) then
//    pbout.writeProtobufBaseObject(FN_CLUBS, FClubs);
//  if IsModifiedField(FN_USERS) then
//    pbout.writeProtobufBaseObject(FN_USERS, FUsers);
  if IsModifiedField(FN_SELF) then
    pbout.writeProtobufBaseObject(FN_SELF, FSelf);
//  if IsModifiedField(FN_GAMES) then
//    pbout.writeProtobufBaseObject(FN_GAMES, FGames);
  result := pbout;
end;


end.

