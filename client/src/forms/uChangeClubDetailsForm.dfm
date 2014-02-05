object frmChangeClubDetails: TfrmChangeClubDetails
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Change Club Details'
  ClientHeight = 132
  ClientWidth = 393
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
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  DesignSize = (
    393
    132)
  PixelsPerInch = 96
  TextHeight = 14
  object lbsClubType: TcxLabel
    Left = 12
    Top = 66
    Caption = 'Club type:'
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
    Left = 94
    Top = 67
    Width = 61
    Height = 17
    Caption = 'Private'
    Checked = True
    TabOrder = 2
    TabStop = True
    Transparent = True
  end
  object rbPublic: TcxRadioButton
    Left = 161
    Top = 68
    Width = 61
    Height = 17
    Caption = 'Public'
    TabOrder = 3
    TabStop = True
    Transparent = True
  end
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
    Left = 94
    Top = 11
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.MaxLength = 64
    Properties.ReadOnly = False
    TabOrder = 0
    Width = 288
  end
  object lbsInvitationCode: TcxLabel
    Left = 12
    Top = 39
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
  object edInvitationCode: TcxTextEdit
    Left = 94
    Top = 38
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.MaxLength = 32
    TabOrder = 1
    Width = 288
  end
  object btOK: TcxButton
    Left = 190
    Top = 96
    Width = 93
    Height = 27
    Action = acOK
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 7
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 289
    Top = 96
    Width = 93
    Height = 27
    Action = acCancel
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 8
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
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
