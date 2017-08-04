object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = #51060#48120#51648' '#48624#50612
  ClientHeight = 667
  ClientWidth = 1035
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 241
    Top = 0
    Height = 648
    ExplicitLeft = 528
    ExplicitTop = 312
    ExplicitHeight = 100
  end
  object ShellTreeView1: TShellTreeView
    Left = 0
    Top = 0
    Width = 241
    Height = 648
    ObjectTypes = [otFolders]
    Root = 'rfDesktop'
    UseShellImages = True
    Align = alLeft
    AutoRefresh = False
    Indent = 19
    ParentColor = False
    RightClickSelect = True
    ShowRoot = False
    TabOrder = 0
    OnChange = ShellTreeView1Change
  end
  object paImage: TPanel
    Left = 244
    Top = 0
    Width = 791
    Height = 648
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Splitter2: TSplitter
      Left = 0
      Top = 297
      Width = 791
      Height = 3
      Cursor = crVSplit
      Align = alTop
      ExplicitWidth = 370
    end
    object lvThumbnails: TListView
      Left = 0
      Top = 0
      Width = 791
      Height = 297
      Align = alTop
      Columns = <>
      OwnerData = True
      TabOrder = 0
      OnChange = lvThumbnailsChange
      OnData = lvThumbnailsData
    end
    object ImgView32: TImgView32
      Left = 0
      Top = 300
      Width = 791
      Height = 348
      Align = alClient
      Bitmap.ResamplerClassName = 'TNearestResampler'
      BitmapAlign = baCustom
      Scale = 1.000000000000000000
      ScaleMode = smScale
      ScrollBars.ShowHandleGrip = True
      ScrollBars.Style = rbsDefault
      ScrollBars.Size = 17
      OverSize = 0
      TabOrder = 1
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 648
    Width = 1035
    Height = 19
    Panels = <
      item
        Width = 600
      end
      item
        Width = 300
      end>
  end
  object MainMenu1: TMainMenu
    AutoHotkeys = maManual
    Left = 512
    Top = 336
    object N1: TMenuItem
      Caption = #54028#51068
      object menu_ImageOpen: TMenuItem
        Caption = #51060#48120#51648#50676#44592
        OnClick = menu_ImageOpenClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object menu_Close: TMenuItem
        Caption = #51333#47308
        OnClick = menu_CloseClick
      end
    end
    object mnu_info: TMenuItem
      Caption = #51221#48372
      object mnu_about: TMenuItem
        Caption = #54532#47196#44536#47016' '#51221#48372
        OnClick = mnu_aboutClick
      end
    end
  end
  object OpenPictureDialog1: TOpenPictureDialog
    Left = 600
    Top = 336
  end
end
