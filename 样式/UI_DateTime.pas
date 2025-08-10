unit UI_DateTime;

interface

uses
  Windows, Messages, Math, XCGUI, XBUTTON, UI_Resource, UI_Color, UI_Animation,
  SysUtils, XWidget, XDateTime, UI_Button,UI_Form;

type
  TDateTimeUI = class(TXDateTime)
  private
    FBtnUI: TSvgBtnUI;
    FDateText: string;
  protected
    class function OnPAINT(hDateTime: Integer; hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnDateTimePopupMonthCal(hDateTime, hMonthCalWnd: Integer; hMonthCal: Integer; var pbHandled: BOOL): Integer; stdcall; static;
    class function OnDateChange(hDateTime: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    procedure Init; override;
  public
  end;

implementation

{ TDateTimeUI }

class function TDateTimeUI.OnDateChange(hDateTime: Integer; pbHandled: PBoolean): Integer;
var
  pnYear, pnMonth, pnDay: Integer;
  Date: TDateTime;
  DateTimeUI: TDateTimeUI;
begin
  Result := 0;
  DateTimeUI := GetClassFormHandle(hDateTime);
  if Assigned(DateTimeUI) then
  begin
    DateTimeUI.GetDate(pnYear, pnMonth, pnDay);
    Date := EncodeDate(pnYear, pnMonth, pnDay);
    DateTimeUI.FDateText := DateToStr(Date);
    DateTimeUI.Redraw;
  end;
end;

procedure TDateTimeUI.Init;
var
  pnYear, pnMonth, pnDay: Integer;
  Date: TDateTime;
begin
  inherited;
  EnableBkTransparent(True);
  GetDate(pnYear, pnMonth, pnDay);
  Date := EncodeDate(pnYear, pnMonth, pnDay);
  FDateText := DateToStr(Date);
  FBtnUI := TSvgBtnUI.FromHandle(GetButton(0));
  FBtnUI.Style('窗口组件\日历.svg', '', 16, 16);
  FBtnUI.SetWidth(4);
  RegEvent(XE_PAINT, @OnPAINT);
  RegEvent(XE_DATETIME_POPUP_MONTHCAL, @OnDateTimePopupMonthCal);
  RegEvent(XE_DATETIME_CHANGE, @OnDateChange);
end;

class function TDateTimeUI.OnDateTimePopupMonthCal(hDateTime, hMonthCalWnd: Integer; hMonthCal: Integer; var pbHandled: BOOL): Integer;
var
  hBkM: Integer;
  hBtnUI: TSvgBtnUI;
  Form: TFormUI;
  R: TRect;
  LhWnd: Integer;
  ShadowSize, physicalShadowSize, logicalWidth, logicalHeight: Integer;
  nAlpha, nCR: Integer;
  bRightAngle: BOOL;
  color: Integer;
  DpiScale: Single;
begin
  Result := 0;
  pbHandled := true;
  hBkM := XEle_GetBkManager(hMonthCal);
  XEle_EnableBkTransparent(hDateTime, True);
  XEle_EnableBkTransparent(hMonthCal, True);
  XBkM_AddFill(hBkM, element_state_flag_leave, 0);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_cur_month or monthCal_state_flag_item_select_no or monthCal_state_flag_item_leave, 0);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_cur_month or monthCal_state_flag_item_select_no or monthCal_state_flag_item_stay, Theme_EleBkColor_Leave);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_cur_month or monthCal_state_flag_item_select_no or monthCal_state_flag_item_down, Theme_EleBkColor_Leave);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_cur_month or monthCal_state_flag_item_select or monthCal_state_flag_item_leave, Theme_EleBkColor_Leave);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_cur_month or monthCal_state_flag_item_select or monthCal_state_flag_item_stay, Theme_EleBkColor_Leave);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_cur_month or monthCal_state_flag_item_select or monthCal_state_flag_item_down, Theme_EleBkColor_Leave);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_last_month or monthCal_state_flag_item_select_no or monthCal_state_flag_item_leave, Theme_Window_BkColor);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_last_month or monthCal_state_flag_item_select_no or monthCal_state_flag_item_stay, Theme_EleBkColor_Leave);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_last_month or monthCal_state_flag_item_select_no or monthCal_state_flag_item_down, Theme_EleBkColor_Leave);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_last_month or monthCal_state_flag_item_select or monthCal_state_flag_item_leave, Theme_EleBkColor_Leave);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_last_month or monthCal_state_flag_item_select or monthCal_state_flag_item_stay, Theme_EleBkColor_Leave);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_last_month or monthCal_state_flag_item_select or monthCal_state_flag_item_down, Theme_EleBkColor_Leave);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_next_month or monthCal_state_flag_item_select_no or monthCal_state_flag_item_leave, Theme_Window_BkColor);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_next_month or monthCal_state_flag_item_select_no or monthCal_state_flag_item_stay, Theme_EleBkColor_Leave);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_next_month or monthCal_state_flag_item_select_no or monthCal_state_flag_item_down, Theme_EleBkColor_Leave);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_next_month or monthCal_state_flag_item_select or monthCal_state_flag_item_leave, Theme_EleBkColor_Leave);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_next_month or monthCal_state_flag_item_select or monthCal_state_flag_item_stay, Theme_EleBkColor_Leave);
  XBkM_AddFill(hBkM, monthCal_state_flag_item_next_month or monthCal_state_flag_item_select or monthCal_state_flag_item_down, Theme_EleBkColor_Leave);
  XEle_EnableFocus(hMonthCal, FALSE);
  XEle_EnableDrawBorder(hMonthCal, FALSE);
  XEle_SetTextColor(hMonthCal, Theme_TextColor_Leave);
  XMonthCal_SetTextColor(hMonthCal, 1, Theme_TextColor_Leave);
  hBtnUI := TSvgBtnUI.FromHandle(XMonthCal_GetButton(hMonthCal, monthCal_button_type_last_year));
  hBtnUI.SetText('');
  hBtnUI.Style('窗口组件\上一年.svg', '上一年');
  hBtnUI := TSvgBtnUI.FromHandle(XMonthCal_GetButton(hMonthCal, monthCal_button_type_last_month));
  hBtnUI.SetText('');
  hBtnUI.Style('窗口组件\上一月.svg', '上一月');
  hBtnUI := TSvgBtnUI.FromHandle(XMonthCal_GetButton(hMonthCal, monthCal_button_type_next_year));
  hBtnUI.SetText('');
  hBtnUI.Style('窗口组件\下一年.svg', '下一年');
  hBtnUI := TSvgBtnUI.FromHandle(XMonthCal_GetButton(hMonthCal, monthCal_button_type_next_month));
  hBtnUI.SetText('');
  hBtnUI.Style('窗口组件\下一月.svg', '下一月');
  hBtnUI := TSvgBtnUI.FromHandle(XMonthCal_GetButton(hMonthCal, monthCal_button_type_today));
  hBtnUI.EnableBorder := True;

  Form := TFormUI.FormHandle(hMonthCalWnd);
  Form.EnableDragWindow(False);
  Form.GetShadowInfo(ShadowSize, nAlpha, nCR, bRightAngle, color);
  LhWnd := XWnd_GetHWND(hMonthCalWnd);
  GetWindowRect(LhWnd, R);

  DpiScale := Form.DpiScale;
  physicalShadowSize := Round(ShadowSize * DpiScale);
  logicalWidth := Round((R.Right - R.Left) / DpiScale);
  logicalHeight := Round((R.Bottom - R.Top) / DpiScale);


  SetWindowPos(LhWnd, 0, R.Left - physicalShadowSize -(r.width- XEle_GetWidth(hDateTime))div 2 , R.Top - physicalShadowSize, (R.Right - R.Left) + physicalShadowSize * 2, (R.Bottom - R.Top) + physicalShadowSize * 2, SWP_NOZORDER or SWP_NOACTIVATE);
  XEle_SetRectEx(hMonthCal, ShadowSize, ShadowSize, logicalWidth, logicalHeight, True);
end;

class function TDateTimeUI.OnPAINT(hDateTime, hDraw: Integer; pbHandled: PBoolean): Integer;
var
  RC: TRect;
  DateTimeUI: TDateTimeUI;
begin
  pbHandled^ := True;
  Result := 0;
  DateTimeUI := GetClassFormHandle(hDateTime);
  XEle_GetClientRect(hDateTime, RC);
  begin
    if XWnd_GetFocusEle(XWidget_GetHWINDOW(hDateTime)) = hDateTime then
      XDraw_SetBrushColor(hDraw, Theme_Edit_BorderColor_focus)
    else
      XDraw_SetBrushColor(hDraw, Theme_Edit_BorderColor_focus_no);
    XDraw_DrawRoundRectEx(hDraw, RC, 4, 4, 4, 4);
  end;

  RC.Top := (XEle_GetHeight(hDateTime) - 16) div 2;
  RC.Left := RC.Left + 8;
  XDraw_SetBrushColor(hDraw, Theme_TextColor_Leave);
  XDraw_DrawText(hDraw, PChar(DateTimeUI.FDateText), -1, RC);
end;

end.

