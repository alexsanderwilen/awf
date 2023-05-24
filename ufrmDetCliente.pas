unit ufrmDetCliente;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Data.DbxSqlite, Data.FMTBcd, Data.DB, Data.SqlExpr;


Const
   ctInserir = 0;
   ctAlterar = 1;
   ctDeletar = 2;

type
  TfrmDetCliente = class(TForm)
    edtID: TEdit;
    lblID: TLabel;
    edtNome: TEdit;
    lblNome: TLabel;
    edtEmail: TEdit;
    lblEmail: TLabel;
    edtArquivo: TEdit;
    lblArquivo: TLabel;
    Panel1: TPanel;
    btnSalvar: TBitBtn;
    btnCancelar: TBitBtn;
    SQLConnection1: TSQLConnection;
    SQL: TSQLQuery;
    SQLid: TLargeintField;
    SQLnome: TWideStringField;
    SQLemail: TWideStringField;
    SQLarquivo: TWideStringField;
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
  private
    { Private declarations }
  public
    Acao: Integer;
  end;

var
  frmDetCliente: TfrmDetCliente;

implementation

{$R *.dfm}

procedure TfrmDetCliente.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmDetCliente.btnSalvarClick(Sender: TObject);
begin
  if(Trim(edtNome.Text) = '')then
  begin
    ShowMessage('O Nome nao pode ficar vazio, verifique!');
    exit;
  end;

  if(Trim(edtEmail.Text) = '')then
  begin
    ShowMessage('O E-mail nao pode ficar vazio, verifique!');
    exit;
  end;

  if(Trim(edtArquivo.Text) = '')then
  begin
    ShowMessage('O Arquivo nao pode ficar vazio, verifique!');
    exit;
  end;

  case Acao of
    ctInserir:Begin
      try
       SQL.Close;
       SQL.SQL.Text := Format('INSERT INTO CLIENTE(NOME, EMAIL, ARQUIVO)VALUES(%s, %s, %s)',
                      [QuotedStr(Trim(edtNome.Text)), QuotedStr(Trim(edtEmail.text)), QuotedStr(Trim(edtArquivo.text))]);
       SQL.execSql;
       ShowMessage('Cliente inserido com Sucesso!');
       close;
      except
        on e: Exception do
           ShowMessage('Erro ao cadastrar Cliente.' + #13 + e.message);
      end;
    End;

    ctAlterar: Begin
      try
       SQL.Close;
       SQL.SQL.Text := Format('UPDATE CLIENTE SET NOME = %s, EMAIL = %s, ARQUIVO = %s WHERE ID = %s',
                      [QuotedStr(Trim(edtNome.Text)), QuotedStr(Trim(edtEmail.text)), QuotedStr(Trim(edtArquivo.text)), Trim(edtID.text)]);
       SQL.execSql;
       ShowMessage('Cliente atualizado com Sucesso!');
       close;
      except
        on e: Exception do
           ShowMessage('Erro ao atualizar Cliente.' + #13 + e.message);
      end;
    End;

    ctDeletar: begin
      try
       SQL.Close;
       SQL.SQL.Text := Format('DELETE FROM CLIENTE WHERE ID = %s',
                      [Trim(edtID.text)]);
       SQL.execSql;
       ShowMessage('Cliente apagado com Sucesso!');
       close;
      except
        on e: Exception do
           ShowMessage('Erro ao apagar Cliente.' + #13 + e.message);
      end;
    end;
  end;
end;

end.
