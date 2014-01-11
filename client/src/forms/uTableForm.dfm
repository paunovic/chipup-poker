object frmTable: TfrmTable
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Table'
  ClientHeight = 400
  ClientWidth = 600
  Color = clWindow
  Constraints.MaxHeight = 1080
  Constraints.MaxWidth = 1538
  Constraints.MinHeight = 427
  Constraints.MinWidth = 608
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 14
  object PaintBox: TPaintBox
    Left = 0
    Top = 0
    Width = 600
    Height = 400
    Align = alClient
    OnPaint = PaintBoxPaint
    ExplicitWidth = 570
    ExplicitHeight = 380
  end
end
