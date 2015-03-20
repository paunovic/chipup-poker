unit Poker.Tables.RenderMetrics;

interface

uses
  Winapi.Windows, Asphyre.Math, Asphyre.Types, Poker.Games.Game, Poker.Seats.Seat,
  System.Types;

type
  TTableSector = (tsTopLeft, tsTop, tsTopRight, tsRight, tsBottomRight, tsBottom, tsBottomLeft, tsLeft, tsMid);

  TTableRenderMetrics = class
  private
    FLastDXAreaSize: TPoint2px;
    FTableResizeRatio: Single;
    FRawTableBounds: TPoint4;
    FTableWidth: Single;
    FTableHeight: Single;
    FTableBounds: TPoint4;
    FTableCenterYOffset: Single;
    FTableCenter: TPoint2;
    FDealerPoint: TPoint2;
    FSeatWidth: Single;
    FSeatHeight: Single;
    FSeatResizeRatio: Single;
    FSeatActionResizeRatio: Single;
    FCardWidth: Single;
    FCardHeight: Single;
    FCardArtworkWidth: Single;
    FCardArtworkHeight: Single;
    FSeatCardsMaxWidth: Single;
    FChipWidth: Single;
    FChipHeight: Single;
    FDealerButtonWidth: Single;
    FDealerButtonHeight: Single;
    FTimebarWidth: Single;
    FTimebarHeight: Single;
    FSeatActionFrameWidth: Single;
    FSeatActionFrameHeight: Single;
    FLowerIntfBorder: Integer;
    FActionButtonWidth: Single;
    FActionButtonHeight: Single;
    FRaisePanelResizeRatio: Single;
    FRaisePanelBounds: TPoint4;
    FRaiseTrackBounds: TPoint4;
    FRaiseThumbBounds: TPoint4;
    FRaisePresetButtonWidth: Single;
    FRaisePresetButtonHeight: Single;
    FRaisePresetButtonsBounds: TArray<TPoint4>;
    FActionButtonsBounds: TArray<TPoint4>;
    FStandUpResizeRatio: Single;
    FStandUpButtonWidth: Single;
    FStandUpButtonHeight: Single;
    FStandUpButtonBounds: TPoint4;
    FTotalRakePoint: TPoint2;
    FPlayNowResizeRatio: Single;
    FPlayNowButtonWidth: Single;
    FPlayNowButtonHeight: Single;
    FJoinWaitingListResizeRatio: Single;
    FJoinWaitingListButtonWidth: Single;
    FJoinWaitingListButtonHeight: Single;
    FLeaveWaitingListResizeRatio: Single;
    FLeaveWaitingListButtonWidth: Single;
    FLeaveWaitingListButtonHeight: Single;
    FPlayNowButtonBounds: TPoint4;
    FJoinWaitingListButtonBounds: TPoint4;
    FLeaveWaitingListButtonBounds: TPoint4;
    FRaiseAmountBoxBounds: TRect;
    FHandPlaybackPreviousHand: TRect;
    FHandPlaybackNextHand: TRect;
    FRaiseAmountBoxFontSize: Integer;
    FChatBoxBounds: TRect;
    FChatEditBounds: TRect;
    FCheckboxesLeft: Integer;
    FHandPlaybackProgress: TRect;
    FHandPlaybackPlay: TRect;
    FHandPlaybackBack: TRect;
    FHandPlaybackForward: TRect;
  public
    const
      CARD_OPEN_PERC   = 0.55;
      CARD_HIDDEN_PERC = 0.35;
      CARD_FOLDED_PERC = 0.55;

    function GetTableSector(const APoint: TPoint2): TTableSector;
    function GetSeatPoint(const AGame: TGameInfo; const ASeatIndex: Integer): TPoint2;
    function GetCardPoint(const AGame: TGameInfo; const ASeatInfo: TSeatInfo; const ACardIndex: Integer): TPoint2;
    function GetDealerPoint(const AGame: TGameInfo; const ASeatIndex: Integer): TPoint2;
    function GetBetPoint(const AGame: TGameInfo; const ASeatIndex, ACurrentDealer: Integer): TPoint2;
    function GetPotPoint(const APotIndex: Integer): TPoint2;
    function IsPointInSeat(const AGame: TGameInfo; const AX, AY: Integer; out ASeatIndex: Integer): Boolean;
    function IsPointInRaiseThumb(const AX, AY: Integer): Boolean;
    function IsPointInRaiseTrack(const AX, AY: Integer; out APercentage: Single): Boolean;

    procedure Update(const ATable: TObject; const ADXAreaSize: TPoint2px; const ARaiseThumbPosition: Single);

    property TableResizeRatio: Single read FTableResizeRatio;
    property RawTableBounds: TPoint4 read FRawTableBounds;
    property TableWidth: Single read FTableWidth;
    property TableHeight: Single read FTableHeight;
    property TableBounds: TPoint4 read FTableBounds;
    property TableCenterYOffset: Single read FTableCenterYOffset;
    property TableCenter: TPoint2 read FTableCenter;
    property SeatResizeRatio: Single read FSeatResizeRatio;
    property SeatWidth: Single read FSeatWidth;
    property SeatHeight: Single read FSeatHeight;
    property CardWidth: Single read FCardWidth;
    property CardHeight: Single read FCardHeight;
    property SeatCardsMaxWidth: Single read FSeatCardsMaxWidth;
    property SeatActionFrameWidth: Single read FSeatActionFrameWidth;
    property SeatActionFrameHeight: Single read FSeatActionFrameHeight;
    property TimebarWidth: Single read FTimebarWidth;
    property TimebarHeight: Single read FTimebarHeight;
    property DealerPoint: TPoint2 read FDealerPoint;
    property DealerButtonWidth: Single read FDealerButtonWidth;
    property DealerButtonHeight: Single read FDealerButtonHeight;
    property ChipWidth: Single read FChipWidth;
    property ChipHeight: Single read FChipHeight;
    property ChatBoxBounds: TRect read FChatBoxBounds;
    property ChatEditBounds: TRect read FChatEditBounds;
    property CheckboxesLeft: Integer read FCheckboxesLeft;
    property RaiseAmountBoxBounds: TRect read FRaiseAmountBoxBounds;
    property RaiseTrackBounds: TPoint4 read FRaiseTrackBounds;
    property RaisePanelBounds: TPoint4 read FRaisePanelBounds;
    property RaiseThumbBounds: TPoint4 read FRaiseThumbBounds;
    property RaiseAmountBoxFontSize: Integer read FRaiseAmountBoxFontSize;
    property HandPlaybackProgress: TRect read FHandPlaybackProgress;
    property HandPlaybackPlay: TRect read FHandPlaybackPlay;
    property HandPlaybackBack: TRect read FHandPlaybackBack;
    property HandPlaybackForward: TRect read FHandPlaybackForward;
    property HandPlaybackNextHand: TRect read FHandPlaybackNextHand;
    property HandPlaybackPreviousHand: TRect read FHandPlaybackPreviousHand;
    property StandUpButtonBounds: TPoint4 read FStandUpButtonBounds;
    property PlayNowButtonBounds: TPoint4 read FPlayNowButtonBounds;
    property JoinWaitingListButtonBounds: TPoint4 read FJoinWaitingListButtonBounds;
    property LeaveWaitingListButtonBounds: TPoint4 read FLeaveWaitingListButtonBounds;
    property RaisePresetButtonsBounds: TArray<TPoint4> read FRaisePresetButtonsBounds;
    property ActionButtonsBounds: TArray<TPoint4> read FActionButtonsBounds;
    property TotalRakePoint: TPoint2 read FTotalRakePoint;
  end;


