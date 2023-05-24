unit ufrmCadSeguradora;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids,
  Vcl.ExtCtrls, Data.DbxSqlite, Data.FMTBcd, Datasnap.DBClient,
  Datasnap.Provider, Data.SqlExpr, Vcl.StdCtrls, Vcl.Buttons;

type
  TfrmCadSeguradora = class(TForm)
    Panel1: TPanel;
    DBGrid1: TDBGrid;
    SQLConnection1: TSQLConnection;
    SQL: TSQLQuery;
    dsp: TDataSetProvider;
    cdsSeguradora: TClientDataSet;
    ds: TDataSource;
    SQLid: TLargeintField;
    SQLNome: TWideStringField;
    SQLFantasia: TWideStringField;
    btnNovoCliente: TBitBtn;
    btnAlterar: TBitBtn;
    btnApagar: TBitBtn;
    Panel2: TPanel;
    Label1: TLabel;
    cbxTipoPesquisa: TComboBox;
    edtPesquisa: TEdit;
    cdsSeguradoraid: TStringField;
    cdsSeguradorafantasia: TStringField;
    cdsSeguradoranome: TStringField;
    procedure FormCreate(Sender: TObject);
    procedure btnNovoClienteClick(Sender: TObject);
    procedure btnAlterarClick(Sender: TObject);
    procedure btnApagarClick(Sender: TObject);
    procedure edtPesquisaChange(Sender: TObject);
    procedure edtPesquisaKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    pesquisarNovamente: Boolean;
    procedure preencherDetalhe;
    procedure CarregarDados;
    procedure PesquisaParcial(cds: TClientDataSet; FieldName: String; palavra: String);
    function RemoverAcentos(const str: string): string;
  public
    { Public declarations }
  end;

var
  frmCadSeguradora: TfrmCadSeguradora;

implementation

{$R *.dfm}

uses ufrmDetSeguradora, System.AnsiStrings;

procedure TfrmCadSeguradora.btnAlterarClick(Sender: TObject);
begin
  Application.CreateForm(TfrmDetSeguradora, frmDetSeguradora);
  frmDetSeguradora.Acao := 1;
  frmDetSeguradora.Caption := frmDetSeguradora.Caption + ' - Alterar Seguradora';
  preencherDetalhe;
  frmDetSeguradora.ShowModal;
  frmDetSeguradora.Release;
  CarregarDados;
end;

procedure TfrmCadSeguradora.btnApagarClick(Sender: TObject);
begin
  Application.CreateForm(TfrmDetSeguradora, frmDetSeguradora);
  frmDetSeguradora.Acao := 2;
  frmDetSeguradora.Caption := frmDetSeguradora.Caption + ' - Apagar Seguradora';
  preencherDetalhe;
  frmDetSeguradora.ShowModal;
  frmDetSeguradora.Release;
  CarregarDados;
end;

procedure TfrmCadSeguradora.btnNovoClienteClick(Sender: TObject);
begin
  Application.CreateForm(TfrmDetSeguradora, frmDetSeguradora);
  frmDetSeguradora.Acao := 0;
  frmDetSeguradora.Caption := frmDetSeguradora.Caption + ' - Nova Seguradora';
  frmDetSeguradora.ShowModal;
  frmDetSeguradora.Release;
  CarregarDados;
end;

procedure TfrmCadSeguradora.CarregarDados;
var
  vId: Integer;
begin
  vId := 0;
  SQLConnection1.Connected := false;
  SQLConnection1.Connected := true;
  sql.Close;
  sql.Open;

  if not cdsSeguradora.Active then
    cdsSeguradora.CreateDataset;

  cdsSeguradora.EmptyDataSet;
  sql.First;
  while not SQL.Eof do
  begin
    inc(vId);
    cdsSeguradora.Insert;
    cdsSeguradoraid.AsInteger := vId;
    cdsSeguradoranome.AsString := SQLNome.AsString;
    cdsSeguradorafantasia.AsString := SQLFantasia.AsString;
    cdsSeguradora.Post;
    SQL.Next;
  end;

  cdsSeguradora.IndexFieldNames := 'id';
  cdsSeguradora.First;

end;

procedure TfrmCadSeguradora.edtPesquisaChange(Sender: TObject);
var
  vTipo: String;
begin
  case cbxTipoPesquisa.ItemIndex of
    0: vTipo := 'id';
    1: vTipo := 'nome';
    2: vTipo := 'fantasia';
  end;
  PesquisaParcial(cdsSeguradora, vTipo,  edtPesquisa.Text);
end;

procedure TfrmCadSeguradora.edtPesquisaKeyDown(Sender: TObject; var Key: Word;
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
      2: vTipo := 'fantasia';
    end;
    PesquisaParcial(cdsSeguradora, vTipo,  edtPesquisa.Text);
  end
  else pesquisarNovamente := false;
end;

procedure TfrmCadSeguradora.FormCreate(Sender: TObject);
begin
  CarregarDados;
end;

procedure TfrmCadSeguradora.PesquisaParcial(cds: TClientDataSet; FieldName,
  palavra: String);
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

procedure TfrmCadSeguradora.preencherDetalhe;
begin
  frmDetSeguradora.edtId.Text := cdsSeguradoraid.AsString;
  frmDetSeguradora.edtRazaoSocial.Text := cdsSeguradoranome.AsString;
  frmDetSeguradora.edtFantasia.Text := cdsSeguradoraFantasia.AsString;
end;

function TfrmCadSeguradora.RemoverAcentos(const str: string): string;
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
