object frmGiveChips: TfrmGiveChips
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Give Chips To Player'
  ClientHeight = 143
  ClientWidth = 359
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
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    359
    143)
  PixelsPerInch = 96
  TextHeight = 14
  object lbsClubName: TcxLabel
    Left = 12
    Top = 13
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
    Left = 94
    Top = 12
    TabStop = False
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.ReadOnly = True
    Style.Color = clSilver
    TabOrder = 0
    Width = 255
  end
  object lbsPlayerName: TcxLabel
    Left = 12
    Top = 40
    Caption = 'Player name:'
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
  object edPlayerName: TcxTextEdit
    Left = 94
    Top = 39
    TabStop = False
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.ReadOnly = True
    Style.Color = clSilver
    TabOrder = 1
    Width = 255
  end
  object lbsChipsAmount: TcxLabel
    Left = 12
    Top = 67
    Caption = 'Chip amount:'
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
  object seChipAmount: TcxSpinEdit
    Left = 94
    Top = 66
    Properties.MaxValue = 2000.000000000000000000
    Properties.SpinButtons.Visible = False
    TabOrder = 2
    Width = 255
  end
  object btOK: TcxButton
    Left = 155
    Top = 104
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
  end
  object btCancel: TcxButton
    Left = 256
    Top = 104
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
  end
  object alChipTransfer: TActionList
    Left = 44
    Top = 92
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
