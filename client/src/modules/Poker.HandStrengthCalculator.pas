// so ugly it eats little kids

unit Poker.HandStrengthCalculator;

interface

uses
  Poker.Protobufs.Objects.Game;

type
  THandStrengthCalculator = class
  private
    class procedure SortCards(var ACards: TArray<String>);
    class function ShortCardToLong(const ACard: Char; const APlural: Boolean = FALSE): String;
    class function IsRoyalFlush(const ACards: TArray<String>): Boolean;
    class function IsStraightFlush(const ACards: TArray<String>; out ACard: String): Boolean;
    class function IsFourOfAKind(const ACards: TArray<String>; out ACard, AKicker: String): Boolean;
    class function IsFullHouse(const ACards: TArray<String>; out AOverCard, AUnderCard: String): Boolean;
    class function IsFlush(const ACards: TArray<String>; out ACard: String): Boolean;
    class function IsStraight(const ACards: TArray<String>; out ACard: String): Boolean;
    class function IsThreeOfAKind(const ACards: TArray<String>; out ACard, AKicker: String): Boolean;
    class function IsTwoPairs(const ACards: TArray<String>; out AOverCard, AUnderCard, AKicker: String): Boolean;
    class function IsPair(const ACards: TArray<String>; out ACard, AKicker: String): Boolean;
  public
    class function GetHandStrength(APlayerCards, ATableCards: String; const AGameType: TGameType; const AShort: Boolean): String;
  end;


implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.Common.Misc, Winapi.Windows, System.SysUtils;

const
  RANKS = '23456789tjqka';
  SUITS = 'hsdc';

class procedure THandStrengthCalculator.SortCards(var ACards: TArray<String>);
var
  C1, C2: Integer;
  r1, r2: Char;
  card: String;
begin
  for C1 := 0 to Length(ACards) - 2 do
    for C2 := C1 + 1 to Length(ACards) - 1 do
    begin
      r1 := ACards[C1][1];
      r2 := ACards[C2][1];
      if Pos(r1, RANKS) < Pos(r2, RANKS) then
      begin
        card := ACards[C2];
        ACards[C2] := ACards[C1];
        ACards[C1] := card;
      end;
    end;
end;

class function THandStrengthCalculator.ShortCardToLong(const ACard: Char; const APlural: Boolean = FALSE): String;
begin
  result := '';

  case ACard of
    '2': if APlural then
           result := 'Deuces'
         else
           result := 'Two';

    '3': if APlural then
           result := 'Treys'
         else
           result := 'Three';

    '4': if APlural then
           result := 'Fours'
         else
           result := 'Four';

    '5': if APlural then
           result := 'Fives'
         else
           result:= 'Five';

    '6': if APlural then
           result := 'Sixes'
         else
           result := 'Six';

    '7': if APlural then
           result := 'Sevens'
         else
           result := 'Seven';

    '8': if APlural then
           result := 'Eights'
         else
           result := 'Eight';

    '9': if APlural then
           result := 'Nines'
         else
           result := 'Nine';

    't': if APlural then
           result := 'Tens'
         else
           result := 'Ten';

    'j': if APlural then
           result := 'Jacks'
         else
           result := 'Jack';

    'q': if APlural then
           result := 'Queens'
         else
           result := 'Queen';

    'k': if APlural then
           result := 'Kings'
         else
           result := 'King';

    'a': if APlural then
           result := 'Aces'
         else
           result := 'Ace';
  else
    result := '?';
  end;
end;

class function THandStrengthCalculator.IsRoyalFlush(const ACards: TArray<String>): Boolean;
const
  CHAIN_STR = 'akqjt';
var
  C1, C2, C3: Integer;
  match: Boolean;
begin
  if Length(ACards) < 5 then
    Exit(FALSE);

  for C1 := 1 to Length(SUITS) do
  begin
    for C2 := 1 to Length(CHAIN_STR) do
    begin
      match := FALSE;
      for C3 := Low(ACards) to High(ACards) do
        if (ACards[C3][2] = SUITS[C1]) and
           (ACards[C3][1] = CHAIN_STR[C2]) then
        begin
          match := TRUE;
          Break;
        end;

      if not match then
        Break;
    end;

    if match then
      Exit(TRUE);
  end;

  Exit(FALSE);
