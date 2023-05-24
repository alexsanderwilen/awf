unit ufrmEmail;

interface

uses
  Winapi.Windows, Winapi.Messages, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Data.DbxSqlite, Data.FMTBcd, Data.DB, Data.SqlExpr, Winapi.ShellAPI,
  IdSMTP, IdMessage, IdAttachmentFile, IdSSLOpenSSL, IdExplicitTLSClientServerBase,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, DateUtils,
  IdMessageClient, IdSMTPBase, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack,
  IdSSL, Vcl.Imaging.jpeg, System.IOUtils, Vcl.ComCtrls, System.RegularExpressions;

type
  TfrmEmail = class(TForm)
    Panel1: TPanel;
    btnEnviarEmail: TBitBtn;
    SQLConnection1: TSQLConnection;
    SQL: TSQLQuery;
    SQLSeguradora: TSQLQuery;
    SQLCorpoEmail: TSQLQuery;
    SQLConfiguracao: TSQLQuery;
    pb: TProgressBar;
    lblEmailAtual: TLabel;
    lblTotalEmails: TLabel;
    lbDTInicial: TLabel;
    lblDTFinal: TLabel;
    lblDuracao: TLabel;
    chkbValidarDados: TCheckBox;
    procedure btnEnviarEmailClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    TotalEmails: Integer;
    PosicaoEmailAtual: Integer;
    procedure ValidarPreenchimentoParametros;
    procedure EnviarEmailVariosAnexos(const ADirectory: string);
    procedure CarregarParametros;
    function ExecCmd(const ACommand: string): string;
    function IsValidEmail(const AEmail: string): Boolean;

  public
    ctServidorSMTP: String;
    ctHost: String;
    ctPort: String;
    ctUsername: String;
    ctPassword: String;
    ctEmail: String;
    ctDiretorioAnexo: String;
    ctDiretorioAnexoEnviado: String;
    ctDiretorioAnexoNaoEnviado: String;
    ctValidarDados: String;

    procedure GetSubDirectories(const ADirectory: string; const AList: TStrings);
    procedure ListarArquivosEmPasta(const CaminhoPasta: string; ListaArquivos: TStringList);
    procedure EnviarEmailSubDirectories(const ADirectory: string);
    procedure EnviarEmailDiretorioRaiz(const ADirectory: string);
    procedure EnviarEmailComAnexo(arquivo:TStringList; nome, email, dtVencimento, cedente: String);
    procedure GetFiles(const ADirectory: string; const AList: TStrings);
    procedure EnviarWhatsAppComAnexo(vTelefone:String; ListaArquivos: TStringList);


   function ExtrairVencimento(arquivo: String): String;
   function ExtrairCedente(arquivo: String): String;
   function ExtrairSacado(arquivo: String): String;
   function ExtraiSacado(arquivo: String): String;
   function GetFantasia(PRazaoSocial: String): String;
  end;

var
  frmEmail: TfrmEmail;

implementation

uses
  Vcl.Dialogs, System.SysUtils, ufrmValidarDados;

{$R *.dfm}

{ TfrmEmail }

procedure TfrmEmail.CarregarParametros;
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
  ctValidarDados := SQLConfiguracao.FieldByName('ValidarDados').AsString;
  chkbValidarDados.Checked := ctValidarDados = 'S';
  SQLConfiguracao.Close;
end;

procedure TfrmEmail.EnviarEmailComAnexo(arquivo:TStringList; nome, email, dtVencimento,
cedente: String);
var
  SMTP: TIdSMTP;
  Msg: TIdMessage;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  I: Integer;
begin
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  SMTP := TIdSMTP.Create(nil);
  Msg := TIdMessage.Create(nil);

  for I := 0 to arquivo.Count -1 do
    TIdAttachmentFile.Create(Msg.MessageParts, Trim(arquivo.Strings[I]));

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
    Msg.ReceiptRecipient.Address := ctEmail;
    Msg.ExtraHeaders.Values['Return-Receipt-To'] := ctEmail;

    Msg.Subject := 'FATURA MENSAL FIANÇA ' + cedente + ' ' + UpperCase(FormatDateTime('mmmm', Now)) + ' - ' + nome;

    SQLCorpoEmail.Close;
    SQLCorpoEmail.Open;

    Msg.Body.Text := StringReplace(SQLCorpoEmail.FieldByName('EMAIL').AsString, '[VENCIMENTO]', dtVencimento, [rfReplaceAll, rfIgnoreCase]);

