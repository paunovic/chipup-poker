object frmDebug: TfrmDebug
  Left = 0
  Top = 0
  Caption = 'Debug'
  ClientHeight = 378
  ClientWidth = 675
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
    Width = 675
    Height = 378
    Align = alClient
    BevelOuter = bvNone
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
    object paInfo: TPanel
      Left = 0
      Top = 303
      Width = 675
      Height = 75
      Align = alBottom
      BevelOuter = bvNone
      Ctl3D = False
      DoubleBuffered = True
      ParentBackground = False
      ParentCtl3D = False
      ParentDoubleBuffered = False
      TabOrder = 0
      DesignSize = (
        675
        75)
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
      end
      object lbsThreads: TcxLabel
        Left = 536
        Top = 6
        Anchors = [akRight, akBottom]
        Caption = 'Threads:'
        Transparent = True
      end
      object lbsMemoryUsage: TcxLabel
        Left = 536
        Top = 22
        Anchors = [akRight, akBottom]
        Caption = 'Memory usage:'
        Transparent = True
      end
      object lbsSocketState: TcxLabel
        Left = 536
        Top = 54
        Anchors = [akRight, akBottom]
        Caption = 'Socket state:'
        Transparent = True
      end
      object lbsCalbackSets: TcxLabel
        Left = 536
        Top = 38
        Anchors = [akRight, akBottom]
        Caption = 'Callback sets:'
        Transparent = True
      end
      object lbvThreads: TcxLabel
        Left = 616
        Top = 6
        Anchors = [akRight, akBottom]
        Caption = '00'
        Style.TextStyle = [fsBold]
        Transparent = True
      end
      object lbvMemoryUsage: TcxLabel
        Left = 616
        Top = 22
        Anchors = [akRight, akBottom]
        Caption = '00000kb'
        Style.TextStyle = [fsBold]
        Transparent = True
      end
      object lbvCallbackSets: TcxLabel
        Left = 616
        Top = 38
        Anchors = [akRight, akBottom]
        Caption = '0'
        Style.TextStyle = [fsBold]
        Transparent = True
      end
      object lbvSocketState: TcxLabel
        Left = 616
        Top = 54
        Anchors = [akRight, akBottom]
        Caption = '0'
        Style.TextStyle = [fsBold]
        Transparent = True
      end
    end
    object reLog: TcxRichEdit
      Left = 0
      Top = 0
      Align = alClient
      ParentFont = False
      PopupMenu = pmLog
      Properties.AutoURLDetect = True
      Properties.HideScrollBars = False
      Properties.HideSelection = False
      Properties.ReadOnly = True
      Properties.ScrollBars = ssBoth
      Properties.WantReturns = False
      Properties.WordWrap = False
      Lines.Strings = (
        'reLog')
      Style.Edges = []
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -11
      Style.Font.Name = 'Consolas'
      Style.Font.Style = []
      Style.TransparentBorder = True
      Style.IsFontAssigned = True
      TabOrder = 1
      Height = 303
      Width = 675
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
