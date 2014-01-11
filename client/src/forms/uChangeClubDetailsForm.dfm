object frmChangeClubDetails: TfrmChangeClubDetails
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Change Club Details'
  ClientHeight = 167
  ClientWidth = 393
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
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    393
    167)
  PixelsPerInch = 96
  TextHeight = 14
  object lbsClubType: TcxLabel
    Left = 12
    Top = 100
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
    Top = 101
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
    Top = 102
    Width = 61
    Height = 17
    Caption = 'Public'
    TabOrder = 3
    TabStop = True
    Transparent = True
  end
  object lbsClubName: TcxLabel
    Left = 12
    Top = 46
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
    Top = 45
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.MaxLength = 64
    Properties.ReadOnly = False
    TabOrder = 0
    Width = 288
  end
  object lbsInvitationCode: TcxLabel
    Left = 12
    Top = 73
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
    Top = 72
    Anchors = [akLeft, akTop, akRight]
    Properties.Alignment.Horz = taLeftJustify
    Properties.MaxLength = 32
    TabOrder = 1
    Width = 288
  end
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
    Style.Font.Style = [fsBold]
    Style.TextStyle = []
    Style.IsFontAssigned = True
    Properties.Alignment.Horz = taCenter
    Properties.Alignment.Vert = taVCenter
    Properties.WordWrap = True
    Transparent = True
    Height = 36
    Width = 373
    AnchorX = 197
    AnchorY = 21
  end
  object btOK: TcxButton
    Left = 190
    Top = 131
    Width = 93
    Height = 27
    Action = acOK
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 8
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 289
    Top = 131
    Width = 93
    Height = 27
    Action = acCancel
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 9
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object acChangeClubDetails: TActionList
    Left = 56
    Top = 121
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
