unit WICImageHelper;

interface

uses
  Windows, SysUtils, IOUtils, ActiveX, ComObj, Wincodec, CryptoUtils, Math,
  Winapi.D2D1, XCGUI, StrUtils,ImageCore;

type
  TCropAlignFlag = (AlignLeft,     // 左对齐
    AlignRight,    // 右对齐
    AlignHCenter,  // 水平居中
    AlignTop,      // 顶对齐
    AlignBottom,   // 底对齐
    AlignVCenter   // 垂直居中
  );

  TWICImage = IWICBitmap;
  TRenderTarget = ID2D1RenderTarget;
  TD2DImage = ID2D1Bitmap;

  TCropAlignFlags = set of TCropAlignFlag;

function XWICImage_LoadFile(const ImagePath: string): IWICBitmap;

function XWICImage_Scale(const SourceBitmap: IWICBitmap; Width, Height: UINT; CropAlign: TCropAlignFlags = [AlignHCenter, AlignVCenter]): IWICBitmap;

function XWICImage_SaveToFile(const Bitmap: IWICBitmap; const FilePath: string): Boolean;

function XWICImage_GetEncoderClsid(const FileName: string; var pClsid: TGUID): HRESULT;

function XWICImage_ConvertToGrayscale(const SourceBitmap: IWICBitmap): IWICBitmap;

function XWICImage_ToHBITMAP(const pBitmap: IWICBitmap): HBITMAP;

function XWICImage_ToD2DImage(const RenderTarget: ID2D1RenderTarget; const SourceBitmap: IWICBitmap): ID2D1Bitmap;

function XWICImage_ScaleAndSaveToFile(const SourcePath, DestPath: string; DestWidth, DestHeight: UINT): Boolean;

procedure XWICImage_Release(var Bitmap: IWICBitmap);

implementation

function XWICImage_LoadFile(const ImagePath: string): IWICBitmap;
var
  Decoder: IWICBitmapDecoder;
  Frame: IWICBitmapFrameDecode;
begin
  Result := nil;
  if (not Assigned(WICFactory)) then
    Exit;
  if (Failed(WICFactory.CreateDecoderFromFilename(PWideChar(ImagePath), GUID_NULL, GENERIC_READ, WICDecodeMetadataCacheOnLoad, Decoder))) then
    Exit;
  if (Failed(Decoder.GetFrame(0, Frame))) then
    Exit;
  if (Failed(WICFactory.CreateBitmapFromSource(Frame, WICBitmapCacheOnLoad, Result))) then
    Result := nil;
end;

procedure XWICImage_Release(var Bitmap: IWICBitmap);
begin
  if Assigned(Bitmap) then
  begin
    Bitmap._Release;
    Bitmap := nil;
  end;
end;

function Ensure32bppPBGRA(var SourceBitmap: IWICBitmap): Boolean;
var
  SourceFormat: TGUID;
  Converter: IWICFormatConverter;
  NewBitmap: IWICBitmap;
begin
  Result := False;
  if (Failed(SourceBitmap.GetPixelFormat(SourceFormat))) then
  begin
    XWICImage_Release(SourceBitmap);
    Exit;
  end;
  if (SourceFormat = GUID_WICPixelFormat32bppPBGRA) then
  begin
    Result := True;
    Exit;
  end;
  if (Failed(WICFactory.CreateFormatConverter(Converter))) then
  begin
    XWICImage_Release(SourceBitmap);
    Exit;
  end;
  if (Failed(Converter.Initialize(SourceBitmap, GUID_WICPixelFormat32bppPBGRA, WICBitmapDitherTypeNone, nil, 0.0, WICBitmapPaletteTypeCustom))) then
  begin
    XWICImage_Release(SourceBitmap);
    Exit;
  end;
  if (Failed(WICFactory.CreateBitmapFromSource(Converter, WICBitmapCacheOnLoad, NewBitmap))) then
  begin
    XWICImage_Release(SourceBitmap);
    Exit;
  end;
  XWICImage_Release(SourceBitmap);
  SourceBitmap := NewBitmap;
  Result := True;
end;

function XWICImage_Scale(const SourceBitmap: IWICBitmap; Width, Height: UINT; CropAlign: TCropAlignFlags = [AlignHCenter, AlignVCenter]): IWICBitmap;
var
  Scaler: IWICBitmapScaler;
  Clipper: IWICBitmapClipper;
  SrcWidth, SrcHeight, ScaledWidth, ScaledHeight: UINT;
  TargetRatio, SourceRatio: Double;
  ClipX, ClipY: Integer;
  WRect: WICRect;
