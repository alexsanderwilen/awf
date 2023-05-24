unit ufrmPrincipal;

interface


uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SynPDF, SynCommons, Winapi.ShellAPI,
  IdSMTP, IdMessage, IdAttachmentFile, IdSSLOpenSSL, IdExplicitTLSClientServerBase,
  Vcl.StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdMessageClient, IdSMTPBase, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack,
  IdSSL, Data.DB, Data.SqlExpr, Data.DbxSqlite, Data.FMTBcd, Vcl.Menus,
  Vcl.ExtCtrls, Vcl.Imaging.jpeg, Vcl.Buttons, System.IOUtils, Vcl.ComCtrls;

type
  TfrmPrincipal = class(TForm)
    Memo1: TMemo;
    SQLConnection1: TSQLConnection;
    SQL: TSQLQuery;
    MainMenu1: TMainMenu;
    Cadastro1: TMenuItem;
    Cliente1: TMenuItem;
    N1: TMenuItem;
    Sair1: TMenuItem;
    Panel1: TPanel;
    btnEnviarEmail: TButton;
    Configurao1: TMenuItem;
    SQLConfiguracao: TSQLQuery;
    Image1: TImage;
    Seguradora1: TMenuItem;
    SQLSeguradora: TSQLQuery;
    CorpodoEmail1: TMenuItem;
    SQLCorpoEmail: TSQLQuery;
    EnviarEmail1: TMenuItem;
    StatusBar1: TStatusBar;
    Utilitario1: TMenuItem;
    ValidacaodeDados1: TMenuItem;
    procedure btnEnviarEmailClick(Sender: TObject);
    procedure Cliente1Click(Sender: TObject);
    procedure Configurao1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Seguradora1Click(Sender: TObject);
    procedure CorpodoEmail1Click(Sender: TObject);
    procedure EnviarEmail1Click(Sender: TObject);
    procedure ValidacaodeDados1Click(Sender: TObject);
  private
    ctServidorSMTP: String;
    ctHost: String;
    ctPort: String;
    ctUsername: String;
    ctPassword: String;
    ctEmail: String;
    ctDiretorioAnexo: String;
    ctDiretorioAnexoEnviado: String;
    ctDiretorioAnexoNaoEnviado: String;
   procedure CarregarParametros;
   procedure EnviarEmailComAnexo(arquivo, nome, email, dtVencimento, cedente: String);
   procedure ListarArquivosEmPasta(const CaminhoPasta: string; ListaArquivos: TStringList);
   function ExtrairVencimento(arquivo: String): String;
   function ExtrairCedente(arquivo: String): String;
   function GetFantasia(RazaoSocial: String): String;

  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

uses ufrmCadCliente, ufrmConfiguracao, ufrmCadSeguradora, ufrmCadCorpoEmail,
  ufrmEmail, ufrmValidarDados;

{ TForm1 }


procedure TfrmPrincipal.btnEnviarEmailClick(Sender: TObject);
var
  NomeArquivo: string;
  dtVencimento: String;
  cedente: String;
  ListaArquivos: TStringList;
  DirArquivosEnviados: String;
  DirArquivosNaoEnviados: String;
  I, j: Integer;
  ListEmail: TStringList;
begin
  exit;
  if not SQLConnection1.Connected then
    SQLConnection1.Connected := True;

  ListaArquivos := TStringList.Create;
  try
    ListarArquivosEmPasta(IncludeTrailingPathDelimiter(ctDiretorioAnexo), ListaArquivos);

    memo1.Lines.Clear;
    for I := 0 to ListaArquivos.Count -1 do
    begin
      NomeArquivo := ExtractFileName(ListaArquivos.Strings[I]);
      dtVencimento := ExtrairVencimento(ListaArquivos.Strings[I]);
      cedente := ExtrairCedente(ListaArquivos.Strings[I]);
      cedente := GetFantasia(cedente);

      SQL.Close;
      SQL.ParamByName('arquivo').AsString := UpperCase(NomeArquivo);
      sql.Open;

      if not sql.IsEmpty then
      begin
        memo1.Lines.Add(ListaArquivos.Strings[I]+ '     -      ' + NomeArquivo);
        try
          ListEmail := TStringList.Create;
          ExtractStrings([';'], [], PChar(SQL.FieldByName('EMAIL').AsString), ListEmail);

          for j := 0 to ListEmail.Count - 1 do
            EnviarEmailComAnexo(ListaArquivos.Strings[I], sql.FieldByName('NOME').AsString, Trim(ListEmail.Strings[j]), dtVencimento, cedente);
        finally
          FreeAndNil(ListEmail);
        end;

        DirArquivosEnviados := IncludeTrailingPathDelimiter(ctDiretorioAnexoEnviado)+FormatDateTime('yyyymmdd', date);
        if not DirectoryExists(DirArquivosEnviados) then
          ForceDirectories(DirArquivosEnviados);

        MoveFile(PChar(ListaArquivos.Strings[I]), PChar(IncludeTrailingPathDelimiter(DirArquivosEnviados) + NomeArquivo));
      end
      else begin
        DirArquivosNaoEnviados := IncludeTrailingPathDelimiter(ctDiretorioAnexoNaoEnviado)+FormatDateTime('yyyymmdd', date);
        if not DirectoryExists(DirArquivosNaoEnviados) then
          ForceDirectories(DirArquivosNaoEnviados);

        MoveFile(PChar(ListaArquivos.Strings[I]), PChar(IncludeTrailingPathDelimiter(DirArquivosNaoEnviados) + NomeArquivo));
      end;
    end;
  finally
    ListaArquivos.Free;
    SQL.Close;
    ShowMessage('Envios de email concluídos!');
  end;
