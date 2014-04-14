unit ChipUpPokerDarkSkin;

interface

uses
  Classes, dxCore, dxGDIPlusApi, cxLookAndFeelPainters, dxSkinsCore, dxSkinsLookAndFeelPainter;

type

  { TdxSkinChipUpPokerDarkStylePainter }

  TdxSkinChipUpPokerDarkStylePainter = class(TdxSkinLookAndFeelPainter)
  public
    function LookAndFeelName: string; override;
  end;

  { TdxSkinChipUpPokerDarkStyle_LoginButtonPainter }

  TdxSkinChipUpPokerDarkStyle_LoginButtonPainter = class(TdxSkinLookAndFeelPainter)
  public
    function LookAndFeelName: string; override;
  end;

  { TdxSkinChipUpPokerDarkStyle_ClubLobbyTabsPainter }

  TdxSkinChipUpPokerDarkStyle_ClubLobbyTabsPainter = class(TdxSkinLookAndFeelPainter)
  public
    function LookAndFeelName: string; override;
  end;

  { TdxSkinChipUpPokerDarkStyle_MainFormButtonsPainter }

  TdxSkinChipUpPokerDarkStyle_MainFormButtonsPainter = class(TdxSkinLookAndFeelPainter)
  public
    function LookAndFeelName: string; override;
  end;

  { TdxSkinChipUpPokerDarkStyle_MainFormBigButtonsPainter }

  TdxSkinChipUpPokerDarkStyle_MainFormBigButtonsPainter = class(TdxSkinLookAndFeelPainter)
  public
    function LookAndFeelName: string; override;
  end;

  { TdxSkinChipUpPokerDarkStyle_MainFormStaticTabsPainter }

  TdxSkinChipUpPokerDarkStyle_MainFormStaticTabsPainter = class(TdxSkinLookAndFeelPainter)
  public
    function LookAndFeelName: string; override;
  end;

implementation

{$R ChipUpPokerDarkSkin.res}

const
  SkinsCount = 6;
  SkinNames: array[0..SkinsCount - 1] of string = (
    'ChipUpPokerDarkStyle',
    'ChipUpPokerDarkStyle_LoginButton',
    'ChipUpPokerDarkStyle_ClubLobbyTabs',
    'ChipUpPokerDarkStyle_MainFormButtons',
    'ChipUpPokerDarkStyle_MainFormBigButtons',
    'ChipUpPokerDarkStyle_MainFormStaticTabs'
  );
  SkinPainters: array[0..SkinsCount - 1] of TdxSkinLookAndFeelPainterClass = (
    TdxSkinChipUpPokerDarkStylePainter,
    TdxSkinChipUpPokerDarkStyle_LoginButtonPainter,
    TdxSkinChipUpPokerDarkStyle_ClubLobbyTabsPainter,
    TdxSkinChipUpPokerDarkStyle_MainFormButtonsPainter,
    TdxSkinChipUpPokerDarkStyle_MainFormBigButtonsPainter,
    TdxSkinChipUpPokerDarkStyle_MainFormStaticTabsPainter
  );


{ TdxSkinChipUpPokerDarkStylePainter }

function TdxSkinChipUpPokerDarkStylePainter.LookAndFeelName: string;
begin
  Result := 'ChipUpPokerDarkStyle';
end;

{ TdxSkinChipUpPokerDarkStyle_LoginButtonPainter }

function TdxSkinChipUpPokerDarkStyle_LoginButtonPainter.LookAndFeelName: string;
begin
  Result := 'ChipUpPokerDarkStyle_LoginButton';
end;

{ TdxSkinChipUpPokerDarkStyle_ClubLobbyTabsPainter }

function TdxSkinChipUpPokerDarkStyle_ClubLobbyTabsPainter.LookAndFeelName: string;
begin
  Result := 'ChipUpPokerDarkStyle_ClubLobbyTabs';
end;

{ TdxSkinChipUpPokerDarkStyle_MainFormButtonsPainter }

function TdxSkinChipUpPokerDarkStyle_MainFormButtonsPainter.LookAndFeelName: string;
begin
  Result := 'ChipUpPokerDarkStyle_MainFormButtons';
end;

{ TdxSkinChipUpPokerDarkStyle_MainFormBigButtonsPainter }

function TdxSkinChipUpPokerDarkStyle_MainFormBigButtonsPainter.LookAndFeelName: string;
begin
  Result := 'ChipUpPokerDarkStyle_MainFormBigButtons';
end;

{ TdxSkinChipUpPokerDarkStyle_MainFormStaticTabsPainter }

function TdxSkinChipUpPokerDarkStyle_MainFormStaticTabsPainter.LookAndFeelName: string;
begin
  Result := 'ChipUpPokerDarkStyle_MainFormStaticTabs';
end;

//

procedure RegisterPainters;
var
  I: Integer;
begin
  if CheckGdiPlus then
  begin
    for I := 0 to SkinsCount - 1 do
      cxLookAndFeelPaintersManager.Register(SkinPainters[I].Create(SkinNames[I], HInstance));
  end;
end;

procedure UnregisterPainters;
var
  I: Integer;
begin
  if cxLookAndFeelPaintersManager <> nil then
  begin
    for I := 0 to SkinsCount - 1 do
      cxLookAndFeelPaintersManager.Unregister(SkinNames[I]);
  end;
end;

{$IFNDEF DXSKINDYNAMICLOADING}
initialization
  dxUnitsLoader.AddUnit(@RegisterPainters, @UnregisterPainters);
finalization
  dxUnitsLoader.RemoveUnit(@UnregisterPainters);
{$ENDIF}
end.
