object frmTable: TfrmTable
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Table'
  ClientHeight = 413
  ClientWidth = 552
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
    Top = 330
    Width = 552
    Height = 83
    Align = alBottom
    BevelOuter = bvNone
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    object paChat: TPanel
      Left = 0
      Top = 0
      Width = 264
      Height = 83
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
        Width = 263
      end
      object reChat: TRichEdit
        Left = 0
        Top = 19
        Width = 263
        Height = 64
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
      Left = 270
      Top = 40
      Width = 89
      Height = 29
      Action = acStandUp
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 1
      Visible = False
    end
    object btFold: TcxButton
      Left = 270
      Top = 6
      Width = 89
      Height = 29
      Action = acFold
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 2
      Visible = False
    end
    object btCallCheck: TcxButton
      Left = 364
      Top = 6
      Width = 89
      Height = 29
      Action = acCall
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 3
      Visible = False
    end
    object btRaise: TcxButton
      Left = 458
      Top = 6
      Width = 89
      Height = 29
      Action = acRaise
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 4
      Visible = False
    end
  end
  object PaintBox: TPaintBox32
    Left = 0
    Top = 0
    Width = 552
    Height = 330
    Align = alClient
    RepaintMode = rmOptimizer
    TabOrder = 1
    OnClick = PaintBoxClick
    ExplicitLeft = 312
    ExplicitTop = 100
    ExplicitWidth = 192
    ExplicitHeight = 192
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
