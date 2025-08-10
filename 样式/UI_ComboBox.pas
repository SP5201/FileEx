unit UI_Combobox;

interface

uses
  Windows, Math, Messages, XCGUI, XCOMBOBOX, UI_Resource, UI_Color, UI_Animation,
  SysUtils, XWidget, UI_Button, UI_ListBox, UI_ScrollBar,UI_Form;

type
  TComboBoxUI = class(TXComboBox)
  private
    FSelectedText: string;
    Fsvg: Integer;
    class function OnPAINT(hComboBox: Integer; hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnComboBoxPopupList(hComboBox, hWindow, hListBox: Integer; var pbHandled: Boolean): Integer; stdcall; static;
    class function OnComboBoxExitList(hComboBox: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function ListBoxDRAWITEMPAINT(ListBox: Integer; hDraw: Integer; var pItem: TlistBox_item_; pbHandled: PBoolean): Integer; stdcall; static;
  protected
    procedure Init; override;
  public
  end;

implementation

{ TComboBoxUI }

procedure TComboBoxUI.Init;
begin
  inherited;
  EnableBkTransparent(True);
  EnableDrawButton(True);
  SetItemTemplate(XResource_LoadZipTemp(listItemTemp_type_listBox, 'ComboBox_Item.xml'));
  FSvg := XResource_LoadZipSvg('窗口组件\组合框下拉按钮.svg');
  CreateAdapter;
  RegEvent(XE_PAINT, @OnPAINT);
  EnableEdit(False);
  SetTextColor(Theme_TextColor_Leave);
  RegEvent(XE_COMBOBOX_POPUP_LIST, @OnComboBoxPopupList);
  RegEvent(XE_COMBOBOX_EXIT_LIST, @OnComboBoxExitList);
end;

class function TComboBoxUI.ListBoxDRAWITEMPAINT(ListBox, hDraw: Integer; var pItem: TlistBox_item_; pbHandled: PBoolean): Integer;
var
  R: TRect;
begin
  Result := 0;
  pbHandled^ := True;
  if pItem.nState = list_item_state_leave then
    XDraw_SetBrushColor(hDraw, 0)
  else if pItem.nState = list_item_state_stay then
    XDraw_SetBrushColor(hDraw, Theme_ItemBkColor_Stay)
  else if pItem.nState = list_item_state_select then
    XDraw_SetBrushColor(hDraw, Theme_ItemBkColor_Select);

  R := pItem.rcItem;
  R.Left := R.Left + 2;
  R.Right := R.Right - 2;
  XDraw_FillRoundRect(hDraw, R, 4, 4);

  XDraw_SetBrushColor(hDraw, Theme_TextColor_Leave);
  XDraw_SetTextAlign(hDraw, textAlignFlag_vcenter);
  R.Left := R.Left + 12;
  XDraw_DrawText(hDraw, XListBox_GetItemTextEx(ListBox, pItem.index, 'name1'), -1, R);
end;

class function TComboBoxUI.OnComboBoxPopupList(hComboBox, hWindow, hListBox: Integer; var pbHandled: Boolean): Integer;
var
  ComboBoxUI: TComboBoxUI;
  FormUI: TFormUI;
  R: TRect;
  LhWnd: Integer;
  ShadowSize, physicalShadowSize, logicalWidth: Integer;
  nAlpha, nCR: Integer;
  bRightAngle: BOOL;
  color: Integer;
  ItemHeight, SelHeight, PopupHeight: Integer;
  DpiScale: Single;
begin
  Result := 0;
  pbHandled := True;
  ComboBoxUI := GetClassFormHandle(hComboBox);

  XListBox_SetItemHeightDefault(hListBox, 28, 28);
  XListBox_GetItemHeightDefault(hListBox, ItemHeight, SelHeight);
  XListBox_SetRowSpace(hListBox, 2);
  XScrollBa_SetDefStyle(hListBox);
  XEle_EnableBkTransparent(hListBox, True);
  XListBox_SetSelectItem(hListBox,0) ;
  XEle_RegEvent(hListBox, XE_LISTBOX_DRAWITEM, @ListBoxDRAWITEMPAINT);

  PopupHeight := XListBox_GetCount_AD(hListBox) * (ItemHeight + XListBox_GetRowSpace(hListBox)) + 6;
  if PopupHeight > 300 then
    PopupHeight := 300;

  if XC_GetObjectType(ComboBoxUI.FSvg) = XC_SVG then
    XAnima_SetRotateStyle(ComboBoxUI.FSvg, DEFAULT_ANIMATION_DURATION, 90, 1, hComboBox);

  FormUI := TFormUI.FormHandle(hWindow);
  FormUI.ShowWindow(SWP_NOACTIVATE);
  FormUI.GetShadowInfo(ShadowSize, nAlpha, nCR, bRightAngle, color);
  LhWnd := XWnd_GetHWND(hWindow);
  GetWindowRect(LhWnd, R);

  DpiScale := FormUI.DpiScale;
  physicalShadowSize := Round(ShadowSize * DpiScale);
  logicalWidth := Round(R.Width / DpiScale);

  SetWindowPos(LhWnd, 0, R.Left - physicalShadowSize, R.Top - physicalShadowSize, R.Width + physicalShadowSize * 2, Round(PopupHeight * DpiScale) + physicalShadowSize * 2, SWP_NOZORDER or SWP_NOACTIVATE);
  XEle_SetRectEx(hListBox, ShadowSize, ShadowSize + 1, logicalWidth, PopupHeight + 1, True);
end;

class function TComboBoxUI.OnComboBoxExitList(hComboBox: Integer; pbHandled: PBoolean): Integer;
var
  ComboBoxUI: TComboBoxUI;
begin
  Result := 0;
  ComboBoxUI := GetClassFormHandle(hComboBox);
  if XC_GetObjectType(ComboBoxUI.FSvg) = XC_SVG then
    XAnima_SetRotateStyle(ComboBoxUI.FSvg, DEFAULT_ANIMATION_DURATION, 0, 1, hComboBox);
end;

class function TComboBoxUI.OnPAINT(hComboBox, hDraw: Integer; pbHandled: PBoolean): Integer;
var
  RC: TRect;
  ButtonRect: TRect;
  ComboBoxUI: TComboBoxUI;
begin
  pbHandled^ := True;
  Result := 0;
  ComboBoxUI := GetClassFormHandle(hComboBox);
  XEle_GetClientRect(hComboBox, RC);
  begin
    if XWnd_GetFocusEle(XWidget_GetHWINDOW(hComboBox)) = hComboBox then
      XDraw_SetBrushColor(hDraw, Theme_Edit_BorderColor_focus)
    else
      XDraw_SetBrushColor(hDraw, Theme_Edit_BorderColor_focus_no);
    XDraw_DrawRoundRectEx(hDraw, RC, 4, 4, 4, 4);
  end;

  RC.Top := (XEle_GetHeight(hComboBox) - 16) div 2;
  RC.Left := RC.Left + 8;
  XDraw_SetBrushColor(hDraw, Theme_TextColor_Leave);
  XDraw_DrawText(hDraw, PChar(ComboBoxUI.FSelectedText), -1, RC);

  XComboBox_GetButtonRect(hComboBox, ButtonRect);
  if XC_GetObjectType(ComboBoxUI.Fsvg) = XC_SVG then
  begin
    XSvg_SetUserFillColor(ComboBoxUI.Fsvg, Theme_SvgColor_Leave, True);
    XDraw_DrawSvgEx(hDraw, ComboBoxUI.Fsvg, ButtonRect.Left + 2, (ComboBoxUI.Height - 14) div 2, 14, 14);
  end;
end;

end.

