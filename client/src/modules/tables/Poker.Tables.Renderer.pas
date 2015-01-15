unit Poker.Tables.Renderer;

interface

uses
  Winapi.Windows, System.Classes, System.Generics.Collections, System.Types, Asphyre.Math, Asphyre.Types, Asphyre.Fonts,
  Poker.Tables.RenderMetrics, Vcl.ActnList, Poker.Games.Game, Poker.Tables.Status, Asphyre.Images, Poker.Seats.Seat, Poker.Cards,
  Poker.ChipStackMaker, IdSync, Poker.DirectX.Button, Vcl.Controls, Poker.ChipStackMaker.ChipStack, System.SysUtils,
  Poker.Protobufs.Objects.Pot, Poker.DirectX.Animations, Poker.Protobufs.Objects.TableStatus;

type
  TDealerChatMessageEvent = procedure(const AMessage: String) of object;
  TSoundPlayEvent = procedure(const ASound: String; const AIgnoreFocus: Boolean = FALSE) of object;

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
    FEnabled: Boolean;
    FSwapChainIndex: Integer;
    FLastDXAreaSize: TPoint2px;
    FDXAreaSize: TPoint2px;
    FMetrics: TTableRenderMetrics;
    FInternalId: Integer;
    FInternalHWND: HWND;
    FTableType: TTableType;
    FTimeImage: TAsphyreImage;
    FRaiseThumbPosition: Single;
    FDXButtons: TObjectList<TDXButton>;
    FRenderingFoldedCards: Boolean;
//    FAnimations: TDXAnimations;

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
    FOnUpdateHandStrength: TNotifyEvent;
    FRaiseThumbDown: Boolean;

    FPots: TPB_PotList;
    FBets: TList<Integer>;

    procedure RenderEvent(Sender: TObject);
    procedure RenderBackground(const AGameInfo: TGameInfo);
    procedure RenderTable;
    procedure RenderSeats(const AGameInfo: TGameInfo);
    procedure RenderSeat(const AGame: TGameInfo; const ASeatIndex: Integer);
    procedure RenderCard(const APoint: TPoint2; const ACard: TCard; const APercentage: Single; const ATransparency: Byte = 0);
    procedure RenderScaleFont(const AText: String; const AColor: TColor2; const AMidPoint: TPoint2; const AFonts: array of TAsphyreFont; const ALowBound, AMinIndex, AMaxIndex, AKerning: Integer; const AMaxHeight, AMaxWidth: Single);
    procedure RenderTableMessages(const AGame: TGameInfo);
    procedure RenderTimebar(const AGame: TGameInfo);
    procedure RenderTableCards;
    procedure RenderDealerButton(const AGame: TGameInfo);
    procedure RenderDealingCardsAni;
    procedure RenderBets(const AGame: TGameInfo);
    procedure RenderPots;
    procedure RenderValue(const APoint: TPoint2; const AValue: UINT32; const AColor: TColor2; const APot: Boolean);
    procedure RenderChipStack(const APoint: TPoint2; const AChipStack: TChipStack; const AColor: TColor4);
    procedure RenderButtons;
    procedure RenderRaisePanel;
    procedure RenderRake;
  public
    constructor Create(const AInternalId: Integer; const AInternalHWND: HWND; const ATableType: TTableType);
    destructor Destroy; override;

    procedure Enable;
    procedure Disable;

    function AcquireSwapChainElement: Boolean;
    procedure SetRenderTarget(const AHandle: THandle);

    procedure ClearAnimations;

    procedure SetTableId(const AId: Integer);
    function UpdateDXAreaSize: Boolean;
    procedure Render(const AUpdateDXAreaSize: Boolean = TRUE);

    function AnimateBets(ABets: TList<UINT32>; const ASeatIndex: Integer = -1): Boolean;
    procedure AnimateBlinds;
    procedure AnimateWinnerPots(const APots: TList<TPB_Pot>);
    procedure AnimateDealingCards;

    procedure AnimationCallback(const AAnimationPointer: pointer);

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer; out ASetRaiseAmount: Boolean);
    procedure MouseMove(Shift: TShiftState; X, Y: Integer; out ASetRaiseAmount: Boolean);
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

    property SwapChainIndex: Integer read FSwapChainIndex;

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
    property OnUpdateHandStrength: TNotifyEvent read FOnUpdateHandStrength write FOnUpdateHandStrength;

    function AddDXButton(const AAction: TAction; const ABounds: PPoint4; const ANormalImage, ADownImage, AHotImage: TAsphyreImage; const ARenderActionCaption: Boolean = FALSE; const AFontScale: Single = 1): Integer;
    function GetDXButton(const AId: Integer): TDXButton;

    property DXButtons: TObjectList<TDXButton> read FDXButtons;
    property RenderHandle: THandle read FHandle;
  end;

implementation

uses
  {$IFDEF DEBUG} Poker.Forms.Debug, {$ENDIF}
  Poker.DirectX.Core, Poker.Tables.Resources, Asphyre.Canvas, Poker.Players.PlayerList, Poker.Protobufs.Objects.SeatInfo,
  Poker.Common.Misc, Poker.Protobufs.Objects.Game, Poker.Server.Settings, Poker.DirectX.Animation, System.DateUtils,
  Poker.DirectX.Timer, Poker.Sounds, Poker.HandStrengthCalculator, Poker.Settings, Poker.Players.Player, Poker.Helpers.PB_Pot,
  Poker.Avatars.AvatarList, Poker.Avatars.Avatar, Poker.DataModule, Poker.Clubs.Club, Poker.Tables.TableList, Poker.Tables.Table,
  Poker.Protobufs.Objects.TableMessage, Poker.Server.Socket, Poker.Tournaments, Poker.Tournaments.Info, Poker.Protobufs.Objects.ClubMember;

{ TTableRenderer }

constructor TTableRenderer.Create(const AInternalId: Integer; const AInternalHWND: HWND; const ATableType: TTableType);
begin
  FEnabled := FALSE;
  FInternalId := AInternalId;
  FInternalHWND := AInternalHWND;
  FMetrics := TTableRenderMetrics.Create;
  FChipStackMaker := TChipStackMaker.Create;
  FDXButtons := TObjectList<TDXButton>.Create;
  FTableType := ATableType;

  FPots := TPB_PotList.Create;
  FBets := TList<Integer>.Create;
{  FAnimations := Poker.DirectX.Animations.TDXAnimations.Create;
  FAnimations.Start;
}
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
  FBets.Free;
  FPots.Free;

