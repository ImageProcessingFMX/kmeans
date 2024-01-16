unit Unit_kmeans_demo.VCL;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, VCL.Graphics,
  VCL.Controls, VCL.Forms, VCL.Dialogs, VCL.StdCtrls, VCL.ExtCtrls,
  System.Diagnostics, Unit_TKmeans,
  VCL.ComCtrls, madExceptVcl;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    SourceImage: TImage;
    OutImage: TImage;
    Button_FullTest: TButton;
    OpenDialog: TOpenDialog;
    DebugMemo: TMemo;
    MyStatusBar: TStatusBar;
    MadExceptionHandler1: TMadExceptionHandler;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button_FullTestClick(Sender: TObject);
  private
    { Private declarations }

    FBitmap: TBitmap;
    FBitmapName: String;
    FOutBitmap: TBitmap;
  public
    { Public declarations }

    procedure UpdateStatus(const Info: String);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    FBitmap.LoadFromFile(OpenDialog.FileName);

    SourceImage.Picture.Bitmap.Assign(FBitmap);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FBitmap := TBitmap.Create;

  FOutBitmap := TBitmap.Create;
end;

procedure TForm1.UpdateStatus(const Info: String);
var PrintStr : String ;
begin
  PrintStr :=  '[' + Datetostr(now) + '||' + TimeToStr(now) +
    '] ->  ' + Info;

  MyStatusBar.SimpleText :=  Info;

  DebugMemo.Lines.Add(PrintStr);

  Application.ProcessMessages;
end;



// Define a centroid function that returns the TClusterData3 object with the average coordinates of all elements in the cluster
function Centroidfct(const A: TClusterDataREC): Cardinal;
begin
  Result := Round((A.DrawingColor and $FF) + ((A.DrawingColor shr 8) and $FF) +
    ((A.DrawingColor shr 16) and $FF)) div 3;
end;

function DistanceMetric(const A, B: TClusterDataREC): Double;
begin
  // Result := Sqrt(Sqr(A.x - B.x) + Sqr(A.y - B.y));

  Result := ABS(Centroidfct(A) - Centroidfct(B));
end;

procedure TForm1.Button_FullTestClick(Sender: TObject);
var
  MyKMeans: TImageClusterKMeans;
  Stopwatch: TStopwatch;
begin
  // Create a new TStopwatch instance
  // Stopwatch := TStopwatch.Create;
  DebugMemo.lines.Clear;

  Stopwatch.Reset;



  UpdateStatus('start kmean image segmentation ...');

  try

    // Start the stopwatch
    Stopwatch.Start;

    MyKMeans := TImageClusterKMeans.Create(5, DistanceMetric, Centroidfct, 10,
      UpdateStatus);
    try
      MyKMeans.LoadData(FBitmap);

      MyKMeans.Execute;

      MyKMeans.SaveData(FOutBitmap);

      FOutBitmap.SaveToFile('c:\temp\outkmeans.bmp');

      OutImage.Picture.Bitmap.Assign(FOutBitmap);

    finally
      MyKMeans.Free;

      UpdateStatus('kmean image segmentation done!');
    end;

    Stopwatch.Stop;

    DebugMemo.lines.Add(Format('Elapsed time: %d ms',
      [Stopwatch.ElapsedMilliseconds]));

  finally
    // Free the TStopwatch instance
    // Stopwatch.Free;
  end;
end;

end.
