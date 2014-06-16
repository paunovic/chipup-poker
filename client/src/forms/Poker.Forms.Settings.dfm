object frmSettings: TfrmSettings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Settings'
  ClientHeight = 425
  ClientWidth = 621
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
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    621
    425)
  PixelsPerInch = 96
  TextHeight = 13
  object gbLeftPanel: TcxGroupBox
    Left = 8
    Top = 8
    Anchors = [akLeft, akTop, akBottom]
    PanelStyle.Active = True
    TabOrder = 0
    Height = 374
    Width = 166
    object lbOptions: TcxListBox
      Left = 2
      Top = 2
      Width = 162
      Height = 370
      Align = alClient
      AutoComplete = False
      ItemHeight = 30
      Items.Strings = (
        'General'
        'Themes')
      ListStyle = lbOwnerDrawFixed
      Style.TextStyle = [fsBold]
      TabOrder = 0
      OnClick = lbOptionsClick
      OnMouseDown = lbOptionsMouseDown
    end
  end
  object gbRightPanel: TcxGroupBox
    Left = 180
    Top = 8
    Anchors = [akLeft, akTop, akRight, akBottom]
    PanelStyle.Active = True
    TabOrder = 1
    Height = 374
    Width = 431
    object pcSettings: TcxPageControl
      Left = 2
      Top = 2
      Width = 427
      Height = 370
      Align = alClient
      TabOrder = 0
      Properties.ActivePage = tsThemes
      Properties.HideTabs = True
      Properties.ShowFrame = True
      ClientRectBottom = 369
      ClientRectLeft = 1
      ClientRectRight = 426
      ClientRectTop = 1
      object tsGeneral: TcxTabSheet
        Caption = 'tsGeneral'
        ImageIndex = 0
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 422
        ExplicitHeight = 345
      end
      object tsThemes: TcxTabSheet
        Caption = 'tsThemes'
        ImageIndex = 1
        DesignSize = (
          425
          368)
        object lbsCardBackground: TcxLabel
          Left = 9
          Top = 10
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Card background:'
          Style.TextStyle = []
          Properties.Alignment.Horz = taLeftJustify
          Transparent = True
        end
        object lbsRoomBackground: TcxLabel
          Left = 9
          Top = 37
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Room background:'
          Style.TextStyle = []
          Properties.Alignment.Horz = taLeftJustify
          Transparent = True
        end
        object cbCardBackground: TcxComboBox
          Left = 105
          Top = 8
          Properties.DropDownListStyle = lsFixedList
          TabOrder = 2
          Width = 178
        end
        object cbRoomBackground: TcxComboBox
          Left = 105
          Top = 35
          Properties.DropDownListStyle = lsFixedList
          TabOrder = 3
          Width = 178
        end
      end
    end
  end
  object btOK: TcxButton
    Left = 419
    Top = 390
    Width = 93
    Height = 27
    Action = acOK
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
  object btCancel: TcxButton
    Left = 518
    Top = 390
    Width = 93
    Height = 27
    Action = acCancel
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
  object alSettings: TActionList
    Left = 52
    Top = 156
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
