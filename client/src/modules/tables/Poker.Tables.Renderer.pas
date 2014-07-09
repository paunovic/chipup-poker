unit Poker.Tables.Renderer;

interface

uses
  System.Classes, System.Generics.Collections, System.Types, Vectors2, Vectors2px, AsphyreTypes, AsphyreFonts, Poker.Tables.RenderMetrics,
  Vcl.ActnList, Poker.Games.Game, Poker.Tables.Status, AsphyreImages, Poker.Seats.Seat, Poker.Cards, Poker.ChipStackMaker,
  IdSync, Poker.DirectX.Button, Vcl.Controls, Poker.ChipStackMaker.ChipStack, System.SysUtils, Poker.Protobufs.Objects.Pot;

type
  TDealerChatMessageEvent = procedure(const AMessage: String) of object;
  TSoundPlayEvent = procedure(const ASound: String) of object;
  TTableType = (ttLiveGame, ttHandPlayback);

  TTableRenderer = class;

  TSyncRenderer = class(TIdSync)
  private
    FRenderer: TTableRenderer;
  protected
    procedure DoSynchronize; override;
  public
    class procedure Render(const ARenderer: TTableRenderer);
  end;

  TTableRenderer = class
  private
    FHandle: THandle;
    FSwapChainIndex: Integer;
    FDXAreaSize: TPoint2px;
    FMetrics: TTableRenderMetrics;
    FGameId: TBytes;
    FTableType: TTableType;
    FTableStatus: TTableStatus;
    FTimeImage: TAsphyreImage;
    FRaiseThumbPosition: Single;
    FDrawColor: TColor4;
    FDXButtons: TObjectList<TDXButton>;
    FRenderingFoldedCards: Boolean;

    FFlopAnimations: TList<Integer>;
    FFlopAnimated: Boolean;
    FTurnAnimations: TList<Integer>;
    FTurnAnimated: Boolean;
    FRiverAnimations: TList<Integer>;
    FRiverAnimated: Boolean;
    FDealAnimations: TList<Integer>;
    FBetAnimations: TList<Integer>;
    FPotWinAnimations: TList<Integer>;

    FChipStackMaker: TChipStackMaker;

    FWinningFlopAniDelay: Single;
    FWinningTurnAniDelay: Single;
    FWinningRiverAniDelay: Single;
    FWinningAniDelay: Single;

    FOnDealerChatMessage: TDealerChatMessageEvent;
    FOnSoundPlay: TSoundPlayEvent;
    FOnTimebankStarted: TNotifyEvent;
    FRaiseThumbDown: Boolean;

    function GetGame(out AGame: TGameInfo): Boolean;

    procedure RenderEvent(Sender: TObject);
    procedure RenderBackground;
    procedure RenderTable;
    procedure RenderSeats;
    procedure RenderSeat(const ASeatIndex: Integer);
    procedure RenderCard(const APoint: TPoint2; const ACard: TCard; const APercentage: Single; const ATransparency: Byte = 0);
    procedure RenderScaleFont(const AText: String; const AColor: TColor2; const AMidPoint: TPoint2; const AFonts: array of TAsphyreFont; const ALowBound, AMinIndex, AMaxIndex, AKerning: Integer; const AMaxHeight, AMaxWidth: Single);
    procedure RenderClosingText;
    procedure RenderTimebar;
    procedure RenderTableCards;
    procedure RenderDealerButton;
    procedure RenderDealingCardsAni;
    procedure RenderBets;
    procedure RenderPots;
    procedure RenderValue(const APoint: TPoint2; const AValue: UINT32; const AColor: TColor2; const APot: Boolean);
    procedure RenderChipStack(const APoint: TPoint2; const AChipStack: TChipStack);
    procedure RenderButtons;
    procedure RenderRaisePanel;
  public
    constructor Create(const ASwapChainIndex: Integer; const AGameId: TBytes; const ATableType: TTableType);
    destructor Destroy; override;

    procedure SetRenderTarget(const AHandle: THandle);

    procedure ClearAnimations;

    procedure SetGameId(const AMongoId: TBytes);
    function UpdateDXAreaSize: Boolean;
    procedure Render;

    function AnimateBets(const ACallback: THandle; ABets: TList<UINT32>; const ASeatIndex: Integer = -1): Boolean;
    procedure AnimateBlinds(const ACallback: THandle);
    procedure AnimateWinnerPots(const ACallback: THandle; const APots: TList<TPB_Pot>);
    procedure AnimateDealingCards(const ACallback: THandle);

    procedure AnimationCallback(const AAnimationPointer: pointer);

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer; out ASetRaiseAmount: Boolean);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer; out ASetRaiseAmount: Boolean);
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    property TableStatus: TTableStatus read FTableStatus;

    property Metrics: TTableRenderMetrics read FMetrics;
    property ChipStackMaker: TChipStackMaker read FChipStackMaker;

    property FlopAnimations: TList<Integer> read FFlopAnimations;
    property TurnAnimations: TList<Integer> read FTurnAnimations;
    property RiverAnimations: TList<Integer> read FRiverAnimations;
    property DealAnimations: TList<Integer> read FDealAnimations;
    property BetAnimations: TList<Integer> read FBetAnimations;
    property PotWinAnimations: TList<Integer> read FPotWinAnimations;

    property FlopAnimated: Boolean read FFlopAnimated write FFlopAnimated;
    property TurnAnimated: Boolean read FTurnAnimated write FTurnAnimated;
    property RiverAnimated: Boolean read FRiverAnimated write FRiverAnimated;

    property WinningFlopAniDelay: Single read FWinningFlopAniDelay write FWinningFlopAniDelay;
    property WinningTurnAniDelay: Single read FWinningTurnAniDelay write FWinningTurnAniDelay;
    property WinningRiverAniDelay: Single read FWinningRiverAniDelay write FWinningRiverAniDelay;
    property WinningAniDelay: Single read FWinningAniDelay write FWinningAniDelay;

    property RaiseThumbPosition: Single read FRaiseThumbPosition write FRaiseThumbPosition;

    property OnDealerChatMessage: TDealerChatMessageEvent read FOnDealerChatMessage write FOnDealerChatMessage;
    property OnSoundPlay: TSoundPlayEvent read FOnSoundPlay write FOnSoundPlay;
    property OnTimebankStarted: TNotifyEvent read FOnTimebankStarted write FOnTimebankStarted;

    function AddDXButton(const AAction: TAction; const ABounds: PPoint4; const ANormalImage, ADownImage, AHotImage: TAsphyreImage; const ARenderActionCaption: Boolean = FALSE; const AFontScale: Single = 1): Integer;
    function GetDXButton(const AId: Integer): TDXButton;

    property DXButtons: TObjectList<TDXButton> read FDXButtons;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Winapi.Windows, Poker.DirectX.Core, Poker.Tables.Resources, AbstractCanvas, Poker.Players.PlayerList, Poker.Protobufs.Objects.SeatInfo,
  Poker.Common.Misc, Poker.Protobufs.Objects.TableStatus, Poker.Protobufs.Objects.Game, Poker.Server.Settings, Poker.DirectX.Animation,
  Poker.DirectX.Timer, Poker.Pots.PotList, Poker.Sounds, Poker.HandStrengthCalculator, Poker.Settings, Poker.Players.Player,
  Poker.Avatars.AvatarList, Poker.Avatars.Avatar, Poker.DataModule, Poker.Clubs.Club;

{ TTableRenderer }

