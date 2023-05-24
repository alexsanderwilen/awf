object frmDetCliente: TfrmDetCliente
  Left = 0
  Top = 0
  Caption = 'Sancode - Detalhe do Cliente'
  ClientHeight = 270
  ClientWidth = 496
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 15
  object lblID: TLabel
    Left = 24
    Top = 24
    Width = 11
    Height = 15
    Caption = 'ID'
  end
  object lblNome: TLabel
    Left = 96
    Top = 24
    Width = 33
    Height = 15
    Caption = 'Nome'
  end
  object lblEmail: TLabel
    Left = 24
    Top = 80
    Width = 34
    Height = 15
    Caption = 'E-mail'
  end
  object lblArquivo: TLabel
    Left = 328
    Top = 24
    Width = 44
    Height = 15
    Caption = 'Telefone'
  end
  object edtID: TEdit
    Left = 24
    Top = 45
    Width = 57
    Height = 23
    TabStop = False
    ReadOnly = True
    TabOrder = 0
  end
  object edtNome: TEdit
    Left = 96
    Top = 45
    Width = 217
    Height = 23
    CharCase = ecUpperCase
    TabOrder = 1
  end
  object edtEmail: TEdit
    Left = 24
    Top = 101
    Width = 457
    Height = 23
    CharCase = ecLowerCase
    TabOrder = 3
  end
  object edtArquivo: TEdit
    Left = 328
    Top = 45
    Width = 153
    Height = 23
    CharCase = ecUpperCase
    TabOrder = 2
  end
  object Panel1: TPanel
    Left = 0
    Top = 229
    Width = 496
    Height = 41
    Align = alBottom
    TabOrder = 4
    ExplicitTop = 228
    ExplicitWidth = 492
    object btnSalvar: TBitBtn
      Left = 176
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Confirmar'
      TabOrder = 0
      OnClick = btnSalvarClick
    end
    object btnCancelar: TBitBtn
      Left = 263
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Cancelar'
      TabOrder = 1
      OnClick = btnCancelarClick
    end
  end
  object SQLConnection1: TSQLConnection
    ConnectionName = 'SQLITECONNECTION'
    DriverName = 'Sqlite'
    LoginPrompt = False
    Params.Strings = (
      'DriverName=Sqlite'
      'Database=C:\awf\db\sancode.db')
    Left = 92
    Top = 128
  end
  object SQL: TSQLQuery
    MaxBlobSize = 1
    Params = <>
    SQL.Strings = (
      'SELECT * FROM CLIENTE')
    SQLConnection = SQLConnection1
    Left = 92
    Top = 168
    object SQLid: TLargeintField
      FieldName = 'id'
      Required = True
    end
    object SQLnome: TWideStringField
      FieldName = 'nome'
      Size = 100
    end
    object SQLemail: TWideStringField
      FieldName = 'email'
      Size = 255
    end
    object SQLarquivo: TWideStringField
      FieldName = 'arquivo'
      Size = 100
    end
  end
end
