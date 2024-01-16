unit Unit_TKmeans;

interface

uses types, classes, SysUtils, Generics.Collections,
{$IFDEF FrameWork_VCL}
  vcl.Graphics;
{$ENDIF}
{$IFDEF FrameWork_FMX}
System.UITypes, System.UIConsts, FMX.types, FMX.Utils, FMX.Graphics;
{$ENDIF}

const
  Infinity = 10000000;

type
  TStatusCallback = reference to procedure(const Status: string);

type
  TClusterDataREC = record
{$IFDEF FrameWork_VCL}
    DrawingColor: TColor;
{$ENDIF}
{$IFDEF FrameWork_FMX}
    DrawingColor: TAlphaColor;
{$ENDIF}
    x, y: Integer;
    chrlabel: char;
    // ...
    // ..
    // .
  end;

  TClusterData = class
    DrawingColor: TColor;
    x, y: Integer;
    chrlabel: char;
    // ...
    // ..
    // .
  end;

  /// <summary>
  /// a bit different pixeldefinition
  /// </summary>
  TClusterDataREC2 = record
    BWColor: Byte;
    x, y: Integer;
    // tbd.
    // ...
    // ..
    // .
  end;

  /// <summary>
  /// here it can be just a simple pixel description,
  /// in general  we store the  complete orginal data inside this list
  /// </summary>
  TRawData<T> = class(TList<T>)
  end;

  /// <summary>
  /// store the  data now inside a  cluster  with a  Centroid
  /// </summary>
  TCluster<T> = record
    /// <summary>
    /// <para>
    /// as of today T, but in future some other data type , depending
    /// </para>
    /// <para>
    /// on future research :-)
    /// </para>
    /// </summary>
    Center: T;

    /// <summary>
    /// the selected elements from out complete raw data
    /// </summary>
    ClusterElements: TArray<T>;
  end;

  /// <summary>
  /// the cluster list
  /// </summary>
  TClusterList<T> = class(TList < TCluster < T >> )
  private
    function GetItem(Aindex: Integer): TCluster<T>;
    procedure SetItem(Aindex: Integer; const Value: TCluster<T>);
  public

    property Items[Aindex: Integer]: TCluster<T> Read GetItem Write SetItem;
  end;

type
  /// <summary>
  /// measure the distance according to this function
  /// </summary
TDistanceMetricfunction < T >= reference to
function(const A, B: T): Double;

type
  /// <summary>
  /// result of this function could be the TColor value , but also
  /// coordinates  my have some impact in future ....
  /// </summary
TCentroidfunction < T >= reference to
function(const A: T): Cardinal;

type
  TKMeans<T> = class
  private

  private
    FClusteredData: TClusterList<T>;

    FRawData: TArray<T>;

    FNumClusters: Integer;

    FDistanceMetric: TDistanceMetricfunction<T>;

    FCentroidfct: TCentroidfunction<T>;

    FMaxIterations: Integer;

    FStatusCallback: TStatusCallback;

  public
    constructor Create(NumClusters: Integer;
      DistanceMetric: TDistanceMetricfunction<T>;
      Centroidfct: TCentroidfunction<T>; MaxIterations: Integer = 10;
      StatusCallback: TStatusCallback = nil);

    function FindNewClusterCentroids: Boolean;

    function InitClusters: Boolean;

    function Execute: Integer;

    function ClusterCentroidsToString: String; virtual; abstract;

    procedure GroupData2NearestCluster;

    property RawData: TArray<T> read FRawData write FRawData;
  end;

type
  TImageClusterKMeans = class(TKMeans<TClusterDataREC>)
  private
    FBMPwidth: Integer;
    FBMPheight: Integer;
  public

    function ClusterCentroidsToString: String;

    procedure LoadData(SoureBitMap: TBitmap);

    procedure SaveData(OutBitMap: TBitmap);
  end;

implementation

constructor TKMeans<T>.Create(NumClusters: Integer;
  DistanceMetric: TDistanceMetricfunction<T>; Centroidfct: TCentroidfunction<T>;
  MaxIterations: Integer = 10; StatusCallback: TStatusCallback = nil);
begin
  FNumClusters := NumClusters;
  FDistanceMetric := DistanceMetric;
  FMaxIterations := MaxIterations;

  FClusteredData := TClusterList<T>.Create;

  // FRawData := TRawData<T>.Create;

  FDistanceMetric := DistanceMetric;

  FCentroidfct := Centroidfct;

  FStatusCallback := StatusCallback;
end;

function TKMeans<T>.Execute: Integer;
var
  i: Integer;
  Changed: Boolean;
  Status: String;
