object frmTable: TfrmTable
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Table'
  ClientHeight = 523
  ClientWidth = 792
  Color = clBtnFace
  Constraints.MaxHeight = 907
  Constraints.MaxWidth = 1320
  Constraints.MinWidth = 600
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  OnClick = FormClick
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnPaint = FormPaint
  OnResize = FormResize
  DesignSize = (
    792
    523)
  PixelsPerInch = 96
  TextHeight = 14
  object edChat: TcxTextEdit
    Left = 1
    Top = 427
    Margins.Left = 1
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Anchors = [akLeft, akBottom]
    AutoSize = False
    Style.BorderStyle = ebsNone
    Style.Edges = []
    Style.TransparentBorder = False
    TabOrder = 0
    OnKeyPress = edChatKeyPress
    ExplicitTop = 429
    Height = 16
    Width = 244
  end
  object reChat: TcxRichEdit
    Left = 1
    Top = 443
    Anchors = [akLeft, akBottom]
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
    ExplicitTop = 445
    Height = 72
    Width = 244
  end
  object cbFoldToAnyBet: TcxCheckBox
    Left = 251
    Top = 434
    Anchors = [akLeft, akBottom]
    AutoSize = False
    Caption = 'Fold to any bet'
    ParentFont = False
    Properties.OnChange = cbFoldToAnyBetPropertiesChange
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = 14
    Style.Font.Name = 'Arial'
    Style.Font.Style = []
    Style.HotTrack = False
    Style.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    Style.IsFontAssigned = True
    StyleDisabled.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    StyleFocused.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    StyleHot.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    TabOrder = 2
    Transparent = True
    Visible = False
    ExplicitTop = 436
    Height = 18
    Width = 113
  end
  object cbSitOutNextHand: TcxCheckBox
    Left = 251
    Top = 452
    Anchors = [akLeft, akBottom]
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
    Style.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    Style.IsFontAssigned = True
    StyleDisabled.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    StyleFocused.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    StyleHot.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    TabOrder = 3
    Transparent = True
    Visible = False
    ExplicitTop = 454
    Height = 12
    Width = 113
  end
  object btStandUp: TcxButton
    Left = 251
    Top = 492
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
    TabOrder = 4
    Visible = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 4227327
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitTop = 494
  end
  object cbSitOutNextBB: TcxCheckBox
    Left = 251
    Top = 467
    Anchors = [akLeft, akBottom]
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
    Style.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    Style.IsFontAssigned = True
    StyleDisabled.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    StyleFocused.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    StyleHot.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    TabOrder = 5
    Transparent = True
    Visible = False
    ExplicitTop = 469
    Height = 12
    Width = 113
  end
  object btPlayNow: TcxButton
    Left = 332
    Top = 148
    Width = 110
    Height = 36
    Action = acPlayNow
    Anchors = [akLeft, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 6
    Visible = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitTop = 150
  end
  object seRaiseAmount: TcxSpinEdit
    Left = 474
    Top = 286
    Anchors = []
    AutoSize = False
    ParentFont = False
    Properties.Alignment.Horz = taCenter
    Properties.Alignment.Vert = taVCenter
    Properties.ImmediatePost = True
    Properties.SpinButtons.Visible = False
    Properties.UseDisplayFormatWhenEditing = True
    Properties.ValueType = vtFloat
    Properties.OnChange = seRaiseAmountPropertiesChange
    Style.BorderStyle = ebsNone
    Style.Color = clBlack
    Style.Edges = []
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.Font.Quality = fqAntialiased
    Style.TextColor = clRed
    Style.IsFontAssigned = True
    TabOrder = 7
    Visible = False
    Height = 20
    Width = 46
  end
  object btAction1: TcxButton
    Left = 412
    Top = 199
    Width = 108
    Height = 37
    Anchors = []
    Enabled = False
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 8
    Visible = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = acCheckExecute
    ExplicitTop = 200
  end
  object btAction2: TcxButton
    Left = 529
    Top = 199
    Width = 108
    Height = 37
    Anchors = []
    Enabled = False
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 9
    Visible = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = acCallExecute
    ExplicitTop = 200
  end
  object tbRaise: TcxTrackBar
    Left = 516
    Top = 170
    Anchors = []
    Properties.AutoSize = False
    Properties.ShowTicks = False
    Properties.OnChange = tbRaisePropertiesChange
    Style.Edges = []
    Style.TransparentBorder = True
    TabOrder = 10
    Transparent = True
    Visible = False
    ExplicitTop = 171
    Height = 25
    Width = 245
  end
  object btAction3: TcxButton
    Left = 646
    Top = 199
    Width = 108
    Height = 37
    Anchors = []
    Enabled = False
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 11
    Visible = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    OnClick = acRaiseExecute
    ExplicitTop = 200
  end
  object btRaiseMin: TcxButton
    Left = 528
    Top = 148
    Width = 52
    Height = 23
    Action = acRaiseMin
    Anchors = []
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
    ExplicitTop = 149
  end
  object btRaise3BB: TcxButton
    Left = 586
    Top = 148
    Width = 52
    Height = 23
    Action = acRaise3BB
    Anchors = []
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
    ExplicitTop = 149
  end
  object btRaisePot: TcxButton
    Left = 644
    Top = 148
    Width = 52
    Height = 23
    Action = acRaisePot
    Anchors = []
    LookAndFeel.SkinName = 'ChipUpDarkTabsStyle'
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 14
    Visible = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitTop = 149
  end
  object btRaiseMax: TcxButton
    Left = 702
    Top = 148
    Width = 52
    Height = 23
    Action = acRaiseMax
    Anchors = []
    LookAndFeel.SkinName = 'ChipUpDarkTabsStyle'
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 15
    Visible = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitTop = 149
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
    object acShowLosingCards: TAction
      Category = 'Game'
      Caption = 'SHOW CARDS'
      OnExecute = acShowLosingCardsExecute
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
