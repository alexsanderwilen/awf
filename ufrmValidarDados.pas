unit ufrmValidarDados;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls, Data.DbxSqlite,
  Data.FMTBcd, Data.SqlExpr, Datasnap.DBClient, System.RegularExpressions;

type
  TfrmValidarDados = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    dbgErros: TDBGrid;
    Splitter1: TSplitter;
    bitValidar: TBitBtn;
    pb: TProgressBar;
    lblContador: TLabel;
    SQLConnection1: TSQLConnection;
    SQLConfiguracao: TSQLQuery;
    SQLSeguradora: TSQLQuery;
    cdsErros: TClientDataSet;
    cdsErrosid: TIntegerField;
    cdsErrosVencimento: TStringField;
    cdsErroscedente: TStringField;
    cdsErrossacado: TStringField;
    cdsErrosemail: TStringField;
    ds: TDataSource;
    cdsErrosarquivo: TStringField;
    SQL: TSQLQuery;
    Timer1: TTimer;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure bitValidarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
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
    vId: Integer;
    TotalEmails: Integer;
    PosicaoEmailAtual: Integer;
    PosicaoAtual: Integer;
    tempo: Integer;
    revalidar: Boolean;
    procedure CarregarParametros;
    procedure ValidarPreenchimentoParametros;
    procedure GetSubDirectories(const ADirectory: string; const AList: TStrings);
    procedure ListarArquivosEmPasta(const CaminhoPasta: string; ListaArquivos: TStringList);
    procedure ValidaArquivosEmSubDiretorios;
    procedure ValidaArquivosEmDireritosRaiz;

    function ExtrairVencimento(arquivo: String): String;
    function ExtrairCedente(arquivo: String): String;
    function ExtrairSacado(arquivo: String): String;
    function GetFantasia(PRazaoSocial: String): String;
    function GetSacado(PSacado: String; Campo: STring): String;
    function IsValidEmail(const AEmail: string): Boolean;
  public
    PossuiErros: Boolean;
    ValidarDadosAutomaticamente: Boolean;
  end;

var
  frmValidarDados: TfrmValidarDados;

implementation

{$R *.dfm}

uses ufrmCadCliente, ufrmCadSeguradora;

procedure TfrmValidarDados.BitBtn1Click(Sender: TObject);
begin
  Application.CreateForm(TfrmCadCliente, frmCadCliente);
  frmCadCliente.ShowModal;
  frmCadCliente.Release;
end;

procedure TfrmValidarDados.BitBtn2Click(Sender: TObject);
begin
  Application.CreateForm(TfrmCadSeguradora, frmCadSeguradora);
  frmCadSeguradora.ShowModal;
  frmCadSeguradora.Release;
end;

procedure TfrmValidarDados.bitValidarClick(Sender: TObject);
var
  fechar: Boolean;
begin
  vId := 0;
  fechar := true;
  PosicaoAtual := 0;
  TotalEmails := 0;
  PossuiErros  := false;

  if not cdsErros.Active then
    cdsErros.CreateDataSet;

  cdsErros.EmptyDataSet;

  ValidaArquivosEmSubDiretorios;
  ValidaArquivosEmDireritosRaiz;
  PossuiErros := cdsErros.RecordCount > 0;
  revalidar := bitValidar.Caption = 'Revalidar';
  if PossuiErros then
  begin
    bitValidar.Caption := 'Revalidar';
    revalidar := true;
  end;

  if (ValidarDadosAutomaticamente) and
     (revalidar) and
     not(PossuiErros) then
    Timer1.Enabled := True;
end;

procedure TfrmValidarDados.CarregarParametros;
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

function TfrmValidarDados.ExtrairCedente(arquivo: String): String;
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

function TfrmValidarDados.ExtrairSacado(arquivo: String): String;
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

function TfrmValidarDados.ExtrairVencimento(arquivo: String): String;
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

