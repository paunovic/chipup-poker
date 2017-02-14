object frmChangeAvatar: TfrmChangeAvatar
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Change Avatar'
  ClientHeight = 219
  ClientWidth = 226
  Color = clWindow
  Ctl3D = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  DesignSize = (
    226
    219)
  PixelsPerInch = 96
  TextHeight = 14
  object btChange: TcxButton
    Left = 17
    Top = 182
    Width = 93
    Height = 27
    Action = acChange
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 0
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object btCancel: TcxButton
    Left = 116
    Top = 182
    Width = 93
    Height = 27
    Action = acClose
    Anchors = [akRight, akBottom]
    SpeedButtonOptions.CanBeFocused = False
    TabOrder = 1
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object imgAvatar: TcxImage
    Left = 38
    Top = 19
    Properties.PopupMenuLayout.MenuItems = []
    Properties.ReadOnly = True
    Properties.ShowFocusRect = False
    Style.BorderColor = 3487029
    TabOrder = 2
    Height = 150
    Width = 150
  end
  object pbUpload: TcxProgressBar
    Left = 17
    Top = 172
    AutoSize = False
    Position = 100.000000000000000000
    Properties.AnimationPath = cxapPingPong
    Properties.AnimationSpeed = 4
    Properties.BarStyle = cxbsGradient
    Properties.BeginColor = clGreen
    Properties.EndColor = 3260672
    Properties.PeakValue = 100.000000000000000000
    Properties.ShowText = False
    Properties.ShowTextStyle = cxtsText
    Style.Edges = []
    Style.LookAndFeel.SkinName = ''
    StyleDisabled.LookAndFeel.SkinName = ''
    StyleFocused.LookAndFeel.SkinName = ''
    StyleHot.LookAndFeel.SkinName = ''
    TabOrder = 3
    Visible = False
    Height = 8
    Width = 192
  end
  object alChangeAvatar: TActionList
    Left = 128
    Top = 108
    object acChange: TAction
      Caption = 'Change...'
      OnExecute = acChangeExecute
    end
    object acClose: TAction
      Caption = 'Close'
      OnExecute = acCloseExecute
    end
  end
  object OpenDialog: TOpenDialog
    Filter = 'Picture Files (*.jpg, *.png, *.bmp)|*.jpg;*.png;*.bmp'
    Left = 56
    Top = 108
  end
  object HttpClient: TSslHttpCli
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    ProxyPort = '80'
    Agent = 'Mozilla/4.0'
    Accept = 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*'
    Connection = 'Keep-Alive'
    NoCache = False
    ContentTypePost = 'application/x-www-form-urlencoded'
    RequestVer = '1.1'
    FollowRelocation = True
    LocationChangeMaxCount = 5
    ServerAuth = httpAuthNone
    ProxyAuth = httpAuthNone
    BandwidthLimit = 0
    BandwidthSampling = 1000
    Options = []
    Timeout = 30
    OnSendData = HttpClientSendData
    SocksAuthentication = socksNoAuthentication
    SocketFamily = sfIPv4
    SslContext = SslContext
    Left = 60
    Top = 40
  end
  object SslContext: TSslContext
    SslVerifyPeer = False
    SslVerifyDepth = 9
    SslVerifyFlags = [sslX509_V_FLAG_CRL_CHECK_ALL]
    SslOptions = []
    SslVerifyPeerModes = [SslVerifyMode_PEER]
    SslSessionCacheModes = []
    SslCipherList = 'ALL:!ADH:RC4+RSA:+SSLv2:@STRENGTH'
    SslVersionMethod = sslTLS_V1_2
    SslECDHMethod = sslECDHNone
    SslSessionTimeout = 0
    SslSessionCacheSize = 20480
    Left = 124
    Top = 40
  end
end
