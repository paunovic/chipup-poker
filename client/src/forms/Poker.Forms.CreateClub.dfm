object frmCreateClub: TfrmCreateClub
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Create Club'
  ClientHeight = 104
  ClientWidth = 294
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
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  DesignSize = (
    294
    104)
  PixelsPerInch = 96
  TextHeight = 14
  object edClubName: TcxTextEdit
    Left = 98
    Top = 10
    Anchors = [akLeft, akTop, akRight]
    Properties.MaxLength = 64
    TabOrder = 0
    ExplicitWidth = 187
    Width = 185
  end
  object lbsClubName: TcxLabel
    Left = 13
    Top = 11
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
    Left = 98
    Top = 37
    Anchors = [akLeft, akTop, akRight]
    Properties.MaxLength = 32
    TabOrder = 1
    ExplicitWidth = 187
    Width = 185
  end
  object lbsInvCode: TcxLabel
    Left = 13
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
  object btOK: TcxButton
    Left = 91
    Top = 68
    Width = 93
    Height = 27
    Action = acOK
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 4
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    ExplicitLeft = 93
  end
  object btCancel: TcxButton
    Left = 190
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
    ExplicitLeft = 192
  end
  object alCreateClub: TActionList
    Left = 19
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
