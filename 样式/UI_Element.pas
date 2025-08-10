unit UI_Element;

interface

uses
  Windows, Classes, XCGUI, XElement, XWidget;

type
  TEleUI = class(TXEle)
  private
    FBackgroundColor: Cardinal;  // 背景颜色
    FEnableBackground: Boolean;  // 是否启用背景
    FCornerRadius: Integer;      // 圆角半径
    procedure SetCornerRadius(const Value: Integer);
  protected
    class function OnElePAINT(hEle: Integer; hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    procedure OnEleUIPAINT(hDraw: Integer);
    procedure Init; override;
  public
    property BackgroundColor: Cardinal read FBackgroundColor write FBackgroundColor;
    property EnableBackground: Boolean read FEnableBackground write FEnableBackground;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius;
  end;

implementation

uses
  UI_Resource, UI_Animation, UI_Color;

{ TEleUI }

procedure TEleUI.Init;
begin
  inherited;
  EnableBkTransparent(True);
  FBackgroundColor := 0;  // 默认透明背景
  FEnableBackground := True;  // 默认启用背景
  FCornerRadius := 0;  // 默认无圆角
  RegEvent(XE_PAINT, @OnElePAINT);
end;

class function TEleUI.OnElePAINT(hEle, hDraw: Integer; pbHandled: PBoolean): Integer;
var
  HEleUI: TEleUI;
begin
  Result := 0;
  pbHandled^ := True;
  HEleUI := TXWidget.GetClassFormHandle(hEle);
  HEleUI.OnEleUIPAINT(hDraw);
end;

procedure TEleUI.OnEleUIPAINT(hDraw: Integer);
var
  rc: TRect;
begin
  // 绘制背景颜色
  if FEnableBackground then
  begin
    XEle_GetClientRect(Handle, rc);
    XDraw_SetBrushColor(hDraw, FBackgroundColor);
    
    if FCornerRadius > 0 then
      // 绘制圆角矩形
      XDraw_FillRoundRectEx(hDraw, rc, FCornerRadius, FCornerRadius, FCornerRadius, FCornerRadius)
    else
      // 绘制普通矩形
      XDraw_FillRect(hDraw, rc);
  end;
end;

procedure TEleUI.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius <> Value then
  begin
    FCornerRadius := Value;
    if IsHELE then
      Redraw;
  end;
end;

end.

