program Project_km_demoVCL;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  Unit_kmeans_demo.VCL in 'Unit_kmeans_demo.VCL.pas' {Form1},
  Unit_TKmeans in 'Unit_TKmeans.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
