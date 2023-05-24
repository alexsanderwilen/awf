object frmCadCliente: TfrmCadCliente
  Left = 0
  Top = 0
  Caption = 'Sancode - Cadastro de Clientes'
  ClientHeight = 442
  ClientWidth = 787
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object DBGrid1: TDBGrid
    Left = 0
    Top = 49
    Width = 787
    Height = 343
    Align = alClient
    DataSource = ds
    ReadOnly = True
    TabOrder = 0
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
        Width = 50
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'nome'
        Title.Caption = 'Nome'
        Width = 234
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'email'
        Title.Caption = 'E-mail'
        Width = 346
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'arquivo'
        Title.Caption = 'Telefone'
        Width = 119
        Visible = True
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 392
    Width = 787
    Height = 50
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 391
    ExplicitWidth = 783
    object btnImportar: TBitBtn
      Left = 24
      Top = 16
      Width = 137
      Height = 25
      Caption = 'Importar Excel'
      TabOrder = 0
      OnClick = btnImportarClick
    end
    object btnNovoCliente: TBitBtn
      Left = 239
      Top = 16
      Width = 137
      Height = 25
      Caption = 'Novo Cliente'
      TabOrder = 1
      OnClick = btnNovoClienteClick
    end
    object btnAlterar: TBitBtn
      Left = 382
      Top = 16
      Width = 137
      Height = 25
      Caption = 'Alterar'
      TabOrder = 2
      OnClick = btnAlterarClick
    end
    object btnApagar: TBitBtn
      Left = 525
      Top = 16
      Width = 137
      Height = 25
      Caption = 'Apagar'
      TabOrder = 3
      OnClick = btnApagarClick
    end
    object pb: TProgressBar
      Left = 24
      Top = 4
      Width = 640
      Height = 11
      TabOrder = 4
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 787
    Height = 49
    Align = alTop
    TabOrder = 2
    ExplicitWidth = 783
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
      OnChange = cbxTipoPesquisaChange
      Items.Strings = (
        'ID'
        'Nome'
        'E-Mail')
    end
    object edtPesquisa: TEdit
      Left = 183
      Top = 14
      Width = 578
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
    Left = 472
    Top = 32
  end
  object SQL: TSQLQuery
    MaxBlobSize = 1
    Params = <>
    SQL.Strings = (
      'SELECT * FROM CLIENTE')
    SQLConnection = SQLConnection1
    Left = 472
    Top = 96
    object SQLid: TWideMemoField
      FieldName = 'id'
      Required = True
      BlobType = ftLargeint
    end
    object SQLnome: TWideMemoField
      FieldName = 'nome'
      BlobType = ftWideMemo
      Size = 1
    end
    object SQLemail: TWideMemoField
      FieldName = 'email'
      BlobType = ftWideMemo
      Size = 1
    end
    object SQLarquivo: TWideMemoField
      FieldName = 'arquivo'
      BlobType = ftWideMemo
      Size = 1
    end
  end
  object ds: TDataSource
    DataSet = cdsCliente
    Left = 472
    Top = 184
  end
  object dsp: TDataSetProvider
    DataSet = SQL
    Left = 368
    Top = 128
  end
  object cdsCliente: TClientDataSet
    Aggregates = <>
    FieldDefs = <>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 376
    Top = 208
    object cdsClienteid: TStringField
      FieldName = 'id'
      Size = 10
    end
    object cdsClientenome: TStringField
      FieldName = 'nome'
      Size = 500
    end
    object cdsClienteemail: TStringField
      FieldName = 'email'
      Size = 2000
    end
    object cdsClientearquivo: TStringField
      FieldName = 'arquivo'
      Size = 200
    end
  end
end
