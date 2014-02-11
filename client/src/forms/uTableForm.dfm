object frmTable: TfrmTable
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Table'
  ClientHeight = 535
  ClientWidth = 707
  Color = clBlack
  Constraints.MaxHeight = 1037
  Constraints.MaxWidth = 1320
  Constraints.MinHeight = 440
  Constraints.MinWidth = 560
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 14
  object paBottom: TPanel
    Left = 0
    Top = 455
    Width = 707
    Height = 80
    Align = alBottom
    BevelOuter = bvNone
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    object paChat: TPanel
      Left = 0
      Top = 0
      Width = 250
      Height = 80
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
        Style.BorderStyle = ebsNone
        Style.Edges = []
        Style.TransparentBorder = False
        TabOrder = 0
        OnKeyPress = edChatKeyPress
        Width = 251
      end
      object reChat: TcxRichEdit
        Left = 0
        Top = 20
        Properties.AutoURLDetect = True
        Properties.ReadOnly = True
        Properties.ScrollBars = ssVertical
        Lines.Strings = (
          'reChat')
        Style.BorderStyle = ebsNone
        Style.Edges = []
        Style.Shadow = False
        Style.TransparentBorder = False
        StyleFocused.BorderStyle = ebsNone
        StyleHot.BorderStyle = ebsNone
        TabOrder = 1
        Height = 61
        Width = 251
      end
    end
    object paButtons: TPanel
      Left = 250
      Top = 0
      Width = 457
      Height = 80
      Align = alClient
      BevelOuter = bvNone
      Color = clBlack
      Padding.Top = 1
      Padding.Right = 1
      ParentBackground = False
      TabOrder = 1
      object btCallCheck: TcxButton
        Left = 13
        Top = 6
        Width = 85
        Height = 27
        Action = acCall
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 0
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object btFold: TcxButton
        Left = 195
        Top = 6
        Width = 85
        Height = 27
        Action = acFold
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 1
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object btRaise: TcxButton
        Left = 104
        Top = 6
        Width = 85
        Height = 27
        Action = acRaise
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 2
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object btStandUp: TcxButton
        Left = 13
        Top = 38
        Width = 85
        Height = 27
        Action = acStandUp
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 3
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object lbsInfo: TcxLabel
        Left = 236
        Top = 52
        Caption = 'lbsInfo'
      end
    end
  end
  object PaintBox: TPaintBox32
    Left = 0
    Top = 0
    Width = 707
    Height = 455
    Align = alClient
    RepaintMode = rmOptimizer
    TabOrder = 1
    OnClick = PaintBoxClick
  end
  object ActionManager: TActionManager
    Left = 212
    Top = 180
    StyleName = 'Platform Default'
    object acStandUp: TAction
      Category = 'Game'
      Caption = 'STAND UP'
      Enabled = False
      OnExecute = acStandUpExecute
    end
    object acFold: TAction
      Category = 'Game'
      Caption = 'FOLD'
      Enabled = False
      OnExecute = acFoldExecute
    end
    object acCall: TAction
      Category = 'Game'
      Caption = 'CALL'
      Enabled = False
      OnExecute = acCallExecute
    end
    object acCheck: TAction
      Category = 'Game'
      Caption = 'CHECK'
      Enabled = False
      OnExecute = acCheckExecute
    end
    object acRaise: TAction
      Category = 'Game'
      Caption = 'RAISE'
      Enabled = False
      OnExecute = acRaiseExecute
    end
  end
end
