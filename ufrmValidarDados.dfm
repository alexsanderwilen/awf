object frmValidarDados: TfrmValidarDados
  Left = 0
  Top = 0
  Caption = 'Sancode - Valida'#231#227'o dos Dados'
  ClientHeight = 442
  ClientWidth = 735
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnActivate = FormActivate
  OnCreate = FormCreate
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 0
    Top = 65
    Width = 735
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ExplicitWidth = 336
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 735
    Height = 65
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 731
    object lblContador: TLabel
      Left = 694
      Top = 14
      Width = 17
      Height = 15
      Alignment = taRightJustify
      Caption = '0/0'
    end
    object pb: TProgressBar
      Left = 16
      Top = 32
      Width = 697
      Height = 17
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 401
    Width = 735
    Height = 41
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 400
    ExplicitWidth = 731
    object bitValidar: TBitBtn
      Left = 320
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Validar'
      TabOrder = 0
      OnClick = bitValidarClick
    end
    object BitBtn1: TBitBtn
      Left = 558
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Clientes'
      TabOrder = 1
      OnClick = BitBtn1Click
    end
    object BitBtn2: TBitBtn
      Left = 646
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Seguradoras'
      TabOrder = 2
      OnClick = BitBtn2Click
    end
  end
  object dbgErros: TDBGrid
    Left = 0
    Top = 68
    Width = 735
    Height = 333
    Align = alClient
    DataSource = ds
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'cedente'
        Title.Caption = 'Cedente'
        Width = 154
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'sacado'
        Title.Caption = 'Sacado'
        Width = 161
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'email'
        Title.Caption = 'E-mail'
        Width = 172
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'arquivo'
        Title.Caption = 'Arquivo PDF'
        Width = 215
        Visible = True
      end>
  end
  object SQLConnection1: TSQLConnection
    ConnectionName = 'SQLITECONNECTION'
    DriverName = 'Sqlite'
    LoginPrompt = False
    Params.Strings = (
      'DriverName=Sqlite'
      'Database=C:\awf\db\sancode.db')
    Connected = True
    Left = 160
    Top = 104
  end
  object SQLConfiguracao: TSQLQuery
    MaxBlobSize = 1
    Params = <>
    SQL.Strings = (
      'SELECT * FROM CONFIGURACAO'
      'where id = 1')
    SQLConnection = SQLConnection1
    Left = 160
    Top = 152
  end
  object SQLSeguradora: TSQLQuery
    MaxBlobSize = 1
    Params = <
      item
        DataType = ftString
        Name = 'RAZAOSOCIAL'
        ParamType = ptInput
        Value = ''
      end>
    SQL.Strings = (
      'SELECT * FROM SEGURADORA'
      'WHERE NOME = :RAZAOSOCIAL')
    SQLConnection = SQLConnection1
    Left = 264
    Top = 104
  end
  object cdsErros: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 304
    Top = 224
    object cdsErrosid: TIntegerField
      FieldName = 'id'
    end
    object cdsErrosVencimento: TStringField
      FieldName = 'Vencimento'
      Size = 1000
    end
    object cdsErroscedente: TStringField
      FieldName = 'cedente'
      Size = 1000
    end
    object cdsErrossacado: TStringField
      FieldName = 'sacado'
      Size = 1000
    end
    object cdsErrosemail: TStringField
      FieldName = 'email'
      Size = 1000
    end
    object cdsErrosarquivo: TStringField
      FieldName = 'arquivo'
      Size = 1000
    end
  end
  object ds: TDataSource
    DataSet = cdsErros
    Left = 384
    Top = 224
  end
  object SQL: TSQLQuery
    MaxBlobSize = 1
    Params = <>
    SQLConnection = SQLConnection1
    Left = 160
    Top = 216
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 464
    Top = 152
  end
end
