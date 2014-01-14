object frmChipUpMain: TfrmChipUpMain
  Left = 0
  Top = 0
  ClientHeight = 575
  ClientWidth = 940
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  OnDestroy = FormDestroy
  DesignSize = (
    940
    575)
  PixelsPerInch = 96
  TextHeight = 14
  object gridJoinedClubs: TcxGrid
    Left = 8
    Top = 184
    Width = 290
    Height = 383
    Anchors = [akLeft, akBottom]
    TabOrder = 0
    ExplicitTop = 246
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
  object lbUserInfo: TcxLabel
    Left = 748
    Top = 74
    Caption = 'You have 100 tokens'
    Transparent = True
  end
  object btCreateClub: TcxButton
    Left = 304
    Top = 139
    Width = 157
    Height = 40
    Action = acShowCreateClubForm
    Anchors = [akLeft, akBottom]
    Caption = 'CREATE CLUB'
    TabOrder = 2
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
    Anchors = [akLeft, akBottom]
    Caption = 'JOIN CLUB'
    TabOrder = 3
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
    Width = 628
    Height = 383
    Anchors = [akLeft, akBottom]
    TabOrder = 4
    ExplicitTop = 246
    object gridGamesTable: TcxGridTableView
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
      object cxGridColumn1: TcxGridColumn
        Caption = 'Id'
        PropertiesClassName = 'TcxSpinEditProperties'
        Visible = False
      end
      object cxGridColumn2: TcxGridColumn
        Caption = 'Game Name'
        PropertiesClassName = 'TcxTextEditProperties'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        SortIndex = 0
        SortOrder = soDescending
        Width = 344
      end
      object cxGridColumn3: TcxGridColumn
        Caption = 'Type'
        PropertiesClassName = 'TcxTextEditProperties'
        HeaderAlignmentHorz = taCenter
        Width = 49
      end
      object gridGamesTableColumn1: TcxGridColumn
        Caption = 'Blinds'
        HeaderAlignmentHorz = taCenter
        Width = 53
      end
      object gridGamesTableColumn2: TcxGridColumn
        Caption = 'Players'
        HeaderAlignmentHorz = taCenter
        Width = 64
      end
      object gridGamesTableColumn3: TcxGridColumn
        Caption = 'Status'
        HeaderAlignmentHorz = taCenter
        Width = 133
      end
    end
    object gridGamesLevel: TcxGridLevel
      GridView = gridGamesTable
    end
  end
  object btCashier: TcxButton
    Left = 678
    Top = 139
    Width = 254
    Height = 40
    Anchors = [akLeft, akBottom]
    Caption = 'CASHIER'
    Enabled = False
    TabOrder = 5
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = btLeaveClubClick
  end
  object btClubLobby: TcxButton
    Left = 8
    Top = 139
    Width = 290
    Height = 40
    Anchors = [akLeft, akBottom]
    Caption = 'OPEN CLUB LOBBY'
    Enabled = False
    TabOrder = 6
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = btLeaveClubClick
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
    object acShowManageClubsForm: TAction
      Caption = 'Manage your clubs'
      OnExecute = acShowManageClubsFormExecute
    end
    object acBuyTokens: TAction
      Caption = 'acBuyTokens'
      OnExecute = acBuyTokensExecute
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
      object mmiBuyTokens: TMenuItem
        Action = acBuyTokens
        Caption = 'Get More Tokens...'
      end
    end
    object mmiClubs: TMenuItem
      Caption = 'Clubs'
      object mmiCreateClub: TMenuItem
        Action = acShowCreateClubForm
        Caption = 'Create Club...'
      end
      object mmiJoinClub: TMenuItem
        Action = acShowJoinClubForm
        Caption = 'Join Club...'
      end
      object SearchPublicClubs1: TMenuItem
        Action = acShowPublicGamesListForm
        Caption = 'Search Public Clubs...'
      end
      object mmiSeparator3: TMenuItem
        Caption = '-'
      end
      object Manageclubs1: TMenuItem
        Action = acShowManageClubsForm
        Caption = 'Manage Your Clubs...'
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