{  FAnimations.Terminate;
  FAnimations.Signal;
  FAnimations.WaitFor;
  FAnimations.Free;
 }
  FDealAnimations.Free;
  FFlopAnimations.Free;
  FTurnAnimations.Free;
  FRiverAnimations.Free;
  FBetAnimations.Free;
  FPotWinAnimations.Free;

  FDXButtons.Free;
  FChipStackMaker.Free;
  FMetrics.Free;
  DXCore.ReleaseSwapChainElement(FSwapChainIndex);

  inherited;
end;

procedure TTableRenderer.Disable;
begin
  FEnabled := FALSE;
end;

procedure TTableRenderer.Enable;
begin
  FEnabled := TRUE;
end;

function TTableRenderer.AcquireSwapChainElement: Boolean;
begin
  result := DXCore.AcquireSwapChainElement(0, FSwapChainIndex);
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

procedure TTableRenderer.SetTableId(const AId: Integer);
begin
  FInternalId := AId;
end;

procedure TTableRenderer.SetRenderTarget(const AHandle: THandle);
begin
  FHandle := AHandle;
  DXCore.ModifySwapChainElement(FSwapChainIndex, FHandle);
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
  if not FRaiseThumbDown then
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
  table: TTable;
  render_it: Boolean;
begin
  ASetRaiseAmount := FALSE;
  render_it := FALSE;

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

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    // render folded cards if needed, and set flag, so we can re-render scene once mouse cursor leaves the seat, and unset the flag then
    if (table.Status.State > tsIdle) and
       (FMetrics.IsPointInSeat(table.Game, X, Y, seat_index)) and
       (table.Status.GetSeatInfo(seat_index, seat)) and
       (seat.Cards.IsKnown) and
       (seat.Status = psFolded) then
    begin
      FRenderingFoldedCards := TRUE;
      render_it := TRUE;
    end
    else
      if FRenderingFoldedCards then
      begin
        FRenderingFoldedCards := FALSE;
        render_it := TRUE;
      end;
  finally
    Tables.Unlock;
  end;

  if render_it then
    Render;
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
  client_rect: TRect;
  table: TTable;
begin
  result := FALSE;
  if FHandle > 0 then
    Winapi.Windows.GetClientRect(FHandle, client_rect);

  // DXAreaSize width/height must always be greater than zero, otherwise swap chain element will get destroyed by Asphyre, causing black screen
  if (client_rect.Width > 0) and
     (client_rect.Height > 0) then
  begin
    FDXAreaSize := Point2px(client_rect.Width, client_rect.Height);
    result := TRUE;
  end
  else
    FDXAreaSize := Point2px(1, 1);

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    FMetrics.Update(table, FDXAreaSize, FRaiseThumbPosition);
  finally
    Tables.Unlock;
  end;

  if FDXAreaSize <> FLastDXAreaSize then
  begin
    DXCore.Device.Resize(FSwapChainIndex, FDXAreaSize);
//    FAnimations.DXAreaSize := FDXAreaSize;
    FLastDXAreaSize := FDXAreaSize;
  end;
end;

procedure TTableRenderer.Render(const AUpdateDXAreaSize: Boolean = TRUE);
begin
  if not FEnabled then
    Exit;

  if (not AUpdateDXAreaSize) or
     (UpdateDXAreaSize) then
    DXCore.Device.Render(FSwapChainIndex, RenderEvent, 0);
end;

procedure TTableRenderer.RenderEvent(Sender: TObject);
var
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    RenderBackground(table.Game);
    RenderTable;
    RenderTableMessages(table.Game);
    RenderTableCards;
    RenderDealerButton(table.Game);
    RenderDealingCardsAni;
    RenderSeats(table.Game);
    RenderBets(table.Game);
    RenderPots;
    RenderTimebar(table.Game);
    RenderRake;
    RenderRaisePanel;
    RenderButtons;
  finally
    Tables.Unlock;
  end;
end;

procedure TTableRenderer.RenderBackground;
var
  background_image: TAsphyreImage;
begin
  if AGameInfo.FinalTable then
    background_image := TableResources.FinalRoomBackgroundImage
  else
    background_image := TableResources.RoomBackgroundImage;

  if FTableType = ttHandReplay then
    DXCore.Canvas.UseImage(TableResources.GrayscaleVersion(background_image), TexFull4)
  else
    DXCore.Canvas.UseImage(background_image, TexFull4);
  DXCore.Canvas.TexMap(pBounds4(0, 0, FDXAreaSize.x, FDXAreaSize.y), clWhite4);
end;

procedure TTableRenderer.RenderTable;
begin
  if FTableType = ttHandReplay then
    DXCore.Canvas.UseImage(TableResources.GrayscaleVersion(TableResources.TableImage), TexFull4)
  else
    DXCore.Canvas.UseImage(TableResources.TableImage, TexFull4);
  DXCore.Canvas.TexMap(FMetrics.RawTableBounds, clWhite4);
end;

procedure TTableRenderer.RenderSeats(const AGameInfo: TGameInfo);
var
  C1: Integer;
begin
  for C1 := 0 to AGameInfo.Seats - 1 do
    RenderSeat(AGameInfo, C1);
end;

procedure TTableRenderer.RenderSeat(const AGame: TGameInfo; const ASeatIndex: Integer);
var
  seat_point: TPoint2;
  seat_info: TSeatInfo;
  player_info: TPlayerInfo;
  seat_image: TAsphyreImage;
  seat_empty_image: TAsphyreImage;
  seat_empty_image_no_text: TAsphyreImage;
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
  table: TTable;
  member: TPB_ClubMember;
