program Project_km_demoFMX;

uses

  System.StartUpCopy,
  FMX.Forms,
  Unit_kmeans_demo.FM in 'Unit_kmeans_demo.FM.pas' {KemansDemoForm},
  Unit_TKmeans in 'Unit_TKmeans.pas',
  Unit_TSimpleProfiler in '..\..\..\code_shared_libraries\Unit_TSimpleProfiler.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TKemansDemoForm, KemansDemoForm);
  Application.Run;
end.
