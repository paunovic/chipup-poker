object frmHandHistory: TfrmHandHistory
  Left = 0
  Top = 0
  Caption = 'Hand History'
  ClientHeight = 496
  ClientWidth = 392
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClick = FormClick
  OnClose = FormClose
  OnDestroy = FormDestroy
  DesignSize = (
    392
    496)
  PixelsPerInch = 96
  TextHeight = 13
  object cbTable: TcxComboBox
    Left = 51
    Top = 11
    Anchors = [akLeft, akTop, akRight]
    Properties.DropDownListStyle = lsFixedList
    TabOrder = 0
    Width = 330
  end
  object lbsTable: TcxLabel
    Left = 11
    Top = 12
    Caption = 'Table:'
    Transparent = True
  end
  object meHandHistory: TcxMemo
    Left = 11
    Top = 62
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      '')
    ParentFont = False
    Properties.ReadOnly = True
    Properties.WordWrap = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.IsFontAssigned = True
    TabOrder = 2
    Height = 391
    Width = 370
  end
  object btOK: TcxButton
    Left = 189
    Top = 460
    Width = 93
    Height = 27
    Action = acOK
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 3
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 288
    Top = 460
    Width = 93
    Height = 27
    Action = acClose
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 4
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object cxComboBox1: TcxComboBox
    Left = 51
    Top = 35
    Anchors = [akLeft, akTop, akRight]
    Properties.DropDownListStyle = lsFixedList
    TabOrder = 1
    Width = 330
  end
  object cxLabel1: TcxLabel
    Left = 11
    Top = 36
    Caption = 'Hand:'
    Transparent = True
  end
  object alHandHistory: TActionList
    Left = 64
    Top = 104
    object acOK: TAction
      Caption = 'OK'
      OnExecute = acOKExecute
    end
    object acClose: TAction
      Caption = 'Close'
      OnExecute = acCloseExecute
    end
  end
end