//    Msg.Headers.Add(Format('Return-Receipt-To: %s', [ctEmail]));
//    Msg.Headers.Add(Format('Disposition-Notification-To: %s', [ctEmail]));
    SQLCorpoEmail.Close;

    SMTP.Connect;
    SMTP.Authenticate;
    SMTP.Send(Msg);
    SMTP.Disconnect;
  finally
    SSLHandler.Free;
    SMTP.Free;
    Msg.Free;
  end;
end;

procedure TfrmEmail.EnviarEmailDiretorioRaiz(const ADirectory: string);
var
  NomeArquivo: string;
  dtVencimento: String;
  cedente: String;
  sacado: String;
  ListaArquivos: TStringList;
  ListaArquivo:TStringList;
  DirArquivosEnviados: String;
  DirArquivosNaoEnviados: String;
  I, j: Integer;
  ListEmail: TStringList;
  emailEnviado: Boolean;
begin
  if not SQLConnection1.Connected then
    SQLConnection1.Connected := True;

  ListaArquivos := TStringList.Create;
  try
    ListarArquivosEmPasta(IncludeTrailingPathDelimiter(ADirectory), ListaArquivos);
    for I := 0 to ListaArquivos.Count -1 do
    begin
      inc(PosicaoEmailAtual);
      pb.Position := PosicaoEmailAtual;
      lblTotalEmails.Caption := Format('%d/%d',[PosicaoEmailAtual, TotalEmails]);
      Application.ProcessMessages;
      NomeArquivo := ExtractFileName(ListaArquivos.Strings[I]);
      dtVencimento := ExtrairVencimento(ListaArquivos.Strings[I]);
      cedente := ExtrairCedente(ListaArquivos.Strings[I]);
      cedente := GetFantasia(cedente);
      sacado := ExtrairSacado(ListaArquivos.Strings[I]);
      lblEmailAtual.Caption := Format('Cliente: %s', [sacado]);
      Application.ProcessMessages;

      SQL.Close;
      SQL.SQL.Text := Format('SELECT * FROM CLIENTE WHERE NOME = %s', [UpperCase(QuotedStr(Trim(Sacado)))]);
      sql.Open;

      if not sql.IsEmpty then
      begin
        try
          ListEmail := TStringList.Create;
          ExtractStrings([';'], [], PChar(SQL.FieldByName('EMAIL').AsString), ListEmail);
          ListaArquivo := TStringList.Create;
          ListaArquivo.Add(ListaArquivos.Strings[I]);

          emailEnviado := false;
          for j := 0 to ListEmail.Count - 1 do
          begin
            if IsValidEmail(ListEmail.Strings[j]) then
            begin
              EnviarEmailComAnexo(ListaArquivo, sql.FieldByName('NOME').AsString, Trim(ListEmail.Strings[j]), dtVencimento, cedente);
              emailEnviado := true;
            end;
          end;

        finally
          FreeAndNil(ListEmail);
          FreeAndNil(ListaArquivo);
        end;

        if emailEnviado then
        begin
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
  end;
end;

procedure TfrmEmail.EnviarEmailSubDirectories(const ADirectory: string);
var
  vNomeArquivo: String;
  vDataVencimento: String;
  vCedente: String;
  vSacado: String;
  vTelefone: String;

  ListaArquivos: TStringList;
  DirArquivosEnviados: String;
  DirArquivosNaoEnviados: String;

  I, j: Integer;
  ListEmail: TStringList;
  emailEnviado: Boolean;

  processar: Boolean;
  SQLSacado: String;
  Diretorio :String;
