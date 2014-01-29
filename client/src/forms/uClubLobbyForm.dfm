object frmClubLobby: TfrmClubLobby
  Left = 0
  Top = 0
  Caption = 'Lobby'
  ClientHeight = 511
  ClientWidth = 581
  Color = clBlack
  Constraints.MinHeight = 410
  Constraints.MinWidth = 589
  Ctl3D = False
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    581
    511)
  PixelsPerInch = 96
  TextHeight = 14
  object lbsHeader: TcxLabel
    Left = 0
    Top = 0
    Align = alTop
    AutoSize = False
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -35
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.Font.Quality = fqAntialiased
    Style.TextColor = clWhite
    Style.IsFontAssigned = True
    Properties.Alignment.Horz = taCenter
    Properties.Alignment.Vert = taVCenter
    Transparent = True
    Height = 80
    Width = 581
    AnchorX = 291
    AnchorY = 40
  end
  object lbsSubheader: TcxLabel
    Left = 0
    Top = 80
    Align = alTop
    AutoSize = False
    ParentFont = False
    Style.Font.Charset = ANSI_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -13
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.Font.Quality = fqAntialiased
    Style.TextColor = clWhite
    Style.IsFontAssigned = True
    Properties.Alignment.Horz = taCenter
    Properties.Alignment.Vert = taVCenter
    Transparent = True
    Height = 24
    Width = 581
    AnchorX = 291
    AnchorY = 92
  end
  object btClubHome: TcxButton
    Left = 5
    Top = 121
    Width = 125
    Height = 32
    Anchors = [akTop]
    Caption = 'Club Home'
    Colors.PressedText = 15461355
    LookAndFeel.SkinName = 'ChipUpDarkTabsStyle'
    SpeedButtonOptions.GroupIndex = 1
    SpeedButtonOptions.CanBeFocused = False
    SpeedButtonOptions.Down = True
    TabOrder = 2
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = btClubHomeClick
  end
  object btTables: TcxButton
    Left = 132
    Top = 121
    Width = 125
    Height = 32
    Anchors = [akTop]
    Caption = 'Tables'
    Colors.PressedText = 15461355
    LookAndFeel.SkinName = 'ChipUpDarkTabsStyle'
    SpeedButtonOptions.GroupIndex = 1
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 3
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = btTablesClick
  end
  object pcTabs: TcxPageControl
    Left = 0
    Top = 156
    Width = 581
    Height = 355
    Align = alBottom
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 4
    Properties.ActivePage = tsTables
    Properties.CustomButtons.Buttons = <>
    Properties.HideTabs = True
    ClientRectBottom = 354
    ClientRectLeft = 1
    ClientRectRight = 580
    ClientRectTop = 1
    object tsClubHome: TcxTabSheet
      Caption = 'tsClubHome'
      ImageIndex = 0
      DesignSize = (
        579
        353)
      object gbClubSettings: TcxGroupBox
        Left = 332
        Top = -1
        Anchors = [akTop, akRight, akBottom]
        Caption = 'Club Settings'
        TabOrder = 0
        Height = 351
        Width = 244
        object Bevel1: TdxBevel
          Left = 13
          Top = 59
          Width = 218
          Height = 1
        end
        object btCloseClub: TcxButton
          Left = 10
          Top = 67
          Width = 224
          Height = 28
          Action = acCloseClub
          SpeedButtonOptions.CanBeFocused = False
          TabOrder = 0
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
        end
        object btChangeClubDetails: TcxButton
          Left = 10
          Top = 23
          Width = 224
          Height = 28
          Action = acShowClubChangeDetailsForm
          Caption = 'Change club details...'
          SpeedButtonOptions.CanBeFocused = False
          TabOrder = 1
        end
        object btLeaveClub: TcxButton
          Left = 10
          Top = 23
          Width = 224
          Height = 28
          Action = acLeaveClub
          SpeedButtonOptions.CanBeFocused = False
          TabOrder = 2
          Visible = False
        end
      end
      object gbPlayers: TcxGroupBox
        Left = 4
        Top = -1
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'Players'
        TabOrder = 1
        DesignSize = (
          323
          345)
        Height = 351
        Width = 323
        object gridPlayersList: TcxGrid
          Left = 3
          Top = 16
          Width = 317
          Height = 252
          Align = alTop
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = cxcbsNone
          TabOrder = 0
          object gridPlayersListTable: TcxGridTableView
            Navigator.Buttons.CustomButtons = <>
            OnFocusedRecordChanged = gridPlayersListTableFocusedRecordChanged
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
            OptionsView.NoDataToDisplayInfoText = ' '
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object gridPlayersListId: TcxGridColumn
              Caption = 'Id'
              DataBinding.ValueType = 'Variant'
              PropertiesClassName = 'TcxBlobEditProperties'
              Properties.BlobEditKind = bekMemo
              Visible = False
            end
            object gridPlayersListName: TcxGridColumn
              Caption = 'Name'
              PropertiesClassName = 'TcxTextEditProperties'
              HeaderAlignmentHorz = taCenter
              Options.Editing = False
              SortIndex = 0
              SortOrder = soAscending
              Width = 179
            end
            object gridPlayersListBalance: TcxGridColumn
              Caption = 'Balance'
              PropertiesClassName = 'TcxSpinEditProperties'
              Properties.Alignment.Horz = taRightJustify
              HeaderAlignmentHorz = taCenter
              Width = 71
            end
            object gridPlayersListStatus: TcxGridColumn
              Caption = 'Status'
              PropertiesClassName = 'TcxTextEditProperties'
              Properties.Alignment.Horz = taCenter
              HeaderAlignmentHorz = taCenter
              Width = 66
            end
          end
          object gridPlayersListLevel: TcxGridLevel
            GridView = gridPlayersListTable
          end
        end
        object btGiveChips: TcxButton
          Left = 8
          Top = 256
          Width = 98
          Height = 28
          Action = acGiveChips
          Anchors = [akLeft, akBottom]
          SpeedButtonOptions.CanBeFocused = False
          TabOrder = 1
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
        end
        object btGiveOwnership: TcxButton
          Left = 112
          Top = 256
          Width = 98
          Height = 28
          Action = acGiveOwnership
          Anchors = [akLeft, akBottom]
          SpeedButtonOptions.CanBeFocused = False
          TabOrder = 2
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
        end
        object btRemovePlayerFromClub: TcxButton
          Left = 216
          Top = 256
          Width = 98
          Height = 28
          Action = acRemovePlayer
          Anchors = [akLeft, akBottom]
          SpeedButtonOptions.CanBeFocused = False
          TabOrder = 3
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
        end
        object btSuspendUnsuspend: TcxButton
          Left = 8
          Top = 222
          Width = 98
          Height = 28
          Action = acSuspendPlayer
          Anchors = [akLeft, akBottom]
          SpeedButtonOptions.CanBeFocused = False
          TabOrder = 4
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
        end
      end
    end
    object tsTables: TcxTabSheet
      Caption = 'tsTables'
      ImageIndex = 1
      DesignSize = (
        579
        353)
      object gbTables: TcxGroupBox
        Left = 4
        Top = -1
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'Tables'
        TabOrder = 0
        DesignSize = (
          572
          345)
        Height = 351
        Width = 572
        object gridGames: TcxGrid
          Left = 3
          Top = 16
          Width = 566
          Height = 227
          Align = alTop
          Anchors = [akLeft, akTop, akRight, akBottom]
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = cxcbsNone
          TabOrder = 0
          object gridGamesTable: TcxGridTableView
            Navigator.Buttons.CustomButtons = <>
            OnCellDblClick = gridGamesTableCellDblClick
            OnFocusedRecordChanged = gridGamesTableFocusedRecordChanged
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
            OptionsView.NoDataToDisplayInfoText = ' '
            OptionsView.ColumnAutoWidth = True
            OptionsView.GroupByBox = False
            object gridGamesId: TcxGridColumn
              DataBinding.ValueType = 'Variant'
              PropertiesClassName = 'TcxBlobEditProperties'
              Properties.BlobEditKind = bekMemo
              Visible = False
            end
            object gridGamesName: TcxGridColumn
              Caption = 'Name'
              PropertiesClassName = 'TcxTextEditProperties'
              HeaderAlignmentHorz = taCenter
              Options.Editing = False
              SortIndex = 0
              SortOrder = soAscending
              Width = 287
            end
            object gridGamesType: TcxGridColumn
              Caption = 'Type'
              PropertiesClassName = 'TcxTextEditProperties'
              Properties.Alignment.Horz = taCenter
              HeaderAlignmentHorz = taCenter
              Width = 117
            end
            object gridGamesBlinds: TcxGridColumn
              Caption = 'Stakes'
              PropertiesClassName = 'TcxTextEditProperties'
              Properties.Alignment.Horz = taCenter
              HeaderAlignmentHorz = taCenter
              Width = 98
            end
            object gridGamesSeats: TcxGridColumn
              Caption = 'Seats'
              PropertiesClassName = 'TcxSpinEditProperties'
              Properties.Alignment.Horz = taCenter
              HeaderAlignmentHorz = taCenter
              Width = 64
            end
          end
          object gridGamesLevel: TcxGridLevel
            GridView = gridGamesTable
          end
        end
        object btNewGame: TcxButton
          Left = 8
          Top = 256
          Width = 98
          Height = 28
          Action = acShowCreateGameForm
          Anchors = [akLeft, akBottom]
          SpeedButtonOptions.CanBeFocused = False
          TabOrder = 1
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
        end
        object btDeleteGame: TcxButton
          Left = 216
          Top = 256
          Width = 98
          Height = 28
          Action = acDeleteGame
          Anchors = [akLeft, akBottom]
          SpeedButtonOptions.CanBeFocused = False
          TabOrder = 2
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
        end
        object btEditGame: TcxButton
          Left = 112
          Top = 256
          Width = 98
          Height = 28
          Action = acShowEditGameForm
          Anchors = [akLeft, akBottom]
          SpeedButtonOptions.CanBeFocused = False
          TabOrder = 3
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = []
          ParentFont = False
        end
      end
    end
  end
  object alManageClubs: TActionList
    Left = 48
    Top = 72
    object acRemovePlayer: TAction
      Caption = 'Remove'
      Enabled = False
      OnExecute = acRemovePlayerExecute
    end
    object acGiveOwnership: TAction
      Caption = 'Give Ownership'
      Enabled = False
      OnExecute = acGiveOwnershipExecute
    end
    object acShowClubChangeDetailsForm: TAction
      Caption = 'Change club details'
      OnExecute = acShowClubChangeDetailsFormExecute
    end
    object acCloseClub: TAction
      Caption = 'Close Club...'
      OnExecute = acCloseClubExecute
    end
    object acGiveChips: TAction
      Caption = 'Give Chips...'
      Enabled = False
      OnExecute = acGiveChipsExecute
    end
    object acShowCreateGameForm: TAction
      Caption = 'Create a Table...'
      OnExecute = acShowCreateGameFormExecute
    end
    object acDeleteGame: TAction
      Caption = 'Delete Table'
      Enabled = False
      OnExecute = acDeleteGameExecute
    end
    object acShowEditGameForm: TAction
      Caption = 'Edit Table...'
      Enabled = False
      OnExecute = acShowEditGameFormExecute
    end
    object acSuspendPlayer: TAction
      Caption = 'Suspend'
      Enabled = False
      OnExecute = acSuspendPlayerExecute
    end
    object acReinstatePlayer: TAction
      Caption = 'Reinstate'
      Enabled = False
      OnExecute = acReinstatePlayerExecute
    end
    object acLeaveClub: TAction
      Caption = 'Leave Club'
      OnExecute = acLeaveClubExecute
    end
  end
end
