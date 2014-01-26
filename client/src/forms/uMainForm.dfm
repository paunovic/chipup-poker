object frmChipUpMain: TfrmChipUpMain
  Left = 0
  Top = 0
  ClientHeight = 618
  ClientWidth = 973
  Color = clWindow
  Constraints.MinHeight = 600
  Constraints.MinWidth = 800
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnDestroy = FormDestroy
  DesignSize = (
    973
    618)
  PixelsPerInch = 96
  TextHeight = 14
  object gridJoinedClubs: TcxGrid
    Left = 8
    Top = 184
    Width = 290
    Height = 426
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 0
    ExplicitHeight = 383
    object gridJoinedClubsTable: TcxGridTableView
      Navigator.Buttons.CustomButtons = <>
      OnCellDblClick = gridJoinedClubsTableCellDblClick
      OnFocusedRecordChanged = gridJoinedClubsTableFocusedRecordChanged
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
      object gridJoinedClubsId: TcxGridColumn
        Caption = 'Club ID'
        PropertiesClassName = 'TcxSpinEditProperties'
        HeaderAlignmentHorz = taCenter
        Width = 65
      end
      object gridJoinedClubsClubName: TcxGridColumn
        Caption = 'Club name'
        PropertiesClassName = 'TcxTextEditProperties'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Width = 161
      end
      object gridJoinedClubsStatus: TcxGridColumn
        Caption = 'Status'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taCenter
        HeaderAlignmentHorz = taCenter
        SortIndex = 0
        SortOrder = soAscending
        Width = 62
      end
    end
    object gridJoinedClubsLevel: TcxGridLevel
      GridView = gridJoinedClubsTable
    end
  end
  object btCreateClub: TcxButton
    Left = 304
    Top = 139
    Width = 157
    Height = 40
    Action = acShowCreateClubForm
    Caption = 'CREATE CLUB'
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btJoinClub: TcxButton
    Left = 467
    Top = 139
    Width = 157
    Height = 40
    Action = acShowJoinClubForm
    Caption = 'JOIN CLUB'
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object gridGames: TcxGrid
    Left = 304
    Top = 184
    Width = 661
    Height = 426
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
    ExplicitWidth = 628
    ExplicitHeight = 383
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
        Caption = 'Id'
        DataBinding.ValueType = 'Variant'
        PropertiesClassName = 'TcxBlobEditProperties'
        Properties.BlobEditKind = bekMemo
        Visible = False
      end
      object gridGamesName: TcxGridColumn
        Caption = 'Game Name'
        PropertiesClassName = 'TcxTextEditProperties'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        SortIndex = 0
        SortOrder = soDescending
        Width = 274
      end
      object gridGamesType: TcxGridColumn
        Caption = 'Type'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taCenter
        HeaderAlignmentHorz = taCenter
        Width = 108
      end
      object gridGamesBlinds: TcxGridColumn
        Caption = 'Blinds'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taCenter
        HeaderAlignmentHorz = taCenter
        Width = 52
      end
      object gridGamesPlayers: TcxGridColumn
        Caption = 'Players'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taCenter
        HeaderAlignmentHorz = taCenter
        Width = 62
      end
      object gridGamesStatus: TcxGridColumn
        Caption = 'Status'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taCenter
        HeaderAlignmentHorz = taCenter
        Width = 130
      end
    end
    object gridGamesLevel: TcxGridLevel
      GridView = gridGamesTable
    end
  end
  object btOpenClubLobby: TcxButton
    Left = 8
    Top = 139
    Width = 290
    Height = 40
    Action = acOpenClubLobby
    Caption = 'OPEN CLUB LOBBY'
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 4
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object cxLabel1: TcxLabel
    Left = 32
    Top = 39
    Caption = 'LOGO AND DESIGN'
    ParentFont = False
    Style.Font.Charset = DEFAULT_CHARSET
    Style.Font.Color = clWindowText
    Style.Font.Height = -40
    Style.Font.Name = 'Arial'
    Style.Font.Style = [fsBold]
    Style.IsFontAssigned = True
    Transparent = True
  end
  object alMainForm: TActionList
    Left = 552
    Top = 24
    object acLogout: TAction
      Caption = 'Logout'
      OnExecute = acLogoutExecute
    end
    object acShowCreateClubForm: TAction
      Caption = 'Create a club'
      OnExecute = acShowCreateClubFormExecute
    end
    object acShowJoinClubForm: TAction
      Caption = 'Join club'
      OnExecute = acShowJoinClubFormExecute
    end
    object acBuyChips: TAction
      Caption = 'acBuyChips'
      OnExecute = acBuyChipsExecute
    end
    object acShowChangeEMailForm: TAction
      Caption = 'acShowChangeEMailForm'
      OnExecute = acShowChangeEMailFormExecute
    end
    object acShowChangePasswordForm: TAction
      Caption = 'acShowChangePasswordForm'
      OnExecute = acShowChangePasswordFormExecute
    end
    object acShowChangeAvatarForm: TAction
      Caption = 'acShowChangeAvatarForm'
      OnExecute = acShowChangeAvatarFormExecute
    end
    object acShowPublicGamesListForm: TAction
      Caption = 'acShowPublicClubsListForm'
      OnExecute = acShowPublicGamesListFormExecute
    end
    object acShowGameTableForm: TAction
      Caption = 'acShowGameTableForm'
      OnExecute = acShowGameTableFormExecute
    end
    object acOpenClubLobby: TAction
      Caption = 'acOpenClubLobby'
      Enabled = False
      OnExecute = acOpenClubLobbyExecute
    end
  end
  object MainMenu: TMainMenu
    Left = 608
    Top = 24
    object mmiAccount: TMenuItem
      Caption = 'Account'
      object mmiChangeEMail: TMenuItem
        Action = acShowChangeEMailForm
        Caption = 'Change E-mail Address...'
      end
      object mmiChangePassword: TMenuItem
        Action = acShowChangePasswordForm
        Caption = 'Change Password...'
      end
      object mmiChangeAvatar: TMenuItem
        Action = acShowChangeAvatarForm
        Caption = 'Change Avatar...'
      end
      object mmiSeparator1: TMenuItem
        Caption = '-'
      end
      object mmiLogout: TMenuItem
        Action = acLogout
      end
    end
    object mmiCashier: TMenuItem
      Caption = 'Cashier'
      object mmiBuyChips: TMenuItem
        Action = acBuyChips
        Caption = 'Get More Chips...'
      end
    end
    object mmiClubs: TMenuItem
      Caption = 'Clubs'
      object SearchPublicClubs1: TMenuItem
        Action = acShowPublicGamesListForm
        Caption = 'Search Public Clubs...'
      end
    end
    object mmiOptions: TMenuItem
      Caption = 'Options'
    end
  end
  object tiBringToFront: TTimer
    Enabled = False
    Interval = 50
    OnTimer = tiBringToFrontTimer
    Left = 672
    Top = 24
  end
  object SkinController: TdxSkinController
    SkinName = 'Darkroom'
    Left = 552
    Top = 80
  end
end