begin
  processar := false;
  ListaArquivos := TStringList.Create;
  try
    ListarArquivosEmPasta(IncludeTrailingPathDelimiter(ADirectory), ListaArquivos);

    for I := 0 to ListaArquivos.Count -1 do
    begin
      inc(PosicaoEmailAtual);
      pb.Position := PosicaoEmailAtual;
      lblTotalEmails.Caption := Format('%d/%d',[PosicaoEmailAtual, TotalEmails]);
      Application.ProcessMessages;
      Diretorio := TPath.GetDirectoryName(ListaArquivos.Strings[I]);
      vNomeArquivo := ExtractFileName(ListaArquivos.Strings[I]);
      vDataVencimento := ExtrairVencimento(ListaArquivos.Strings[I]);
      vCedente := ExtrairCedente(ListaArquivos.Strings[I]);
      vCedente := GetFantasia(vCedente);
      vSacado := ExtrairSacado(ListaArquivos.Strings[I]);
      lblEmailAtual.Caption := Format('Cliente: %s', [vSacado]);
      Application.ProcessMessages;

      if vSacado <> '' then
      begin
        processar := true;
        break;
      end;
    end;

    if processar then
    begin
      if not SQLConnection1.Connected then
        SQLConnection1.Connected := true;

      SQL.Close;
      SQL.SQL.Text := Format('SELECT * FROM CLIENTE WHERE NOME = %s', [UpperCase(QuotedStr(Trim(vSacado)))]);
      sql.Open;

      vTelefone := SQL.FieldByName('ARQUIVO').AsString;

      if not sql.IsEmpty then
      begin
        try
          ListEmail := TStringList.Create;
          ExtractStrings([';'], [], PChar(SQL.FieldByName('EMAIL').AsString), ListEmail);

          emailEnviado := false;
          for j := 0 to ListEmail.Count - 1 do
          begin
            if IsValidEmail(ListEmail.Strings[j]) then
            begin
              EnviarEmailComAnexo(ListaArquivos, sql.FieldByName('NOME').AsString, Trim(ListEmail.Strings[j]), vDataVencimento, vCedente);
              emailEnviado := true;
            end;
          end;

        finally
          FreeAndNil(ListEmail);
        end;

        if emailEnviado then
        begin
          DirArquivosEnviados := IncludeTrailingPathDelimiter(ctDiretorioAnexoEnviado)+FormatDateTime('yyyymmdd', date);
          TDirectory.Move(Diretorio, IncludeTrailingPathDelimiter(DirArquivosEnviados)+ExtractFileName(Diretorio));
        end
        else begin
          DirArquivosNaoEnviados := IncludeTrailingPathDelimiter(ctDiretorioAnexoNaoEnviado)+FormatDateTime('yyyymmdd', date);
          TDirectory.Move(Diretorio, IncludeTrailingPathDelimiter(DirArquivosNaoEnviados)+ExtractFileName(Diretorio));
        end;

      end
      else begin
        DirArquivosNaoEnviados := IncludeTrailingPathDelimiter(ctDiretorioAnexoNaoEnviado)+FormatDateTime('yyyymmdd', date);
        TDirectory.Move(Diretorio, IncludeTrailingPathDelimiter(DirArquivosNaoEnviados)+ExtractFileName(Diretorio));
      end;
    end;
  finally
    ListaArquivos.Free;
    SQL.Close;
  end;
end;

procedure TfrmEmail.EnviarEmailVariosAnexos(const ADirectory: string);
begin
//
end;

procedure TfrmEmail.EnviarWhatsAppComAnexo(vTelefone: String;
  ListaArquivos: TStringList);
begin
//
end;

function TfrmEmail.ExtrairCedente(arquivo: String): String;
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

