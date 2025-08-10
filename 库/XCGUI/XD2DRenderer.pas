unit XD2DRenderer;

interface

uses
  Windows, SysUtils, Messages, IOUtils, ActiveX, ComObj, Wincodec, Math,
  Winapi.D2D1, XCGUI, StrUtils, Winapi.DXGIFormat, ImageCore;

const
  DWRITE_DRAW_TEXT_OPTIONS_CLIP = $00000001;

type
  // DirectWrite文本修剪选项结构
  DWRITE_TRIMMING = record
    granularity: DWORD;
    delimiter: UINT32;
    delimiterCount: UINT32;
  end;

  TColorTagRange = record
    StartPos: Integer;
    Length: Integer;
    Color: Cardinal; // AARRGGBB
  end;

  TD2DFont = IDWriteTextFormat;

  TD2DImge = ID2D1Bitmap;

type
  TXD2DRenderer = class
    class function GetFontFormatKey(const fontFamilyName: PWideChar; fontSize: Single; fontWeight: DWRITE_FONT_WEIGHT; fontStyle: DWRITE_FONT_STYLE; fontStretch: DWRITE_FONT_STRETCH; const fontFilePath: PWideChar = nil): string;
    class function CreateFontFormat(const fontFamilyName: PWideChar; const fontFilePath: PWideChar = nil; fontSize: Single = 13; fontWeight: DWRITE_FONT_WEIGHT = DWRITE_FONT_WEIGHT_NORMAL; fontStyle: DWRITE_FONT_STYLE = DWRITE_FONT_STYLE_NORMAL; fontStretch: DWRITE_FONT_STRETCH = DWRITE_FONT_STRETCH_NORMAL; AXcguiWindow: HWINDOW = 0): IDWriteTextFormat;

  private
    FDraw: Integer;
    FRenderTarget: ID2D1HwndRenderTarget;
    class function RGBAToD2D1ColorF(RGBAValue: DWORD): TD2D1ColorF;
    class function RectToD2D1RectF(const RC: TRect): TD2D1RectF;
  public
    class procedure ParseColorTagRanges(const Text: string; out CleanText: string; out Ranges: TArray<TColorTagRange>; DefaultColor: Cardinal);
    constructor Create(hWND: Integer);
    constructor FormDrawHandle(hDraw: Integer);
    procedure ReleaseDraw;
    procedure DrawColorText(Text: PChar; RC: TRect; Color: Integer; TextFormat: IDWriteTextFormat = nil; ADpi: Single = 96.0);
    procedure DrawParsedColorText(const CleanText: string; const Ranges: TArray<TColorTagRange>; RC: TRect; DefaultColor: Cardinal; TextFormat: IDWriteTextFormat = nil; ADpi: Single = 96.0);
    procedure DrawImage(Bitmap: ID2D1Bitmap; RC: TRect; Alpha: Single = 1.0);
    function GetTextSize(Text: PWideChar; TextFormat: IDWriteTextFormat = nil): TSize;
    function GetParsedTextSize(const CleanText: string; TextFormat: IDWriteTextFormat = nil): TSize;
    property Draw: Integer read FDraw;
  end;

implementation

class function TXD2DRenderer.GetFontFormatKey(const fontFamilyName: PWideChar; fontSize: Single; fontWeight: DWRITE_FONT_WEIGHT; fontStyle: DWRITE_FONT_STYLE; fontStretch: DWRITE_FONT_STRETCH; const fontFilePath: PWideChar = nil): string;
begin
  Result := WideString(fontFamilyName) + '|' + FloatToStr(fontSize) + '|' + IntToStr(Integer(fontWeight)) + '|' + IntToStr(Integer(fontStyle)) + '|' + IntToStr(Integer(fontStretch));
  if (fontFilePath <> nil) and (WideString(fontFilePath) <> '') then
    Result := Result + '|file:' + WideString(fontFilePath);
end;

class function TXD2DRenderer.RGBAToD2D1ColorF(RGBAValue: DWORD): TD2D1ColorF;
begin
  with Result do
  begin
    r := Byte(RGBAValue) / 255;
    g := Byte(RGBAValue shr 8) / 255;
    b := Byte(RGBAValue shr 16) / 255;
    a := Byte(RGBAValue shr 24) / 255;
  end;