constructor TTableRenderer.Create(const ASwapChainIndex: Integer; const AGameId: TBytes; const ATableType: TTableType);
begin
  FSwapChainIndex := ASwapChainIndex;
  FGameId := AGameId;
  FTableType := ATableType;
  FMetrics := TTableRenderMetrics.Create;
  FChipStackMaker := TChipStackMaker.Create;
  FDXButtons := TObjectList<TDXButton>.Create;
  FTableStatus := TTableStatus.Create;

  if FTableType = ttHandPlayback then
    FDrawColor := cAlpha4(150)
  else
    FDrawColor := clWhite4;

  FFlopAnimations := TList<Integer>.Create;
  FFlopAnimated := FALSE;

  FTurnAnimations := TList<Integer>.Create;
  FTurnAnimated := FALSE;

  FRiverAnimations := TList<Integer>.Create;
  FRiverAnimated := FALSE;

  FDealAnimations := TList<Integer>.Create;
  FBetAnimations := TList<Integer>.Create;
  FPotWinAnimations := TList<Integer>.Create;
end;

destructor TTableRenderer.Destroy;
begin
  FDealAnimations.Free;
  FFlopAnimations.Free;
  FTurnAnimations.Free;
  FRiverAnimations.Free;
  FBetAnimations.Free;
  FPotWinAnimations.Free;

  FDXButtons.Free;
  FChipStackMaker.Free;
  FMetrics.Free;
  FreeAndNil(FTableStatus);

  inherited;
end;

function TTableRenderer.GetDXButton(const AId: Integer): TDXButton;
var
  button: TDXButton;
begin
  for button in FDXButtons do
    if button.Id = AId then
      Exit(button);
  Exit(nil);
end;

function TTableRenderer.GetGame(out AGame: TGameInfo): Boolean;
var
  club: TClubInfo;
begin
  result := dmMain.SelfInfo.Clubs.FindGame(FGameId, club, AGame);
end;

procedure TTableRenderer.SetGameId(const AMongoId: TBytes);
begin
  FGameId := AMongoId;
end;

procedure TTableRenderer.SetRenderTarget(const AHandle: THandle);
begin
  FHandle := AHandle;
end;

procedure TTableRenderer.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer; out ASetRaiseAmount: Boolean);
var
  dxbutton: TDXButton;
  percent: Single;
begin
  ASetRaiseAmount := FALSE;

  for dxbutton in FDXButtons do
    dxbutton.MouseDown(Button, Shift, X, Y);

  // check click on raise thumb button
  if FMetrics.IsPointInRaiseThumb(X, Y) then
    FRaiseThumbDown := TRUE
  else
    if FMetrics.IsPointInRaiseTrack(X, Y, percent) then // check click on raise track
    begin
      FRaiseThumbPosition := percent;
      ASetRaiseAmount := TRUE;
    end;
end;

procedure TTableRenderer.MouseMove(Shift: TShiftState; X, Y: Integer; out ASetRaiseAmount: Boolean);
var
  dxbutton: TDXButton;
  percent: Single;
  seat_index: Integer;
  seat: TSeatInfo;
  game: TGameInfo;
begin
  if not GetGame(game) then
    Exit;

  ASetRaiseAmount := FALSE;

  for dxbutton in FDXButtons do
    dxbutton.MouseMove(Shift, X, Y);

  if FRaiseThumbDown then
  begin
    percent := (X - FMetrics.RaiseTrackBounds[0].x) / (FMetrics.RaiseTrackBounds[1].x - FMetrics.RaiseTrackBounds[0].x);
    if percent < 0 then
      percent := 0
    else
      if percent > 1 then
        percent := 1;

    FRaiseThumbPosition := percent;
    ASetRaiseAmount := TRUE;
  end;

  // render folded cards if needed, and set flag, so we can re-render scene once mouse cursor leaves the seat, and unset the flag then
  if (FTableStatus.State > tsIdle) and
     (FMetrics.IsPointInSeat(game, X, Y, seat_index)) and
     (FTableStatus.GetSeatInfo(seat_index, seat)) and
     (seat.Cards.IsKnown) and
     (seat.Status = psFolded) then
  begin
    FRenderingFoldedCards := TRUE;
    Render;
  end
  else
    if FRenderingFoldedCards then
    begin
      FRenderingFoldedCards := FALSE;
      Render;
    end;
end;

procedure TTableRenderer.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  dxbutton: TDXButton;
begin
  for dxbutton in FDXButtons do
    dxbutton.MouseUp(Button, Shift, X, Y);

  FRaiseThumbDown := FALSE;
end;

function TTableRenderer.UpdateDXAreaSize: Boolean;
var
  rect: TRect;
  game: TGameInfo;
begin
  result := FALSE;
  if not GetGame(game) then
    Exit;

  if FHandle > 0 then
  begin
    Winapi.Windows.GetClientRect(FHandle, rect);

    // dont resize if its 0px wide/tall, this causes swap chain element to get destroyed in Asphyre, and black screen after that
    if (rect.Width > 0) and
       (rect.Height > 0) then
    begin
      FDXAreaSize := Point2px(rect.Width, rect.Height);
      result := TRUE;
    end;
  end;

  FMetrics.Update(game, FDXAreaSize, FRaiseThumbPosition);
  DXCore.Device.Resize(FSwapChainIndex, FDXAreaSize);
end;

procedure TTableRenderer.Render;
begin
  if UpdateDXAreaSize then
    DXCore.Device.Render(FSwapChainIndex, RenderEvent, 0);
end;

procedure TTableRenderer.RenderEvent(Sender: TObject);
begin
  RenderBackground;
  RenderTable;
  RenderClosingText;
  RenderTableCards;
  RenderDealerButton;
  RenderDealingCardsAni;
  RenderSeats;
  RenderBets;
  RenderPots;
  RenderTimebar;
  RenderRaisePanel;
  RenderButtons;
end;

procedure TTableRenderer.RenderBackground;
begin
  DXCore.Canvas.UseImage(TableResources.RoomBackgroundImage, TexFull4);
  DXCore.Canvas.TexMap(pBounds4(0, 0, FDXAreaSize.x, FDXAreaSize.y), FDrawColor);
end;

procedure TTableRenderer.RenderTable;
begin
  DXCore.Canvas.UseImage(TableResources.TableImage, TexFull4);
  DXCore.Canvas.TexMap(FMetrics.RawTableBounds, FDrawColor);
end;

procedure TTableRenderer.RenderSeats;
var
  C1: Integer;
  game: TGameInfo;
begin
  if not GetGame(game) then
    Exit;

  for C1 := 0 to game.Seats - 1 do
    RenderSeat(C1);
end;

procedure TTableRenderer.RenderSeat(const ASeatIndex: Integer);
var
  seat_point: TPoint2;
  seat_info: TSeatInfo;
  player_info: TPlayerInfo;
  seat_image: TAsphyreImage;
  seat_empty_image: TAsphyreImage;
  seat_inactive_image: TAsphyreImage;
  seat_active_image: TAsphyreImage;
  action_image: TAsphyreImage;
//  seat_light_image: TAsphyreImage;
  avatar: TAvatar;
  avatar_point: TPoint2;
  avatar_width: Single;
  avatar_height: Single;
  seat_upper_text: String;
  seat_lower_text: String;
  seat_upper_text_color: TColor2;
  seat_lower_text_color: TColor2;
  seat_upper_text_point: TPoint2;
  seat_lower_text_point: TPoint2;
  seat_text_x_center: Single;
  card_point: TPoint2;
  seat_action_frame_point: TPoint2;
  C1: Integer;
  mousepoint: TPoint;
  mousepointf: TPointF;
  game: TGameInfo;
