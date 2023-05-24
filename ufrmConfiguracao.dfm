object frmConfiguracao: TfrmConfiguracao
  Left = 0
  Top = 0
  Caption = 'Sancode - Configura'#231#227'o de Par'#226'metros'
  ClientHeight = 435
  ClientWidth = 586
  Color = clBtnFace
  ParentFont = True
  Position = poMainFormCenter
  StyleElements = [seClient, seBorder]
  OnCreate = FormCreate
  TextHeight = 15
  object grbConfiguracaoServidorEmail: TGroupBox
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 580
    Height = 217
    Align = alTop
    Caption = '| Configura'#231#227'o Servidor de E-mail |'
    Color = clBtnFace
    ParentColor = False
    TabOrder = 0
    StyleElements = [seClient, seBorder]
    ExplicitWidth = 576
    object Label1: TLabel
      Left = 24
      Top = 32
      Width = 76
      Height = 15
      Caption = 'Servidor SMTP'
    end
    object Label2: TLabel
      Left = 216
      Top = 32
      Width = 25
      Height = 15
      Caption = 'Host'
    end
    object Label3: TLabel
      Left = 408
      Top = 32
      Width = 22
      Height = 15
      Caption = 'Port'
    end
    object Label4: TLabel
      Left = 24
      Top = 88
      Width = 101
      Height = 15
      Caption = 'Username( E-mail )'
    end
    object Label5: TLabel
      Left = 216
      Top = 88
      Width = 50
      Height = 15
      Caption = 'Password'
    end
    object Label6: TLabel
      Left = 24
      Top = 144
      Width = 37
      Height = 15
      Caption = 'E-mail '
    end
    object edtServidorSMTP: TEdit
      Left = 24
      Top = 53
      Width = 177
      Height = 23
      CharCase = ecLowerCase
      TabOrder = 0
      Text = 'smtp.gmail.com:587'
    end
    object edtHost: TEdit
      Left = 216
      Top = 53
      Width = 177
      Height = 23
      CharCase = ecLowerCase
      TabOrder = 1
      Text = 'smtp.gmail.com'
    end
    object edtPort: TEdit
      Left = 408
      Top = 53
      Width = 57
      Height = 23
      TabOrder = 2
      Text = '587'
    end
    object edtUsername: TEdit
      Left = 24
      Top = 109
      Width = 177
      Height = 23
      CharCase = ecLowerCase
      TabOrder = 3
    end
    object edtPassword: TEdit
      Left = 216
      Top = 109
      Width = 177
      Height = 23
      PasswordChar = '*'
      TabOrder = 4
    end
    object btnVerSenha: TBitBtn
      Left = 408
      Top = 108
      Width = 97
      Height = 25
      Caption = 'Mostrar Senha'
      TabOrder = 5
      OnClick = btnVerSenhaClick
    end
    object edtEmail: TEdit
      Left = 24
      Top = 165
      Width = 177
      Height = 23
      CharCase = ecLowerCase
      TabOrder = 6
    end
    object ckbValidarDados: TCheckBox
      Left = 216
      Top = 168
      Width = 345
      Height = 17
      Caption = 'Sempre iniciar Marcado para Validar Dados ao Enviar E-mails'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      TabOrder = 7
      StyleElements = [seClient, seBorder]
    end
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 223
    Width = 586
    Height = 171
    Align = alClient
    Caption = '| Configura'#231#227'o de Diret'#243'rios'
    TabOrder = 1
    ExplicitWidth = 582
    ExplicitHeight = 170
    object Label7: TLabel
      Left = 27
      Top = 27
      Width = 110
      Height = 15
      Caption = 'Diret'#243'rio dos Anexos'
    end
    object Label8: TLabel
      Left = 27
      Top = 75
      Width = 160
      Height = 15
      Caption = 'Diret'#243'rio dos Anexos Enviados'
    end
    object Label9: TLabel
      Left = 27
      Top = 123
      Width = 185
      Height = 15
      Caption = 'Diret'#243'rio dos Anexos N'#227'o Enviados'
    end
    object edtDiretorioAnexo: TEdit
      Left = 27
      Top = 45
      Width = 369
      Height = 23
      TabOrder = 0
    end
    object edtDiretorioAnexosEnviados: TEdit
      Left = 27
      Top = 93
      Width = 369
      Height = 23
      TabOrder = 1
    end
    object edtDiretorioAnexosNaoEnviados: TEdit
      Left = 27
      Top = 141
      Width = 369
      Height = 23
      TabOrder = 2
    end
    object btnAnexosNaoEnviados: TBitBtn
      Left = 411
      Top = 139
      Width = 38
      Height = 25
      Hint = 'Clique para Selecionar um Diretorio'
      Caption = '...'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = btnAnexosNaoEnviadosClick
    end
  end
  object btnDiretorioAnexos: TBitBtn
    Left = 411
    Top = 267
    Width = 38
    Height = 25
    Hint = 'Clique para Selecionar um Diretorio'
    Caption = '...'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnClick = btnDiretorioAnexosClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 394
    Width = 586
    Height = 41
    Align = alBottom
    TabOrder = 3
    ExplicitTop = 393
    ExplicitWidth = 582
    object BitBtn1: TBitBtn
      Left = 184
      Top = 9
      Width = 97
      Height = 25
      Caption = 'Confirmar'
      TabOrder = 0
      OnClick = BitBtn1Click
    end
    object BitBtn2: TBitBtn
      Left = 300
      Top = 9
      Width = 96
      Height = 25
      Caption = 'Cancelar'
      TabOrder = 1
      OnClick = BitBtn2Click
    end
  end
  object btnAnexosEnviados: TBitBtn
    Left = 411
    Top = 315
    Width = 38
    Height = 25
    Hint = 'Clique para Selecionar um Diretorio'
    Caption = '...'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    OnClick = btnAnexosEnviadosClick
  end
  object SQLConnection1: TSQLConnection
    ConnectionName = 'SQLITECONNECTION'
    DriverName = 'Sqlite'
    LoginPrompt = False
    Params.Strings = (
      'DriverName=Sqlite'
      'Database=C:\awf\db\sancode.db')
    Left = 488
    Top = 160
  end
  object SQL: TSQLQuery
    MaxBlobSize = 1
    Params = <>
    SQL.Strings = (
      'SELECT * FROM CONFIGURACAO'
      'where id = 1')
    SQLConnection = SQLConnection1
    Left = 496
    Top = 224
  end
  object SQLAcoes: TSQLQuery
    MaxBlobSize = -1
    Params = <>
    SQLConnection = SQLConnection1
    Left = 496
    Top = 296
  end
end
