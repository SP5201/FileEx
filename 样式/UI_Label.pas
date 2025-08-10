unit UI_Label;

interface

uses
  Windows, Classes, Math, XCGUI, XElement, UI_Color, UI_Resource, UI_Element,
  UI_Tooltip, System.SysUtils, XD2DRenderer, Winapi.D2D1;

type
  TSvgLabelUI = class(TEleUI)
  private
    FText: string;
    FCleanText: string;
    FColorRanges: TArray<TColorTagRange>;
    FSvg: Integer;
    FSvgFile: string;
    FSpace: Integer;
    FHintText: string;
    FHint: THintUI;
    FPosition: THintPosition;
    FSvgColor: COLORREF;
    FEnabledUserColor: Boolean;
    FTextAlign: Integer;
    FFont: IDWriteTextFormat;
    FOffsetX, FOffsetY: Integer;
    FOffsetIconX, FOffsetIconY: Integer;
    FAutoSize: Boolean;
    FPadding: TpaddingSize_;
    FISEmptyShow: Boolean;
    procedure SetHint(const Value: string);
    procedure SetText(const Value: string);
    procedure SetSvgFile(const Value: string);
    procedure SetSvgColor(const Value: COLORREF);
    procedure SetEnabledUserColor(const Value: Boolean);
    procedure SetTextAlign(const Value: Integer);
    procedure SetAutoSize(const Value: Boolean);
    procedure SetPadding(const Value: TpaddingSize_);
    procedure SetISEmptyShow(const Value: Boolean);
    procedure UpdateAutoSize;
  protected
    procedure Init; override;
    class function OnPAINT(hEle: Integer; hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    procedure PAINT(hDraw: Integer); virtual;
  public
    destructor Destroy; override;
    function GetContentSize: TSize;
    procedure Style(SvgFile, LabelText, LabelHintText: string; SvgWidth, SvgHeight: integer; Position: THintPosition = Integer(Position_Flag_Bottom) or Integer(Position_Flag_Center); AOffsetX: Integer = 0; AOffsetY: Integer = 0);
    property Text: string read FText write SetText;
    property SvgFile: string read FSvgFile write SetSvgFile;
    property HintText: string read FHintText write SetHint;
    property SvgColor: COLORREF read FSvgColor write SetSvgColor;
    property EnabledUserColor: Boolean read FEnabledUserColor write SetEnabledUserColor;
    property TextAlign: Integer read FTextAlign write SetTextAlign;
    property Font: IDWriteTextFormat  read FFont write FFont;
    property Svg: Integer read FSvg;
    property AutoSize: Boolean read FAutoSize write SetAutoSize;
    property Padding: TpaddingSize_ read FPadding write SetPadding;
    property ISEmptyShow: Boolean read FISEmptyShow write SetISEmptyShow;
    procedure SetOffset(x, y: Integer);
    procedure SetOffsetIcon(x, y: Integer);
  end;

implementation

destructor TSvgLabelUI.Destroy;
begin
  if Assigned(FHint) then
    FHint.Free;
  if XC_SVG = XC_GetObjectType(FSvg) then
    XSvg_Release(FSvg);
  inherited;
end;

procedure TSvgLabelUI.Init;
begin
  inherited;
  EnableBkTransparent(True);
  FEnabledUserColor := False;
  FTextAlign := textAlignFlag_left or textAlignFlag_top or textFormatFlag_NoWrap;
  FOffsetX := 0;
  FOffsetY := 0;
  FOffsetIconX := 0;
  FOffsetIconY := 0;
  FFont := nil;
  FISEmptyShow := True;

  // 初始化自适应属性
  FAutoSize := False;
  FPadding.leftSize := 0;
  FPadding.topSize := 0;
  FPadding.rightSize := 0;
  FPadding.bottomSize := 0;
  RegEvent(XE_PAINT, @OnPAINT);
end;

class function TSvgLabelUI.OnPAINT(hEle: Integer; hDraw: Integer; pbHandled: PBoolean): Integer;
var
  LabelUI: TSvgLabelUI;
begin
  Result := 0;
  pbHandled^ := True;
  LabelUI := GetClassFormHandle(hEle);
  if Assigned(LabelUI) then
    LabelUI.PAINT(hDraw);
end;

procedure TSvgLabelUI.PAINT(hDraw: Integer);
var
  RC, TextRect: TRect;
  SZ: TSize;
  SvgWidth, SvgHeight, TextWidth, TextHeight, FSpace: Integer;
  SvgLeft, SvgTop: Integer;
  D2DRenderer: TXD2DRenderer;
  D2DFont: IDWriteTextFormat;
begin
  if not FISEmptyShow and (FText = '') then
    Exit;
  SvgHeight := 0;
  SvgWidth := 0;
  GetClientRect(RC);
  TextRect := RC;
  XEle_GetWndClientRectDPI(Handle, TextRect);
  D2DRenderer := TXD2DRenderer.FormDrawHandle(hDraw);
  try
    // --- 步骤 1: 获取所有内容的逻辑尺寸 ---
    SZ := D2DRenderer.GetParsedTextSize(FCleanText, D2DFont);
    TextWidth := SZ.cx;
    TextHeight := SZ.cy;

    if XC_GetObjectType(FSvg) = XC_SVG then
    begin
      SvgWidth := XSvg_GetWidth(FSvg);
      SvgHeight := XSvg_GetHeight(FSvg);
    end;

    // --- 步骤 2: 计算 SVG 和 Text 的矩形 (逻辑单位) ---
    FSpace := Ord((FText <> '') and (SvgWidth > 0)) * 2;
    SvgLeft := RC.Left;
    TextRect.Left := TextRect.Left +  Round(SvgWidth*DpiScale) + FSpace;
    SvgTop := Round((RC.Height - SvgHeight) / 2);
    TextRect.Top :=TextRect.Top+ Round((RC.Bottom -TextHeight) / 2);
    // 应用偏移并计算最终矩形
    SvgLeft := SvgLeft + FOffsetIconX;
    SvgTop := SvgTop + FOffsetIconY;

    TextRect.Left := TextRect.Left + FOffsetX;
    TextRect.Top := TextRect.Top + FOffsetY;
    TextRect.Right := TextRect.Left + TextWidth;
    TextRect.Bottom := TextRect.Top + TextHeight;

    // --- 步骤 3: 绘制 ---
    // 绘制 SVG (使用逻辑坐标)
    if SvgWidth > 0 then
    begin
      if FEnabledUserColor then
        XSvg_SetUserFillColor(FSvg, FSvgColor, True)
      else
        XSvg_SetUserFillColor(FSvg, Theme_SvgLabel_TextColor, True);
      XDraw_DrawSvgEx(hDraw, FSvg, SvgLeft, SvgTop, SvgWidth, SvgHeight);
    end;


    D2DRenderer.DrawParsedColorText(FCleanText, FColorRanges, TextRect, Theme_SvgLabel_TextColor, D2DFont,DPI);

  finally
    D2DRenderer.Free;
  end;
end;

procedure TSvgLabelUI.SetEnabledUserColor(const Value: Boolean);
begin
  if FEnabledUserColor <> Value then
  begin
    FEnabledUserColor := Value;
    if IsHELE then
      Redraw;
  end;
end;

procedure TSvgLabelUI.SetHint(const Value: string);
begin
  FHintText := Value;
  EnableMouseThrough(FHintText = '');
  if Assigned(FHint) then
    FHint.Free;
  if (Value <> '') and (Tooltip = nil) then
  begin
    FHint := THintUI.RegisterHint(Handle, Value);
    FHint.EnableAnimation := False;
  end
  else if (Value = '') and (Tooltip <> nil) then
    FHint.UnregisterHint;
end;

procedure TSvgLabelUI.SetSvgColor(const Value: COLORREF);
begin
  FSvgColor := Value;
  FEnabledUserColor := True;
  if IsHELE then
    Redraw;
end;

procedure TSvgLabelUI.SetSvgFile(const Value: string);
begin
  FSvgFile := Value;
  FSvg := XResource_LoadZipSvg(PChar(Value));
  if IsHELE then
  begin
    UpdateAutoSize;
    Redraw;
  end;
end;

procedure TSvgLabelUI.SetText(const Value: string);
begin
  if FText <> Value then
  begin
    FText := Value;
    TXD2DRenderer.ParseColorTagRanges(FText, FCleanText, FColorRanges, Theme_SvgLabel_TextColor);
    if IsHELE then
    begin
      UpdateAutoSize;
      Redraw;
    end;
  end;
end;

procedure TSvgLabelUI.SetTextAlign(const Value: Integer);
begin
  if FTextAlign <> Value then
  begin
    FTextAlign := Value;
    if IsHELE then
      Redraw;
  end;
end;

procedure TSvgLabelUI.SetOffset(x, y: Integer);
begin
  FOffsetX := x;
  FOffsetY := y;
  if IsHELE then
    Redraw;
end;

procedure TSvgLabelUI.SetOffsetIcon(x, y: Integer);
begin
  FOffsetIconX := x;
  FOffsetIconY := y;
end;

procedure TSvgLabelUI.SetAutoSize(const Value: Boolean);
begin
  if FAutoSize <> Value then
  begin
    FAutoSize := Value;
    if IsHELE then
    begin
      UpdateAutoSize;
      Redraw;
    end;
  end;
end;

procedure TSvgLabelUI.SetPadding(const Value: TpaddingSize_);
begin
  if (FPadding.leftSize <> Value.leftSize) or (FPadding.topSize <> Value.topSize) or (FPadding.rightSize <> Value.rightSize) or (FPadding.bottomSize <> Value.bottomSize) then
  begin
    FPadding := Value;
    if IsHELE then
    begin
      UpdateAutoSize;
      Redraw;
    end;
  end;
end;

procedure TSvgLabelUI.SetISEmptyShow(const Value: Boolean);
begin
  if FISEmptyShow <> Value then
  begin
    FISEmptyShow := Value;
    if IsHELE then
      Redraw;
  end;
end;

function TSvgLabelUI.GetContentSize: TSize;
var
  TextSize: TSize;
  SvgWidth, SvgHeight: Integer;
  Renderer: TXD2DRenderer;
begin
  Result.cx := 0;
  Result.cy := 0;
  TextSize.cx := 0;
  TextSize.cy := 0;

  if not IsHELE then
    Exit;

  // 计算文本尺寸
  if FCleanText <> '' then
  begin
    Renderer := TXD2DRenderer.Create(GetHWINDOW);
    try
      TextSize := Renderer.GetParsedTextSize(FCleanText, FFont);
    finally
      Renderer.ReleaseDraw;
      Renderer.Free;
    end;
  end;

  // 计算SVG尺寸
  if XC_GetObjectType(FSvg) = XC_SVG then
  begin
    SvgWidth := XSvg_GetWidth(FSvg);
    SvgHeight := XSvg_GetHeight(FSvg);

    if FCleanText <> '' then
    begin
      // 有文本和SVG时，宽度为SVG宽度 + 间距 + 文本宽度
      Result.cx := SvgWidth + FSpace + TextSize.cx;
      // 高度取SVG和文本的最大值
      Result.cy := Max(SvgHeight, TextSize.cy);
    end
    else
    begin
      // 只有SVG时
      Result.cx := SvgWidth;
      Result.cy := SvgHeight;
    end;
  end
  else
  begin
    // 只有文本
    Result.cx := TextSize.cx;
    Result.cy := TextSize.cy;
  end;


  // 应用内边距
  Result.cx := Result.cx + FPadding.leftSize + FPadding.rightSize+1;
  Result.cy := Result.cy + FPadding.topSize + FPadding.bottomSize+1;
end;

procedure TSvgLabelUI.UpdateAutoSize;
begin
  if not IsHELE then
    Exit;

  if not (FAutoSize) then
    Exit;
  XWidget_LayoutItem_SetWidth(Handle, layout_size_fixed, GetContentSize.cx);
  XWidget_LayoutItem_SetHeight(Handle, layout_size_fixed, GetContentSize.cy);
  XWnd_AdjustLayout(GetHWINDOW);
end;

procedure TSvgLabelUI.Style(SvgFile, LabelText, LabelHintText: string; SvgWidth, SvgHeight: integer; Position: THintPosition = Integer(Position_Flag_Bottom) or Integer(Position_Flag_Center); AOffsetX: Integer = 0; AOffsetY: Integer = 0);
begin
  FSvgFile := SvgFile;
  FSvg := XResource_LoadZipSvg(PChar(SvgFile));
  if XC_GetObjectType(FSvg) = XC_SVG then
    XSvg_SetSize(FSvg, SvgWidth, SvgHeight);

  Text := LabelText;
  FPosition := Position;

  HintText := LabelHintText;

  // 设置提示窗口的偏移量
  if (FHint <> nil) and (LabelHintText <> '') then
    FHint.SetPositionOffset(AOffsetX, AOffsetY);

  if IsHELE then
  begin
    UpdateAutoSize;
  end;
end;

end.

