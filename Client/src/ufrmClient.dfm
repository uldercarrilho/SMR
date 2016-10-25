object frmClient: TfrmClient
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Client'
  ClientHeight = 240
  ClientWidth = 528
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblPurchaseOrder: TLabel
    Left = 196
    Top = 8
    Width = 75
    Height = 13
    Caption = 'Purchase Order'
  end
  object rgClientType: TRadioGroup
    Left = 8
    Top = 102
    Width = 182
    Height = 99
    Caption = ' Client Type '
    ItemIndex = 0
    Items.Strings = (
      'Telemarketing'
      'Loja Virtual'
      'Loja F'#237'sica'
      'Revendedor')
    TabOrder = 1
  end
  object grpGroupMembership: TGroupBox
    Left = 8
    Top = 8
    Width = 182
    Height = 88
    Caption = ' Group Membership '
    TabOrder = 0
    object lblGroupHostName: TLabel
      Left = 12
      Top = 24
      Width = 55
      Height = 13
      Caption = 'Host name:'
    end
    object lblGroupPort: TLabel
      Left = 44
      Top = 51
      Width = 24
      Height = 13
      Caption = 'Port:'
    end
    object edtGroupHostName: TEdit
      Left = 73
      Top = 21
      Width = 95
      Height = 21
      TabOrder = 0
      Text = '127.0.0.1'
    end
    object edtGroupPort: TEdit
      Left = 73
      Top = 48
      Width = 95
      Height = 21
      TabOrder = 1
      Text = '400'
    end
  end
  object btnBuy: TButton
    Left = 8
    Top = 207
    Width = 182
    Height = 25
    Caption = 'Buy'
    TabOrder = 2
    OnClick = btnBuyClick
  end
  object mmoPurchaseOrder: TMemo
    Left = 196
    Top = 27
    Width = 324
    Height = 205
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object SQLConnGroupMembership: TSQLConnection
    DriverName = 'DataSnap'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=Data.DBXDataSnap'
      'HostName=localhost'
      'Port=400'
      'CommunicationProtocol=tcp/ip'
      'DatasnapContext=datasnap/'
      
        'DriverAssemblyLoader=Borland.Data.TDBXClientDriverLoader,Borland' +
        '.Data.DbxClientDriver,Version=23.0.0.0,Culture=neutral,PublicKey' +
        'Token=91d62ebb5b0d1b1b')
    Left = 264
    Top = 40
    UniqueId = '{99A971DB-8FFF-49D0-BEB7-C0DCFF670FE5}'
  end
  object SQLConnSequencer: TSQLConnection
    DriverName = 'DataSnap'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=Data.DBXDataSnap'
      'HostName=localhost'
      'Port=500'
      'CommunicationProtocol=tcp/ip'
      'DatasnapContext=datasnap/'
      
        'DriverAssemblyLoader=Borland.Data.TDBXClientDriverLoader,Borland' +
        '.Data.DbxClientDriver,Version=23.0.0.0,Culture=neutral,PublicKey' +
        'Token=91d62ebb5b0d1b1b')
    Left = 264
    Top = 112
    UniqueId = '{8096F810-E1C0-4B5A-BA4C-5F2C157A6419}'
  end
end
