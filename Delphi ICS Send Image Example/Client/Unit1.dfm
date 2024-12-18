object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Client'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Image1: TImage
    Left = 208
    Top = 0
    Width = 193
    Height = 185
    Stretch = True
  end
  object ButtonConnect: TButton
    Left = 24
    Top = 408
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
    OnClick = ButtonConnectClick
  end
  object ButtonBrowse: TButton
    Left = 248
    Top = 408
    Width = 113
    Height = 25
    Caption = 'ButtonBrowse'
    Enabled = False
    TabOrder = 1
    OnClick = ButtonBrowseClick
  end
  object ButtonSendImage: TButton
    Left = 448
    Top = 408
    Width = 155
    Height = 25
    Caption = 'ButtonSendImage'
    Enabled = False
    TabOrder = 2
    OnClick = ButtonSendImageClick
  end
  object MemoLog: TMemo
    Left = 0
    Top = 191
    Width = 616
    Height = 202
    Lines.Strings = (
      'MemoLog')
    TabOrder = 3
  end
  object WSocket1: TWSocket
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
    OnSessionClosed = WSocket1SessionClosed
    OnSessionConnected = WSocket1SessionConnected
    SocketErrs = wsErrTech
    Left = 32
    Top = 32
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Filter = 
      'Device Independent Bitmap (*.dib)|*.dib|Scalable Vector Graphics' +
      ' (*.svg)|*.svg|Portable network graphics (AlphaControls) (*.png)' +
      '|*.png|Scalable Vector Graphics (*.svg)|*.svg|CompuServe GIF Ima' +
      'ge (*.gif)|*.gif|Cursor files (*.cur)|*.cur|PCX Image (*.pcx)|*.' +
      'pcx|ANI Image (*.ani)|*.ani|APRO APF Format (*.apf)|*.apf|WBMP I' +
      'mages (*.wbmp)|*.wbmp|WebP Images (*.webp)|*.webp|Scalable Vecto' +
      'r Graphics (*.svg)|*.svg|GIF Image (*.gif)|*.gif|JPEG Image File' +
      ' (*.jpg)|*.jpg|JPEG Image File (*.jpeg)|*.jpeg|Portable Network ' +
      'Graphics (*.png)|*.png|Bitmaps (*.bmp)|*.bmp|Icons (*.ico)|*.ico' +
      '|Enhanced Metafiles (*.emf)|*.emf|Metafiles (*.wmf)|*.wmf|TIFF I' +
      'mages (*.tif)|*.tif|TIFF Images (*.tiff)|*.tiff'
    Left = 48
    Top = 96
  end
end
