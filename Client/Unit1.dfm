object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Client'
  ClientHeight = 266
  ClientWidth = 330
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  DesignSize = (
    330
    266)
  TextHeight = 15
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 329
    Height = 239
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Edit1: TEdit
    Left = 0
    Top = 240
    Width = 233
    Height = 23
    TabOrder = 1
  end
  object Button1: TButton
    Left = 238
    Top = 240
    Width = 91
    Height = 23
    Caption = 'Send'
    TabOrder = 2
    OnClick = Button1Click
  end
  object WSocket1: TWSocket
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
    OnDataAvailable = WSocket1DataAvailable
    OnSessionConnected = WSocket1SessionConnected
    SocketErrs = wsErrTech
    Left = 32
    Top = 8
  end
end
