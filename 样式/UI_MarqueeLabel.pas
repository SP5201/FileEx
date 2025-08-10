unit UI_MarqueeLabel;

interface

uses
  Windows, SysUtils, Classes, ShellAPI, XCGUI,
  XElement;

const
  FTimerID = 1;

type
  TMarqueeLabelUI = class(TXEle)
  private
    FMarqueeText: string;
    FSpeed: Integer;
    FOffset: Integer;
    FRECTArray: TArray<TRect>;
    FFontWidth: Integer;
    FDefaultFont: Integer;
    procedure SetMarqueeText(const Value: string);
    procedure SetSpeed(const Value: Integer);
  protected
    class function OnPaint(hEle, hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function TimerProc(hEle, nTimerID: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    procedure Init; override;
  public
    destructor Destroy; override;
    property MarqueeText: string read FMarqueeText write SetMarqueeText;
    property Speed: Integer read FSpeed write SetSpeed default 50;
  end;

implementation

uses
  UI_Color;

procedure TMarqueeLabelUI.Init;
begin
  inherited;
  RegEvent(XE_PAINT, @OnPaint);
  RegEvent(XE_XC_TIMER, @TimerProc);
  FDefaultFont := XRes_GetFont('微软雅黑15');
end;

destructor TMarqueeLabelUI.Destroy;
begin
  XEle_KillXCTimer(Handle, FTimerID);
  inherited Destroy;
end;

class function TMarqueeLabelUI.OnPaint(hEle, hDraw: Integer; pbHandled: PBoolean): Integer; stdcall;
var
  MarqueeLabel: TMarqueeLabelUI;
  RC: TRect;
  i: Integer;
begin
  Result := 0;
  MarqueeLabel := GetClassFormHandle(hEle);
  if not Assigned(MarqueeLabel) then
    Exit;

  XEle_GetClientRect(hEle, RC);

  // 设置绘制属性
  XDraw_SetFont(hDraw, MarqueeLabel.FDefaultFont);
  XDraw_SetBrushColor(hDraw, Theme_TextColor_Leave);
  XDraw_SetTextAlign(hDraw, textAlignFlag_left or textFormatFlag_NoWrap);
  // 绘制所有文本实例
  for i := 0 to High(MarqueeLabel.FRECTArray) do
  begin
    RC.Left := MarqueeLabel.FRECTArray[i].Left;
    XDraw_DrawText(hDraw, PChar(MarqueeLabel.MarqueeText), -1, RC);
  end;
end;

procedure TMarqueeLabelUI.SetMarqueeText(const Value: string);
var
  Size: TSize;
  EleWidth: Integer;
  i, Count: Integer;
begin
  FMarqueeText := Value;
  FOffset := 1; // 每次移动的像素数

  // 计算字体宽度
  XC_GetTextShowSize(PChar(Value), -1, FDefaultFont, Size);
  FFontWidth := Size.cx;
  EleWidth := XEle_GetWidth(Handle);

  // 清除旧定时器
  XEle_KillXCTimer(Handle, FTimerID);

  if FFontWidth > EleWidth then
  begin
    // 计算需要的矩形数量（足够覆盖控件宽度）
    Count := (EleWidth div (FFontWidth + 20)) + 2;
    SetLength(FRECTArray, Count);

    // 初始化矩形位置
    for i := 0 to High(FRECTArray) do
      FRECTArray[i].Left := i * (FFontWidth + 20);

    // 启动定时器
    XEle_SetXCTimer(Handle, FTimerID, Speed);
  end
  else
  begin
    SetLength(FRECTArray, 1);
    FRECTArray[0].Left := 0;
    Redraw;
  end;
end;

class function TMarqueeLabelUI.TimerProc(hEle, nTimerID: Integer; pbHandled: PBoolean): Integer; stdcall;
var
  P: Pointer;
  MarqueeLabel: TMarqueeLabelUI;
  i: Integer;
  LastIndex: Integer;
  TempRect: TRect;
begin
  Result := 0;
  P := GetClassFormHandle(hEle);
  if not Assigned(P) then
    Exit;

  MarqueeLabel := TMarqueeLabelUI(P);

  // 移动所有矩形
  for i := 0 to High(MarqueeLabel.FRECTArray) do
    MarqueeLabel.FRECTArray[i].Left := MarqueeLabel.FRECTArray[i].Left - MarqueeLabel.FOffset;

  // 检查并重置移出屏幕的矩形
  i := 0;
  while i <= High(MarqueeLabel.FRECTArray) do
  begin
    if MarqueeLabel.FRECTArray[i].Left + MarqueeLabel.FFontWidth < 0 then
    begin
      LastIndex := High(MarqueeLabel.FRECTArray);

      // 移动到最后一个矩形右侧
      MarqueeLabel.FRECTArray[i].Left := MarqueeLabel.FRECTArray[LastIndex].Left + MarqueeLabel.FFontWidth + 20;

      // 保持数组顺序：将当前矩形移动到末尾
      if i < LastIndex then
      begin
        TempRect := MarqueeLabel.FRECTArray[i];
        Move(MarqueeLabel.FRECTArray[i + 1], MarqueeLabel.FRECTArray[i], (LastIndex - i) * SizeOf(TRect));
        MarqueeLabel.FRECTArray[LastIndex] := TempRect;
      end;
    end
    else
      Inc(i);
  end;

  MarqueeLabel.Redraw; // 触发重绘
end;

procedure TMarqueeLabelUI.SetSpeed(const Value: Integer);
begin
  FSpeed := Value; // 实际定时器间隔由SetMarqueeText设置
end;

end.






