unit UI_Tooltip;

interface

uses
  Windows, Messages, Classes, XCGUI, XWidget, UI_Color, XForm, SysUtils,
  Winapi.DXGIFormat, ImageCore, System.Math, D2D1;

type
  THintPositionFlag = (
    Position_Flag_Bottom = 1,
    Position_Flag_Top = 2,
    Position_Flag_Left = 4,
    Position_Flag_Right = 8,
    Position_Flag_Center = 16,
    Position_Flag_Custom = 32
  );

  THintPosition = Integer;

  THintTextAlign = (HintTextAlign_Left, HintTextAlign_Center, HintTextAlign_Right);

  THintUI = class(TXForm)
    class var
      FParentWindow: HWINDOW;
      FHintWindow: HWINDOW;
      FHintWindowText: string;
      TextSize: TSIZE;
      FHintWindowWidth: Integer;
      FHintWindowHeight: Integer;
      FCurrentHintPosition: THintPosition;
      FCurrentTextAlign: THintTextAlign;
      FCurrentRotationAngle: Single;
      FClassTimerID: Integer;
      FClassAnimationStep: Integer;
      FClassAnimationDirection: Integer;
      FDPI: Integer;
      FDPIScale: Extended;
  private
    FHintText: string;
    FTargetComponentHandle: Integer;
    FTargetWidget: TXWidget;
    FOffsetX: Integer;
    FOffsetY: Integer;
    FHintPosition: THintPosition;
    FDefaultHintPosition: THintPosition;
    FTextAlign: THintTextAlign;
    FRotationAngle: Single;
    FEnableAnimation: Boolean;
    procedure CreateHintWindow;
    procedure ShowHintWindow;
    procedure HideHintWindow;
    procedure CalculateWindowSize;
    function CalculateWindowPosition: TPoint;
    class function OnMouseSTAY(hElement: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnMOUSELEAVE(hElement, hEleStay: Integer; pbHandled: pBoolean): Integer; stdcall; static;
    class function OnPAINT(hWindow, hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    procedure SetHintPosition(const Value: THintPosition);
    procedure SetTextAlign(const Value: THintTextAlign);
    procedure SetRotationAngle(const Value: Single);
    procedure SetEnableAnimation(const Value: Boolean);
    class function OnTimer(hWindow: Integer; nIDEvent: UINT_PTR; pbHandled: PBoolean): Integer; stdcall; static;
  public
    constructor RegisterHint(ATargetComponentHandle: Integer; const AHintText: string);
    procedure UnregisterHint;
    procedure Close;
    procedure SetPositionOffset(AOffsetX, AOffsetY: Integer);
    property Position: THintPosition read FHintPosition write SetHintPosition;
    property TextAlign: THintTextAlign read FTextAlign write SetTextAlign;
    property RotationAngle: Single read FRotationAngle write SetRotationAngle;
    property EnableAnimation: Boolean read FEnableAnimation write SetEnableAnimation;
  end;

const
  ANIMATION_TIMER_ID = 1;
  ANIMATION_INTERVAL = 4; // ms, for ~250 FPS, even faster animation
  ANIMATION_STEPS = 30;

  // 统一UI样式参数，方便管理和缩放
  DEFAULT_FONT_SIZE = 14.0;
  DEFAULT_CORNER_RADIUS = 4.0;
  DEFAULT_TRIANGLE_SIZE = 8.0;
  DEFAULT_TEXT_PADDING = 8.0;
  DEFAULT_SHADOW_PADDING = 20.0;

  // 阴影绘制参数
  SHADOW_STEPS = 21;
  SHADOW_MAX_BLUR_FACTOR = 40.0 / SHADOW_STEPS; // 模糊半径系数
  SHADOW_OPACITY_FACTOR = 0.035; // 不透明度系数

implementation

constructor THintUI.RegisterHint(ATargetComponentHandle: Integer; const AHintText: string);
begin
  FTargetComponentHandle := ATargetComponentHandle;
  FHintText := AHintText;
  FHintPosition := Integer(Position_Flag_Bottom) or Integer(Position_Flag_Center);
  FDefaultHintPosition := FHintPosition;
  FOffsetX := 0;
  FOffsetY := 0;
  FTextAlign := HintTextAlign_Left; // 默认居左对齐
  FRotationAngle := 0; // 默认不旋转
  FEnableAnimation := False; // 默认关闭动画
  XEle_RegEvent(FTargetComponentHandle, XE_MOUSESTAY, @OnMOUSESTAY);
  XEle_RegEvent(FTargetComponentHandle, XE_MOUSELEAVE, @OnMOUSELEAVE);
  FTargetWidget := TXWidget.GetClassFormHandle(ATargetComponentHandle);
  FTargetWidget.Tooltip := Self;

  if not XC_IsHWINDOW(FHintWindow) then
    CreateHintWindow;
end;

procedure THintUI.CreateHintWindow;
begin
  FHintWindow := XWnd_CreateEx(WS_EX_TOPMOST or WS_EX_TRANSPARENT or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE,
    WS_POPUP, nil, 0, 0, 100, 100, nil, XWidget_GetHWND(FTargetComponentHandle), window_style_nothing);
  XWnd_SetTransparentType(FHintWindow, window_transparent_shaped);
  XWnd_SetTransparentAlpha(FHintWindow, 240);
  XWnd_RegEvent(FHintWindow, WM_PAINT, @OnPAINT);
  XWnd_RegEvent(FHintWindow, WM_TIMER, @OnTimer);
end;

function GetTextShowSize(const AText: string; AFontSize: Single; out ASize: TSize): Boolean;
var
  TextLayout: IDWriteTextLayout;
  TextMetrics: TDWriteTextMetrics;
  TextFormat: IDWriteTextFormat;
begin
  Result := False;
  ASize.cx := 0;
  ASize.cy := 0;

  if (DWriteFactory = nil) or (AText = '') then
    Exit;

  if Failed(DWriteFactory.CreateTextFormat('微软雅黑', nil, DWRITE_FONT_WEIGHT_NORMAL, DWRITE_FONT_STYLE_NORMAL, DWRITE_FONT_STRETCH_NORMAL, AFontSize, '', TextFormat)) then
    Exit;

  TextFormat.SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
  TextFormat.SetTextAlignment(DWRITE_TEXT_ALIGNMENT_CENTER);
  TextFormat.SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);

  if Succeeded(DWriteFactory.CreateTextLayout(PWideChar(AText), Length(AText), TextFormat, 10000, 10000, TextLayout)) then
  begin
    if Succeeded(TextLayout.GetMetrics(TextMetrics)) then
    begin
      ASize.cx := Round(TextMetrics.widthIncludingTrailingWhitespace);
      ASize.cy := Round(TextMetrics.height);
      Result := True;
    end;
  end;
end;

procedure THintUI.CalculateWindowSize;
var
  TriangleSize, TextPadding, ShadowPadding: Single;
begin
  TriangleSize := DEFAULT_TRIANGLE_SIZE * FDPIScale;
  TextPadding := DEFAULT_TEXT_PADDING * FDPIScale;
  ShadowPadding := DEFAULT_SHADOW_PADDING * FDPIScale;

  GetTextShowSize(FHintWindowText, DEFAULT_FONT_SIZE * FDPIScale, TextSize);

  // GetTextShowSize返回的已经是缩放后的尺寸，无需再次缩放
  // TextSize.cx := Round(TextSize.cx * FDPIScale);
  // TextSize.cy := Round(TextSize.cy * FDPIScale);

  FHintWindowWidth := TextSize.cx + Round(TextPadding * 2);
  FHintWindowHeight := TextSize.cy + Round(TextPadding);

  if ((FHintPosition and Integer(Position_Flag_Top)) <> 0) or
     ((FHintPosition and Integer(Position_Flag_Bottom)) <> 0) then
    FHintWindowHeight := FHintWindowHeight + Round(TriangleSize)
  else if ((FHintPosition and Integer(Position_Flag_Left)) <> 0) or
          ((FHintPosition and Integer(Position_Flag_Right)) <> 0) then
    FHintWindowWidth := FHintWindowWidth + Round(TriangleSize);

  FHintWindowWidth := FHintWindowWidth + Round(ShadowPadding * 2);
  FHintWindowHeight := FHintWindowHeight + Round(ShadowPadding * 2);
end;

function THintUI.CalculateWindowPosition: TPoint;
var
  TargetScreenRect, WndClientRect: TRect;
  ScreenPosition: TPoint;
  X, Y: Integer;
  ShadowPadding: Single;
  ScreenHeight, ScreenWidth: Integer;
  TempWidth, TempHeight: Integer;
  IsPositionTop, IsPositionLeft, IsPositionRight, IsPositionCenter: Boolean;
begin
  ShadowPadding := DEFAULT_SHADOW_PADDING * FDPIScale;
  XEle_GetWndClientRectDPI(FTargetComponentHandle, WndClientRect);
  ScreenPosition.X := WndClientRect.Left;
  ScreenPosition.Y := WndClientRect.Top;
  Windows.ClientToScreen(XWidget_GetHWND(FTargetComponentHandle), ScreenPosition);

  XEle_GetRect(FTargetComponentHandle, TargetScreenRect);
  TempWidth :=Round(TargetScreenRect.Width * FDPIScale);
  TempHeight :=Round( TargetScreenRect.Height * FDPIScale);

  ScreenHeight := GetSystemMetrics(SM_CYSCREEN);
  ScreenWidth := GetSystemMetrics(SM_CXSCREEN);

  // --- 确定最佳垂直位置 ---
  IsPositionTop := (FHintPosition and Integer(Position_Flag_Top)) <> 0;

  // 如果默认在下方，但空间不足，则尝试移动到上方
  if not IsPositionTop and ((ScreenPosition.Y + TempHeight + FHintWindowHeight) > ScreenHeight) then
  begin
    if (ScreenPosition.Y - FHintWindowHeight) >= 0 then // 上方有空间
    begin
      FHintPosition := (FHintPosition and not Integer(Position_Flag_Bottom)) or Integer(Position_Flag_Top);
      IsPositionTop := True;
    end;
  end;
  // 如果默认在上方，但空间不足，则尝试移动到下方
  if IsPositionTop and ((ScreenPosition.Y - FHintWindowHeight) < 0) then
  begin
     if (ScreenPosition.Y + TempHeight + FHintWindowHeight) <= ScreenHeight then // 下方有空间
     begin
        FHintPosition := (FHintPosition and not Integer(Position_Flag_Top)) or Integer(Position_Flag_Bottom);
        IsPositionTop := False;
     end;
  end;

  // --- 确定垂直坐标 Y ---
  if IsPositionTop then
    Y := ScreenPosition.Y - FHintWindowHeight + Ceil(ShadowPadding + 8* FDPIScale) // 向上微调
  else // 默认或调整后在下方
    Y := ScreenPosition.Y + TempHeight - Floor(ShadowPadding -8* FDPIScale); // 向下微调

  // --- 确定水平对齐方式 ---
  IsPositionCenter := (FHintPosition and Integer(Position_Flag_Center)) <> 0;
  IsPositionLeft := (FHintPosition and Integer(Position_Flag_Left)) <> 0;
  IsPositionRight := (FHintPosition and Integer(Position_Flag_Right)) <> 0;

  // 初始基于居中计算X
  X := ScreenPosition.X + (TempWidth - FHintWindowWidth) div 2;

  // --- 检查并调整水平位置 ---
  if IsPositionCenter then
  begin
    if (X + FHintWindowWidth > ScreenWidth) then // 右边出界
      IsPositionRight := True
    else if X < 0 then // 左边出界
      IsPositionLeft := True;
  end;

  // --- 根据最终对齐方式计算水平坐标 X ---
  if IsPositionLeft then
    X := ScreenPosition.X
  else if IsPositionRight then
    X := ScreenPosition.X + TempWidth - FHintWindowWidth;

  // 应用用户设置的偏移量
  X := X + Round(FOffsetX * FDPIScale);
  Y := Y + Round(FOffsetY * FDPIScale);

  Result.X := X;
  Result.Y := Y;
end;

procedure THintUI.ShowHintWindow;
var
  WindowPosition: TPoint;
begin
  if XC_IsHWINDOW(FHintWindow) then
  begin
    FParentWindow := XWidget_GetHWINDOW(FTargetComponentHandle);
    FDPI := XWnd_GetDPI(FParentWindow);
    FDPIScale := FDPI / 96.0;
    FHintPosition := FDefaultHintPosition;
    CalculateWindowSize;
    WindowPosition := CalculateWindowPosition;
    FCurrentHintPosition := FHintPosition;
    FCurrentTextAlign := FTextAlign;

    if FEnableAnimation then
    begin
      FClassAnimationStep := 0;
      FClassAnimationDirection := 1;
      FCurrentRotationAngle := 15; // Set initial angle for first paint
      if FClassTimerID <> 0 then
        XWnd_KillTimer(FHintWindow, FClassTimerID);
      FClassTimerID := XWnd_SetTimer(FHintWindow, ANIMATION_TIMER_ID, ANIMATION_INTERVAL);
    end
    else
    begin
      FCurrentRotationAngle := FRotationAngle;
    end;

    Windows.SetWindowPos(XWnd_GetHWND(FHintWindow), HWND_TOPMOST, WindowPosition.X, WindowPosition.Y, FHintWindowWidth, FHintWindowHeight, SWP_NOACTIVATE);
    XWnd_ShowWindow(FHintWindow, SW_SHOWNOACTIVATE);
  end;
end;

procedure THintUI.HideHintWindow;
begin
  if XC_IsHWINDOW(FHintWindow) then
  begin
    if FClassTimerID <> 0 then
    begin
      XWnd_KillTimer(FHintWindow, FClassTimerID);
      FClassTimerID := 0;
    end;
    XWnd_ShowWindow(FHintWindow, SW_HIDE);
  end;
end;

procedure THintUI.Close;
begin
  HideHintWindow;
end;

class function THintUI.OnMouseSTAY(hElement: Integer; pbHandled: PBoolean): Integer;
var
  TargetWidget: TXWidget;
  HintUI: THintUI;
begin
  Result := 0;
  TargetWidget := TXWidget.GetClassFormHandle(hElement);
  if (TargetWidget <> nil) and (TargetWidget.Tooltip <> nil) then
  begin
    HintUI := THintUI(TargetWidget.Tooltip);
    FHintWindowText := HintUI.FHintText;
    HintUI.ShowHintWindow;
  end;
end;

class function THintUI.OnPAINT(hWindow, hDraw: Integer; pbHandled: PBoolean): Integer; stdcall;
var
  RC: TRECT;
  D2dRenderTarget: ID2D1RenderTarget;
  ClientRect: TD2D1RectF;
  WindowWidth, WindowHeight: Single;
  CornerRadius, TriangleSize, TextPadding, ShadowPadding: Single;
  BackgroundColor, TextColor, BorderColor: TD2D1ColorF;
  BackgroundBrush, TextBrush, BorderBrush, ShadowBrush: ID2D1SolidColorBrush;
  TextFormat: IDWriteTextFormat;
  PathGeometry: ID2D1PathGeometry;
  GeometrySink: ID2D1GeometrySink;
  TrianglePosition: Single;
  arc: TD2D1ArcSegment;
  TextRect: TD2D1RectF;
  HintPosition: THintPosition;
  i: Integer;
  transform, oldTransform, rotateTransform: TD2D1Matrix3x2F;
  CurrentRotationAngle: Single;
  RotationCenter: TD2D1Point2F;
begin
  Result := 0;
  pbHandled^ := True;

  XWnd_GetDrawRect(hWindow, RC);
  WindowWidth := RC.Width;
  WindowHeight := RC.Height;

  ShadowPadding := DEFAULT_SHADOW_PADDING * FDPIScale;

  ClientRect := D2D1RectF(ShadowPadding, ShadowPadding, WindowWidth - ShadowPadding, WindowHeight - ShadowPadding);
  D2dRenderTarget := ID2D1RenderTarget(XDraw_GetD2dRenderTarget(hDraw));

  if D2dRenderTarget = nil then
    Exit;

  HintPosition := FCurrentHintPosition;
  if HintPosition = 0 then // 如果位置无效，则使用默认值
    HintPosition := Integer(Position_Flag_Bottom) or Integer(Position_Flag_Center);

  CornerRadius := DEFAULT_CORNER_RADIUS * FDPIScale;
  TriangleSize := DEFAULT_TRIANGLE_SIZE * FDPIScale;
  TextPadding := DEFAULT_TEXT_PADDING * FDPIScale;

  BackgroundColor := RGBAToD2D1ColorF(Theme_Window_BkColor);
  TextColor := RGBAToD2D1ColorF(Theme_TextColor_Leave);
  BorderColor := RGBAToD2D1ColorF(Theme_Window_BorderColor);

  D2dRenderTarget.Clear(D2D1ColorF(0, 0, 0, 0));
  D2dRenderTarget.CreateSolidColorBrush(BackgroundColor, nil, BackgroundBrush);
  D2dRenderTarget.CreateSolidColorBrush(TextColor, nil, TextBrush);
  D2dRenderTarget.CreateSolidColorBrush(BorderColor, nil, BorderBrush);
  D2dRenderTarget.CreateSolidColorBrush(D2D1.D2D1ColorF(0,0,0,1.0), nil, ShadowBrush);

  // Ensure drawing rectangle is on pixel boundaries
  ClientRect.left := Round(ClientRect.left) + 0.5;
  ClientRect.top := Round(ClientRect.top) + 0.5;
  ClientRect.right := Round(ClientRect.right) - 0.5;
  ClientRect.bottom := Round(ClientRect.bottom) - 0.5;

  D2dRenderTarget.GetFactory(D2D1Factory);
  D2D1Factory.CreatePathGeometry(PathGeometry);
  PathGeometry.Open(GeometrySink);

  arc.size := D2D1.D2D1SizeF(CornerRadius, CornerRadius);
  arc.rotationAngle := 0;
  arc.sweepDirection := D2D1_SWEEP_DIRECTION_CLOCKWISE;
  arc.arcSize := D2D1_ARC_SIZE_SMALL;

  // --- 简化后的绘制逻辑 ---
  TrianglePosition := (ClientRect.right - ClientRect.left) / 2;
  if (HintPosition and Integer(Position_Flag_Left)) <> 0 then
    TrianglePosition := CornerRadius * 3
  else if (HintPosition and Integer(Position_Flag_Right)) <> 0 then
    TrianglePosition := (ClientRect.right - ClientRect.left) - CornerRadius * 3;

  if (HintPosition and Integer(Position_Flag_Top)) <> 0 then
  begin
    // 提示在上方，箭头朝下
    GeometrySink.BeginFigure(D2D1.D2D1PointF(ClientRect.left + CornerRadius, ClientRect.top), D2D1_FIGURE_BEGIN_FILLED);
    GeometrySink.AddLine(D2D1.D2D1PointF(ClientRect.right - CornerRadius, ClientRect.top)); // Top edge
    arc.point := D2D1.D2D1PointF(ClientRect.right, ClientRect.top + CornerRadius);
    GeometrySink.AddArc(arc); // Top-right corner
    GeometrySink.AddLine(D2D1.D2D1PointF(ClientRect.right, ClientRect.bottom - TriangleSize - CornerRadius)); // Right edge
    arc.point := D2D1.D2D1PointF(ClientRect.right - CornerRadius, ClientRect.bottom - TriangleSize);
    GeometrySink.AddArc(arc); // Bottom-right corner
    GeometrySink.AddLine(D2D1.D2D1PointF(ClientRect.left + TrianglePosition + TriangleSize, ClientRect.bottom - TriangleSize)); // Bottom edge to triangle
    GeometrySink.AddLine(D2D1.D2D1PointF(ClientRect.left + TrianglePosition, ClientRect.bottom)); // Triangle tip
    GeometrySink.AddLine(D2D1.D2D1PointF(ClientRect.left + TrianglePosition - TriangleSize, ClientRect.bottom - TriangleSize)); // Triangle to bottom edge
    GeometrySink.AddLine(D2D1.D2D1PointF(ClientRect.left + CornerRadius, ClientRect.bottom - TriangleSize)); // Bottom edge
    arc.point := D2D1.D2D1PointF(ClientRect.left, ClientRect.bottom - TriangleSize - CornerRadius);
    GeometrySink.AddArc(arc); // Bottom-left corner
    GeometrySink.AddLine(D2D1.D2D1PointF(ClientRect.left, ClientRect.top + CornerRadius)); // Left edge
    arc.point := D2D1.D2D1PointF(ClientRect.left + CornerRadius, ClientRect.top);
    GeometrySink.AddArc(arc); // Top-left corner
  end
  else
  begin
    // 提示在下方（默认），箭头朝上
    GeometrySink.BeginFigure(D2D1.D2D1PointF(ClientRect.left + TrianglePosition, ClientRect.top), D2D1_FIGURE_BEGIN_FILLED); // Start at triangle tip
    GeometrySink.AddLine(D2D1.D2D1PointF(ClientRect.left + TrianglePosition + TriangleSize, ClientRect.top + TriangleSize));
    GeometrySink.AddLine(D2D1.D2D1PointF(ClientRect.right - CornerRadius, ClientRect.top + TriangleSize)); // Top edge
    arc.point := D2D1.D2D1PointF(ClientRect.right, ClientRect.top + TriangleSize + CornerRadius);
    GeometrySink.AddArc(arc); // Top-right corner
    GeometrySink.AddLine(D2D1.D2D1PointF(ClientRect.right, ClientRect.bottom - CornerRadius)); // Right edge
    arc.point := D2D1.D2D1PointF(ClientRect.right - CornerRadius, ClientRect.bottom);
    GeometrySink.AddArc(arc); // Bottom-right corner
    GeometrySink.AddLine(D2D1.D2D1PointF(ClientRect.left + CornerRadius, ClientRect.bottom)); // Bottom edge
    arc.point := D2D1.D2D1PointF(ClientRect.left, ClientRect.bottom - CornerRadius);
    GeometrySink.AddArc(arc); // Bottom-left corner
    GeometrySink.AddLine(D2D1.D2D1PointF(ClientRect.left, ClientRect.top + TriangleSize + CornerRadius)); // Left edge
    arc.point := D2D1.D2D1PointF(ClientRect.left + CornerRadius, ClientRect.top + TriangleSize);
    GeometrySink.AddArc(arc); // Top-left corner
    GeometrySink.AddLine(D2D1.D2D1PointF(ClientRect.left + TrianglePosition - TriangleSize, ClientRect.top + TriangleSize));
    GeometrySink.AddLine(D2D1.D2D1PointF(ClientRect.left + TrianglePosition, ClientRect.top)); // Back to triangle tip
  end;

  GeometrySink.EndFigure(D2D1_FIGURE_END_CLOSED);
  GeometrySink.Close;

  // 保存当前变换矩阵
  D2dRenderTarget.GetTransform(oldTransform);

  // 计算旋转中心点（三角形位置）
  if (HintPosition and Integer(Position_Flag_Top)) <> 0 then
  begin
    // 如果三角形在顶部，旋转中心为底部中间的三角形
    RotationCenter.x := ClientRect.left + TrianglePosition;
    RotationCenter.y := ClientRect.bottom;
  end
  else // 默认三角形在底部
  begin
    // 如果三角形在底部，旋转中心为顶部中间的三角形
    RotationCenter.x := ClientRect.left + TrianglePosition;
    RotationCenter.y := ClientRect.top;
  end;

  // 使用设置的旋转角度（转换为弧度）
  CurrentRotationAngle := FCurrentRotationAngle * PI / 180;

  // 创建旋转变换矩阵 - 手动计算旋转矩阵
  rotateTransform._11 := Cos(CurrentRotationAngle);
  rotateTransform._12 := Sin(CurrentRotationAngle);
  rotateTransform._21 := -Sin(CurrentRotationAngle);
  rotateTransform._22 := Cos(CurrentRotationAngle);
  rotateTransform._31 := RotationCenter.x - Cos(CurrentRotationAngle) * RotationCenter.x + Sin(CurrentRotationAngle) * RotationCenter.y;
  rotateTransform._32 := RotationCenter.y - Sin(CurrentRotationAngle) * RotationCenter.x - Cos(CurrentRotationAngle) * RotationCenter.y;
  
  // 应用旋转变换
  D2dRenderTarget.SetTransform(rotateTransform * oldTransform);

  if ShadowBrush <> nil then
  begin
    transform._11 := 1.0;
    transform._12 := 0.0;
    transform._21 := 0.0;
    transform._22 := 1.0;
    transform._31 := 0;
    transform._32 := 1 * FDPIScale;
    D2dRenderTarget.SetTransform(transform * rotateTransform * oldTransform);

    for i := SHADOW_STEPS downto 1 do
    begin
      // 使用幂曲线模拟更自然的光晕衰减效果
      ShadowBrush.SetOpacity(SHADOW_OPACITY_FACTOR * Power((SHADOW_STEPS + 1 - i) / SHADOW_STEPS, 2));

      // 动态计算模糊半径
      D2dRenderTarget.DrawGeometry(PathGeometry, ShadowBrush, i * SHADOW_MAX_BLUR_FACTOR * FDPIScale, nil);
    end;

    // 恢复为只有旋转的变换
    D2dRenderTarget.SetTransform(rotateTransform * oldTransform);
  end;

  // Draw shape and border
  D2dRenderTarget.FillGeometry(PathGeometry, BackgroundBrush);
  D2dRenderTarget.DrawGeometry(PathGeometry, BorderBrush, 1.0);

  // Draw text
  if Succeeded(DWriteFactory.CreateTextFormat('微软雅黑', nil, DWRITE_FONT_WEIGHT_NORMAL, DWRITE_FONT_STYLE_NORMAL, DWRITE_FONT_STRETCH_NORMAL, DEFAULT_FONT_SIZE * FDPIScale, '', TextFormat)) then
  begin
    TextFormat.SetWordWrapping(DWRITE_WORD_WRAPPING_NO_WRAP);
    
    // 根据文本对齐属性设置对齐方式
    case FCurrentTextAlign of
      HintTextAlign_Left: 
        TextFormat.SetTextAlignment(DWRITE_TEXT_ALIGNMENT_LEADING);
      HintTextAlign_Center: 
        TextFormat.SetTextAlignment(DWRITE_TEXT_ALIGNMENT_CENTER);
      HintTextAlign_Right: 
        TextFormat.SetTextAlignment(DWRITE_TEXT_ALIGNMENT_TRAILING);
    end;
    
    TextFormat.SetParagraphAlignment(DWRITE_PARAGRAPH_ALIGNMENT_CENTER);

    TextRect := ClientRect;
    TextRect.left := TextRect.left + TextPadding;
    TextRect.top := TextRect.top + TextPadding + Ord((HintPosition and Integer(Position_Flag_Bottom)) <> 0) * TriangleSize;
    TextRect.right := TextRect.right - TextPadding;
    TextRect.bottom := TextRect.bottom - TextPadding - Ord((HintPosition and Integer(Position_Flag_Top)) <> 0) * TriangleSize;

    // 文本已经在旋转变换下绘制，无需额外设置变换
    D2dRenderTarget.DrawText(PChar(FHintWindowText), Length(FHintWindowText), TextFormat, TextRect, TextBrush);
  end;
  
  // 恢复原始变换
  D2dRenderTarget.SetTransform(oldTransform);
end;

class function THintUI.OnMOUSELEAVE(hElement, hEleStay: Integer; pbHandled: pBoolean): Integer;
var
  TargetWidget: TXWidget;
  HintUI: THintUI;
begin
  Result := 0;
  TargetWidget := TXWidget.GetClassFormHandle(hElement);
  if (TargetWidget <> nil) and (TargetWidget.Tooltip <> nil) then
  begin
    HintUI := THintUI(TargetWidget.Tooltip);
    HintUI.HideHintWindow;
  end;
end;

class function THintUI.OnTimer(hWindow: Integer; nIDEvent: UINT_PTR; pbHandled: PBoolean): Integer; stdcall;
begin
  Result := 0;
  pbHandled^ := True;

  if FClassAnimationDirection = 1 then
  begin
    // 阶段一: 15度 -> -15度
    FCurrentRotationAngle := 15 - (30 * FClassAnimationStep / ANIMATION_STEPS);
    Inc(FClassAnimationStep);
    if FClassAnimationStep > ANIMATION_STEPS then
    begin
      FClassAnimationStep := 0;
      FClassAnimationDirection := -1; // 进入第二阶段
    end;
  end
  else
  begin
    // 阶段二: -15度 -> 0度 (使用cos插值以获得缓出效果)
    FCurrentRotationAngle := -15 * Cos(FClassAnimationStep / ANIMATION_STEPS * PI / 2);
    Inc(FClassAnimationStep);
    if FClassAnimationStep > ANIMATION_STEPS then
    begin
      // 动画结束
      FCurrentRotationAngle := 0;
      if FClassTimerID <> 0 then
      begin
        XWnd_KillTimer(hWindow, FClassTimerID);
        FClassTimerID := 0;
      end;
    end;
  end;

  XWnd_Redraw(hWindow, False);
end;

procedure THintUI.UnregisterHint;
begin
  XEle_RemoveEvent(FTargetComponentHandle, XE_MOUSESTAY, @OnMouseSTAY);
  XEle_RemoveEvent(FTargetComponentHandle, XE_MOUSELEAVE, @OnMOUSELEAVE);
  if FTargetWidget <> nil then
    FTargetWidget.Tooltip := nil;
end;

procedure THintUI.SetPositionOffset(AOffsetX, AOffsetY: Integer);
begin
  FOffsetX := AOffsetX;
  FOffsetY := AOffsetY;
end;

procedure THintUI.SetHintPosition(const Value: THintPosition);
begin
  FHintPosition := Value;
  FDefaultHintPosition := Value;
end;

procedure THintUI.SetTextAlign(const Value: THintTextAlign);
begin
  FTextAlign := Value;
end;

procedure THintUI.SetRotationAngle(const Value: Single);
begin
  FRotationAngle := Value;
end;

procedure THintUI.SetEnableAnimation(const Value: Boolean);
begin
  FEnableAnimation := Value;
end;

end.

