object frmTable: TfrmTable
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Table'
  ClientHeight = 548
  ClientWidth = 725
  Color = clBlack
  Constraints.MaxHeight = 1037
  Constraints.MaxWidth = 1320
  Constraints.MinHeight = 573
  Constraints.MinWidth = 730
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
    Top = 468
    Width = 725
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
      Width = 475
      Height = 80
      Align = alClient
      BevelOuter = bvNone
      Color = clBlack
      Padding.Top = 1
      Padding.Right = 1
      ParentBackground = False
      TabOrder = 1
      DesignSize = (
        475
        80)
      object btCall: TcxButton
        Left = 266
        Top = 41
        Width = 92
        Height = 28
        Action = acCall
        Anchors = [akRight, akBottom]
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
      object btCheckFold: TcxButton
        Left = 168
        Top = 41
        Width = 92
        Height = 28
        Action = acCheck
        Anchors = [akRight, akBottom]
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
        Left = 372
        Top = 41
        Width = 92
        Height = 28
        Action = acRaise
        Anchors = [akRight, akBottom]
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
        Left = 40
        Top = 41
        Width = 92
        Height = 28
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
        Left = 139
        Top = 6
        AutoSize = False
        Caption = 'lbsInfo'
        Transparent = True
        Height = 18
        Width = 174
      end
      object seRaiseAmount: TcxSpinEdit
        Left = 323
        Top = 13
        Anchors = [akRight, akBottom]
        Properties.ImmediatePost = True
        Properties.SpinButtons.Visible = False
        Properties.ValueType = vtFloat
        Properties.OnChange = seRaiseAmountPropertiesChange
        TabOrder = 5
        Visible = False
        Width = 46
      end
      object tbRaise: TcxTrackBar
        Left = 367
        Top = 14
        Anchors = [akRight, akBottom]
        Properties.AutoSize = False
        Properties.ShowTicks = False
        Properties.OnChange = tbRaisePropertiesChange
        Style.Edges = []
        Style.TransparentBorder = True
        TabOrder = 6
        Transparent = True
        Visible = False
        Height = 25
        Width = 100
      end
      object btPlayNow: TcxButton
        Left = 138
        Top = 41
        Width = 92
        Height = 28
        Action = acPlayNow
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 7
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object cbSitOutNextHand: TcxCheckBox
        Left = 7
        Top = 6
        Caption = 'Sit out next hand'
        Properties.OnChange = cbSitOutNextHandPropertiesChange
        TabOrder = 8
        Transparent = True
        Visible = False
        Width = 109
      end
      object lbsDebug: TcxLabel
        Left = 138
        Top = 22
        AutoSize = False
        Transparent = True
        Height = 18
        Width = 174
      end
    end
  end
  object PaintBox: TPaintBox32
    Left = 0
    Top = 0
    Width = 725
    Height = 468
    Align = alClient
    RepaintMode = rmOptimizer
    TabOrder = 1
    OnClick = PaintBoxClick
  end
  object pbTime: TcxProgressBar
    Left = 52
    Top = 82
    AutoSize = False
    Position = 100.000000000000000000
    Properties.BarStyle = cxbsGradientLEDs
    Properties.BeginColor = clRed
    Properties.EndColor = clLime
    Properties.PeakValue = 100.000000000000000000
    Properties.ShowText = False
    Properties.ShowTextStyle = cxtsText
    Style.BorderColor = clBlack
    Style.BorderStyle = ebsNone
    Style.Edges = []
    Style.LookAndFeel.SkinName = ''
    Style.TransparentBorder = True
    StyleDisabled.LookAndFeel.SkinName = ''
    StyleFocused.LookAndFeel.SkinName = ''
    StyleHot.LookAndFeel.SkinName = ''
    TabOrder = 2
    Transparent = True
    Visible = False
    Height = 7
    Width = 122
  end
  object ActionManager: TActionManager
    Left = 108
    Top = 32
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
    object acPlayNow: TAction
      Category = 'Game'
      Caption = 'PLAY NOW'
      Enabled = False
      OnExecute = acPlayNowExecute
    end
  end
  object tiActiveFrameBlink: TTimer
    Enabled = False
    Interval = 700
    OnTimer = tiActiveFrameBlinkTimer
    Left = 52
    Top = 32
  end
  object tiSitOutNextHand: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tiSitOutNextHandTimer
    Left = 164
    Top = 32
  end
  object tiSeatCaptionClear: TTimer
    Enabled = False
    Interval = 1800
    OnTimer = tiSeatClearCaptionTimer
    Left = 220
    Top = 32
  end
  object tiPlayTimer: TTimer
    Enabled = False
    Interval = 300
    OnTimer = tiPlayTimerTimer
    Left = 272
    Top = 32
  end
end