begin
  if not GetGame(game) then
    Exit;

  // get seat point
  seat_point := FMetrics.GetSeatPoint(game, ASeatIndex);

  // calculate seat elements positions & dimensions
  avatar_width := TableResources.SEAT_AVATAR_WIDTH * FMetrics.SeatResizeRatio;
  avatar_height := TTableResources.SEAT_AVATAR_HEIGHT * FMetrics.SeatResizeRatio;

  if FMetrics.GetTableSector(seat_point) in [tsLeft, tsTopLeft, tsBottomLeft] then
  begin
    seat_empty_image := TableResources.SeatLeftEmptyImage;
    seat_inactive_image := TableResources.SeatLeftImage;
    seat_active_image := TableResources.SeatLeftActiveImage;

    avatar_point := Point2(seat_point.X - FMetrics.SeatWidth / 2 + TableResources.SEAT_LEFT_AVATAR_X * FMetrics.SeatResizeRatio, seat_point.Y);
    seat_text_x_center := seat_point.X - (seat_point.X + FMetrics.SeatWidth / 2 - avatar_point.X) / 2 - 10 * FMetrics.SeatResizeRatio;
  end
  else
  begin
    seat_empty_image := TableResources.SeatRightEmptyImage;
    seat_inactive_image := TableResources.SeatRightImage;
    seat_active_image := TableResources.SeatRightActiveImage;

    avatar_point := Point2(seat_point.X - FMetrics.SeatWidth / 2 + TableResources.SEAT_RIGHT_AVATAR_X * FMetrics.SeatResizeRatio, seat_point.Y);
    seat_text_x_center := seat_point.X + (avatar_point.X - (seat_point.X - FMetrics.SeatWidth / 2) - 10 * FMetrics.SeatResizeRatio);
  end;
  seat_upper_text_point := Point2(seat_text_x_center, seat_point.Y - FMetrics.SeatHeight / 4.5);
  seat_lower_text_point := Point2(seat_text_x_center, seat_point.Y + FMetrics.SeatHeight / 5);
  seat_action_frame_point := Point2(seat_point.x, seat_point.Y + FMetrics.SeatHeight / 2 + FMetrics.SeatActionFrameHeight / 2.15);

  // seat taken
  if (Assigned(FTableStatus)) and
     (FTableStatus.GetSeatInfo(ASeatIndex, seat_info)) then
  begin
    // find player info
    if not Players.TryGetValue(seat_info.PlayerMongoId, player_info) then
      player_info := nil;

    // set seat image that we should render
    if (FTableStatus.CurrentSeat = seat_info.SeatIndex) and
       (not FTableStatus.Locked) and
       (not FTableStatus.LockTimerEnabled) then
    begin
{      if tiActiveFrameBlink.Tag = 1 then
        seat_image := active_seat_light_image
      else
        seat_image := active_seat_dark_image;}
      seat_image := seat_active_image;
    end
    else
      seat_image := seat_inactive_image;

    if Assigned(player_info) then
    begin
      // set avatar
      avatar := Avatars.Add(player_info.AvatarId, nil);

      // set seat upper text
      seat_upper_text := player_info.Nick;
      seat_upper_text_color := cColor2($FFCCCCCC);
    end
    else
    begin
      // set seat upper text
      seat_upper_text := seat_info.UpperCaption;
      seat_upper_text_color := cColor2($FFCCCCCC);

      avatar := Avatars.DefaultAvatar;
    end;

    // set seat lower text
    if seat_info.Disconnected then
    begin
      seat_lower_text := 'Disconnected';
      seat_lower_text_color := cColor2($FFFF3535);
    end
    else
    begin
      case seat_info.Status of
        psOutOfPlay: seat_lower_text := 'Sitting Out';
      else
        if FWinningAniDelay > 0 then
          seat_lower_text := ChipsToStr(seat_info.PreviousChips)
        else
          seat_lower_text := ChipsToStr(seat_info.Chips);
      end;
      seat_lower_text_color := cColor2($FF8DC63F);
    end;

    // set seat action
    action_image := nil;
    if seat_info.LowerCaption = 'CALL' then
      action_image := TableResources.SeatActionCall;
    if seat_info.LowerCaption = 'CHECK' then
      action_image := TableResources.SeatActionCheck;
    if seat_info.LowerCaption = 'RAISE' then
      action_image := TableResources.SeatActionRaise;
    if seat_info.LowerCaption = 'FOLD' then
      action_image := TableResources.SeatActionFold;
    if seat_info.LowerCaption = 'DISCONNECTED' then
      action_image := TableResources.SeatActionDisconnected;

    // render seat cards
    if FTableStatus.State > tsIdle then
    begin
      case seat_info.Status of
        psInHand, psAllIn: begin
          for C1 := 0 to seat_info.DealtCards - 1 do
          begin
            card_point := FMetrics.GetCardPoint(game, seat_info, C1);
            if ((C1 >= 0) and (C1 < seat_info.Cards.Count)) and
               (seat_info.Cards[C1].IsKnown) then
              RenderCard(card_point, seat_info.Cards[C1], FMetrics.CARD_OPEN_PERC)
            else
              RenderCard(card_point, nil, FMetrics.CARD_HIDDEN_PERC);
          end;
        end;

        psFolded: begin
          mousepoint := Mouse.CursorPos;
          ScreenToClient(FHandle, mousepoint);
          mousepointf.X := mousepoint.X;
          mousepointf.Y := mousepoint.Y;

          if (seat_info.CardsVisible) or
             ((seat_info.Cards.IsKnown) and
              (System.Types.PtInRect(RectF(seat_point.x - FMetrics.SeatWidth / 2, seat_point.y - FMetrics.SeatHeight / 2,
                     seat_point.x + FMetrics.SeatWidth / 2, seat_point.y + FMetrics.SeatHeight / 2), mousepointf))) then
            for C1 := 0 to seat_info.Cards.Count - 1 do
            begin
              card_point := FMetrics.GetCardPoint(game, seat_info, C1);
              RenderCard(card_point, seat_info.Cards[C1], FMetrics.CARD_FOLDED_PERC, 170)
            end;
        end;
      end;
    end;

    // render avatar
    if avatar.DXImage.TextureCount > 0 then
    begin
      DXCore.Canvas.UseImage(avatar.DXImage, TexFull4);
      DXCore.Canvas.TexMap(pBounds4(avatar_point.X - avatar_width / 2, avatar_point.Y - avatar_height / 2, avatar_width, avatar_height), clWhite4);
    end;

    // render seat
    DXCore.Canvas.UseImage(seat_image, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(seat_point.X - FMetrics.SeatWidth / 2, seat_point.Y - FMetrics.SeatHeight / 2, FMetrics.SeatWidth, FMetrics.SeatHeight), clWhite4);

    // render upper seat text
    RenderScaleFont(seat_upper_text, seat_upper_text_color, seat_upper_text_point, TableResources.BarmenoFonts, Low(TableResources.BarmenoFonts),
                    Low(TableResources.BarmenoFonts), 16, 0, FMetrics.SeatHeight * 0.36, FMetrics.SeatWidth * 0.75);

    // render lower seat text
    RenderScaleFont(seat_lower_text, seat_lower_text_color, seat_lower_text_point, TableResources.BarmenoFonts, Low(TableResources.BarmenoFonts),
                    Low(TableResources.BarmenoFonts), High(TableResources.BarmenoFonts), 0, FMetrics.SeatHeight * 0.37, FMetrics.SeatWidth * 0.55);

    // render seat action frame/text
    if Assigned(action_image) then
    begin
      // render seat action frame
      DXCore.Canvas.UseImage(action_image, TexFull4);
      DXCore.Canvas.TexMap(pBounds4(seat_action_frame_point.X - FMetrics.SeatActionFrameWidth / 2,
           seat_action_frame_point.Y - FMetrics.SeatActionFrameHeight / 2, FMetrics.SeatActionFrameWidth, FMetrics.SeatActionFrameHeight), clWhite4);
{
      // render seat action text
      RenderScaleFont(seat_action_text, seat_action_text_color, seat_action_frame_point, TableResources.SintonyFonts, Low(TableResources.SintonyFonts),
                      10, 16, 2, FSeatActionFrameHeight * 0.75, FSeatActionFrameWidth * 0.9);
}
    end;
  end
  else
  begin
    // empty seat
    DXCore.Canvas.UseImage(seat_empty_image, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(seat_point.X - FMetrics.SeatWidth / 2, seat_point.Y - FMetrics.SeatHeight / 2, FMetrics.SeatWidth, FMetrics.SeatHeight), clWhite4);
  end;
end;