function TfrmEmail.ExtrairSacado(arquivo: String): String;
var
  Output: string;
  ProcessInfo: TProcessInformation;
  StartupInfo: TStartupInfo;
  SecurityInfo: TSecurityAttributes;
  PipeRead, PipeWrite: THandle;
  Buffer: array[0..1023] of AnsiChar;
  BytesRead, BytesAvail, ErrorCode: DWORD;
  cont: Integer;
  ErrorMessage : String;
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
  if CreateProcess(nil, PChar('python.exe C:\awf\get_sacado.py "' + arquivo + '"'),
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
          break;

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

function TfrmEmail.ExtrairVencimento(arquivo: String): String;
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

function TfrmEmail.ExtraiSacado(arquivo: String): String;
var
  Output: string;
begin
  Output := ExecCmd('ping 127.0.0.1');
  ShowMessage(Output);
end;



procedure TfrmEmail.FormCreate(Sender: TObject);
begin
  CarregarParametros;
end;

function TfrmEmail.GetFantasia(PRazaoSocial: String): String;
begin
  SQLSeguradora.Close;
  SQLSeguradora.ParamByName('RAZAOSOCIAL').AsString := Trim(UpperCase(PRazaoSocial));
  SQLSeguradora.Open;
  Result := SQLSeguradora.FieldByName('FANTASIA').AsString;
  SQLSeguradora.Close;
end;

procedure TfrmEmail.GetFiles(const ADirectory: string; const AList: TStrings);
var
  SearchRec: TSearchRec;
begin
  if FindFirst(ADirectory + '\*', faAnyFile, SearchRec) = 0 then
  begin
    try
      repeat
        if ((SearchRec.Attr and faDirectory) = 0) then
          AList.Add(ADirectory + '\' + SearchRec.Name);
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;
end;

procedure TfrmEmail.GetSubDirectories(const ADirectory: string;
  const AList: TStrings);
var
  SearchRec: TSearchRec;
begin
  if FindFirst(ADirectory + '\*', faDirectory, SearchRec) = 0 then
  begin
    try
      repeat
        if ((SearchRec.Attr and faDirectory) <> 0) and (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
        begin
          AList.Add(ADirectory + '\' + SearchRec.Name);
          GetSubDirectories(ADirectory + '\' + SearchRec.Name, AList);
        end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
    end;
  end;
end;

function TfrmEmail.IsValidEmail(const AEmail: string): Boolean;
const
  // Expressão regular para validar o formato de um email.
  EmailRegex = '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
var
  Regex: TRegEx;
begin
  // Cria um objeto TRegEx com a expressão regular definida acima.
  Regex := TRegEx.Create(EmailRegex);

  // Verifica se o email passado como parâmetro corresponde à expressão regular.
  Result := Regex.IsMatch(Trim(AEmail));
end;

procedure TfrmEmail.ListarArquivosEmPasta(const CaminhoPasta: string;
  ListaArquivos: TStringList);
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

procedure TfrmEmail.ValidarPreenchimentoParametros;
var
  vErro: String;
  vMensagemErro: STring;
begin
  VErro := '';
  vMensagemErro := '';
  if Trim(ctDiretorioAnexo) = EmptyStr then
  begin
    vMensagemErro := 'Diretório dos Anexos deve ser informado, verifique a tela de parâmetros!';
    VErro := 'S';
  end;

  if Trim(ctDiretorioAnexoEnviado) = EmptyStr then
  begin
    vMensagemErro := 'Diretório dos Anexo Enviado deve ser informado, verifique a tela de parâmetros!';
    VErro := 'S';
  end;

  if Trim(ctDiretorioAnexoNaoEnviado) = EmptyStr then
  begin
    vMensagemErro := 'Diretório dos Anexo Não Enviado deve ser informado, verifique a tela de parâmetros!';
    VErro := 'S';
  end;

  if VErro = 'S' then
   raise Exception.Create(vMensagemErro);
end;

procedure TfrmEmail.btnEnviarEmailClick(Sender: TObject);
var
  SubDiretorios: TStringList;
  ListaArquivos: TStringList;
  I: Integer;
  dthrInicial: TDateTime;
  dthrFinal: TDateTime;
  dthrDuracao:Integer;
  difHorario: TDateTime;
  vPossuiErros: Boolean;
  validChecked: Boolean;
begin
  vPossuiErros:= false;

  validChecked := chkbValidarDados.Checked;
  if chkbValidarDados.Checked then
  begin
    Application.CreateForm(TfrmValidarDados, frmValidarDados);
    frmValidarDados.ValidarDadosAutomaticamente := true;
    frmValidarDados.ShowModal;
    vPossuiErros := frmValidarDados.PossuiErros;
    frmValidarDados.Release;
  end;

  if vPossuiErros then
  begin
    ShowMessage('Erro nos dados foram encontrados, corrigi-los para continuar o envio de E-mail!');
    exit;
  end;

  dthrInicial := now;
  lbDTInicial.Caption := lbDTInicial.Caption + FormatDateTime('dd/mm/yyyy hh:mm:ss', dthrInicial);

  CarregarParametros;
  chkbValidarDados.Checked := validChecked;

  ValidarPreenchimentoParametros;

  SubDiretorios := TStringList.Create;
  GetSubDirectories(ctDiretorioAnexo, SubDiretorios);

  ListaArquivos := TStringList.Create;
  try
    ListarArquivosEmPasta(IncludeTrailingPathDelimiter(ctDiretorioAnexo), ListaArquivos);
    TotalEmails := SubDiretorios.Count + ListaArquivos.Count;
    PosicaoEmailAtual := 0;
  finally
    FreeAndNil(ListaArquivos);
  end;

  lblTotalEmails.Caption := Format('%d/%d',[0, TotalEmails]);
  pb.Max := TotalEmails;
  for I := 0 to SubDiretorios.Count -1 do
  begin
    EnviarEmailSubDirectories(SubDiretorios.Strings[I]);
  end;

  EnviarEmailDiretorioRaiz(ctDiretorioAnexo);

  dthrFinal := now;
  lblDTFinal.Caption := lblDTFinal.Caption + FormatDateTime('dd/mm/yyyy hh:mm:ss', dthrFinal);

  dthrDuracao := SecondsBetween(dthrFinal, dthrInicial );
  difHorario := EncodeTime(dthrDuracao div 3600, (dthrDuracao div 60) mod 60, dthrDuracao mod 60, 0);
  lblDuracao.Caption := lblDuracao.Caption + FormatDateTime('hh:nn:ss', difHorario);
  ShowMessage('Envios de email concluídos!');
end;


function TfrmEmail.ExecCmd(const ACommand: string): string;
const
  CReadBuffer = 2400;
var
  saSecurity: TSecurityAttributes;
  hRead: THandle;
  hWrite: THandle;
  suiStartup: TStartupInfo;
  piProcess: TProcessInformation;
  pBuffer: array[0..CReadBuffer] of AnsiChar;
  dRead: DWORD;
  dRunning: DWORD;
begin
  Result := '';
  saSecurity.nLength := SizeOf(TSecurityAttributes);
  saSecurity.bInheritHandle := True;
  saSecurity.lpSecurityDescriptor := nil;
  if CreatePipe(hRead, hWrite, @saSecurity, 0) then
  begin
    FillChar(suiStartup, SizeOf(TStartupInfo), #0);
    suiStartup.cb := SizeOf(TStartupInfo);
    suiStartup.hStdInput := GetStdHandle(STD_INPUT_HANDLE);
    suiStartup.hStdOutput := hWrite;
    suiStartup.hStdError := hWrite;
    suiStartup.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    suiStartup.wShowWindow := SW_HIDE;
    if CreateProcess(nil, PChar(ACommand), nil, nil, True, NORMAL_PRIORITY_CLASS, nil, nil, suiStartup, piProcess) then
    begin
      repeat
        dRunning := WaitForSingleObject(piProcess.hProcess, 100);
        Application.ProcessMessages();
        repeat
          dRead := 0;
          ReadFile(hRead, pBuffer[0], CReadBuffer, dRead, nil);
          pBuffer[dRead] := #0;
          OemToAnsi(pBuffer, pBuffer);
          Result := Result + String(pBuffer);
        until (dRead < CReadBuffer);
      until (dRunning <> WAIT_TIMEOUT);
      CloseHandle(piProcess.hProcess);
      CloseHandle(piProcess.hThread);
    end;
    CloseHandle(hRead);
    CloseHandle(hWrite);
  end;
end;

end.