end;

procedure TfrmPrincipal.CarregarParametros;
begin
  if not SQLConnection1.Connected then
    SQLConnection1.Connected := True;

  SQLConfiguracao.Close;
  SQLConfiguracao.Open;
  ctServidorSMTP := SQLConfiguracao.FieldByName('servidorSMTP').AsString;
  ctHost := SQLConfiguracao.FieldByName('Host').AsString;
  ctPort := SQLConfiguracao.FieldByName('Port').AsString;
  ctUsername := SQLConfiguracao.FieldByName('Username').AsString;
  ctPassword := SQLConfiguracao.FieldByName('Password').AsString;
  ctEmail := SQLConfiguracao.FieldByName('Email').AsString;
  ctDiretorioAnexo := SQLConfiguracao.FieldByName('dirAnexo').AsString;
  ctDiretorioAnexoEnviado := SQLConfiguracao.FieldByName('dirAnexoEnviado').AsString;
  ctDiretorioAnexoNaoEnviado := SQLConfiguracao.FieldByName('dirAnexoNaoEnviado').AsString;
  SQLConfiguracao.Close;
end;

procedure TfrmPrincipal.Cliente1Click(Sender: TObject);
begin
  Application.CreateForm(TfrmCadCliente, frmCadCliente);
  frmCadCliente.ShowModal;
  frmCadCliente.Release;
end;

procedure TfrmPrincipal.Configurao1Click(Sender: TObject);
begin
  Application.CreateForm(TfrmConfiguracao, frmConfiguracao);
  frmConfiguracao.ShowModal;
  frmConfiguracao.Release;
  CarregarParametros;
end;

procedure TfrmPrincipal.CorpodoEmail1Click(Sender: TObject);
begin
  Application.CreateForm(TfrmCorpoEmail, frmCorpoEmail);
  frmCorpoEmail.ShowModal;
  frmCorpoEmail.Release;
end;

procedure TfrmPrincipal.EnviarEmail1Click(Sender: TObject);
begin
  Application.CreateForm(TfrmEmail, frmEmail);
  frmEmail.ShowModal;
  frmEmail.Release;
end;

procedure TfrmPrincipal.EnviarEmailComAnexo(arquivo, nome, email, dtVencimento, cedente: String);
var
  SMTP: TIdSMTP;
  Msg: TIdMessage;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  SMTP := TIdSMTP.Create(nil);
  Msg := TIdMessage.Create(nil);

  TIdAttachmentFile.Create(Msg.MessageParts, Trim(arquivo)); // Substitua pelo caminho do arquivo que deseja enviar
  try
    SSLHandler.Destination := ctServidorSMTP; // ou outro servidor SMTP
    SSLHandler.Host := ctHost; // ou outro servidor SMTP
    SSLHandler.Port := StrToInt(Trim(ctPort)); // ou outra porta

    SMTP.IOHandler := SSLHandler;
    SMTP.UseTLS := utUseExplicitTLS;
    SMTP.AuthType := satDefault;
    SMTP.Username := ctUsername; // coloque aqui o seu email
    SMTP.Password := ctPassword; // coloque aqui a sua senha

    SMTP.Host := ctHost; // ou outro servidor SMTP
    SMTP.Port := StrToInt(Trim(ctPort)); // ou outra porta

    Msg.From.Address := ctEmail; // coloque aqui o seu email
    Msg.Recipients.Add.Address := email; // coloque aqui o email do destinatário

    Msg.Subject := 'FATURA MENSAL FIANÇA ' + cedente + ' ' + UpperCase(FormatDateTime('mmmm', Now)) + ' - ' + nome;

    SQLCorpoEmail.Close;
    SQLCorpoEmail.Open;

    Msg.Body.Text := StringReplace(SQLCorpoEmail.FieldByName('EMAIL').AsString, '[VENCIMENTO]', dtVencimento, [rfReplaceAll, rfIgnoreCase]);
    SQLCorpoEmail.Close;

    SMTP.Connect;
    SMTP.Send(Msg);
    SMTP.Disconnect;
  finally
    SSLHandler.Free;
    SMTP.Free;
    Msg.Free;
  end;