procedure TfrmValidarDados.FormActivate(Sender: TObject);
begin
  if ValidarDadosAutomaticamente then
  begin
    bitValidarClick(sender);
    Timer1.Enabled := not PossuiErros;
  end;
end;

procedure TfrmValidarDados.FormCreate(Sender: TObject);
begin
  ValidarDadosAutomaticamente := false;
  Timer1.Enabled := false;
  tempo := 0;
  PossuiErros := false;
  revalidar := false;
end;

function TfrmValidarDados.GetFantasia(PRazaoSocial: String): String;
begin
  SQLSeguradora.Close;
  SQLSeguradora.ParamByName('RAZAOSOCIAL').AsString := Trim(UpperCase(PRazaoSocial));
  SQLSeguradora.Open;
  Result := SQLSeguradora.FieldByName('FANTASIA').AsString;
  SQLSeguradora.Close;
end;

function TfrmValidarDados.GetSacado(PSacado: String; Campo: STring): String;
begin
  if Trim(PSacado) = '' then
  begin
    Result := '';
    exit;
  end;

  SQL.Close;
  SQL.SQL.Text := 'SELECT * FROM CLIENTE WHERE NOME = ' + QuotedStr(Trim(UpperCase(PSacado)));
  SQL.Open;
  Result := SQL.FieldByName(Campo).AsString;
  SQL.Close;
end;