begin
  // get seat point
  seat_point := FMetrics.GetSeatPoint(AGame, ASeatIndex);

  // calculate seat elements positions & dimensions
  avatar_width := TableResources.SEAT_AVATAR_WIDTH * FMetrics.SeatResizeRatio;
  avatar_height := TTableResources.SEAT_AVATAR_HEIGHT * FMetrics.SeatResizeRatio;

  if FMetrics.GetTableSector(seat_point) in [tsLeft, tsTopLeft, tsBottomLeft] then
  begin
    seat_empty_image := TableResources.SeatLeftEmptyImage;
    seat_empty_image_no_text := TableResources.SeatLeftEmptyTournamentImage;
    seat_inactive_image := TableResources.SeatLeftImage;
    seat_active_image := TableResources.SeatLeftActiveImage;

    avatar_point := Point2(seat_point.X - FMetrics.SeatWidth / 2 + TableResources.SEAT_LEFT_AVATAR_X * FMetrics.SeatResizeRatio, seat_point.Y);
    seat_text_x_center := seat_point.X - (seat_point.X + FMetrics.SeatWidth / 2 - avatar_point.X) / 2 - 10 * FMetrics.SeatResizeRatio;
  end
  else
  begin
    seat_empty_image := TableResources.SeatRightEmptyImage;
    seat_empty_image_no_text := TableResources.SeatRightEmptyTournamentImage;
    seat_inactive_image := TableResources.SeatRightImage;
    seat_active_image := TableResources.SeatRightActiveImage;

    avatar_point := Point2(seat_point.X - FMetrics.SeatWidth / 2 + TableResources.SEAT_RIGHT_AVATAR_X * FMetrics.SeatResizeRatio, seat_point.Y);
    seat_text_x_center := seat_point.X + (avatar_point.X - (seat_point.X - FMetrics.SeatWidth / 2) - 10 * FMetrics.SeatResizeRatio);
  end;
  seat_upper_text_point := Point2(seat_text_x_center, seat_point.Y - FMetrics.SeatHeight / 4.5);
  seat_lower_text_point := Point2(seat_text_x_center, seat_point.Y + FMetrics.SeatHeight / 5);
  seat_action_frame_point := Point2(seat_point.x, seat_point.Y + FMetrics.SeatHeight / 2 + FMetrics.SeatActionFrameHeight / 2.15);

  // seat taken
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.Status.GetSeatInfo(ASeatIndex, seat_info) then
    begin
      // find player info
      if not Players.TryGetValue(seat_info.PlayerMongoId, player_info) then
        player_info := nil;

      // set seat image that we should render
      if (table.Status.CurrentSeat = seat_info.SeatIndex) and
         (not table.Status.Locked) and
         (not table.GameplayLocked) then
        seat_image := seat_active_image
      else
        seat_image := seat_inactive_image;

      if Assigned(player_info) then
      begin
        // set avatar
        avatar := Avatars.Add(player_info.Avatar, nil);

        // set seat upper text
        seat_upper_text := player_info.Displayname;
        seat_upper_text_color := cColor2($FFCCCCCC);
      end
      else
      begin
        // set seat upper text
        seat_upper_text := seat_info.UpperCaption;
        seat_upper_text_color := cColor2($FFCCCCCC);

        avatar := Avatars.DefaultAvatar;
      end;

      // make seat blink text to blnk if its disconnected
      if (seat_info.Disconnected) and
         (MilliSecondsBetween(Now, seat_info.LastDisconnectedBlink) > 1200) then
      begin
        seat_info.ShowDisconnectedLabel := not seat_info.ShowDisconnectedLabel;
        seat_info.LastDisconnectedBlink := Now;
      end;

      // set seat lower text
      if seat_info.ShowDisconnectedLabel then
      begin
        seat_lower_text := 'Disconnected';
        seat_lower_text_color := cColor2($FFFF3535);
      end
      else
      begin
        seat_lower_text_color := cColor2($FF8DC63F);
        case seat_info.Status of
          psOutOfPlay: begin
            if (table.Club.GetMemberInfo(seat_info.PlayerMongoId, member)) and
               (member.Suspended) then
            begin
              seat_lower_text := 'Suspended';
              seat_lower_text_color := cColor2($FFFF3535);
            end
            else
              seat_lower_text := 'Sitting Out';
          end;
        else
          if FWinningAniDelay > 0 then
            seat_lower_text := ChipsToStr(seat_info.PreviousChips)
          else
            seat_lower_text := ChipsToStr(seat_info.Chips);
        end;
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
      if table.Status.State > tsIdle then
      begin
        case seat_info.Status of
          psInHand, psAllIn: begin
            for C1 := 0 to seat_info.DealtCards - 1 do
            begin
              card_point := FMetrics.GetCardPoint(AGame, seat_info, C1);
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

            if (seat_info.Cards.IsKnown) and
               ((System.Types.PtInRect(RectF(seat_point.x - FMetrics.SeatWidth / 2, seat_point.y - FMetrics.SeatHeight / 2,
                       seat_point.x + FMetrics.SeatWidth / 2, seat_point.y + FMetrics.SeatHeight / 2), mousepointf)) or
                (seat_info.CardsVisible)) then
              for C1 := 0 to seat_info.Cards.Count - 1 do
              begin
                card_point := FMetrics.GetCardPoint(AGame, seat_info, C1);
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
                      Low(TableResources.BarmenoFonts), 16, 0, FMetrics.SeatHeight * 0.36, FMetrics.SeatWidth * 0.6);

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
      if FTableType = ttLive then
        DXCore.Canvas.UseImage(seat_empty_image, TexFull4)
      else
        DXCore.Canvas.UseImage(seat_empty_image_no_text, TexFull4);
      DXCore.Canvas.TexMap(pBounds4(seat_point.X - FMetrics.SeatWidth / 2, seat_point.Y - FMetrics.SeatHeight / 2, FMetrics.SeatWidth, FMetrics.SeatHeight), clWhite4);
    end;
  finally
    Tables.Unlock;
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
begin
  if ATransparency > 0 then
    color := cAlpha4(ATransparency)
  else
    color := clWhite4;

  if (not Assigned(ACard)) or
     (not ACard.IsKnown) then
  begin
    // render card background
    DXCore.Canvas.UseImagePx(TableResources.CardBackgroundImage,
      pBounds4(0, 0,
        TableResources.CardBackgroundImage.Texture[0].Width,
        TableResources.CardBackgroundImage.Texture[0].Height * APercentage));
    DXCore.Canvas.TexMap(pBounds4(APoint.x, APoint.y + 2, FMetrics.CardWidth, FMetrics.CardHeight * APercentage), color);
  end
  else
  begin
    // render card front background
    DXCore.Canvas.UseImagePx(TableResources.CardFrontBackgroundImage,
      pBounds4(0, 0,
        TableResources.CardFrontBackgroundImage.Texture[0].Width,
        TableResources.CardFrontBackgroundImage.Texture[0].Height * APercentage));

    DXCore.Canvas.TexMap(pBounds4(APoint.x, APoint.y + 2, FMetrics.CardWidth, FMetrics.CardHeight * APercentage), color);

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
      DXCore.Canvas.TexMap(artwork_points, color);

      // render rectangle frame around artwork
      DXCore.Canvas.FrameRect(artwork_points, cColorAlpha4($FFCFCFCF, ATransparency));
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