end;

//function TfrmPrincipal.ExtrairCedente(arquivo: String): String;
//var
//  CommandLine: string;
//  Output: TStringList;
//begin
//  CommandLine := '/c python C:\awf\cedente_boleto.py "' + arquivo + '"';
//  ShellExecute(0, nil, 'cmd.exe', PChar(CommandLine), nil, SW_HIDE);
//
//  Output := TStringList.Create;
//  try
//    Output.LoadFromFile('C:\awf\dados_cedente.txt');
//    Memo1.Lines.AddStrings(Output);
//    Result := Output.Strings[0];
//  finally
//    Output.Free;
//  end;
//end;



function TfrmPrincipal.ExtrairVencimento(arquivo: String): String;
var
  Output: string;
  ProcessInfo: TProcessInformation;
  StartupInfo: TStartupInfo;
  SecurityInfo: TSecurityAttributes;
  PipeRead, PipeWrite: THandle;
  Buffer: array[0..1023] of AnsiChar;
  BytesRead, BytesAvail: DWORD;
  cont: Integer;
begin
  cont := 0;
  Result := '';

  // Cria a estrutura de segurança para as pipes de leitura e escrita
  SecurityInfo.nLength := SizeOf(TSecurityAttributes);
  SecurityInfo.bInheritHandle := True;
  SecurityInfo.lpSecurityDescriptor := nil;

  // Cria as pipes de leitura e escrita
  if not CreatePipe(PipeRead, PipeWrite, @SecurityInfo, 0) then
  begin
    ShowMessage('Erro ao criar pipes!');
    Exit;
  end;

  // Define as propriedades da estrutura de inicialização
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
  StartupInfo.wShowWindow := SW_HIDE;
  StartupInfo.hStdInput := GetStdHandle(STD_INPUT_HANDLE);
  StartupInfo.hStdOutput := PipeWrite;
  StartupInfo.hStdError := PipeWrite;

  // Executa o processo
  if CreateProcess(nil, PChar('python.exe C:\awf\data_boleto.py "' + arquivo + '"'),
    nil, nil, True, 0, nil, nil, StartupInfo, ProcessInfo) then
  begin
    CloseHandle(PipeWrite);

    // Lê a saída do processo
    repeat
      PeekNamedPipe(PipeRead, nil, 0, nil, @BytesAvail, nil);
      if BytesAvail > 0 then
      begin
        if BytesAvail > SizeOf(Buffer) then BytesAvail := SizeOf(Buffer);
        if not ReadFile(PipeRead, Buffer, BytesAvail, BytesRead, nil) then Break;
        Output := Output + Copy(Buffer, 1, BytesRead);
      end;
      inc(cont);

      if cont > 100000 then
        output := ' ';
    until Output <> '';

    CloseHandle(PipeRead);
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(ProcessInfo.hProcess);
  end
  else
  begin
    ShowMessage('Erro ao iniciar processo!');
    CloseHandle(PipeRead);
    CloseHandle(PipeWrite);
    Exit;
  end;

  Result := Trim(Output);
end;


//function TfrmPrincipal.ExtrairVencimento(arquivo: String): String;
//var
//  CommandLine: string;
//  Output: TStringList;
//begin
//
// if CreateProcess(nil, PChar(CmdLine), nil, nil, False, 0, nil, nil, StartupInfo, ProcessInformation) then
//  begin
//    WaitForSingleObject(ProcessInformation.hProcess, INFINITE);
//    CloseHandle(ProcessInformation.hProcess);
//    CloseHandle(ProcessInformation.hThread);
//    Result := True;
//  end;
//
//
//
//
//  CommandLine := '/c python C:\awf\data_boleto.py "' + arquivo + '"';
//  ShellExecute(0, nil, 'cmd.exe', PChar(CommandLine), nil, SW_HIDE);
//
//  // Lê o conteúdo do arquivo de saída
//  Output := TStringList.Create;
//  try
//    Output.LoadFromFile('C:\awf\datas_vencimento.txt');
//    // Faça o que quiser com o conteúdo do arquivo
//    // por exemplo, exiba o conteúdo em um memo:
//    Memo1.Lines.AddStrings(Output);
//    Result := Output.Strings[0];
//  finally
//    Output.Free;
//  end;
//
//end;