implementation

uses
  System.SysUtils, Poker.Tables.Resources, Poker.Common.Misc, Poker.Tables.Table,
  Poker.Protobufs.Objects.TableStatus, Poker.SoftExceptions;

{ TTableRenderMetrics }

function TTableRenderMetrics.GetTableSector(const APoint: TPoint2): TTableSector;
var
  points: array[0..3] of TPoint2;
begin
  points[0] := Point2(TableCenter.X - SeatWidth / 4, TableCenter.Y - SeatHeight / 2.5);
  points[1] := Point2(TableCenter.X + SeatWidth / 4, TableCenter.Y - SeatHeight / 2.5);
  points[2] := Point2(TableCenter.X - SeatWidth / 4, TableCenter.Y + SeatHeight / 2.5);
  points[3] := Point2(TableCenter.X + SeatWidth / 4, TableCenter.Y + SeatHeight / 2.5);

  if APoint.X < points[0].X then
  begin
    if APoint.Y < points[0].y then
      result := tsTopLeft
    else
      if APoint.Y > points[2].y then
        result := tsBottomLeft
      else
        result := tsLeft
  end
  else
    if APoint.X > points[1].X then
    begin
      if APoint.Y < points[0].y then
        result := tsTopRight
      else
        if APoint.Y > points[2].y then
          result := tsBottomRight
        else
          result := tsRight
    end
    else
      if APoint.Y < points[0].y then
        result := tsTop
      else
        if APoint.Y > points[2].y then
          result := tsBottom
        else
          result := tsMid;
