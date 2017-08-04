program khImageViewer;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {frmMain},
  BrowserThreadUnit in 'BrowserThreadUnit.pas',
  uAbout in 'uAbout.pas' {frmAbout};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
