object frmTableSit: TfrmTableSit
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Table Sit Options'
  ClientHeight = 81
  ClientWidth = 226
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    226
    81)
  PixelsPerInch = 96
  TextHeight = 13
  object lbsBuyinAmount: TcxLabel
    AlignWithMargins = True
    Left = 11
    Top = 13
    Margins.Left = 10
    Margins.Right = 10
    Caption = 'Buy-in amount:'
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.TextStyle = []
    Style.IsFontAssigned = True
    Properties.Alignment.Horz = taLeftJustify
    Properties.Alignment.Vert = taVCenter
    Properties.WordWrap = True
    Transparent = True
    Width = 76
    AnchorY = 22
  end
  object seBuyin: TcxSpinEdit
    Left = 92
    Top = 12
    Properties.MinValue = 1.000000000000000000
    Properties.SpinButtons.Visible = False
    Properties.ValueType = vtInt
    TabOrder = 1
    Value = 1
    Width = 87
  end
  object btOK: TcxButton
    Left = 25
    Top = 46
    Width = 93
    Height = 27
    Action = acOK
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 2
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 124
    Top = 46
    Width = 93
    Height = 27
    Action = acCancel
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 3
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object Edit1: TEdit
    Left = 185
    Top = 13
    Width = 33
    Height = 19
    TabOrder = 4
    Text = '1'
  end
  object alTableSit: TActionList
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