begin

  i := 0;

  if (self.InitClusters) then
  begin
    repeat
      GroupData2NearestCluster;

      Changed := FindNewClusterCentroids;

      inc(i);

      if Assigned(FStatusCallback) then
      begin
        Status := Format('Clustering iteration %d of %d', [i, 10]);
        // FStatusCallback(Status + ClusterCentroidsToString);
      end;

    until ((i > FMaxIterations) or (NOT Changed));
  end;

  result := i;

end;

function TKMeans<T>.FindNewClusterCentroids: Boolean;
var
  i, j: Integer;
  SelectedCluster: TCluster<T>;
  OldCentroid: Cardinal;
  ElementCount: Cardinal;
  Centroid: Cardinal;
begin

  for i := 0 to FClusteredData.Count - 1 do
  begin
    SelectedCluster := FClusteredData.Items[i];
    ElementCount := length(SelectedCluster.ClusterElements);
    OldCentroid := FCentroidfct(SelectedCluster.Center);

    for j := low(SelectedCluster.ClusterElements)
      to High(SelectedCluster.ClusterElements) do
    begin
      Centroid := Centroid + FCentroidfct(SelectedCluster.ClusterElements[j]);
    end;

    if (ElementCount <> 0) then
    begin
      Centroid := Round(Centroid / ElementCount);
    end
    else
    begin
      // this  should not happen !
    end;

  end;

  result := true;

end;

procedure TKMeans<T>.GroupData2NearestCluster;
var
  i, j: Integer;
  closestCluster: Integer;
  minDist: Double;
  Dist: Double;
  ReferenceClusterCenter: T;
  RawDataItem: T;
  UpdateCluster: TCluster<T>;
begin
  /// loop all raw data elements
  for j := low(FRawData) to high(FRawData) do
  begin
    RawDataItem := FRawData[j];
    closestCluster := -1;
    minDist := Infinity;

    // Find the nearest cluster
    for i := 0 to FClusteredData.Count - 1 do
    begin
      Dist := FDistanceMetric(RawDataItem, FClusteredData[i].Center);
      if Dist < minDist then
      begin
        closestCluster := i;
        minDist := Dist;
      end;
    end;

    // these lines are wrong and do not compile, fix the  code here !!!!
    UpdateCluster := FClusteredData[closestCluster];

    SetLength(UpdateCluster.ClusterElements,
      length(UpdateCluster.ClusterElements) + 1);

    UpdateCluster.ClusterElements[High(UpdateCluster.ClusterElements)] :=
      FRawData[j];

    FClusteredData[closestCluster] := UpdateCluster;
  end;
end;

function TKMeans<T>.InitClusters: Boolean;
var
  OneCluster: TCluster<T>;
  i: Integer;
  DataSize: Integer;
begin

  DataSize := length(FRawData);
  FClusteredData.Clear;

  // Initialize the clusters with randomly chosen centers
  for i := 1 to FNumClusters do
  begin
    OneCluster.Center := FRawData[Random(DataSize)];
    SetLength(OneCluster.ClusterElements, 0);
    FClusteredData.Add(OneCluster);
  end;

  result := ((FClusteredData.Count = FNumClusters) and
    (DataSize > FNumClusters));

end;

{$IFDEF FrameWork_VCL}

procedure TImageClusterKMeans.SaveData(OutBitMap: TBitmap);
var
  i, j: Integer;
  ClusterIndex: Integer;
  closestCluster: Integer;
  minDist: Double;
  Dist: Double;
  OneCluster: TCluster<TClusterDataREC>;
  ClusteredData: TClusterDataREC;
begin
  // Loop through all the pixels in the output bitmap

    // Clear the old data
  OutBitMap.Height := FBMPheight;
  OutBitMap.Width := FBMPwidth;
  OutBitMap.PixelFormat := pf24bit;

  for i := 0 to FClusteredData.Count - 1 do
  begin
    OneCluster := FClusteredData[i];

    for j := low(OneCluster.ClusterElements)
      to high(OneCluster.ClusterElements) do
    begin

      ClusteredData := OneCluster.ClusterElements[j];

      OutBitMap.Canvas.Pixels[ClusteredData.x, ClusteredData.y] :=
        OneCluster.Center.DrawingColor;

    end;
  end;

  // Save the output bitmap to a file or show it in a GUI component
  // For example, to save the bitmap to a file:
  OutBitMap.SaveToFile('c:\temp\output.bmp');


end;

function TImageClusterKMeans.ClusterCentroidsToString: String;
var
  i: Integer;
  OneCluster: TCluster<TClusterDataREC>;
begin
  result := '';
  for i := 0 to FClusteredData.Count - 1 do
  begin
    OneCluster := FClusteredData[i];
{$IFDEF FrameWork_VCL}
    result := result + ColorToString(OneCluster.Center.DrawingColor) + '|' +
      IntTostr(length(OneCluster.ClusterElements)) + '; ';
{$ENDIF}
{$IFDEF FrameWork_FMX}
    result := result + AlphaColorToString(OneCluster.Center.DrawingColor) + '|'
      + IntTostr(length(OneCluster.ClusterElements)) + '; ';
{$ENDIF}
  end;
