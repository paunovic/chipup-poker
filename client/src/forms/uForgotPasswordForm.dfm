object frmForgotPassword: TfrmForgotPassword
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Forgot password'
  ClientHeight = 158
  ClientWidth = 305
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
  OnKeyPress = FormKeyPress
  DesignSize = (
    305
    158)
  PixelsPerInch = 96
  TextHeight = 14
  object btOk: TcxButton
    Left = 20
    Top = 102
    Width = 126
    Height = 38
    Action = acOK
    Enabled = False
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 0
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 159
    Top = 102
    Width = 126
    Height = 38
    Action = acCancel
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 1
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object edEMail: TcxTextEdit
    Left = 104
    Top = 66
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.MaxLength = 200
    Properties.OnChange = edEmailChange
    TabOrder = 2
    Width = 181
  end
  object lbsEMail: TcxLabel
    Left = 20
    Top = 66
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
  object lbsInfo: TcxLabel
    AlignWithMargins = True
    Left = 10
    Top = 3
    Margins.Left = 10
    Margins.Right = 10
    Align = alTop
    AutoSize = False
    Caption = 
      'Please enter your E-mail address in the box below. Upon submissi' +
      'on, your password reset link will be sent to it.'
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.TextStyle = []
    Style.IsFontAssigned = True
    Properties.Alignment.Horz = taLeftJustify
    Properties.Alignment.Vert = taVCenter
    Properties.WordWrap = True
    Transparent = True
    Height = 57
    Width = 285
    AnchorY = 32
  end
  object alForgotPassword: TActionList
    Left = 36
    Top = 8
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
