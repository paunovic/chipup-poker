object frmAbout: TfrmAbout
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsNone
  Caption = 'ChipUP Poker'
  ClientHeight = 281
  ClientWidth = 345
  Color = clFuchsia
  TransparentColor = True
  TransparentColorValue = clFuchsia
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnHide = FormHide
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbsClientVersion: TcxLabel
    Left = 142
    Top = 173
    Caption = 'Client Version:'
    ParentColor = False
    Style.Color = clBlack
    Style.TextStyle = []
  end
  object lbvClientVersion: TcxLabel
    Left = 216
    Top = 173
    Caption = '0.0'
    ParentColor = False
    Style.Color = clBlack
    Style.TextStyle = []
  end
  object lbsCopyright: TcxLabel
    Left = 142
    Top = 122
    Caption = 'Copyright '#169' 2014 ChipUP Poker'
    ParentColor = False
    Style.Color = clBlack
    Style.TextStyle = [fsBold]
  end
  object lbsURL: TcxLabel
    Left = 142
    Top = 138
    Cursor = crHandPoint
    Caption = 'www.chipuppoker.com'
    ParentColor = False
    Style.Color = clBlack
    Style.TextColor = 16764234
    Style.TextStyle = [fsBold]
    OnClick = lbsURLClick
  end
end