end;

class function TXD2DRenderer.RectToD2D1RectF(const RC: TRect): TD2D1RectF;
begin
  Result.left := RC.Left;
  Result.top := RC.Top;
  Result.right := RC.Width;
  Result.bottom := RC.Height;
end;

constructor TXD2DRenderer.FormDrawHandle(hDraw: Integer);
begin
  inherited Create;
  FDraw := hDraw;
  FRenderTarget := ID2D1HwndRenderTarget(XDraw_GetD2dRenderTarget(FDraw));
end;

class procedure TXD2DRenderer.ParseColorTagRanges(const Text: string; out CleanText: string; out Ranges: TArray<TColorTagRange>; DefaultColor: Cardinal);
var
  i, TagStart, TagEnd, ColorTagEnd: Integer;
  S, ColorStr: string;
  ColorVal, CurColor: Cardinal;
  Range: TColorTagRange;
begin
  SetLength(Ranges, 0);
  CleanText := '';
  i := 1;
  CurColor := DefaultColor;
  while i <= Length(Text) do
  begin
    TagStart := PosEx('<color=#', Text, i);
    if TagStart = 0 then
    begin
      // 剩余部分为普通文本
      S := Copy(Text, i, MaxInt);
      if S <> '' then
      begin
        Range.StartPos := Length(CleanText);
        Range.Length := Length(S);
        Range.Color := CurColor;
        SetLength(Ranges, Length(Ranges) + 1);
        Ranges[High(Ranges)] := Range;
        CleanText := CleanText + S;
      end;
      Break;
    end;
    // 普通文本区间
    S := Copy(Text, i, TagStart - i);
    if S <> '' then
    begin
      Range.StartPos := Length(CleanText);
      Range.Length := Length(S);
      Range.Color := CurColor;
      SetLength(Ranges, Length(Ranges) + 1);
      Ranges[High(Ranges)] := Range;
      CleanText := CleanText + S;
    end;
    ColorTagEnd := PosEx('>', Text, TagStart);
    if ColorTagEnd = 0 then
      Break;
    ColorStr := Copy(Text, TagStart + 8, ColorTagEnd - TagStart - 8);
    ColorVal := HexToRGBA(ColorStr);
    TagEnd := PosEx('</color>', Text, ColorTagEnd + 1);
    if TagEnd = 0 then
      Break;
    S := Copy(Text, ColorTagEnd + 1, TagEnd - ColorTagEnd - 1);
    if S <> '' then
    begin
      Range.StartPos := Length(CleanText);
      Range.Length := Length(S);
      Range.Color := ColorVal;
      SetLength(Ranges, Length(Ranges) + 1);
      Ranges[High(Ranges)] := Range;
      CleanText := CleanText + S;
    end;
    i := TagEnd + 8;
  end;
end;

constructor TXD2DRenderer.Create(hWND: Integer);
begin
  FDraw := XDraw_Create(hWND);
  FRenderTarget := ID2D1HwndRenderTarget(XDraw_GetD2dRenderTarget(FDraw));
  // FRenderTarget := CreateD2DRenderTarget(hWND);
end;

procedure TXD2DRenderer.ReleaseDraw;
begin
  XDraw_Destroy(FDraw);
end;

class function TXD2DRenderer.CreateFontFormat(const fontFamilyName: PWideChar; const fontFilePath: PWideChar = nil; fontSize: Single = 13; fontWeight: DWRITE_FONT_WEIGHT = DWRITE_FONT_WEIGHT_NORMAL; fontStyle: DWRITE_FONT_STYLE = DWRITE_FONT_STYLE_NORMAL; fontStretch: DWRITE_FONT_STRETCH = DWRITE_FONT_STRETCH_NORMAL; AXcguiWindow: HWINDOW = 0): IDWriteTextFormat;
var
  LResult: Integer;
  DpiX, DpiY: Single;
  ScaledFontSize: Single;
