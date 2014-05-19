object frmCloseClubConfirmation: TfrmCloseClubConfirmation
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Close Club Confirmation'
  ClientHeight = 114
  ClientWidth = 327
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
  OnKeyDown = FormKeyDown
  DesignSize = (
    327
    114)
  PixelsPerInch = 96
  TextHeight = 13
  object btConfirm: TcxButton
    Left = 123
    Top = 79
    Width = 93
    Height = 27
    Action = acConfirm
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 1
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 222
    Top = 79
    Width = 93
    Height = 27
    Action = acCancel
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
  object lbsWarning1: TcxLabel
    Left = 8
    Top = 6
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'You are about to disband the club!'
    Style.TextColor = 7434751
    Style.TextStyle = [fsBold]
    Properties.Alignment.Horz = taCenter
    Transparent = True
    Height = 17
    Width = 311
    AnchorX = 164
  end
  object lbsWarning2: TcxLabel
    Left = 8
    Top = 24
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Please enter club password to confirm this action:'
    Style.TextColor = 7434751
    Style.TextStyle = [fsBold]
    Properties.Alignment.Horz = taCenter
    Transparent = True
    Height = 17
    Width = 311
    AnchorX = 164
  end
  object edPassword: TcxTextEdit
    Left = 87
    Top = 47
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.EchoMode = eemPassword
    Properties.MaxLength = 32
    Properties.PasswordChar = '*'
    Properties.OnChange = edPasswordPropertiesChange
    TabOrder = 0
    OnKeyDown = edPasswordKeyDown
    Width = 154
  end
  object alCloseClub: TActionList
    Left = 36
    Top = 52
    object acCancel: TAction
      Caption = 'Cancel'
      OnExecute = acCancelExecute
    end
    object acConfirm: TAction
      Caption = 'Confirm'
      Enabled = False
      OnExecute = acConfirmExecute
    end
  end
end
