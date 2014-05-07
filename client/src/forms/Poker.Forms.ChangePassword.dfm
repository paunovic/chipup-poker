object frmChangePassword: TfrmChangePassword
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Change Password'
  ClientHeight = 128
  ClientWidth = 301
  Color = clBlack
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  DesignSize = (
    301
    128)
  PixelsPerInch = 96
  TextHeight = 13
  object lbsCurrentPassword: TcxLabel
    Left = 7
    Top = 12
    Caption = 'Current password:'
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
  object lbsNewPassword: TcxLabel
    Left = 7
    Top = 39
    Caption = 'New password:'
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
  object edNewPassword: TcxTextEdit
    Left = 106
    Top = 38
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.EchoMode = eemPassword
    Properties.MaxLength = 32
    Properties.PasswordChar = '*'
    TabOrder = 1
    Width = 187
  end
  object edCurrentPassword: TcxTextEdit
    Left = 106
    Top = 11
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.EchoMode = eemPassword
    Properties.MaxLength = 32
    Properties.PasswordChar = '*'
    TabOrder = 0
    Width = 187
  end
  object lbsConfirmPassword: TcxLabel
    Left = 7
    Top = 63
    Caption = 'Confirm password:'
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
  object edConfirmPassword: TcxTextEdit
    Left = 106
    Top = 62
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.EchoMode = eemPassword
    Properties.MaxLength = 32
    Properties.PasswordChar = '*'
    TabOrder = 2
    Width = 187
  end
  object btOK: TcxButton
    Left = 101
    Top = 92
    Width = 93
    Height = 27
    Action = acOK
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 3
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitTop = 94
  end
  object btCancel: TcxButton
    Left = 200
    Top = 92
    Width = 93
    Height = 27
    Action = acCancel
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 4
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    ExplicitTop = 94
  end
  object alChangePassword: TActionList
    Left = 36
    Top = 82
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
