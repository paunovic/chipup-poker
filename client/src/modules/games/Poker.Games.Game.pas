unit Poker.Games.Game;

interface

uses
  Winapi.Windows, System.SysUtils, Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.TableStatus, Poker.Types;

type
  TGameInfo = class(TPB_Game)
  private
    function GetStateStr: String;
    function GetName: String;
  public
    constructor Create;

    procedure Assign(const AProtobufObject: TPB_Game);

    class procedure BlindsEnumToInts(const ABlinds: TGameBlinds; out ASmallBlind, ABigBlind: UINT32);
    class function GameTypeToStr(const AGameType: TGameType; const AGameLimit: TGameLimit; const AShort: Boolean): String;

    function AsString(const AShort: Boolean): String;

    property GameName: String read GetName;
    property StateAsStr: String read GetStateStr;
  end;

implementation

{ TGameInfo }

constructor TGameInfo.Create;
begin
  inherited Create(TRUE);
end;

procedure TGameInfo.Assign(const AProtobufObject: TPB_Game);
begin
  Clear;
  MergeFrom(AProtobufObject);
end;

class procedure TGameInfo.BlindsEnumToInts(const ABlinds: TGameBlinds; out ASmallBlind, ABigBlind: UINT32);
begin
  case ABlinds of
    gb1x2: begin
      ASmallBlind := 1;
      ABigBlind := 2;
    end;
    gb5x5: begin
      ASmallBlind := 5;
      ABigBlind := 5;
    end;
    gb5x10: begin
      ASmallBlind := 5;
      ABigBlind := 10;
    end;
    gb10x25: begin
      ASmallBlind := 10;
      ABigBlind := 25;
    end;
    gb25x50: begin
      ASmallBlind := 25;
      ABigBlind := 50;
    end;
    gb50x100: begin
      ASmallBlind := 50;
      ABigBlind := 100;
    end;
    gbOther: begin
      ASmallBlind := 0;
      ABigBlind := 0;
    end;
  end;
end;

function TGameInfo.AsString(const AShort: Boolean): String;
begin
  result := GameTypeToStr(GameType, GameLimit, AShort);
end;

class function TGameInfo.GameTypeToStr(const AGameType: TGameType; const AGameLimit: TGameLimit; const AShort: Boolean): String;
begin
  result := '';
  case AGameLimit of
    glNoLimit: if AShort then
      result := 'NL'
    else
      result := 'No Limit';
    glFixedLimit: if AShort then
      result := 'FL'
    else
      result := 'Fixed Limit';
    glPotLimit: if AShort then
      result := 'PL'
    else
      result := 'Pot Limit';
  end;

  case AGameType of
    gtHoldem: if AShort then
      result := result + 'H'
    else
      result := result + ' Hold''em';
    gtOmaha: if AShort then
      result := result + 'O'
    else
      result := result + ' Omaha';
    gtRotationNLHPLO: result := 'Rotation NLH/PLO';
  end;
end;

function TGameInfo.GetName: String;
begin
  if FinalTable then
    result := 'Final Table'
  else
    result := (self as TPB_Game).Gamename;
end;

function TGameInfo.GetStateStr: String;
begin
  case State of
    gsActive: result := 'Open';
    gsClosing: result := 'Closing';
    gsClosed: result := 'Closed';
    gsEmpty: result := 'Open';
  else
    result := 'Unknown';
  end;
end;

end.