procedure TfrmValidarDados.GetSubDirectories(const ADirectory: string;
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

function TfrmValidarDados.IsValidEmail(const AEmail: string): Boolean;
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

procedure TfrmValidarDados.ListarArquivosEmPasta(const CaminhoPasta: string;
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

procedure TfrmValidarDados.Timer1Timer(Sender: TObject);
begin
  inc(tempo);
  if tempo = 2 then
  begin
    Timer1.Enabled := false;
    Close;
  end;
end;

procedure TfrmValidarDados.ValidaArquivosEmDireritosRaiz;
var
  I, J, k: Integer;

  SubDiretorios: TStringList;
  ListaArquivos: TStringList;
  listaEmails: TStringList;


  dthrInicial: TDateTime;
  dthrFinal: TDateTime;
  dthrDuracao:Integer;
  difHorario: TDateTime;

  vDataVencimento: String;
  vCedente: String;
  vSacado: String;
  vTelefone: String;
  vEmail: String;

  DirArquivo: String;
  vencimentoErro: STring;
  cedenteErroArquivo: String;
  cedenteErroCadastro: String;
  sacadoErroArquivo: String;
  sacadoErroCadastro: String;
  emailErro: String;
  emailValido: Boolean;

  tudoOk: Boolean;

  procedure LimparVariaveis;
  begin
    vDataVencimento := '';
    vCedente := '';
    vSacado := '';
    vTelefone := '';
    vEmail := '';


    dirArquivo := '';
    vencimentoErro := '';
    cedenteErroArquivo := '';
    cedenteErroCadastro := '';
    sacadoErroArquivo := '';
    sacadoErroCadastro := '';
    emailErro := '';

    tudoOk := false;

  end;
begin
  dthrInicial := now;
  listaEmails := TStringList.Create;
  LimparVariaveis;
  CarregarParametros;
  ValidarPreenchimentoParametros;

  SubDiretorios := TStringList.Create;
  GetSubDirectories(ctDiretorioAnexo, SubDiretorios);

  ListaArquivos := TStringList.Create;
  try
    ListarArquivosEmPasta(IncludeTrailingPathDelimiter(ctDiretorioAnexo), ListaArquivos);
    TotalEmails := SubDiretorios.Count + ListaArquivos.Count;
  finally
    FreeAndNil(ListaArquivos);
  end;

  ListaArquivos := TStringList.Create;
  lblContador.Caption := Format('%d/%d',[PosicaoAtual, TotalEmails]);
  pb.Max := TotalEmails;
    ListaArquivos.Clear;
    ListarArquivosEmPasta(IncludeTrailingPathDelimiter(ctDiretorioAnexo), ListaArquivos);
    for j := 0 to ListaArquivos.Count -1 do
    begin
      inc(PosicaoAtual);
      pb.Position := PosicaoAtual;
      lblContador.Caption := Format('%d/%d',[PosicaoAtual, TotalEmails]);
      Application.ProcessMessages;
      LimparVariaveis;

      Application.ProcessMessages;
      vDataVencimento := ExtrairVencimento(ListaArquivos.Strings[j]);
      vCedente := ExtrairCedente(ListaArquivos.Strings[j]);

      if (vCedente = '') then
        cedenteErroArquivo := 'Noi foi possivel encontrar o cedente no arquivo pdf';

      vCedente := GetFantasia(vCedente);
      vSacado := ExtrairSacado(ListaArquivos.Strings[j]);

      if (vSacado = '') then
        sacadoErroArquivo := 'Não foi possivel encontrar o sacado no Arquivo pdf';

      vSacado := GetSacado(vSacado, 'NOME');
      vEmail := GetSacado(vSacado, 'EMAIL');

      ExtractStrings([';'], [], PChar(vEmail), listaEmails);

      emailValido := false;
      for k:= 0 to listaEmails.Count-1 do
      begin
        if IsValidEmail(listaEmails.Strings[k]) then
          emailValido := true;
      end;

      if (vDataVencimento = '') then
        vencimentoErro := 'Não foi possivel encontrar a data de vencimento';

      if (vCedente = '') and (cedenteErroArquivo = '') then
        cedenteErroCadastro := 'Não foi possivel encontrar o cedente no cadastro';

      if (vsacado = '') and (sacadoErroArquivo = '') then
        sacadoErroCadastro := 'Não foi possivel encontrar o sacado no cadastro';

      if not emailValido then
        emailErro := 'E-mail inválido';

      if (vencimentoErro <> '') or
         (cedenteErroArquivo <> '') or
         (cedenteErroCadastro <> '') or
         (sacadoErroArquivo <> '') or
         (sacadoErroCadastro <> '') or
         (emailErro <> '') then

      begin
        DirArquivo := ListaArquivos.Strings[j];
        if not cdsErros.Active then
          cdsErros.CreateDataSet;

        inc(vId);
        cdsErros.Insert;
        cdsErrosid.AsInteger := vId;
        cdsErrosVencimento.AsString := vencimentoErro;
        cdsErroscedente.AsString := cedenteErroArquivo + cedenteErroCadastro;
        cdsErrosSacado.AsString := sacadoErroArquivo + sacadoErroCadastro;
        cdsErrosEmail.AsString := emailErro;
        cdsErrosarquivo.AsString := DirArquivo;
        cdsErros.Insert;
      end;
    end;
end;

procedure TfrmValidarDados.ValidaArquivosEmSubDiretorios;
var
  I, J, k: Integer;

  SubDiretorios: TStringList;
  ListaArquivos: TStringList;
  listaEmails: TStringList;

  dthrInicial: TDateTime;
  dthrFinal: TDateTime;
  dthrDuracao:Integer;
  difHorario: TDateTime;

  vDataVencimento: String;
  vCedente: String;
  vSacado: String;
  vTelefone: String;
  vEmail: String;

  DirArquivo: String;
  vencimentoErro: STring;
  cedenteErroArquivo: String;
  cedenteErroCadastro: String;
  sacadoErroArquivo: String;
  sacadoErroCadastro: String;
  emailErro: String;
  emailValido: Boolean;
  tudoOk: Boolean;

  procedure LimparVariaveis;
  begin
    vDataVencimento := '';
    vCedente := '';
    vSacado := '';
    vTelefone := '';
    vEmail := '';

    dirArquivo := '';
    vencimentoErro := '';
    cedenteErroArquivo := '';
    cedenteErroCadastro := '';
    sacadoErroArquivo := '';
    sacadoErroCadastro := '';
    emailErro := '';
    tudoOk := false;

    listaEmails.Clear;
  end;
begin
  listaEmails := TStringList.Create;
  dthrInicial := now;
  LimparVariaveis;
  CarregarParametros;
  ValidarPreenchimentoParametros;

  SubDiretorios := TStringList.Create;
  GetSubDirectories(ctDiretorioAnexo, SubDiretorios);

  ListaArquivos := TStringList.Create;
  try
    ListarArquivosEmPasta(IncludeTrailingPathDelimiter(ctDiretorioAnexo), ListaArquivos);
    TotalEmails := SubDiretorios.Count + ListaArquivos.Count;
  finally
    FreeAndNil(ListaArquivos);
  end;

  ListaArquivos := TStringList.Create;
  lblContador.Caption := Format('%d/%d',[PosicaoAtual, TotalEmails]);
  pb.Max := TotalEmails;
  for I := 0 to SubDiretorios.Count -1 do
  begin
    inc(PosicaoAtual);
    pb.Position := PosicaoAtual;
    lblContador.Caption := Format('%d/%d',[PosicaoAtual, TotalEmails]);
    Application.ProcessMessages;
    LimparVariaveis;
    ListaArquivos.Clear;
    ListarArquivosEmPasta(IncludeTrailingPathDelimiter(SubDiretorios.Strings[I]), ListaArquivos);
    for j := 0 to ListaArquivos.Count -1 do
    begin
      Application.ProcessMessages;
      vDataVencimento := ExtrairVencimento(ListaArquivos.Strings[j]);
      vCedente := ExtrairCedente(ListaArquivos.Strings[j]);

      if (vCedente = '') then
        cedenteErroArquivo := 'Noi foi possivel encontrar o cedente no arquivo pdf';

      vCedente := GetFantasia(vCedente);
      vSacado := ExtrairSacado(ListaArquivos.Strings[j]);

      if (vSacado = '') then
        sacadoErroArquivo := 'Não foi possivel encontrar o sacado no Arquivo pdf';

      vSacado := GetSacado(vSacado, 'NOME');
      vEmail := GetSacado(vSacado, 'EMAIL');

      ExtractStrings([';'], [], PChar(vEmail), listaEmails);
      emailValido := false;
      for k:= 0 to listaEmails.Count-1 do
      begin
        if IsValidEmail(listaEmails.Strings[k]) then
          emailValido := true;
      end;


      if (vDataVencimento = '') then
        vencimentoErro := 'Não foi possivel encontrar a data de vencimento';

      if (vCedente = '') and (cedenteErroArquivo = '') then
        cedenteErroCadastro := 'Não foi possivel encontrar o cedente no cadastro';

      if (vsacado = '') and (sacadoErroArquivo = '') then
        sacadoErroCadastro := 'Não foi possivel encontrar o sacado no cadastro';

      if not emailValido then
        emailErro := 'E-mail inválido';

      if (vencimentoErro <> '') or
         (cedenteErroArquivo <> '') or
         (cedenteErroCadastro <> '') or
         (sacadoErroArquivo <> '') or
         (sacadoErroCadastro <> '') or
         (emailErro <> '') then
      begin
        DirArquivo := ListaArquivos.Strings[j];
      end
      else begin
        tudoOk := true;
        break;
      end;
    end;
    if not tudoOk then
    begin
      if not cdsErros.Active then
        cdsErros.CreateDataSet;

      inc(vId);
      cdsErros.Insert;
      cdsErrosid.AsInteger := vId;
      cdsErrosVencimento.AsString := vencimentoErro;
      cdsErroscedente.AsString := cedenteErroArquivo + cedenteErroCadastro;
      cdsErrosSacado.AsString := sacadoErroArquivo + sacadoErroCadastro;
      cdsErrosEmail.AsString := emailErro;
      cdsErrosarquivo.AsString := DirArquivo;
      cdsErros.Insert;
    end;
  end;
end;

procedure TfrmValidarDados.ValidarPreenchimentoParametros;
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

end.
