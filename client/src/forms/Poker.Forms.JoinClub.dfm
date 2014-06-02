object frmJoinClub: TfrmJoinClub
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Join Club'
  ClientHeight = 104
  ClientWidth = 294
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
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  DesignSize = (
    294
    104)
  PixelsPerInch = 96
  TextHeight = 14
  object lbsClubID: TcxLabel
    Left = 11
    Top = 11
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
    Left = 95
    Top = 37
    Anchors = [akLeft, akTop, akRight]
    Properties.MaxLength = 32
    TabOrder = 1
    ExplicitWidth = 143
    Width = 189
  end
  object lbsInvCode: TcxLabel
    Left = 11
    Top = 38
    Caption = 'Club password:'
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
    Left = 95
    Top = 10
    Anchors = [akLeft, akTop, akRight]
    Properties.MaxValue = 999999999.000000000000000000
    Properties.MinValue = 1.000000000000000000
    Properties.SpinButtons.Visible = False
    Properties.ValueType = vtInt
    Properties.OnChange = edClubIDPropertiesChange
    TabOrder = 0
    Value = 1
    ExplicitWidth = 143
    Width = 189
  end
  object btOK: TcxButton
    Left = 92
    Top = 68
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
    Font.Style = []
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 191
    Top = 68
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
