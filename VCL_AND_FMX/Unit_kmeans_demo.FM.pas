unit Unit_kmeans_demo.FM;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Diagnostics,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  Unit_TKmeans, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.StdCtrls,
  FMX.Controls.Presentation,
  // ImageLibraryUnit;
  Unit_TSimpleProfiler, FMX.Objects;

type
  TKemansDemoForm = class(TForm)
    Panel1: TPanel;
    CornerButton_FullTest: TCornerButton;
    CornerButton_list_class: TCornerButton;
    Panel2: TPanel;
    StatusbarLabel: TLabel;
    CornerButton_list_rec: TCornerButton;
    OpenDialog: TOpenDialog;
    CornerButton_LoadBMP: TCornerButton;
    DebugMemo: TMemo;
    ImagePanel: TPanel;
    SourceImage: TImage;
    OutImage: TImage;
    CheckBox_strechImages: TCheckBox;
    procedure CornerButton_FullTestClick(Sender: TObject);
    procedure CornerButton_list_classClick(Sender: TObject);
    procedure CornerButton_list_recClick(Sender: TObject);
    procedure CornerButton_LoadBMPClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ImagePanelResize(Sender: TObject);
  private
    { Private declarations }
    FBitmap: TBitmap;
    FBitmapName: String;
    FOutBitmap: TBitmap;
    procedure UpdateStatus(const Info: String);
  public
    { Public declarations }
  end;

var
  KemansDemoForm: TKemansDemoForm;

implementation

{$R *.fmx}

// Define a centroid function that returns the TClusterData3 object with the average coordinates of all elements in the cluster
function Centroidfct(const A: TClusterDataREC): Cardinal;
begin
  Result := Round((A.DrawingColor and $FF) + ((A.DrawingColor shr 8) and $FF) +
    ((A.DrawingColor shr 16) and $FF)) div 3;
end;

function DistanceMetric(const A, B: TClusterDataREC): Double;
begin
  // Result := Sqrt(Sqr(A.x - B.x) + Sqr(A.y - B.y));

  Result :=  ABS(Centroidfct(A) - Centroidfct(B) );
end;

procedure TKemansDemoForm.CornerButton_FullTestClick(Sender: TObject);
var
  MyKMeans: TImageClusterKMeans;
  Stopwatch: TStopwatch;
begin
  // Create a new TStopwatch instance
  // Stopwatch := TStopwatch.Create;
  DebugMemo.lines.Clear;


  Stopwatch.Reset;
  try

    // Start the stopwatch
    Stopwatch.Start;

    MyKMeans := TImageClusterKMeans.Create(5, DistanceMetric, Centroidfct, 10,
      UpdateStatus);
    try
      MyKMeans.LoadData(FBitmap);

      MyKMeans.Execute;

      MyKMeans.SaveData(FOutBitmap);

      OutImage.Bitmap.Assign(FOutBitmap);
    finally
      MyKMeans.Free;
    end;

    Stopwatch.Stop;

    DebugMemo.lines.Add(Format('Elapsed time: %d ms',
      [Stopwatch.ElapsedMilliseconds]));

  finally
    // Free the TStopwatch instance
    // Stopwatch.Free;
  end;
end;

procedure TKemansDemoForm.UpdateStatus(const Info: String);
var PrintStr : String ;
begin
  PrintStr :=  '[' + Datetostr(now) + '||' + TimeToStr(now) +
    '] ->  ' + Info;

  StatusbarLabel.Text :=  Info;

  DebugMemo.Lines.Add(PrintStr);

  Application.ProcessMessages;
end;

procedure TKemansDemoForm.CornerButton_list_classClick(Sender: TObject);
var
  rawdata_class: TRawData<TClusterData>;
  i: Integer;
  newclass: TClusterData;

begin

  StatusbarLabel.Text := ' Create Elements';

  AProfiler.Start;

  rawdata_class := TRawData<TClusterData>.Create;

  for i := 0 to (16000 * 16000) do
  begin
    newclass := TClusterData.Create;

    newclass.x := random(1000);
    newclass.y := random(1000);
    newclass.DrawingColor := 20000;

    rawdata_class.Add(newclass);
  end;

  AProfiler.Stop;

  StatusbarLabel.Text := 'DONE  CLASS: ' + AProfiler.GetElapsedTime(total_time);

  rawdata_class.Free;
end;

procedure TKemansDemoForm.CornerButton_list_recClick(Sender: TObject);
var
  rawdata_rec: TRawData<TClusterDataREC>;
  i: Integer;
  newrec: TClusterDataREC;

begin

  StatusbarLabel.Text := ' Create Elements';

  AProfiler.Start;

  rawdata_rec := TRawData<TClusterDataREC>.Create;

  for i := 0 to (16000 * 16000) do
  begin
    newrec.x := random(1000);
    newrec.y := random(1000);
    newrec.DrawingColor := 20000;

    rawdata_rec.Add(newrec);
  end;

  AProfiler.Stop;

  StatusbarLabel.Text := 'DONE  REC: ' + AProfiler.GetElapsedTime(total_time);

  rawdata_rec.Free;
end;

procedure TKemansDemoForm.CornerButton_LoadBMPClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    FBitmap.LoadFromFile(OpenDialog.FileName);

    SourceImage.Bitmap.Assign(FBitmap);
  end;
end;

procedure TKemansDemoForm.FormCreate(Sender: TObject);
begin
  FBitmap := TBitmap.Create;

  FOutBitmap := TBitmap.Create;
end;

procedure TKemansDemoForm.ImagePanelResize(Sender: TObject);
begin
  UpdateStatus(' RESIZE ... ');

  // ImagePanel.Width := Round(ImagePanel.Width / 2);
  //
  // SourceImage.Height := ImagePanel.Height;
  //
  // SourceImage.Position.X := 0;
  //
  // SourceImage.Position.Y := 0;
  //
  // OutImage.Width := Round(ImagePanel.Width / 2);
  //
  // OutImage.Height := ImagePanel.Height;
  //
  // OutImage.Position.X := Round(ImagePanel.Width / 2);
  //
  // OutImage.Position.Y := 0;

  // SourceImage.Repaint;

  // OutImage.Repaint;

  UpdateStatus(' RESIZE DONE ');
end;

end.
