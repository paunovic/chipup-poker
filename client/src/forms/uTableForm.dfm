object frmTable: TfrmTable
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Table'
  ClientHeight = 456
  ClientWidth = 600
  Color = clWindow
  Constraints.MaxHeight = 1080
  Constraints.MaxWidth = 1538
  Constraints.MinHeight = 427
  Constraints.MinWidth = 608
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 14
  object PaintBox: TPaintBox
    Left = 0
    Top = 0
    Width = 600
    Height = 354
    Align = alClient
    OnPaint = PaintBoxPaint
    ExplicitWidth = 570
    ExplicitHeight = 380
  end
  object paBottom: TPanel
    Left = 0
    Top = 354
    Width = 600
    Height = 102
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object paChat: TPanel
      Left = 0
      Top = 0
      Width = 290
      Height = 102
      Align = alLeft
      BevelOuter = bvNone
      Color = clBlack
      Padding.Top = 1
      Padding.Right = 1
      ParentBackground = False
      TabOrder = 0
      object edChat: TcxTextEdit
        Left = 0
        Top = 1
        Align = alTop
        Style.Edges = []
        TabOrder = 0
        OnKeyDown = edChatKeyDown
        Width = 289
      end
      object reChat: TRichEdit
        Left = 0
        Top = 19
        Width = 289
        Height = 83
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        Color = 3552822
        Font.Charset = ANSI_CHARSET
        Font.Color = clSilver
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
    object btSitStandUp: TcxButton
      Left = 396
      Top = 38
      Width = 97
      Height = 34
      Action = acShowTableSitForm
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 1
    end
    object lbsInfo: TcxLabel
      Left = 296
      Top = 6
      Caption = 'lbsInfo'
      Transparent = True
    end
  end
  object alTable: TActionList
    Left = 28
    Top = 16
    object acShowTableSitForm: TAction
      Caption = 'Sit'
      OnExecute = acShowTableSitFormExecute
    end
    object acStandUp: TAction
      Caption = 'Stand Up'
      OnExecute = acStandUpExecute
    end
  end
end
