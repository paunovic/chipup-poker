object frmContactUs: TfrmContactUs
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Contact Us'
  ClientHeight = 298
  ClientWidth = 433
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  DesignSize = (
    433
    298)
  PixelsPerInch = 96
  TextHeight = 13
  object lbsMessage: TcxLabel
    Left = 14
    Top = 41
    Caption = 'Message:'
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
  object cbType: TcxComboBox
    Left = 77
    Top = 13
    Anchors = [akLeft, akTop, akRight]
    Properties.DropDownListStyle = lsFixedList
    Properties.Items.Strings = (
      'Support'
      'Bug Report'
      'Other')
    Properties.ReadOnly = False
    TabOrder = 3
    Text = 'Support'
    ExplicitWidth = 369
    Width = 336
  end
  object lbsType: TcxLabel
    Left = 14
    Top = 15
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
  object meMessage: TcxMemo
    Left = 77
    Top = 41
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    Height = 211
    Width = 336
  end
  object btSend: TcxButton
    Left = 221
    Top = 261
    Width = 93
    Height = 27
    Action = acSend
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 1
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 320
    Top = 261
    Width = 93
    Height = 27
    Action = acCancel
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 2
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object ActionList: TActionList
    Left = 24
    Top = 152
    object acSend: TAction
      Caption = 'Send'
      OnExecute = acSendExecute
    end
    object acCancel: TAction
      Caption = 'Cancel'
      OnExecute = acCancelExecute
    end
  end
end