procedure TTableRenderer.RenderTableMessages(const AGame: TGameInfo);
var
  mins: Integer;
  txt: String;
  table: TTable;
  min_end_time: UINT64;
  duration, gtc: UINT32;
  tmessage, render_tmessage: TPB_TableMessage;
  tournament: TTournamentInfo;
begin
  txt := '';
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    min_end_time := 0;
    render_tmessage := nil;
    for tmessage in table.Status.Messages do
      if (min_end_time = 0) or
         (tmessage.EndTime < min_end_time) then
      begin
        min_end_time := tmessage.EndTime;
        render_tmessage := tmessage;
      end;

    if Assigned(render_tmessage) then
    begin
      gtc := GetTickCount;
      min_end_time := render_tmessage.EndTime - ServerSocket.TimeOffset;
      if min_end_time < gtc then
        duration := 0
      else
        duration := min_end_time - gtc;

      case render_tmessage.Message of
        tmtClosing: begin
          if duration = 0 then
            txt := 'Table is closing after current hand'
          else
          begin
            mins := duration div 60000 + 1;
            if mins = 1 then
              txt := 'Table is closing in less than a minute'
            else
              txt := Format('Table is closing in %d minutes', [mins]);
          end;
        end;

        tmtTournamentBreak: begin
          mins := duration div 60000 + 1;
          if mins = 1 then
            txt := 'Break (ending in less than a minute)'
          else
            txt := Format('Break (%d minutes left)', [mins]);
        end;

        tmtTournamentStart: begin
          mins := duration div 60000 + 1;
          if mins = 1 then
            txt := 'Tournament is starting in less than a minute'
          else
            txt := Format('Tournament is starting in %d minutes', [mins]);
        end;
      end;
    end;

    if not table.TournamentId.IsEmpty then
    begin
      if Tournaments.GetAndLock(table.TournamentId, tournament) then
      try
        if (tournament.SecondsUntilNextLevel > Integer(tournament.Timeperlevel * 60 - 15)) and
           (tournament.SecondsUntilNextLevel <= Integer(tournament.Timeperlevel * 60)) and
           (tournament.CurrentBlindLevel > 0) then
          txt := Format('Blinds are going up. Level %d (%d/%d)', [tournament.CurrentBlindLevel + 1, tournament.BlindStructure[tournament.CurrentBlindLevel].Sb, tournament.BlindStructure[tournament.CurrentBlindLevel].Bb]);
      finally
        Tournaments.Unlock;
      end;
    end;
  finally
    Tables.Unlock;
  end;

  if AGame.State = gsClosed then
    txt := 'Table is closed';

  if txt <> '' then
    RenderScaleFont(txt, clWhite2, Point2(FMetrics.TableCenter.x, FMetrics.TableCenter.Y + FMetrics.CardHeight / 3), TableResources.SintonyFonts,
                    Low(TableResources.SintonyFonts), 12, 16, 2, 8 + 8 * FMetrics.TableResizeRatio, 0);
end;

procedure TTableRenderer.RenderTimebar(const AGame: TGameInfo);
var
  seat: TSeatInfo;
  seat_point: TPoint2;
  time_percent: Single;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.Status.Locked) or
       (table.Status.Time = 0) or
       (table.Status.TimebarEndtime = 0) or
       (table.GameplayLocked) then
      Exit;

    if table.Status.GetSeatInfo(table.Status.CurrentSeat, seat) then
    begin
      seat_point := FMetrics.GetSeatPoint(AGame, seat.SeatIndex);

      table.Status.UpdateCurrentPlaytime;
      if table.Status.CurrentPlaytime > 0 then
      begin
        FTimeImage := TableResources.TimebarImage;
        time_percent := (table.Status.CurrentPlaytime / (ServerSettings.Playtime * 1000)) * 1.5;
      end
      else
      begin
        // using timebank..
        if (FTimeImage <> TableResources.TimebankImage) and
           (table.Status.CurrentSeat = table.Status.SelfSeatIndex) and
           (Assigned(FOnTimebankStarted)) then
          FOnTimebankStarted(self);

        FTimeImage := TableResources.TimebankImage;
        time_percent := (Integer(seat.Timebank) + table.Status.CurrentPlaytime) / (ServerSettings.Timebank * 1000);
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
  finally
    Tables.Unlock;
  end;
end;

procedure TTableRenderer.RenderTableCards;
const
  SPLIT_COUNT = 2;
var
  C1, C2: Integer;
  card_points_curr: array[0..SPLIT_COUNT - 1] of array of TPoint2;
  card_points_mid: array[0..SPLIT_COUNT - 1] of array of TPoint2;
  card_points_final: array[0..SPLIT_COUNT - 1] of array of TPoint2;
  show_cards: array[0..SPLIT_COUNT - 1] of array of Integer; // -1 - hide completely, 0 - card face down, 1 - card face up
  animation: TDXAnimation;
  table: TTable;
  crow, cindex: Integer;
  indexv: Variant;
  currcardpoint: TPoint2;
