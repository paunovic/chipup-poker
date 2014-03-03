unit uDCSeatData;

interface

uses
  System.SysUtils, System.Generics.Collections, GR32, uTableStatus;

type
  TStoreSeatDataResult = (ssdOK, ssdExists);

  TDCSeatData = class
  private
    FTableResizeRatio: Double;
    FSeatIndex       : Integer;
    FSeatWidth       : Integer;
    FSeatHeight      : Integer;
    FSeatImage       : TBitmap32;
    FRect            : TRect;
    FCacheImage      : TBitmap32;
    FUpperText       : WideString;
    FLowerText       : WideString;
    FUpperTextColor  : TColor32;
    FLowerTextColor  : TColor32;
    FCardCount       : Integer;
    FCardsStr        : String;
    FAvatar          : TBytes;

  public
    procedure Assign(const ASeatInfo: TSeatInfo; const ARect: TRect; const ATableResizeRatio: Double; const ASeatIndex: Integer; const ASeatWidth, ASeatHeight: Integer;
        const ASeatImage, ACacheImage: TBitmap32; const AAvatar: TBytes; const AUpperText: WideString; const AUpperTextColor: TColor32; const ALowerText: WideString;
        const ALowerTextColor: TColor32);

    destructor Destroy; override;

    property Rect: TRect read FRect;
    property TableResizeRatio: Double read FTableResizeRatio;
    property SeatIndex: Integer read FSeatIndex;
    property SeatWidth: Integer read FSeatWidth;
    property SeatHeight: Integer read FSeatHeight;
    property SeatImage: TBitmap32 read FSeatImage;
    property CacheImage: TBitmap32 read FCacheImage;
    property UpperText: WideString read FUpperText;
    property LowerText: WideString read FLowerText;
    property UpperTextColor: TColor32 read FUpperTextColor;
    property LowerTextColor: TColor32 read FLowerTextColor;
    property CardCount: Integer read FCardCount;
    property CardsStr: String read FCardsStr;
    property Avatar: TBytes read FAvatar;
  end;

  TDCLSeatData = class(TObjectList<TDCSeatData>)
    procedure StoreCachedData(const ASeatInfo: TSeatInfo; const ASourceBitmap: TBitmap32; const ASourceRect: TRect; const ATableResizeRatio: Double;
        const ASeatIndex, ASeatWidth, ASeatHeight: Integer; const ASeatImage: TBitmap32; const AAvatar: TBytes; const AUpperText: WideString;
        const AUpperTextColor: TColor32; const ALowerText: WideString; const ALowerTextColor: TColor32);

    function GetCachedData(const ASeatInfo: TSeatInfo; const ATableResizeRatio: Double; const ASeatIndex: Integer; const ASeatPoint: TPoint;
        const ASeatWidth, ASeatHeight: Integer; const ASeatImage: TBitmap32; const AAvatar: TBytes; const AUpperText: WideString;
        const AUpperTextColor: TColor32; const ALowerText: WideString; const ALowerTextColor: TColor32): TDCSeatData;

  end;

implementation

uses
  Winapi.Windows, GR32_Backends, uCommon;

{ TDCSeatData }

destructor TDCSeatData.Destroy;
begin
  FCacheImage.Free;

  inherited;
end;

procedure TDCSeatData.Assign(const ASeatInfo: TSeatInfo; const ARect: TRect; const ATableResizeRatio: Double; const ASeatIndex: Integer; const ASeatWidth, ASeatHeight: Integer;
      const ASeatImage, ACacheImage: TBitmap32; const AAvatar: TBytes; const AUpperText: WideString; const AUpperTextColor: TColor32; const ALowerText: WideString;
      const ALowerTextColor: TColor32);
begin
  FRect := ARect;
  FTableResizeRatio := ATableResizeRatio;
  FSeatIndex := ASeatIndex;
  FSeatWidth := ASeatWidth;
  FSeatHeight := ASeatHeight;
  FSeatImage := ASeatImage;
  if Assigned(FCacheImage) then
    FreeAndNil(FCacheImage);
  FCacheImage := ACacheImage;
  FUpperText := AUpperText;
  FLowerText := ALowerText;
  FUpperTextColor := AUpperTextColor;
  FLowerTextColor := ALowerTextColor;
  FCardCount := ASeatInfo.CardCount;
  FCardsStr := ASeatInfo.Cards.AsString;
  FAvatar := AAvatar;
end;


{ TDCLSeatData }

function TDCLSeatData.GetCachedData(const ASeatInfo: TSeatInfo; const ATableResizeRatio: Double; const ASeatIndex: Integer; const ASeatPoint: TPoint;
        const ASeatWidth, ASeatHeight: Integer; const ASeatImage: TBitmap32; const AAvatar: TBytes; const AUpperText: WideString;
        const AUpperTextColor: TColor32; const ALowerText: WideString; const ALowerTextColor: TColor32): TDCSeatData;
var
  seat: TDCSeatData;
begin
  for seat in ToArray do
    if (seat.SeatIndex = ASeatIndex) and
       (seat.TableResizeRatio = ATableResizeRatio) and
       (seat.SeatWidth = ASeatWidth) and
       (seat.SeatHeight = ASeatHeight) and
       (seat.SeatImage = ASeatImage) and
       (seat.UpperText = AUpperText) and
       (seat.UpperTextColor = AUpperTextColor) and
       (seat.LowerText = ALowerText) and
       (seat.LowerTextColor = ALowerTextColor) and
       (seat.CardCount = ASeatInfo.CardCount) and
       (seat.CardsStr = ASeatInfo.Cards.AsString) and
       (CompareBytes(seat.Avatar, AAvatar)) then
      Exit(seat);
  Exit(nil);
end;

procedure TDCLSeatData.StoreCachedData(const ASeatInfo: TSeatInfo; const ASourceBitmap: TBitmap32; const ASourceRect: TRect; const ATableResizeRatio: Double;
        const ASeatIndex, ASeatWidth, ASeatHeight: Integer; const ASeatImage: TBitmap32; const AAvatar: TBytes; const AUpperText: WideString;
        const AUpperTextColor: TColor32; const ALowerText: WideString; const ALowerTextColor: TColor32);
var
  seat : TDCSeatData;
  cache: TBitmap32;
begin
  cache := TBitmap32.Create;
  cache.SetSize(ASourceRect.Width, ASourceRect.Height);
  cache.Draw(cache.BoundsRect, ASourceRect, ASourceBitmap.Handle);

  for seat in ToArray do
    if seat.SeatIndex = ASeatIndex then
    begin
      seat.Assign(ASeatInfo, ASourceRect, ATableResizeRatio, ASeatIndex, ASeatWidth, ASeatHeight, ASeatImage, cache, AAvatar, AUpperText, AUpperTextColor, ALowerText, ALowerTextColor);
      Exit;
    end;

  seat := TDCSeatData.Create;
  seat.Assign(ASeatInfo, ASourceRect, ATableResizeRatio, ASeatIndex, ASeatWidth, ASeatHeight, ASeatImage, cache, AAvatar, AUpperText, AUpperTextColor, ALowerText, ALowerTextColor);

  Add(seat);
end;

end.