procedure TTableRenderer.RenderCard(const APoint: TPoint2; const ACard: TCard; const APercentage: Single; const ATransparency: Byte = 0);
var
  card_artwork: TAsphyreImage;
  artwork_points: TPoint4;
  card_value_point: TPoint2;
  card_suit_point: TPoint2;
  card_value_text: String;
  card_suit_text: String;
  card_value_extent: TPoint2;
  card_suit_extent: TPoint2;
  card_text_width: Single;
  text_color: TColor2;
  card_font: TAsphyreFont;
  color: TColor4;
  blending_effect: TBlendingEffect;
begin
  if ATransparency > 0 then
  begin
    color := cAlpha4(ATransparency);
    blending_effect := beNormal;
  end
  else
  begin
    color := clWhite4;
    blending_effect := beNormal;
  end;

  if (not Assigned(ACard)) or
     (not ACard.IsKnown) then
  begin
    // render card background
    DXCore.Canvas.UseImagePx(TableResources.CardBackgroundImage,
      pBounds4(0, 0,
        TableResources.CardBackgroundImage.Texture[0].Width,
        TableResources.CardBackgroundImage.Texture[0].Height * APercentage));
    DXCore.Canvas.TexMap(pBounds4(APoint.x, APoint.y + 2, FMetrics.CardWidth, FMetrics.CardHeight * APercentage), color, blending_effect);
  end
  else
  begin
    // render card front background
    DXCore.Canvas.UseImagePx(TableResources.CardFrontBackgroundImage,
      pBounds4(0, 0,
        TableResources.CardFrontBackgroundImage.Texture[0].Width,
        TableResources.CardFrontBackgroundImage.Texture[0].Height * APercentage));

    DXCore.Canvas.TexMap(pBounds4(APoint.x, APoint.y + 2, FMetrics.CardWidth, FMetrics.CardHeight * APercentage), color, blending_effect);

    // render card value & suit
    card_value_text := ACard.ValueAsString(ACard.Value);
    if card_value_text = 'T' then
      card_value_text := '=';

    case ACard.Suit of
      csHeart: begin
        card_suit_text := '{';
        text_color := cColor2($FFFF0000);
      end;
      csDiamond: begin
        card_suit_text := '[';
        text_color := cColor2($FFFF0000);
      end;
      csClub: begin
        card_suit_text := ']';
        text_color := cColor2($FF000000);
      end;
      csSpade: begin
        card_suit_text := '}';
        text_color := cColor2($FF000000);
      end;
    else
      text_color := cColor2($FF00FF00);
    end;

    card_font := TableResources.CardCharactersFont_19px;
    card_font.Kerning := 1;
    if ((FMetrics.CardWidth > 29) and (APercentage > 0.95)) or
       ((FMetrics.CardWidth > 33) and (APercentage < 1)) then
    begin
      // render card with artwork
      card_text_width := FMetrics.CardWidth / 2.6;

      card_font.Scale := FMetrics.TableResizeRatio * 1.2;
      if card_font.Scale < 0.6 then
        card_font.Scale := 0.6;

      card_value_extent := card_font.TextExtent(card_value_text);
      card_value_point.x := APoint.x + card_text_width / 2;
      card_value_point.y := APoint.y + FMetrics.CardHeight / 14 + card_value_extent.y / 2;

      card_font.TextMidFF(card_value_point, card_value_text, text_color);

      card_font.Scale := FMetrics.TableResizeRatio;
      if card_font.Scale < 0.43 then
        card_font.Scale := 0.43;

      card_suit_extent := card_font.TextExtent(card_suit_text);
      card_suit_point := Point2(APoint.x + card_text_width / 2, card_value_point.y + card_value_extent.y / 2 + 4 * FMetrics.TableResizeRatio + card_suit_extent.y / 2);

      card_font.TextMidFF(card_suit_point, card_suit_text, text_color);

      // render card artwork
      card_artwork := TableResources.GetCardArtwork(ACard);
      artwork_points := pBounds4(APoint.x + card_text_width, APoint.y + 10 * FMetrics.TableResizeRatio,
              FMetrics.CardWidth - card_text_width - 8 * FMetrics.TableResizeRatio, FMetrics.CardHeight - 12 * FMetrics.TableResizeRatio);

      DXCore.Canvas.UseImagePx(card_artwork, pBounds4(0, 0,
          card_artwork.Texture[0].Width,
          card_artwork.Texture[0].Height));
      DXCore.Canvas.TexMap(artwork_points, color, blending_effect);

      // render rectangle frame around artwork
      DXCore.Canvas.FrameRect(artwork_points, cColorAlpha4($FFCFCFCF, ATransparency), blending_effect);
    end
    else
    begin
      // render simple card
      card_font.Kerning := 1;
      card_font.Scale := FMetrics.TableResizeRatio * 1.1;
      if card_font.Scale < 0.70 then
        card_font.Scale := 0.70;

      card_value_extent := card_font.TextExtent(card_value_text);
      card_value_point := Point2(APoint.x + FMetrics.CardHeight / 14, APoint.y + FMetrics.CardHeight / 14);
      card_font.TextOut(card_value_point, card_value_text, text_color, ATransparency / 255);

      card_font.Scale := FMetrics.TableResizeRatio * 1.2;
      if card_font.Scale < 0.65 then
        card_font.Scale := 0.65;

      if APercentage < 1 then
      begin
        card_font.Scale := card_font.Scale - 0.15;
        card_suit_extent := card_font.TextExtent(card_suit_text);
        card_suit_point := Point2(APoint.x + FMetrics.CardWidth - 5 * FMetrics.TableResizeRatio - card_suit_extent.x, card_value_point.y)
      end
      else
      begin
        card_suit_extent := card_font.TextExtent(card_suit_text);
        card_suit_point := Point2(APoint.x + FMetrics.CardWidth - 5 * FMetrics.TableResizeRatio - card_suit_extent.x,
                APoint.y + FMetrics.CardHeight - 5 * FMetrics.TableResizeRatio - card_suit_extent.y);
      end;

      card_font.TextOut(card_suit_point, card_suit_text, text_color, ATransparency / 255);
    end;
  end;
end;

procedure TTableRenderer.RenderScaleFont(const AText: String; const AColor: TColor2; const AMidPoint: TPoint2; const AFonts: array of TAsphyreFont; const ALowBound, AMinIndex, AMaxIndex, AKerning: Integer; const AMaxHeight, AMaxWidth: Single);
var
  index: Integer;
  font: TAsphyreFont;
  lb, hb: Integer;
begin
  lb := AMinIndex - ALowBound;
  hb := AMaxIndex - ALowBound;
  index := hb;
  font := AFonts[index];
  font.Kerning := AKerning;
  font.Scale := 1;
  while ((AMaxHeight <> 0) and (font.TextHeight(AText) > AMaxHeight)) or
        ((AMaxWidth <> 0) and (font.TextWidth(AText) > AMaxWidth)) do
    if index > lb then
    begin
      Dec(index);
      font := AFonts[index];
      font.Kerning := AKerning;
      font.Scale := 1;
    end
    else
      font.Scale := font.Scale - 0.01;

  font.TextMidF(AMidPoint, AText, AColor);
end;

procedure TTableRenderer.RenderClosingText;
var
  mins: Integer;
  minute_text: String;
  txt: String;
  game: TGameInfo;
