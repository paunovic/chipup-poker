unit Poker.HandHistory.Playback;

interface

uses
  Poker.HandHistory.Items;

type
  THandHistoryPlayback = class
  private
  public
    constructor Create(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);
  end;

implementation

{ THandHistoryPlayback }

constructor THandHistoryPlayback.Create(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);
begin

end;

end.
