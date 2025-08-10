unit UI_Mask;

interface

uses
  Winapi.Windows, System.Classes, Winapi.Messages, XCGUI, System.SysUtils, Math,
  XLayout, XWidget, ImageCore, Winapi.D2D1;

type
  TMaskLoadUI = class(TXLayout)
  private
    FText: string;
    FLoadEle: Integer;
    FProgress: Single;
    FStartAngle: Single;
    FCircleRadius: Single;
    FIsIncreasing: Boolean;
    FTailAngle: Single;
    function GetText: string;
    procedure SetText(Text: string);
    function GetProgress: Single;
    procedure SetProgress(Value: Single);
    function GetStartAngle: Single;
    procedure SetStartAngle(Value: Single);
    function GetCircleRadius: Single;
    procedure SetCircleRadius(Value: Single);
    function CreateTextFormat(out ATextFormat: IDWriteTextFormat): HRESULT;
    class function OnElePAINT(hEle: Integer; hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnEleXCTimer(hEle:Integer;nTimerID: UINT; var pbHandled: Boolean): Integer; stdcall; static;
  protected
    procedure Init; override;
  public
    destructor Destroy; override;
    procedure ShowLoading(const AText: string = '正在加载...');
    procedure HideLoading;
    property Text: string read GetText write SetText;
    property Progress: Single read GetProgress write SetProgress;
    property StartAngle: Single read GetStartAngle write SetStartAngle;
    property CircleRadius: Single read GetCircleRadius write SetCircleRadius;
  end;

implementation

uses
  UI_Color;

destructor TMaskLoadUI.Destroy;
begin
  XWnd_AdjustLayout(GetHWINDOW);
  XWnd_Redraw(GetHWINDOW);
  inherited;
end;

function TMaskLoadUI.GetText: string;
begin
  Result := FText;
end;

procedure TMaskLoadUI.Init;
begin
  FProgress := 0.6;
  FStartAngle := -90; // 默认顶部为起点
  FCircleRadius := 40; // 默认圆半径
  FIsIncreasing := True;
  FTailAngle := 0;
  XWidget_LayoutItem_SetWidth(Handle, layout_size_fill, 1);
  XWidget_LayoutItem_SetHeight(Handle, layout_size_fill, 1);
  XLayoutBox_SetAlignV(Handle, layout_align_center);
  XLayoutBox_SetAlignH(Handle, layout_align_center);
  FLoadEle := XEle_Create(110, 110, 200, 200, Handle);
  XEle_SetUserData(FLoadEle, Integer(Self));
  XEle_EnableBkTransparent(FLoadEle, True);
  XEle_RegEvent(FLoadEle, XE_PAINT, @OnElePAINT);
  XWnd_AdjustLayout(hWindow);
  XWnd_Redraw(hWindow);
  RegEvent(XE_XC_TIMER, @OnEleXCTimer);
  inherited;
end;

function TMaskLoadUI.CreateTextFormat(out ATextFormat: IDWriteTextFormat): HRESULT;
begin
  Result := DWriteFactory.CreateTextFormat('微软雅黑', nil, DWRITE_FONT_WEIGHT_BOLD, DWRITE_FONT_STYLE_NORMAL, DWRITE_FONT_STRETCH_NORMAL, 13.6, 'zh-CN', ATextFormat);
end;

class function TMaskLoadUI.OnElePAINT(hEle: Integer; hDraw: Integer; pbHandled: PBoolean): Integer; stdcall;
var
  RC: TRect;
  RenderTarget: ID2D1RenderTarget;
  CenterX, CenterY: Single;
  Factory: ID2D1Factory;
  PathGeometry: ID2D1PathGeometry;
  Sink: ID2D1GeometrySink;
  StartAngle, SweepAngle: Single;
  StartPoint, EndPoint: D2D1_POINT_2F;
  Progress: Single; // 0.0 ~ 1.0
  Brush: ID2D1SolidColorBrush;
  StrokeStyle: ID2D1StrokeStyle;
  OldAntialiasMode: D2D1_ANTIALIAS_MODE;
  EllipseGeo: ID2D1EllipseGeometry;
  LThis: TMaskLoadUI;
  CircleRadius: Single;
  ArcSize: D2D1_ARC_SIZE;
  TextFormat: IDWriteTextFormat;
  TextLayout: IDWriteTextLayout;
  TextRect: D2D1_RECT_F;
begin
  Result := 0;
  pbHandled^ := True;
  LThis := TMaskLoadUI(XEle_GetUserData(hEle));
  if not Assigned(LThis) then
    Exit;
  XEle_GetClientRect(hEle, RC);

  XDraw_SetBrushColor(hDraw, RGBA(0, 0, 0, 220));
  XDraw_FillRoundRectEx(hDraw, RC, 12, 12, 12, 12);
  RenderTarget := ID2D1RenderTarget(XDraw_GetD2dRenderTarget(hDraw));
  XEle_RectClientToWndClientDPI(hEle, RC);
  if not Assigned(RenderTarget) then
    Exit;

  OldAntialiasMode := RenderTarget.GetAntialiasMode;
  RenderTarget.SetAntialiasMode(D2D1_ANTIALIAS_MODE_PER_PRIMITIVE);

  CenterX := (RC.Left + RC.width) / 2;
  CenterY := (RC.Top + RC.height) / 2 - 22;
  CircleRadius := LThis.FCircleRadius;

  Factory := nil;
  RenderTarget.GetFactory(Factory);
  Factory.CreateStrokeStyle(D2D1StrokeStyleProperties(D2D1_CAP_STYLE_ROUND, D2D1_CAP_STYLE_ROUND, D2D1_CAP_STYLE_ROUND, D2D1_LINE_JOIN_ROUND, 10.0, D2D1_DASH_STYLE_SOLID, 0.0), nil, 0, StrokeStyle);

  // 绘制半透明背景圆
  if Succeeded(RenderTarget.CreateSolidColorBrush(D2D1ColorF(1.0, 1.0, 1.0, 0.15), nil, Brush)) then
  begin
    Factory.CreateEllipseGeometry(D2D1Ellipse(D2D1PointF(CenterX, CenterY), CircleRadius, CircleRadius), EllipseGeo);
    RenderTarget.DrawGeometry(EllipseGeo, Brush, 6, StrokeStyle);
    Brush := nil;
    EllipseGeo := nil;
  end;

  Progress := LThis.FProgress;
  if Progress > 0 then
  begin
    if Succeeded(RenderTarget.CreateSolidColorBrush(D2D1ColorF(1.0, 1.0, 1.0, 1.0), nil, Brush)) then
    begin
      StartAngle := LThis.FStartAngle;
      SweepAngle := 360 * Progress;
      if SweepAngle > 360 then SweepAngle := 360; // 限制最大角度

      if SweepAngle > 180 then
        ArcSize := D2D1_ARC_SIZE_LARGE
      else
        ArcSize := D2D1_ARC_SIZE_SMALL;

      Factory.CreatePathGeometry(PathGeometry);
      PathGeometry.Open(Sink);

      // 头部始终在StartAngle，尾部在StartAngle - SweepAngle
      EndPoint := D2D1PointF(CenterX + CircleRadius * Cos(StartAngle * Pi / 180),
                             CenterY + CircleRadius * Sin(StartAngle * Pi / 180));
      StartPoint := D2D1PointF(CenterX + CircleRadius * Cos((StartAngle - SweepAngle) * Pi / 180),
                               CenterY + CircleRadius * Sin((StartAngle - SweepAngle) * Pi / 180));

      Sink.BeginFigure(StartPoint, D2D1_FIGURE_BEGIN_HOLLOW);
      Sink.AddArc(D2D1ArcSegment(EndPoint, D2D1SizeF(CircleRadius, CircleRadius), SweepAngle, D2D1_SWEEP_DIRECTION_CLOCKWISE, ArcSize));
      Sink.EndFigure(D2D1_FIGURE_END_OPEN);
      Sink.Close;

      RenderTarget.DrawGeometry(PathGeometry, Brush, 6, StrokeStyle);
      Brush := nil;
    end;
  end;

  // 绘制文本
  if (LThis.FText <> '') and Succeeded(RenderTarget.CreateSolidColorBrush(D2D1ColorF(1.0, 1.0, 1.0, 1.0), nil, Brush)) then
  begin
    if Assigned(DWriteFactory) and Succeeded(LThis.CreateTextFormat(TextFormat)) then
    begin
      TextFormat.SetTextAlignment(DWRITE_TEXT_ALIGNMENT_CENTER);
      TextFormat.SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);

      // 设置文本区域
      TextRect := D2D1RectF(RC.Left, CenterY + CircleRadius - 12, RC.width, RC.height - 8);

      // 创建文本布局
      if Succeeded(DWriteFactory.CreateTextLayout(PChar(LThis.FText), Length(LThis.FText), TextFormat, TextRect.right - TextRect.left, TextRect.bottom - TextRect.top, TextLayout)) then
      begin
        // 绘制文本
        RenderTarget.DrawTextLayout(D2D1PointF(TextRect.left, TextRect.top), TextLayout, Brush, D2D1_DRAW_TEXT_OPTIONS_NONE);
        TextLayout := nil;
      end;
      TextFormat := nil;
    end;
    Brush := nil;
  end;

  RenderTarget.SetAntialiasMode(OldAntialiasMode);
  StrokeStyle := nil;
  Sink := nil;
  PathGeometry := nil;
  Factory := nil;
