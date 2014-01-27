object frmDebug: TfrmDebug
  Left = 0
  Top = 0
  Caption = 'Debug'
  ClientHeight = 353
  ClientWidth = 523
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 14
  object paLog: TPanel
    Left = 0
    Top = 0
    Width = 523
    Height = 353
    Align = alClient
    BevelOuter = bvNone
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
    object paInfo: TPanel
      Left = 0
      Top = 278
      Width = 523
      Height = 75
      Align = alBottom
      BevelOuter = bvNone
      Ctl3D = False
      ParentBackground = False
      ParentCtl3D = False
      TabOrder = 1
      DesignSize = (
        523
        75)
      object lbsThreads: TLabel
        Left = 355
        Top = 8
        Width = 43
        Height = 14
        Anchors = [akTop, akRight]
        Caption = 'Threads:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        ExplicitLeft = 414
      end
      object lbvThreads: TLabel
        Left = 450
        Top = 8
        Width = 12
        Height = 14
        Anchors = [akTop, akRight]
        Caption = '00'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitLeft = 509
      end
      object lbsMemoryUsage: TLabel
        Left = 355
        Top = 24
        Width = 74
        Height = 14
        Anchors = [akTop, akRight]
        Caption = 'Memory usage:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        ExplicitLeft = 414
      end
      object lbvMemoryUsage: TLabel
        Left = 450
        Top = 24
        Width = 44
        Height = 14
        Anchors = [akTop, akRight]
        Caption = '00000kb'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitLeft = 509
      end
      object lbsMessageHandlers: TLabel
        Left = 355
        Top = 40
        Width = 92
        Height = 14
        Anchors = [akTop, akRight]
        Caption = 'Message handlers:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        ExplicitLeft = 414
      end
      object lbvMessageHandlers: TLabel
        Left = 450
        Top = 40
        Width = 6
        Height = 14
        Anchors = [akTop, akRight]
        Caption = '0'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        ExplicitLeft = 509
      end
      object lbsMessages: TLabel
        Left = 355
        Top = 56
        Width = 77
        Height = 14
        Anchors = [akTop, akRight]
        Caption = 'Message count:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object lbvMessages: TLabel
        Left = 450
        Top = 56
        Width = 6
        Height = 14
        Anchors = [akTop, akRight]
        Caption = '0'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object cbSockInc: TcxCheckBox
        Tag = 3
        Left = 86
        Top = 21
        Caption = 'SOCK INC'
        Properties.OnChange = cbLogOptionsChange
        State = cbsChecked
        TabOrder = 0
        Transparent = True
        Width = 81
      end
      object cbSockOut: TcxCheckBox
        Tag = 4
        Left = 166
        Top = 21
        Caption = 'SOCK OUT'
        Properties.OnChange = cbLogOptionsChange
        State = cbsChecked
        TabOrder = 1
        Transparent = True
        Width = 81
      end
      object cbNetInc: TcxCheckBox
        Tag = 5
        Left = 6
        Top = 36
        Caption = 'NET INC'
        Properties.OnChange = cbLogOptionsChange
        State = cbsChecked
        TabOrder = 2
        Transparent = True
        Width = 81
      end
      object cbNetOut: TcxCheckBox
        Tag = 6
        Left = 86
        Top = 36
        Caption = 'NET OUT'
        Properties.OnChange = cbLogOptionsChange
        State = cbsChecked
        TabOrder = 3
        Transparent = True
        Width = 81
      end
      object cbApp: TcxCheckBox
        Tag = 1
        Left = 86
        Top = 6
        Caption = 'APP'
        Properties.OnChange = cbLogOptionsChange
        State = cbsChecked
        TabOrder = 4
        Transparent = True
        Width = 81
      end
      object cbException: TcxCheckBox
        Left = 6
        Top = 6
        Caption = 'EXCEPTION'
        Properties.OnChange = cbLogOptionsChange
        State = cbsChecked
        TabOrder = 5
        Transparent = True
        Width = 81
      end
      object cbForm: TcxCheckBox
        Tag = 7
        Left = 6
        Top = 51
        Caption = 'FORM'
        ParentFont = False
        Properties.OnChange = cbLogOptionsChange
        TabOrder = 6
        Transparent = True
        Width = 81
      end
      object cbSocket: TcxCheckBox
        Tag = 2
        Left = 6
        Top = 21
        Caption = 'SOCK'
        Properties.OnChange = cbLogOptionsChange
        State = cbsChecked
        TabOrder = 7
        Transparent = True
        Width = 81
      end
    end
    object reLog: TRichEdit
      Left = 0
      Top = 0
      Width = 523
      Height = 278
      Align = alClient
      BorderStyle = bsNone
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      HideSelection = False
      HideScrollBars = False
      ParentFont = False
      PopupMenu = pmLog
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
    end
  end
  object alDebug: TActionList
    Left = 72
    Top = 32
    object acClearLog: TAction
      Caption = 'Clear'
      OnExecute = acClearLogExecute
    end
    object acSaveLog: TAction
      Caption = 'Save'
      OnExecute = acSaveLogExecute
    end
    object acCopyLogSelection: TAction
      Caption = 'Copy'
      OnExecute = acCopyLogSelectionExecute
    end
    object acWordWrap: TAction
      Caption = 'Word Wrap'
      OnExecute = acWordWrapExecute
    end
  end
  object SaveDialog: TSaveDialog
    Filter = 'Rich Text File (*.rtf)|*.rtf|Text File (*.txt)|*.txt'
    Left = 136
    Top = 32
  end
  object pmLog: TPopupMenu
    Left = 200
    Top = 32
    object pmiLogSave: TMenuItem
      Action = acSaveLog
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object pmiLogClear: TMenuItem
      Action = acClearLog
    end
    object pmiLogCopy: TMenuItem
      Action = acCopyLogSelection
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object pmiLogWordWrap: TMenuItem
      Action = acWordWrap
    end
  end
  object tiAppInfoRefresh: TTimer
    Interval = 500
    OnTimer = tiAppInfoRefreshTimer
    Left = 68
    Top = 88
  end
end
