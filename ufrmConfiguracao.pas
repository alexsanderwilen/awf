unit ufrmConfiguracao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Data.DbxSqlite, Data.FMTBcd, Data.DB, Data.SqlExpr;

type
  TfrmConfiguracao = class(TForm)
    grbConfiguracaoServidorEmail: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    edtServidorSMTP: TEdit;
    edtHost: TEdit;
    edtPort: TEdit;
    edtUsername: TEdit;
    edtPassword: TEdit;
    btnVerSenha: TBitBtn;
    edtEmail: TEdit;
    GroupBox1: TGroupBox;
    Label7: TLabel;
    edtDiretorioAnexo: TEdit;
    btnDiretorioAnexos: TBitBtn;
    Panel1: TPanel;
    Label8: TLabel;
    edtDiretorioAnexosEnviados: TEdit;
    btnAnexosEnviados: TBitBtn;
    Label9: TLabel;
    edtDiretorioAnexosNaoEnviados: TEdit;
    btnAnexosNaoEnviados: TBitBtn;
    SQLConnection1: TSQLConnection;
    SQL: TSQLQuery;
    SQLAcoes: TSQLQuery;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    ckbValidarDados: TCheckBox;
    procedure btnVerSenhaClick(Sender: TObject);
    procedure btnDiretorioAnexosClick(Sender: TObject);
    procedure btnAnexosEnviadosClick(Sender: TObject);
    procedure btnAnexosNaoEnviadosClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private

  public
    { Public declarations }
  end;

var
  frmConfiguracao: TfrmConfiguracao;

implementation

{$R *.dfm}

procedure TfrmConfiguracao.btnAnexosNaoEnviadosClick(Sender: TObject);
var
  dlg: TFileOpenDialog;
begin
  dlg := TFileOpenDialog.Create(nil);
  try
    dlg.Options := [fdoPickFolders];
    if dlg.Execute then
      edtDiretorioAnexosNaoEnviados.Text := dlg.FileName;
  finally
    dlg.Free;
  end;
end;

procedure TfrmConfiguracao.BitBtn1Click(Sender: TObject);
var
  sql: String;
  vValidaDados: String;
begin
  SQL := 'UPDATE CONFIGURACAO SET ' +
         ' servidorSMTP = %s, ' +
         ' host = %s, ' +
         ' port = %s, ' +
         ' username = %s, ' +
         ' password = %s, ' +
         ' email = %s, ' +
         ' dirAnexo = %s, ' +
         ' dirAnexoEnviado = %s, ' +
         ' dirAnexoNaoEnviado = %s, ' +
         ' validarDados = %s ' +
         'WHERE ID = 1';

  SQLConnection1.Connected := False;
  SQLConnection1.Connected := True;

  if ckbValidarDados.Checked then
    vValidaDados := 'S'
  else
    vValidaDados := 'F';

  SQLAcoes.Close;
  SQLAcoes.SQL.Text :=
      Format(sql, [QuotedStr(Trim(edtServidorSMTP.Text)),
                   QuotedStr(Trim(edtHost.Text)),
                   QuotedStr(Trim(edtPort.Text)),
                   QuotedStr(Trim(edtUsername.Text)),
                   QuotedStr(Trim(edtPassword.Text)),
                   QuotedStr(Trim(edtEmail.Text)),
                   QuotedStr(Trim(edtDiretorioAnexo.Text)),
                   QuotedStr(Trim(edtDiretorioAnexosEnviados.Text)),
                   QuotedStr(Trim(edtDiretorioAnexosNaoEnviados.Text)),
                   QuotedStr(Trim(vValidaDados))]);
  SQLAcoes.ExecSQL();
  SQLConnection1.Connected := False;
  Close;
end;

procedure TfrmConfiguracao.BitBtn2Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmConfiguracao.btnAnexosEnviadosClick(Sender: TObject);
var
  dlg: TFileOpenDialog;
begin
  dlg := TFileOpenDialog.Create(nil);
  try
    dlg.Options := [fdoPickFolders];
    if dlg.Execute then
      edtDiretorioAnexosEnviados.Text := dlg.FileName;
  finally
    dlg.Free;
  end;
end;

procedure TfrmConfiguracao.btnDiretorioAnexosClick(Sender: TObject);
var
  dlg: TFileOpenDialog;
begin
  dlg := TFileOpenDialog.Create(nil);
  try
    dlg.Options := [fdoPickFolders];
    if dlg.Execute then
      edtDiretorioAnexo.Text := dlg.FileName;
  finally
    dlg.Free;
  end;
end;

procedure TfrmConfiguracao.btnVerSenhaClick(Sender: TObject);
begin
  if edtPassword.Tag = 0 then
  begin
    edtPassword.PasswordChar := edtHost.PasswordChar;
    edtPassword.Tag := 1;
    btnVerSenha.Caption := 'Ocultar Senha';
  end
  else begin
    edtPassword.PasswordChar := '*';
    edtPassword.Tag := 0;
    btnVerSenha.Caption := 'Mostrar Senha';
  end;
end;

procedure TfrmConfiguracao.FormCreate(Sender: TObject);
begin
  SQLConnection1.Connected := False;
  SQLConnection1.Connected := True;
  SQL.Close;
  SQL.Open;
  edtServidorSMTP.Text := SQL.FieldByName('servidorSMTP').AsString;
  edtHost.Text := SQL.FieldByName('Host').AsString;
  edtPort.Text := SQL.FieldByName('Port').AsString;
  edtUsername.Text := SQL.FieldByName('Username').AsString;
  edtPassword.Text := SQL.FieldByName('Password').AsString;
  edtEmail.Text := SQL.FieldByName('Email').AsString;
  edtDiretorioAnexo.Text := SQL.FieldByName('dirAnexo').AsString;
  edtDiretorioAnexosEnviados.Text := SQL.FieldByName('dirAnexoEnviado').AsString;
  edtDiretorioAnexosNaoEnviados.Text := SQL.FieldByName('dirAnexoNaoEnviado').AsString;
  ckbValidarDados.Checked := SQL.FieldByName('validarDados').AsString = 'S';

  SQL.Close;
  SQLConnection1.Connected := False;
end;

end.
