object frmChangeAvatar: TfrmChangeAvatar
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Change Avatar'
  ClientHeight = 255
  ClientWidth = 226
  Color = clBlack
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
  OnKeyPress = FormKeyPress
  DesignSize = (
    226
    255)
  PixelsPerInch = 96
  TextHeight = 14
  object lbsInfo: TcxLabel
    AlignWithMargins = True
    Left = 10
    Top = 3
    Margins.Left = 10
    Margins.Right = 10
    Align = alTop
    AutoSize = False
    Caption = 
      'Maximum allowed size of avatar is 100kb. Maximum dimensions are ' +
      '150x150px.'
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
    Height = 43
    Width = 206
    AnchorY = 25
  end
  object btChange: TcxButton
    Left = 17
    Top = 218
    Width = 93
    Height = 27
    Action = acChange
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 1
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 116
    Top = 218
    Width = 93
    Height = 27
    Action = acClose
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 2
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object imgAvatar: TcxImage
    Left = 38
    Top = 53
    Properties.PopupMenuLayout.MenuItems = []
    Properties.ReadOnly = True
    Properties.ShowFocusRect = False
    TabOrder = 3
    Height = 150
    Width = 150
  end
  object alChangeAvatar: TActionList
    Left = 104
    Top = 124
    object acChange: TAction
      Caption = 'Change...'
      OnExecute = acChangeExecute
    end
    object acClose: TAction
      Caption = 'Close'
      OnExecute = acCloseExecute
    end
  end
  object OpenDialog: TOpenDialog
    Filter = 'Picture Files (*.jpg, *.png, *.bmp)|*.jpg;*.png;*.bmp'
    Left = 28
    Top = 124
  end
end