end;

function TTableRenderMetrics.GetSeatPoint(const AGame: TGameInfo; const ASeatIndex: Integer): TPoint2;
var
  seat_radians: Double;
  x, y: Single;
  pf: TPointF;
begin
  seat_radians := TTableResources.SEAT_POINTS[AGame.Seats, ASeatIndex];

  x := TableCenter.X + (TableWidth * 0.9 / 2) * Cos(seat_radians);
  y := TableCenter.Y - TableCenterYOffset + (TableHeight * 0.95 / 2) * Sin(seat_radians) - 8 * TableResizeRatio;

  pf := PointF(x, y);

  case GetTableSector(Point2(x, y)) of
    tsTopLeft: pf.Offset(-SeatWidth / 2.35, -SeatHeight / 2);
    tsLeft: pf.Offset(-SeatWidth / 2.35, 0);
    tsBottomLeft: pf.Offset(-SeatWidth / 2.35, SeatHeight / 2);
    tsBottom: pf.Offset(0, SeatHeight / 1.55);
    tsBottomRight: pf.Offset(SeatWidth / 2.35, SeatHeight / 2);
    tsRight: pf.Offset(SeatWidth / 2.35, 0);
    tsTopRight: pf.Offset(SeatWidth / 2.35, -SeatHeight / 2);
    tsTop: pf.Offset(0, -SeatHeight / 2);
  end;

  result := Point2(pf.x, pf.y);
end;

function TTableRenderMetrics.GetBetPoint(const AGame: TGameInfo; const ASeatIndex, ACurrentDealer: Integer): TPoint2;
var
  seat_radians: Double;
  x, y: Single;
  xr, yr: Single;
begin
  if ACurrentDealer = ASeatIndex then
  begin
    xr := TableWidth / 1.51;
    yr := TableHeight / 2;
  end
  else
  begin
    xr := TableWidth / 1.26;
    yr := TableHeight / 1.45;
  end;

  seat_radians := TTableResources.SEAT_POINTS[AGame.Seats, ASeatIndex];
  x := TableCenter.X + (xr / 2) * Cos(seat_radians);
  y := TableCenter.Y - TableCenterYOffset + (yr / 2) * Sin(seat_radians) - 40 * TableResizeRatio;
  result := Point2(x, y);
end;

function TTableRenderMetrics.GetCardPoint(const AGame: TGameInfo; const ASeatInfo: TSeatInfo; const ACardIndex: Integer): TPoint2;
var
  seat_point: TPoint2;
  cards_width: Single;
  cards_overlap_width: Single;
  cards_starting_x: Single;
  perc: Single;
