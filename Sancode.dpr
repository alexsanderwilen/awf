program Sancode;

uses
  Vcl.Forms,
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  ufrmCadCliente in 'ufrmCadCliente.pas' {frmCadCliente},
  ufrmDetCliente in 'ufrmDetCliente.pas' {frmDetCliente},
  ufrmConfiguracao in 'ufrmConfiguracao.pas' {frmConfiguracao},
  ufrmCadSeguradora in 'ufrmCadSeguradora.pas' {frmCadSeguradora},
  ufrmDetSeguradora in 'ufrmDetSeguradora.pas' {frmDetSeguradora},
  ufrmCadCorpoEmail in 'ufrmCadCorpoEmail.pas' {frmCorpoEmail},
  ufrmEmail in 'ufrmEmail.pas' {frmEmail},
  ufrmValidarDados in 'ufrmValidarDados.pas' {frmValidarDados};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
