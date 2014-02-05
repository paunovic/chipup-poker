object frmCreateClub: TfrmCreateClub
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Create Club'
  ClientHeight = 145
  ClientWidth = 386
  Color = clBlack
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
  DesignSize = (
    386
    145)
  PixelsPerInch = 96
  TextHeight = 14
  object edClubName: TcxTextEdit
    Left = 100
    Top = 14
    Properties.MaxLength = 64
    TabOrder = 0
    Width = 269
  end
  object lbsClubName: TcxLabel
    Left = 18
    Top = 15
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
  object edClubCode: TcxTextEdit
    Left = 100
    Top = 43
    Properties.MaxLength = 32
    TabOrder = 1
    Width = 269
  end
  object lbsInvCode: TcxLabel
    Left = 18
    Top = 44
    Caption = 'Invitation code:'
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
  object lbsClubType: TcxLabel
    Left = 18
    Top = 73
    Caption = 'Type:'
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
  object rbPrivate: TcxRadioButton
    Left = 100
    Top = 75
    Width = 61
    Height = 17
    Caption = 'Private'
    Checked = True
    TabOrder = 2
    TabStop = True
    Transparent = True
  end
  object rbPublic: TcxRadioButton
    Left = 167
    Top = 75
    Width = 61
    Height = 17
    Caption = 'Public'
    TabOrder = 3
    TabStop = True
    Transparent = True
  end
  object btOK: TcxButton
    Left = 177
    Top = 105
    Width = 93
    Height = 27
    Action = acOK
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 7
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 276
    Top = 105
    Width = 93
    Height = 27
    Action = acCancel
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 8
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object alCreateClub: TActionList
    Left = 24
    Top = 4
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
