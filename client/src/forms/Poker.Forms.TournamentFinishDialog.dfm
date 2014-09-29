object frmTournamentFinishDialog: TfrmTournamentFinishDialog
  Left = 0
  Top = 0
  Caption = 'Tournament Info'
  ClientHeight = 103
  ClientWidth = 304
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  DesignSize = (
    304
    103)
  PixelsPerInch = 96
  TextHeight = 13
  object lbvText: TcxLabel
    Left = 8
    Top = 8
    Anchors = [akLeft, akTop, akRight, akBottom]
    AutoSize = False
    Properties.Alignment.Horz = taCenter
    Properties.Alignment.Vert = taVCenter
    Properties.WordWrap = True
    Transparent = True
    Height = 54
    Width = 288
    AnchorX = 152
    AnchorY = 35
  end
  object btOk: TcxButton
    Left = 221
    Top = 70
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
    ExplicitTop = 80
  end
end
