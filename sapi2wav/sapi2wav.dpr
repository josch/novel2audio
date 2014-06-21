program sapi2wav;

uses
  Forms,
  ttswav in 'ttswav.pas' {MainForm};

{$R *.res}
begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