begin
  if not GetGame(game) then
    Exit;

  case game.State of
    gsClosing: begin
      if Assigned(FTableStatus) then
      begin
        FTableStatus.UpdateClosingTime(game);

        if FTableStatus.ClosingTime = 0 then
          txt := 'Table is closing after curent hand'
        else
        begin
          mins := FTableStatus.ClosingTime div 60000 + 1;
          if mins = 1 then
            txt := Format('Table is closing in less than a minute', [mins, minute_text])
          else
            txt := Format('Table is closing in %d minutes', [mins]);
        end;
      end;

      RenderScaleFont(txt, clWhite2, Point2(FMetrics.TableCenter.x, FMetrics.TableCenter.Y + FMetrics.CardHeight / 3), TableResources.SintonyFonts,
                      Low(TableResources.SintonyFonts), 12, 16, 2, 8 + 8 * FMetrics.TableResizeRatio, 0);
    end;

    gsClosed: RenderScaleFont('Table is closed', clWhite2, Point2(FMetrics.TableCenter.x, FMetrics.TableCenter.Y + FMetrics.CardHeight / 3), TableResources.SintonyFonts,
                        Low(TableResources.SintonyFonts), 12, 16, 2, 8 + 8 * FMetrics.TableResizeRatio, 0);

  end;
end;

procedure TTableRenderer.RenderTimebar;
var
  seat: TSeatInfo;
  seat_point: TPoint2;
  time_percent: Single;
  game: TGameInfo;
begin
  if not GetGame(game) then
    Exit;

  if (not Assigned(FTableStatus)) or
     (FTableStatus.Locked) or
     (FTableStatus.Time = 0) or
     (FTableStatus.TimebarEndtime = 0) or
     (FTableStatus.LockTimerEnabled) then
    Exit;

  if FTableStatus.GetSeatInfo(FTableStatus.CurrentSeat, seat) then
  begin
    seat_point := FMetrics.GetSeatPoint(game, seat.SeatIndex);

    FTableStatus.UpdateCurrentPlaytime;

    if FTableStatus.CurrentPlaytime > 0 then
    begin
      FTimeImage := TableResources.TimebarImage;
      time_percent := (FTableStatus.CurrentPlaytime / (ServerSettings.Playtime * 1000)) * 1.5;
    end
    else
    begin
      // using timebank..
      if (FTimeImage <> TableResources.TimebankImage) and
         (Assigned(FOnTimebankStarted)) then
        FOnTimebankStarted(self);

      FTimeImage := TableResources.TimebankImage;
      time_percent := (Integer(seat.Timebank) + FTableStatus.CurrentPlaytime) / (ServerSettings.Timebank * 1000);
    end;

    if time_percent > 1 then
      time_percent := 1;

    if time_percent > 0 then
    begin
      DXCore.Canvas.UseImagePx(FTimeImage, pBounds4(0, 0, time_percent * FTimeImage.Texture[0].Width, FTimeImage.Texture[0].Height));
      DXCore.Canvas.TexMap(pBounds4(seat_point.X - FMetrics.TimebarWidth / 2,
         seat_point.Y + FMetrics.SeatHeight / 2 - 3 * FMetrics.TableResizeRatio, FMetrics.TimebarWidth * time_percent, FMetrics.TimebarHeight),
         clWhite4);
    end;
  end;
end;

procedure TTableRenderer.RenderTableCards;

  procedure RenderSingleCard(const ACard: TCard; const AAnimationsList: TList<Integer>; var AIsAnimated: Boolean; var ACurrentCardPoint: TPoint2; var AShowCard: Integer; const AAnimateFrom, AAnimateTo: TPoint2; const ADelay: Single);
  var
    animation: TDXAnimation;
    C1: Integer;
  begin
    if ACard.Value <> cvUnknown then
    begin
      if not AIsAnimated then
      begin
        AAnimationsList.Clear;
        animation := DXTimer.AddAnimation(FHandle, AAnimateFrom, AAnimateTo, 0.15, ADelay, 0, FDXAreaSize); AAnimationsList.Add(animation.Id);
        AIsAnimated := TRUE;
      end;

      if AAnimationsList.Count > 0 then
        if DXTimer.AnimationsEnabled then
        begin
          for C1 := 0 to AAnimationsList.Count - 1 do
            if DXTimer.Find(FHandle, AAnimationsList[C1], animation) then
            begin
              ACurrentCardPoint := animation.GetCurrPoint(FDXAreaSize);
              if animation.Status = asAnimating then
                AShowCard := 1;
            end;
        end
        else
          AShowCard := -1
      else
        AShowCard := 1;

      case AShowCard of
        -1: ;
         0: RenderCard(ACurrentCardPoint, nil, 1);
         1: RenderCard(ACurrentCardPoint, ACard, 1);
      end;
    end;
  end;

var
  C1: Integer;
  card_points_curr: array of TPoint2;
  card_points_mid: array of TPoint2;
  card_points_final: array of TPoint2;
  show_cards: array of Integer; // -1 - hide completely, 0 - card face down, 1 - card face up
  animation: TDXAnimation;
begin
  SetLength(card_points_final, 5);
  SetLength(card_points_curr, 5);
  SetLength(card_points_mid, 5);
  SetLength(show_cards, 5);
  for C1 := Low(card_points_final) to High(card_points_final) do
  begin
    card_points_final[C1].x := FMetrics.TableCenter.X - (FMetrics.CardWidth * 5) / 2 - 4 * 3 + (C1 * FMetrics.CardWidth) + (C1 * 3);
    card_points_final[C1].y := FMetrics.TableCenter.Y - FMetrics.CardHeight / 2;
    card_points_curr[C1] := card_points_final[C1];
    card_points_mid[C1] := card_points_final[C1];
    show_cards[C1] := -1;
  end;
  card_points_mid[0].x := card_points_final[0].x - 5;
  card_points_mid[1].x := card_points_final[0].x - 0;
  card_points_mid[2].x := card_points_final[0].x + 5;
//  card_points_mid[3].x := card_points_final[3].x + FCardWidth / 2;
//  card_points_mid[4].x := card_points_final[4].x + FCardWidth / 2;

  if (Assigned(FTableStatus)) and
     (FTableStatus.FlopCards.Count > 0) and
     (FTableStatus.State >= tsFlop) then
  begin
    if not FFlopAnimated then
    begin
      FFlopAnimations.Clear;

      animation := DXTimer.AddAnimation(FHandle, FMetrics.DealerPoint, card_points_mid[0], 0.15, 0.9, 0, FDXAreaSize); animation.Tags.AddOrSetValue(ANITAG_CARD_INDEX, 0); FFlopAnimations.Add(animation.Id);
      animation := DXTimer.AddAnimation(FHandle, FMetrics.DealerPoint, card_points_mid[1], 0.15, 0.9, 0, FDXAreaSize); animation.Tags.AddOrSetValue(ANITAG_CARD_INDEX, 1); FFlopAnimations.Add(animation.Id);
      animation := DXTimer.AddAnimation(FHandle, FMetrics.DealerPoint, card_points_mid[2], 0.15, 0.9, 0, FDXAreaSize); animation.Tags.AddOrSetValue(ANITAG_CARD_INDEX, 2); FFlopAnimations.Add(animation.Id);

      animation := DXTimer.AddAnimation(FHandle, card_points_mid[0], card_points_final[0], 0.2, 1.1, 0, FDXAreaSize); animation.Tags.AddOrSetValue(ANITAG_CARD_INDEX, 0); FFlopAnimations.Add(animation.Id);
      animation := DXTimer.AddAnimation(FHandle, card_points_mid[1], card_points_final[1], 0.2, 1.1, 0, FDXAreaSize); animation.Tags.AddOrSetValue(ANITAG_CARD_INDEX, 1); FFlopAnimations.Add(animation.Id);
      animation := DXTimer.AddAnimation(FHandle, card_points_mid[2], card_points_final[2], 0.2, 1.1, 0, FDXAreaSize); animation.Tags.AddOrSetValue(ANITAG_CARD_INDEX, 2); FFlopAnimations.Add(animation.Id);

      FFlopAnimated := TRUE;
    end;

    if FFlopAnimations.Count > 0 then
      if DXTimer.AnimationsEnabled then
      begin
        for C1 := 0 to FFlopAnimations.Count - 1 do
          if (DXTimer.Find(FHandle, FFlopAnimations[C1], animation)) and
             (animation.Status = asAnimating) then
          begin
            card_points_curr[Integer(animation.Tags[ANITAG_CARD_INDEX])] := animation.GetCurrPoint(FDXAreaSize);
            if FFlopAnimations.Count > 3 then
              show_cards[Integer(animation.Tags[ANITAG_CARD_INDEX])] := 0
            else
              show_cards[Integer(animation.Tags[ANITAG_CARD_INDEX])] := 1;
          end;
      end
      else
      begin
        show_cards[0] := -1;
        show_cards[1] := -1;
        show_cards[2] := -1;
      end
    else
    begin
      show_cards[0] := 1;
      show_cards[1] := 1;
      show_cards[2] := 1;
    end;

    for C1 := 0 to FTableStatus.FlopCards.Count - 1 do
      case show_cards[C1] of
        -1: Continue;
         0: RenderCard(card_points_curr[C1], nil, 1);
         1: RenderCard(card_points_curr[C1], FTableStatus.FlopCards[C1], 1);
      end;
  end;

  if Assigned(FTableStatus) then
  begin
    if FTableStatus.State >= tsTurn then
      RenderSingleCard(FTableStatus.TurnCard, FTurnAnimations, FTurnAnimated, card_points_curr[3], show_cards[3], FMetrics.DealerPoint, card_points_final[3], 0.75 + FWinningTurnAniDelay);

    if FTableStatus.State >= tsRiver then
      RenderSingleCard(FTableStatus.RiverCard, FRiverAnimations, FRiverAnimated, card_points_curr[4], show_cards[4], FMetrics.DealerPoint, card_points_final[4], 0.75 + FWinningRiverAniDelay);
  end;
