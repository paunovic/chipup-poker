unit Poker.Seats.SeatList;

interface

uses
  System.Generics.Collections, Poker.Seats.Seat;

type
  TSeatList = class(TObjectList<TSeatInfo>)
  private
    procedure NotifyEvent(Sender: TObject; const AValue: TSeatInfo; AAction: TCollectionNotification);
  public
    constructor Create;

    procedure ClearCaptions;
    procedure Sort;
  end;

implementation

uses
  System.Generics.Defaults;

{ TSeatList }

constructor TSeatList.Create;
begin
  inherited Create(TRUE);
  OnNotify := NotifyEvent;
end;

procedure TSeatList.NotifyEvent(Sender: TObject; const AValue: TSeatInfo; AAction: TCollectionNotification);
begin
  Sort;
end;

procedure TSeatList.Sort;
var
  comparer: IComparer<TSeatInfo>;
begin
  comparer := TComparer<TSeatInfo>.Construct(
    function(const ASeatInfo1, ASeatInfo2: TSeatInfo): Integer
    begin
      if ASeatInfo1.SeatIndex < ASeatInfo2.SeatIndex then
        result := -1
      else
        if ASeatInfo1.SeatIndex > ASeatInfo2.SeatIndex then
          result := 1
        else
          result := 0;
    end
  );

  inherited Sort(comparer);
end;

procedure TSeatList.ClearCaptions;
var
  seat: TSeatInfo;
begin
  for seat in ToArray do
  begin
    seat.UpperCaption := '';
    seat.LowerCaption := '';
  end;
end;


end.
