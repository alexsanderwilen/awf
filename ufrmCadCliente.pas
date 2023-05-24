unit ufrmCadCliente;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DbxSqlite, Data.FMTBcd, Data.DB,
  Datasnap.DBClient, Datasnap.Provider, Vcl.Grids, Vcl.DBGrids, Data.SqlExpr,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.OleAuto, Vcl.ComCtrls;

type
  TfrmCadCliente = class(TForm)
    SQLConnection1: TSQLConnection;
    SQL: TSQLQuery;
    ds: TDataSource;
    DBGrid1: TDBGrid;
    dsp: TDataSetProvider;
    cdsCliente: TClientDataSet;
    Panel1: TPanel;
    btnImportar: TBitBtn;
    btnNovoCliente: TBitBtn;
    btnAlterar: TBitBtn;
    btnApagar: TBitBtn;
    pb: TProgressBar;
    SQLid: TWideMemoField;
    SQLnome: TWideMemoField;
    SQLemail: TWideMemoField;
    SQLarquivo: TWideMemoField;
    Panel2: TPanel;
    Label1: TLabel;
    cbxTipoPesquisa: TComboBox;
    edtPesquisa: TEdit;
    cdsClientenome: TStringField;
    cdsClienteemail: TStringField;
    cdsClienteid: TStringField;
    cdsClientearquivo: TStringField;
    procedure FormCreate(Sender: TObject);
    procedure btnNovoClienteClick(Sender: TObject);
    procedure btnAlterarClick(Sender: TObject);
    procedure btnApagarClick(Sender: TObject);
    procedure btnImportarClick(Sender: TObject);
    procedure cdsClientenomeGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure cdsClienteemailGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure cdsClientearquivoGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
    procedure edtPesquisaChange(Sender: TObject);
    procedure cbxTipoPesquisaChange(Sender: TObject);
    procedure edtPesquisaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    pesquisarNovamente: Boolean;
    procedure preencherDetalhe;
    procedure CarregarDados;
    procedure PesquisaParcial(cds: TClientDataSet; FieldName: String; palavra: String);
    function RemoverAcentos(const str: string): string;
  public
  end;

var
  frmCadCliente: TfrmCadCliente;

implementation

{$R *.dfm}

uses ufrmDetCliente, System.AnsiStrings;

procedure TfrmCadCliente.btnAlterarClick(Sender: TObject);
begin
  Application.CreateForm(TfrmDetCliente, frmDetCliente);
  frmDetCliente.Acao := 1;
  frmDetCliente.Caption := frmDetCliente.Caption + ' - Alterar Cliente';
  preencherDetalhe;
  frmDetCliente.ShowModal;
  frmDetCliente.Release;
  CarregarDados;
end;

procedure TfrmCadCliente.btnApagarClick(Sender: TObject);
begin
  Application.CreateForm(TfrmDetCliente, frmDetCliente);
  frmDetCliente.Acao := 2;
  frmDetCliente.Caption := frmDetCliente.Caption + ' - Apagar Cliente';
  preencherDetalhe;
  frmDetCliente.ShowModal;
  frmDetCliente.Release;
  CarregarDados;
end;

procedure TfrmCadCliente.btnImportarClick(Sender: TObject);
var
  Excel: Variant;
  Sheet: Variant;
  Row, Col: Integer;
  LastRow, LastCol: Integer;
begin
  try
    Excel := CreateOleObject('Excel.Application');
    Excel.Workbooks.Open('C:\awf\excel\clientes.xlsx');
    Sheet := Excel.Worksheets['E-mails para envio fatura'];
    Sheet.Activate;
    LastRow := Sheet.UsedRange.Rows.Count;
    LastCol := Sheet.UsedRange.Columns.Count;
    pb.Visible := true;
    pb.Max := LastRow;
    for Row := 1 to LastRow do
    begin
      pb.Position := Row;
      if Trim(Sheet.Cells[Row, 1].Value) = EmptyStr then
        continue;

      SQL.Close;
      SQL.SQL.Text := Format('INSERT INTO CLIENTE(NOME, EMAIL, ARQUIVO)VALUES(%s, %s, %s)',
                      [QuotedStr(UpperCase(Trim(Sheet.Cells[Row, 1].Value))), QuotedStr(LowerCase(Trim(Sheet.Cells[Row, 2].Value))), QuotedStr(UpperCase(Trim(Sheet.Cells[Row, 1].Value) + '.pdf'))]);
      SQL.execSql;
    end;
    Excel.Quit;
    Excel := Unassigned;
  finally
    VarClear(Excel);
    pb.Visible := false;
    pb.Position := 0;
  end;
end;

procedure TfrmCadCliente.btnNovoClienteClick(Sender: TObject);
begin
  Application.CreateForm(TfrmDetCliente, frmDetCliente);
  frmDetCliente.Acao := 0;
  frmDetCliente.Caption := frmDetCliente.Caption + ' - Novo Cliente';
  frmDetCliente.ShowModal;
  frmDetCliente.Release;
  CarregarDados;
