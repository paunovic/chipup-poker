unit Poker.Seats.SeatList;

interface

uses
  System.Generics.Collections, Poker.Seats.Seat;

type
  TSeatList = class(TObjectList<TSeatInfo>)
  private
  public
    procedure ClearCaptions;

    procedure Sort; reintroduce;
  end;

implementation

uses
  System.Generics.Defaults;

{ TSeatList }

procedure TSeatList.Sort;
var
  comparer: IComparer<TSeatInfo>;
  comparison: TComparison<TSeatInfo>;
begin
  comparison := function(const ASeatInfo1, ASeatInfo2: TSeatInfo): Integer
  begin
    if ASeatInfo1.SeatIndex < ASeatInfo2.SeatIndex then
      result := -1
    else
      if ASeatInfo1.SeatIndex > ASeatInfo2.SeatIndex then
        result := 1
      else
        result := 0;
  end;

  comparer := TComparer<TSeatInfo>.Construct(comparison);
  inherited Sort(comparer);
end;

procedure TSeatList.ClearCaptions;
var
  C1: Integer;
begin
  for C1 := Low(ToArray) to High(ToArray) do
  begin
    ToArray[C1].UpperCaption := '';
    ToArray[C1].LowerCaption := '';
  end;
end;


end.
