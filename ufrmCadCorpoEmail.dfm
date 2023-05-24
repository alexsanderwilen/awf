object frmCorpoEmail: TfrmCorpoEmail
  Left = 0
  Top = 0
  Caption = 'Sancode - Defina o Corpo do  E-mail'
  ClientHeight = 442
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 401
    Width = 628
    Height = 41
    Align = alBottom
    TabOrder = 0
    ExplicitLeft = 232
    ExplicitTop = 224
    ExplicitWidth = 185
    object BitBtn1: TBitBtn
      Left = 168
      Top = 8
      Width = 121
      Height = 25
      Caption = 'Confirmar'
      TabOrder = 0
      OnClick = BitBtn1Click
    end
    object BitBtn2: TBitBtn
      Left = 320
      Top = 8
      Width = 113
      Height = 25
      Caption = 'Cancelar'
      TabOrder = 1
      OnClick = BitBtn2Click
    end
  end
  object Memo1: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 622
    Height = 395
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 232
    ExplicitTop = 200
    ExplicitWidth = 185
    ExplicitHeight = 89
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
      'SELECT * FROM CORPO_EMAIL'
      'WHERE ID = 1')
    SQLConnection = SQLConnection1
    Left = 92
    Top = 192
    object SQLID: TLargeintField
      FieldName = 'ID'
      Required = True
    end
    object SQLEMAIL: TWideMemoField
      FieldName = 'EMAIL'
      BlobType = ftWideMemo
      Size = 1
    end
  end
  object SQLCorpoEmail: TSQLQuery
    MaxBlobSize = 1
    Params = <>
    SQL.Strings = (
      'SELECT * FROM CORPO_EMAIL'
      'WHERE ID = 1')
    SQLConnection = SQLConnection1
    Left = 92
    Top = 256
    object LargeintField1: TLargeintField
      FieldName = 'ID'
      Required = True
    end
    object WideMemoField1: TWideMemoField
      FieldName = 'EMAIL'
      BlobType = ftWideMemo
      Size = 1
    end
  end
end