end;

class function THandStrengthCalculator.IsStraightFlush(const ACards: TArray<String>; out ACard: String): Boolean;
var
  cards: array[1..4] of TArray<String>;
  card: String;
  C1, si: Integer;
begin
  if Length(ACards) < 5 then
    Exit(FALSE);

  for C1 := Low(ACards) to High(ACards) do
  begin
    si := Pos(ACards[C1][2], SUITS);
    if si = 0 then
      Continue;

    SetLength(cards[si], Length(cards[si]) + 1);
    cards[si][Length(cards[si]) - 1] := ACards[C1];
  end;

  for C1 := Low(cards) to High(cards) do
    if IsStraight(cards[C1], card) then
    begin
      ACard := card;
      Exit(TRUE);
    end;

  Exit(FALSE);
end;

class function THandStrengthCalculator.IsFourOfAKind(const ACards: TArray<String>; out ACard, AKicker: String): Boolean;
var
  C1, p, four_of_a_kind_index: Integer;
  card_count: array[1..13] of Integer;
begin
  if Length(ACards) < 4 then
    Exit(FALSE);

  FillChar(card_count, Length(card_count) * SizeOf(Integer), 0);
  for C1 := Low(ACards) to High(ACards) do
  begin
    p := Pos(ACards[C1][1], RANKS);
    if p <> 0 then
      Inc(card_count[p]);
  end;

  four_of_a_kind_index := 0;
  for C1 := High(card_count) downto Low(card_count) do
    if card_count[C1] >= 4 then
    begin
      four_of_a_kind_index := C1;
      Break;
    end;

  if four_of_a_kind_index = 0 then
    Exit(FALSE);

  ACard := RANKS[four_of_a_kind_index];

  for C1 := High(card_count) downto Low(card_count) do
    if (card_count[C1] > 0) and
       (C1 <> four_of_a_kind_index) then
    begin
      AKicker := RANKS[C1];
      Break;
    end;

  Exit(TRUE);
end;

class function THandStrengthCalculator.IsFullHouse(const ACards: TArray<String>; out AOverCard, AUnderCard: String): Boolean;
var
  C1, p: Integer;
  card_count: array[1..13] of Integer;
  over_card_index, under_card_index: Integer;
begin
  if Length(ACards) < 5 then
    Exit(FALSE);

  FillChar(card_count, Length(card_count) * SizeOf(Integer), 0);
  for C1 := Low(ACards) to High(ACards) do
  begin
    p := Pos(ACards[C1][1], RANKS);
    if p <> 0 then
      Inc(card_count[p]);
  end;

  over_card_index := 0;
  for C1 := High(card_count) downto Low(card_count) do
    if card_count[C1] >= 3 then
    begin
      over_card_index := C1;
      Break;
    end;
  if over_card_index = 0 then
    Exit(FALSE);

  under_card_index := 0;
  for C1 := High(card_count) downto Low(card_count) do
    if (card_count[C1] >= 2) and
       (C1 <> over_card_index) then
    begin
      under_card_index := C1;
      Break;
    end;
  if under_card_index = 0 then
    Exit(FALSE);

  AOverCard := RANKS[over_card_index];
  AUnderCard := RANKS[under_card_index];

  Exit(TRUE);
end;

class function THandStrengthCalculator.IsFlush(const ACards: TArray<String>; out ACard: String): Boolean;
var
  C1, p: Integer;
  suits_count: array[1..4] of Integer;
  suit_index: Integer;
