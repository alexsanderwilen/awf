object frmDetSeguradora: TfrmDetSeguradora
  Left = 0
  Top = 0
  Caption = 'Sancode - Detalhe da Seguradora'
  ClientHeight = 262
  ClientWidth = 504
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
    Width = 65
    Height = 15
    Caption = 'Raz'#227'o Social'
  end
  object lblEmail: TLabel
    Left = 24
    Top = 80
    Width = 43
    Height = 15
    Caption = 'Fantasia'
  end
  object Panel1: TPanel
    Left = 0
    Top = 221
    Width = 504
    Height = 41
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 220
    ExplicitWidth = 500
    object btnSalvar: TBitBtn
      Left = 240
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Confirmar'
      TabOrder = 0
      OnClick = btnSalvarClick
    end
    object btnCancelar: TBitBtn
      Left = 327
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Cancelar'
      TabOrder = 1
      OnClick = btnCancelarClick
    end
  end
  object edtID: TEdit
    Left = 24
    Top = 45
    Width = 57
    Height = 23
    TabStop = False
    ReadOnly = True
    TabOrder = 1
  end
  object edtRazaoSocial: TEdit
    Left = 96
    Top = 45
    Width = 385
    Height = 23
    CharCase = ecUpperCase
    TabOrder = 2
  end
  object edtFantasia: TEdit
    Left = 24
    Top = 101
    Width = 457
    Height = 23
    CharCase = ecUpperCase
    TabOrder = 3
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
      'SELECT * FROM SEGURADORA')
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