end;

procedure TMaskLoadUI.SetText(Text: string);
var
  TextFormat: IDWriteTextFormat;
  TextLayout: IDWriteTextLayout;
  TextMetrics: DWRITE_TEXT_METRICS;
  TextSize: TSize;
begin
  FText := Text;
  if not XC_IsHELE(Handle) then
    Exit;

  if Succeeded(CreateTextFormat(TextFormat)) then
  begin
    if Succeeded(DWriteFactory.CreateTextLayout(PChar(Text), Length(Text), TextFormat, 1000, 1000, TextLayout)) then
    begin
      TextLayout.GetMetrics(TextMetrics);
      TextSize.cx := Ceil(TextMetrics.width);
      TextSize.cy := Ceil(TextMetrics.height);
      TextLayout := nil;
    end;
    TextFormat := nil;
  end;

  XEle_SetWidth(FLoadEle, Max(200, TextSize.cx + 50));
  XEle_SetHeight(FLoadEle, Max(100, round(FCircleRadius * 2) + TextSize.cy + 60));

  if XC_IsHELE(FLoadEle) then
    XEle_Redraw(FLoadEle, True);
end;

procedure TMaskLoadUI.ShowLoading(const AText: string);
begin
  if not IsShow then
  begin
    Show(True);
    Text := AText;
    XWnd_AdjustLayout(GetHWINDOW);
    SetXCTimer(44,15);
  end;
