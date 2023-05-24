object frmEmail: TfrmEmail
  Left = 0
  Top = 0
  Caption = 'Sancode - Envio de Email'
  ClientHeight = 198
  ClientWidth = 525
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  TextHeight = 15
  object lblEmailAtual: TLabel
    Left = 8
    Top = 99
    Width = 40
    Height = 15
    Caption = 'Cliente:'
  end
  object lblTotalEmails: TLabel
    Left = 491
    Top = 103
    Width = 17
    Height = 15
    Alignment = taRightJustify
    Caption = '0/0'
  end
  object lbDTInicial: TLabel
    Left = 8
    Top = 8
    Width = 93
    Height = 15
    Caption = 'Data Hora Inicial: '
  end
  object lblDTFinal: TLabel
    Left = 8
    Top = 29
    Width = 87
    Height = 15
    Caption = 'Data Hora Final: '
  end
  object lblDuracao: TLabel
    Left = 8
    Top = 50
    Width = 50
    Height = 15
    Caption = 'Dura'#231#227'o: '
  end
  object Panel1: TPanel
    Left = 0
    Top = 157
    Width = 525
    Height = 41
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 156
    ExplicitWidth = 521
    object btnEnviarEmail: TBitBtn
      Left = 200
      Top = 8
      Width = 129
      Height = 25
      Caption = 'Enviar E-mail'
      TabOrder = 0
      OnClick = btnEnviarEmailClick
    end
  end
  object pb: TProgressBar
    Left = 8
    Top = 120
    Width = 505
    Height = 17
    TabOrder = 1
  end
  object chkbValidarDados: TCheckBox
    Left = 8
    Top = 74
    Width = 481
    Height = 17
    Caption = 
      'Validar Dados Antes de Enviar E-mails? (Muito Importante para qu' +
      'e tudo funcione bem!)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    StyleElements = [seClient, seBorder]
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
    Top = 8
  end
  object SQL: TSQLQuery
    MaxBlobSize = 1
    Params = <
      item
        DataType = ftWideMemo
        Name = 'nome'
        ParamType = ptInput
      end>
    SQL.Strings = (
      'select * from cliente'
      'where nome = :nome')
    SQLConnection = SQLConnection1
    Left = 160
    Top = 88
  end
  object SQLSeguradora: TSQLQuery
    MaxBlobSize = -1
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
    Left = 280
    Top = 16
  end
  object SQLCorpoEmail: TSQLQuery
    MaxBlobSize = -1
    Params = <>
    SQL.Strings = (
      'SELECT * FROM CORPO_EMAIL'
      'WHERE ID = 1')
    SQLConnection = SQLConnection1
    Left = 280
    Top = 72
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
end
