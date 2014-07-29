object frmTournamentLobby: TfrmTournamentLobby
  Left = 0
  Top = 0
  Caption = 'Tournament Lobby'
  ClientHeight = 591
  ClientWidth = 875
  Color = clWindow
  Ctl3D = False
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
  DesignSize = (
    875
    591)
  PixelsPerInch = 96
  TextHeight = 13
  object gridPlayers: TcxGrid
    Left = 8
    Top = 132
    Width = 305
    Height = 345
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 0
    object gridPlayersTable: TcxGridTableView
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnFiltering = False
      OptionsCustomize.ColumnGrouping = False
      OptionsCustomize.ColumnHidingOnGrouping = False
      OptionsCustomize.ColumnMoving = False
      OptionsData.Deleting = False
      OptionsData.DeletingConfirmation = False
      OptionsData.Editing = False
      OptionsData.Inserting = False
      OptionsSelection.CellSelect = False
      OptionsView.FocusRect = False
      OptionsView.NoDataToDisplayInfoText = 'Retrieving data...'
      OptionsView.ColumnAutoWidth = True
      OptionsView.GroupByBox = False
      Styles.Inactive = dmMain.styleInactiveCell
      Styles.OnGetContentStyle = gridPlayersTableStylesGetContentStyle
      object gridPlayersMongoId: TcxGridColumn
        Caption = 'Club ID'
        DataBinding.ValueType = 'Variant'
        PropertiesClassName = 'TcxBlobEditProperties'
        Properties.BlobEditKind = bekMemo
        Visible = False
        HeaderAlignmentHorz = taCenter
        Width = 41
      end
      object gridPlayersName: TcxGridColumn
        Caption = 'Player'
        PropertiesClassName = 'TcxTextEditProperties'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        SortIndex = 0
        SortOrder = soAscending
        Width = 221
      end
      object gridPlayersChips: TcxGridColumn
        Caption = 'Chips'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.DisplayFormat = ',0.##;(,0.##)'
        Properties.EditFormat = '$,0.##;($,0.##)'
        Properties.UseDisplayFormatWhenEditing = True
        Properties.UseThousandSeparator = True
        HeaderAlignmentHorz = taCenter
        Width = 82
      end
    end
    object gridPlayersLevel: TcxGridLevel
      GridView = gridPlayersTable
    end
  end
  object btTournamentRegister: TcxButton
    Left = 682
    Top = 58
    Width = 143
    Height = 35
    Margin = 15
    Action = acRegister
    Anchors = [akLeft, akBottom]
    Colors.NormalText = 48896
    Colors.HotText = 58880
    Colors.PressedText = 48896
    Colors.DisabledText = 7631988
    Enabled = False
    LookAndFeel.SkinName = 'ChipUpPokerDarkStyle_MainFormButtons'
    OptionsImage.Margin = 15
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 51712
    Font.Height = -11
    Font.Name = 'Sintony'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object StyleRepository: TcxStyleRepository
    Left = 468
    Top = 220
    PixelsPerInch = 96
    object stylePlayersSelf: TcxStyle
      AssignedValues = [svColor]
      Color = 20736
    end
    object stylePlayersOther: TcxStyle
    end
  end
  object alTournamentLobby: TActionList
    State = asSuspended
    Left = 588
    Top = 220
    object acRegister: TAction
      Caption = 'REGISTER'
      OnExecute = acRegisterExecute
    end
    object acUnregister: TAction
      Caption = 'UNREGISTER'
      OnExecute = acUnregisterExecute
    end
  end
end