end;

procedure TMaskLoadUI.HideLoading;
begin
  KillXCTimer(44);
  Show(False);
end;

class function TMaskLoadUI.OnEleXCTimer(hEle: Integer; nTimerID: UINT; var pbHandled: Boolean): Integer;
var
  LoadUI: TMaskLoadUI;
begin
  Result := 0;
  LoadUI := TMaskLoadUI.GetClassFormHandle(hEle);

  if not Assigned(LoadUI) then
    Exit;

  if LoadUI.FIsIncreasing then
  begin
    // 变长：尾部固定，头部旋转，进度是被动计算出来的
    LoadUI.FProgress := (LoadUI.FStartAngle - LoadUI.FTailAngle) / 360.0;
    if LoadUI.FProgress >= 0.7 then
    begin
      LoadUI.FProgress := 0.7;
      LoadUI.FIsIncreasing := False;
    end;
  end
  else
  begin
    // 变短：主动缩短尾部，速度减慢（原来是0.015，提高1.5倍）
    LoadUI.FProgress := LoadUI.FProgress - 0.0225;

    if LoadUI.FProgress <= 0.2 then
    begin
      LoadUI.FProgress := 0.2;
      LoadUI.FIsIncreasing := True;
      // 开始加长时，记录当前尾部的位置
      LoadUI.FTailAngle := LoadUI.FStartAngle - (360.0 * LoadUI.FProgress);
    end;
  end;

  // 更新旋转角度 (持续增加)（原来是6，提高1.5倍）
  LoadUI.FStartAngle := LoadUI.FStartAngle + 9;

  LoadUI.Redraw();
end;

function TMaskLoadUI.GetProgress: Single;
begin
  Result := FProgress;
end;

procedure TMaskLoadUI.SetProgress(Value: Single);
begin
  FProgress := Max(0, Min(1, Value));
  if XC_IsHELE(FLoadEle) then
    XEle_Redraw(FLoadEle, True);
end;

function TMaskLoadUI.GetStartAngle: Single;
begin
  Result := FStartAngle;
end;

procedure TMaskLoadUI.SetStartAngle(Value: Single);
begin
  FStartAngle := Value;
  if XC_IsHELE(FLoadEle) then
    XEle_Redraw(FLoadEle, True);
end;

function TMaskLoadUI.GetCircleRadius: Single;
begin
  Result := FCircleRadius;
end;

procedure TMaskLoadUI.SetCircleRadius(Value: Single);
begin
  FCircleRadius := Max(5, Value); // 设置最小半径为5
  if XC_IsHELE(FLoadEle) then
    XEle_Redraw(FLoadEle, True);
end;

end.

