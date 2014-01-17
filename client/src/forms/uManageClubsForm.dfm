object frmManageClubs: TfrmManageClubs
  Left = 0
  Top = 0
  Caption = 'Manage Your Clubs'
  ClientHeight = 447
  ClientWidth = 1115
  Color = clWindow
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
    1115
    447)
  PixelsPerInch = 96
  TextHeight = 14
  object gbPlayers: TcxGroupBox
    Left = 423
    Top = 8
    Anchors = [akLeft, akTop, akBottom]
    Caption = 'Players'
    TabOrder = 0
    DesignSize = (
      320
      425)
    Height = 431
    Width = 320
    object gridPlayersList: TcxGrid
      Left = 3
      Top = 16
      Width = 314
      Height = 250
      Align = alTop
      Anchors = [akLeft, akTop, akRight, akBottom]
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
          Width = 198
        end
        object gridPlayersListBalance: TcxGridColumn
          Caption = 'Balance'
          PropertiesClassName = 'TcxSpinEditProperties'
          Properties.Alignment.Horz = taRightJustify
          HeaderAlignmentHorz = taCenter
          Width = 73
        end
      end
      object gridPlayersListLevel: TcxGridLevel
        GridView = gridPlayersListTable
      end
    end
    object btGiveOwnership: TcxButton
      Left = 113
      Top = 272
      Width = 95
      Height = 28
      Action = acGiveOwnership
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
    object btRemovePlayerFromClub: TcxButton
      Left = 214
      Top = 272
      Width = 95
      Height = 28
      Action = acKickPlayer
      Anchors = [akLeft, akBottom]
      Caption = 'Kick'
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 2
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object btGiveChips: TcxButton
      Left = 12
      Top = 272
      Width = 95
      Height = 28
      Action = acGiveChips
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
  object gbClubs: TcxGroupBox
    Left = 8
    Top = 8
    Anchors = [akLeft, akTop, akBottom]
    Caption = 'Clubs'
    TabOrder = 1
    DesignSize = (
      409
      425)
    Height = 431
    Width = 409
    object gridClubs: TcxGrid
      Left = 3
      Top = 16
      Width = 403
      Height = 365
      Align = alTop
      BorderStyle = cxcbsNone
      TabOrder = 0
      object gridClubsTable: TcxGridTableView
        Navigator.Buttons.CustomButtons = <>
        OnFocusedRecordChanged = gridClubsTableFocusedRecordChanged
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
        object gridClubsId: TcxGridColumn
          Caption = 'ID'
          DataBinding.ValueType = 'Integer'
          PropertiesClassName = 'TcxSpinEditProperties'
          HeaderAlignmentHorz = taCenter
          SortIndex = 0
          SortOrder = soAscending
          Width = 59
        end
        object gridClubsClubName: TcxGridColumn
          Caption = 'Name'
          PropertiesClassName = 'TcxTextEditProperties'
          HeaderAlignmentHorz = taCenter
          Options.Editing = False
          Width = 228
        end
        object gridClubsType: TcxGridColumn
          Caption = 'Type'
          PropertiesClassName = 'TcxTextEditProperties'
          HeaderAlignmentHorz = taCenter
          Width = 71
        end
        object gridClubsBalance: TcxGridColumn
          Caption = 'Balance'
          PropertiesClassName = 'TcxSpinEditProperties'
          Properties.SpinButtons.Visible = False
          HeaderAlignmentHorz = taCenter
          Width = 81
        end
      end
      object gridClubsLevel: TcxGridLevel
        GridView = gridClubsTable
      end
    end
    object btChangeClubType: TcxButton
      Left = 11
      Top = 272
      Width = 117
      Height = 28
      Action = acShowClubChangeDetailsForm
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
    object btDisbandClub: TcxButton
      Left = 134
      Top = 272
      Width = 117
      Height = 28
      Action = acDisbandClub
      Anchors = [akLeft, akBottom]
      Colors.DefaultText = clRed
      SpeedButtonOptions.CanBeFocused = False
      TabOrder = 2
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
  end
  object gbGames: TcxGroupBox
    Left = 749
    Top = 8
    Anchors = [akLeft, akTop, akBottom]
    Caption = 'Games'
    TabOrder = 2
    DesignSize = (
      358
      425)
    Height = 431
    Width = 358
    object gridGames: TcxGrid
      Left = 3
      Top = 16
      Width = 352
      Height = 250
      Align = alTop
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = cxcbsNone
      TabOrder = 0
      object gridGamesTable: TcxGridTableView
        Navigator.Buttons.CustomButtons = <>
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
          Width = 162
        end
        object gridGamesType: TcxGridColumn
          Caption = 'Type'
          PropertiesClassName = 'TcxTextEditProperties'
          HeaderAlignmentHorz = taCenter
          Width = 76
        end
        object gridGamesBlinds: TcxGridColumn
          Caption = 'Blinds'
          PropertiesClassName = 'TcxTextEditProperties'
          HeaderAlignmentHorz = taCenter
          Width = 69
        end
        object gridGamesSeats: TcxGridColumn
          Caption = 'Seats'
          PropertiesClassName = 'TcxSpinEditProperties'
          HeaderAlignmentHorz = taCenter
          Width = 45
        end
      end
      object gridGamesLevel: TcxGridLevel
        GridView = gridGamesTable
      end
    end
    object btNewGame: TcxButton
      Left = 12
      Top = 272
      Width = 95
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
      Left = 214
      Top = 272
      Width = 95
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
      Left = 113
      Top = 272
      Width = 95
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
  object alManageClubs: TActionList
    Left = 48
    Top = 72
    object acKickPlayer: TAction
      Caption = 'Remove from the club'
      Enabled = False
      OnExecute = acKickPlayerExecute
    end
    object acGiveOwnership: TAction
      Caption = 'Give ownership'
      Enabled = False
      OnExecute = acGiveOwnershipExecute
    end
    object acShowClubChangeDetailsForm: TAction
      Caption = 'Change club details'
      Enabled = False
      OnExecute = acShowClubChangeDetailsFormExecute
    end
    object acDisbandClub: TAction
      Caption = 'Disband club'
      Enabled = False
      OnExecute = acDisbandClubExecute
    end
    object acGiveChips: TAction
      Caption = 'Give chips'
      Enabled = False
      OnExecute = acGiveChipsExecute
    end
    object acShowCreateGameForm: TAction
      Caption = 'New game'
      Enabled = False
      OnExecute = acShowCreateGameFormExecute
    end
    object acDeleteGame: TAction
      Caption = 'Delete game'
      Enabled = False
      OnExecute = acDeleteGameExecute
    end
    object acShowEditGameForm: TAction
      Caption = 'Edit game'
      Enabled = False
      OnExecute = acShowEditGameFormExecute
    end
  end
end
