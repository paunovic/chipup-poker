object frmTableSit: TfrmTableSit
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Get Chips'
  ClientHeight = 87
  ClientWidth = 228
  Color = clBlack
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
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  DesignSize = (
    228
    87)
  PixelsPerInch = 96
  TextHeight = 13
  object lbsBuyinAmount: TcxLabel
    AlignWithMargins = True
    Left = 15
    Top = 17
    Margins.Left = 10
    Margins.Right = 10
    Caption = 'Chips amount:'
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
    Width = 72
    AnchorY = 26
  end
  object seBuyin: TcxSpinEdit
    Left = 91
    Top = 16
    Properties.MinValue = 1.000000000000000000
    Properties.SpinButtons.Visible = False
    Properties.UseLeftAlignmentOnEditing = False
    Properties.ValueType = vtFloat
    TabOrder = 1
    Value = 100.000000000000000000
    Width = 128
  end
  object btOK: TcxButton
    Left = 27
    Top = 51
    Width = 93
    Height = 27
    Action = acOK
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 2
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    ExplicitTop = 58
  end
  object btCancel: TcxButton
    Left = 126
    Top = 51
    Width = 93
    Height = 27
    Action = acCancel
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 3
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    ExplicitTop = 58
  end
  object alTableSit: TActionList
    Left = 104
    Top = 32
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
