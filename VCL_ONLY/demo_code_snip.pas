procedure TImageSegmenationForm.UpdateStatus(const Info: String);
begin
  MainStatusBar.SimpleText := '[' + Datetostr(now) + '||' + TimeToStr(now) +
    '] ->  ' + Info;
end;

procedure TImageSegmenationForm.UpdateOutputimage(const Outimg: TBitmap);
begin
  OutImage.Picture.Bitmap.Assign(Outimg);

  OutImage.Repaint;

  Application.ProcessMessages;
end;

procedure TImageSegmenationForm.Action_KmeansExecute(Sender: TObject);
var
  OutBMP: TBitmap;
  k: Integer;
begin
  ///
  UpdateStatus(' Selection :  K MEANS');

  OutBMP := TBitmap.Create;
  try

    k := StrToInt(ClusterLabeledEdit.text);

    KMeansCluster(FImage, OutBMP, k, UpdateStatus, UpdateOutputimage);

    UpdateOutputimage(OutBMP);

  finally
    OutBMP.Free;
  end;

end;
