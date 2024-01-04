unit Unit_kmeans_algo;

interface

uses
  types, classes, System.Generics.Collections, System.SysUtils,
  System.Generics.Defaults,
{$IFDEF Framework_VCL}
  Windows, {Windows API Funktionen}
  VCL.Graphics; { pf1bit, pf... }
{$ENDIF}
{$IFDEF Framework_FMX}
// not yet working :-(
System.UITypes, FMX.Graphics; { pf1bit, pf... }
{$ENDIF}

type
  TStatusCallback = reference to procedure(const Status: string);
  TBitmapProcessCallback = reference to procedure(const Image: TBitmap);

type
  TCluster = record
    DrawingColor: TColor;
    Center: TColor;
    Pixels: array of TColor;
  end;

  TClusterList = TArray<TCluster>;

  /// <summary>
  /// This procedure clusters a bitmap image into K clusters using the K-means algorithm.
  /// https://rosettacode.org/wiki/K-means%2B%2B_clustering#Delphi
  /// The input bitmap image
  /// The output bitmap image
  /// The number of clusters
  /// Optional reference to a procedure to receive status updates during the clustering process
  /// Optional reference to a procedure to receive updates on the output bitmap image during the clustering process
  /// </summary>
procedure KMeansCluster(const Input: TBitmap; const Output: TBitmap;
  const K: Integer; const StatusCallback: TStatusCallback = nil;
  const BitmapProcessCallback: TBitmapProcessCallback = nil);

implementation

/// <summary>
/// Generates a random color.
/// </summary>
function RandomColor: TColor;
begin
  Result := RGB(Random(255), Random(255), Random(255));
end;

/// <summary>
/// Generates a random color.
/// </summary>
/// <param name="A">
/// first value
/// </param>
/// <param name="B">
/// second value
/// </param>
function GetDistance(const A, B: TColor): Double;
var
  R1, G1, B1, R2, G2, B2: Byte;
begin
  R1 := GetRValue(A);
  G1 := GetGValue(A);
  B1 := GetBValue(A);
  R2 := GetRValue(B);
  G2 := GetGValue(B);
  B2 := GetBValue(B);
  Result := Sqrt(Sqr(R1 - R2) + Sqr(G1 - G2) + Sqr(B1 - B2));
end;

/// <summary>
/// Assigns each pixel of the input bitmap image to the nearest cluster.
/// </summary>
procedure GroupPixels2NearestCluster(const Input: TBitmap;
  Clusters: TClusterList);
var
  x, y: Integer;
  i: Integer;
  W, H: Integer;
  K: Integer;
  Distance, MinDistance: Double;
  NearestCluster: Integer;
begin

  W := Input.Width;
  H := Input.Height;
  K := length(Clusters);

  // Clear the pixels from the previous iteration
  for i := 0 to K - 1 do
    SetLength(Clusters[i].Pixels, 0);

  // Assign each pixel to the nearest cluster
  for y := 0 to H - 1 do
  begin
    for x := 0 to W - 1 do
    begin
      MinDistance := MaxInt;
      NearestCluster := -1;

      // Find the nearest cluster for the current pixel
      for i := 0 to K - 1 do
      begin
        Distance := GetDistance(Input.Canvas.Pixels[x, y], Clusters[i].Center);
        if Distance < MinDistance then
        begin
          MinDistance := Distance;
          NearestCluster := i;
        end;
      end;

      // Assign the current pixel to the nearest cluster
      SetLength(Clusters[NearestCluster].Pixels,
        length(Clusters[NearestCluster].Pixels) + 1);
      Clusters[NearestCluster].Pixels[High(Clusters[NearestCluster].Pixels)] :=
        Input.Canvas.Pixels[x, y];
    end;
  end;
end;

/// <summary>
/// Converts the cluster centers into a string representation for debugging
/// purposes.
/// </summary>
function ClusterCentroidsToString(Clusters: TClusterList): string;
var
  i, K: Integer;
  R, G, B: Byte;
  line, s: String;
  len: Cardinal;
begin
  K := length(Clusters);
  line := '';

  for i := 0 to K - 1 do
  begin

    R := GetRValue(Clusters[i].Center);
    G := GetGValue(Clusters[i].Center);
    B := GetBValue(Clusters[i].Center);
    s := Format('[#%.2X%.2X%.2X]', [R, G, B]);

    len := length(Clusters[i].Pixels);
    line := line + s + '->' + IntToStr(len) + ';  '
  end;

  Result := line;