end;

procedure TTableRenderer.RenderDealerButton;
var
  dealer_point: TPoint2;
  game: TGameInfo;
begin
  if not GetGame(game) then
    Exit;

  if (not Assigned(FTableStatus)) or
     (FTableStatus.Dealer = -1) then
    Exit;

  dealer_point := FMetrics.GetDealerPoint(game, FTableStatus.Dealer);

  DXCore.Canvas.UseImage(TableResources.DealerButtonImage, TexFull4);
  DXCore.Canvas.TexMap(pBounds4(dealer_point.X - FMetrics.DealerButtonWidth / 2, dealer_point.Y - FMetrics.DealerButtonHeight / 2,
       FMetrics.DealerButtonWidth, FMetrics.DealerButtonHeight), clWhite4);
end;

procedure TTableRenderer.RenderDealingCardsAni;
var
  C1: Integer;
  animation: TDXAnimation;
begin
  if not DXTimer.AnimationsEnabled then
    Exit;

  for C1 := 0 to FDealAnimations.Count - 1 do
    if (DXTimer.Find(FHandle, FDealAnimations[C1], animation)) and
       (animation.Status = asAnimating) then
    begin
      RenderCard(animation.GetCurrPoint(FDXAreaSize), nil, 1);
      if animation.Tags.ContainsKey(ANITAG_SOUND) then
      begin
        if Assigned(FOnSoundPlay) then
          FOnSoundPlay(animation.Tags[ANITAG_SOUND]);
        animation.Tags.Remove(ANITAG_SOUND);
      end;
    end;
end;

procedure TTableRenderer.RenderBets;
var
  C1, C2: Integer;
  chips_point: TPoint2;
  chips_stack: TChipStack;
  animation: TDXAnimation;
  seat_index: Integer;
  animated_seats: TList<Integer>;
  game: TGameInfo;
begin
  if not GetGame(game) then
    Exit;

  if not Assigned(FTableStatus) then
    Exit;

  animated_seats := TList<Integer>.Create;
  try
    for C2 := 0 to FBetAnimations.Count - 1 do
      if DXTimer.Find(FHandle, FBetAnimations[C2], animation) then
      begin
        if (not animation.Tags.ContainsKey(ANITAG_BLIND)) or
           (animation.Status = asAnimating) then
        begin
          chips_stack := FChipStackMaker.MakeStack(animation.Tags[ANITAG_CHIPS]);
          chips_point := animation.GetCurrPoint(FDXAreaSize);
          RenderChipStack(chips_point, chips_stack);

          if animation.Tags.ContainsKey(ANITAG_BLIND) then
            RenderValue(chips_point, animation.Tags[ANITAG_CHIPS], clWhite2, FALSE);

          if animation.Tags.ContainsKey(ANITAG_SOUND) then
          begin
            if Assigned(FOnSoundPlay) then
              FOnSoundPlay(animation.Tags[ANITAG_SOUND]);
            animation.Tags.Remove(ANITAG_SOUND);
          end;
        end;
        animated_seats.Add(animation.Tags[ANITAG_SEAT]);
      end;

    if FPotWinAnimations.Count = 0 then
      for C1 := 0 to FTableStatus.Seats.Count - 1 do
      begin
        seat_index := FTableStatus.Seats[C1].SeatIndex;

        if (not animated_seats.Contains(seat_index)) and
           (FTableStatus.Bets.Count > seat_index) and
           (FTableStatus.Bets[seat_index] > 0) then
        begin
          chips_point := FMetrics.GetBetPoint(game, seat_index, FTableStatus.Dealer);
          chips_stack := FChipStackMaker.MakeStack(FTableStatus.Bets[seat_index]);
          RenderChipStack(chips_point, chips_stack);
          RenderValue(chips_point, FTableStatus.Bets[seat_index], clWhite2, FALSE);
        end;
      end;
  finally
    animated_seats.Free;
  end;
end;

procedure TTableRenderer.RenderPots;
var
  C1, C2: Integer;
  pot_value: UINT32;
  chips_stack: TChipStack;
  pot_point: TPoint2;
  animation: TDXAnimation;
  pots: TPotList;
begin
  if not Assigned(FTableStatus) then
    Exit;

  if FBetAnimations.Count = 0 then
    pots := FTableStatus.Pots
  else
    pots := FTableStatus.PreviousPots;

  for C1 := 0 to pots.Count - 1 do
  begin
    pot_value := pots[C1].ValueWithoutRake;

    for C2 := 0 to FPotWinAnimations.Count - 1 do
      if (DXTimer.Find(FHandle, FPotWinAnimations[C2], animation)) and
         (animation.Tags[ANITAG_POT_INDEX] = C1) and
         (animation.Status in [asAnimating, asDone]) then
      begin
        chips_stack := FChipStackMaker.MakeStack(animation.Tags[ANITAG_CHIPS]);
        RenderChipStack(animation.GetCurrPoint(FDXAreaSize), chips_stack);

        if animation.Tags[ANITAG_CHIPS] >= pot_value then
          pot_value := 0
        else
          Dec(pot_value, UINT32(animation.Tags[ANITAG_CHIPS]));

        if animation.Tags.ContainsKey(ANITAG_SOUND) then
        begin
          if Assigned(FOnSoundPlay) then
            FOnSoundPlay(animation.Tags[ANITAG_SOUND]);
          animation.Tags.Remove(ANITAG_SOUND);
        end;

        if animation.Tags.ContainsKey(ANITAG_WINMSG) then
        begin
          if Assigned(FOnDealerChatMessage) then
            FOnDealerChatMessage(animation.Tags[ANITAG_WINMSG]);
          animation.Tags.Remove(ANITAG_WINMSG);
        end;
      end;

    if pot_value > 0 then
    begin
      pot_point := FMetrics.GetPotPoint(C1);
      if (pot_point.X > 0) and (pot_point.Y > 0) then
      begin
        chips_stack := FChipStackMaker.MakeStack(pot_value);
        RenderChipStack(pot_point, chips_stack);
        RenderValue(pot_point, pot_value, clWhite2, TRUE);
      end;
    end;
  end;
end;

procedure TTableRenderer.RenderValue(const APoint: TPoint2; const AValue: UINT32; const AColor: TColor2; const APot: Boolean);
var
  font: TAsphyreFont;
  text: String;
  p: TPoint2;
