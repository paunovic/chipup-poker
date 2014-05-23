object frmClubMemberOptions: TfrmClubMemberOptions
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Set Player Limit'
  ClientHeight = 77
  ClientWidth = 228
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    228
    77)
  PixelsPerInch = 96
  TextHeight = 13
  object btOK: TcxButton
    Left = 24
    Top = 42
    Width = 93
    Height = 27
    Action = acOK
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 2
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 123
    Top = 42
    Width = 93
    Height = 27
    Action = acCancel
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 3
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object seLimit: TcxSpinEdit
    Left = 46
    Top = 9
    Properties.MaxValue = 999999999.000000000000000000
    Properties.MinValue = 1.000000000000000000
    Properties.UseDisplayFormatWhenEditing = True
    Properties.ValueType = vtFloat
    TabOrder = 0
    Value = 1000.000000000000000000
    Width = 95
  end
  object cbUnlimited: TcxCheckBox
    Left = 145
    Top = 9
    Caption = 'Unlimited'
    Properties.ImmediatePost = True
    Properties.OnChange = cbUnlimitedPropertiesChange
    TabOrder = 1
    Transparent = True
    Width = 113
  end
  object lbsLimit: TcxLabel
    Left = 11
    Top = 10
    Caption = 'Limit:'
    Transparent = True
  end
  object alClubMemberOptions: TActionList
    Left = 56
    Top = 12
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