begin
  if Length(ACards) < 5 then
    Exit(FALSE);

  FillChar(suits_count, Length(suits_count) * SizeOf(Integer), 0);
  for C1 := Low(ACards) to High(ACards) do
  begin
    p := Pos(ACards[C1][2], SUITS);
    if p <> 0 then
      Inc(suits_count[p]);
  end;

  suit_index := 0;
  for C1 := Low(suits_count) to High(suits_count) do
    if suits_count[C1] >= 5 then
    begin
      suit_index := C1;
      Break;
    end;

  if suit_index = 0 then
    Exit(FALSE);

  ACard := RANKS[1];
  for C1 := Low(ACards) to High(ACards) do
    if (SUITS[suit_index] = ACards[C1][2]) and
       (Pos(ACards[C1][1], RANKS) > Pos(ACard, RANKS)) then
      ACard := ACards[C1][1];
  ACard := ACard + SUITS[suit_index];
  Exit(TRUE);
end;

class function THandStrengthCalculator.IsStraight(const ACards: TArray<String>; out ACard: String): Boolean;
var
  custom_cards: TArray<String>;
  C1: Integer;
  reduce: Integer;
  prevcard: Char;
  chain: Integer;
  cpos: Integer;
  prevpos: Integer;
begin
  // check if ace is last, and exit immediately, it doesnt make sense for ace to be last, and more importantly,
  // it would cause dead while loop which copies aces from beginning to end of array
  if (Length(ACards) < 5) or
     (ACards[High(ACards)][1] = 'a') then
    Exit(FALSE);

  // eliminate duplicates
  reduce := 0;
  prevcard := ' ';
  SetLength(custom_cards, Length(ACards));
  for C1 := Low(ACards) to High(ACards) do
    if prevcard <> ACards[C1][1] then
    begin
      custom_cards[C1 - reduce] := ACards[C1];
      prevcard := ACards[C1][1];
    end
    else
      Inc(reduce);
  if reduce > 0 then
    SetLength(custom_cards, Length(custom_cards) - reduce);

  result := FALSE;
  chain := 0;
  prevpos := 0;
  for C1 := Low(custom_cards) to High(custom_cards) do
  begin
    cpos := Pos(custom_cards[C1][1], RANKS);
    if (cpos = prevpos - 1) or
       (prevpos = 0) then
    begin
      Inc(chain);
      prevpos := cpos;

      if chain >= 5 then
      begin
        ACard := custom_cards[C1 - 4];
        Exit(TRUE);
      end;
    end
    else
    begin
      chain := 1;
      prevpos := cpos;
    end;
  end;

  // special case for straight, where A is low card
  if (custom_cards[Low(custom_cards)][1] = 'a') and
     (custom_cards[High(custom_cards)][1] = '2') and
     (custom_cards[High(custom_cards) - 1][1] = '3') and
     (custom_cards[High(custom_cards) - 2][1] = '4') and
     (custom_cards[High(custom_cards) - 3][1] = '5') then
  begin
    ACard := custom_cards[High(custom_cards) - 3];
    result := TRUE;
  end;
end;

class function THandStrengthCalculator.IsThreeOfAKind(const ACards: TArray<String>; out ACard, AKicker: String): Boolean;
var
  C1, p: Integer;
  card_count: array[1..13] of Integer;
  three_of_a_kind_index: Integer;
begin
  if Length(ACards) < 3 then
    Exit(FALSE);

  FillChar(card_count, Length(card_count) * SizeOf(Integer), 0);
  for C1 := Low(ACards) to High(ACards) do
  begin
    p := Pos(ACards[C1][1], RANKS);
    if p <> 0 then
      Inc(card_count[p]);
  end;

  three_of_a_kind_index := 0;
  for C1 := High(card_count) downto Low(card_count) do
    if card_count[C1] >= 3 then
    begin
      three_of_a_kind_index := C1;
      Break;
    end;
  if three_of_a_kind_index = 0 then
    Exit(FALSE);

  ACard := RANKS[three_of_a_kind_index];

  AKicker := '';
  for C1 := High(card_count) downto Low(card_count) do
    if card_count[C1] > 0 then
    begin
      AKicker := RANKS[C1];
      Break;
    end;

  Exit(TRUE);
end;

class function THandStrengthCalculator.IsTwoPairs(const ACards: TArray<String>; out AOverCard, AUnderCard, AKicker: String): Boolean;
var
  C1, p: Integer;
  card_count: array[1..13] of Integer;
  over_card_index, under_card_index: Integer;