begin
  for C1 := Low(card_points_final) to High(card_points_final) do
  begin
    SetLength(card_points_final[C1], 5);
    SetLength(card_points_curr[C1], 5);
    SetLength(card_points_mid[C1], 5);
    SetLength(show_cards[C1], 5);
    for C2 := Low(show_cards[C1]) to High(show_cards[C1]) do
      show_cards[C1][C2] := -1;
  end;

  for C1 := Low(card_points_final) to High(card_points_final) do
    for C2 := Low(card_points_final[C1]) to High(card_points_final[C1]) do
    begin
      card_points_final[C1][C2].x := FMetrics.TableCenter.X - (FMetrics.CardWidth * 5) / 2 - 4 * 3 + (C2 * FMetrics.CardWidth) + (C2 * 3);
      card_points_final[C1][C2].y := FMetrics.TableCenter.Y - FMetrics.CardHeight / 2 + C1 * FMetrics.CardHeight / 3;
      card_points_curr[C1][C2] := card_points_final[C1][C2];
      card_points_mid[C1][C2] := card_points_final[C1][C2];
    end;

  for C1 := Low(card_points_mid) to High(card_points_mid) do
  begin
    card_points_mid[C1][0].x := card_points_final[C1][0].x - 5;
    card_points_mid[C1][1].x := card_points_final[C1][0].x - 0;
    card_points_mid[C1][2].x := card_points_final[C1][0].x + 5;
  end;
//  card_points_mid[3].x := card_points_final[3].x + FCardWidth / 2;
//  card_points_mid[4].x := card_points_final[4].x + FCardWidth / 2;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.Status.FlopCards.Count > 0) and
       (table.Status.State >= tsFlop) then
    begin
      if not FFlopAnimated then
      begin
        FFlopAnimations.Clear;

        for C1 := 0 to table.Status.FlopCards.Count - 1 do
        begin
          animation := DXTimer.AddAnimation(FInternalHWND, FMetrics.DealerPoint, card_points_mid[C1][0],
              0.15, 0.9 + C1 * 2.5, 0.2, FDXAreaSize);
          animation.Tags.AddOrSetValue(ANITAG_CARD_INDEX, C1 * 5 + 0);
          animation.Tags.AddOrSetValue(ANITAG_SHOW_CARD, 0);
          FFlopAnimations.Add(animation.Id);

          animation := DXTimer.AddAnimation(FInternalHWND, FMetrics.DealerPoint, card_points_mid[C1][1],
              0.15, 0.9 + C1 * 2.5, 0.2, FDXAreaSize);
          animation.Tags.AddOrSetValue(ANITAG_CARD_INDEX, C1 * 5 + 1);
          animation.Tags.AddOrSetValue(ANITAG_SHOW_CARD, 0);
          FFlopAnimations.Add(animation.Id);

          animation := DXTimer.AddAnimation(FInternalHWND, FMetrics.DealerPoint, card_points_mid[C1][2],
              0.15, 0.9 + C1 * 2.5, 0.2, FDXAreaSize);
          animation.Tags.AddOrSetValue(ANITAG_CARD_INDEX, C1 * 5 + 2);
          animation.Tags.AddOrSetValue(ANITAG_SHOW_CARD, 0);
          FFlopAnimations.Add(animation.Id);

          // second phase

          animation := DXTimer.AddAnimation(FInternalHWND, card_points_mid[C1][0], card_points_final[C1][0],
              0.2, 1.1 + C1 * 2.5, Abs(C1 - 1) * 2.5, FDXAreaSize);
          animation.Tags.AddOrSetValue(ANITAG_CARD_INDEX, C1 * 5 + 0);
          animation.Tags.AddOrSetValue(ANITAG_SHOW_CARD, 1);
          FFlopAnimations.Add(animation.Id);

          animation := DXTimer.AddAnimation(FInternalHWND, card_points_mid[C1][1], card_points_final[C1][1],
              0.2, 1.1 + C1 * 2.5, Abs(C1 - 1) * 2.5, FDXAreaSize);
          animation.Tags.AddOrSetValue(ANITAG_CARD_INDEX, C1 * 5 + 1);
          animation.Tags.AddOrSetValue(ANITAG_SHOW_CARD, 1);
          FFlopAnimations.Add(animation.Id);

          animation := DXTimer.AddAnimation(FInternalHWND, card_points_mid[C1][2], card_points_final[C1][2],
              0.2, 1.1 + C1 * 2.5, Abs(C1 - 1) * 2.5, FDXAreaSize);
          animation.Tags.AddOrSetValue(ANITAG_CARD_INDEX, C1 * 5 + 2);
          animation.Tags.AddOrSetValue(ANITAG_SHOW_CARD, 1);
          FFlopAnimations.Add(animation.Id);
        end;

        FFlopAnimated := TRUE;
      end;

      if FFlopAnimations.Count > 0 then
        if DXTimer.AnimationsEnabled then
        begin
          for C1 := 0 to FFlopAnimations.Count - 1 do
            if (DXTimer.Find(FInternalHWND, FFlopAnimations[C1], animation)) and
               (animation.Status in [asAnimating, asDone]) then
            begin
              crow := Integer(animation.Tags[ANITAG_CARD_INDEX]) div 5;
              cindex := Integer(animation.Tags[ANITAG_CARD_INDEX]) mod 5;
              card_points_curr[crow][cindex] := animation.GetCurrPoint(FDXAreaSize);
              show_cards[crow][cindex] := animation.Tags[ANITAG_SHOW_CARD];
            end;
        end
        else
        begin
          for C1 := Low(show_cards) to High(show_cards) do
          begin
            show_cards[C1][0] := -1;
            show_cards[C1][1] := -1;
            show_cards[C1][2] := -1;
          end;
        end
      else
        for C1 := Low(show_cards) to High(show_cards) do
        begin
          show_cards[C1][0] := 1;
          show_cards[C1][1] := 1;
          show_cards[C1][2] := 1;
        end;

      for C1 := 0 to table.Status.FlopCards.Count - 1 do
        for C2 := 0 to table.Status.FlopCards[C1].Count - 1 do
          case show_cards[C1][C2] of
            -1: Continue;
             0: RenderCard(card_points_curr[C1][C2], nil, 1);
             1: RenderCard(card_points_curr[C1][C2], table.Status.FlopCards[C1][C2], 1);
          end;
    end;

    if table.Status.State >= tsTurn then
    begin
      if not FTurnAnimated then
      begin
        FTurnAnimations.Clear;
        for C1 := 0 to table.Status.TurnCard.Count - 1 do
        begin
          animation := DXTimer.AddAnimation(FInternalHWND, FMetrics.DealerPoint,
             card_points_final[C1][3], 0.15, 0.75 + FWinningTurnAniDelay + C1 * 2.5,
             Abs(C1 - 1) * 2.5, FDXAreaSize);
          animation.Tags.AddOrSetValue(ANITAG_CARD_INDEX, C1 * 5 + 3);
          FTurnAnimations.Add(animation.Id);
        end;
        FTurnAnimated := TRUE;
      end;

      if FTurnAnimations.Count > 0 then
      begin
        if DXTimer.AnimationsEnabled then
        begin
          for C1 := 0 to FTurnAnimations.Count - 1 do
            if (DXTimer.Find(FInternalHWND, FTurnAnimations[C1], animation)) and
               (animation.Status = asAnimating) then
            begin
              currcardpoint := animation.GetCurrPoint(FDXAreaSize);
              if animation.Tags.TryGetValue(ANITAG_CARD_INDEX, indexv) then
                RenderCard(currcardpoint, table.Status.TurnCard[Integer(indexv) div 5], 1)
              else
                RenderCard(currcardpoint, nil, 1);
            end;
        end;
      end
      else
        for C1 := 0 to table.Status.TurnCard.Count - 1 do
          RenderCard(card_points_final[C1][3], table.Status.TurnCard[C1], 1);
    end;

    if table.Status.State >= tsRiver then
    begin
      if not FRiverAnimated then
      begin
        FRiverAnimations.Clear;
        for C1 := 0 to table.Status.RiverCard.Count - 1 do
        begin
          animation := DXTimer.AddAnimation(FInternalHWND, FMetrics.DealerPoint,
             card_points_final[C1][4], 0.15, 0.75 + FWinningRiverAniDelay + C1 * 2.5,
             Abs(C1 - 1) * 2.5, FDXAreaSize);
          animation.Tags.AddOrSetValue(ANITAG_CARD_INDEX, C1 * 5 + 4);
          FRiverAnimations.Add(animation.Id);
        end;
        FRiverAnimated := TRUE;
      end;

      if FRiverAnimations.Count > 0 then
      begin
        if DXTimer.AnimationsEnabled then
        begin
          for C1 := 0 to FRiverAnimations.Count - 1 do
            if (DXTimer.Find(FInternalHWND, FRiverAnimations[C1], animation)) and
               (animation.Status = asAnimating) then
            begin
              currcardpoint := animation.GetCurrPoint(FDXAreaSize);
              if animation.Tags.TryGetValue(ANITAG_CARD_INDEX, indexv) then
                RenderCard(currcardpoint, table.Status.RiverCard[Integer(indexv) div 5], 1)
              else
                RenderCard(currcardpoint, nil, 1);
            end;
        end;
      end
      else
        for C1 := 0 to table.Status.RiverCard.Count - 1 do
          RenderCard(card_points_final[C1][4], table.Status.RiverCard[C1], 1);
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TTableRenderer.RenderDealerButton(const AGame: TGameInfo);
var
  dealer_point: TPoint2;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if table.Status.Dealer = -1 then
      Exit;

    dealer_point := FMetrics.GetDealerPoint(AGame, table.Status.Dealer);

    DXCore.Canvas.UseImage(TableResources.DealerButtonImage, TexFull4);
    DXCore.Canvas.TexMap(pBounds4(dealer_point.X - FMetrics.DealerButtonWidth / 2, dealer_point.Y - FMetrics.DealerButtonHeight / 2,
         FMetrics.DealerButtonWidth, FMetrics.DealerButtonHeight), clWhite4);
  finally
    Tables.Unlock;
  end;
