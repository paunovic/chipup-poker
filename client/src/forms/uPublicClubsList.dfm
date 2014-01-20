object frmPublicClubsList: TfrmPublicClubsList
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Public Clubs List'
  ClientHeight = 416
  ClientWidth = 477
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    477
    416)
  PixelsPerInch = 96
  TextHeight = 13
  object gridClubs: TcxGrid
    Left = 8
    Top = 8
    Width = 459
    Height = 362
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    ExplicitWidth = 515
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
        Caption = 'Club ID'
        PropertiesClassName = 'TcxSpinEditProperties'
        HeaderAlignmentHorz = taCenter
        Width = 67
      end
      object gridClubsName: TcxGridColumn
        Caption = 'Club name'
        PropertiesClassName = 'TcxTextEditProperties'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        SortIndex = 0
        SortOrder = soDescending
        Width = 219
      end
      object gridClubsInvitationCode: TcxGridColumn
        Caption = 'Invitation Code'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.Alignment.Horz = taCenter
        HeaderAlignmentHorz = taCenter
        Width = 100
      end
      object gridClubsPlayers: TcxGridColumn
        Caption = 'Players'
        PropertiesClassName = 'TcxSpinEditProperties'
        HeaderAlignmentHorz = taCenter
        Width = 71
      end
    end
    object gridClubsLevel: TcxGridLevel
      GridView = gridClubsTable
    end
  end
  object btJoinClub: TcxButton
    Left = 377
    Top = 379
    Width = 90
    Height = 27
    Action = acJoinClub
    Anchors = [akRight, akBottom]
    TabOrder = 1
    ExplicitLeft = 433
  end
  object btRefreshList: TcxButton
    Left = 8
    Top = 379
    Width = 90
    Height = 27
    Action = acRefresh
    Anchors = [akLeft, akBottom]
    TabOrder = 2
  end
  object alPublicClubsList: TActionList
    Left = 96
    Top = 140
    object acRefresh: TAction
      Caption = 'Refresh List'
      OnExecute = acRefreshExecute
    end
    object acJoinClub: TAction
      Caption = 'Join Club'
      Enabled = False
      OnExecute = acJoinClubExecute
    end
  end
  object tiRefreshActionEnabler: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = tiRefreshActionEnablerTimer
    Left = 200
    Top = 140
  end
end
