object Form1: TForm1
  Left = 228
  Top = 125
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1060#1088#1072#1082#1090#1072#1083#1100#1085#1086#1077' '#1089#1078#1072#1090#1080#1077' / '#1088#1072#1089#1087#1072#1082#1086#1074#1082#1072' '#1088#1072#1089#1090#1088#1086#1074#1099#1093' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1081
  ClientHeight = 378
  ClientWidth = 588
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object ImPreview: TImage
    Left = 440
    Top = 56
    Width = 137
    Height = 129
    Center = True
    Proportional = True
    Stretch = True
  end
  object Label1: TLabel
    Left = 8
    Top = 32
    Width = 441
    Height = 16
    Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1088#1072#1089#1090#1088#1086#1074#1086#1077' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077' '#1088#1072#1079#1084#1077#1088#1072#1084#1080' '#1085#1077' '#1073#1086#1083#1077#1077' 512 x 512'
  end
  object Label2: TLabel
    Left = 483
    Top = 31
    Width = 69
    Height = 16
    Caption = #1055#1088#1086#1089#1084#1086#1090#1088
  end
  object lbSize: TLabel
    Left = 473
    Top = 187
    Width = 6
    Height = 16
    Caption = '  '
  end
  object Label4: TLabel
    Left = 8
    Top = 104
    Width = 130
    Height = 16
    Caption = #1057#1084#1077#1097#1077#1085#1080#1077' '#1076#1086#1084#1077#1085#1072':'
  end
  object Label5: TLabel
    Left = 8
    Top = 136
    Width = 115
    Height = 16
    Caption = #1056#1072#1079#1084#1077#1088' '#1088#1077#1075#1080#1086#1085#1072':'
  end
  object Label6: TLabel
    Left = 8
    Top = 352
    Width = 220
    Height = 16
    Caption = #1050#1086#1083'-'#1074#1086' '#1080#1090#1077#1088#1072#1094#1080#1081' '#1076#1077#1082#1086#1084#1087#1088#1077#1089#1089#1080#1080':'
  end
  object Label7: TLabel
    Left = 8
    Top = 8
    Width = 163
    Height = 20
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1089#1078#1072#1090#1080#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = 176
    Top = 16
    Width = 401
    Height = 9
    Shape = bsTopLine
  end
  object Label3: TLabel
    Left = 10
    Top = 288
    Width = 223
    Height = 20
    Caption = #1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1076#1077#1082#1086#1084#1087#1088#1077#1089#1089#1080#1080
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Bevel2: TBevel
    Left = 240
    Top = 296
    Width = 337
    Height = 9
    Shape = bsTopLine
  end
  object Label8: TLabel
    Left = 8
    Top = 320
    Width = 115
    Height = 16
    Caption = #1056#1072#1079#1084#1077#1088' '#1088#1077#1075#1080#1086#1085#1072':'
  end
  object Label9: TLabel
    Left = 108
    Top = 187
    Width = 144
    Height = 16
    Caption = #1054#1089#1090#1072#1083#1086#1089#1100' '#1074#1088#1077#1084#1077#1085#1080', '#1089':'
  end
  object lbTime: TLabel
    Left = 256
    Top = 187
    Width = 3
    Height = 16
  end
  object Edit1: TEdit
    Left = 8
    Top = 56
    Width = 385
    Height = 25
    ReadOnly = True
    TabOrder = 0
    Text = #1048#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077' '#1085#1077' '#1074#1099#1073#1088#1072#1085#1086'!'
  end
  object Button1: TButton
    Left = 400
    Top = 56
    Width = 25
    Height = 25
    Caption = '...'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 440
    Top = 215
    Width = 137
    Height = 26
    Caption = #1055#1086#1083#1085#1086#1089#1090#1100#1102'...'
    TabOrder = 2
    OnClick = Button2Click
  end
  object CheckBox1: TCheckBox
    Left = 440
    Top = 192
    Width = 137
    Height = 17
    Caption = #1055#1088#1077#1076#1086#1073#1088#1072#1073#1086#1090#1082#1072
    TabOrder = 3
  end
  object ProgressBar1: TProgressBar
    Left = 104
    Top = 216
    Width = 329
    Height = 25
    TabOrder = 4
  end
  object Button4: TButton
    Left = 8
    Top = 216
    Width = 89
    Height = 25
    Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100
    TabOrder = 5
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 295
    Top = 248
    Width = 98
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 6
    OnClick = Button5Click
  end
  object Edit2: TEdit
    Left = 144
    Top = 96
    Width = 89
    Height = 25
    TabOrder = 7
    Text = '1'
  end
  object Edit3: TEdit
    Left = 144
    Top = 128
    Width = 89
    Height = 25
    TabOrder = 8
    Text = '8'
  end
  object Button3: TButton
    Left = 344
    Top = 328
    Width = 113
    Height = 25
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    TabOrder = 9
    OnClick = Button3Click
  end
  object Button6: TButton
    Left = 464
    Top = 328
    Width = 113
    Height = 25
    Caption = #1056#1072#1089#1087#1072#1082#1086#1074#1072#1090#1100
    TabOrder = 10
    OnClick = Button6Click
  end
  object Edit4: TEdit
    Left = 240
    Top = 344
    Width = 97
    Height = 25
    TabOrder = 11
    Text = '15'
  end
  object Button7: TButton
    Left = 104
    Top = 248
    Width = 185
    Height = 25
    Caption = #1055#1088#1086#1089#1084#1086#1090#1088#1077#1090#1100' '#1088#1077#1079#1091#1083#1100#1090#1072#1090
    TabOrder = 12
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 8
    Top = 248
    Width = 89
    Height = 25
    Caption = #1055#1088#1077#1088#1074#1072#1090#1100
    TabOrder = 13
    OnClick = Button8Click
  end
  object CheckBox2: TCheckBox
    Left = 248
    Top = 112
    Width = 177
    Height = 33
    Alignment = taLeftJustify
    Caption = #1042#1099#1087#1086#1083#1085#1103#1090#1100' '#1074#1089#1077' '#1087#1088#1077#1086#1073#1088#1072#1079#1086#1074#1072#1085#1080#1103
    Checked = True
    State = cbChecked
    TabOrder = 14
    WordWrap = True
  end
  object Edit5: TEdit
    Left = 240
    Top = 312
    Width = 97
    Height = 27
    TabOrder = 15
    Text = '8'
  end
  object Button9: TButton
    Left = 400
    Top = 248
    Width = 177
    Height = 25
    Caption = #1056#1072#1079#1084#1077#1088' '#1092#1072#1081#1083#1072
    TabOrder = 16
    OnClick = Button9Click
  end
  object OpenPictureDialog1: TOpenPictureDialog
    DefaultExt = '*.bmp'
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 312
    Top = 160
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '*.ifs'
    Filter = '*.ifs|*.ifs|*.*|*.*'
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 344
    Top = 160
  end
end