end;

procedure TTableRenderer.RenderDealingCardsAni;
var
  C1: Integer;
  animation: TDXAnimation;
begin
  if not DXTimer.AnimationsEnabled then
    Exit;

  for C1 := 0 to FDealAnimations.Count - 1 do
    if (DXTimer.Find(FInternalHWND, FDealAnimations[C1], animation)) and
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

procedure TTableRenderer.RenderBets(const AGame: TGameInfo);
var
  C1, C2: Integer;
  chips_point: TPoint2;
  chips_stack: TChipStack;
  animation: TDXAnimation;
  seat_index: Integer;
  animated_seats: TList<Integer>;
  table: TTable;
begin
  animated_seats := TList<Integer>.Create;
  try
    for C2 := 0 to FBetAnimations.Count - 1 do
      if DXTimer.Find(FInternalHWND, FBetAnimations[C2], animation) then
      begin
        if (not animation.Tags.ContainsKey(ANITAG_BLIND)) or
           (animation.Status = asAnimating) then
        begin
          chips_stack := FChipStackMaker.MakeStack(animation.Tags[ANITAG_CHIPS]);
          chips_point := animation.GetCurrPoint(FDXAreaSize);
          RenderChipStack(chips_point, chips_stack, clWhite4);

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

    if (FPotWinAnimations.Count = 0) and
       (Tables.GetAndLockTable(FInternalId, table)) then
    try
      for C1 := 0 to table.Status.Seats.Count - 1 do
      begin
        seat_index := table.Status.Seats[C1].SeatIndex;

        if (not animated_seats.Contains(seat_index)) and
           (table.Status.Bets.Count > seat_index) and
           (table.Status.Bets[seat_index] > 0) then
        begin
          chips_point := FMetrics.GetBetPoint(AGame, seat_index, table.Status.Dealer);
          chips_stack := FChipStackMaker.MakeStack(table.Status.Bets[seat_index]);
          RenderChipStack(chips_point, chips_stack, clWhite4);
          RenderValue(chips_point, table.Status.Bets[seat_index], clWhite2, FALSE);
        end;
      end;
    finally
      Tables.Unlock;
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
  pots: TPB_PotList;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if FBetAnimations.Count = 0 then
      pots := table.Status.Pots
    else
      pots := table.Status.PreviousPots;

    for C1 := 0 to pots.Count - 1 do
    begin
      pot_value := pots[C1].ValueWithoutRake;

      for C2 := 0 to FPotWinAnimations.Count - 1 do
        if (DXTimer.Find(FInternalHWND, FPotWinAnimations[C2], animation)) and
           (animation.Tags[ANITAG_POT_INDEX] = C1) and
           (animation.Status in [asAnimating, asDone]) then
        begin
          chips_stack := FChipStackMaker.MakeStack(animation.Tags[ANITAG_CHIPS]);
          RenderChipStack(animation.GetCurrPoint(FDXAreaSize), chips_stack, clWhite4);

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
          RenderChipStack(pot_point, chips_stack, clWhite4);
          RenderValue(pot_point, pot_value, clWhite2, TRUE);
        end;
      end;
    end;
  finally
    Tables.Unlock;
  end;