begin
  if Length(ACards) < 4 then
    Exit(FALSE);

  FillChar(card_count, Length(card_count) * SizeOf(Integer), 0);
  for C1 := Low(ACards) to High(ACards) do
  begin
    p := Pos(ACards[C1][1], RANKS);
    if p <> 0 then
      Inc(card_count[p]);
  end;

  over_card_index := 0;
  for C1 := High(card_count) downto Low(card_count) do
    if card_count[C1] >= 2 then
    begin
      over_card_index := C1;
      Break;
    end;
  if over_card_index = 0 then
    Exit(FALSE);

  under_card_index := 0;
  for C1 := High(card_count) downto Low(card_count) do
    if (card_count[C1] >= 2) and
       (C1 <> over_card_index) then
    begin
      under_card_index := C1;
      Break;
    end;
  if under_card_index = 0 then
    Exit(FALSE);

  AOverCard := RANKS[over_card_index];
  AUnderCard := RANKS[under_card_index];

  AKicker := '';
  for C1 := High(card_count) downto Low(card_count) do
    if (card_count[C1] > 0) and
       (C1 <> over_card_index) and
       (C1 <> under_card_index) then
    begin
      AKicker := RANKS[C1];
      Break;
    end;

  Exit(TRUE);
end;

class function THandStrengthCalculator.IsPair(const ACards: TArray<String>; out ACard, AKicker: String): Boolean;
var
  C1, p: Integer;
  card_count: array[1..13] of Integer;
  card_index: Integer;
begin
  if Length(ACards) < 2 then
    Exit(FALSE);

  FillChar(card_count, Length(card_count) * SizeOf(Integer), 0);
  for C1 := Low(ACards) to High(ACards) do
  begin
    p := Pos(ACards[C1][1], RANKS);
    if p <> 0 then
      Inc(card_count[p]);
  end;

  card_index := 0;
  for C1 := High(card_count) downto Low(card_count) do
    if card_count[C1] >= 2 then
    begin
      card_index := C1;
      Break;
    end;
  if card_index = 0 then
    Exit(FALSE);

  ACard := RANKS[card_index];

  AKicker := '';
  for C1 := High(card_count) downto Low(card_count) do
    if (card_count[C1] > 0) and
       (C1 <> card_index) then
    begin
      AKicker := RANKS[C1];
      Break;
    end;

  Exit(TRUE);
end;

class function THandStrengthCalculator.GetHandStrength(APlayerCards, ATableCards: String; const AGameType: TGameType; const AShort: Boolean): String;
var
  cards: TArray<String>;
  C1, C2, C3: Integer;
  pcardscount, tcardscount: Integer;
  card, kicker, overcard, undercard: String;
  pcombs, tcombs: TArray<String>;
  check_combs: TArray<TArray<String>>;
  best_comb_index: Integer;
  index, index1: Integer;
  best_kicker, best_undercard, best_card: Integer;
