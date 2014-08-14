object frmTournamentLobby: TfrmTournamentLobby
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Tournament Lobby'
  ClientHeight = 593
  ClientWidth = 877
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
    877
    593)
  PixelsPerInch = 96
  TextHeight = 13
  object gridPlayers: TcxGrid
    Left = 8
    Top = 402
    Width = 391
    Height = 183
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 0
    object gridPlayersTable: TcxGridTableView
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnFiltering = False
      OptionsCustomize.ColumnGrouping = False
      OptionsCustomize.ColumnHidingOnGrouping = False
      OptionsCustomize.ColumnHorzSizing = False
      OptionsCustomize.ColumnMoving = False
      OptionsCustomize.ColumnSorting = False
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
        Width = 221
      end
      object gridPlayersChips: TcxGridColumn
        Caption = 'Chips'
        DataBinding.ValueType = 'Currency'
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
  object gridTables: TcxGrid
    Left = 8
    Top = 151
    Width = 391
    Height = 248
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 1
    object gridTablesTable: TcxGridTableView
      OnCellDblClick = gridTablesTableCellDblClick
      OnFocusedRecordChanged = gridTablesTableFocusedRecordChanged
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnFiltering = False
      OptionsCustomize.ColumnGrouping = False
      OptionsCustomize.ColumnHidingOnGrouping = False
      OptionsCustomize.ColumnHorzSizing = False
      OptionsCustomize.ColumnMoving = False
      OptionsCustomize.ColumnSorting = False
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
      object gridTablesId: TcxGridColumn
        Caption = 'Club ID'
        DataBinding.ValueType = 'Variant'
        PropertiesClassName = 'TcxBlobEditProperties'
        Properties.BlobEditKind = bekMemo
        Visible = False
        HeaderAlignmentHorz = taCenter
        Width = 41
      end
      object gridTablesName: TcxGridColumn
        Caption = 'Table'
        DataBinding.ValueType = 'Integer'
        PropertiesClassName = 'TcxSpinEditProperties'
        Properties.Alignment.Horz = taCenter
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        SortIndex = 0
        SortOrder = soAscending
        Width = 70
      end
      object gridTablesPlayers: TcxGridColumn
        Caption = 'Players'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.Alignment.Horz = taCenter
        Properties.DisplayFormat = ',0.##;(,0.##)'
        Properties.EditFormat = '$,0.##;($,0.##)'
        Properties.UseDisplayFormatWhenEditing = True
        Properties.UseThousandSeparator = True
        HeaderAlignmentHorz = taCenter
        Width = 69
      end
      object gridTablesSmallestStack: TcxGridColumn
        Caption = 'Smallest Stack'
        DataBinding.ValueType = 'Currency'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.DisplayFormat = ',0.##;(,0.##)'
        Properties.EditFormat = '$,0.##;($,0.##)'
        HeaderAlignmentHorz = taCenter
        Width = 60
      end
      object gridTablesAverageStack: TcxGridColumn
        Caption = 'Avg Stack'
        DataBinding.ValueType = 'Currency'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.DisplayFormat = ',0.##;(,0.##)'
        Properties.EditFormat = '$,0.##;($,0.##)'
        HeaderAlignmentHorz = taCenter
        Width = 60
      end
      object gridTablesLargestStack: TcxGridColumn
        Caption = 'Largest Stack'
        DataBinding.ValueType = 'Currency'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.DisplayFormat = ',0.##;(,0.##)'
        Properties.EditFormat = '$,0.##;($,0.##)'
        HeaderAlignmentHorz = taCenter
        Width = 60
      end
    end
    object gridTablesLevel: TcxGridLevel
      GridView = gridTablesTable
    end
  end
  object paHeader: TPanel
    Left = 0
    Top = 0
    Width = 877
    Height = 145
    Align = alTop
    TabOrder = 2
    DesignSize = (
      877
      145)
    object lbsHeader: TcxLabel
      AlignWithMargins = True
      Left = 1
      Top = 6
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      AutoSize = False
      ParentFont = False
      Style.Font.Charset = ANSI_CHARSET
      Style.Font.Color = clWindowText
      Style.Font.Height = -27
      Style.Font.Name = 'Arial'
      Style.Font.Style = [fsBold]
      Style.Font.Quality = fqAntialiased
      Style.TextColor = clWhite
      Style.IsFontAssigned = True
      Properties.Alignment.Horz = taCenter
      Properties.Alignment.Vert = taVCenter
      Transparent = True
      Height = 107
      Width = 875
      AnchorX = 439
      AnchorY = 60
    end
    object btTournamentRegister: TcxButton
      Left = 714
      Top = 16
      Width = 143
      Height = 35
      Margin = 15
      Action = acRegister
      Anchors = [akLeft, akBottom]
      Colors.NormalText = 48896
      Colors.HotText = 58880
      Colors.PressedText = 48896
      Colors.DisabledText = 7631988
      LookAndFeel.SkinName = 'ChipUpPokerDarkStyle_MainFormButtons'
      OptionsImage.Margin = 15
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 51712
      Font.Height = -11
      Font.Name = 'Sintony'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object gridAllPlayers: TcxGrid
    Left = 402
    Top = 151
    Width = 238
    Height = 434
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 3
    object gridAllPlayersTable: TcxGridTableView
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnFiltering = False
      OptionsCustomize.ColumnGrouping = False
      OptionsCustomize.ColumnHidingOnGrouping = False
      OptionsCustomize.ColumnHorzSizing = False
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
      object gridAllPlayersId: TcxGridColumn
        Caption = 'Club ID'
        DataBinding.ValueType = 'Variant'
        PropertiesClassName = 'TcxBlobEditProperties'
        Properties.BlobEditKind = bekMemo
        Visible = False
        HeaderAlignmentHorz = taCenter
        Width = 41
      end
      object gridAllPlayersName: TcxGridColumn
        Caption = 'Player'
        PropertiesClassName = 'TcxTextEditProperties'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Width = 221
      end
      object gridAllPlayersChips: TcxGridColumn
        Caption = 'Chips'
        DataBinding.ValueType = 'Currency'
        PropertiesClassName = 'TcxCurrencyEditProperties'
        Properties.Alignment.Horz = taRightJustify
        Properties.DisplayFormat = ',0.##;(,0.##)'
        Properties.EditFormat = '$,0.##;($,0.##)'
        Properties.UseDisplayFormatWhenEditing = True
        Properties.UseThousandSeparator = True
        HeaderAlignmentHorz = taCenter
        SortIndex = 0
        SortOrder = soDescending
        Width = 82
      end
    end
    object gridAllPlayersLevel: TcxGridLevel
      GridView = gridAllPlayersTable
    end
  end
  object gridBlinds: TcxGrid
    Left = 643
    Top = 151
    Width = 226
    Height = 218
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 4
    object gridBlindsTable: TcxGridTableView
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsCustomize.ColumnFiltering = False
      OptionsCustomize.ColumnGrouping = False
      OptionsCustomize.ColumnHidingOnGrouping = False
      OptionsCustomize.ColumnHorzSizing = False
      OptionsCustomize.ColumnMoving = False
      OptionsCustomize.ColumnSorting = False
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
      object gridBlindsTLevel: TcxGridColumn
        Caption = 'Level'
        DataBinding.ValueType = 'Integer'
        PropertiesClassName = 'TcxSpinEditProperties'
        Properties.Alignment.Horz = taCenter
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Width = 51
      end
      object gridBlindsBlinds: TcxGridColumn
        Caption = 'Blinds'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taCenter
        HeaderAlignmentHorz = taCenter
        Width = 98
      end
      object gridBlindsMinutes: TcxGridColumn
        Caption = 'Minutes'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taCenter
        HeaderAlignmentHorz = taCenter
        Width = 75
      end
    end
    object gridBlindsLevel: TcxGridLevel
      GridView = gridBlindsTable
    end
  end
  object StyleRepository: TcxStyleRepository
    Left = 56
    Top = 60
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
    Left = 176
    Top = 60
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
