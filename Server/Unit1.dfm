object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'server'
  ClientHeight = 348
  ClientWidth = 303
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    303
    348)
  TextHeight = 15
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 303
    Height = 226
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        AutoSize = True
        Caption = 'IP Address'
      end
      item
        AutoSize = True
        Caption = 'NickName'
      end>
    ReadOnly = True
    RowSelect = True
    PopupMenu = SendMenu
    TabOrder = 0
    ViewStyle = vsReport
    OnClick = ListView1Click
  end
  object Memo1: TMemo
    Left = 0
    Top = 232
    Width = 303
    Height = 113
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object WSocketServer1: TWSocketServer
    LineMode = True
    LineLimit = 2147483647
    LineEnd = #13#10
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    LocalPort = '0'
    SocksLevel = '5'
    ExclusiveAddr = False
    ComponentOptions = []
    ListenBacklog = 15
    OnBgException = WSocketServer1BgException
    SocketErrs = wsErrTech
    OnClientDisconnect = WSocketServer1ClientDisconnect
    OnClientConnect = WSocketServer1ClientConnect
    MultiListenSockets = <>
    Left = 40
    Top = 40
    Banner = ''
    BannerTooBusy = ''
  end
  object SendMenu: TPopupMenu
    Left = 40
    Top = 96
    object S1: TMenuItem
      Caption = 'Send To ALL'
      OnClick = S1Click
    end
    object S2: TMenuItem
      Caption = 'Send To Selected Client'
      OnClick = S2Click
    end
  end
end
