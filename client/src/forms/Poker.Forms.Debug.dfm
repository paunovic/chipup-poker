object frmDebug: TfrmDebug
  Left = 0
  Top = 0
  ClientHeight = 380
  ClientWidth = 621
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  ScreenSnap = True
  SnapBuffer = 20
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 14
  object rvMemoryState: TRichView
    Left = 0
    Top = 18
    Width = 621
    Height = 255
    Align = alClient
    TabOrder = 4
    Visible = False
    BorderStyle = bsNone
    DoInPaletteMode = rvpaCreateCopies
    Style = RVStyles
  end
  object meSeatPos: TcxMemo
    Left = 0
    Top = 18
    Align = alClient
    Lines.Strings = (
      '(0, pi, 0, 0, 0, 0, 0, 0, 0, 0), // 2'
      '(0, pi/2, pi, 0, 0, 0, 0, 0, 0, 0), // 3'
      '(-pi/4, pi/4, pi*3/4, pi*5/4, 0, 0, 0, 0, 0, 0), // 4'
      '(-pi/5.5, pi/7, pi/2, pi-pi/7, pi+pi/5.5, 0, 0, 0, 0, 0), // 5'
      
        '(-pi/3.5, pi/48, pi/2.7, pi-pi/2.7, pi+pi/48, pi+pi/3.5, 0, 0, 0' +
        ', 0), // 6'
      '(-pi/4, 0, pi/4, pi/2, pi*3/4, pi, pi*5/4, 0, 0, 0), // 7'
      
        '(-pi/3.25, -pi/13, pi/6.5, pi/2.3, pi-pi/2.3, pi-pi/6.5, pi+pi/1' +
        '3, pi+pi/3.25, 0, 0), // 8'
      
        '(-pi/2.65, -pi/9, pi/24, pi/3, pi/2, pi-pi/3, pi-pi/24, pi+pi/9,' +
        ' pi+pi/2.65, 0), // 9'
      
        '(-pi/2.65, -pi/6, pi/80, pi/5, pi/2.25, pi-pi/2.25, pi-pi/5, pi-' +
        'pi/80, pi+pi/6, pi+pi/2.65) // 10')
    ParentFont = False
    Properties.WordWrap = False
    Properties.OnChange = meSeatPosPropertiesChange
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -12
    Style.Font.Name = 'Consolas'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 0
    Visible = False
    Height = 255
    Width = 621
  end
  object rvLog: TRichView
    Left = 0
    Top = 18
    Width = 621
    Height = 255
    Align = alClient
    PopupMenu = pmLog
    TabOrder = 1
    BorderStyle = bsNone
    DoInPaletteMode = rvpaCreateCopies
    Options = [rvoAllowSelection, rvoScrollToEnd, rvoShowPageBreaks, rvoAutoCopyUnicodeText, rvoAutoCopyRVF, rvoAutoCopyImage, rvoAutoCopyRTF, rvoFormatInvalidate, rvoDblClickSelectsWord, rvoFastFormatting]
    Style = RVStyles
    OnRVMouseUp = rvLogRVMouseUp
  end
  object paInfo: TPanel
    Left = 0
    Top = 292
    Width = 621
    Height = 88
    Align = alBottom
    BevelOuter = bvNone
    Ctl3D = False
    DoubleBuffered = True
    ParentBackground = False
    ParentCtl3D = False
    ParentDoubleBuffered = False
    TabOrder = 2
    DesignSize = (
      621
      88)
    object dxBevel1: TdxBevel
      AlignWithMargins = True
      Left = 124
      Top = 6
      Width = 3
      Height = 77
      Margins.Left = 1
      Margins.Top = 6
      Margins.Right = 1
      Margins.Bottom = 5
      Align = alLeft
      LookAndFeel.SkinName = 'FantasyDarkStyle'
      Shape = dxbsLineCenteredHorz
      ExplicitLeft = 140
      ExplicitTop = 9
      ExplicitHeight = 94
    end
    object dxBevel2: TdxBevel
      AlignWithMargins = True
      Left = 224
      Top = 6
      Width = 3
      Height = 77
      Margins.Left = 1
      Margins.Top = 6
      Margins.Right = 1
      Margins.Bottom = 5
      Align = alLeft
      LookAndFeel.SkinName = 'FantasyDarkStyle'
      Shape = dxbsLineCenteredHorz
      ExplicitLeft = 274
      ExplicitTop = 9
    end
    object btSeatPos: TcxButton
      Left = 584
      Top = 54
      Width = 31
      Height = 29
      Hint = 'Seat positions'
      Anchors = [akTop, akRight]
      Colors.PressedText = clRed
      OptionsImage.Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000686868807979799400000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000929292B3B0B0B0D800000000000000000000000000000000000000000000
        00000000000000000000141414191A1A1A201818181E13131317111111151111
        1115929292B3A6A6A6CC00000000000000000000000000000000000000000000
        000000000000000000006F6F6F88929292B38D8D8DADB2B2B2DAC3C3C3EFC3C3
        C3EFCCCCCCFAA1A1A1C500000000000000000000000000000000000000000000
        0000000000000000000000000000000000002A2A2A34C7C7C7F4D0D0D0FFD0D0
        D0FFD0D0D0FF8A8A8AA900000000000000000000000000000000000000000000
        0000000000000000000000000000000000004F4F4F61D0D0D0FF6868687F3A3A
        3A473A3A3A470D0D0D1000000000000000000000000000000000000000000000
        0000000000000000000000000000000000004A4A4A5BD0D0D0FF393939460000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000004A4A4A5BD0D0D0FF4040404E0000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000004E4E4E60D0D0D0FF3F3F3F4D0000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000037373744BCBCBCE63333333E0000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000001919191F5F5F5F742323232B0000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000001616161BB5B5B5DED0D0D0FFBCBCBCE61D1D
        1D24000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000003030303BD0D0D0FFD0D0D0FFD0D0D0FF3A3A
        3A47000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000070707097C7C7C98B7B7B7E0868686A40909
        090B000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000}
      ParentShowHint = False
      ShowHint = True
      SpeedButtonOptions.GroupIndex = 1
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.AllowAllUp = True
      SpeedButtonOptions.Transparent = True
      TabOrder = 0
      Visible = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btSeatPosClick
    end
    object paInfoPanel1: TPanel
      Left = 0
      Top = 0
      Width = 123
      Height = 88
      Align = alLeft
      BevelEdges = []
      BevelOuter = bvNone
      TabOrder = 1
      object lbvServer: TcxLabel
        Left = 34
        Top = 4
        AutoSize = False
        Caption = 'Unknown'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = []
        Style.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Style.TextColor = clWhite
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleFocused.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleHot.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Transparent = True
        Height = 17
        Width = 90
      end
      object lbsServer: TcxLabel
        Left = 5
        Top = 4
        Hint = 'Server'
        Caption = 'SRV:'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = [fsBold]
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lbsSocketState: TcxLabel
        Left = 5
        Top = 20
        Hint = 'Socket state'
        Caption = 'SCK:'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = [fsBold]
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lbvSocketState: TcxLabel
        Left = 34
        Top = 20
        AutoSize = False
        Caption = 'Unknown'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = []
        Style.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Style.TextColor = clWhite
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleFocused.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleHot.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Transparent = True
        Height = 17
        Width = 90
      end
      object lbsLatency: TcxLabel
        Left = 5
        Top = 36
        Hint = 'Latency'
        Caption = 'LAT:'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = [fsBold]
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lbvLatency: TcxLabel
        Left = 34
        Top = 36
        AutoSize = False
        Caption = 'Unknown'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = []
        Style.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Style.TextColor = clWhite
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleFocused.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleHot.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Transparent = True
        Height = 17
        Width = 90
      end
      object lbsDataRecv: TcxLabel
        Left = 5
        Top = 52
        Hint = 'Data received'
        Caption = 'RCV:'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = [fsBold]
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lbvDataRecv: TcxLabel
        Left = 34
        Top = 52
        AutoSize = False
        Caption = 'Unknown'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = []
        Style.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Style.TextColor = clWhite
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleFocused.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleHot.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Transparent = True
        Height = 17
        Width = 90
      end
      object lbvDataSent: TcxLabel
        Left = 34
        Top = 68
        AutoSize = False
        Caption = 'Unknown'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = []
        Style.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Style.TextColor = clWhite
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleFocused.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleHot.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Transparent = True
        Height = 17
        Width = 90
      end
      object lbsDataSent: TcxLabel
        Left = 5
        Top = 68
        Hint = 'Data sent'
        Caption = 'SNT:'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = [fsBold]
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
    end
    object paInfoPanel3: TPanel
      Left = 128
      Top = 0
      Width = 95
      Height = 88
      Align = alLeft
      BevelEdges = []
      BevelOuter = bvNone
      TabOrder = 2
      object lbsThreads: TcxLabel
        Left = 5
        Top = 4
        Hint = 'Threads'
        Caption = 'THD:'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = [fsBold]
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lbvThreads: TcxLabel
        Left = 34
        Top = 4
        AutoSize = False
        Caption = 'Unknown'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = []
        Style.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Style.TextColor = clWhite
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleFocused.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleHot.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Transparent = True
        Height = 17
        Width = 90
      end
      object lbsCPU: TcxLabel
        Left = 5
        Top = 20
        Hint = 'CPU'
        Caption = 'CPU:'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = [fsBold]
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lbvCPU: TcxLabel
        Left = 34
        Top = 20
        AutoSize = False
        Caption = 'Unknown'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = []
        Style.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Style.TextColor = clWhite
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleFocused.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleHot.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Transparent = True
        Height = 17
        Width = 90
      end
      object lbvMemoryUsage: TcxLabel
        Left = 34
        Top = 36
        AutoSize = False
        Caption = 'Unknown'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = []
        Style.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Style.TextColor = clWhite
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleFocused.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleHot.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Transparent = True
        Height = 17
        Width = 90
      end
      object lbsMemoryUsage: TcxLabel
        Left = 5
        Top = 36
        Hint = 'Memory'
        Caption = 'MEM:'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = [fsBold]
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
    end
    object paInfoPanel2: TPanel
      Left = 228
      Top = 0
      Width = 95
      Height = 88
      Align = alLeft
      BevelEdges = []
      BevelOuter = bvNone
      TabOrder = 3
      object lbsCallbacks: TcxLabel
        Left = 5
        Top = 4
        Hint = 'Callbacks'
        Caption = 'CBC:'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = [fsBold]
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lbvCallbacks: TcxLabel
        Left = 34
        Top = 4
        AutoSize = False
        Caption = 'Unknown'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = []
        Style.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Style.TextColor = clWhite
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleFocused.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleHot.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Transparent = True
        Height = 17
        Width = 90
      end
      object lbsSwapChain: TcxLabel
        Left = 5
        Top = 20
        Hint = 'Swap chain elements'
        Caption = 'SWC:'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = [fsBold]
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lbvSwapChain: TcxLabel
        Left = 34
        Top = 20
        AutoSize = False
        Caption = 'Unknown'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = []
        Style.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Style.TextColor = clWhite
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleFocused.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleHot.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Transparent = True
        Height = 17
        Width = 90
      end
      object lbsAnimations: TcxLabel
        Left = 5
        Top = 36
        Hint = 'Animations'
        Caption = 'ANI:'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = [fsBold]
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lbsSounds: TcxLabel
        Left = 5
        Top = 52
        Hint = 'Sounds'
        Caption = 'SND:'
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = [fsBold]
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        Transparent = True
      end
      object lbvSounds: TcxLabel
        Left = 34
        Top = 52
        AutoSize = False
        Caption = 'Unknown'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = []
        Style.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Style.TextColor = clWhite
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleFocused.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleHot.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Transparent = True
        Height = 17
        Width = 90
      end
      object lbvAnimations: TcxLabel
        Left = 34
        Top = 36
        AutoSize = False
        Caption = 'Unknown'
        ParentFont = False
        Style.Font.Charset = DEFAULT_CHARSET
        Style.Font.Color = clWindowText
        Style.Font.Height = -11
        Style.Font.Name = 'Consolas'
        Style.Font.Style = []
        Style.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Style.TextColor = clWhite
        Style.TextStyle = [fsBold]
        Style.IsFontAssigned = True
        StyleDisabled.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleFocused.LookAndFeel.SkinName = 'FantasyDarkStyle'
        StyleHot.LookAndFeel.SkinName = 'FantasyDarkStyle'
        Transparent = True
        Height = 17
        Width = 90
      end
    end
    object btShowSocketIO: TcxButton
      Left = 544
      Top = 6
      Width = 71
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Socket I/O'
      Colors.PressedText = 65408
      ParentShowHint = False
      ShowHint = False
      SpeedButtonOptions.GroupIndex = 2
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.AllowAllUp = True
      SpeedButtonOptions.Transparent = True
      TabOrder = 4
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btShowSocketIOClick
    end
  end
  object paTop: TPanel
    Left = 0
    Top = 0
    Width = 621
    Height = 18
    Align = alTop
    BevelEdges = [beLeft, beTop, beRight]
    BevelOuter = bvNone
    TabOrder = 3
    object teRegexFilter: TcxTextEdit
      Left = 313
      Top = 0
      Align = alRight
      AutoSize = False
      ParentFont = False
      Properties.OnChange = teRegexFilterPropertiesChange
      Style.BorderStyle = ebsUltraFlat
      Style.Edges = [bLeft, bBottom]
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 0
      Text = 'RegEx filtering...'
      OnEnter = teFindTextEnter
      OnExit = teFindTextExit
      Height = 18
      Width = 154
    end
    object teFindText: TcxTextEdit
      Left = 467
      Top = 0
      Align = alRight
      AutoSize = False
      ParentFont = False
      Properties.OnChange = teFindTextPropertiesChange
      Style.BorderStyle = ebsUltraFlat
      Style.Edges = [bLeft, bBottom]
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 1
      Text = 'Find text...'
      OnEnter = teFindTextEnter
      OnExit = teFindTextExit
      Height = 18
      Width = 154
    end
    object cbDebugInfo: TcxComboBox
      Left = 20
      Top = 0
      Align = alClient
      AutoSize = False
      ParentFont = False
      Properties.DropDownListStyle = lsFixedList
      Properties.Items.Strings = (
        'Debug Output'
        'Memory State')
      Properties.OnChange = cbDebugInfoPropertiesChange
      Style.Edges = [bLeft, bBottom]
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 2
      Text = 'Debug Output'
      Height = 18
      Width = 293
    end
    object btPause: TcxButton
      Left = 0
      Top = 0
      Width = 20
      Height = 18
      Hint = 'Pause logging'
      Align = alLeft
      Colors.PressedText = clRed
      OptionsImage.Glyph.Data = {
        36090000424D3609000000000000360000002800000018000000180000000100
        2000000000000009000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        00000000000000000000000000000000000034353549696D6C9A696D6B9A686C
        6B9A6063628F07070707070707076163628F696D6B9A686C6B9A686C6A9A3435
        344A000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000006A6D6CA3F2F3F2FFEEF0EFFFEBEE
        ECFFB7BBBAE90A0A0A0C08080809B9BCBAE8EFF1F0FFECEFEEFFEDEFEEFF6A6E
        6CA6000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000666867A4F2F3F3FFE9ECEBFFE5E8
        E7FFB9BBBAEB0A0A0A0D0808080ABBBDBCEAECEEEDFFE7EAE9FFEBEEEDFF6568
        67A7000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000005F6160A5F0F2F1FFE8EBE9FFE4E7
        E6FFB6B9B8EB0909090E0808080BB8BBBAEBEAECEBFFE6E9E8FFEBEEEDFF5F62
        61A8000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000585B59A5EDEFEEFFE3E6E5FFE0E4
        E2FFB5B8B6EC0909090F0707070BB6B8B7EBE4E7E6FFE1E5E3FFEAECEBFF595B
        5AA9000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000515453A5EBEDEBFFE1E6E4FFDDE2
        E0FFB3B5B4ED0808080F0606060CB4B6B5ECDDE2E0FFDBE0DEFFE7EAE9FF5154
        53A9000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000004A4D4BA6E9ECEBFFE6E9E8FFE5E8
        E7FFB2B4B3EE070707100606060DB2B4B3EEE0E4E2FFDCE1DFFFE6E9E8FF4A4D
        4CAA000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000474948A7E7EAE9FFE2E6E4FFE1E5
        E4FFB2B6B4EF060606110505050EB2B5B3EEE2E6E4FFE2E6E4FFE7EAE9FF474A
        48AB000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000454846A8E5E9E8FFDFE4E2FFDFE4
        E2FFB5B9B7EF050505120404040FB4B7B5EFDFE3E1FFDFE4E2FFE7EAE8FF4649
        48AB000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000444746A8E6EAE8FFDFE4E2FFDFE4
        E2FFB9BCBBF00404041303030310B8BBB9F0DFE3E1FFDFE4E2FFE7EBEAFF4548
        47AC000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000434645A9EFF1F0FFE4E8E6FFE4E8
        E6FFBBBEBDF10303031302020210BABDBCF1E4E8E6FFE4E8E6FFEFF2F1FF4447
        46AC000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000001F211F65545755BB545755BB5457
        55BB484B4AB1000000110000000F484B4AB1545755BB545755BB545755BB2022
        2167000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000300000005000000050000
        0005000000050000000100000001000000050000000500000005000000050000
        0003000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000}
      ParentShowHint = False
      ShowHint = True
      SpeedButtonOptions.GroupIndex = 3
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 3
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object paSocketIO: TPanel
    Left = 0
    Top = 273
    Width = 621
    Height = 19
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 5
    Visible = False
    object btSocketIOSend: TcxButton
      Left = 507
      Top = 0
      Width = 57
      Height = 19
      Align = alRight
      Action = acSendSocketIO
      Colors.PressedText = 65408
      ParentShowHint = False
      ShowHint = False
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btSocketIORecv: TcxButton
      Left = 564
      Top = 0
      Width = 57
      Height = 19
      Align = alRight
      Action = acRecvSocketIO
      Colors.PressedText = 65408
      ParentShowHint = False
      ShowHint = False
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 2
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object teSocketIO: TcxTextEdit
      Left = 20
      Top = 0
      Align = alClient
      AutoSize = False
      ParentFont = False
      Style.BorderStyle = ebsUltraFlat
      Style.Edges = [bTop, bRight, bBottom]
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.IsFontAssigned = True
      TabOrder = 3
      Height = 19
      Width = 412
    end
    object btAutoClearSocketIO: TcxButton
      Left = 432
      Top = 0
      Width = 75
      Height = 19
      Align = alRight
      Caption = 'Auto clear'
      Colors.PressedText = 4227327
      ParentShowHint = False
      ShowHint = False
      SpeedButtonOptions.GroupIndex = 4
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.AllowAllUp = True
      SpeedButtonOptions.Down = True
      TabOrder = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btClearSocketIO: TcxButton
      Left = 0
      Top = 0
      Width = 20
      Height = 19
      Align = alLeft
      Action = acClearSocketIO
      Colors.PressedText = clRed
      ParentShowHint = False
      ShowHint = False
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.AllowAllUp = True
      TabOrder = 4
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Consolas'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object alDebug: TActionList
    Left = 68
    Top = 36
    object acClearLog: TAction
      Caption = 'Clear'
      OnExecute = acClearLogExecute
    end
    object acSaveLog: TAction
      Caption = 'Save'
      OnExecute = acSaveLogExecute
    end
    object acCopyLogSelection: TAction
      Caption = 'Copy'
      OnExecute = acCopyLogSelectionExecute
    end
    object acSendSocketIO: TAction
      Caption = 'Send'
      OnExecute = acSendSocketIOExecute
    end
    object acRecvSocketIO: TAction
      Caption = 'Recv'
      OnExecute = acRecvSocketIOExecute
    end
    object acClearSocketIO: TAction
      Caption = 'x'
      OnExecute = acClearSocketIOExecute
    end
  end
  object SaveDialog: TSaveDialog
    Filter = 'Rich Text File (*.rtf)|*.rtf|Text File (*.txt)|*.txt'
    Left = 136
    Top = 32
  end
  object pmLog: TPopupMenu
    Left = 200
    Top = 32
    object pmiShowPings: TMenuItem
      AutoCheck = True
      Caption = 'Show pings'
      GroupIndex = 5
    end
    object pmiRTTIEnabled: TMenuItem
      AutoCheck = True
      Caption = 'Enable RTTI'
      Checked = True
      GroupIndex = 6
    end
    object N1: TMenuItem
      Caption = '-'
      GroupIndex = 20
    end
    object pmiLogSave: TMenuItem
      Action = acSaveLog
      GroupIndex = 20
    end
    object pmiLogCopy: TMenuItem
      Action = acCopyLogSelection
      GroupIndex = 20
    end
    object N2: TMenuItem
      Caption = '-'
      GroupIndex = 20
    end
    object pmiLogClear: TMenuItem
      Action = acClearLog
      GroupIndex = 20
    end
  end
  object tiAppInfoRefresh: TTimer
    OnTimer = tiAppInfoRefreshTimer
    Left = 68
    Top = 88
  end
  object RVStyles: TRVStyle
    TextStyles = <
      item
        StyleName = 'Default'
        FontName = 'Consolas'
        Size = 8
        Color = clSilver
        Unicode = True
      end
      item
        StyleName = 'Time'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clSilver
        Unicode = True
      end
      item
        StyleName = 'T-EXCP'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clRed
        Unicode = True
      end
      item
        StyleName = 'T-APPL'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = 14408667
        Unicode = True
      end
      item
        StyleName = 'T-SINC'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = 1958479
        Unicode = True
      end
      item
        StyleName = 'T-SOUT'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = 1958479
        Unicode = True
      end
      item
        StyleName = 'T-SOCK'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = 1958479
        Unicode = True
      end
      item
        StyleName = 'T-NINC'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clMoneyGreen
        Unicode = True
      end
      item
        StyleName = 'T-NOUT'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clMoneyGreen
        Unicode = True
      end
      item
        StyleName = 'T-FORM'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clGray
        Unicode = True
      end
      item
        StyleName = 'T-UNKN'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clYellow
        Unicode = True
      end
      item
        StyleName = 'T-PING'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = 1958479
        Unicode = True
      end
      item
        StyleName = 'D-EXCP'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clRed
        Unicode = True
      end
      item
        StyleName = 'D-APPL'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = 14408667
        Unicode = True
      end
      item
        StyleName = 'D-SINC'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = 1958479
        Unicode = True
      end
      item
        StyleName = 'D-SOUT'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = 1958479
        Unicode = True
      end
      item
        StyleName = 'D-SOCK'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = 1958479
        Unicode = True
      end
      item
        StyleName = 'D-NINC'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clMoneyGreen
        Unicode = True
      end
      item
        StyleName = 'D-NOUT'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clMoneyGreen
        Unicode = True
      end
      item
        StyleName = 'D-FORM'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clGray
        Unicode = True
      end
      item
        StyleName = 'D-UNKN'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clYellow
        Unicode = True
      end
      item
        StyleName = 'D-PING'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = 1958479
        Unicode = True
      end
      item
        StyleName = 'Subdata'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = 13750737
        Unicode = True
      end
      item
        StyleName = 'MemoryState'
        FontName = 'Consolas'
        Size = 8
        Color = clWhite
        Unicode = True
      end
      item
        StyleName = 'Buffer'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clGray
        Unicode = True
      end
      item
        StyleName = 'Buffer-Copied'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = 16744448
        Unicode = True
      end>
    ParaStyles = <
      item
        StyleName = 'Time'
        Alignment = rvaCenter
        Options = [rvpaoReadOnly]
        Tabs = <>
      end
      item
        StyleName = 'Type'
        Alignment = rvaCenter
        Options = [rvpaoReadOnly]
        Tabs = <>
      end
      item
        StyleName = 'Data'
        Options = [rvpaoReadOnly]
        Tabs = <>
      end>
    ListStyles = <>
    UseSound = False
    Color = 2763306
    SelColor = clGray
    InactiveSelColor = clGray
    SelectionMode = rvsmParagraph
    InvalidPicture.Data = {
      07544269746D617036100000424D361000000000000036000000280000002000
      0000200000000100200000000000001000000000000000000000000000000000
      0000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C00000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C00000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C00000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C00000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C00000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF000000FF000000FF00FFFF
      FF00FFFFFF000000FF000000FF00FFFFFF00FFFFFF00C0C0C00000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000
      FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF00C0C0C00000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C00000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000
      FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF00C0C0C00000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF000000FF000000FF00FFFF
      FF00FFFFFF000000FF000000FF00FFFFFF00FFFFFF00C0C0C00000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C00000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C00000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C00000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C00000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008080800080808000808080008080800080808000808080008080
      800080808000808080008080800080808000808080008080800080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000}
    StyleTemplates = <>
    Left = 144
    Top = 88
  end
  object HintStyleController: TcxHintStyleController
    Global = False
    HintStyleClassName = 'TcxHintStyle'
    HintStyle.CaptionFont.Charset = DEFAULT_CHARSET
    HintStyle.CaptionFont.Color = clWindowText
    HintStyle.CaptionFont.Height = -11
    HintStyle.CaptionFont.Name = 'Tahoma'
    HintStyle.CaptionFont.Style = []
    HintStyle.Font.Charset = DEFAULT_CHARSET
    HintStyle.Font.Color = clWindowText
    HintStyle.Font.Height = -11
    HintStyle.Font.Name = 'Tahoma'
    HintStyle.Font.Style = []
    HintShortPause = 30
    HintPause = 30
    Left = 264
    Top = 32
  end
  object tiBufferCopyIndicator: TTimer
    Enabled = False
    OnTimer = tiBufferCopyIndicatorTimer
    Left = 236
    Top = 88
  end
end