function TfrmPrincipal.ExtrairCedente(arquivo: String): String;
var
  Output: string;
  ProcessInfo: TProcessInformation;
  StartupInfo: TStartupInfo;
  SecurityInfo: TSecurityAttributes;
  PipeRead, PipeWrite: THandle;
  Buffer: array[0..1023] of AnsiChar;
  BytesRead, BytesAvail: DWORD;
  cont: Integer;
begin
  cont := 0;
  Result := '';

  // Cria a estrutura de segurança para as pipes de leitura e escrita
  SecurityInfo.nLength := SizeOf(TSecurityAttributes);
  SecurityInfo.bInheritHandle := True;
  SecurityInfo.lpSecurityDescriptor := nil;

  // Cria as pipes de leitura e escrita
  if not CreatePipe(PipeRead, PipeWrite, @SecurityInfo, 0) then
  begin
    ShowMessage('Erro ao criar pipes!');
    Exit;
  end;

  // Define as propriedades da estrutura de inicialização
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
  StartupInfo.wShowWindow := SW_HIDE;
  StartupInfo.hStdInput := GetStdHandle(STD_INPUT_HANDLE);
  StartupInfo.hStdOutput := PipeWrite;
  StartupInfo.hStdError := PipeWrite;

  // Executa o processo
  if CreateProcess(nil, PChar('python.exe C:\awf\cedente_boleto.py "' + arquivo + '"'),
    nil, nil, True, 0, nil, nil, StartupInfo, ProcessInfo) then
  begin
    CloseHandle(PipeWrite);

    // Lê a saída do processo
    repeat
      PeekNamedPipe(PipeRead, nil, 0, nil, @BytesAvail, nil);
      if BytesAvail > 0 then
      begin
        if BytesAvail > SizeOf(Buffer) then
          BytesAvail := SizeOf(Buffer);
        if not ReadFile(PipeRead, Buffer, BytesAvail, BytesRead, nil) then
          Break;
        Output := Output + Copy(Buffer, 1, BytesRead);
      end;
      inc(cont);

      if cont > 1000000 then
        output := ' ';
    until Output <> '';

    CloseHandle(PipeRead);
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(ProcessInfo.hProcess);
  end
  else
  begin
    ShowMessage('Erro ao iniciar processo!');
    CloseHandle(PipeRead);
    CloseHandle(PipeWrite);
    Exit;
  end;

  Result := Trim(Output);
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  CarregarParametros;
end;

function TfrmPrincipal.GetFantasia(RazaoSocial: String): String;
begin
  SQLSeguradora.Close;
  SQLSeguradora.ParamByName('RAZAOSOCIAL').AsString := Trim(RazaoSocial);
  SQLSeguradora.Open;
  Result := SQLSeguradora.FieldByName('FANTASIA').AsString;
  SQLSeguradora.Close;
end;

procedure TfrmPrincipal.ListarArquivosEmPasta(const CaminhoPasta: string; ListaArquivos: TStringList);
var
  Arquivo: TSearchRec;
  PathCompleto: string;
begin
  if FindFirst(CaminhoPasta + '*.*', faAnyFile, Arquivo) = 0 then
  begin
    repeat
      if (Arquivo.Name <> '.') and (Arquivo.Name <> '..') then
      begin
        PathCompleto := IncludeTrailingPathDelimiter(CaminhoPasta) + Arquivo.Name;
        if (Arquivo.Attr and faDirectory) <> faDirectory then
        begin
          ListaArquivos.Add(PathCompleto);
        end;
      end;
    until FindNext(Arquivo) <> 0;
    FindClose(Arquivo);
  end;
end;

procedure TfrmPrincipal.Seguradora1Click(Sender: TObject);
begin
  Application.CreateForm(TfrmCadSeguradora, frmCadSeguradora);
  frmCadSeguradora.ShowModal;
  frmCadSeguradora.Release;
end;

procedure TfrmPrincipal.ValidacaodeDados1Click(Sender: TObject);
begin
  Application.CreateForm(TfrmValidarDados, frmValidarDados);
  frmValidarDados.ShowModal;
  frmValidarDados.Release;
end;

{ TfrmPrincipal }

end.