begin
  Result := nil;

  if DWriteFactory = nil then
  begin
    OutputDebugString('CreateFontFormat: DWriteFactory is nil.');
    Exit;
  end;

  if (fontFilePath <> nil) and (WideString(fontFilePath) <> '') then
  begin
    LResult := AddFontResourceEx(fontFilePath, FR_PRIVATE, nil);
    if LResult > 0 then
    begin
      SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
      OutputDebugString(PChar('LoadAppFont: Font added temporarily - ' + WideString(fontFilePath) + '. Count: ' + IntToStr(LResult)));
    end
    else
      OutputDebugString(PChar('LoadAppFont: Failed to add font - ' + WideString(fontFilePath) + '. Error: ' + SysErrorMessage(GetLastError)));
  end;

  // Get system DPI for font scaling
  if AXcguiWindow <> 0 then
  begin
    // If we have a window, get its DPI
    DpiX := XWnd_GetDpi(AXcguiWindow);
    DpiY := XWnd_GetDpi(AXcguiWindow);
  end
  else
  begin
    // Otherwise use system DPI
    DpiX := 96.0;
    DpiY := 96.0;

    // Try to get system DPI
    if D2D1Factory <> nil then
    begin
      D2D1Factory.GetDesktopDpi(DpiX, DpiY);
    end;
  end;

  // Scale font size according to DPI
  ScaledFontSize := fontSize;

  // The 'fontSize' parameter is treated as DIPs (Device Independent Pixels).
  // DirectWrite will handle scaling at render time based on the render target's DPI.
  DWriteFactory.CreateTextFormat(fontFamilyName, nil, fontWeight, fontStyle, fontStretch, ScaledFontSize, 'zh-cn', Result);
end;

procedure TXD2DRenderer.DrawColorText(Text: PChar; RC: TRect; Color: Integer; TextFormat: IDWriteTextFormat; ADpi: Single);
var
  CleanText: string;
  Ranges: TArray<TColorTagRange>;
begin
  if (D2D1Factory = nil) or (DWriteFactory = nil) or (FRenderTarget = nil) then
    Exit;

  ParseColorTagRanges(Text, CleanText, Ranges, Color);
  DrawParsedColorText(CleanText, Ranges, RC, Color, TextFormat, ADpi);
end;

procedure TXD2DRenderer.DrawParsedColorText(const CleanText: string; const Ranges: TArray<TColorTagRange>; RC: TRect; DefaultColor: Cardinal; TextFormat: IDWriteTextFormat = nil; ADpi: Single = 96.0);
var
  TextBrush: ID2D1SolidColorBrush;
  TextLayout: IDWriteTextLayout;
  DrawRect: TD2D1RectF;
  ColorF: TD2D1ColorF;
  i: Integer;
  RangeColorF: TD2D1ColorF;
  Range: DWRITE_TEXT_RANGE;
  CustomBrush: ID2D1SolidColorBrush;
  Effect: IUnknown;
  TextLen: Integer;
  FullTextRange: DWRITE_TEXT_RANGE;
