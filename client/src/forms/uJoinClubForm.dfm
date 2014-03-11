object frmJoinClub: TfrmJoinClub
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Join Club'
  ClientHeight = 114
  ClientWidth = 292
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
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  DesignSize = (
    292
    114)
  PixelsPerInch = 96
  TextHeight = 14
  object lbsClubID: TcxLabel
    Left = 18
    Top = 18
    Caption = 'Club ID:'
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
    Left = 98
    Top = 44
    Anchors = [akLeft, akTop, akRight]
    Properties.MaxLength = 32
    TabOrder = 1
    Width = 179
  end
  object lbsInvCode: TcxLabel
    Left = 18
    Top = 45
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
  object edClubID: TcxSpinEdit
    Left = 98
    Top = 17
    Anchors = [akLeft, akTop, akRight]
    Properties.MaxValue = 999999999.000000000000000000
    Properties.MinValue = 1.000000000000000000
    Properties.SpinButtons.Visible = False
    Properties.ValueType = vtInt
    Properties.OnChange = edClubIDPropertiesChange
    TabOrder = 0
    Value = 1
    Width = 179
  end
  object btOK: TcxButton
    Left = 85
    Top = 76
    Width = 93
    Height = 27
    Action = acOk
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 4
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 184
    Top = 76
    Width = 93
    Height = 27
    Action = acCancel
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 5
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object alJoinClub: TActionList
    Left = 24
    Top = 76
    object acOk: TAction
      Caption = 'OK'
      OnExecute = acOkExecute
    end
    object acCancel: TAction
      Caption = 'Cancel'
      OnExecute = acCancelExecute
    end
  end
end
