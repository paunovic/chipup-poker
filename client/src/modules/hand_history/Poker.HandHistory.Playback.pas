unit Poker.HandHistory.Playback;

interface

uses
  System.Generics.Collections, Poker.HandHistory.Items, Poker.Protobufs.Objects.TableStatus;

type
  THandHistoryPlayback = class
  private
    FStates: TObjectList<TPB_TableStatus>;
    FCurrentStateIndex: Integer;
  public
    constructor Create(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);
    destructor Destroy; override;

    procedure CreateStates(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);
    function CurrentState: TPB_TableStatus;
    function NextState: TPB_TableStatus;
    function PrevState: TPB_TableStatus;

    property States: TObjectList<TPB_TableStatus> read FStates;
    property CurrentStateIndex: Integer read FCurrentStateIndex write FCurrentStateIndex;
  end;

implementation

uses
  Poker.HandHistory.Moves, Poker.HandHistory.Players, Poker.Protobufs.Objects.SeatInfo, Poker.Protobufs.Objects.TableEvent,
  Poker.Protobufs.Objects.Pot, Poker.Protobufs.Objects.Game, Poker.Objects.PotInfo, Poker.Protobufs.Objects.WinnerPotInfo,
  Poker.Protobufs.Objects.WinnerData, Poker.Common.Misc, Poker.DataModule;

{ THandHistoryPlayback }

constructor THandHistoryPlayback.Create(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);
begin
  FCurrentStateIndex := -1;
  FStates := TObjectList<TPB_TableStatus>.Create;
  CreateStates(AHandHistoryItems, AHandHistoryItem);
end;

destructor THandHistoryPlayback.Destroy;
begin
  FStates.Free;
  inherited;
end;

procedure THandHistoryPlayback.CreateStates(const AHandHistoryItems: THandHistoryItems; const AHandHistoryItem: THandHistoryItem);
var
  pbtablestatus: TPB_TableStatus;
  pbseat: TPB_SeatInfo;
  move: THandHistoryMove;
  player: TPlayerHandHistory;
  tablestate: TTableState;
  pbevent: TPB_TableEvent;
  pbpot: TPB_Pot;
  bets: TArray<UINT32>;
  sbseat: Integer;
  bbseat: Integer;
  pbwinnerpotinfo: TPB_WinnerPotInfo;
  winnerdata: TPB_WinnerData;
  C1, C2, C3: Integer;
  folded: TArray<Boolean>;
  pots: TObjectList<TPB_Pot>;
