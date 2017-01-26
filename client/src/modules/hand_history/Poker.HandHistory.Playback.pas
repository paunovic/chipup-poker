unit Poker.HandHistory.Playback;

interface

uses
  System.Generics.Collections, Poker.HandHistory.Items,
  Poker.Protobufs.Objects.TableEvent, Poker.Protobufs.Objects.TableStatus;

type
  THandHistoryPlayback = class
  private
    FStates: TObjectList<TPB_TableStatus>;
    FCurrentStateIndex: Integer;

    function AddTableEvent(const ATableStatus: TPB_TableStatus; const AEventType: TTableEventType; const ASeatIndex: Integer): TPB_TableEvent;
  public
    constructor Create(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);
    destructor Destroy; override;

    procedure Configure(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);

    procedure CreateStates(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);
    function CurrentState: TPB_TableStatus;
    function NextState: TPB_TableStatus;
    function PrevState: TPB_TableStatus;

    property States: TObjectList<TPB_TableStatus> read FStates;
    property CurrentStateIndex: Integer read FCurrentStateIndex write FCurrentStateIndex;
  end;

implementation

uses
  Poker.HandHistory.Players, Poker.Protobufs.Objects.SeatInfo, Poker.Protobufs.Objects.Pot,
  Poker.Protobufs.Objects.Game, Poker.Protobufs.Objects.WinnerData, Poker.Common.Misc, Poker.DataModule, Poker.Protobufs.Objects.HandHistoryMove,
  Poker.Helpers.HandHistoryMove, Poker.Protobufs.Objects.PlayerHandHistory, Poker.Types;

{ THandHistoryPlayback }

constructor THandHistoryPlayback.Create(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);
begin
  FCurrentStateIndex := -1;
  FStates := TObjectList<TPB_TableStatus>.Create;
  Configure(AHandHistoryItems, AHandHistoryItem);
end;

destructor THandHistoryPlayback.Destroy;
begin
  FStates.Free;
  inherited;
end;

procedure THandHistoryPlayback.Configure(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);
begin
  CreateStates(AHandHistoryItems, AHandHistoryItem);
end;

function THandHistoryPlayback.AddTableEvent(const ATableStatus: TPB_TableStatus; const AEventType: TTableEventType; const ASeatIndex: Integer): TPB_TableEvent;
var
  te: TPB_TableEvent;
begin
  te := TPB_TableEvent.Create;
  te.Event := AEventType;
  te.Seat := ASeatIndex;
  ATableStatus.Events.Add(te);
  result := te;
end;

procedure THandHistoryPlayback.CreateStates(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);
type
  TPlayerState = record
    PhaseStartChips: UINT32;
    CurrentChips: UINT32;
    CurrentBet: UINT32;
    Folded: Boolean;
  end;
var
  player: TPB_PlayerHandHistory;
  player_states: TArray<TPlayerState>;
  move: TPB_HandHistoryMove;
  ts: TPB_TableStatus;
  te: TPB_TableEvent;
  si: TPB_SeatInfo;
  table_state: TTableState;
  contained_event: TTableEventType;
  C1, C2: Integer;
  sbseat, bbseat: Integer;
  pots: TObjectList<TPB_Pot>;
  current_split_count: Integer;
  flop_move_index: Integer;
