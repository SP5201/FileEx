unit UI_SliderBar;

interface

uses
  Windows, Classes, SysUtils, Types,
  XCGUI, XSliderBar, XWidget,
  UI_Resource, UI_Color;

type
  TSliderBarUI = class(TXSliderBar)
  private
    FTrackColor: Integer;
    FThumbColor: Integer;
    FThumbHotColor: Integer;
    procedure SetTrackColor(const Value: Integer);
    procedure SetThumbColor(const Value: Integer);
    procedure SetThumbHotColor(const Value: Integer);
  protected
    class function OnPAINT(hEle: Integer; hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnButtonPAINT(hEle: Integer; hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    procedure PAINT(hDraw: Integer); virtual;
    procedure Init; override;
    procedure UpdateThemeStyle;
  public
    constructor Create(x, y, cx, cy: Integer; hParent: TXWidget); reintroduce; overload;
    destructor Destroy; override;
    procedure SetDefaultStyle;
    property TrackColor: Integer read FTrackColor write SetTrackColor;
    property ThumbColor: Integer read FThumbColor write SetThumbColor;
    property ThumbHotColor: Integer read FThumbHotColor write SetThumbHotColor;
  end;

implementation

{ TSliderBarUI }

constructor TSliderBarUI.Create(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  inherited Create(x, y, cx, cy, hParent);
end;

destructor TSliderBarUI.Destroy;
begin
  inherited;
end;

procedure TSliderBarUI.Init;
begin
  inherited;
  SetDefaultStyle;
end;

procedure TSliderBarUI.SetDefaultStyle;
var
  hButton: HELE;
begin
  EnableBkTransparent(True);
  RegEvent(XE_PAINT, @OnPAINT);
  ButtonWidth:=12;
  ButtonHeight:=12;

  // 设置滑块按钮为圆形绘制
  hButton := XSliderBar_GetButton(Handle);
  if hButton <> 0 then
  begin
    XEle_RegEvent(hButton, XE_PAINT, @OnButtonPAINT);
    XEle_EnableBkTransparent(hButton, True);
    XEle_SetCursor(hButton, LoadCursor(0, IDC_HAND)); // 设置手形光标
  end;

  UpdateThemeStyle;
end;

procedure TSliderBarUI.UpdateThemeStyle;
begin
  // 使用默认颜色，您可以根据需要修改这些值
  TrackColor := RGBA(200, 200, 200, 255);  // 灰色滑道
  ThumbColor := RGBA(100, 100, 100, 255);  // 深灰色滑块
  ThumbHotColor := RGBA(80, 80, 80, 255);  // 更深的灰色（悬停状态）
end;


class function TSliderBarUI.OnPAINT(hEle, hDraw: Integer; pbHandled: PBoolean): Integer;
var
  Slider: TSliderBarUI;
begin
  Result := 0;
  pbHandled^ := True;
  Slider := TSliderBarUI.GetClassFormHandle(hEle);
  if Assigned(Slider) then
    Slider.PAINT(hDraw);
end;

class function TSliderBarUI.OnButtonPAINT(hEle, hDraw: Integer; pbHandled: PBoolean): Integer;
var
  rc: TRect;
begin
  Result := 0;
  pbHandled^ := True;
  
  XEle_GetClientRect(hEle, rc);
  
  // 滑块按钮任何状态都使用主题色
  XDraw_SetBrushColor(hDraw, Theme_PrimaryColor);
  XDraw_FillEllipse(hDraw, rc);
end;

procedure TSliderBarUI.PAINT(hDraw: Integer);
var
  rc, selectedRc: TRect;
  selectedWidth: Integer;
  currentPos, maxPos: Integer;
begin
  GetClientRect(rc);

  // 绘制整个滑道背景（圆角矩形）
  XDraw_SetBrushColor(hDraw, Theme_Window_BorderColor);
  // 一个简单的垂直居中滑道
  rc.Top := rc.Top + rc.Height div 2 - 1;
  rc.Bottom := rc.Top + 2;
  XDraw_FillRoundRect(hDraw, rc, 1, 1);
  
  // 绘制选中部分的滑道（主题色圆角矩形）
  currentPos := Pos;
  maxPos := RangeMax;
  if (maxPos > 0) and (currentPos > 0) then
  begin
    selectedWidth := Round((currentPos / maxPos) * rc.Width);
    if selectedWidth > 0 then
    begin
      selectedRc := rc;
      selectedRc.Right := selectedRc.Left + selectedWidth;
      
      XDraw_SetBrushColor(hDraw, Theme_PrimaryColor);
      XDraw_FillRoundRect(hDraw, selectedRc, 1, 1);
    end;
  end;
  
  // 滑块按钮的圆形绘制已在初始化时设置
end;

procedure TSliderBarUI.SetTrackColor(const Value: Integer);
begin
  if FTrackColor <> Value then
  begin
    FTrackColor := Value;
  end;
end;


procedure TSliderBarUI.SetThumbColor(const Value: Integer);
begin
  if FThumbColor <> Value then
  begin
    FThumbColor := Value;
  end;
end;

procedure TSliderBarUI.SetThumbHotColor(const Value: Integer);
begin
  if FThumbHotColor <> Value then
  begin
    FThumbHotColor := Value;
  end;
end;

end. 