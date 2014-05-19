object frmChangeClubDetails: TfrmChangeClubDetails
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Change Club Details'
  ClientHeight = 161
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
    161)
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
    Left = 127
    Top = 11
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.MaxLength = 64
    Properties.ReadOnly = False
    TabOrder = 0
    Width = 255
  end
  object lbsInvitationCode: TcxLabel
    Left = 12
    Top = 38
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
    Left = 127
    Top = 37
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.MaxLength = 32
    TabOrder = 1
    Width = 255
  end
  object btOK: TcxButton
    Left = 190
    Top = 125
    Width = 93
    Height = 27
    Action = acOK
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 5
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    ExplicitTop = 67
  end
  object btCancel: TcxButton
    Left = 289
    Top = 125
    Width = 93
    Height = 27
    Action = acCancel
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 6
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    ExplicitTop = 67
  end
  object cbDefaultPlayerLimit: TcxCheckBox
    Left = 10
    Top = 93
    Caption = 'Default player limit:'
    Properties.ImmediatePost = True
    Properties.OnChange = cbDefaultPlayerLimitPropertiesChange
    TabOrder = 3
    Transparent = True
    Width = 113
  end
  object seLimit: TcxSpinEdit
    Left = 127
    Top = 93
    Enabled = False
    Properties.MinValue = 1.000000000000000000
    Properties.UseDisplayFormatWhenEditing = True
    Properties.ValueType = vtFloat
    TabOrder = 4
    Value = 1000.000000000000000000
    Width = 95
  end
  object seRake: TcxSpinEdit
    Left = 127
    Top = 65
    Properties.CanEdit = False
    Properties.DisplayFormat = '#%'
    Properties.MaxValue = 10.000000000000000000
    Properties.MinValue = 1.000000000000000000
    Properties.UseDisplayFormatWhenEditing = True
    TabOrder = 2
    Value = 1
    Width = 56
  end
  object lbsClubRake: TcxLabel
    Left = 14
    Top = 66
    Caption = 'Club rake:'
    Transparent = True
  end
  object acChangeClubDetails: TActionList
    Left = 52
    Top = 21
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
