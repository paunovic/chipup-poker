unit uCards;

interface

uses
  System.SysUtils, System.Generics.Collections;


type
  TCardSuit = (csUnknown, csHeart, csDiamond, csClub, csSpade);
  TCardValue = (cvUnknown, cvTwo, cvThree, cvFour, cvFive, cvSix, cvSeven, cvEight, cvNine, cvTen, cvJack, cvQueen, cvKing, cvAce);

  TCard = class
  private
    FValue: TCardValue;
    FSuit : TCardSuit;

    function GetAsString: String; overload;

  public
    constructor Create; overload;
    constructor Create(const AValue: TCardValue; const ASuit: TCardSuit); overload;
    constructor Create(const AByte: Byte); overload;

    procedure Assign(const AByte: Byte); overload;
    procedure Assign(const ABytes: TBytes); overload;

    class function GetAsString(const AValue: TCardValue; const ASuit: TCardSuit): String; overload;

    property Value: TCardValue read FValue;
    property Suit: TCardSuit read FSuit;
    property AsString: String read GetAsString;
  end;

  TCards = class(TObjectList<TCard>)
  private
    function GetAsString: String;

  public
    constructor Create; overload;
    constructor Create(const ABytes: TBytes); overload;

    procedure Assign(const ABytes: TBytes);

    property AsString: String read GetAsString;
  end;

implementation

{ TCard }

constructor TCard.Create;
begin
  FValue := cvUnknown;
  FSuit := csUnknown;
end;

constructor TCard.Create(const AValue: TCardValue; const ASuit: TCardSuit);
begin
  FValue := AValue;
  FSuit := ASuit;
end;

constructor TCard.Create(const AByte: Byte);
begin
  Assign(AByte);
end;

procedure TCard.Assign(const AByte: Byte);
var
  d, m: Integer;
begin
  d := AByte div 4;
  m := AByte mod 4;

  Assert(d in [0..12]);
  FValue := TCardValue(d + 1);

  Assert(m in [0..3]);
  FSuit := TCardSuit(m + 1);
end;

procedure TCard.Assign(const ABytes: TBytes);
begin
  if Length(ABytes) = 0 then
  begin
    FValue := cvUnknown;
    FSuit := csUnknown;
  end
  else
    Assign(ABytes[0]);
end;


class function TCard.GetAsString(const AValue: TCardValue; const ASuit: TCardSuit): String;
var
  value, suit: String;
begin
  case AValue of
    cvTwo: value := '2';
    cvThree: value := '3';
    cvFour: value := '4';
    cvFive: value := '5';
    cvSix: value := '6';
    cvSeven: value := '7';
    cvEight: value := '8';
    cvNine: value := '9';
    cvTen: value := 'T';
    cvJack: value := 'J';
    cvQueen: value := 'Q';
    cvKing: value := 'K';
    cvAce: value := 'A';
  else
    value := 'X';
  end;

  case ASuit of
    csHeart: suit := 'h';
    csSpade: suit := 's';
    csClub: suit := 'c';
    csDiamond: suit := 'd';
  else
    suit := 'x';
  end;

  result := value + suit;
end;

function TCard.GetAsString: String;
begin
  result := GetAsString(FValue, FSuit);
end;

{ TCards }

constructor TCards.Create;
begin
  inherited Create;
end;

constructor TCards.Create(const ABytes: TBytes);
begin
  inherited Create;

  Assign(ABytes);
end;

procedure TCards.Assign(const ABytes: TBytes);
var
  C1: Integer;
begin
  Clear;
  for C1 := Low(ABytes) to High(ABytes) do
    Add(TCard.Create(ABytes[C1]));
end;

function TCards.GetAsString: String;
var
  C1: Integer;
begin
  result := '';
  for C1 := Low(ToArray) to High(ToArray) do
    result := result + ToArray[C1].AsString;
end;

end.