begin
  text := ChipsToStr(AValue);

  font := TableResources.BarmenoFonts[High(TableResources.BarmenoFonts)];
  font.Scale := FMetrics.TableResizeRatio;
  font.Kerning := 2;

  p := APoint;
  if APot then
    p.y := p.y + FMetrics.ChipHeight + 15 * FMetrics.TableResizeRatio
  else
  begin
    if FMetrics.GetTableSector(APoint) in [tsTopRight, tsRight, tsBottomRight] then
      p.x := p.x - FMetrics.ChipWidth / 2 - 10 * FMetrics.TableResizeRatio - font.TextWidth(text) / 2
    else
      p.x := p.x + FMetrics.ChipWidth / 2 + 10 * FMetrics.TableResizeRatio + font.TextWidth(text) / 2;

    p.y := p.y + FMetrics.ChipHeight / 1.70;
  end;
  font.TextMidF(p, text, AColor);
end;

procedure TTableRenderer.RenderChipStack(const APoint: TPoint2; const AChipStack: TChipStack);
var
  C1: Integer;
begin
  if Length(AChipStack.Images) = 0 then
    Exit;

  for C1 := Low(AChipStack.Images) to High(AChipStack.Images) do
  begin
    DXCore.Canvas.UseImage(AChipStack.Images[C1], TexFull4);
    DXCore.Canvas.TexMap(pBounds4(APoint.X - FMetrics.ChipWidth / 2,
        APoint.Y - C1 * 5 * FMetrics.TableResizeRatio, FMetrics.ChipWidth, FMetrics.ChipHeight), clWhite4);
  end;
end;

procedure TTableRenderer.RenderButtons;
var
  button: TDXButton;
begin
  for button in FDXButtons do
    button.RenderTo(DXCore.Canvas, FMetrics);
end;

procedure TTableRenderer.RenderRaisePanel;
var
  red_bounds: TPoint4;
begin
  if not Assigned(FTableStatus) then
    Exit;

  if (FTableStatus.ActionRaise) or
     (FTableStatus.ActionBet) then
  begin
    // render raise slider background
    DXCore.Canvas.UseImage(TableResources.RaiseSliderBackgroundImage, TexFull4);
    DXCore.Canvas.TexMap(FMetrics.RaisePanelBounds, clWhite4);

    // render raise red fill
    red_bounds := pBounds4(FMetrics.RaiseTrackBounds[0].x + 1, FMetrics.RaiseTrackBounds[0].y + 1,
         FRaiseThumbPosition * (FMetrics.RaiseTrackBounds[1].x - FMetrics.RaiseTrackBounds[0].x - 2),
         FMetrics.RaiseTrackBounds[2].y - FMetrics.RaiseTrackBounds[0].y - 3);
    DXCore.Canvas.FillQuad(red_bounds, cColor4($FFB40004));

    // render raise thumb
    DXCore.Canvas.UseImage(TableResources.RaiseSliderButtonImage, TexFull4);
    DXCore.Canvas.TexMap(FMetrics.RaiseThumbBounds, clWhite4);
  end;
end;

function TTableRenderer.AddDXButton(const AAction: TAction; const ABounds: PPoint4; const ANormalImage, ADownImage, AHotImage: TAsphyreImage; const ARenderActionCaption: Boolean = FALSE; const AFontScale: Single = 1): Integer;
var
  dxb: TDXButton;
  id: Integer;
  id_exists: Boolean;
begin
  id := 0;
  repeat
    Inc(id);
    id_exists := FALSE;

    for dxb in FDXButtons do
      if dxb.Id = id then
      begin
        id_exists := TRUE;
        Break;
      end;
  until not id_exists;

  dxb := TDXButton.Create;
  dxb.Id := id;
  dxb.Action := AAction;
  dxb.Bounds := ABounds;
  dxb.ImageNormal := ANormalImage;
  dxb.ImageDown := ADownImage;
  dxb.ImageHot := AHotImage;
  dxb.RenderActionCaption := ARenderActionCaption;
  dxb.FontScaleRatio := AFontScale;
  FDXButtons.Add(dxb);

  result := dxb.Id;
end;

procedure TTableRenderer.ClearAnimations;
begin
  FFlopAnimations.Clear;
  FTurnAnimations.Clear;
  FRiverAnimations.Clear;
  FDealAnimations.Clear;
  FBetAnimations.Clear;
  FPotWinAnimations.Clear;

  if Assigned(FTableStatus) then
  begin
    FFlopAnimated := FTableStatus.State >= tsFlop;
    FTurnAnimated := FTableStatus.State >= tsTurn;
    FRiverAnimated := FTableStatus.State >= tsRiver;
  end
  else
  begin
    FFlopAnimated := FALSE;
    FTurnAnimated := FALSE;
    FRiverAnimated := FALSE;
  end;
end;

procedure TTableRenderer.AnimationCallback(const AAnimationPointer: pointer);
var
  seat_index: Integer;
  seat: TSeatInfo;
  animation: TDXAnimation;
begin
  if not Assigned(AAnimationPointer) then
  begin
    Render;
    Exit;
  end;

  animation := TDXAnimation(AAnimationPointer);

  if animation.Status = asDone then
  begin
    if FFlopAnimations.Contains(animation.Id) then
      FFlopAnimations.Remove(animation.Id);

    if FTurnAnimations.Contains(animation.Id) then
      FTurnAnimations.Remove(animation.Id);

    if FRiverAnimations.Contains(animation.Id) then
      FRiverAnimations.Remove(animation.Id);

    if FBetAnimations.Contains(animation.Id) then
      FBetAnimations.Remove(animation.Id);

    if FPotWinAnimations.Contains(animation.Id) then
    begin
      FPotWinAnimations.Remove(animation.Id);
      if FPotWinAnimations.Count = 0 then
      begin
        FTableStatus.PreviousPots.Clear;
        FTableStatus.Pots.Clear;
      end;
    end;

    if FDealAnimations.Contains(animation.Id) then
    begin
      seat_index := animation.Tags[ANITAG_SEAT];
      if (Assigned(FTableStatus)) and
         (FTableStatus.GetSeatInfo(seat_index, seat)) then
        seat.IncDealtCards;
      FDealAnimations.Remove(animation.Id);
    end;
  end;
end;

function TTableRenderer.AnimateBets(const ACallback: THandle; ABets: TList<UINT32>; const ASeatIndex: Integer = -1): Boolean;
var
  C1: Integer;
  bet_point: TPoint2;
  pot_point: TPoint2;
  animation: TDXAnimation;
  game: TGameInfo;
begin
  result := FALSE;
  if not GetGame(game) then
    Exit;

  if not Assigned(FTableStatus) then
    Exit;

  for C1 := 0 to ABets.Count - 1 do
    if (ABets[C1] > 0) and
       ((ASeatIndex = -1) or
        (ASeatIndex = C1)) then
    begin
      bet_point := FMetrics.GetBetPoint(game, C1, FTableStatus.Dealer);
      pot_point := FMetrics.GetPotPoint(0);

      animation := DXTimer.AddAnimation(ACallback, bet_point, pot_point, Settings.Hardcoded.ANIMATION_METRICS.BETS_SPEED,
          Settings.Hardcoded.ANIMATION_METRICS.BETS_START_DELAY, 0, FDXAreaSize);
      animation.Tags.AddOrSetValue(ANITAG_SEAT, C1);
      animation.Tags.AddOrSetValue(ANITAG_CHIPS, ABets[C1]);
      animation.Tags.AddOrSetValue(ANITAG_SOUND, Sounds.SOUND_MOVE_CHIPS);
      FBetAnimations.Add(animation.Id);

      result := TRUE;
    end;
end;

procedure TTableRenderer.AnimateBlinds(const ACallback: THandle);
var
  bet_point: TPoint2;
  animation: TDXAnimation;
  game: TGameInfo;
