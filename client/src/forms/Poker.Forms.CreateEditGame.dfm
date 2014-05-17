object frmCreateEditGame: TfrmCreateEditGame
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  ClientHeight = 226
  ClientWidth = 376
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  DesignSize = (
    376
    226)
  PixelsPerInch = 96
  TextHeight = 14
  object edGameName: TcxTextEdit
    Left = 88
    Top = 17
    Properties.MaxLength = 64
    TabOrder = 0
    Width = 273
  end
  object lbsGameName: TcxLabel
    Left = 18
    Top = 18
    Caption = 'Game name:'
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.TextStyle = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object lbsGameType: TcxLabel
    Left = 18
    Top = 45
    Caption = 'Game type:'
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.TextStyle = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object btOK: TcxButton
    Left = 169
    Top = 187
    Width = 93
    Height = 27
    Action = acOK
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 9
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 268
    Top = 187
    Width = 93
    Height = 27
    Action = acCancel
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 10
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object cbGameType: TcxComboBox
    Left = 88
    Top = 44
    Properties.DropDownListStyle = lsFixedList
    Properties.Items.Strings = (
      'Hold'#39'em'
      'Omaha'
      'Rotation (NLH/PLO)')
    Properties.ReadOnly = False
    Properties.OnChange = cbGameTypePropertiesChange
    TabOrder = 1
    Text = 'Hold'#39'em'
    Width = 273
  end
  object lbsBlinds: TcxLabel
    Left = 18
    Top = 99
    Caption = 'Blinds:'
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.TextStyle = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object lbsSeats: TcxLabel
    Left = 18
    Top = 154
    Caption = 'Seats:'
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.TextStyle = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cbSeats: TcxComboBox
    Left = 88
    Top = 153
    Properties.DropDownListStyle = lsFixedList
    Properties.DropDownRows = 10
    Properties.Items.Strings = (
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9'
      '10')
    Properties.ReadOnly = False
    TabOrder = 6
    Text = '10'
    Width = 65
  end
  object cbLimit: TcxComboBox
    Left = 88
    Top = 71
    Properties.DropDownListStyle = lsFixedList
    Properties.Items.Strings = (
      'No Limit'
      'Pot Limit')
    TabOrder = 2
    Text = 'No Limit'
    Width = 273
  end
  object lbsLimit: TcxLabel
    Left = 18
    Top = 71
    Caption = 'Limit:'
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.TextStyle = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object cbBlinds: TcxComboBox
    Left = 88
    Top = 98
    Properties.DropDownListStyle = lsFixedList
    Properties.Items.Strings = (
      '1/2'
      '5/5'
      '5/10'
      '10/25'
      '25/50'
      '50/100')
    TabOrder = 3
    Text = '1/2'
    Width = 273
  end
  object lbsBuyinLimit: TcxLabel
    Left = 18
    Top = 127
    Caption = 'Buy-in limit:'
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.TextStyle = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object seBuyinMin: TcxSpinEdit
    Left = 111
    Top = 126
    Properties.MinValue = 5.000000000000000000
    TabOrder = 4
    Value = 20
    Width = 53
  end
  object seBuyinMax: TcxSpinEdit
    Left = 199
    Top = 126
    Properties.MinValue = 10.000000000000000000
    TabOrder = 5
    Value = 200
    Width = 53
  end
  object lbsBuyinMin: TcxLabel
    Left = 86
    Top = 127
    Caption = 'min'
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.TextStyle = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object lbsBuyinMax: TcxLabel
    Left = 167
    Top = 127
    Caption = ' max'
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.TextStyle = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object lbsBuyinBigBlinds: TcxLabel
    Left = 255
    Top = 127
    Caption = 'big blinds'
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.TextStyle = []
    Style.IsFontAssigned = True
    Transparent = True
  end
  object alCreateGame: TActionList
    Left = 24
    Top = 4
    object acOK: TAction
      Caption = 'OK'
      OnExecute = acOKExecute
    end
    object acCancel: TAction
      Caption = 'Cancel'
      OnExecute = acCancelExecute
    end
  end
end
