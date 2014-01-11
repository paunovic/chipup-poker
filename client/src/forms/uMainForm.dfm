object frmMain: TfrmMain
  Left = 0
  Top = 0
  ClientHeight = 637
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
    637)
  PixelsPerInch = 96
  TextHeight = 14
  object gridJoinedClubs: TcxGrid
    Left = 8
    Top = 246
    Width = 290
    Height = 383
    Anchors = [akLeft, akBottom]
    TabOrder = 0
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
  object btLeaveClub: TcxButton
    Left = 60
    Top = 97
    Width = 105
    Height = 32
    Caption = 'Leave Club'
    Enabled = False
    TabOrder = 1
    OnClick = btLeaveClubClick
  end
  object lbUserInfo: TcxLabel
    Left = 8
    Top = 191
    Transparent = True
  end
  object btOpenTable: TButton
    Left = 460
    Top = 81
    Width = 75
    Height = 25
    Caption = 'Open Table'
    TabOrder = 3
    OnClick = btOpenTableClick
  end
  object cxButton1: TcxButton
    Left = 216
    Top = 57
    Width = 105
    Height = 32
    Caption = 'Create Club'
    Enabled = False
    TabOrder = 4
    OnClick = btLeaveClubClick
  end
  object cxButton2: TcxButton
    Left = 60
    Top = 57
    Width = 105
    Height = 32
    Caption = 'Join Club'
    Enabled = False
    TabOrder = 5
    OnClick = btLeaveClubClick
  end
  object cxButton3: TcxButton
    Left = 216
    Top = 97
    Width = 105
    Height = 32
    Caption = 'Manage Club'
    Enabled = False
    TabOrder = 6
    OnClick = btLeaveClubClick
  end
  object cxGrid1: TcxGrid
    Left = 304
    Top = 246
    Width = 628
    Height = 383
    Anchors = [akLeft, akBottom]
    TabOrder = 7
    object cxGridTableView1: TcxGridTableView
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
      object cxGridTableView1Column1: TcxGridColumn
        Caption = 'Blinds'
        HeaderAlignmentHorz = taCenter
        Width = 53
      end
      object cxGridTableView1Column2: TcxGridColumn
        Caption = 'Players'
        HeaderAlignmentHorz = taCenter
        Width = 64
      end
      object cxGridTableView1Column3: TcxGridColumn
        Caption = 'Status'
        HeaderAlignmentHorz = taCenter
        Width = 133
      end
    end
    object cxGridLevel1: TcxGridLevel
      GridView = cxGridTableView1
    end
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
    SkinName = 'DevExpressStyle'
    Left = 552
    Top = 80
  end
end