end;

function FindNewClusterCentroids(Clusters: TClusterList): Boolean;
var
  i, j, K: Integer;
  R, G, B: Cardinal;
  Count: Cardinal;
  OldCenter: Array of TColor;
  AnyChange: Boolean;
begin

  K := length(Clusters);
  SetLength(OldCenter, K);
  AnyChange := false;

  // Update the centers of the clusters
  for i := 0 to K - 1 do
  begin
    Count := length(Clusters[i].Pixels);
    OldCenter[i] := Clusters[i].Center;

    if Count > 0 then
    begin
      R := 0;
      G := 0;
      B := 0;

      // Compute the average color of the pixels in the current cluster
      for j := 0 to Count - 1 do
      begin
        R := R + GetRValue(Clusters[i].Pixels[j]);
        G := G + GetGValue(Clusters[i].Pixels[j]);
        B := B + GetBValue(Clusters[i].Pixels[j]);
      end;

      Clusters[i].Center := RGB(R div Count, G div Count, B div Count);

      if (Clusters[i].Center <> OldCenter[i]) then
        AnyChange := true;

    end;
  end;

  Result := AnyChange;
end;

procedure UpdateClusterImage(Input, Output: TBitmap; Clusters: TClusterList);
var
  x, y: Integer;
  i, K: Integer;
  H, W: Integer;
  Distance, MinDistance: Double;
  NearestCluster: Integer;
begin

  K := length(Clusters);
  H := Output.Height;
  W := Output.Width;

  // Assign the pixels to the clustered colors

  for y := 0 to H - 1 do
  begin
    for x := 0 to W - 1 do
    begin
      MinDistance := MaxInt;
      NearestCluster := -1;

      // Find the nearest cluster for the current pixel
      for i := 0 to K - 1 do
      begin
        Distance := GetDistance(Input.Canvas.Pixels[x, y], Clusters[i].Center);
        if Distance < MinDistance then
        begin
          MinDistance := Distance;
          NearestCluster := i;
        end;
      end;

      // Assign the current pixel to the color of the nearest cluster
      Output.Canvas.Pixels[x, y] := Clusters[NearestCluster].Center;
    end;
  end;

end;

procedure KMeansCluster(const Input: TBitmap; const Output: TBitmap;
  const K: Integer; const StatusCallback: TStatusCallback = nil;
  const BitmapProcessCallback: TBitmapProcessCallback = nil);
var
  x, y, i, j: Integer;
  W, H: Integer;
  Clusters: TClusterList;
  Distance, MinDistance: Double;
  NearestCluster: Integer;
  Status: string;
  Changed: Boolean;
begin
  W := Input.Width;
  H := Input.Height;

  Output.PixelFormat := pf24bit;
  Output.Width := Input.Width;
  Output.Height := Input.Height;

  // Initialize the clusters with randomly chosen centers
  SetLength(Clusters, K);
  for i := 0 to K - 1 do
  begin
    Clusters[i].Center := Input.Canvas.Pixels[Random(W), Random(H)];

    Clusters[i].DrawingColor := RandomColor;
  end;

  Clusters[0].Center := clBlack;
  Clusters[K - 1].Center := clWhite;

  i := 0;

  // Repeat the clustering until convergence
  repeat

    if Assigned(StatusCallback) then
    begin
      Status := Format('Clustering iteration %d of %d', [i, 10]);
      StatusCallback(Status);
    end;

    GroupPixels2NearestCluster(Input, Clusters);

    if Assigned(StatusCallback) then
    begin
      Status := 'Updating cluster centers...';
      StatusCallback(Status);
    end;

    Changed := FindNewClusterCentroids(Clusters);

    if Assigned(StatusCallback) then
    begin
      Status := ClusterCentroidsToString(Clusters);
      StatusCallback(Status);
    end;

    inc(i);

    if Assigned(BitmapProcessCallback) then
    begin
      UpdateClusterImage(Input, Output, Clusters);

      BitmapProcessCallback(Output);
    end;
  until ((i > 10) or (NOT Changed));

  UpdateClusterImage(Input, Output, Clusters);

  if Assigned(StatusCallback) then
  begin
    Status := 'FINAL: ' + ClusterCentroidsToString(Clusters) + 'ITER:' +
      i.ToString;
    StatusCallback(Status);
  end;

end;

end.