begin
  // initialize vars
  FStates.Clear;
  table_state := tsPreFlop;
  sbseat := -1; bbseat := -1;
  current_split_count := 0;
  flop_move_index := 0;

  // set player states array length to number of seats
  SetLength(player_states, AHandHistoryItems.Game.Seats);

  // initiate all players
  for player in AHandHistoryItem.Players do
  begin
    player_states[player.Seat].PhaseStartChips := player.Chips;
    player_states[player.Seat].CurrentChips := player.Chips;
    player_states[player.Seat].CurrentBet := 0;
    player_states[player.Seat].Folded := FALSE;
  end;

  pots := TObjectList<TPB_Pot>.Create;
  try
    C1 := 0;
    while C1 < AHandHistoryItem.Moves.Count do
    begin
      move := AHandHistoryItem.Moves[C1];

      // set basic TS vars
      ts := TPB_TableStatus.Create;
      ts.TableMongoId := AHandHistoryItems.FGameId;
      ts.Dealer := AHandHistoryItem.DealerIndex;
      ts.CurrentSeat := move.Seat;
      ts.RakePercent := AHandHistoryItem.Rake;

      // SB/BB events
      if move.ContainsEvent([teSB, teBB], contained_event) then
      begin
        case contained_event of
          teSB: if sbseat = -1 then sbseat := move.Seat;
          teBB: if bbseat = -1 then bbseat := move.Seat;
        end;
        player_states[move.Seat].CurrentBet := move.Bet;
        player_states[move.Seat].CurrentChips := player_states[move.Seat].PhaseStartChips - player_states[move.Seat].CurrentBet;
      end;

      // set SB/BB vars in TS
      ts.SmallBlind := sbseat;
      ts.BigBlind := bbseat;

      // dealing event
      if move.ContainsEvent(teDealing) then
        AddTableEvent(ts, teDealing, -1);

      // flop/turn/river events
      if move.ContainsEvent([teFlop, teTurn, teRiver], contained_event) then
      begin
        for C2 := Low(player_states) to High(player_states) do
          player_states[C2].PhaseStartChips := player_states[C2].CurrentChips;

        // set pots only if it is first split pass
        // subsequent split passes should not adjust the pot
        if current_split_count = 0 then
        begin
          pots.Clear;
          for C2 := 0 to move.Pots.Count - 1 do
            pots.Add(TPB_Pot.Create(move.Pots[C2]));
        end;

        te := AddTableEvent(ts, contained_event, -1);

        case contained_event of
          teFlop: begin
            for C2 := 0 to current_split_count do
              te.Cards.Add(Copy(AHandHistoryItem.Cards[C2], 0, 3));
            flop_move_index := C1;

            if table_state < tsFlop then
              table_state := tsFlop;
          end;

          teTurn: begin
            for C2 := 0 to current_split_count do
              if Length(AHandHistoryItem.Cards[C2]) > 3 then
                te.Cards.Add(Copy(AHandHistoryItem.Cards[C2], 3, 1))
              else
                if Length(AHandHistoryItem.Cards[C2]) >= 2 then
                  te.Cards.Add(Copy(AHandHistoryItem.Cards[C2], 0, 1));

            if table_state < tsTurn then
              table_state := tsTurn;
          end;

          teRiver: begin
            for C2 := 0 to current_split_count do
              if Length(AHandHistoryItem.Cards[C2]) > 0 then
                te.Cards.Add(Copy(AHandHistoryItem.Cards[C2], Length(AHandHistoryItem.Cards[C2]) - 1, 1));

            if table_state < tsRiver then
              table_state := tsRiver;

            if current_split_count < AHandHistoryItem.Cards.Count - 1 then
            begin
              Inc(current_split_count);
              C1 := flop_move_index - 1;
            end;
          end;
        end;

        for C2 := Low(player_states) to High(player_states) do
        begin
          te.Bets.Add(player_states[C2].CurrentBet);
          player_states[C2].CurrentBet := 0;
        end;
      end;

      // fold event
      if move.ContainsEvent(teFold) then
      begin
        player_states[move.Seat].Folded := TRUE;
        AddTableEvent(ts, teFold, move.Seat);
      end;

      // check event
      if move.ContainsEvent(teCheck) then
        AddTableEvent(ts, teCheck, move.Seat);

      // call/raise/all-in events
      if move.ContainsEvent([teCall, teRaise, teAllIn], contained_event) then
      begin
        AddTableEvent(ts, contained_event, move.Seat);
        player_states[move.Seat].CurrentBet := move.Bet;
        player_states[move.Seat].CurrentChips := player_states[move.Seat].PhaseStartChips - player_states[move.Seat].CurrentBet;
      end;

      // winning event
      // create winning pots and clear player bets
      if move.ContainsEvent(teWinning) then
      begin
        te := AddTableEvent(ts, teWinning, -1);
        for C2 := 0 to move.WinnerPotData.Count - 1 do
          te.Pots.Add(TPB_Pot.Create(move.WinnerPotData[C2]));
        for C2 := Low(player_states) to High(player_states) do
          player_states[C2].CurrentBet := 0;
        table_state := tsWinning;
      end;

      // set TS pots
      for C2 := 0 to pots.Count - 1 do
        ts.Pots.Add(TPB_Pot.Create(pots[C2]));

      // set TS state to the appropriate one
      ts.State := table_state;

      // set TS seats
      for player in AHandHistoryItem.Players do
      begin
        si := TPB_SeatInfo.Create;
        si.SeatIndex := player.Seat;
        si.PlayerMongoId := player.MongoId;
        si.Chips := player_states[player.Seat].CurrentChips;
        si.Cards := player.Cards;

        if (player.Status = psFolded) and
           (not player_states[player.Seat].Folded) then
          si.Status := psInHand
        else
          si.Status := player.Status;

        case AHandHistoryItem.CurrentGame of
          gtHoldem: si.CardCount := 2;
          gtOmaha: si.CardCount := 4;
        end;

        si.CardsVisible := TRUE;
        ts.Seats.Add(si);
      end;

      // set TS bets
      ts.Bets.Clear;
      for C2 := Low(player_states) to High(player_states) do
        ts.Bets.Add(player_states[C2].CurrentBet);

      FStates.Add(ts);
      Inc(C1);
    end;
  finally
    pots.Free;
  end;

  if FStates.Count > 0 then
    FCurrentStateIndex := 0
  else
    FCurrentStateIndex := -1;
end;

function THandHistoryPlayback.CurrentState: TPB_TableStatus;
begin
  if (FStates.Count > 0) and
     (FCurrentStateIndex < FStates.Count) then
    result := FStates[FCurrentStateIndex]
  else
    result := nil;
end;

function THandHistoryPlayback.NextState: TPB_TableStatus;
begin
  if FCurrentStateIndex < FStates.Count - 1 then
    Inc(FCurrentStateIndex);
  result := CurrentState;
end;

function THandHistoryPlayback.PrevState: TPB_TableStatus;
begin
  if FCurrentStateIndex > 0 then
    Dec(FCurrentStateIndex);
  result := CurrentState;
end;

end.
