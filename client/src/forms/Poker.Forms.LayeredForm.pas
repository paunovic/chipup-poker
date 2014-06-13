unit Poker.Forms.LayeredForm;

interface

uses
  Winapi.Windows, System.Classes, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Imaging.PngImage;

type
  TfrmLayered = class(TForm)
    procedure FormActivate(Sender: TObject);
  private
    FParentForm: TForm;
    procedure SetAlphaBackground(const AResourceName: String);
  public
    constructor Create(AOwner: TComponent; const ABitmapResourceName: String); reintroduce;
    procedure UpdatePosition;
  end;

var
  frmLayered: TfrmLayered;

implementation

{$R *.dfm}


constructor TfrmLayered.Create(AOwner: TComponent; const ABitmapResourceName: String);
begin
  inherited Create(AOwner);

  FParentForm := AOwner as TForm;
  SetAlphaBackground(ABitmapResourceName);
end;

procedure TfrmLayered.FormActivate(Sender: TObject);
begin
  if (Active) and (FParentForm.Visible) and (Assigned(FParentForm)) then
    FParentForm.SetFocus;
end;

procedure TfrmLayered.UpdatePosition;
begin
  if Assigned(FParentForm) then
  begin
    Left := Round(FParentForm.Left - (ClientWidth - FParentForm.ClientWidth) / 2);
    Top := Round(FParentForm.Top - (ClientHeight - FParentForm.ClientHeight) / 2);
  end;
end;

procedure TfrmLayered.SetAlphaBackground(const AResourceName: String);
var
  blend_func: TBlendFunction;
  imgpos: TPoint;
  imgsize: TSize;
  exStyle: DWORD;
  png: TPngImage;
  bmp: TBitmap;
begin
  // enable window layering
  exStyle := GetWindowLongA(Handle, GWL_EXSTYLE);
  if (exStyle and WS_EX_LAYERED) = 0 then
    SetWindowLong(Handle, GWL_EXSTYLE, exStyle or WS_EX_LAYERED);

  png := TPngImage.Create;
  try
    png.LoadFromResourceName(HInstance, AResourceName);

    bmp := TBitmap.Create;
    try
      bmp.Assign(png);

      // resize the form
      ClientWidth := bmp.Width;
      ClientHeight := bmp.Height;

      // position image on form
      imgpos := Point(0, 0);
      imgsize.cx := bmp.Width;
      imgsize.cy := bmp.Height;

      // setup alpha blending parameters
      blend_func.BlendOp := AC_SRC_OVER;
      blend_func.BlendFlags := 0;
      blend_func.SourceConstantAlpha := 255;
      blend_func.AlphaFormat := AC_SRC_ALPHA;

      UpdateLayeredWindow(Handle, 0, nil, @imgsize, bmp.Canvas.Handle, @imgpos, 0, @blend_func, ULW_ALPHA);
    finally
      bmp.Free;
    end;
  finally
    png.Free;
  end;
end;

end.
