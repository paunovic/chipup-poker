object frmCreateClub: TfrmCreateClub
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Create Club'
  ClientHeight = 112
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
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  DesignSize = (
    386
    112)
  PixelsPerInch = 96
  TextHeight = 14
  object edClubName: TcxTextEdit
    Left = 103
    Top = 14
    Properties.MaxLength = 64
    TabOrder = 0
    Width = 266
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
    Left = 103
    Top = 41
    Properties.MaxLength = 32
    TabOrder = 1
    Width = 266
  end
  object lbsInvCode: TcxLabel
    Left = 18
    Top = 42
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
    Left = 177
    Top = 72
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
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitTop = 101
  end
  object btCancel: TcxButton
    Left = 276
    Top = 72
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
    ExplicitTop = 101
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