begin
  Assert(Length(APlayerCards) mod 2 = 0);
  Assert(Length(ATableCards) mod 2 = 0);
  pcardscount := Length(APlayerCards) div 2;
  tcardscount := Length(ATableCards) div 2;
  APlayerCards := LowerCase(APlayerCards);
  ATableCards := LowerCase(ATableCards);

  case AGameType of
    gtHoldem: begin
      SetLength(check_combs, 1);
      SetLength(check_combs[0], pcardscount + tcardscount);
      index := 0;
      for C1 := 0 to pcardscount - 1 do
      begin
        check_combs[0][index] := Copy(APlayerCards, C1 * 2 + 1, 2);
        Inc(index);
      end;
      for C1 := 0 to tcardscount - 1 do
      begin
        check_combs[0][index] := Copy(ATableCards, C1 * 2 + 1, 2);
        Inc(index);
      end;
    end;

    gtOmaha: begin
      SetLength(cards, pcardscount);
      for C1 := 0 to pcardscount - 1 do
        cards[C1] := Copy(APlayerCards, C1 * 2 + 1, 2);
      GetAllCombinations(cards, 2, pcombs);

      SetLength(cards, tcardscount);
      for C1 := 0 to tcardscount - 1 do
        cards[C1] := Copy(ATableCards, C1 * 2 + 1, 2);
      GetAllCombinations(cards, 3, tcombs);

      index := 0;
      SetLength(check_combs, Length(pcombs) * Length(tcombs));
      if Length(tcombs) = 0 then // case when there are no table cards (pre-flop omaha)
      begin
        SetLength(check_combs, Length(pcombs));
        for C1 := Low(pcombs) to High(pcombs) do
        begin
          SetLength(check_combs[index], Length(pcombs[C1]) div 2);
          index1 := 0;
          for C2 := 0 to Length(pcombs[C1]) div 2 - 1 do
          begin
            check_combs[index][index1] := Copy(pcombs[C1], C2 * 2 + 1, 2);
            Inc(index1);
          end;
          Inc(index);
        end;
      end
      else
        for C1 := Low(pcombs) to High(pcombs) do
          for C2 := Low(tcombs) to High(tcombs) do
          begin
            SetLength(check_combs[index], (Length(pcombs[C1]) + Length(tcombs[C2])) div 2);
            index1 := 0;
            for C3 := 0 to Length(pcombs[C1]) div 2 - 1 do
            begin
              check_combs[index][index1] := Copy(pcombs[C1], C3 * 2 + 1, 2);
              Inc(index1);
            end;
            for C3 := 0 to Length(tcombs[C2]) div 2 - 1 do
            begin
              check_combs[index][index1] := Copy(tcombs[C2], C3 * 2 + 1, 2);
              Inc(index1);
            end;
            Inc(index);
          end;
    end;
  else
    Exit('');
  end;

  best_card := -1;
  best_kicker := -1;
  best_undercard := -1;
  best_comb_index := 1000;
  for C1 := Low(check_combs) to High(check_combs) do
  begin
    SortCards(check_combs[C1]);

    if IsRoyalFlush(check_combs[C1]) then
    begin
      if best_comb_index > 0 then
      begin
        best_comb_index := 0;
        result := 'Royal Flush'
      end;
    end
    else
      if IsStraightFlush(check_combs[C1], card) then
      begin
        if best_comb_index > 1 then
        begin
          best_comb_index := 1;
          if AShort then
            result := 'Straight Flush'
          else
            result := Format('%s high Straight Flush', [ShortCardToLong(card[1])])
        end;
      end
      else
        if IsFourOfAKind(check_combs[C1], card, kicker) then
        begin
          if best_comb_index >= 2 then
          begin
            if best_comb_index = 2 then
            begin
              if (Pos(card[1], RANKS) < best_card) or
                 ((Pos(card[1], RANKS) = best_card) and
                  (Pos(kicker[1], RANKS) < best_kicker)) then
                Continue;
            end;

            best_card := Pos(card[1], RANKS);
            best_kicker := Pos(kicker[1], RANKS);

            best_comb_index := 2;
            if AShort then
              result := 'Four of a Kind'
            else
              result := Format('Four %s', [ShortCardToLong(card[1], TRUE)])
          end;
        end
        else
          if IsFullHouse(check_combs[C1], overcard, undercard) then
          begin
            if best_comb_index >= 3 then
            begin
              if best_comb_index = 3 then
              begin
                if (Pos(overcard[1], RANKS) < best_card) or
                   ((Pos(overcard[1], RANKS) = best_card) and
                    (Pos(undercard[1], RANKS) < best_undercard)) then
                  Continue;
              end;

              best_card := Pos(overcard[1], RANKS);
              best_undercard := Pos(undercard[1], RANKS);

              best_comb_index := 3;
              if AShort then
                result := 'Full House'
              else
                result := Format('%s Full over %s', [ShortCardToLong(overcard[1], TRUE), ShortCardToLong(undercard[1], TRUE)])
            end;
          end
          else
            if IsFlush(check_combs[C1], card) then
            begin
              if best_comb_index >= 4 then
              begin
                if best_comb_index = 4 then
                begin
                  if Pos(card[1], RANKS) < best_card then
                    Continue;
                end;

                best_card := Pos(card[1], RANKS);

                best_comb_index := 4;
                if AShort then
                  result := 'Flush'
                else
                  result := Format('%s high Flush', [ShortCardToLong(card[1])])
              end;
            end
            else
              if IsStraight(check_combs[C1], card) then
              begin
                if best_comb_index >= 5 then
                begin
                  if best_comb_index = 5 then
                  begin
                    if Pos(card[1], RANKS) < best_card then
                      Continue;
                  end;

                  best_card := Pos(card[1], RANKS);

                  best_comb_index := 5;
                  if AShort then
                    result := 'Straight'
                  else
                    result := Format('%s high Straight', [ShortCardToLong(card[1])])
                end;
              end
              else
                if IsThreeOfAKind(check_combs[C1], card, kicker) then
                begin
                  if best_comb_index >= 6 then
                  begin
                    if best_comb_index = 6 then
                    begin
                      if (Pos(card, RANKS) < best_card) or
                         ((Pos(card, RANKS) = best_card) and
                          (Pos(kicker, RANKS) < best_kicker)) then
                        Continue;
                    end;

                    best_card := Pos(card, RANKS);
                    best_kicker := Pos(kicker, RANKS);

                    best_comb_index := 6;
                    if AShort then
                      result := 'Three of a Kind'
                    else
                      result := Format('Three %s', [ShortCardToLong(card[1], TRUE)])
                  end;
                end
                else
                  if IsTwoPairs(check_combs[C1], overcard, undercard, kicker) then
                  begin
                    if best_comb_index >= 7 then
                    begin
                      if best_comb_index = 7 then
                      begin
                        if (Pos(overcard, RANKS) < best_card) or
                           ((Pos(overcard, RANKS) = best_card) and
                            (Pos(undercard, RANKS) < best_undercard)) or
                           ((Pos(overcard, RANKS) = best_card) and
                            (Pos(undercard, RANKS) = best_undercard) and
                            (Pos(kicker, RANKS) < best_kicker)) then
                          Continue;
                      end;

                      best_card := Pos(overcard, RANKS);
                      best_undercard := Pos(undercard, RANKS);
                      best_kicker := Pos(kicker, RANKS);

                      best_comb_index := 7;
                      if AShort then
                        result := 'Two Pairs'
                      else
                        result := Format('Two Pairs, %s and %s with %s kicker', [ShortCardToLong(overcard[1], TRUE), ShortCardToLong(undercard[1], TRUE), ShortCardToLong(kicker[1])])
                    end;
                  end
                  else
                    if IsPair(check_combs[C1], card, kicker) then
                    begin
                      if best_comb_index >= 8 then
                      begin
                        if best_comb_index = 8 then
                        begin
                          if (Pos(card, RANKS) < best_card) or
                             ((Pos(card, RANKS) = best_card) and
                              (Pos(kicker, RANKS) < best_kicker)) then
                            Continue;
                        end;

                        best_card := Pos(card, RANKS);
                        best_kicker := Pos(kicker, RANKS);

                        best_comb_index := 8;
                        if AShort then
                          result := 'One Pair'
                        else
                          result := Format('Pair of %s with %s kicker', [ShortCardToLong(card[1], TRUE), ShortCardToLong(kicker[1])])
                      end;
                    end
                    else
                      if Length(check_combs[C1]) > 0 then
                      begin
                        if best_comb_index >= 9 then
                        begin
                          if best_comb_index = 9 then
                          begin
                            if Pos(check_combs[C1][0][1], RANKS) < best_card then
                              Continue;
                          end;

                          best_card := Pos(check_combs[C1][0][1], RANKS);

                          best_comb_index := 9;
                          result := Format('%s high', [ShortCardToLong(check_combs[C1][0][1])])
                        end;
                      end
                      else
                        result := '';
  end;
end;


end.
