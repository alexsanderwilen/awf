unit ufrmDetSeguradora;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DbxSqlite, Data.FMTBcd, Data.DB,
  Data.SqlExpr, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;


Const
   ctInserir = 0;
   ctAlterar = 1;
   ctDeletar = 2;

type
  TfrmDetSeguradora = class(TForm)
    SQLConnection1: TSQLConnection;
    SQL: TSQLQuery;
    SQLid: TLargeintField;
    SQLnome: TWideStringField;
    SQLemail: TWideStringField;
    SQLarquivo: TWideStringField;
    Panel1: TPanel;
    btnSalvar: TBitBtn;
    btnCancelar: TBitBtn;
    lblID: TLabel;
    lblNome: TLabel;
    lblEmail: TLabel;
    edtID: TEdit;
    edtRazaoSocial: TEdit;
    edtFantasia: TEdit;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    { Private declarations }
  public
    Acao: Integer;
  end;

var
  frmDetSeguradora: TfrmDetSeguradora;

implementation

{$R *.dfm}

procedure TfrmDetSeguradora.btnCancelarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmDetSeguradora.btnSalvarClick(Sender: TObject);
begin
  if(Trim(edtRazaoSocial.Text) = '')then
  begin
    ShowMessage('A Razão Social não pode ficar vazio, verifique!');
    exit;
  end;

  if(Trim(edtFantasia.Text) = '')then
  begin
    ShowMessage('O E-mail não pode ficar vazio, verifique!');
    exit;
  end;


  case Acao of
    ctInserir:Begin
      try
       SQL.Close;
       SQL.SQL.Text := Format('INSERT INTO SEGURADORA(NOME, FANTASIA)VALUES(%s, %s)',
                      [QuotedStr(Trim(edtRazaoSocial.Text)), QuotedStr(Trim(edtFantasia.text))]);
       SQL.execSql;
       ShowMessage('Seguradora inserida com Sucesso!');
       close;
      except
        on e: Exception do
           ShowMessage('Erro ao cadastrar Seguradora.' + #13 + e.message);
      end;
    End;

    ctAlterar: Begin
      try
       SQL.Close;
       SQL.SQL.Text := Format('UPDATE SEGURADORA SET NOME = %s, FANTASIA = %s WHERE ID = %s',
                      [QuotedStr(Trim(edtRazaoSocial.Text)), QuotedStr(Trim(edtFantasia.text)), Trim(edtID.text)]);
       SQL.execSql;
       ShowMessage('Seguradora atualizada com Sucesso!');
       close;
      except
        on e: Exception do
           ShowMessage('Erro ao atualizar Seguradora.' + #13 + e.message);
      end;
    End;

    ctDeletar: begin
      try
       SQL.Close;
       SQL.SQL.Text := Format('DELETE FROM SEGURADORA WHERE ID = %s',
                      [Trim(edtID.text)]);
       SQL.execSql;
       ShowMessage('Seguradora apagado com Sucesso!');
       close;
      except
        on e: Exception do
           ShowMessage('Erro ao apagar Seguradora.' + #13 + e.message);
      end;
    end;
  end;
end;

end.