begin
  seat_point := GetSeatPoint(AGame, ASeatInfo.SeatIndex);
  cards_width := ASeatInfo.CardCount * CardWidth;
  if (cards_width > SeatCardsMaxWidth) and
     (ASeatInfo.CardCount > 1) then
  begin
    cards_overlap_width := (cards_width - SeatCardsMaxWidth) / (ASeatInfo.CardCount - 1);
    cards_starting_x := seat_point.X - SeatCardsMaxWidth / 2;
  end
  else
  begin
    cards_overlap_width := 1;
    cards_starting_x := seat_point.X - (ASeatInfo.CardCount * (CardWidth + cards_overlap_width) - 1) / 2;
  end;

  if ((ACardIndex >= 0) and (ACardIndex < ASeatInfo.Cards.Count)) and
     (ASeatInfo.Cards[0].IsKnown) then
    perc := CARD_OPEN_PERC
  else
    perc := CARD_HIDDEN_PERC;

  result := Point2(cards_starting_x + ACardIndex * (CardWidth - cards_overlap_width), seat_point.Y - SeatHeight / 2 - CardHeight * perc);
end;

function TTableRenderMetrics.GetDealerPoint(const AGame: TGameInfo; const ASeatIndex: Integer): TPoint2;
var
  seat_radians: Double;
  x, y: Single;
  xr, yr: Single;
begin
  if (AGame.Seats < Low(TableResources.SEAT_POINTS)) or
     (AGame.Seats > High(TableResources.SEAT_POINTS)) then
  begin
    SoftException(Format('Invalid AGame.Seats number [%d]', [AGame.Seats]));
    Exit(Point2(0, 0));
  end;

  xr := TableWidth / 1.25;
  yr := TableHeight / 1.45;

  seat_radians := TTableResources.SEAT_POINTS[AGame.Seats, ASeatIndex];
  x := TableCenter.X + (xr / 2) * Cos(seat_radians);
  y := TableCenter.Y - TableCenterYOffset + (yr / 2) * Sin(seat_radians) - 17 * TableResizeRatio;
  result := Point2(x, y);
end;

function TTableRenderMetrics.GetPotPoint(const APotIndex: Integer): TPoint2;
var
  topy, bottomy: Integer;
begin
  topy := Round(TableCenter.Y - CardHeight - TableResizeRatio * 10);
  bottomy := Round(TableCenter.Y + CardHeight + TableResizeRatio * 16);
  case APotIndex of
    0: result := Point2(TableCenter.X, topy);
    1: result := Point2(TableCenter.X + 60, topy);
    2: result := Point2(TableCenter.X - 60, topy);
    3: result := Point2(TableCenter.X - 60, bottomy);
    4: result := Point2(TableCenter.X + 60, bottomy);
  else
    result := Point2(-1, -1);
  end;
end;

function TTableRenderMetrics.IsPointInRaiseThumb(const AX, AY: Integer): Boolean;
begin
  result := PtInCircle(AX, AY, FRaiseThumbBounds[0].x + (FRaiseThumbBounds[1].x - FRaiseThumbBounds[0].x) / 2,
                  FRaiseThumbBounds[0].y + (FRaiseThumbBounds[2].y - FRaiseThumbBounds[0].y) / 2,
                  (FRaiseThumbBounds[1].x - FRaiseThumbBounds[0].x) / 2);
end;

function TTableRenderMetrics.IsPointInRaiseTrack(const AX, AY: Integer; out APercentage: Single): Boolean;
begin
  result := PtInBounds(Point(AX, AY), FRaiseTrackBounds);
  if result then
    APercentage := (AX - FRaiseTrackBounds[0].x) / (FRaiseTrackBounds[1].x - FRaiseTrackBounds[0].x);
end;

function TTableRenderMetrics.IsPointInSeat(const AGame: TGameInfo; const AX, AY: Integer; out ASeatIndex: Integer): Boolean;
var
  C1: Integer;
  seat_point: TPoint2;
  seat_rect: TRectF;