end;

procedure TTableRenderer.RenderValue(const APoint: TPoint2; const AValue: UINT32; const AColor: TColor2; const APot: Boolean);
var
  font: TAsphyreFont;
  text: String;
  p: TPoint2;
begin
  if AValue = 0 then
    Exit;

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

procedure TTableRenderer.RenderChipStack(const APoint: TPoint2; const AChipStack: TChipStack; const AColor: TColor4);
var
  C1: Integer;
begin
  if Length(AChipStack.Images) = 0 then
    Exit;

  for C1 := Low(AChipStack.Images) to High(AChipStack.Images) do
  begin
    DXCore.Canvas.UseImage(AChipStack.Images[C1], TexFull4);
    DXCore.Canvas.TexMap(pBounds4(APoint.X - FMetrics.ChipWidth / 2,
        APoint.Y - C1 * 5 * FMetrics.TableResizeRatio, FMetrics.ChipWidth, FMetrics.ChipHeight), AColor);
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
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.Status.ActionRaise) or
       (table.Status.ActionBet) then
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
  finally
    Tables.Unlock;
  end;
end;

procedure TTableRenderer.RenderRake;
var
  table: TTable;
  rake: UINT32;
  chips_stack: TChipStack;
begin
  rake := 0;
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    rake := table.Status.TotalRake;
  finally
    Tables.Unlock;
  end;

  if (rake > 0) and
     (rake < 100) then
    rake := 100;

  chips_stack := FChipStackMaker.MakeStack(rake);
  RenderChipStack(FMetrics.TotalRakePoint, chips_stack, cRGB4(110, 110, 110));
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
var
  table: TTable;
begin
//  FAnimations.Clear;

  FFlopAnimations.Clear;
  FTurnAnimations.Clear;
  FRiverAnimations.Clear;
  FDealAnimations.Clear;
  FBetAnimations.Clear;
  FPotWinAnimations.Clear;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    FFlopAnimated := table.Status.State >= tsFlop;
    FTurnAnimated := table.Status.State >= tsTurn;
    FRiverAnimated := table.Status.State >= tsRiver;
  finally
    Tables.Unlock;
  end;
end;

procedure TTableRenderer.AnimationCallback(const AAnimationPointer: pointer);
var
  seat_index: Integer;
  seat: TSeatInfo;
  animation: TDXAnimation;
  table: TTable;
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
        if Tables.GetAndLockTable(FInternalId, table) then
        try
          table.Status.PreviousPots.Clear;
          table.Status.Pots.Clear;
        finally
          Tables.Unlock;
        end;
      end;
    end;

    if FDealAnimations.Contains(animation.Id) then
    begin
      seat_index := animation.Tags[ANITAG_SEAT];
      if Tables.GetAndLockTable(FInternalId, table) then
      try
        if table.Status.GetSeatInfo(seat_index, seat) then
          seat.DealtCards := seat.DealtCards + 1;
      finally
        Tables.Unlock;
      end;
      FDealAnimations.Remove(animation.Id);
      if (FDealAnimations.Count = 0) and
         (Assigned(FOnUpdateHandStrength)) then
        FOnUpdateHandStrength(self);
    end;
  end;

  if Tables.GetAndLockTable(FInternalId, table) then
  try
    Render;
  finally
    Tables.Unlock;
  end;
end;

function TTableRenderer.AnimateBets(ABets: TList<UINT32>; const ASeatIndex: Integer = -1): Boolean;
var
  C1: Integer;
  bet_point: TPoint2;
  pot_point: TPoint2;
  animation: TDXAnimation;
  table: TTable;
begin
  result := FALSE;
  for C1 := 0 to ABets.Count - 1 do
    if (ABets[C1] > 0) and
       ((ASeatIndex = -1) or
        (ASeatIndex = C1)) then
    begin
      if Tables.GetAndLockTable(FInternalId, table) then
      try
        bet_point := FMetrics.GetBetPoint(table.Game, C1, table.Status.Dealer);
      finally
        Tables.Unlock;
      end;

      pot_point := FMetrics.GetPotPoint(0);

      animation := DXTimer.AddAnimation(FInternalHWND, bet_point, pot_point, Settings.Hardcoded.ANIMATION_METRICS.BETS_SPEED,
          Settings.Hardcoded.ANIMATION_METRICS.BETS_START_DELAY, 0, FDXAreaSize);
      animation.Tags.AddOrSetValue(ANITAG_SEAT, C1);
      animation.Tags.AddOrSetValue(ANITAG_CHIPS, ABets[C1]);
      if ASeatIndex <> -1 then
        animation.Tags.AddOrSetValue(ANITAG_SOUND, Sounds.SOUND_MOVE_CHIPS);
      FBetAnimations.Add(animation.Id);

      result := TRUE;
    end;
end;

procedure TTableRenderer.AnimateBlinds;
var
  bet_point_sb, bet_point_bb: TPoint2;
  animation: TDXAnimation;
  table: TTable;
begin
  if Tables.GetAndLockTable(FInternalId, table) then
  try
    if (table.Status.SmallBlindSeat < 0) or (table.Status.SmallBlindSeat > table.Status.Bets.Count - 1) or
       (table.Status.BigBlindSeat < 0) or (table.Status.BigBlindSeat > table.Status.Bets.Count - 1) then
      Exit;

    bet_point_sb := FMetrics.GetBetPoint(table.Game, table.Status.SmallBlindSeat, table.Status.Dealer);
    bet_point_bb := FMetrics.GetBetPoint(table.Game, table.Status.BigBlindSeat, table.Status.Dealer);

    animation := DXTimer.AddAnimation(FInternalHWND, bet_point_sb, bet_point_sb, 0.1, 0.1, 0.9, FDXAreaSize);
    animation.Tags.AddOrSetValue(ANITAG_SEAT, table.Status.SmallBlindSeat);
    animation.Tags.AddOrSetValue(ANITAG_CHIPS, table.Status.Bets[table.Status.SmallBlindSeat]);
    animation.Tags.AddOrSetValue(ANITAG_BLIND, TRUE);
    animation.Tags.AddOrSetValue(ANITAG_SOUND, Sounds.SOUND_PUTCHIPS_SMALL);
    FBetAnimations.Add(animation.Id);

    animation := DXTimer.AddAnimation(FInternalHWND, bet_point_bb, bet_point_bb, 0.1, 0.5, 0.5, FDXAreaSize);
    animation.Tags.AddOrSetValue(ANITAG_SEAT, table.Status.BigBlindSeat);
    animation.Tags.AddOrSetValue(ANITAG_CHIPS, table.Status.Bets[table.Status.BigBlindSeat]);
    animation.Tags.AddOrSetValue(ANITAG_BLIND, TRUE);
    animation.Tags.AddOrSetValue(ANITAG_SOUND, Sounds.SOUND_PUTCHIPS_SMALL);
    FBetAnimations.Add(animation.Id);
  finally
    Tables.Unlock;
  end;
