object frmEditGame: TfrmEditGame
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Edit Table'
  ClientHeight = 196
  ClientWidth = 376
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  DesignSize = (
    376
    196)
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
  object btOK: TcxButton
    Left = 169
    Top = 157
    Width = 93
    Height = 27
    Action = acOK
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 6
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitTop = 158
  end
  object btCancel: TcxButton
    Left = 268
    Top = 157
    Width = 93
    Height = 27
    Action = acCancel
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 7
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    ExplicitTop = 158
  end
  object lbsSeats: TcxLabel
    Left = 18
    Top = 128
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
    Top = 127
    Properties.DropDownListStyle = lsFixedList
    Properties.Items.Strings = (
      '2'
      '6'
      '9'
      '10')
    Properties.ReadOnly = False
    TabOrder = 4
    Text = '10'
    Width = 65
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
  object cbGameType: TcxComboBox
    Left = 88
    Top = 44
    Properties.DropDownListStyle = lsFixedList
    Properties.Items.Strings = (
      'Hold'#39'em'
      'Omaha')
    Properties.ReadOnly = False
    TabOrder = 1
    Text = 'Hold'#39'em'
    Width = 273
  end
  object lbsBlinds: TcxLabel
    Left = 18
    Top = 100
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
  object cbLimit: TcxComboBox
    Left = 88
    Top = 71
    Properties.DropDownListStyle = lsFixedList
    Properties.Items.Strings = (
      'No Limit'
      'Fixed Limit'
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
    Top = 99
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
  object alEditGame: TActionList
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
