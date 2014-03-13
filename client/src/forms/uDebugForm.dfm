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
      object lbsCalbackSets: TLabel
        Left = 355
        Top = 40
        Width = 67
        Height = 14
        Anchors = [akTop, akRight]
        Caption = 'Callback sets:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object lbvCallbackSets: TLabel
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
      object lbsSocketState: TLabel
        Left = 355
        Top = 56
        Width = 63
        Height = 14
        Anchors = [akTop, akRight]
        Caption = 'Socket state:'
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
      end
      object lbvSocketState: TLabel
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
      object btPause: TcxButton
        Left = 8
        Top = 10
        Width = 93
        Height = 31
        Caption = 'PAUSE'
        Colors.PressedText = clRed
        SpeedButtonOptions.GroupIndex = 1
        SpeedButtonOptions.CanBeFocused = False
        SpeedButtonOptions.AllowAllUp = True
        TabOrder = 0
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = btPauseClick
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
