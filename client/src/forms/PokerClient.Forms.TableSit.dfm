object frmTableSit: TfrmTableSit
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Get Chips'
  ClientHeight = 160
  ClientWidth = 298
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
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  DesignSize = (
    298
    160)
  PixelsPerInch = 96
  TextHeight = 13
  object lbsBuyinAmount: TcxLabel
    AlignWithMargins = True
    Left = 15
    Top = 94
    Margins.Left = 10
    Margins.Right = 10
    Anchors = [akLeft, akBottom]
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
    AnchorY = 103
  end
  object seBuyin: TcxSpinEdit
    Left = 91
    Top = 93
    Anchors = [akLeft, akRight, akBottom]
    Properties.MinValue = 1.000000000000000000
    Properties.SpinButtons.Visible = False
    Properties.UseLeftAlignmentOnEditing = False
    Properties.ValueType = vtFloat
    Properties.OnChange = seBuyinPropertiesChange
    TabOrder = 1
    Value = 100.000000000000000000
    Width = 84
  end
  object btOK: TcxButton
    Left = 97
    Top = 124
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
  end
  object btCancel: TcxButton
    Left = 196
    Top = 124
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
  end
  object lbsInfo: TcxLabel
    AlignWithMargins = True
    Left = 3
    Top = 6
    Margins.Top = 6
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    AutoSize = False
    Properties.Alignment.Horz = taCenter
    Properties.Alignment.Vert = taVCenter
    Transparent = True
    Height = 78
    Width = 292
    AnchorX = 149
    AnchorY = 45
  end
  object btMin: TcxButton
    Left = 177
    Top = 94
    Width = 55
    Height = 19
    Action = acMin
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 5
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object btMax: TcxButton
    Left = 234
    Top = 94
    Width = 55
    Height = 19
    Action = acMax
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 6
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object alTableSit: TActionList
    Left = 44
    Top = 45
    object acOK: TAction
      Caption = 'OK'
      Enabled = False
      OnExecute = acOKExecute
    end
    object acCancel: TAction
      Caption = 'Cancel'
      OnExecute = acCancelExecute
    end
    object acMin: TAction
      Caption = 'MIN'
      OnExecute = acMinExecute
    end
    object acMax: TAction
      Caption = 'MAX'
      OnExecute = acMaxExecute
    end
  end
end
