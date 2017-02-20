object frmChangeClubDetails: TfrmChangeClubDetails
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Change Club Settings'
  ClientHeight = 192
  ClientWidth = 393
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
    393
    192)
  PixelsPerInch = 96
  TextHeight = 14
  object lbsClubName: TcxLabel
    Left = 12
    Top = 12
    Caption = 'Club name:'
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
  object edClubName: TcxTextEdit
    Left = 95
    Top = 13
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.MaxLength = 64
    Properties.ReadOnly = False
    TabOrder = 0
    Width = 287
  end
  object lbsInvitationCode: TcxLabel
    Left = 12
    Top = 43
    Caption = 'Club password:'
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
  object edInvitationCode: TcxTextEdit
    Left = 95
    Top = 41
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.MaxLength = 32
    TabOrder = 1
    Width = 287
  end
  object btOK: TcxButton
    Left = 190
    Top = 156
    Width = 93
    Height = 27
    Action = acOK
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 6
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 289
    Top = 156
    Width = 93
    Height = 27
    Action = acCancel
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 7
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object cbDefaultPlayerLimit: TcxCheckBox
    Left = 10
    Top = 97
    Caption = 'Default player limit:'
    Properties.ImmediatePost = True
    Properties.OnChange = cbDefaultPlayerLimitPropertiesChange
    TabOrder = 3
    Transparent = True
  end
  object seLimit: TcxSpinEdit
    Left = 127
    Top = 97
    Enabled = False
    Properties.MinValue = 1.000000000000000000
    Properties.UseDisplayFormatWhenEditing = True
    Properties.ValueType = vtFloat
    TabOrder = 4
    Value = 1000.000000000000000000
    Width = 95
  end
  object seRake: TcxSpinEdit
    Left = 70
    Top = 69
    Properties.AssignedValues.MinValue = True
    Properties.CanEdit = False
    Properties.DisplayFormat = '0%'
    Properties.MaxValue = 10.000000000000000000
    Properties.UseDisplayFormatWhenEditing = True
    TabOrder = 2
    Value = 1
    Width = 56
  end
  object lbsClubRake: TcxLabel
    Left = 12
    Top = 70
    Caption = 'Club rake:'
    Transparent = True
  end
  object lbsResetBuyinLimits: TcxLabel
    Left = 12
    Top = 126
    Caption = 'Hit && Run rule: player must wait minimum'
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
  object cbResetBuyinLimits: TcxComboBox
    Left = 212
    Top = 125
    Properties.DropDownListStyle = lsFixedList
    Properties.Items.Strings = (
      '30'
      '60'
      '90'
      '120')
    TabOrder = 5
    Text = '30'
    Width = 56
  end
  object lbsResetBuyinMinutes: TcxLabel
    Left = 270
    Top = 126
    Caption = 'minutes'
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
  object acChangeClubDetails: TActionList
    Left = 24
    Top = 115
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
