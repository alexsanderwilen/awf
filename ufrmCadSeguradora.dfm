object frmCadSeguradora: TfrmCadSeguradora
  Left = 0
  Top = 0
  Caption = 'Sancode - Cadastro de Seguradora'
  ClientHeight = 442
  ClientWidth = 628
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 401
    Width = 628
    Height = 41
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 400
    ExplicitWidth = 624
    object btnNovoCliente: TBitBtn
      Left = 95
      Top = 8
      Width = 137
      Height = 25
      Caption = 'Nova Seguradora'
      TabOrder = 0
      OnClick = btnNovoClienteClick
    end
    object btnAlterar: TBitBtn
      Left = 254
      Top = 8
      Width = 137
      Height = 25
      Caption = 'Alterar'
      TabOrder = 1
      OnClick = btnAlterarClick
    end
    object btnApagar: TBitBtn
      Left = 411
      Top = 8
      Width = 137
      Height = 25
      Caption = 'Apagar'
      TabOrder = 2
      OnClick = btnApagarClick
    end
  end
  object DBGrid1: TDBGrid
    Left = 0
    Top = 49
    Width = 628
    Height = 352
    Align = alClient
    DataSource = ds
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'id'
        Title.Caption = 'ID'
        Width = 60
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'nome'
        Title.Caption = 'Nome'
        Width = 330
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'fantasia'
        Title.Caption = 'Fantasia'
        Width = 200
        Visible = True
      end>
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 628
    Height = 49
    Align = alTop
    TabOrder = 2
    object Label1: TLabel
      Left = 40
      Top = 17
      Width = 46
      Height = 15
      Caption = 'Pesquisa'
    end
    object cbxTipoPesquisa: TComboBox
      Left = 95
      Top = 14
      Width = 82
      Height = 23
      ItemIndex = 1
      TabOrder = 0
      Text = 'Nome'
      Items.Strings = (
        'ID'
        'Nome'
        'Fantasia')
    end
    object edtPesquisa: TEdit
      Left = 183
      Top = 14
      Width = 423
      Height = 23
      CharCase = ecUpperCase
      TabOrder = 1
      OnChange = edtPesquisaChange
      OnKeyDown = edtPesquisaKeyDown
    end
  end
  object SQLConnection1: TSQLConnection
    ConnectionName = 'SQLITECONNECTION'
    DriverName = 'Sqlite'
    LoginPrompt = False
    Params.Strings = (
      'DriverName=Sqlite'
      'Database=C:\awf\db\sancode.db')
    Connected = True
    Left = 488
    Top = 112
  end
  object SQL: TSQLQuery
    MaxBlobSize = 1
    Params = <>
    SQL.Strings = (
      'SELECT * FROM SEGURADORA')
    SQLConnection = SQLConnection1
    Left = 488
    Top = 168
    object SQLid: TLargeintField
      FieldName = 'id'
      Required = True
    end
    object SQLNome: TWideStringField
      DisplayLabel = 'Raz'#227'o Social'
      FieldName = 'Nome'
      Size = 100
    end
    object SQLFantasia: TWideStringField
      FieldName = 'Fantasia'
      Size = 100
    end
  end
  object dsp: TDataSetProvider
    DataSet = SQL
    Left = 368
    Top = 128
  end
  object cdsSeguradora: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 368
    Top = 184
    object cdsSeguradoraid: TStringField
      FieldName = 'id'
      Size = 10
    end
    object cdsSeguradoranome: TStringField
      FieldName = 'nome'
      Size = 500
    end
    object cdsSeguradorafantasia: TStringField
      FieldName = 'fantasia'
      Size = 500
    end
  end
  object ds: TDataSource
    DataSet = cdsSeguradora
    Left = 488
    Top = 224
  end
end