begin
  for C1 := 0 to AGame.Seats - 1 do
  begin
    seat_point := GetSeatPoint(AGame, C1);
    seat_rect := TRectF.Create(seat_point.X - FSeatWidth / 2, seat_point.Y - FSeatHeight / 2, seat_point.X + FSeatWidth / 2, seat_point.Y + FSeatHeight / 2);
    if (AX >= seat_rect.Left) and (AX <= seat_rect.Right) and
       (AY >= seat_rect.Top) and (AY <= seat_rect.Bottom) then
    begin
      ASeatIndex := C1;
      Exit(TRUE);
    end;
  end;
  Exit(FALSE);
end;

procedure TTableRenderMetrics.Update(const ATable: TObject; const ADXAreaSize: TPoint2px; const ARaiseThumbPosition: Single);
const
  TABLE_X_LEFT = 64;
  TABLE_X_RIGHT = 64;
  TABLE_Y_TOP = 66;
  TABLE_Y_BOTTOM = 133;
  TABLE_Y_OFFSET = -20;
  TABLE_HEIGHT_OF_FORM = 0.715;
var
  C1: Integer;
  w, h: Single;
  wint, hint: Integer;
  area_resized: Boolean;
begin
  area_resized := (ADXAreaSize.x <> FLastDXAreaSize.x) or
                  (ADXAreaSize.y <> FLastDXAreaSize.y);

  if area_resized then
  begin
    // table resize ratio
    FTableResizeRatio := (ADXAreaSize.y * TABLE_HEIGHT_OF_FORM) / TableResources.TableImage.Texture[0].Height;

    // lower interface border
    FLowerIntfBorder := Round(10 * FTableResizeRatio);

    // table raw dimensions, the ones that include table shadow, used to draw table on canvas
    w := TableResources.TableImage.Texture[0].Width * FTableResizeRatio;
    h := TableResources.TableImage.Texture[0].Height * FTableResizeRatio;
    FRawTableBounds := pBounds4((ADXAreaSize.x - w) / 2, (ADXAreaSize.y - h) / 2 + TABLE_Y_OFFSET * FTableResizeRatio, w, h);

    // dimensions of table only, used to calculate position of elements inside it (chips, cards, etc)
    FTableWidth := (FRawTableBounds[1].X - FRawTableBounds[0].X) - (TABLE_X_LEFT + TABLE_X_RIGHT) * FTableResizeRatio;
    FTableHeight := (FRawTableBounds[2].Y - FRawTableBounds[0].Y) - (TABLE_Y_TOP + TABLE_Y_BOTTOM) * FTableResizeRatio;
    FTableBounds := pBounds4(FRawTableBounds[0].X + TABLE_X_LEFT * FTableResizeRatio,
                             FRawTableBounds[0].Y + TABLE_Y_TOP * FTableResizeRatio,
                             FTableWidth,
                             FTableHeight);

    // table center
    FTableCenterYOffset := -28 * FTableResizeRatio;
    FTableCenter.X := FTableBounds[0].X + (FTableBounds[1].X - FTableBounds[0].X) / 2;
    FTableCenter.Y := FTableBounds[0].Y + (FTableBounds[2].Y - FTableBounds[0].Y) / 2 + FTableCenterYOffset;

    // dealer center point (where the cards come from, not dealer button point!)
    FDealerPoint.X := FTableCenter.X;
    FDealerPoint.Y := FTableBounds[0].Y;
  end;

  // seats
  FSeatHeight := (ADXAreaSize.y - (FTableBounds[2].Y - FTableBounds[0].Y)) / 5.2;
  if (ATable as TTable).Game.Seats = 10 then
    FSeatHeight := FSeatHeight * 0.85;

  if area_resized then
  begin
    FSeatWidth := FSeatHeight * TableResources.SeatAspectRatio;
    FSeatResizeRatio := FSeatWidth / TableResources.SeatLeftImage.Texture[0].Width;
    FSeatActionResizeRatio := FSeatResizeRatio * 1.1;

    // cards
    FCardWidth := TableResources.CardBackgroundImage.Texture[0].Width * FTableResizeRatio;
    FCardHeight := FCardWidth / TableResources.CardAspectRatio;
    FCardArtworkWidth := FCardWidth * (0.48 + FTableResizeRatio / 5);
    FCardArtworkHeight := FCardHeight * 0.85;
    FSeatCardsMaxWidth := FSeatWidth * 0.65;
    if FSeatCardsMaxWidth < (FCardWidth * 2) + 2 then
      FSeatCardsMaxWidth := (FCardWidth * 2) + 2;

    // dealer button
    FDealerButtonWidth := TableResources.DealerButtonImage.Texture[0].Width * FTableResizeRatio;
    FDealerButtonHeight := FDealerButtonWidth / TableResources.DealerButtonAspectRatio;

    // chips
    FChipWidth := TableResources.Chip1Image.Texture[0].Width * FTableResizeRatio;
    FChipHeight := FChipWidth / TableResources.ChipAspectRatio;

    // timebar/timebank
    FTimebarWidth := TableResources.TimebarImage.Texture[0].Width * FSeatActionResizeRatio;
    FTimebarHeight := FTimebarWidth / TableResources.TimebarAspectRatio;

    // seat action frame
    FSeatActionFrameWidth := TableResources.SeatActionCheck.Texture[0].Width * FSeatActionResizeRatio;
    FSeatActionFrameHeight := FSeatActionFrameWidth / TableResources.SeatActionFrameAspectRatio;

    // standup button resize ratio
    FStandUpResizeRatio := FTableResizeRatio * 1.5;
    if FStandUpResizeRatio > 1 then
      FStandUpResizeRatio := 1;

    // standup button bounds
    FStandUpButtonWidth := TableResources.StandUpButtonNormalImage.Texture[0].Width * FStandUpResizeRatio;
    FStandUpButtonHeight := FStandUpButtonWidth / TableResources.StandUpButtonAspectRatio;
    FStandUpButtonBounds := pBounds4(ADXAreaSize.x - FStandUpButtonWidth + 1, -1, FStandUpButtonWidth, FStandUpButtonHeight);

    // action buttons bounds
    FActionButtonWidth := TableResources.ActionButtonNormalImage.Texture[0].Width * FTableResizeRatio;
    FActionButtonHeight := FActionButtonWidth / TableResources.ActionButtonAspectRatio;
    SetLength(FActionButtonsBounds, 3);
    FActionButtonsBounds[High(FActionButtonsBounds)] := pBounds4(ADXAreaSize.x - FLowerIntfBorder * 1.5 - FActionButtonWidth,
                                                                 ADXAreaSize.y - FLowerIntfBorder - FActionButtonHeight,
                                                                 FActionButtonWidth, FActionButtonHeight);

    for C1 := High(FActionButtonsBounds) - 1 downto Low(FActionButtonsBounds) do
      FActionButtonsBounds[C1] := pBounds4(FActionButtonsBounds[C1 + 1][0].x - FlowerIntfBorder * 2 - FActionButtonWidth,
                                           FActionButtonsBounds[C1 + 1][0].y, FActionButtonWidth, FActionButtonHeight);

    // raise panel bounds
    w := FActionButtonsBounds[High(FActionButtonsBounds)][0].x + FActionButtonWidth - FActionButtonsBounds[Low(FActionButtonsBounds)][0].x;
    h := Round(w / TableResources.RaiseSliderAspectRatio);
    FRaisePanelResizeRatio := w / TableResources.RaiseSliderBackgroundImage.Texture[0].Width;

    FRaisePanelBounds := pBounds4(FActionButtonsBounds[Low(FActionButtonsBounds)][0].x, FActionButtonsBounds[Low(FActionButtonsBounds)][0].y - FLowerIntfBorder - h, w, h);

    // raise track bounds (track where thumb button moves on)
    FRaiseTrackBounds := pBounds4(FRaisePanelBounds[0].x + TableResources.RAISE_TRACK_LEFT_OFFSET * FRaisePanelResizeRatio,
                                  FRaisePanelBounds[0].y + TableResources.RAISE_TRACK_TOP_OFFSET * FRaisePanelResizeRatio,
                                  TableResources.RAISE_TRACK_SLIDER_WIDTH * FRaisePanelResizeRatio,
                                  TableResources.RAISE_TRACK_SLIDER_HEIGHT * FRaisePanelResizeRatio);
  end;

  if area_resized then
  begin
    // raise preset buttons bounds
    FRaisePresetButtonWidth := TableResources.RaisePresetButtonNormalImage.Texture[0].Width * FTableResizeRatio;
    FRaisePresetButtonHeight := FRaisePresetButtonWidth / TableResources.RaisePresetButtonAspectRatio;

    SetLength(FRaisePresetButtonsBounds, 4);
    FRaisePresetButtonsBounds[High(FRaisePresetButtonsBounds)] := pBounds4(FRaisePanelBounds[1].x - FRaisePresetButtonWidth,
                                                                           FRaisePanelBounds[0].y - FLowerIntfBorder / 2.5 - FRaisePresetButtonHeight,
                                                                           FRaisePresetButtonWidth, FRaisePresetButtonHeight);
    for C1 := High(FRaisePresetButtonsBounds) - 1 downto Low(FRaisePresetButtonsBounds) do
      FRaisePresetButtonsBounds[C1] := pBounds4(FRaisePresetButtonsBounds[C1 + 1][0].x - FLowerIntfBorder - FRaisePresetButtonWidth,
                                                FRaisePresetButtonsBounds[C1 + 1][0].y, FRaisePresetButtonWidth, FRaisePresetButtonHeight);

    // raise amount box bounds
    FRaiseAmountBoxBounds.Left := Round(FRaisePanelBounds[0].x + TableResources.RAISE_VALUEBOX_X * FRaisePanelResizeRatio);
    FRaiseAmountBoxBounds.Top := Round(FRaisePanelBounds[0].y + TableResources.RAISE_VALUEBOX_Y * FRaisePanelResizeRatio);
    FRaiseAmountBoxBounds.Width := Round(TableResources.RAISE_VALUEBOX_WIDTH * FRaisePanelResizeRatio);
    FRaiseAmountBoxBounds.Height := Round(TableResources.RAISE_VALUEBOX_HEIGHT * FRaisePanelResizeRatio);

    // raise amount font size
    if FRaiseAmountBoxBounds.Height < 19 then
      FRaiseAmountBoxFontSize := 7
    else
      if FRaiseAmountBoxBounds.Height < 22 then
        FRaiseAmountBoxFontSize := 9
      else
        FRaiseAmountBoxFontSize := 10;

    // chat box and editbox bounds
    wint := Round(ADXAreaSize.x / 3.15);
    hint := ADXAreaSize.y div 7;
    FChatBoxBounds := TRect.Create(Point(FLowerIntfBorder, ADXAreaSize.y - FLowerIntfBorder - hint - 18), wint, hint);
    FChatEditBounds := TRect.Create(Point(FChatBoxBounds.Left, FChatBoxBounds.Top + FChatBoxBounds.Height), FChatBoxBounds.Width, 18);
    FCheckboxesLeft := FChatBoxBounds.Right + FLowerIntfBorder;

    // playnow and join/leave waiting list button resize ratio
    FPlayNowResizeRatio := FTableResizeRatio * 1.38;
    if FPlayNowResizeRatio > 1 then
      FPlayNowResizeRatio := 1;
    FJoinWaitingListResizeRatio := FPlayNowResizeRatio;
    FLeaveWaitingListResizeRatio := FPlayNowResizeRatio;

    // playnow button bounds
    FPlayNowButtonWidth := TableResources.PlayNowButtonNormalImage.Texture[0].Width * FPlayNowResizeRatio;
    FPlayNowButtonHeight := FPlayNowButtonWidth / TableResources.PlayNowButtonAspectRatio;
    FPlayNowButtonBounds := pBounds4(FChatBoxBounds.Right + (ADXAreaSize.x - FChatBoxBounds.Right) / 2 - FPlayNowButtonWidth / 2,
                                     FChatBoxBounds.Top + (ADXAreaSize.y - FChatBoxBounds.Top) / 2.5 - FPlayNowButtonHeight / 2,
                                     FPlayNowButtonWidth, FPlayNowButtonHeight);

    // join/leave waiting list button bounds
    FJoinWaitingListButtonWidth := TableResources.JoinWaitingListNormal.Texture[0].Width * FJoinWaitingListResizeRatio;
    FJoinWaitingListButtonHeight := FJoinWaitingListButtonWidth / TableResources.JoinWaitingListButtonAspectRatio;

    FLeaveWaitingListButtonWidth := TableResources.LeaveWaitingListNormal.Texture[0].Width * FLeaveWaitingListResizeRatio;
    FLeaveWaitingListButtonHeight := FLeaveWaitingListButtonWidth / TableResources.LeaveWaitingListButtonAspectRatio;

    FJoinWaitingListButtonBounds := FPlayNowButtonBounds;
    FLeaveWaitingListButtonBounds := FPlayNowButtonBounds;

    // hand playback bounds
    wint := Round(ADXAreaSize.x / 2.5);
    hint := 9;
    FHandPlaybackProgress := TRect.Create(Point(Round(ADXAreaSize.x / 2 - wint / 5), FChatBoxBounds.Top), wint, hint);

    wint := 48;
    hint := 48;
    FHandPlaybackPlay := TRect.Create(Point(Round(FHandPlaybackProgress.Left + FHandPlaybackProgress.Width / 2 - wint / 2),
                                            Round(FHandPlaybackProgress.Bottom + 3)), wint, hint);
    FHandPlaybackBack := FHandPlaybackPlay;
    FHandPlaybackBack.Offset(-wint - 3, 0);

    FHandPlaybackForward := FHandPlaybackPlay;
    FHandPlaybackForward.Offset(wint + 3, 0);

    FHandPlaybackPreviousHand := FHandPlaybackBack;
    FHandPlaybackPreviousHand.Offset(-wint - 3, 0);

    FHandPlaybackNextHand := FHandPlaybackForward;
    FHandPlaybackNextHand.Offset(wint + 3, 0);
  end;

  // raise thumb button bounds
  w := TableResources.RaiseSliderButtonImage.Texture[0].Width * FRaisePanelResizeRatio;
  h := w * TableResources.RaiseSliderButtonAspectRatio;
  FRaiseThumbBounds := pBounds4(FRaiseTrackBounds[0].x + ARaiseThumbPosition * (FRaiseTrackBounds[1].x - FRaiseTrackBounds[0].x) - w / 2,
                                FRaiseTrackBounds[0].y + (FRaiseTrackBounds[2].y - FRaiseTrackBounds[0].y) / 2 - h / 2, w, h);

  // total rake bounds
  if ((ATable as TTable).Status.IsSitting) and
     ((ATable as TTable).TableType <> ttHandReplay) then
    FTotalRakePoint := Point2(FStandUpButtonBounds[0].x - 30 * FTableResizeRatio - FChipWidth / 2, FStandUpButtonBounds[0].y + (FStandUpButtonBounds[2].y - FStandUpButtonBounds[0].y) / 4)
  else
    FTotalRakePoint := Point2(FStandUpButtonBounds[1].x - 10 * FTableResizeRatio - FChipWidth / 2, FStandUpButtonBounds[0].y + (FStandUpButtonBounds[2].y - FStandUpButtonBounds[0].y) / 4);

  if area_resized then
    FLastDXAreaSize := ADXAreaSize;
end;

end.
