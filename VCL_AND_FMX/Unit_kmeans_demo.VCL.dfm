object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 472
  ClientWidth = 1024
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object SourceImage: TImage
    Left = 240
    Top = 64
    Width = 329
    Height = 313
  end
  object OutImage: TImage
    Left = 624
    Top = 64
    Width = 321
    Height = 313
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 440
    Align = alLeft
    Caption = 'Panel1'
    TabOrder = 0
    ExplicitTop = 8
    ExplicitHeight = 456
    object Button1: TButton
      Left = 16
      Top = 16
      Width = 145
      Height = 49
      Caption = 'Button_LoadBMP'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button_FullTest: TButton
      Left = 16
      Top = 88
      Width = 145
      Height = 49
      Caption = 'Button_FullTest'
      TabOrder = 1
      OnClick = Button_FullTestClick
    end
    object DebugMemo: TMemo
      Left = 1
      Top = 231
      Width = 183
      Height = 208
      Align = alBottom
      Lines.Strings = (
        'DebugMemo')
      TabOrder = 2
      ExplicitLeft = 0
      ExplicitTop = 264
      ExplicitWidth = 185
    end
  end
  object MyStatusBar: TStatusBar
    Left = 0
    Top = 440
    Width = 1024
    Height = 32
    Panels = <>
    SimplePanel = True
    ExplicitTop = 445
  end
  object OpenDialog: TOpenDialog
    Left = 24
    Top = 152
  end
  object MadExceptionHandler1: TMadExceptionHandler
    Left = 792
    Top = 384
  end
end
