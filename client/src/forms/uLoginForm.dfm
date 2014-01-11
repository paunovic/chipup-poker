object frmLogin: TfrmLogin
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Welcome to ChipUP Poker'
  ClientHeight = 368
  ClientWidth = 552
  Color = clWindow
  Ctl3D = False
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 14
  object cbRememberLogin: TcxCheckBox
    Left = 267
    Top = 114
    Caption = 'Remember login'
    ParentFont = False
    TabOrder = 2
    Transparent = True
    Width = 129
  end
  object cbRememberPassword: TcxCheckBox
    Left = 267
    Top = 136
    Caption = 'Remember password'
    ParentFont = False
    TabOrder = 3
    Transparent = True
    Width = 129
  end
  object btLogin: TcxButton
    Left = 180
    Top = 171
    Width = 170
    Height = 50
    Action = acLogin
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 4
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btCreateAccount: TcxButton
    Left = 257
    Top = 245
    Width = 139
    Height = 36
    Action = acShowCreateAccountForm
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 5
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object btForgotPassword: TcxButton
    Left = 257
    Top = 287
    Width = 139
    Height = 36
    Action = acShowForgotPasswordForm
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 6
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object edLogin: TcxTextEdit
    Left = 198
    Top = 59
    Properties.MaxLength = 200
    TabOrder = 0
    Width = 198
  end
  object edPassword: TcxTextEdit
    Left = 198
    Top = 86
    Properties.EchoMode = eemPassword
    Properties.MaxLength = 32
    Properties.PasswordChar = '*'
    TabOrder = 1
    Width = 198
  end
  object lbsLogin: TcxLabel
    Left = 133
    Top = 60
    Caption = 'Login:'
    ParentFont = False
    Transparent = True
  end
  object lbsPassword: TcxLabel
    Left = 133
    Top = 87
    Caption = 'Password:'
    ParentFont = False
    Transparent = True
  end
  object StatusBar: TdxStatusBar
    Left = 0
    Top = 348
    Width = 552
    Height = 20
    Panels = <
      item
        PanelStyleClassName = 'TdxStatusBarTextPanelStyle'
      end>
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
  end
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'CRASH'
    TabOrder = 10
    OnClick = Button1Click
  end
  object alLogin: TActionList
    Left = 36
    Top = 44
    object acLogin: TAction
      Caption = 'Login'
      Enabled = False
      OnExecute = acLoginExecute
    end
    object acShowCreateAccountForm: TAction
      Caption = 'Create new account'
      Enabled = False
      OnExecute = acShowCreateAccountFormExecute
    end
    object acShowForgotPasswordForm: TAction
      Caption = 'Forgot password'
      Enabled = False
      OnExecute = acShowForgotPasswordFormExecute
    end
  end
  object SkinController: TdxSkinController
    SkinName = 'DevExpressStyle'
    Left = 496
    Top = 12
  end
end