begin
  Result := nil;
  if (not Assigned(WICFactory) or not Assigned(SourceBitmap) or (Width = 0) or (Height = 0)) then
    Exit;
  if (Failed(SourceBitmap.GetSize(SrcWidth, SrcHeight))) then
    Exit;
  TargetRatio := Width / Height;
  SourceRatio := SrcWidth / SrcHeight;
  if (SourceRatio > TargetRatio) then
  begin
    ScaledHeight := Height;
    ScaledWidth := Ceil(Height * SourceRatio);
  end
  else
  begin
    ScaledWidth := Width;
    ScaledHeight := Ceil(Width / SourceRatio);
  end;
  if (Failed(WICFactory.CreateBitmapScaler(Scaler))) then
    Exit;
  if (Failed(Scaler.Initialize(SourceBitmap, ScaledWidth, ScaledHeight, WICBitmapInterpolationModeFant))) then
    Exit;
  if ((ScaledWidth = Width) and (ScaledHeight = Height)) then
  begin
    WICFactory.CreateBitmapFromSource(Scaler, WICBitmapCacheOnLoad, Result);
    Exit;
  end;

  if (AlignLeft in CropAlign) then
    ClipX := 0
  else if (AlignRight in CropAlign) then
    ClipX := ScaledWidth - Width
  else if (AlignHCenter in CropAlign) then
    ClipX := (ScaledWidth - Width) div 2
  else
    ClipX := (ScaledWidth - Width) div 2;

  if (AlignTop in CropAlign) then
    ClipY := 0
  else if (AlignBottom in CropAlign) then
    ClipY := ScaledHeight - Height
  else if (AlignVCenter in CropAlign) then
    ClipY := (ScaledHeight - Height) div 2
  else
    ClipY := (ScaledHeight - Height) div 2;

  ClipX := Max(ClipX, 0);
  ClipY := Max(ClipY, 0);
  WRect.X := ClipX;
  WRect.Y := ClipY;
  WRect.Width := Width;
  WRect.Height := Height;
  if (Failed(WICFactory.CreateBitmapClipper(Clipper))) then
    Exit;
  if (Failed(Clipper.Initialize(Scaler, WRect))) then
    Exit;
  WICFactory.CreateBitmapFromSource(Clipper, WICBitmapCacheOnLoad, Result);
end;

function XWICImage_SaveToFile(const Bitmap: IWICBitmap; const FilePath: string): Boolean;
var
  Encoder: IWICBitmapEncoder;
  Stream: IWICStream;
  FrameEncode: IWICBitmapFrameEncode;
  Props: IPropertyBag2;
  ContainerFormat: TGUID;
begin
  Result := False;
  if (not Assigned(WICFactory) or not Assigned(Bitmap) or (FilePath = '')) then
    Exit;
  if (Failed(XWICImage_GetEncoderClsid(FilePath, ContainerFormat))) then
    Exit;
  if (Failed(WICFactory.CreateStream(Stream))) then
    Exit;
  if (Failed(Stream.InitializeFromFilename(PWideChar(FilePath), GENERIC_WRITE))) then
    Exit;
  if (Failed(WICFactory.CreateEncoder(ContainerFormat, GUID_NULL, Encoder))) then
    Exit;
  if (Failed(Encoder.Initialize(Stream, WICBitmapEncoderNoCache))) then
    Exit;
  if (Failed(Encoder.CreateNewFrame(FrameEncode, Props))) then
    Exit;
  Result := (Succeeded(FrameEncode.Initialize(nil)) and Succeeded(FrameEncode.WriteSource(Bitmap, nil)) and Succeeded(FrameEncode.Commit) and Succeeded(Encoder.Commit));
end;

function XWICImage_GetEncoderClsid(const FileName: string; var pClsid: TGUID): HRESULT;
var
  Ext: string;
begin
  Ext := LowerCase(ExtractFileExt(FileName));
  if (Ext = '.bmp') then
    pClsid := GUID_ContainerFormatBmp
  else if (Ext = '.png') then
    pClsid := GUID_ContainerFormatPng
  else if ((Ext = '.jpg') or (Ext = '.jpeg')) then
    pClsid := GUID_ContainerFormatJpeg
  else
  begin
    Result := E_FAIL;
    Exit;
  end;
  Result := S_OK;
end;

