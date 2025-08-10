unit UI_SearchEdit;

interface

uses
  Windows, Messages, XCGUI, XEdit, UI_Button, UI_Resource, UI_Animation, UI_Edit,
  UI_Messages, SysUtils, UI_Color, UI_Form, UI_List;

type
  TSearchEditUI = class(TEditUI)
  private
    FSearchBtnUI: TSvgBtnUI;
    FTopLeftRadius: Integer;
    FTopRightRadius: Integer;
    FBottomLeftRadius: Integer;
    FBottomRightRadius: Integer;
    FPopupFormUI: TFormUI;
    FListUI: TListUI; // 改为属性
  protected
    procedure KeyDown(wParam: WPARAM; lParam: LPARAM); override;
    class function OnSearchBNCLICK(hBtn: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnSetFocus(hEle: HELE; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnKillFocus(hEle: HELE; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnPopupWndPAINT(hWindow, hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    procedure Paint(hEdit, hDraw: Integer; pbHandled: PBoolean); override;
    procedure Init; override;
  public
    property ListUI: TListUI read FListUI write FListUI;
    procedure SetRadius(TopLeft, TopRight, BottomLeft, BottomRight: Integer);
  end;

implementation

procedure TSearchEditUI.SetRadius(TopLeft, TopRight, BottomLeft, BottomRight: Integer);
begin
  FTopLeftRadius := TopLeft;
  FTopRightRadius := TopRight;
  FBottomLeftRadius := BottomLeft;
  FBottomRightRadius := BottomRight;
end;

procedure TSearchEditUI.Init;
begin
  inherited;
  FTopLeftRadius := 4;
  FTopRightRadius := 4;
  FBottomLeftRadius := 4;
  FBottomRightRadius := 4;
  SetDefaultText('请输入关键字或演员名查询');
  SetPadding(10, 0, 10, 0);
  FSearchBtnUI := TSvgBtnUI.FromXmlID(GetHWINDOW, 1);
  FSearchBtnUI.Style('窗口组件\搜索.svg', '', 17, 17);
  FSearchBtnUI.RegEvent(XE_BNCLICK, @OnSearchBNCLICK);
  RegEvent(XE_SETFOCUS, @OnSetFocus);
  RegEvent(XE_KILLFOCUS, @OnKillFocus);
end;

procedure TSearchEditUI.KeyDown(wParam: wParam; lParam: lParam);
var
  Text: string;
begin
  Text := GetText_Temp;
  if wParam = VK_RETURN then
    XC_SendMessage(GetHWINDOW, XE_SEARCH_EDIT_RETURN, Integer(PChar(Text)), 0);
end;

class function TSearchEditUI.OnSearchBNCLICK(hBtn: Integer; pbHandled: PBoolean): Integer;
var
  Text: string;
  EditUI: TSearchEditUI;
begin
  Result := 0;
  EditUI := GetClassFormHandle(XWidget_GetParent(hBtn));
  Text := EditUI.GetText_Temp;
  XC_SendMessage(EditUI.GetHWINDOW, XE_SEARCH_EDIT_RETURN, Integer(PChar(Text)), 0);
end;

class function TSearchEditUI.OnSetFocus(hEle: hEle; pbHandled: PBoolean): Integer;
var
  EditUI: TSearchEditUI;
  hWindow: Integer;
  rc: TRect;
begin
  Result := 0;
  EditUI := GetClassFormHandle(hEle);
  if (EditUI <> nil) and not (EditUI.FPopupFormUI <> nil) then
  begin
    hWindow := EditUI.HWND;
    XEle_GetWndClientRect(EditUI.Handle, rc);
    ClientToScreen(hWindow, rc.TopLeft);
    ClientToScreen(hWindow, rc.BottomRight);

    EditUI.FPopupFormUI := TFormUI.CreateEx(WS_EX_TOPMOST or WS_EX_TRANSPARENT or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE, WS_POPUP, nil, rc.Left, rc.Bottom, rc.Right - rc.Left, 100, nil, XWidget_GetHWND(hEle), window_style_nothing);
    EditUI.FListUI := TListUI.Create(0,0,0,0,EditUI.FPopupFormUI);
    EditUI.FListUI.Init;
    EditUI.FListUI.ShowSBarH(False);
    EditUI.FListUI.SetHeaderHeight(0);
    EditUI.FListUI.SetColumnWidth(0,rc.Width);
    EditUI.FListUI.LayoutItem_SetWidth(layout_size_fill, 0);
    EditUI.FListUI.LayoutItem_SetHeight(layout_size_fill, 0);
    EditUI.FPopupFormUI.RegEvent(WM_PAINT, @OnPopupWndPAINT);
    EditUI.FPopupFormUI.ShowWindow(SW_SHOWNOACTIVATE);
  end;
end;

class function TSearchEditUI.OnKillFocus(hEle: hEle; pbHandled: PBoolean): Integer;
var
  EditUI: TSearchEditUI;
  hFocusWnd: Integer;
begin
  Result := 0;
  EditUI := GetClassFormHandle(hEle);
  if (EditUI <> nil) and (EditUI.FPopupFormUI <> nil) then
  begin
    if EditUI.FPopupFormUI.IsHWINDOW then
    begin
      hFocusWnd := Windows.GetFocus;
      if hFocusWnd <> Integer(EditUI.FPopupFormUI.HWND) then
      begin
        EditUI.FPopupFormUI.CloseWindow;
        EditUI.FPopupFormUI := nil;
        XWnd_SetFocusEle(EditUI.HWINDOW, XC_GetObjectByName('收藏总数'));
      end;
    end;
  end;
end;

class function TSearchEditUI.OnPopupWndPAINT(hWindow, hDraw: Integer; pbHandled: PBoolean): Integer;
var
  RC: TRect;
begin
  Result := 0;
  pbHandled^ := True;
  XWnd_GetClientRect(hWindow, RC); //取窗口客户区坐标

  XDraw_SetBrushColor(hDraw, Theme_Window_BkColor);
  XDraw_FillRoundRect(hDraw, RC, 0, 0);
  XDraw_SetBrushColor(hDraw, Theme_Window_BorderColor);
  XDraw_DrawRoundRect(hDraw, RC, 0, 0);
end;

procedure TSearchEditUI.Paint(hEdit, hDraw: Integer; pbHandled: PBoolean);
var
  RC: TRect;
begin
  XDraw_SetBrushColor(hDraw, RGBA(255, 255, 255, 26));
  XEle_GetClientRect(hEdit, RC);
  XDraw_FillRoundRectEx(hDraw, RC, FTopLeftRadius, FTopRightRadius, FBottomLeftRadius, FBottomRightRadius);
end;

end.

