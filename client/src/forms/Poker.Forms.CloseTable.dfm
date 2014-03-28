object frmCloseTable: TfrmCloseTable
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Close Table'
  ClientHeight = 115
  ClientWidth = 184
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btCloseInstant: TcxButton
    Left = 8
    Top = 9
    Width = 165
    Height = 28
    Action = acCloseAfterCurrentHand
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 0
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object btClose5: TcxButton
    Left = 8
    Top = 43
    Width = 165
    Height = 28
    Action = acCloseAfter5Mins
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 1
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object btClose15: TcxButton
    Left = 8
    Top = 77
    Width = 165
    Height = 28
    Action = acCloseAfter15Mins
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 2
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object ActionList: TActionList
    Left = 12
    Top = 4
    object acCloseAfterCurrentHand: TAction
      Caption = 'Close After Current Hand'
      OnExecute = acCloseAfterCurrentHandExecute
    end
    object acCloseAfter5Mins: TAction
      Caption = 'Close After 5 Minutes'
      OnExecute = acCloseAfter5MinsExecute
    end
    object acCloseAfter15Mins: TAction
      Caption = 'Close After 15 Minutes'
      OnExecute = acCloseAfter15MinsExecute
    end
  end
end
