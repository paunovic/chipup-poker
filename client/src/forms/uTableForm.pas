unit uTableForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, SynGdiPlus;

type
  TfrmTable = class(TForm)
    PaintBox: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PaintBoxPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FFormAspectRatio : Double;
    FSenderObject    : TObject;
    FId              : DWORD;

    FPaintBoxBitmap  : TBitmap;

    FMF_Table        : TMetaFile;
    FImg_Background  : TPngImage;
    FMFP_Table       : Double;

    function CreateMetafile(const AResourceName: String; var AProportions: Double): TMetaFile;
    procedure ResizeControls;

  protected
    procedure CreateParams(var AParams: TCreateParams); override;
    procedure WMSizing(var AMessage: TMessage); message WM_SIZING;
  public
    constructor Create(const ASender: TObject; const AId: DWORD); reintroduce;
  end;

implementation

{$R *.dfm}

uses
  uTable;

constructor TfrmTable.Create(const ASender: TObject; const AId: DWORD);
begin
  inherited Create(nil);

  if not Assigned(Gdip) then
    Gdip := TGDIPlusFull.Create('gdiplus.dll');

  FId := AId;
  FSenderObject := ASender;
end;

procedure TfrmTable.FormCreate(Sender: TObject);
begin
  FFormAspectRatio := Width / Height;

  FPaintBoxBitmap := TBitmap.Create;

  FMF_Table := CreateMetafile('GameTable', FMFP_Table);
  FImg_Background := TPngImage.Create;
  FImg_Background.LoadFromResourceName(HInstance, 'GameCarpet');

  Caption := Format('Table #%d', [FId]);

  ResizeControls;
end;

procedure TfrmTable.FormDestroy(Sender: TObject);
begin
  FMF_Table.Free;
  FImg_Background.Free;
  FPaintBoxBitmap.Free;
end;

procedure TfrmTable.CreateParams(var AParams: TCreateParams);
begin
  inherited;

  AParams.WndParent := 0;
end;

procedure TfrmTable.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  (FSenderObject as TTable).NotifyClose;
end;

procedure TfrmTable.FormResize(Sender: TObject);
begin
  if Width / Height <> FFormAspectRatio then
    Height := Round(Width / FFormAspectRatio);

  ResizeControls;
end;

procedure TfrmTable.PaintBoxPaint(Sender: TObject);
begin
  PaintBox.Canvas.Draw(0, 0, FPaintBoxBitmap);
end;

procedure TfrmTable.WMSizing(var AMessage: TMessage);
begin
  inherited;

  case AMessage.wParam of
    WMSZ_LEFT, WMSZ_RIGHT, WMSZ_BOTTOMLEFT: with PRect(AMessage.LParam)^ do Bottom := Top + Round((Right - Left) / FFormAspectRatio);
    WMSZ_TOP, WMSZ_BOTTOM, WMSZ_TOPRIGHT, WMSZ_BOTTOMRIGHT: with PRect(AMessage.LParam)^ do Right := Left + Round((Bottom - Top) * FFormAspectRatio);
    WMSZ_TOPLEFT: with PRect(AMessage.LParam)^ do Top := Bottom - Round((Right - Left) / FFormAspectRatio);
  end;
end;

function TfrmTable.CreateMetafile(const AResourceName: String; var AProportions: Double): TMetaFile;
var
  rstream: TResourceStream;
begin
  result := TMetafile.Create;

  rstream := TResourceStream.Create(HInstance, AResourceName, RT_RCDATA);
  try
    result.LoadFromStream(rstream);
  finally
    rstream.Free;
  end;

  AProportions := result.Width / result.Height;
end;

procedure TfrmTable.ResizeControls;
var
  w, h: Integer;
  R   : TRect;
  X, Y: Integer;
begin
  R := TRect.Create(0, 0, PaintBox.Width, PaintBox.Height);

  FPaintBoxBitmap.SetSize(R.Width, R.Height);

  // tile background
  Y := 0;
  while Y < FPaintBoxBitmap.Height do
  begin
    X := 0;
    while X < FPaintBoxBitmap.Width do
    begin
      FPaintBoxBitmap.Canvas.Draw(X, Y, FImg_Background);
      Inc(X, FImg_Background.Width);
    end;
    Inc(Y, FImg_Background.Height);
  end;

  // calculate table size and draw it
  w := Round(0.75 * ClientWidth); // 75% of form width
  h := Round(w / FMFP_Table);
  FMF_Table.SetSize(w, h);
  Gdip.DrawAntiAliased(FMF_Table, FPaintBoxBitmap.Canvas.Handle, TRect.Create(Point((FPaintBoxBitmap.Width - FMF_Table.Width) div 2, 50), w, h));
end;

end.