end;

procedure TfrmCadCliente.CarregarDados;
var
  vId: Integer;
begin
  vId := 0;
  SQLConnection1.Connected := false;
  SQLConnection1.Connected := true;
  sql.Close;
  sql.Open;

  if not cdsCliente.Active then
    cdsCliente.CreateDataSet;

  cdsCliente.EmptyDataSet;
  sql.First;
  while not (sql.Eof) do
  begin
    inc(vId);
    cdsCliente.Insert;
    cdsClienteid.AsString := IntToStr(vID);
    cdsClientenome.AsString := sqlnome.AsString;
    cdsClienteemail.AsString := sqlemail.AsString;
    cdsCliente.Post;
    sql.Next;
  end;
  cdsCliente.Close;
  cdsCliente.Active := true;
end;

procedure TfrmCadCliente.cbxTipoPesquisaChange(Sender: TObject);
begin
  case cbxTipoPesquisa.ItemIndex of
    1: edtPesquisa.CharCase := ecUpperCase;
    2: edtPesquisa.CharCase := ecLowerCase;
  end;
end;

procedure TfrmCadCliente.cdsClientearquivoGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  Text := Sender.AsString;
end;

procedure TfrmCadCliente.cdsClienteemailGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  Text := Sender.AsString;
end;

procedure TfrmCadCliente.cdsClientenomeGetText(Sender: TField; var Text: string;
  DisplayText: Boolean);
begin
  Text := Sender.AsString;
end;

procedure TfrmCadCliente.edtPesquisaChange(Sender: TObject);
var
  vTipo: String;
begin
  case cbxTipoPesquisa.ItemIndex of
    0: vTipo := 'id';
    1: vTipo := 'nome';
    2: vTipo := 'email';
  end;
  PesquisaParcial(cdsCliente, vTipo,  edtPesquisa.Text);
end;

procedure TfrmCadCliente.edtPesquisaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  vTipo: String;
begin
  if Key = VK_RETURN then
  begin
    pesquisarNovamente := true;
    case cbxTipoPesquisa.ItemIndex of
      0: vTipo := 'id';
      1: vTipo := 'nome';
      2: vTipo := 'email';
    end;
    PesquisaParcial(cdsCliente, vTipo,  edtPesquisa.Text);
  end
  else pesquisarNovamente := false;
end;

procedure TfrmCadCliente.FormCreate(Sender: TObject);
begin
  pb.Visible := false;
  CarregarDados;
end;

procedure TfrmCadCliente.PesquisaParcial(cds: TClientDataSet; fieldName: STring; palavra: String);
var
 bookmark: TBookmark;
 encontrou: Boolean;
begin
  encontrou := false;
  bookmark := cds.GetBookmark;
  cds.DisableControls;
  if pesquisarNovamente then
    cds.Next
  else
    cds.First;
  try
    while not (cds.Eof) do
    begin
      if PosEx(AnsiUpperCase(RemoverAcentos(palavra)), AnsiUpperCase(RemoverAcentos(cds.FieldByName(fieldname).AsString)), 1) > 0 then
      begin
        encontrou := true;
        break;
      end;
      cds.Next;
    end;
  finally
    if not encontrou then
      cds.GotoBookmark(bookmark);
    cds.FreeBookmark(bookmark);
    cds.EnableControls;
  end;
end;

procedure TfrmCadCliente.preencherDetalhe;
begin
  frmDetCliente.edtId.Text    := cdsClienteid.AsString;
  frmDetCliente.edtNome.Text  := cdsClienteNome.AsString;
  frmDetCliente.edtEmail.Text := cdsClienteEmail.AsString;
end;


function TfrmCadCliente.RemoverAcentos(const str: string): string;
const
  ComAcento: array[0..35] of char = ('á', 'à', 'ã', 'â', 'é', 'è', 'ê', 'í', 'ì', 'î', 'ó', 'ò', 'õ', 'ô', 'ú', 'ù', 'û', 'ç', 'Á', 'À', 'Ã', 'Â', 'É', 'È', 'Ê', 'Í', 'Ì', 'Î', 'Ó', 'Ò', 'Õ', 'Ô', 'Ú', 'Ù', 'Û', 'Ç');
  SemAcento: array[0..35] of char = ('a', 'a', 'a', 'a', 'e', 'e', 'e', 'i', 'i', 'i', 'o', 'o', 'o', 'o', 'u', 'u', 'u', 'c', 'A', 'A', 'A', 'A', 'E', 'E', 'E', 'I', 'I', 'I', 'O', 'O', 'O', 'O', 'U', 'U', 'U', 'C');
var
  i, j: Integer;
begin
  Result := str;
  for i := Low(ComAcento) to High(ComAcento) do
    for j := 1 to Length(Result) do
      if Result[j] = ComAcento[i] then
        Result[j] := SemAcento[i];
end;


end.

