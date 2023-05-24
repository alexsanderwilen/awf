unit ufrmCadCorpoEmail;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Data.DbxSqlite, Data.FMTBcd, Data.DB, Data.SqlExpr;

type
  TfrmCorpoEmail = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Memo1: TMemo;
    SQLConnection1: TSQLConnection;
    SQL: TSQLQuery;
    SQLID: TLargeintField;
    SQLEMAIL: TWideMemoField;
    SQLCorpoEmail: TSQLQuery;
    LargeintField1: TLargeintField;
    WideMemoField1: TWideMemoField;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCorpoEmail: TfrmCorpoEmail;

implementation

{$R *.dfm}

procedure TfrmCorpoEmail.BitBtn1Click(Sender: TObject);
begin
  SQLCorpoEmail.Close;
  SQLCorpoEmail.SQL.Text := Format('UPDATE CORPO_EMAIL SET EMAIL = %S WHERE ID = 1', [QuotedStr(Memo1.Text)]);
  SQLCorpoEmail.ExecSQL;
  Close;
end;

procedure TfrmCorpoEmail.BitBtn2Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmCorpoEmail.FormCreate(Sender: TObject);
begin
  SQL.Close;
  SQL.Open;

  Memo1.Text := SQL.FieldByName('EMAIL').AsString;
  SQL.Close;
end;

end.