begin
  bbseat := -1;
  sbseat := -1;

  FStates.Clear;
  tablestate := tsPreFlop;

  SetLength(bets, AHandHistoryItems.Game.Seats);
  FillChar(bets[0], Length(bets) * SizeOf(UINT32), 0);
  SetLength(folded, AHandHistoryItems.Game.Seats);

  pots := TObjectList<TPB_Pot>.Create;
  try
    for C1 := 0 to AHandHistoryItem.Moves.Count - 1 do
    begin
      move := AHandHistoryItem.Moves[C1];

      pbtablestatus := TPB_TableStatus.Create;

      pbtablestatus.TableMongoId := AHandHistoryItems.FGameId;
      pbtablestatus.Dealer := AHandHistoryItem.DealerIndex;
      pbtablestatus.CurrentSeat := move.Seat;
      pbtablestatus.RakePercent := AHandHistoryItem.Rake;

      if move.ContainsEvent(teSB) then
      begin
        if sbseat = -1 then
          sbseat := move.Seat;
        bets[move.Seat] := move.Bet;
      end;

      if move.ContainsEvent(teBB) then
      begin
        if bbseat = -1 then
          bbseat := move.Seat;
        bets[move.Seat] := move.Bet;
      end;

      pbtablestatus.SmallBlind := sbseat;
      pbtablestatus.BigBlind := bbseat;

      if move.ContainsEvent(teDealing) then
      begin
        pbevent := TPB_TableEvent.Create;
        pbevent.Event := teDealing;
        pbtablestatus.Events.Add(pbevent);
      end;

      for C2 := 0 to C1 do
        if (move.ContainsEvent(teFlop)) or
           (move.ContainsEvent(teTurn)) or
           (move.ContainsEvent(teRiver)) then
        begin
          pots.Clear;
          for C3 := 0 to move.Pots.Count - 1 do
          begin
            pbpot := TPB_Pot.Create;
            pbpot.Value := move.Pots[C3].Value;
            pbpot.Members.AddRange(move.Pots[C3].Members);
            pots.Add(pbpot);
          end;

          pbevent := TPB_TableEvent.Create;
          if move.ContainsEvent(teFlop) then
          begin
            tablestate := tsFlop;
            pbevent.Event := teFlop;
            pbevent.Cards := Copy(AHandHistoryItem.Cards, 0, 3);
          end
          else
            if move.ContainsEvent(teTurn) then
            begin
              tablestate := tsTurn;
              pbevent.Event := teTurn;
              pbevent.Cards := Copy(AHandHistoryItem.Cards, 3, 1);
            end
            else
              if move.ContainsEvent(teRiver) then
              begin
                tablestate := tsRiver;
                pbevent.Event := teRiver;
                pbevent.Cards := Copy(AHandHistoryItem.Cards, 4, 1);
              end;
          pbevent.Bets.AddRange(bets);
          FillChar(bets[0], Length(bets) * SizeOf(UINT32), 0);
          pbtablestatus.Events.Add(pbevent);
        end;

      if move.ContainsEvent(teWinning) then
      begin
        pbevent := TPB_TableEvent.Create;
        for C2 := 0 to move.WinnerPots.Count - 1 do
        begin
          pbwinnerpotinfo := TPB_WinnerPotInfo.Create;
          pbwinnerpotinfo.Sum := move.WinnerPots[C2].Value;
          pbwinnerpotinfo.Rake := move.WinnerPots[C2].Rake;
          for C3 := 0 to move.WinnerPots[C2].WinnerData.Count - 1 do
          begin
            winnerdata := TPB_WinnerData.Create;
            winnerdata.Seat := move.WinnerPots[C2].WinnerData[C3].Seat;
            winnerdata.Msg := move.WinnerPots[C2].WinnerData[C3].Msg;
            pbwinnerpotinfo.WinnerData.Add(winnerdata);
          end;
          pbwinnerpotinfo.Seats.AddRange(move.WinnerPots[C2].Members);
          pbevent.Pots.Add(pbwinnerpotinfo);
        end;

        FillChar(bets[0], Length(bets) * SizeOf(UINT32), 0);

        pbevent.Event := teWinning;
        pbtablestatus.Events.Add(pbevent);
        tablestate := tsWinning;
      end;

      pbtablestatus.State := tablestate;

      for C2 := 0 to pots.Count - 1 do
      begin
        pbpot := TPB_Pot.Create;
        pbpot.Value := pots[C2].Value;
        pbpot.Members.AddRange(pots[C2].Members);
        pbtablestatus.Pots.Add(pbpot);
      end;

      if move.ContainsEvent(teFold) then
      begin
        folded[move.Seat] := TRUE;
        pbevent := TPB_TableEvent.Create;
        pbevent.Seat := move.Seat;
        pbevent.Event := teFold;
        pbtablestatus.Events.Add(pbevent);
      end;

      if move.ContainsEvent(teCheck) then
      begin
        pbevent := TPB_TableEvent.Create;
        pbevent.Seat := move.Seat;
        pbevent.Event := teCheck;
        pbtablestatus.Events.Add(pbevent);
      end;

      if move.ContainsEvent(teRaise) then
      begin
        pbevent := TPB_TableEvent.Create;
        pbevent.Seat := move.Seat;
        bets[move.Seat] := move.Bet;
        pbevent.Event := teRaise;
        pbtablestatus.Events.Add(pbevent);
      end;

      if move.ContainsEvent(teCall) then
      begin
        pbevent := TPB_TableEvent.Create;
        pbevent.Seat := move.Seat;
        bets[move.Seat] := move.Bet;
        pbevent.Event := teCall;
        pbtablestatus.Events.Add(pbevent);
      end;

      for player in AHandHistoryItem.Players do
      begin
        pbseat := TPB_SeatInfo.Create;
        pbseat.Seat := player.Seat;
        pbseat.PlayerMongoId := player.MongoId;
        pbseat.Chips := player.Chips;
        if (CompareBytes(dmMain.SelfInfo.Id, player.MongoId)) or
           ((not player.Mucked) and
            (pbtablestatus.State >= tsWinning)) then
          pbseat.Cards := player.Cards;
        if (player.Status in [psFolded]) and
           (not folded[player.Seat]) then
          pbseat.Status := psInHand
        else
          pbseat.Status := player.Status;
        case AHandHistoryItem.CurrentGame of
          gtHoldem: pbseat.CardCount := 2;
          gtOmaha: pbseat.CardCount := 4;
        end;
        pbseat.CardsVisible := TRUE;
        pbtablestatus.Seats.Add(pbseat);
      end;

      pbtablestatus.Bets.Clear;
      for C2 := Low(bets) to High(bets) do
        pbtablestatus.Bets.Add(bets[C2]);

      FStates.Add(pbtablestatus);
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
