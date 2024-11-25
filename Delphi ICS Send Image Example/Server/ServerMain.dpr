program ServerMain;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {ServerForm},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('GNome Dark Flat');
  Application.CreateForm(Tform1, ServerForm);
  Application.Run;
end.

