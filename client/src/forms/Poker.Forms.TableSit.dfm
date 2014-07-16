object frmTableSit: TfrmTableSit
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Get Chips'
  ClientHeight = 134
  ClientWidth = 298
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
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  DesignSize = (
    298
    134)
  PixelsPerInch = 96
  TextHeight = 13
  object lbsChipsAmount: TcxLabel
    AlignWithMargins = True
    Left = 15
    Top = 64
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
    Style.TextStyle = [fsBold]
    Style.IsFontAssigned = True
    Properties.Alignment.Horz = taLeftJustify
    Properties.Alignment.Vert = taVCenter
    Properties.WordWrap = True
    Transparent = True
    Width = 84
    AnchorY = 73
  end
  object seBuyin: TcxSpinEdit
    Left = 102
    Top = 63
    Anchors = [akLeft, akRight, akBottom]
    Properties.MaxValue = 99999999.000000000000000000
    Properties.MinValue = 1.000000000000000000
    Properties.SpinButtons.Visible = False
    Properties.UseLeftAlignmentOnEditing = False
    Properties.ValueType = vtFloat
    Properties.OnChange = seBuyinPropertiesChange
    Style.TextColor = clWhite
    Style.TextStyle = [fsBold]
    TabOrder = 1
    Value = 100.000000000000000000
    Width = 72
  end
  object btOK: TcxButton
    Left = 97
    Top = 98
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
    Font.Style = []
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 196
    Top = 98
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
  object lbvTableName: TcxLabel
    AlignWithMargins = True
    Left = 3
    Top = 6
    Margins.Top = 6
    Align = alTop
    AutoSize = False
    Caption = 'Table Name'
    Style.TextColor = clWhite
    Style.TextStyle = [fsBold]
    Properties.Alignment.Horz = taCenter
    Properties.Alignment.Vert = taVCenter
    Transparent = True
    Height = 22
    Width = 292
    AnchorX = 149
    AnchorY = 17
  end
  object btMin: TcxButton
    Left = 177
    Top = 64
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
    Top = 64
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
  object lbsTableBuyins: TcxLabel
    AlignWithMargins = True
    Left = 8
    Top = 26
    Margins.Top = 6
    AutoSize = False
    Caption = '(min buy-in %.2f, max buyin %.2f)'
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -11
    Style.Font.Name = 'Tahoma'
    Style.Font.Style = []
    Style.TextStyle = [fsBold]
    Style.IsFontAssigned = True
    Properties.Alignment.Horz = taCenter
    Properties.Alignment.Vert = taVCenter
    Transparent = True
    Height = 17
    Width = 282
    AnchorX = 149
    AnchorY = 35
  end
  object alTableSit: TActionList
    Left = 256
    Top = 9
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
