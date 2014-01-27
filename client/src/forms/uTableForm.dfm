object frmTable: TfrmTable
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Table'
  ClientHeight = 456
  ClientWidth = 600
  Color = clBlack
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 14
  object PaintBox: TPaintBox
    Left = 0
    Top = 0
    Width = 600
    Height = 345
    Align = alClient
    OnClick = PaintBoxClick
    OnPaint = PaintBoxPaint
    ExplicitWidth = 570
    ExplicitHeight = 380
  end
  object paBottom: TPanel
    Left = 0
    Top = 345
    Width = 600
    Height = 111
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object paChat: TPanel
      Left = 0
      Top = 0
      Width = 290
      Height = 111
      Align = alLeft
      BevelOuter = bvNone
      Color = clBlack
      Padding.Top = 1
      Padding.Right = 1
      ParentBackground = False
      TabOrder = 0
      object edChat: TcxTextEdit
        Left = 0
        Top = 1
        Align = alTop
        Style.Edges = []
        TabOrder = 0
        OnKeyPress = edChatKeyPress
        Width = 289
      end
      object reChat: TRichEdit
        Left = 0
        Top = 19
        Width = 289
        Height = 92
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        Color = 3552822
        Font.Charset = ANSI_CHARSET
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        Lines.Strings = (
          '')
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
    object btStandUp: TcxButton
      Left = 296
      Top = 38
      Width = 97
      Height = 34
      Action = acStandUp
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 1
      Visible = False
    end
    object lbsInfo: TcxLabel
      Left = 296
      Top = 6
      Caption = 'lbsInfo'
      Transparent = True
    end
    object btFold: TcxButton
      Left = 399
      Top = 38
      Width = 97
      Height = 34
      Action = acFold
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 3
      Visible = False
    end
  end
  object ActionManager: TActionManager
    Left = 208
    Top = 180
    StyleName = 'Platform Default'
    object acStandUp: TAction
      Category = 'Game'
      Caption = 'Stand Up'
      Enabled = False
      OnExecute = acStandUpExecute
    end
    object acFold: TAction
      Category = 'Game'
      Caption = 'Fold'
      Enabled = False
    end
  end
end
