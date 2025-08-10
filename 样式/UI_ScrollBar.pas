unit UI_ScrollBar;

interface

uses
  Windows, Classes, XCGUI;

procedure XScrollBa_SetDefStyle(Hele: Integer; MinLength: Integer = 36);

implementation

function OnSliderPAINT(hSlider, hDraw: Integer; pbHandle: PBoolean): Integer; stdcall;
var
  RC: TRect;
begin
   Result :=0;
  pbHandle^ := True;
  XEle_GetClientRect(hSlider, RC);
  RC.Right := RC.Right-2 ;
  if XBtn_GetState(hSlider) = button_state_leave then
    XDraw_SetBrushColor(hDraw, RGBA(255, 255, 255, 30))
  else
    XDraw_SetBrushColor(hDraw, RGBA(255, 255, 255, 50));

  XDraw_FillRoundRectEx(hDraw, RC, 3, 3, 3, 3);
end;

procedure XScrollBa_SetDefStyle(Hele: Integer; MinLength: Integer = 36);
var
  mSlider: Integer;
  mScrollBar: Integer;
begin
  mScrollBar := XSView_GetScrollBarV(Hele);
  XSView_SetScrollBarSize(Hele, 10);
  XEle_EnableBkTransparent(mScrollBar, True);
  XSView_EnableAutoShowScrollBar(Hele, true);
  XSBar_ShowButton(mScrollBar, False);
  mSlider := XSBar_GetButtonSlider(mScrollBar);
  XEle_EnableBkTransparent(mSlider, TRUE);
  XSBar_SetSliderMinLength(mScrollBar, MinLength);
  XEle_SetCursor(mSlider, LoadCursor(0, IDC_HAND));
  XEle_RegEventC1(mSlider, XE_PAINT, Integer(@OnSliderPAINT));
end;

end.