begin
  if (D2D1Factory = nil) or (DWriteFactory = nil) or (FRenderTarget = nil) then
    Exit;
  ColorF := RGBAToD2D1ColorF(DefaultColor);
  FRenderTarget.SetTextAntialiasMode(D2D1_TEXT_ANTIALIAS_MODE_CLEARTYPE);
  FRenderTarget.SetAntialiasMode(D2D1_ANTIALIAS_MODE_PER_PRIMITIVE);

  // 将RC从物理像素转换为DIPs
  DrawRect.left := RC.Left;
  DrawRect.top := RC.Top;
  DrawRect.right := RC.Right;
  DrawRect.bottom := RC.Bottom;

  if TextFormat = nil then
    TextFormat := DefaultTextFormat;

  if Succeeded(FRenderTarget.CreateSolidColorBrush(ColorF, nil, TextBrush)) then
  begin
    if Assigned(TextFormat) then
    begin
      // 获取文本长度
      TextLen := Length(CleanText);

      // 将布局矩形从物理像素转换为DIPs以用于CreateTextLayout
      if Succeeded(DWriteFactory.CreateTextLayout(PChar(CleanText), TextLen, TextFormat, (DrawRect.right - DrawRect.left) * ADpi / 96 * 2, (DrawRect.bottom - DrawRect.top) * ADpi / 96 * 2, TextLayout)) then
      begin

        FullTextRange.startPosition := 0;
        FullTextRange.length := TextLen;
        TextLayout.SetFontSize(TextFormat.GetFontSize * ADpi / 96, FullTextRange);

        // 应用颜色区间
        for i := 0 to High(Ranges) do
        begin
          RangeColorF := RGBAToD2D1ColorF(Ranges[i].Color);
          if Succeeded(FRenderTarget.CreateSolidColorBrush(RangeColorF, nil, CustomBrush)) then
          begin
            Effect := CustomBrush as IUnknown;
            Range.startPosition := Ranges[i].StartPos;
            Range.length := Ranges[i].Length;
            TextLayout.SetDrawingEffect(Effect, Range);
          end;
        end;

        // 使用DPI感知的坐标绘制文本
        FRenderTarget.DrawTextLayout(D2D1PointF(DrawRect.left, DrawRect.top), TextLayout, TextBrush, DWRITE_DRAW_TEXT_OPTIONS_CLIP);
      end;
    end;
  end;
end;

function TXD2DRenderer.GetParsedTextSize(const CleanText: string; TextFormat: IDWriteTextFormat): TSize;
var
  TextLayout: IDWriteTextLayout;
  TextMetrics: TDWriteTextMetrics;
  MaxWidth: Single;
begin
  Result := TSize.Create(0, 0);
  if (DWriteFactory = nil) or (FRenderTarget = nil) then
    Exit;

  if TextFormat = nil then
    TextFormat := DefaultTextFormat;

  if not Assigned(TextFormat) then
    Exit;

  MaxWidth := 10000; // 用于单行文本测量的较大值 (DIPs)

  if Succeeded(DWriteFactory.CreateTextLayout(PChar(CleanText), Length(CleanText), TextFormat, MaxWidth, MaxWidth, TextLayout)) then
  begin
    if Succeeded(TextLayout.GetMetrics(TextMetrics)) then
    begin
      // 将布局指标从DIPs转换为物理像素
      Result.cx := Round(TextMetrics.widthIncludingTrailingWhitespace);
      Result.cy := Round(TextMetrics.height);
    end;
  end;
end;

function TXD2DRenderer.GetTextSize(Text: PWideChar; TextFormat: IDWriteTextFormat = nil): TSize;
var
  CleanText: string;
  Ranges: TArray<TColorTagRange>;
begin
  Result := TSize.Create(0, 0);
  if (DWriteFactory = nil) or (FRenderTarget = nil) then
    Exit;

  if TextFormat = nil then
    TextFormat := DefaultTextFormat;

  if not Assigned(TextFormat) then
    Exit;

  ParseColorTagRanges(Text, CleanText, Ranges, 0);
  Result := GetParsedTextSize(CleanText, TextFormat);
end;

procedure TXD2DRenderer.DrawImage(Bitmap: ID2D1Bitmap; RC: TRect; Alpha: Single = 1.0);
var
  DrawRect: TD2D1RectF;
begin
  if (FRenderTarget = nil) or (Bitmap = nil) then
    Exit;

  DrawRect := RectToD2D1RectF(RC);

  if (DrawRect.left >= DrawRect.right) or (DrawRect.top >= DrawRect.bottom) then
  begin
    // 可以选择性地输出调试信息，了解无效矩形的具体值
    OutputDebugString(PChar(Format('DrawImage: Invalid target rectangle L:%.1f, T:%.1f, R:%.1f, B:%.1f', [DrawRect.left, DrawRect.top, DrawRect.right, DrawRect.bottom])));
    Exit; // 如果矩形无效，则不执行绘制
  end;

  // 使用DrawBitmap绘制位图到指定区域
  FRenderTarget.DrawBitmap(Bitmap, @DrawRect, Alpha, D2D1_BITMAP_INTERPOLATION_MODE_LINEAR, nil);
end;

end.

