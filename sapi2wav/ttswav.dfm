object MainForm: TMainForm
  Left = 283
  Top = 175
  BorderStyle = bsNone
  Caption = 'Sapi2wav'
  ClientHeight = 133
  ClientWidth = 228
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object SpVoice1: TSpVoice
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 8
    Top = 8
  end
  object SpFileStream: TSpFileStream
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 40
    Top = 8
  end
end
