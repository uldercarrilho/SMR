object frmSequencer: TfrmSequencer
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Sequencer'
  ClientHeight = 275
  ClientWidth = 577
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
  object lblEventsHistory: TLabel
    Left = 196
    Top = 8
    Width = 80
    Height = 13
    Caption = 'Purchase Orders'
  end
  object grpService: TGroupBox
    Left = 8
    Top = 102
    Width = 182
    Height = 163
    Caption = ' Sequencer Service '
    TabOrder = 0
    object lblPort: TLabel
      Left = 43
      Top = 24
      Width = 24
      Height = 13
      Caption = 'Port:'
    end
    object lblMode: TLabel
      Left = 37
      Top = 49
      Width = 30
      Height = 13
      Caption = 'Mode:'
    end
    object lblStatus: TLabel
      Left = 32
      Top = 94
      Width = 35
      Height = 13
      Caption = 'Status:'
    end
    object lblActive: TLabel
      Left = 73
      Top = 94
      Width = 30
      Height = 13
      Caption = 'Active'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object edtServicePort: TEdit
      Left = 73
      Top = 21
      Width = 49
      Height = 21
      TabOrder = 0
      Text = '500'
    end
    object rbPrimary: TRadioButton
      Left = 73
      Top = 48
      Width = 52
      Height = 17
      Caption = 'Primary'
      Checked = True
      TabOrder = 1
      TabStop = True
    end
    object rbBackup: TRadioButton
      Left = 73
      Top = 71
      Width = 50
      Height = 17
      Caption = 'Backup'
      TabOrder = 2
    end
    object btnActive: TButton
      Left = 44
      Top = 123
      Width = 95
      Height = 25
      Caption = 'Start'
      TabOrder = 3
      OnClick = btnActiveClick
    end
  end
  object grpGroupMembership: TGroupBox
    Left = 8
    Top = 8
    Width = 182
    Height = 88
    Caption = ' Group Membership '
    TabOrder = 1
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
  object mmoPurchaseOrders: TMemo
    Left = 196
    Top = 27
    Width = 373
    Height = 240
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object SQLConnection: TSQLConnection
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
    Left = 352
    Top = 40
    UniqueId = '{94C681A4-D8D3-4914-A582-6D36E3CCEC4D}'
  end
  object DSServer: TDSServer
    AutoStart = False
    Left = 240
    Top = 40
  end
  object DSServerClass: TDSServerClass
    OnGetClass = DSServerClassGetClass
    Server = DSServer
    Left = 240
    Top = 104
  end
  object DSTCPServerTransport: TDSTCPServerTransport
    Server = DSServer
    Filters = <>
    Left = 240
    Top = 168
  end
end