end;

procedure TImageClusterKMeans.LoadData(SoureBitMap: TBitmap);
var
  x, y: Integer;
  ClusterData: TClusterDataREC;
begin
  // Clear the old data
  SetLength(FRawData, SoureBitMap.Height * SoureBitMap.Width);
  FBMPwidth := SoureBitMap.Width;
  FBMPheight := SoureBitMap.Height;

  // Loop through all the pixels in the bitmap
  for y := 0 to SoureBitMap.Height - 1 do
  begin
    for x := 0 to SoureBitMap.Width - 1 do
    begin
      // Create a TClusterData object for each pixel
      ClusterData.DrawingColor := SoureBitMap.Canvas.Pixels[x, y];
      ClusterData.x := x;
      ClusterData.y := y;

      // Add the TClusterData object to the FRawData list
      FRawData[y * SoureBitMap.Width + x] := ClusterData;
    end;
  end;
end;
{$ENDIF}
{$IFDEF FrameWork_FMX}

procedure SetPixel(Color: TAlphaColor; i, j: Integer; bitdata: TBitmapData;
  PixelFormat: TPixelFormat);
begin
  AlphaColorToPixel(Color, @PAlphaColorArray(bitdata.Data)
    [j * (bitdata.Pitch div PixelFormatBytes[PixelFormat]) + 1 * i],
    PixelFormat);

end;

function GetPixel(i, j: Integer; bitdata: TBitmapData;
  PixelFormat: TPixelFormat): TAlphaColor;
begin

  result := PixelToAlphaColor(@PAlphaColorArray(bitdata.Data)
    [j * (bitdata.Pitch div PixelFormatBytes[PixelFormat]) + 1 * i],
    PixelFormat);
end;

procedure TImageClusterKMeans.SaveData(OutBitMap: TBitmap);
var
  bitdata1: TBitmapData;
  i: Integer;
  j: Integer;
  Color: TAlphaColor;
  Cquer: Byte;
  OneCluster: TCluster<TClusterDataREC>;
  ClusteredData: TClusterDataREC;
begin

  // Clear the old data
  OutBitMap.Height := FBMPheight;
  OutBitMap.Width := FBMPwidth;

  // Loop through all the pixels in the bitmap

  if (OutBitMap.Map(TMapAccess.ReadWrite, bitdata1)) then
    try

      for i := 0 to FClusteredData.Count - 1 do
      begin
        OneCluster := FClusteredData[i];

        for j := low(OneCluster.ClusterElements)
          to high(OneCluster.ClusterElements) do
        begin

          ClusteredData := OneCluster.ClusterElements[j];

          SetPixel(OneCluster.Center.DrawingColor, ClusteredData.x,
            ClusteredData.y, bitdata1, OutBitMap.PixelFormat)
        end;
      end;

    finally
      OutBitMap.Unmap(bitdata1);
    end;
end;

procedure TImageClusterKMeans.LoadData(SoureBitMap: TBitmap);
var
  bitdata1: TBitmapData;
  i: Integer;
  j: Integer;
  Color: TAlphaColor;
  Cquer: Byte;

  ClusterData: TClusterDataREC;
begin

  // Clear the old data
  SetLength(FRawData, SoureBitMap.Height * SoureBitMap.Width);
  FBMPwidth := SoureBitMap.Width;
  FBMPheight := SoureBitMap.Height;


  // Loop through all the pixels in the bitmap

  if (SoureBitMap.Map(TMapAccess.ReadWrite, bitdata1)) then
    try
      for i := 0 to SoureBitMap.Width - 1 do
        for j := 0 to SoureBitMap.Height - 1 do
        begin
          Color := GetPixel(i, j, bitdata1, SoureBitMap.PixelFormat);

          Cquer := Round(TAlphaColorRec(Color).B * 0.3 + TAlphaColorRec(Color).G
            * 0.59 + TAlphaColorRec(Color).R * 0.11);

          ClusterData.DrawingColor := Color;
          ClusterData.x := i;
          ClusterData.y := j;

          // Add the TClusterData object to the FRawData list
          FRawData[j * SoureBitMap.Width + i] := ClusterData;


        end;

    finally
      SoureBitMap.Unmap(bitdata1);
    end;
end;

{$ENDIF}
{ TClusterList<T> }

function TClusterList<T>.GetItem(Aindex: Integer): TCluster<T>;
begin
  result := inherited Items[Aindex];
end;

procedure TClusterList<T>.SetItem(Aindex: Integer; const Value: TCluster<T>);
begin
  inherited Items[Aindex] := Value;
end;

end.
