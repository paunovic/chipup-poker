object frmCreateAccount: TfrmCreateAccount
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Create New Account'
  ClientHeight = 264
  ClientWidth = 336
  Color = clWindow
  Ctl3D = False
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 14
  object edEMail: TcxTextEdit
    Left = 120
    Top = 21
    Properties.MaxLength = 200
    TabOrder = 0
    Width = 198
  end
  object edPassword: TcxTextEdit
    Left = 120
    Top = 56
    Properties.EchoMode = eemPassword
    Properties.MaxLength = 32
    Properties.PasswordChar = '*'
    TabOrder = 1
    Width = 198
  end
  object edConfirmPassword: TcxTextEdit
    Left = 120
    Top = 84
    Properties.EchoMode = eemPassword
    Properties.MaxLength = 32
    Properties.PasswordChar = '*'
    TabOrder = 2
    Width = 198
  end
  object edUsername: TcxTextEdit
    Left = 120
    Top = 118
    Properties.MaxLength = 20
    TabOrder = 3
    Width = 198
  end
  object cb18Years: TcxCheckBox
    Left = 22
    Top = 153
    Caption = 'I am at least 18 years of age'
    TabOrder = 4
    Transparent = True
    Width = 177
  end
  object cbTOS: TcxCheckBox
    Left = 22
    Top = 176
    Caption = 'I agree to'
    TabOrder = 5
    Transparent = True
    Width = 68
  end
  object btSignUp: TcxButton
    Left = 188
    Top = 212
    Width = 130
    Height = 36
    Action = acSignUp
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 6
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lbsEMail: TcxLabel
    Left = 22
    Top = 22
    Caption = 'E-mail address:'
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
  object lbsPassword: TcxLabel
    Left = 22
    Top = 57
    Caption = 'Password:'
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
  object lbsConfirmPassword: TcxLabel
    Left = 22
    Top = 85
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
  object lbsUsername: TcxLabel
    Left = 22
    Top = 119
    Caption = 'Username:'
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
  object lbTOS: TcxLabel
    Left = 89
    Top = 176
    Cursor = crHandPoint
    Caption = 'Terms and Conditions'
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clAqua
    Style.Font.Height = -11
    Style.Font.Name = 'Arial'
    Style.Font.Style = []
    Style.LookAndFeel.NativeStyle = True
    Style.TextStyle = [fsUnderline]
    Style.IsFontAssigned = True
    StyleDisabled.LookAndFeel.NativeStyle = True
    StyleFocused.LookAndFeel.NativeStyle = True
    StyleHot.LookAndFeel.NativeStyle = True
    Transparent = True
    OnClick = lbTOSClick
  end
  object alCreateAccount: TActionList
    Left = 44
    Top = 216
    object acSignUp: TAction
      Caption = 'SIGN ME UP'
      OnExecute = acSignUpExecute
    end
  end
end
