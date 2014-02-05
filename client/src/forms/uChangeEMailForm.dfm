object frmChangeEMail: TfrmChangeEMail
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Change E-mail Address'
  ClientHeight = 174
  ClientWidth = 428
  Color = clBlack
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
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
  DesignSize = (
    428
    174)
  PixelsPerInch = 96
  TextHeight = 14
  object lbInfo: TcxLabel
    AlignWithMargins = True
    Left = 10
    Top = 3
    Margins.Left = 10
    Margins.Right = 10
    Align = alTop
    AutoSize = False
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Arial'
    Style.Font.Style = []
    Style.TextColor = clRed
    Style.TextStyle = []
    Style.IsFontAssigned = True
    Properties.Alignment.Horz = taCenter
    Properties.Alignment.Vert = taVCenter
    Properties.WordWrap = True
    Transparent = True
    Height = 69
    Width = 408
    AnchorX = 214
    AnchorY = 38
  end
  object lbsCurrentMail: TcxLabel
    Left = 7
    Top = 79
    Caption = 'Current e-mail address:'
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
  object edCurrentMail: TcxTextEdit
    Left = 127
    Top = 78
    TabStop = False
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.ReadOnly = True
    TabOrder = 0
    Width = 291
  end
  object lbsNewMail: TcxLabel
    Left = 7
    Top = 106
    Caption = 'New e-mail address:'
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
  object edNewMail: TcxTextEdit
    Left = 127
    Top = 105
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.MaxLength = 32
    Properties.OnChange = edNewMailPropertiesChange
    TabOrder = 1
    Width = 291
  end
  object btOK: TcxButton
    Left = 226
    Top = 138
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
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 325
    Top = 138
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
  end
  object alChangeEMailAddress: TActionList
    Left = 56
    Top = 122
    object acOK: TAction
      Caption = 'OK'
      Enabled = False
      OnExecute = acOKExecute
    end
    object acCancel: TAction
      Caption = 'Cancel'
      OnExecute = acCancelExecute
    end
  end
end