end;

procedure TTableRenderer.AnimateDealingCards;
var
  iterate: Boolean;
  animation: TDXAnimation;
  cc: Integer;
  card_index: Integer;
  C1: Integer;
  seat: TSeatInfo;
  table: TTable;
begin
  cc := 0;
  card_index := 0;
  repeat
    iterate := FALSE;
    if Tables.GetAndLockTable(FInternalId, table) then
    try
      C1 := table.Status.SmallBlindSeat;
      if C1 < 0 then
        Break;

      repeat
        if table.Status.GetSeatInfo(C1, seat) then
        begin
          seat.DealtCards := 0;
          if seat.CardCount > card_index then
          begin
            animation := DXTimer.AddAnimation(FInternalHWND,
                  Point2(FMetrics.TableCenter.x - FMetrics.CardWidth / 2, FMetrics.TableBounds[0].y), FMetrics.GetCardPoint(table.Game, seat, card_index),
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
        if C1 >= table.Game.Seats then
          C1 := 0;
      until C1 = table.Status.SmallBlindSeat;
      Inc(card_index);
    finally
      Tables.Unlock;
    end;
  until not iterate;
end;

procedure TTableRenderer.AnimateWinnerPots(const APots: TList<TPB_Pot>);
var
  pot: TPB_Pot;
  C1, C2: Integer;
  total_chips_val: UINT32;
  nick_list: TStringList;
  nick, nicks: String;
  animation: TDXAnimation;
  seat: TSeatInfo;
  player: TPlayerInfo;
  suffix, chips_plural: String;
  winmsg: String;
  bet_point: TPoint2;
  table: TTable;
begin
  for C1 := 0 to APots.Count - 1 do
  begin
    pot := APots[C1];

    if (pot.Value = 0) or (pot.WinnerData.Count = 0) then
      Continue;

    total_chips_val := pot.Value - pot.Rake;

    nicks := '';
    animation := nil;
    nick_list := TStringList.Create;
    try
      nick_list.Duplicates := dupIgnore;
      nick_list.Sorted := TRUE;
      nick_list.CaseSensitive := FALSE;

      for C2 := 0 to pot.WinnerData.Count - 1 do
      begin
        if Tables.GetAndLockTable(FInternalId, table) then
        try
          if (table.Status.GetSeatInfo(pot.WinnerData[C2].Seat, seat)) and
             (Players.TryGetValue(seat.PlayerMongoId, player)) then
            nick := player.Displayname
          else
            nick := Format('Seat #%d', [pot.WinnerData[C2].Seat]);

          if nick_list.IndexOf(nick) = -1 then
          begin
            nick_list.Add(nick);
            nicks := nicks + Format('%s, ', [nick]);
          end;

          // restore bets if table is in playback mode, so values are shown
          if FTableType = ttHandReplay then
            table.Status.Bets[pot.WinnerData[C2].Seat] := table.Status.Bets[pot.WinnerData[C2].Seat] + total_chips_val div UINT32(pot.WinnerData.Count);

          bet_point := FMetrics.GetBetPoint(table.Game, pot.WinnerData[C2].Seat, table.Status.Dealer);
        finally
          Tables.Unlock;
        end;

        animation := DXTimer.AddAnimation(FInternalHWND, FMetrics.GetPotPoint(C1), bet_point,
             Settings.Hardcoded.ANIMATION_METRICS.POTS_INITIAL_DELAY,
             WinningAniDelay + 1.5 + C1 * Settings.Hardcoded.ANIMATION_METRICS.POTS_INBETWEEN_DELAY,
             Settings.Hardcoded.ANIMATION_METRICS.POTS_END_DELAY,
             FDXAreaSize);

        animation.Tags.AddOrSetValue(ANITAG_POT_INDEX, C1);
        animation.Tags.AddOrSetValue(ANITAG_SEAT, pot.WinnerData[C2].Seat);
        animation.Tags.AddOrSetValue(ANITAG_CHIPS, total_chips_val div UINT32(pot.WinnerData.Count));
        PotWinAnimations.Add(animation.Id);
      end;
      if nicks <> '' then
        Delete(nicks, Length(nicks) - 1, 2);

      chips_plural := '';
      if total_chips_val <> 100 then
        chips_plural := 's';

      suffix := '';
      if nick_list.Count > 1 then
        suffix := 'each ';

      winmsg := pot.WinnerData[0].Msg;
      if winmsg = 'default' then
        winmsg := ''
      else
      begin
        if Tables.GetAndLockTable(FInternalId, table) then
        try
//          if table.Status.GetSeatInfo(pot.WinnerData[0].Seat, seat) then
//            winmsg := THandStrengthCalculator.GetHandStrength(seat.Cards.AsString, table.Status.FlopCards.AsString + table.Status.TurnCard.AsString + table.Status.RiverCard.AsString, table.Status.CurrentGame, FALSE)
//          else
//            winmsg := pot.WinnerData[0].Msg;
        finally
          Tables.Unlock;
        end;
      end;

      if winmsg <> '' then
        winmsg := Format('(%s)', [winmsg]);

      animation.Tags.AddOrSetValue(ANITAG_SOUND, Sounds.SOUND_MOVE_CHIPS);
      animation.Tags.AddOrSetValue(ANITAG_WINMSG, Format('%s won %s chip%s %s%s', [nicks, ChipsToStr(total_chips_val div UINT32(nick_list.Count)), chips_plural, suffix, winmsg]));
    finally
      nick_list.Free;
    end;
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
