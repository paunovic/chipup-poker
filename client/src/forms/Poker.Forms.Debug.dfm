object frmDebug: TfrmDebug
  Left = 0
  Top = 0
  Caption = 'ChipUP Poker - Debug'
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
  PixelsPerInch = 96
  TextHeight = 14
  object rvMemoryState: TRichView
    Left = 0
    Top = 19
    Width = 621
    Height = 290
    Align = alClient
    TabOrder = 4
    Visible = False
    BorderStyle = bsNone
    DoInPaletteMode = rvpaCreateCopies
    Style = RVStyles
  end
  object meSeatPos: TcxMemo
    Left = 0
    Top = 19
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
    Height = 290
    Width = 621
  end
  object rvLog: TRichView
    Left = 0
    Top = 19
    Width = 621
    Height = 290
    Align = alClient
    PopupMenu = pmLog
    TabOrder = 1
    BorderStyle = bsNone
    DoInPaletteMode = rvpaCreateCopies
    Style = RVStyles
    OnRVMouseUp = rvLogRVMouseUp
  end
  object paInfo: TPanel
    Left = 0
    Top = 309
    Width = 621
    Height = 71
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
      71)
    object dxBevel1: TdxBevel
      Left = 68
      Top = 6
      Width = 19
      Height = 60
      LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Shape = dxbsLineCenteredHorz
    end
    object dxBevel2: TdxBevel
      Left = 215
      Top = 6
      Width = 19
      Height = 60
      LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Shape = dxbsLineCenteredHorz
    end
    object dxBevel3: TdxBevel
      Left = 342
      Top = 6
      Width = 19
      Height = 60
      LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Shape = dxbsLineCenteredHorz
    end
    object lbsThreads: TcxLabel
      Left = 358
      Top = 3
      Anchors = [akLeft, akBottom]
      Caption = 'Threads:'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = [fsBold]
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lbsMemoryUsage: TcxLabel
      Left = 358
      Top = 19
      Anchors = [akLeft, akBottom]
      Caption = 'Memory:'
      ParentFont = False
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
      Left = 82
      Top = 3
      Anchors = [akLeft, akBottom]
      Caption = 'Socket:'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = [fsBold]
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lbsCalbackSets: TcxLabel
      Left = 230
      Top = 3
      Anchors = [akLeft, akBottom]
      Caption = 'Callbacks:'
      ParentFont = False
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
      Left = 410
      Top = 3
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Unknown'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Style.TextColor = clWhite
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleFocused.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleHot.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Transparent = True
      Height = 17
      Width = 90
    end
    object lbvMemoryUsage: TcxLabel
      Left = 410
      Top = 19
      Anchors = [akLeft, akBottom]
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
      Style.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Style.TextColor = clWhite
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleFocused.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleHot.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Transparent = True
      Height = 17
      Width = 90
    end
    object lbvCallbackSets: TcxLabel
      Left = 300
      Top = 3
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Unknown'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Style.TextColor = clWhite
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleFocused.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleHot.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Transparent = True
      Height = 17
      Width = 52
    end
    object lbvSocketState: TcxLabel
      Left = 134
      Top = 3
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Unknown'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Style.TextColor = clWhite
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleFocused.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleHot.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Transparent = True
      Height = 17
      Width = 90
    end
    object btSeatPos: TcxButton
      Left = 586
      Top = 6
      Width = 30
      Height = 29
      Hint = 'Seat positions'
      Anchors = [akLeft, akBottom]
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
      SpeedButtonOptions.GroupIndex = 3
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.AllowAllUp = True
      SpeedButtonOptions.Transparent = True
      TabOrder = 8
      Visible = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btSeatPosClick
    end
    object btPause: TcxButton
      Left = 6
      Top = 6
      Width = 30
      Height = 29
      Hint = 'Pause logging'
      Anchors = [akLeft, akBottom]
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
      SpeedButtonOptions.GroupIndex = 1
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.AllowAllUp = True
      SpeedButtonOptions.Flat = True
      SpeedButtonOptions.Transparent = True
      TabOrder = 9
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbsLatency: TcxLabel
      Left = 82
      Top = 19
      Anchors = [akLeft, akBottom]
      Caption = 'Latency:'
      ParentFont = False
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
      Left = 134
      Top = 19
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Unknown'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Style.TextColor = clWhite
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleFocused.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleHot.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Transparent = True
      Height = 17
      Width = 90
    end
    object btRunAnotherInstance: TcxButton
      Left = 6
      Top = 37
      Width = 30
      Height = 29
      Action = acRunNewInstance
      Anchors = [akLeft, akBottom]
      Colors.PressedText = clRed
      OptionsImage.Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000010101014848485EA6A6A6DDAAAA
        AAE2A7A7A7DEA7A7A7DEA9A9A9E2585858720000000000000000000000000000
        0000000000000000000000000000000000000B0B0B0E929292AFD1D1D1FFD1D1
        D1FFD1D1D1FFD1D1D1FFD1D1D1FFB7B7B7DF0000000000000000000000000000
        00000000000000000000020202021616161E292929388D8D8DAED1D1D1FFD0D0
        D0FFD0D0D0FFD0D0D0FFD0D0D0FFB3B3B3DC0000000000000000000000000000
        000000000000000000002222222AA0A0A0CF929292BE8A8A8AABD1D1D1FFD0D0
        D0FFD0D0D0FFD0D0D0FFD0D0D0FFB3B3B3DB0000000000000000000000000000
        0000000000000000000043434352D3D3D3FF989898B88B8B8BABD0D0D0FFD0D0
        D0FFD0D0D0FFD0D0D0FFD0D0D0FFB2B2B2DA0000000000000000000000000000
        0000111111174242425B5454546CD1D1D1FE949494B5909090B0D1D1D1FFD1D1
        D1FFD1D1D1FFD0D0D0FFD0D0D0FFBBBBBBE50000000000000000000000000000
        000075757594C0C0C0F57A7A7A99D0D0D0FE8C8C8CAC76767691C4C4C4F2C0C0
        C0EDC0C0C0ECC6C6C6F4CCCCCCFAADADADD40000000000000000000000000000
        0000B2B2B2D9C5C5C5EF7C7C7C97CECECEFC9F9F9FC57C7C7CA1AFAFAFE6AAAA
        AADEB1B1B1E767676785414141503232323D0000000000000000000000000000
        0000AAAAAAD0C1C1C1ED7B7B7B97D1D1D1FECDCDCDFBC5C5C5F5C9C9C9FDC9C9
        C9FDCBCBCBFF4848485A00000000000000000000000000000000000000000000
        0000AAAAAAD0C0C0C0EB61616178ACACACD6BFBFBFECBEBEBEEABCBCBCE8C1C1
        C1EBC6C6C6F14444445300000000000000000000000000000000000000000000
        0000A8A8A8CEC9C9C9F58E8E8EB4A7A7A7DCB1B1B1E9B7B7B7F08A8A8AB63131
        313D212121280A0A0A0C00000000000000000000000000000000000000000000
        0000AFAFAFD6D0D0D0FFCDCDCDFCCDCDCDFECECECEFECFCFCFFF9E9E9EC31717
        171C000000000000000000000000000000000000000000000000000000000000
        000075757590AFAFAFD6ADADADD4ADADADD4AEAEAED5B6B6B6DF7C7C7C971111
        1114000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000}
      ParentShowHint = False
      ShowHint = True
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.AllowAllUp = True
      SpeedButtonOptions.Flat = True
      SpeedButtonOptions.Transparent = True
      TabOrder = 12
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btServerTest: TcxButton
      Left = 38
      Top = 37
      Width = 30
      Height = 29
      Action = acServerCrashTest
      Anchors = [akLeft, akBottom]
      Colors.PressedText = clRed
      OptionsImage.Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000000000000000
        000001010101070707090707070A070707090101010100000000000000000000
        0000000000000000000001010101070707090707070A07070709000000000000
        000000000000010101020D0D0D120F0F0F140D0D0D1201010102000000000000
        0000000000000000000000000000010101020D0D0D120707070A000000001717
        171C8080809FA1A1A1C77E7E7E9C38383847848484A6A4A4A4CD8080809F1C1C
        1C236B6B6B859E9E9EC39E9E9EC45656566B04040405070707090F0F0F13BCBC
        BCE7D0D0D0FFD0D0D0FFD0D0D0FFCFCFCFFFCECECEFFD8D8D8FFD8D8D8FFCFCF
        CFFFD0D0D0FFD0D0D0FFD0D0D0FFCFCFCFFF888888A7020202026E6E6E86D1D1
        D1FFD1D1D1FFD1D1D1FFD1D1D1FFD1D1D1FFD1D1D1FF5555555A3E3E3E42CFCF
        CFFFD0D0D0FFD1D1D1FFD1D1D1FFD1D1D1FFD1D1D1FF42424250989898B8D2D2
        D2FFD2D2D2FFD2D2D2FFD2D2D2FFD2D2D2FFD2D2D2FFD9D9D9FFCDCDCDF3D0D0
        D0FFD0D0D0FFD2D2D2FFD2D2D2FFD2D2D2FFD2D2D2FF878787A48C8C8CA9D2D2
        D2FFD3D3D3FFD3D3D3FFD3D3D3FFD3D3D3FFD3D3D3FF7070707D4343434BD1D1
        D1FFD1D1D1FFD1D1D1FFD3D3D3FFD3D3D3FFD3D3D3FF9D9D9DBE47474756D3D3
        D3FFD3D3D3FFD4D4D4FFD4D4D4FFD4D4D4FFD4D4D4FF3A3A3A3F1C1C1C1ED4D4
        D4FFD2D2D2FFD2D2D2FFD2D2D2FFD4D4D4FFD4D4D4FF868686A0020202028282
        829CD4D4D4FFD3D3D3FFD5D5D5FFD6D6D6FFD6D6D6FF2D2D2D301B1B1B1DD6D6
        D6FFD5D5D5FFD3D3D3FFD3D3D3FFD3D3D3FFD5D5D5FF3C3C3C48000000000101
        010145454554D4D4D4FFD4D4D4FFD7D7D7FFD7D7D7FF202020210E0E0E0FD7D7
        D7FFD7D7D7FFD7D7D7FFD4D4D4FFD4D4D4FF8B8B8BA702020202000000000000
        00000E0E0E11D2D2D2FBD5D5D5FFD5D5D5FFD8D8D8FF151515150F0F0F0FD8D8
        D8FFD8D8D8FFD8D8D8FFD8D8D8FF6767677D1111111607070709000000000000
        0000000000006D6D6D80D7D7D7FFD6D6D6FFD4D4D4FCE4E4E4FFE5E5E5FFD9D9
        D9FFD9D9D9FFD9D9D9FFD2D2D2F7060606080D0D0D120707070A000000000000
        000000000000000000002525252C3B3B3B485D5D5D70D8D8D8FFDADADAFFDBDB
        DBFFDBDBDBFFDBDBDBFF75757588000000000101010207070709000000000000
        0000000000000000000000000000010101020D0D0D1251515160A1A1A1BDB0B0
        B0CC9D9D9DB65454546103030303000000000000000001010101000000000000
        00000000000000000000000000000000000001010101070707090707070A0707
        0709010101010000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000}
      ParentShowHint = False
      ShowHint = True
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.AllowAllUp = True
      SpeedButtonOptions.Flat = True
      SpeedButtonOptions.Transparent = True
      TabOrder = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbsSwapChain: TcxLabel
      Left = 230
      Top = 19
      Anchors = [akLeft, akBottom]
      Caption = 'Swap chain:'
      ParentFont = False
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
      Left = 300
      Top = 19
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Unknown'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Style.TextColor = clWhite
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleFocused.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleHot.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Transparent = True
      Height = 17
      Width = 52
    end
    object lbsUser: TcxLabel
      Left = 82
      Top = 51
      Anchors = [akLeft, akBottom]
      Caption = 'User:'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = [fsBold]
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lbvUser: TcxLabel
      Left = 134
      Top = 51
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Unknown'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Style.TextColor = clWhite
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleFocused.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleHot.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Transparent = True
      Height = 17
      Width = 90
    end
    object lbsServer: TcxLabel
      Left = 82
      Top = 35
      Anchors = [akLeft, akBottom]
      Caption = 'Server:'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = [fsBold]
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lbvServer: TcxLabel
      Left = 134
      Top = 35
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Unknown'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Style.TextColor = clWhite
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleFocused.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleHot.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Transparent = True
      Height = 17
      Width = 90
    end
    object lbsSoundBuffers: TcxLabel
      Left = 230
      Top = 51
      Anchors = [akLeft, akBottom]
      Caption = 'Sounds:'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = [fsBold]
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lbvSoundBuffers: TcxLabel
      Left = 300
      Top = 51
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Unknown'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Style.TextColor = clWhite
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleFocused.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleHot.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Transparent = True
      Height = 17
      Width = 52
    end
    object lbsAnimations: TcxLabel
      Left = 230
      Top = 35
      Anchors = [akLeft, akBottom]
      Caption = 'Animations:'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = [fsBold]
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      Transparent = True
    end
    object lbvAnimations: TcxLabel
      Left = 300
      Top = 35
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Unknown'
      ParentFont = False
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Style.TextColor = clWhite
      Style.TextStyle = [fsBold]
      Style.IsFontAssigned = True
      StyleDisabled.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleFocused.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      StyleHot.LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Transparent = True
      Height = 17
      Width = 52
    end
    object btMemoryState: TcxButton
      Left = 38
      Top = 6
      Width = 30
      Height = 29
      Hint = 'Memory state'
      Anchors = [akLeft, akBottom]
      Colors.PressedText = clRed
      OptionsImage.Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000002B2B2B36676767810808080A6262627B44444455141414197272
        728E000000005252526640404050000000000000000000000000000000000000
        00000000000034343441808080A012121217747474915858586E1F1F1F278686
        86A80D0D0D10666666804C4C4C5F000000000000000000000000000000000000
        00002323232C868686A79D9D9DC4868686A7969696BC929292B7898989AB9999
        99BF878787A9999999BF8A8A8AAD2222222B0000000000000000000000002424
        242D7E7E7E9DCCCCCCFFCBCBCBFECCCCCCFFC9C9C9FBCBCBCBFECBCBCBFEC9C9
        C9FBCCCCCCFFCACACAFDCCCCCCFF7F7F7F9F2626262F00000000000000004D4D
        4D60949494B9CCCCCCFFC1C1C1F1C1C1C1F1C2C2C2F2C1C1C1F1C1C1C1F1C2C2
        C2F2C1C1C1F1C1C1C1F1CCCCCCFF999999BF4E4E4E6100000000000000004646
        46578E8E8EB1CCCCCCFFC1C1C1F1C2C2C2F2C2C2C2F2C2C2C2F2C2C2C2F2C2C2
        C2F2C2C2C2F2C1C1C1F1CCCCCCFF939393B84646465700000000000000004040
        40508C8C8CAFCCCCCCFFC1C1C1F1C2C2C2F2C2C2C2F2C2C2C2F2C2C2C2F2C2C2
        C2F2C2C2C2F2C1C1C1F1CCCCCCFF939393B84040405000000000000000004E4E
        4E62949494B9CCCCCCFFC1C1C1F1C1C1C1F1C2C2C2F2C1C1C1F1C1C1C1F1C2C2
        C2F2C1C1C1F1C1C1C1F1CCCCCCFF9A9A9AC15050506400000000000000002323
        232C7E7E7E9DCCCCCCFFCBCBCBFECCCCCCFFC9C9C9FBCBCBCBFECBCBCBFEC8C8
        C8FACCCCCCFFCACACAFDCCCCCCFF7D7D7D9C2323232C00000000000000000000
        00002222222B848484A59B9B9BC2848484A5959595BA919191B5878787A99898
        98BE868686A7969696BB878787A9212121290000000000000000000000000000
        00000000000033333340808080A012121216737373905656566C1E1E1E268686
        86A80C0C0C0F6565657E4A4A4A5C000000000000000000000000000000000000
        0000000000002C2C2C37686868820808080A6363637C44444455141414197171
        718D000000005151516540404050000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000}
      ParentShowHint = False
      ShowHint = True
      SpeedButtonOptions.GroupIndex = 2
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.AllowAllUp = True
      SpeedButtonOptions.Flat = True
      SpeedButtonOptions.Transparent = True
      TabOrder = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btMemoryStateClick
    end
  end
  object paTop: TPanel
    Left = 0
    Top = 0
    Width = 621
    Height = 19
    Align = alTop
    BevelEdges = [beLeft, beTop, beRight]
    BevelOuter = bvNone
    TabOrder = 3
    object ccbLogForms: TcxCheckComboBox
      Left = 0
      Top = 0
      Align = alClient
      AutoSize = False
      ParentFont = False
      Properties.Alignment.Vert = taVCenter
      Properties.DropDownRows = 16
      Properties.Items = <>
      Properties.OnChange = ccbLogFormsPropertiesChange
      Style.BorderStyle = ebsUltraFlat
      Style.Edges = [bBottom]
      Style.Font.Charset = DEFAULT_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.TextStyle = []
      Style.IsFontAssigned = True
      TabOrder = 0
      Height = 19
      Width = 313
    end
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
      TabOrder = 1
      Text = 'RegEx filtering...'
      OnEnter = teFindTextEnter
      OnExit = teFindTextExit
      Height = 19
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
      TabOrder = 2
      Text = 'Find text...'
      OnEnter = teFindTextEnter
      OnExit = teFindTextExit
      Height = 19
      Width = 154
    end
  end
  object alDebug: TActionList
    Left = 72
    Top = 32
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
    object acRunNewInstance: TAction
      Hint = 'Run new instance'
      OnExecute = acRunNewInstanceExecute
    end
    object acServerCrashTest: TAction
      Hint = 'Server crash test'
      OnExecute = acServerCrashTestExecute
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
      GroupIndex = 1
    end
    object pmiRTTIEnabled: TMenuItem
      AutoCheck = True
      Caption = 'Enable RTTI'
      Checked = True
      GroupIndex = 2
    end
    object N1: TMenuItem
      Caption = '-'
      GroupIndex = 2
    end
    object pmiLogSave: TMenuItem
      Action = acSaveLog
      GroupIndex = 3
    end
    object pmiLogCopy: TMenuItem
      Action = acCopyLogSelection
      GroupIndex = 3
    end
    object N2: TMenuItem
      Caption = '-'
      GroupIndex = 3
    end
    object pmiLogClear: TMenuItem
      Action = acClearLog
      GroupIndex = 3
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
        Color = clWhite
        Unicode = True
      end
      item
        StyleName = 'T-SINC'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clLime
        Unicode = True
      end
      item
        StyleName = 'T-SOUT'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clLime
        Unicode = True
      end
      item
        StyleName = 'T-SOCK'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clLime
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
        Color = clLime
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
        Color = clWhite
        Unicode = True
      end
      item
        StyleName = 'D-SINC'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clLime
        Unicode = True
      end
      item
        StyleName = 'D-SOUT'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clLime
        Unicode = True
      end
      item
        StyleName = 'D-SOCK'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clLime
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
        Color = clLime
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
end
