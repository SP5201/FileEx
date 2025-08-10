unit UI_MoviePanel;

interface

uses
  Windows, SysUtils, Classes, ShellAPI, XCGUI, XLayout, UI_MarqueeLabel,
  UI_TagBox, UI_Resource, Ui_Color, XWidget, XElement, WICImageHelper, D2D1,
  DxgiFormat;

type
  TMoviePanelUI = class(TXLayout)
  private
    FVideoD2DBitmap: ID2D1Bitmap;
    FVideoFrameData: TBytes;
    FNewVideoFrame: Boolean;
    FVideoFrameWidth: Integer;
    FVideoFrameHeight: Integer;

    FVideoPreviewHeight: Integer;
    FMoviePath: string;
    FMarqueeLabelUI: TMarqueeLabelUI;
    FTagBoxUI: TTagBoxUI;

    FMarqueeText: string;

    FPlottEditText: string;
    // 渐变颜色相关变量
    FGradientStartColor: TD2D1ColorF;
    FGradientEndColor: TD2D1ColorF;

    FLastFramePtr: Pointer; // 新增：用于存储帧数据的指针
    FLastFrameLen: Integer; // 新增：用于存储帧数据的长度

    procedure SetMarqueeText(const Value: string);

    procedure SetPlotText(const Value: string);
    procedure SetMoviePath(const Value: string);
    procedure UpdateGradientColors;
    procedure SetVideoPreviewHeight(const Value: Integer);

  protected
    procedure Init; override;
    class function OnPaint(hEle, hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
  public
    constructor Create(x: Integer = 0; y: Integer = 0; cx: Integer = 0; cy: Integer = 0; hParent: TXWidget = nil);
    destructor Destroy; override;
    procedure Clear;
    procedure ClearVideo;
    procedure SetVideoSize(AWidth, AHeight: Integer);
    procedure UpdateVideoFrame(const AData: Pointer; ADataLen, AWidth, AHeight: Integer);
    property MarqueeText: string read FMarqueeText write SetMarqueeText;

    property PlotText: string read FPlottEditText write SetPlotText;
    property MoviePath: string read FMoviePath write SetMoviePath;
    property VideoPreviewHeight: Integer read FVideoPreviewHeight write SetVideoPreviewHeight;

    property TagBox: TTagBoxUI read FTagBoxUI;
  end;

implementation

procedure TMoviePanelUI.UpdateGradientColors;
begin
  // 从Theme_Window_BkColor提取RGB值
  FGradientStartColor.r := GetRValue(Theme_Window_BkColor) / 255;
  FGradientStartColor.g := GetGValue(Theme_Window_BkColor) / 255;
  FGradientStartColor.b := GetBValue(Theme_Window_BkColor) / 255;
  FGradientStartColor.a := 0.0; // 完全透明

  FGradientEndColor.r := GetRValue(Theme_Window_BkColor) / 255;
  FGradientEndColor.g := GetGValue(Theme_Window_BkColor) / 255;
  FGradientEndColor.b := GetBValue(Theme_Window_BkColor) / 255;
  FGradientEndColor.a := 1.0; // 完全不透明
end;

procedure TMoviePanelUI.Init;
begin
  inherited;
  RegEvent(XE_PAINT, @OnPAINT);
  FVideoPreviewHeight := 220;
  FMarqueeLabelUI := TMarqueeLabelUI.FromXmlName('左侧展示_标题');
  FMarqueeLabelUI.EnableBkTransparent(True);
  FMarqueeLabelUI.Speed := 50;
  FTagBoxUI := TTagBoxUI.FromXmlName('左侧展示_分类盒');

  // 初始化渐变颜色
  UpdateGradientColors;

  // 注册主题变更回调，当主题改变时更新渐变颜色
  XTheme_AddChangeCallback(UpdateGradientColors);
end;

class function TMoviePanelUI.OnPaint(hEle, hDraw: Integer; pbHandled: PBoolean): Integer;
var
  PanelUI: TMoviePanelUI;
  RenderTarget: TRenderTarget;
  destRect: TD2D1RectF;
  props: TD2D1BitmapProperties;
  bmSize: TD2D1SizeU;
  rc: TD2D1RectU;
  R: TRect;
  gradientStops: array[0..1] of TD2D1GradientStop;
  gradientStopCollection: ID2D1GradientStopCollection;
  linearGradientBrush: ID2D1LinearGradientBrush;
  gradientRect: TD2D1RectF;
  linearGradientBrushProps: TD2D1LinearGradientBrushProperties;
  availableWidth: Integer;
  destWidth, destHeight, containerHeight: Single;
  sourceWidth, sourceHeight: Integer;
  aspectRatio: Single;
  stride: Integer;
  srcRect: TD2D1RectF;
  containerRatio: Single;
  roundedRect: TD2D1RoundedRect;
  roundedRectGeo: ID2D1RoundedRectangleGeometry;
  layerParams: TD2D1LayerParameters;
  d2dFactory: ID2D1Factory;
  identityMatrix: TD2D1Matrix3x2F;
begin
  Result := 0;
  pbHandled^ := True;
  PanelUI := TMoviePanelUI.GetClassFormHandle(hEle);
  if not Assigned(PanelUI) then
    Exit;

  RenderTarget := ID2D1RenderTarget(XDraw_GetD2dRenderTarget(hDraw));
  if not Assigned(RenderTarget) then
    Exit;


  try
    // 优先处理和绘制视频帧: 当有新数据时，创建或更新D2D位图
    if PanelUI.FNewVideoFrame and (PanelUI.FLastFramePtr <> nil) then
    begin
      PanelUI.FNewVideoFrame := False;

      // 设置位图属性
      props.pixelFormat := D2D1PixelFormat(DXGI_FORMAT_B8G8R8A8_UNORM, D2D1_ALPHA_MODE_PREMULTIPLIED);
      props.dpiX :=  PanelUI.DPI;
      props.dpiY := PanelUI.DPI;

      // 获取原始视频帧尺寸
      sourceWidth := PanelUI.FVideoFrameWidth;
      sourceHeight := PanelUI.FVideoFrameHeight;

      // 确保尺寸有效
      if (sourceWidth <= 0) or (sourceHeight <= 0) then
        Exit;

      // 计算行步长 (每行的字节数，包括可能的填充)
      stride := sourceWidth * 4; // BGRA格式，每像素4字节

      // 检查是否需要重新创建位图
      if Assigned(PanelUI.FVideoD2DBitmap) then
      begin
        PanelUI.FVideoD2DBitmap.GetPixelSize(bmSize);
        if (bmSize.width <> Cardinal(sourceWidth)) or (bmSize.height <> Cardinal(sourceHeight)) then
          PanelUI.FVideoD2DBitmap := nil;
      end;

      // 创建新位图
      if not Assigned(PanelUI.FVideoD2DBitmap) then
      begin
        bmSize.width := sourceWidth;
        bmSize.height := sourceHeight;
        RenderTarget.CreateBitmap(bmSize, nil, 0, props, PanelUI.FVideoD2DBitmap);
      end;

      // 复制帧数据到位图
      if Assigned(PanelUI.FVideoD2DBitmap) and (PanelUI.FLastFrameLen >= stride * sourceHeight) then
      begin
        rc.left := 0;
        rc.top := 0;
        rc.right := sourceWidth;
        rc.bottom := sourceHeight;
        PanelUI.FVideoD2DBitmap.CopyFromMemory(rc, PanelUI.FLastFramePtr, stride);
      end;
    end;

    // 绘制视频帧和渐变效果
    if Assigned(PanelUI.FVideoD2DBitmap) then
    begin
      // 获取面板尺寸
      XEle_GetWndClientRectDPI(hEle, R);

      // 获取位图尺寸
      PanelUI.FVideoD2DBitmap.GetPixelSize(bmSize);
      sourceWidth := bmSize.width;
      sourceHeight := bmSize.height;

      if (sourceWidth <= 0) or (sourceHeight <= 0) then
        Exit;

      availableWidth := R.Width;
      containerHeight := Round(PanelUI.FVideoPreviewHeight * PanelUI.DpiScale);
      destRect := D2D1RectF(R.Left, R.Top, R.Right, R.Top + containerHeight);

      containerRatio := availableWidth / containerHeight;
      aspectRatio := sourceWidth / sourceHeight;

      if aspectRatio > containerRatio then
      begin
        // 视频更宽，水平裁剪
        srcRect.Top := 0;
        srcRect.Bottom := sourceHeight;
        destWidth := sourceHeight * containerRatio;
        srcRect.Left := (sourceWidth - destWidth) / 2;
        srcRect.Right := srcRect.Left + destWidth;
      end
      else
      begin
        // 视频更高，垂直裁剪
        srcRect.Left := 0;
        srcRect.Right := sourceWidth;
        destHeight := sourceWidth / containerRatio;
        srcRect.Top := (sourceHeight - destHeight) / 2;
        srcRect.Bottom := srcRect.Top + destHeight;
      end;

      // 改为绘制圆角图片
      roundedRect.rect := destRect;
      roundedRect.radiusX := 8 * PanelUI.DpiScale;
      roundedRect.radiusY := 8 * PanelUI.DpiScale;

      // 获取D2D工厂
      RenderTarget.GetFactory(d2dFactory);
      if Assigned(d2dFactory) then
      begin
        d2dFactory.CreateRoundedRectangleGeometry(roundedRect, roundedRectGeo);
        d2dFactory := nil;
      end;

      if Assigned(roundedRectGeo) then
      try
        // 设置图层参数
        identityMatrix := Default(TD2D1Matrix3x2F);
        identityMatrix._11 := 1.0;
        identityMatrix._22 := 1.0;

        layerParams.contentBounds := destRect;
        layerParams.geometricMask := roundedRectGeo;
        layerParams.maskAntialiasMode := D2D1_ANTIALIAS_MODE_PER_PRIMITIVE;
        layerParams.maskTransform := identityMatrix;
        layerParams.opacity := 1.0;
        layerParams.opacityBrush := nil;
        layerParams.layerOptions := D2D1_LAYER_OPTIONS_NONE;

        // 推入图层
        RenderTarget.PushLayer(layerParams, nil);

        // 在图层内绘制位图
        RenderTarget.DrawBitmap(PanelUI.FVideoD2DBitmap, @destRect, 1.0,
          D2D1_BITMAP_INTERPOLATION_MODE_LINEAR, @srcRect);

        // 弹出图层
        RenderTarget.PopLayer;
      finally
        roundedRectGeo := nil;
      end
      else
      begin
        // 如果创建几何体失败，则回退到原始的绘制方式
        RenderTarget.DrawBitmap(PanelUI.FVideoD2DBitmap, @destRect, 1.0,  // 不透明度为100%
          D2D1_BITMAP_INTERPOLATION_MODE_LINEAR, @srcRect);
      end;

      // 绘制底部渐变
      gradientStops[0].color := PanelUI.FGradientStartColor;
      gradientStops[0].position := 0.0;
      gradientStops[1].color := PanelUI.FGradientEndColor;
      gradientStops[1].position := 1.0;

      RenderTarget.CreateGradientStopCollection(@gradientStops[0], 2, D2D1_GAMMA_2_2, D2D1_EXTEND_MODE_CLAMP, gradientStopCollection);
      if Assigned(gradientStopCollection) then
      begin
        gradientRect := D2D1RectF(R.Left, R.top + (containerHeight * 0.3), R.Right, containerHeight + R.top);
        linearGradientBrushProps.startPoint := D2D1PointF(gradientRect.left, gradientRect.top);
        linearGradientBrushProps.endPoint := D2D1PointF(gradientRect.left, gradientRect.bottom);

        RenderTarget.CreateLinearGradientBrush(linearGradientBrushProps, nil, gradientStopCollection, linearGradientBrush);
        if Assigned(linearGradientBrush) then
        begin
          RenderTarget.FillRectangle(gradientRect, linearGradientBrush);
          linearGradientBrush := nil;
        end;
        gradientStopCollection := nil;
      end;

      // 绘制右上角CSS效果渐变
      gradientStops[0].color := PanelUI.FGradientEndColor;
      gradientStops[0].position := 0;
      gradientStops[1].color := PanelUI.FGradientStartColor;
      gradientStops[1].position := 0.5;

      RenderTarget.CreateGradientStopCollection(@gradientStops[0], 2, D2D1_GAMMA_2_2, D2D1_EXTEND_MODE_CLAMP, gradientStopCollection);
      if Assigned(gradientStopCollection) then
      begin
        gradientRect := D2D1RectF(R.width - 100, R.top, R.Right, R.top + 100);
        linearGradientBrushProps.startPoint := D2D1PointF(gradientRect.right, gradientRect.top);
        linearGradientBrushProps.endPoint := D2D1PointF(gradientRect.left, gradientRect.bottom);

        RenderTarget.CreateLinearGradientBrush(linearGradientBrushProps, nil, gradientStopCollection, linearGradientBrush);
        if Assigned(linearGradientBrush) then
        begin
          RenderTarget.FillRectangle(gradientRect, linearGradientBrush);
          linearGradientBrush := nil;
        end;
        gradientStopCollection := nil;
      end;
    end;
  finally
  end;
end;

constructor TMoviePanelUI.Create(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  inherited Create(x, y, cx, cy, hParent);
end;

destructor TMoviePanelUI.Destroy;
begin
  // 移除主题变更回调
  XTheme_RemoveThemeChangeCallback(UpdateGradientColors);

  FVideoD2DBitmap := nil;
  FVideoFrameData := nil;
  inherited;
end;

procedure TMoviePanelUI.ClearVideo;
begin
  if Assigned(FVideoD2DBitmap) then
    FVideoD2DBitmap := nil;
  FVideoFrameData := nil;
  FLastFramePtr := nil;
  FLastFrameLen := 0;
end;

procedure TMoviePanelUI.Clear;
begin
  ClearVideo;
  FMoviePath := '';
  MarqueeText := '';
  PlotText := '';
  TagBox.Rating := -2;
  TagBox.Year := 0;
end;

procedure TMoviePanelUI.SetMarqueeText(const Value: string);
begin
  FMarqueeText := Value;
  if Assigned(FMarqueeLabelUI) then
    FMarqueeLabelUI.MarqueeText := Value;
end;

procedure TMoviePanelUI.SetMoviePath(const Value: string);
begin
  FMoviePath := Value;
end;

procedure TMoviePanelUI.SetPlotText(const Value: string);
begin
  FPlottEditText := Value;
  if Assigned(FTagBoxUI) then
  begin
    FTagBoxUI.PlotText := Value;
  end;
end;


procedure TMoviePanelUI.SetVideoSize(AWidth, AHeight: Integer);
begin
  if (FVideoFrameWidth <> AWidth) or (FVideoFrameHeight <> AHeight) then
  begin
    FVideoFrameWidth := AWidth;
    FVideoFrameHeight := AHeight;
    FVideoD2DBitmap := nil;
    Redraw;
  end;
end;

procedure TMoviePanelUI.UpdateVideoFrame(const AData: Pointer; ADataLen, AWidth, AHeight: Integer);
begin
  try
    // 数据有效性检查
    if (AData = nil) or (ADataLen <= 0) then
      Exit;
    if (AWidth <= 0) or (AHeight <= 0) then
      Exit;

    // 存储原始视频帧尺寸
    FVideoFrameWidth := AWidth;
    FVideoFrameHeight := AHeight;

    // 拷贝帧数据到本地，避免外部指针失效
    // 只在必要时重新分配内存
    if Length(FVideoFrameData) <> ADataLen then
      SetLength(FVideoFrameData, ADataLen);

    if Length(FVideoFrameData) > 0 then
    begin
      Move(AData^, FVideoFrameData[0], ADataLen);
      FLastFramePtr := @FVideoFrameData[0];
      FLastFrameLen := ADataLen;
      FNewVideoFrame := True;

      // 使用完整重绘，确保整个视频区域平滑渲染

      RedrawRect(TRect.Create(0, 0, FVideoPreviewHeight, FVideoPreviewHeight), False);
    end;
  except
    on E: Exception do
    begin
      // 捕获任何异常，防止程序崩溃
    end;
  end;
end;

procedure TMoviePanelUI.SetVideoPreviewHeight(const Value: Integer);
begin
  FVideoPreviewHeight := Value;
end;

end.

