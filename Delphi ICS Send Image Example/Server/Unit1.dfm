object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Server'
  ClientHeight = 368
  ClientWidth = 525
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Image1: TImage
    Left = 160
    Top = 0
    Width = 193
    Height = 182
    Stretch = True
  end
  object ButtonStart: TButton
    Left = 0
    Top = 335
    Width = 266
    Height = 25
    Caption = 'Start Server'
    TabOrder = 0
    OnClick = ButtonStartClick
  end
  object ButtonStop: TButton
    Left = 272
    Top = 335
    Width = 245
    Height = 25
    Caption = 'STOP Server'
    Enabled = False
    TabOrder = 1
    OnClick = ButtonStopClick
  end
  object memolog: TMemo
    Left = 0
    Top = 200
    Width = 517
    Height = 129
    TabOrder = 2
  end
  object ProgressBar1: TProgressBar
    Left = 0
    Top = 182
    Width = 517
    Height = 17
    TabOrder = 3
  end
  object WSocketServer1: TWSocketServer
    LineMode = True
    LineEnd = #13#10
    Proto = 'tcp'
    LocalAddr = '0.0.0.0'
    LocalAddr6 = '::'
    LocalPort = '0'
    SocksLevel = '5'
    ExclusiveAddr = False
    ComponentOptions = []
    ListenBacklog = 15
    SocketErrs = wsErrTech
    OnClientDisconnect = WSocketServer1ClientDisconnect
    OnClientConnect = WSocketServer1ClientConnect
    MultiListenSockets = <>
    Left = 56
    Top = 32
  end
end
