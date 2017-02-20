object frmImageCrop: TfrmImageCrop
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Crop Avatar'
  ClientHeight = 478
  ClientWidth = 645
  Color = clWindow
  Constraints.MinHeight = 250
  Constraints.MinWidth = 250
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnPaint = FormPaint
  DesignSize = (
    645
    478)
  PixelsPerInch = 96
  TextHeight = 13
  object btOK: TcxButton
    Left = 445
    Top = 443
    Width = 93
    Height = 27
    Action = acOK
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 0
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 544
    Top = 443
    Width = 93
    Height = 27
    Action = acCancel
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 1
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object PaintBox: TPaintBox32
    AlignWithMargins = True
    Left = 5
    Top = 5
    Width = 635
    Height = 429
    Cursor = crCross
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 44
    Align = alClient
    RepaintMode = rmOptimizer
    TabOrder = 2
    OnMouseDown = PaintBoxMouseDown
    OnMouseMove = PaintBoxMouseMove
    OnMouseUp = PaintBoxMouseUp
  end
  object cxButton1: TcxButton
    Left = 346
    Top = 443
    Width = 93
    Height = 27
    Action = acNoCrop
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
  object ActionList: TActionList
    Left = 48
    Top = 232
    object acOK: TAction
      Caption = 'OK'
      OnExecute = acOKExecute
    end
    object acCancel: TAction
      Caption = 'Cancel'
      OnExecute = acCancelExecute
    end
    object acNoCrop: TAction
      Caption = 'Don'#39't Crop'
      OnExecute = acNoCropExecute
    end
  end
end
