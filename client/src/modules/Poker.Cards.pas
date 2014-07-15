unit Poker.Cards;

interface

uses
  System.SysUtils, System.Generics.Collections;


type
  TCardSuit = (csUnknown, csHeart, csDiamond, csClub, csSpade);
  TCardValue = (cvUnknown, cvTwo, cvThree, cvFour, cvFive, cvSix, cvSeven, cvEight, cvNine, cvTen, cvJack, cvQueen, cvKing, cvAce);

  TCard = class
  private
    FValue: TCardValue;
    FSuit: TCardSuit;

  public
    constructor Create; overload;
    constructor Create(const AValue: TCardValue; const ASuit: TCardSuit); overload;
    constructor Create(const AByte: Byte); overload;

    procedure Assign(const AByte: Byte); overload;
    procedure Assign(const ABytes: TBytes); overload;
    procedure Assign(const ACard: TCard); overload;

    procedure Clear;

    function AsString: String;
    function IsKnown: Boolean;

    class function GetAsString(const AValue: TCardValue; const ASuit: TCardSuit): String; overload;
    class function SuitAsString(const ASuit: TCardSuit): String;
    class function ValueAsString(const AValue: TCardValue): String;
    class function ByteToString(const AByte: Byte): String;

    property Value: TCardValue read FValue;
    property Suit: TCardSuit read FSuit;
  end;

  TCards = class(TObjectList<TCard>)
  private
    function GetAsString: String;

  public
    constructor Create; overload;
    constructor Create(const ABytes: TBytes); overload;

    procedure Assign(const ABytes: TBytes);
    function IsKnown: Boolean;

    class function BytesToString(const ACards: TBytes; const ADelimiter: String = ''; const ALength: Integer = 0): String;

    property AsString: String read GetAsString;
  end;

implementation

{ TCard }

constructor TCard.Create;
begin
  Clear;
end;

constructor TCard.Create(const AValue: TCardValue; const ASuit: TCardSuit);
begin
  FValue := AValue;
  FSuit := ASuit;
end;

procedure TCard.Clear;
begin
  FValue := cvUnknown;
  FSuit := csUnknown;
end;

constructor TCard.Create(const AByte: Byte);
begin
  Assign(AByte);
end;

procedure TCard.Assign(const AByte: Byte);
var
  d, m: Integer;
  val: TCardValue;
  sui: TCardSuit;
begin
  d := AByte div 4;
  m := AByte mod 4;

  if (d in [0..12]) and
     (m in [0..3]) then
  begin
    val := TCardValue(d + 1);
    sui := TCardSuit(m + 1);
  end
  else
  begin
    val := cvUnknown;
    sui := csUnknown;
  end;

  FValue := val;
  FSuit := sui;
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
begin
  result := ValueAsString(AValue) + SuitAsString(ASuit);
end;

function TCard.IsKnown: Boolean;
begin
  result := (FValue <> cvUnknown) and
            (FSuit <> csUnknown);
end;

class function TCard.SuitAsString(const ASuit: TCardSuit): String;
begin
  case ASuit of
    csHeart: result := 'h';
    csSpade: result := 's';
    csClub: result := 'c';
    csDiamond: result := 'd';
  else
    result := '';
  end;
end;

class function TCard.ValueAsString(const Avalue: TCardValue): String;
begin
  case AValue of
    cvTwo: result :=  '2';
    cvThree: result :=  '3';
    cvFour: result :=  '4';
    cvFive: result :=  '5';
    cvSix: result :=  '6';
    cvSeven: result :=  '7';
    cvEight: result :=  '8';
    cvNine: result :=  '9';
    cvTen: result :=  'T';
    cvJack: result :=  'J';
    cvQueen: result :=  'Q';
    cvKing: result :=  'K';
    cvAce: result :=  'A';
  else
    result :=  '';
  end;
end;

procedure TCard.Assign(const ACard: TCard);
begin
  FValue := ACard.Value;
  FSuit := ACard.Suit;
end;

function TCard.AsString: String;
begin
  result := GetAsString(FValue, FSuit);
end;

class function TCard.ByteToString(const AByte: Byte): String;
var
  card: TCard;
begin
  card := TCard.Create(AByte);
  try
    result := card.AsString;
  finally
    card.Free;
  end;
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

function TCards.IsKnown: Boolean;
var
  card: TCard;
begin
  for card in ToArray do
    if card.IsKnown then
      Exit(TRUE);
  Exit(FALSE);
end;

class function TCards.BytesToString(const ACards: TBytes; const ADelimiter: String = ''; const ALength: Integer = 0): String;
var
  C1: Integer;
  card: TCard;
  size: Integer;
  cstr: String;
begin
  result := '';
  size := ALength;
  if ALength = 0 then
    size := Length(ACards);

  for C1 := 0 to size - 1 do
  begin
    card := TCard.Create(ACards[C1]);
    try
      cstr := card.AsString;
      if cstr = '' then
        Continue;

      result := result + cstr + ADelimiter;
    finally
      card.Free;
    end;
  end;

  if (result <> '') and
     (ADelimiter <> '') then
    System.Delete(result, Length(result) - Length(ADelimiter) + 1, Length(ADelimiter));
end;

end.
