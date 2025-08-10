unit UI_Edit;

interface

uses
  Windows, Messages, XCGUI, XEdit, UI_Button, UI_Resource, XWidget,
  UI_Color;

type
  TEditUI = class(TXEdit)
  private
    FEnableBorder: Boolean;
    FEnableNumberOnly: Boolean;
    procedure UpdateThemeStyle;
  protected
    procedure Init; override;
    class function OnPaint(hEdit, hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnKeyDown(hEdit: Integer; wParam: WPARAM; lParam: LPARAM; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnCHAR(hEdit: Integer; wParam: WPARAM; lParam: LPARAM; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnEditPosChanged(hEdit: Integer;iPos: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    procedure Paint(hEdit, hDraw: Integer; pbHandled: PBoolean); virtual;
    procedure KeyDown(wParam: WPARAM; lParam: LPARAM); virtual;
    procedure Style;
  public
    constructor CreateEx(x, y, cx, cy: Integer; editType: edit_type_; hParent: TXWidget);
    property EnableBorder: Boolean read FEnableBorder write FEnableBorder default False;
    property EnableNumberOnly: Boolean read FEnableNumberOnly write FEnableNumberOnly default False;
    destructor Destroy; override;
  end;

implementation
uses
UI_ScrollBar, System.SysUtils;


constructor TEditUI.CreateEx(x, y, cx, cy: Integer; editType: edit_type_; hParent: TXWidget);
begin
  Handle := XEdit_CreateEx(x, y, cx, cy, editType, hParent.Handle);
  Init;
end;

destructor TEditUI.Destroy;
begin
  XTheme_RemoveThemeChangeCallback(Style);
  inherited;
end;

procedure TEditUI.Init;
begin
  inherited;
  if IsMultiLine then
    SetBorderSize(5, 5, 0, 5)
  else
    SetBorderSize(5, 0, 4, 0);
  XScrollBa_SetDefStyle(Handle);
  EnableBkTransparent(True);
  RegEvent(XE_PAINT, @OnPaint);
  FEnableBorder := False;
  FEnableNumberOnly := False;
  RegEvent(XE_KEYDOWN, @OnKEYDOWN);
  RegEvent(XE_CHAR, @OnCHAR);
  RegEvent(XE_EDIT_POS_CHANGED , @OnEditPosChanged);
  XTheme_AddChangeCallback(Style);
  Style;
end;

procedure TEditUI.Style;
begin
  SetDefaultTextColor(Theme_EDit_Default);
  SetCaretColor(Theme_EDit_CaretColor);
  SetTextColor(Theme_EDit_TextColor);
  UpdateThemeStyle;
end;

class function TEditUI.OnCHAR(hEdit: Integer; wParam: wParam; lParam: lParam; pbHandled: PBoolean): Integer;
var
  EditUI: TEditUI;
  ch: WideChar;
begin
  Result := 0;
  EditUI := TEditUI(GetClassFormHandle(hEdit));
  if Assigned(EditUI) and EditUI.EnableNumberOnly then
  begin
    ch := WideChar(wParam);
    // 只允许输入数字和控制字符(如退格, 回车, 左右键等)
    // 此处逻辑为：如果是可打印字符(ch >= ' ')，但又不是数字，则拦截。
    if (ch >= ' ') and not CharInSet(ch, ['0'..'9']) then
    begin
      pbHandled^ := True;
      Result := 1;
    end;
  end;
end;


class function TEditUI.OnEditPosChanged(hEdit: Integer;iPos: Integer; pbHandled: PBoolean): Integer;
begin
   Result := 0;
   XEle_Redraw(hEdit);
end;

class function TEditUI.OnKeyDown(hEdit: Integer; wParam: wParam; lParam: lParam; pbHandled: PBoolean): Integer;
begin
  Result := 0;
  TEditUI(GetClassFormHandle(hEdit)).KeyDown(wParam, lParam);
end;

procedure TEditUI.KeyDown(wParam: wParam; lParam: lParam);
begin
end;

class function TEditUI.OnPaint(hEdit, hDraw: Integer; pbHandled: PBoolean): Integer;
begin
  Result := 0;
  pbHandled^ := True;
  TEditUI(GetClassFormHandle(hEdit)).Paint(hEdit, hDraw, pbHandled);
end;

procedure TEditUI.Paint(hEdit, hDraw: Integer; pbHandled: PBoolean);
var
  RC: TRect;
begin
  GetClientRect(RC);
  if FEnableBorder then
  begin
    if XWnd_GetFocusEle(XWidget_GetHWINDOW(hEdit)) = hEdit then
      XDraw_SetBrushColor(hDraw, Theme_Edit_BorderColor_focus)
    else
      XDraw_SetBrushColor(hDraw, Theme_Edit_BorderColor_focus_no);
    XDraw_DrawRoundRectEx(hDraw, RC, Theme_Edit_CornerRadius, Theme_Edit_CornerRadius, Theme_Edit_CornerRadius, Theme_Edit_CornerRadius);
  end;
end;

procedure TEditUI.UpdateThemeStyle;
begin
  if IsHELE then
    Redraw;
end;

end.

