object frmTable: TfrmTable
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Table'
  ClientHeight = 524
  ClientWidth = 792
  Color = clWindow
  Constraints.MaxHeight = 910
  Constraints.MaxWidth = 1320
  Constraints.MinWidth = 650
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
  PixelsPerInch = 96
  TextHeight = 14
  object paBottom: TPanel
    Left = 0
    Top = 428
    Width = 792
    Height = 96
    Align = alBottom
    BevelOuter = bvNone
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    ExplicitTop = 377
    ExplicitWidth = 721
    object paChat: TPanel
      Left = 0
      Top = 0
      Width = 250
      Height = 96
      Align = alLeft
      BevelOuter = bvNone
      Color = clBlack
      Padding.Left = 3
      Padding.Top = 4
      Padding.Right = 3
      Padding.Bottom = 4
      ParentBackground = False
      TabOrder = 0
      object edChat: TcxTextEdit
        Left = 3
        Top = 4
        Margins.Left = 1
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        AutoSize = False
        Style.BorderStyle = ebsNone
        Style.Edges = []
        Style.TransparentBorder = False
        TabOrder = 0
        OnKeyPress = edChatKeyPress
        Height = 16
        Width = 244
      end
      object reChat: TcxRichEdit
        Left = 3
        Top = 20
        Align = alClient
        Properties.AutoURLDetect = True
        Properties.ReadOnly = True
        Properties.ScrollBars = ssVertical
        Lines.Strings = (
          'reChat')
        Style.BorderStyle = ebsNone
        Style.Edges = []
        Style.Shadow = False
        Style.TransparentBorder = True
        StyleFocused.BorderStyle = ebsNone
        StyleHot.BorderStyle = ebsNone
        TabOrder = 1
        Height = 72
        Width = 244
      end
    end
    object paButtons: TPanel
      Left = 250
      Top = 0
      Width = 542
      Height = 96
      Align = alClient
      BevelOuter = bvNone
      Color = clBlack
      Padding.Top = 1
      Padding.Right = 1
      ParentBackground = False
      TabOrder = 1
      ExplicitWidth = 471
      DesignSize = (
        542
        96)
      object cbSitOutNextBB: TcxCheckBox
        Left = -2
        Top = 40
        AutoSize = False
        Caption = 'Sit out next BB'
        ParentFont = False
        Properties.OnChange = cbSitOutNextBBPropertiesChange
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = 14
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.HotTrack = False
        Style.IsFontAssigned = True
        TabOrder = 9
        Transparent = True
        Visible = False
        Height = 19
        Width = 128
      end
      object cbSitOutNextHand: TcxCheckBox
        Left = -2
        Top = 22
        AutoSize = False
        Caption = 'Sit out next hand'
        ParentFont = False
        Properties.OnChange = cbSitOutNextHandPropertiesChange
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = 14
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.HotTrack = False
        Style.IsFontAssigned = True
        TabOrder = 8
        Transparent = True
        Visible = False
        Height = 19
        Width = 128
      end
      object cbFoldToAnyBet: TcxCheckBox
        Left = -2
        Top = 4
        AutoSize = False
        Caption = 'Fold to any bet'
        ParentFont = False
        Properties.OnChange = cbSitOutNextHandPropertiesChange
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = 14
        Style.Font.Name = 'Arial'
        Style.Font.Style = []
        Style.HotTrack = False
        Style.IsFontAssigned = True
        TabOrder = 7
        Transparent = True
        Visible = False
        Height = 19
        Width = 128
      end
      object btAction2: TcxButton
        Left = 313
        Top = 55
        Width = 108
        Height = 37
        Anchors = [akRight, akBottom]
        Enabled = False
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 0
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = acCallExecute
        ExplicitLeft = 242
      end
      object btAction1: TcxButton
        Left = 196
        Top = 55
        Width = 108
        Height = 37
        Anchors = [akRight, akBottom]
        Enabled = False
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 1
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = acCheckExecute
        ExplicitLeft = 125
      end
      object btAction3: TcxButton
        Left = 430
        Top = 55
        Width = 108
        Height = 37
        Anchors = [akRight, akBottom]
        Enabled = False
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 2
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        OnClick = acRaiseExecute
        ExplicitLeft = 359
      end
      object btStandUp: TcxButton
        Left = 3
        Top = 69
        Width = 79
        Height = 23
        Action = acStandUp
        Anchors = [akLeft, akBottom]
        Colors.DefaultText = 1933784
        Colors.NormalText = 1933784
        Colors.HotText = 1933784
        Colors.PressedText = 1933784
        Colors.DisabledText = 1933784
        LookAndFeel.SkinName = 'ChipUpRedButton'
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 3
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 4227327
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object seRaiseAmount: TcxSpinEdit
        Left = 260
        Top = 27
        Anchors = [akTop, akRight]
        Properties.ImmediatePost = True
        Properties.SpinButtons.Visible = False
        Properties.ValueType = vtFloat
        Properties.OnChange = seRaiseAmountPropertiesChange
        TabOrder = 4
        Visible = False
        ExplicitLeft = 189
        Width = 46
      end
      object tbRaise: TcxTrackBar
        Left = 300
        Top = 28
        Anchors = [akTop, akRight]
        Properties.AutoSize = False
        Properties.ShowTicks = False
        Properties.OnChange = tbRaisePropertiesChange
        Style.Edges = []
        Style.TransparentBorder = True
        TabOrder = 5
        Transparent = True
        Visible = False
        ExplicitLeft = 229
        Height = 25
        Width = 245
      end
      object btPlayNow: TcxButton
        Left = 87
        Top = 13
        Width = 91
        Height = 32
        Action = acPlayNow
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 6
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object btRaiseMax: TcxButton
        Left = 486
        Top = 5
        Width = 52
        Height = 23
        Action = acRaiseMax
        Anchors = [akTop, akRight]
        LookAndFeel.SkinName = 'ChipUpDarkTabsStyle'
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 13
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitLeft = 415
      end
      object btRaisePot: TcxButton
        Left = 428
        Top = 5
        Width = 52
        Height = 23
        Action = acRaisePot
        Anchors = [akTop, akRight]
        LookAndFeel.SkinName = 'ChipUpDarkTabsStyle'
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 12
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitLeft = 357
      end
      object btRaise3BB: TcxButton
        Left = 370
        Top = 5
        Width = 52
        Height = 23
        Action = acRaise3BB
        Anchors = [akTop, akRight]
        LookAndFeel.SkinName = 'ChipUpDarkTabsStyle'
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 11
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitLeft = 299
      end
      object btRaiseMin: TcxButton
        Left = 312
        Top = 5
        Width = 52
        Height = 23
        Action = acRaiseMin
        Anchors = [akTop, akRight]
        LookAndFeel.SkinName = 'ChipUpDarkTabsStyle'
        SpeedButtonOptions.CanBeFocused = False
        TabOrder = 10
        Visible = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitLeft = 241
      end
    end
  end
  object ActionManager: TActionManager
    Left = 56
    Top = 104
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
    object acRaiseMin: TAction
      Category = 'Game'
      Caption = 'MIN'
      OnExecute = acRaiseMinExecute
    end
    object acRaise3BB: TAction
      Category = 'Game'
      Caption = '3BB'
      OnExecute = acRaise3BBExecute
    end
    object acRaisePot: TAction
      Category = 'Game'
      Caption = 'POT'
      OnExecute = acRaisePotExecute
    end
    object acRaiseMax: TAction
      Category = 'Game'
      Caption = 'MAX'
      OnExecute = acRaiseMaxExecute
    end
  end
  object tiActiveFrameBlink: TTimer
    Enabled = False
    Interval = 750
    OnTimer = tiActiveFrameBlinkTimer
    Left = 56
    Top = 32
  end
  object tiSitOutNextHand: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tiSitOutNextHandTimer
    Left = 144
    Top = 32
  end
  object tiSeatCaptionClear: TTimer
    Enabled = False
    Interval = 1800
    OnTimer = tiSeatClearCaptionTimer
    Left = 236
    Top = 32
  end
  object tiSitOutNextBB: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tiSitOutNextBBTimer
    Left = 144
    Top = 100
  end
end
