object frmSubscriptions: TfrmSubscriptions
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Select a Plan'
  ClientHeight = 155
  ClientWidth = 401
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 401
    Height = 79
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object cxButton1: TcxButton
      Left = 18
      Top = 30
      Width = 117
      Height = 37
      Caption = 'NORMAL'
      LookAndFeel.SkinName = 'ChipUpPokerDarkStyle_MainFormBigButtons'
      SpeedButtonOptions.GroupIndex = 1
      SpeedButtonOptions.CanBeFocused = False
      SpeedButtonOptions.Down = True
      TabOrder = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cxButton2: TcxButton
      Left = 141
      Top = 30
      Width = 117
      Height = 37
      Caption = 'BASIC'
      LookAndFeel.SkinName = 'ChipUpPokerDarkStyle_MainFormBigButtons'
      SpeedButtonOptions.GroupIndex = 1
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cxButton3: TcxButton
      Left = 264
      Top = 30
      Width = 117
      Height = 37
      Caption = 'SUPER'
      LookAndFeel.SkinName = 'ChipUpPokerDarkStyle_MainFormBigButtons'
      SpeedButtonOptions.GroupIndex = 1
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 2
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cxLabel1: TcxLabel
      Left = 0
      Top = 0
      Align = alTop
      AutoSize = False
      Caption = 'Subscription plan'
      Properties.Alignment.Horz = taCenter
      Properties.Alignment.Vert = taBottomJustify
      Transparent = True
      Height = 23
      Width = 401
      AnchorX = 201
      AnchorY = 23
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 79
    Width = 401
    Height = 76
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object cxButton4: TcxButton
      Left = 78
      Top = 29
      Width = 117
      Height = 37
      Caption = 'CREDIT CARD'
      LookAndFeel.SkinName = 'ChipUpPokerDarkStyle_MainFormBigButtons'
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cxButton5: TcxButton
      Left = 201
      Top = 29
      Width = 117
      Height = 37
      Action = acPayPal
      LookAndFeel.SkinName = 'ChipUpPokerDarkStyle_MainFormBigButtons'
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 1
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cxLabel2: TcxLabel
      Left = 0
      Top = 0
      Align = alTop
      AutoSize = False
      Caption = 'Payment method'
      Properties.Alignment.Horz = taCenter
      Properties.Alignment.Vert = taBottomJustify
      Transparent = True
      Height = 23
      Width = 401
      AnchorX = 201
      AnchorY = 23
    end
  end
  object alSubscriptionForm: TActionList
    Left = 48
    Top = 68
    object acPayPal: TAction
      Caption = 'PAYPAL'
      OnExecute = acPayPalExecute
    end
  end
end
