object frmDebug: TfrmDebug
  Left = 0
  Top = 0
  Caption = 'ChipUP Poker - Debug'
  ClientHeight = 379
  ClientWidth = 675
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 14
  object meSeatPos: TcxMemo
    Left = 0
    Top = 0
    Align = alClient
    Lines.Strings = (
      '(0, pi, 0, 0, 0, 0, 0, 0, 0, 0), // 2'
      '(0, pi/2, pi, 0, 0, 0, 0, 0, 0, 0), // 3'
      '(-pi/4, pi/4, pi*3/4, pi*5/4, 0, 0, 0, 0, 0, 0), // 4'
      '(-pi/5.5, pi/7, pi/2, pi-pi/7, pi+pi/5.5, 0, 0, 0, 0, 0), // 5'
      '(-pi/3, 0, pi/2.7, pi-pi/2.7, pi, pi+pi/3, 0, 0, 0, 0), // 6'
      '(-pi/4, 0, pi/4, pi/2, pi*3/4, pi, pi*5/4, 0, 0, 0), // 7'
      
        '(-pi/3, -pi/10.4, pi/8, pi/2.3, pi-pi/2.3, pi-pi/8, pi+pi/10.4, ' +
        'pi+pi/3, 0, 0), // 8'
      
        '(-pi/2.7, -pi/10.3, pi/64, pi/3.5, pi/2, pi-pi/3.5, pi-pi/64, pi' +
        '+pi/10.3, pi+pi/2.7, 0), // 9'
      
        '(-pi/2.7, -pi/7.7, pi/128, pi/6, pi/2.3, pi-pi/2.3, pi-pi/6, pi-' +
        'pi/128, pi+pi/7.7, pi+pi/2.7) // 10')
    ParentFont = False
    Properties.WordWrap = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -12
    Style.Font.Name = 'Consolas'
    Style.Font.Style = []
    Style.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    Style.IsFontAssigned = True
    StyleDisabled.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    StyleFocused.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    StyleHot.LookAndFeel.SkinName = 'ChipUpDarkStyle'
    TabOrder = 0
    Visible = False
    Height = 303
    Width = 675
  end
  object rvLog: TRichView
    Left = 0
    Top = 0
    Width = 675
    Height = 303
    Align = alClient
    PopupMenu = pmLog
    TabOrder = 1
    BorderStyle = bsNone
    DoInPaletteMode = rvpaCreateCopies
    Style = RVStyles
  end
  object paInfo: TPanel
    Left = 0
    Top = 303
    Width = 675
    Height = 76
    Align = alBottom
    BevelOuter = bvNone
    Ctl3D = False
    DoubleBuffered = True
    ParentBackground = False
    ParentCtl3D = False
    ParentDoubleBuffered = False
    TabOrder = 2
    DesignSize = (
      675
      76)
    object dxBevel1: TdxBevel
      Left = 33
      Top = 6
      Width = 19
      Height = 65
      LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Shape = dxbsLineCenteredHorz
    end
    object dxBevel2: TdxBevel
      Left = 191
      Top = 6
      Width = 19
      Height = 65
      LookAndFeel.SkinName = 'ChipUpDarkStyle'
      Shape = dxbsLineCenteredHorz
    end
    object lbsThreads: TcxLabel
      Left = 46
      Top = 4
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
      Left = 46
      Top = 20
      Anchors = [akLeft, akBottom]
      Caption = 'Memory usage:'
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
      Left = 204
      Top = 4
      Anchors = [akLeft, akBottom]
      Caption = 'Socket state:'
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
      Left = 46
      Top = 36
      Anchors = [akLeft, akBottom]
      Caption = 'Callback sets:'
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
      Left = 135
      Top = 4
      Anchors = [akLeft, akBottom]
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
    end
    object lbvMemoryUsage: TcxLabel
      Left = 135
      Top = 20
      Anchors = [akLeft, akBottom]
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
    end
    object lbvCallbackSets: TcxLabel
      Left = 135
      Top = 36
      Anchors = [akLeft, akBottom]
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
    end
    object lbvSocketState: TcxLabel
      Left = 287
      Top = 4
      Anchors = [akLeft, akBottom]
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
    end
    object btSeatPos: TcxButton
      Left = 571
      Top = 6
      Width = 93
      Height = 31
      Anchors = [akRight, akBottom]
      Caption = 'SEAT POS'
      Colors.PressedText = clRed
      SpeedButtonOptions.GroupIndex = 2
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.AllowAllUp = True
      SpeedButtonOptions.Flat = True
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
    object btSet: TcxButton
      Left = 571
      Top = 39
      Width = 93
      Height = 31
      Anchors = [akRight, akBottom]
      Caption = 'SET'
      Colors.PressedText = clRed
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 9
      Visible = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = btSetClick
    end
    object btPause: TcxButton
      Left = 5
      Top = 5
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
      TabOrder = 10
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lbsLatency: TcxLabel
      Left = 204
      Top = 20
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
      Left = 287
      Top = 20
      Anchors = [akLeft, akBottom]
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
    end
    object gbServerTests: TcxGroupBox
      Left = 497
      Top = 8
      Anchors = [akRight, akBottom]
      Caption = ' Server Tests '
      TabOrder = 13
      Height = 59
      Width = 173
      object btServerTest1: TcxButton
        Left = 9
        Top = 22
        Width = 23
        Height = 21
        Action = acServerTest1
        Colors.PressedText = clWhite
        ParentShowHint = False
        ShowHint = True
        SpeedButtonOptions.CanBeFocused = False
        SpeedButtonOptions.AllowAllUp = True
        SpeedButtonOptions.Flat = True
        TabOrder = 0
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object btServerTest2: TcxButton
        Left = 31
        Top = 22
        Width = 23
        Height = 21
        Action = acServerTest2
        Colors.PressedText = clWhite
        ParentShowHint = False
        ShowHint = True
        SpeedButtonOptions.CanBeFocused = False
        SpeedButtonOptions.AllowAllUp = True
        SpeedButtonOptions.Flat = True
        TabOrder = 1
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object btServerTest4: TcxButton
        Left = 75
        Top = 22
        Width = 23
        Height = 21
        Action = acServerTest4
        Colors.PressedText = clWhite
        ParentShowHint = False
        ShowHint = True
        SpeedButtonOptions.CanBeFocused = False
        SpeedButtonOptions.AllowAllUp = True
        SpeedButtonOptions.Flat = True
        TabOrder = 2
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object btServerTest3: TcxButton
        Left = 53
        Top = 22
        Width = 23
        Height = 21
        Action = acServerTest3
        Colors.PressedText = clWhite
        ParentShowHint = False
        ShowHint = True
        SpeedButtonOptions.CanBeFocused = False
        SpeedButtonOptions.AllowAllUp = True
        SpeedButtonOptions.Flat = True
        TabOrder = 3
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object btServerTest5: TcxButton
        Left = 97
        Top = 22
        Width = 23
        Height = 21
        Action = acServerTest5
        Colors.PressedText = clWhite
        ParentShowHint = False
        ShowHint = True
        SpeedButtonOptions.CanBeFocused = False
        SpeedButtonOptions.AllowAllUp = True
        SpeedButtonOptions.Flat = True
        TabOrder = 4
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object btServerTest6: TcxButton
        Left = 119
        Top = 22
        Width = 23
        Height = 21
        Action = acServerTest6
        Colors.PressedText = clWhite
        ParentShowHint = False
        ShowHint = True
        SpeedButtonOptions.CanBeFocused = False
        SpeedButtonOptions.AllowAllUp = True
        SpeedButtonOptions.Flat = True
        TabOrder = 5
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object btServerTest7: TcxButton
        Left = 141
        Top = 22
        Width = 23
        Height = 21
        Action = acServerTest7
        Colors.PressedText = clWhite
        ParentShowHint = False
        ShowHint = True
        SpeedButtonOptions.CanBeFocused = False
        SpeedButtonOptions.AllowAllUp = True
        SpeedButtonOptions.Flat = True
        TabOrder = 6
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object btShowPings: TcxButton
      Left = 5
      Top = 40
      Width = 30
      Height = 29
      Hint = 'Show pings'
      Anchors = [akLeft, akBottom]
      Colors.PressedText = clRed
      OptionsImage.Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        20000000000000040000000000000000000000000000000000003232323FC7C7
        C7F9979797BD0202020300000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000BEBEBEEDCCCC
        CCFFCCCCCCFF7E7E7E9D00000000000000000000000000000000000000000000
        00000000000000000000000000000000000000000000000000008F8F8FB3CCCC
        CCFFCCCCCCFFCCCCCCFF5E5E5E7600000000000000003030303C2D2D2D380000
        0000141414190000000000000000000000000000000000000000020202037C7C
        7C9BCCCCCCFFCCCCCCFFC7C7C7F9969696BBB1B1B1DDC2C2C2F2333333407171
        718DCCCCCCFF838383A412121217000000000000000000000000000000000000
        00005858586ECCCCCCFFCCCCCCFFCCCCCCFFC5C5C5F6373737456E6E6E89CCCC
        CCFFCCCCCCFFCCCCCCFFC1C1C1F13232323F0000000000000000000000000000
        000000000000979797BDCCCCCCFFBDBDBDEC2F2F2F3B6565657ECCCCCCFFCCCC
        CCFFCCCCCCFFCCCCCCFFCCCCCCFFB2B2B2DE1111111500000000000000000000
        000000000000ABABABD6CCCCCCFF2E2E2E396363637CCCCCCCFFCCCCCCFFCCCC
        CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFF6E6E6E8A1616161C000000000000
        000028282832B6B6B6E3363636446666667FCCCCCCFFCCCCCCFFCCCCCCFFCCCC
        CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFAAAAAAD553535368000000000000
        00002A2A2A35343434416B6B6B86CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
        CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFB5B5B5E260606078000000000000
        0000000000007272728FCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
        CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC6C6C6F76E6E6E8A000000000000
        000012121217BCBCBCEBCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
        CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFBEBEBEED67676781000000000000
        00000000000079797997CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
        CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFA2A2A2CA4949495B1F1F1F279494
        94B96666667F1515151AB3B3B3E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
        CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFF676767810A0A0A0DA5A5A5CECCCC
        CCFFCCCCCCFF6363637C0E0E0E12B3B3B3E0CCCCCCFFCCCCCCFFCCCCCCFFCCCC
        CCFFCCCCCCFFCCCCCCFFCCCCCCFF989898BE0101010100000000BEBEBEEECCCC
        CCFFCCCCCCFF8E8E8EB2000000000D0D0D107E7E7E9DC9C9C9FBCCCCCCFFCCCC
        CCFFCCCCCCFFCCCCCCFF6B6B6B8604040405000000000000000046464658C9C9
        C9FBA9A9A9D31F1F1F2700000000000000000000000014141419424242535555
        556A474747591919191F00000000000000000000000000000000}
      ParentShowHint = False
      ShowHint = True
      SpeedButtonOptions.GroupIndex = 2
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.AllowAllUp = True
      SpeedButtonOptions.Flat = True
      SpeedButtonOptions.Transparent = True
      TabOrder = 14
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
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
    object acServerTest1: TAction
      Caption = '1'
      OnExecute = acServerTest1Execute
    end
    object acServerTest2: TAction
      Caption = '2'
      OnExecute = acServerTest2Execute
    end
    object acServerTest3: TAction
      Caption = '3'
      OnExecute = acServerTest3Execute
    end
    object acServerTest4: TAction
      Caption = '4'
      OnExecute = acServerTest4Execute
    end
    object acServerTest5: TAction
      Caption = '5'
    end
    object acServerTest6: TAction
      Caption = '6'
    end
    object acServerTest7: TAction
      Caption = '7'
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
    object pmiLogSave: TMenuItem
      Action = acSaveLog
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object pmiLogCopy: TMenuItem
      Action = acCopyLogSelection
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object pmiLogClear: TMenuItem
      Action = acClearLog
    end
  end
  object tiAppInfoRefresh: TTimer
    Interval = 500
    OnTimer = tiAppInfoRefreshTimer
    Left = 68
    Top = 88
  end
  object RVStyles: TRVStyle
    TextStyles = <
      item
        StyleName = 'Time'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clSilver
        Unicode = True
      end
      item
        StyleName = 'Type: Exception'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clRed
        Unicode = True
      end
      item
        StyleName = 'Type: Application'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clWhite
        Unicode = True
      end
      item
        StyleName = 'Type: Socket'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clLime
        Unicode = True
      end
      item
        StyleName = 'Type: Net'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clMoneyGreen
        Unicode = True
      end
      item
        StyleName = 'Type: Form'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clGray
        Unicode = True
      end
      item
        StyleName = 'Type: Unknown'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clYellow
        Unicode = True
      end
      item
        StyleName = 'Data: Exception'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clRed
        Unicode = True
      end
      item
        StyleName = 'Data: Application'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clWhite
        Unicode = True
      end
      item
        StyleName = 'Data: Socket'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clLime
        Unicode = True
      end
      item
        StyleName = 'Data: Net'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clMoneyGreen
        Unicode = True
      end
      item
        StyleName = 'Data: Form'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clGray
        Unicode = True
      end
      item
        StyleName = 'Data: Unknown'
        FontName = 'Consolas'
        Size = 8
        Style = [fsBold]
        Color = clYellow
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