function XWICImage_ScaleAndSaveToFile(const SourcePath, DestPath: string; DestWidth, DestHeight: UINT): Boolean;
var
  SourceBitmap, ScaledBitmap: IWICBitmap;
begin
  Result := False;
  SourceBitmap := XWICImage_LoadFile(SourcePath);
  if (not Assigned(SourceBitmap)) then
    Exit;
  ScaledBitmap := XWICImage_Scale(SourceBitmap, DestWidth, DestHeight, [AlignHCenter, AlignVCenter]);
  if (not Assigned(ScaledBitmap)) then
    Exit;
  Result := XWICImage_SaveToFile(ScaledBitmap, DestPath);
end;

function XWICImage_ConvertToGrayscale(const SourceBitmap: IWICBitmap): IWICBitmap;
var
  Factory: IWICImagingFactory;
  Converter: IWICFormatConverter;
  PixelFormat: TGUID;
begin
  Result := nil;
  if (Failed(CoCreateInstance(CLSID_WICImagingFactory, nil, CLSCTX_INPROC_SERVER, IID_IWICImagingFactory, Factory))) then
    Exit;
  if (Failed(Factory.CreateFormatConverter(Converter))) then
    Exit;
  PixelFormat := GUID_WICPixelFormat8bppGray;
  if (Failed(Converter.Initialize(SourceBitmap, PixelFormat, WICBitmapDitherTypeNone, nil, 0.0, WICBitmapPaletteTypeCustom))) then
    Exit;
  if (Failed(Factory.CreateBitmapFromSource(Converter, WICBitmapCacheOnLoad, Result))) then
    Exit;
end;


function XWICImage_ToHBITMAP(const pBitmap: IWICBitmap): HBITMAP;
var
  bmi: TBitmapInfo;
  pbBuffer: Pointer;
  converter: IWICFormatConverter;
  srcWidth, srcHeight, srcStride, bufferSize: UINT;
begin
  Result := 0;
  if (not Assigned(pBitmap)) then
    Exit;
  if (Failed(WICFactory.CreateFormatConverter(converter))) then
    Exit;
  if (Failed(converter.Initialize(pBitmap, GUID_WICPixelFormat32bppPBGRA, WICBitmapDitherTypeNone, nil, 0, WICBitmapPaletteTypeMedianCut))) then
    Exit;
  converter.GetSize(srcWidth, srcHeight);
  srcStride := srcWidth * 4;
  bufferSize := srcStride * srcHeight;
  ZeroMemory(@bmi, SizeOf(bmi));
  with bmi.bmiHeader do
  begin
    biSize := SizeOf(TBitmapInfoHeader);
    biWidth := srcWidth;
    biHeight := -Integer(srcHeight);
    biPlanes := 1;
    biBitCount := 32;
    biCompression := BI_RGB;
    biSizeImage := bufferSize;
  end;
  Result := CreateDIBSection(0, bmi, DIB_RGB_COLORS, pbBuffer, 0, 0);
  if (Result = 0) then
    Exit;
  if (Failed(converter.CopyPixels(nil, srcStride, bufferSize, pbBuffer))) then
  begin
    DeleteObject(Result);
    Result := 0;
  end;
end;

function XWICImage_ToD2DImage(const RenderTarget: ID2D1RenderTarget; const SourceBitmap: IWICBitmap): ID2D1Bitmap;
var
  Converter: IWICFormatConverter;
  wicBitmapSourceToUse: IWICBitmapSource;
  PixelFormat: TGUID;
begin
  Result := nil;
  if not Assigned(RenderTarget) or not Assigned(SourceBitmap) or not Assigned(WICFactory) then
    Exit;

  if Failed(SourceBitmap.GetPixelFormat(PixelFormat)) then
    Exit;

  if IsEqualGUID(PixelFormat, GUID_WICPixelFormat32bppPBGRA) then
    wicBitmapSourceToUse := SourceBitmap
  else
  begin
    if Failed(WICFactory.CreateFormatConverter(Converter)) then
      Exit;
    if Failed(Converter.Initialize(SourceBitmap, GUID_WICPixelFormat32bppPBGRA, WICBitmapDitherTypeNone, nil, 0.0, WICBitmapPaletteTypeMedianCut)) then
      Exit;
    wicBitmapSourceToUse := Converter;
  end;

  if Failed(RenderTarget.CreateBitmapFromWicBitmap(wicBitmapSourceToUse, nil, Result)) then
    Result := nil;
end;

end.