begin
  if not GetGame(game) then
    Exit;

  if (not Assigned(FTableStatus)) or
     (FTableStatus.SmallBlindSeat < 0) or (FTableStatus.SmallBlindSeat > FTableStatus.Bets.Count - 1) or
     (FTableStatus.BigBlindSeat < 0) or (FTableStatus.BigBlindSeat > FTableStatus.Bets.Count - 1) then
    Exit;

  bet_point := FMetrics.GetBetPoint(game, FTableStatus.SmallBlindSeat, FTableStatus.Dealer);
  animation := DXTimer.AddAnimation(ACallback, bet_point, bet_point, 0.1, 0.1, 0.9, FDXAreaSize);
  animation.Tags.AddOrSetValue(ANITAG_SEAT, FTableStatus.SmallBlindSeat);
  animation.Tags.AddOrSetValue(ANITAG_CHIPS, FTableStatus.Bets[FTableStatus.SmallBlindSeat]);
  animation.Tags.AddOrSetValue(ANITAG_BLIND, TRUE);
  animation.Tags.AddOrSetValue(ANITAG_SOUND, Sounds.SOUND_PUTCHIPS_SMALL);
  FBetAnimations.Add(animation.Id);

  bet_point := Metrics.GetBetPoint(game, FTableStatus.BigBlindSeat, FTableStatus.Dealer);
  animation := DXTimer.AddAnimation(ACallback, bet_point, bet_point, 0.1, 0.5, 0.5, FDXAreaSize);
  animation.Tags.AddOrSetValue(ANITAG_SEAT, FTableStatus.BigBlindSeat);
  animation.Tags.AddOrSetValue(ANITAG_CHIPS, FTableStatus.Bets[FTableStatus.BigBlindSeat]);
  animation.Tags.AddOrSetValue(ANITAG_BLIND, TRUE);
  animation.Tags.AddOrSetValue(ANITAG_SOUND, Sounds.SOUND_PUTCHIPS_SMALL);
  FBetAnimations.Add(animation.Id);
end;

procedure TTableRenderer.AnimateDealingCards(const ACallback: THandle);
var
  iterate: Boolean;
  animation: TDXAnimation;
  cc: Integer;
  card_index: Integer;
  C1: Integer;
  seat: TSeatInfo;
  seat_point: TPoint2;
  game: TGameInfo;
begin
  if not GetGame(game) then
    Exit;

  cc := 0;
  card_index := 0;
  repeat
    iterate := FALSE;
    C1 := FTableStatus.SmallBlindSeat;
    if C1 < 0 then
      Break;
    repeat
      if FTableStatus.GetSeatInfo(C1, seat) then
      begin
        seat.ResetDealtCards;
        if seat.CardCount > card_index then
        begin
          seat_point := FMetrics.GetSeatPoint(game, seat.SeatIndex);
          animation := DXTimer.AddAnimation(ACallback,
                Point2(FMetrics.TableCenter.x - FMetrics.CardWidth / 2, FMetrics.TableBounds[0].y),
                FMetrics.GetCardPoint(game, seat, card_index),
                Settings.Hardcoded.ANIMATION_METRICS.DEALING_CARD_SPEED,
                Settings.Hardcoded.ANIMATION_METRICS.DEALING_INITIAL_DELAY + Settings.Hardcoded.ANIMATION_METRICS.DEALING_CARD_DELAY * cc,
                0, FDXAreaSize);
          animation.Tags.AddOrSetValue(ANITAG_SEAT, seat.SeatIndex);
          Inc(cc);
          if cc mod 2 = 0 then
            animation.Tags.AddOrSetValue(ANITAG_SOUND, Sounds.SOUND_DEALING);
          FDealAnimations.Add(animation.Id);
          iterate := TRUE;
        end;
      end;

      Inc(C1);
      if C1 >= game.Seats then
        C1 := 0;
    until C1 = FTableStatus.SmallBlindSeat;
    Inc(card_index);
  until not iterate;
end;

procedure TTableRenderer.AnimateWinnerPots(const ACallback: THandle; const APots: TList<TPB_Pot>);
var
  pot: TPB_Pot;
  C1, C2: Integer;
  total_chips_val: UINT32;
  nick, nicks: String;
  animation: TDXAnimation;
  seat: TSeatInfo;
  player: TPlayerInfo;
  suffix, chips_plural: String;
  winmsg: String;
  game: TGameInfo;
begin
  if not GetGame(game) then
    Exit;

  for C1 := 0 to APots.Count - 1 do
  begin
    pot := APots[C1];

    if (pot.Value = 0) or (pot.WinnerData.Count = 0) then
      Continue;

    total_chips_val := pot.Value - pot.Rake;

    nicks := '';
    animation := nil;
    for C2 := 0 to pot.WinnerData.Count - 1 do
    begin
      if (FTableStatus.GetSeatInfo(pot.WinnerData[C2].Seat, seat)) and
         (Players.TryGetValue(seat.PlayerMongoId, player)) then
        nick := player.Nick
      else
        nick := Format('Seat #%d', [pot.WinnerData[C2].Seat]);

      nicks := nicks + Format('%s, ', [nick]);

      // restore bets if table is in playback mode, so values are shown
      if FTableType = ttHandPlayback then
        FTableStatus.Bets[pot.WinnerData[C2].Seat] := FTableStatus.Bets[pot.WinnerData[C2].Seat] + total_chips_val div UINT32(pot.WinnerData.Count);

      animation := DXTimer.AddAnimation(ACallback,
           FMetrics.GetPotPoint(C1),
           FMetrics.GetBetPoint(game, pot.WinnerData[C2].Seat, FTableStatus.Dealer),
           Settings.Hardcoded.ANIMATION_METRICS.POTS_INITIAL_DELAY,
           WinningAniDelay + 1.5 + C1 * Settings.Hardcoded.ANIMATION_METRICS.POTS_INBETWEEN_DELAY,
           Settings.Hardcoded.ANIMATION_METRICS.POTS_END_DELAY,
           FDXAreaSize);

      animation.Tags.AddOrSetValue(ANITAG_POT_INDEX, C1);
      animation.Tags.AddOrSetValue(ANITAG_SEAT, pot.WinnerData[C2].Seat);
      animation.Tags.AddOrSetValue(ANITAG_CHIPS, total_chips_val div UINT32(pot.WinnerData.Count));
      PotWinAnimations.Add(animation.Id);
    end;
    Delete(nicks, Length(nicks) - 1, 2);

    chips_plural := '';
    if total_chips_val <> 100 then
      chips_plural := 's';

    suffix := '';
    if pot.WinnerData.Count > 1 then
      suffix := 'each ';

    winmsg := pot.WinnerData[0].Msg;
    if winmsg = 'default' then
      winmsg := ''
    else
      if FTableStatus.GetSeatInfo(pot.WinnerData[0].Seat, seat) then
        winmsg := THandStrengthCalculator.GetHandStrength(seat.Cards.AsString, FTableStatus.FlopCards.AsString + FTableStatus.TurnCard.AsString + FTableStatus.RiverCard.AsString, FTableStatus.CurrentGame, FALSE)
      else
        winmsg := pot.WinnerData[0].Msg;

    if winmsg <> '' then
      winmsg := Format('(%s)', [winmsg]);

    Assert(Assigned(animation));
    animation.Tags.AddOrSetValue(ANITAG_SOUND, Sounds.SOUND_MOVE_CHIPS);
    animation.Tags.AddOrSetValue(ANITAG_WINMSG, Format('%s won %s chip%s %s%s', [nicks, ChipsToStr(total_chips_val div UINT32(pot.WinnerData.Count)), chips_plural, suffix, winmsg]));
  end;
end;

{ TTableSyncRender }

procedure TSyncRenderer.DoSynchronize;
begin
  FRenderer.Render;
end;

class procedure TSyncRenderer.Render(const ARenderer: TTableRenderer);
var
  syncr: TSyncRenderer;
begin
  syncr := TSyncRenderer.Create;
  try
    syncr.FRenderer := ARenderer;
    syncr.Synchronize;
  finally
    syncr.Free;
  end;
end;


end.
