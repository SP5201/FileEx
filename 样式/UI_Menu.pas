unit UI_Menu;

interface

uses
  Windows, Classes, Messages, SysUtils,
  ShellAPI, System.Generics.Collections, XForm, XWidget, XMenu, XElement,
  XCGUI;

type
  TPopupMenuSeletEvent = procedure(nID: Integer);
  TPopupMenuExitEvent = procedure of Object;

  TPopupMenuUI = class(TXMenu)
      class var
      FExpandImage: Integer;   //展开图像
  private
      FOnSeletCallback: TPopupMenuSeletEvent;
      FOnExitCallback:  TPopupMenuExitEvent;
      FSvg: Integer;
      FWidget: TXWidget;
  protected
    class function OnMenuSelet(Parent: Integer; nid: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnMenuExit(Parent: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnWndMenuPopupWND(Parent, hMenu: Integer; var pInfo: Tmenu_popupWnd_; pbHandle: PBoolean): Integer; stdcall; static;
    class function OnWndMenuDRAWITEM(Parent: Integer; hDraw: Integer; var pInfo: Tmenu_drawItem_; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnWndMenuDrawBackground(Parent: Integer; hDraw: Integer; var pInfo: Tmenu_drawBackground_; pbHandled: PBoolean): Integer; stdcall; static;
    procedure RegEvent;
  public
    property MenuSeletCallback: TPopupMenuSeletEvent read FOnSeletCallback write FOnSeletCallback;
    property MenuExitCallback: TPopupMenuExitEvent read FOnExitCallback write FOnExitCallback;
    procedure AddItemSvg(nID: Integer; pText: PWideChar; nParentID: Integer; SvgFile: PWideChar; nWidth: integer = 16; nHeight: integer = 16; nFlags: Integer = 0); overload;
    procedure Popup(hWidget: TXWidget = nil; x: Integer = 0; y: Integer = 0; nPosition: Tmenu_popup_position_ = menu_popup_position_left_top; AlignToWidget: Boolean = False);
    constructor Create(hXcgui:Integer); overload;
    destructor Destroy; override;
  end;

implementation

uses
  UI_Resource, UI_Color, UI_Animation;

constructor TPopupMenuUI.Create(hXcgui: Integer);
begin
    inherited Create;
  SetItemHeight(28);
  if XC_GetObjectType(FExpandImage) <> XC_IMAGE then
  begin
    FSvg := XResource_LoadZipSvg('窗口组件\右键菜单展开.svg');
    XSvg_SetSize(FSvg, 15, 15);
    XSvg_SetUserFillColor(FSvg, Theme_TextColor_Leave, True);
    FExpandImage := XImage_LoadSvg(FSvg);
  end;
end;

destructor TPopupMenuUI.Destroy;
begin
  if XC_GetObjectType(FExpandImage) = XC_IMAGE then
    XImage_Release(FExpandImage);
  inherited;
end;

procedure TPopupMenuUI.AddItemSvg(nID: Integer; pText: PWideChar; nParentID: Integer; SvgFile: PWideChar; nWidth: integer = 16; nHeight: integer = 16; nFlags: Integer = 0);
var
  hSvg: Integer;
  hImage: Integer;
begin
  hSvg := XResource_LoadZipSvg(SvgFile);
  if XC_GetObjectType(hSvg) = XC_SVG then
  begin
    XSvg_SetUserFillColor(hSvg, Theme_TextColor_Leave, True);
    XSvg_SetSize(hSvg, nWidth, nHeight);
    hImage := XImage_LoadSvg(hSvg);
    if XC_GetObjectType(hImage) = XC_IMAGE then
    begin
      XImage_SetDrawType(hImage, image_draw_type_stretch);
      XMenu_AddItemIcon(Handle, nID, pText, nParentID, hImage, nFlags);
    end;
  end
  else
    XMenu_AddItemIcon(Handle, nID, pText, nParentID, 0, nFlags);
end;

class function TPopupMenuUI.OnMenuExit(Parent: Integer; pbHandled: PBoolean): Integer;
var
  FWidget: TXWidget;
  PopupMenuUI: TPopupMenuUI;
begin
  Result := 0;
  FWidget := GetClassFormHandle(Parent);
  PopupMenuUI := FWidget.PopupMenu;
  if Assigned(PopupMenuUI.FOnExitCallback) then
    PopupMenuUI.FOnExitCallback;
  PopupMenuUI.Free;
end;

class function TPopupMenuUI.OnWndMenuPopupWND(Parent, hMenu: Integer; var pInfo: Tmenu_popupWnd_; pbHandle: PBoolean): Integer; stdcall;
var
  nRect, mRect: TRect;
  Anima: Integer;
  AnimaGroup: Integer;
  dpi: Integer ;
  scale: Double  ;
begin
  Result := 0;
  XWnd_EnableDragWindow(pInfo.hWindow, False);
  XWnd_EnableDragCaption(pInfo.hWindow, False);
  XMenu_EnableDrawBackground(hMenu, True);
  XMenu_EnableDrawItem(hMenu, True);
  XWnd_GetRect(pInfo.hWindow, nRect);
  XWnd_GetClientRect(pInfo.hWindow, mRect);
  XWnd_SetTransparentType(pInfo.hWindow, window_transparent_shaped);
  XWnd_SetTransparentAlpha(pInfo.hWindow, 255);
  XWnd_SetBorderSize(pInfo.hWindow, 11, 11, 11, 11);
  if pInfo.nParentID <> 0 then
  begin
    // DPI-aware values
    dpi:= XWnd_GetDPI(pInfo.hWindow);
    scale:= dpi / 96.0;
    MoveWindow(XWnd_GetHWND(pInfo.hWindow), Round((nRect.Left - 20) * scale), Round(nRect.Top * scale), Round((mRect.width + 22) * scale), Round((mRect.height + 22) * scale), True);
    AnimaGroup := XAnimaGroup_Create(1);
    Anima := XAnima_Create(pInfo.hWindow, 1);
    XAnima_MoveEx(Anima, 120, Round((nRect.Left - 20) * scale), Round((nRect.Top - 20) * scale), Round((nRect.Left - 20) * scale), Round(nRect.Top * scale), 1, ease_flag_back, False);
    XAnima_EnableAutoDestroy(Anima, True);
    XAnimaGroup_AddItem(AnimaGroup, Anima);
    Anima := XAnima_Create(pInfo.hWindow, 1);
    XAnima_AlphaEx(Anima, 300, 10, 255, 1, ease_flag_in, False);
    XAnima_EnableAutoDestroy(Anima, True);
    XAnimaGroup_AddItem(AnimaGroup, Anima);
    XAnima_Run(AnimaGroup, pInfo.hWindow);
  end
  else
  begin
    MoveWindow(XWnd_GetHWND(pInfo.hWindow), Round(nRect.Left*XWnd_GetDPI(pInfo.hWindow)/96), Round(nRect.Top*XWnd_GetDPI(pInfo.hWindow)/96), Round((mRect.width + 22)*XWnd_GetDPI(pInfo.hWindow)/96), Round((mRect.Height + 22)*XWnd_GetDPI(pInfo.hWindow)/96), True);
    XAnima_SetWindowAlphaScale(pInfo.hWindow, 400, 20, 255, 1.04, 1.04);
  end;
end;


class function TPopupMenuUI.OnMenuSelet(Parent, nid: Integer;
  pbHandled: PBoolean): Integer;
begin
  Result := 0;
  SendMessage(XWidget_GetHWND(Parent), XE_MENU_SELECT, nid, Parent);
end;

procedure TPopupMenuUI.Popup(hWidget: TXWidget; x: Integer; y: Integer; nPosition: Tmenu_popup_position_; AlignToWidget: Boolean);
var
  Point: TPoint;
  WidgetRect: TRect;
begin
  FWidget := hWidget;
  if not Assigned(FWidget) then Exit;

  FWidget.PopupMenu := Self;
  RegEvent;

  if AlignToWidget and hWidget.IsHELE then
  begin
    XEle_GetWndClientRectDPI(hWidget.Handle, WidgetRect);
    Point.X := WidgetRect.Left;
    Point.Y := WidgetRect.Bottom;
    ClientToScreen(hWidget.GetHWND, Point);

    XMenu_Popup(Handle, FWidget.GetHWND, Point.X + x, Point.Y + y, FWidget.Handle, nPosition);
  end
  else
  begin
    GetCursorPos(Point);
    if FWidget.IsHELE then
      XMenu_Popup(Handle, FWidget.GetHWND, Point.X + x, Point.y + y, FWidget.Handle, nPosition)
    else
      XMenu_Popup(Handle, FWidget.Handle, Point.X + x, Point.y + y, 0, nPosition);
  end;
end;

procedure TPopupMenuUI.RegEvent;
var
  Control: TXEle;
  Form: XForm.TXForm;
begin
  if FWidget.IsHELE then
  begin
    Control := TXEle(FWidget);
    Control.RemoveEvent(XE_MENU_POPUP_WND, @OnWndMenuPopupWND);
    Control.RemoveEvent(XE_MENU_DRAWITEM, @OnWndMenuDRAWITEM);
    Control.RemoveEvent(XE_MENU_DRAW_BACKGROUND, @OnWndMenuDrawBackground);
    Control.RemoveEvent(XE_MENU_EXIT, @OnMenuExit);
    Control.RemoveEvent(XE_MENU_SELECT, @OnMenuSelet);
    Control.RegEvent(XE_MENU_EXIT, @OnMenuExit);
    Control.RegEvent(XE_MENU_SELECT, @OnMenuSelet);
    Control.RegEvent(XE_MENU_POPUP_WND, @OnWndMenuPopupWND);
    Control.RegEvent(XE_MENU_DRAWITEM, @OnWndMenuDRAWITEM);
    Control.RegEvent(XE_MENU_DRAW_BACKGROUND, @OnWndMenuDrawBackground);
  end
  else if XC_IsHWINDOW(FWidget.Handle) then
  begin
    Form := TXForm(FWidget);
    Form.RemoveEvent(XWM_MENU_POPUP_WND, @OnWndMenuPopupWND);
    Form.RemoveEvent(XWM_MENU_DRAW_BACKGROUND, @OnWndMenuDrawBackground);
    Form.RemoveEvent(XWM_MENU_DRAWITEM, @OnWndMenuDRAWITEM);
    Form.RemoveEvent(XWM_MENU_EXIT, @OnMenuExit);
    Form.RegEvent(XWM_MENU_EXIT, @OnMenuExit);
    Form.RegEvent(XWM_MENU_POPUP_WND, @OnWndMenuPopupWND);
    Form.RegEvent(XWM_MENU_DRAW_BACKGROUND, @OnWndMenuDrawBackground);
    Form.RegEvent(XWM_MENU_DRAWITEM, @OnWndMenuDRAWITEM);
  end;
end;


class function TPopupMenuUI.OnWndMenuDRAWITEM(Parent: Integer; hDraw: Integer; var pInfo: Tmenu_drawItem_; pbHandled: PBoolean): Integer; stdcall;
var
  Rc: TRect;
 // pt: array[0..2] of TPOINT;
begin
  pbHandled^ := true;
  Result := 0;

  if (pInfo.nState = menu_item_flag_stay) or (pInfo.nState = menu_item_flag_stay or menu_item_flag_popup) then
  begin
    XDraw_SetBrushColor(hDraw, Theme_MenuBkColor_Stay);
    XDraw_FillRoundRectEx(hDraw, pInfo.rcItem, 4, 4, 4, 4);
  end;

  if pInfo.hIcon > 0 then
    XDraw_Image(hDraw, pInfo.hIcon, pInfo.rcItem.Left + 12, pInfo.rcItem.top + (XMenu_GetItemHeight(pInfo.hMenu) - XImage_GetHeight(pInfo.hIcon)) div 2);

  if (pInfo.nState = menu_item_flag_popup) or (pInfo.nState = menu_item_flag_popup or menu_item_flag_select) then
  begin
   // pt[0].x := pInfo.rcItem.cx + pInfo.rcItem.x - 25;
   // pt[0].y := pInfo.rcItem.y + 7;

   // pt[1].x := pInfo.rcItem.cx + pInfo.rcItem.x - 25;
   // pt[1].y := pInfo.rcItem.y + 17;

  //  pt[2].x := pInfo.rcItem.cx + pInfo.rcItem.x - 20;
   // pt[2].y := pInfo.rcItem.y + 12;

   // XDraw_SetBrushColor(hDraw, RGBA(255, 255, 255, 255));
  //  XDraw_FillPolygon(hDraw, @pt[0], 3);
    XDraw_ImageEx(hDraw, TPopupMenuUI.FExpandImage, pInfo.rcItem.Right - 18, pInfo.rcItem.top + 7, 15, 15);
  end;

  Rc := pInfo.rcItem;
  Rc.left := pInfo.rcItem.left + XMenu_GetLeftWidth(pInfo.hMenu) + 5;
  XDraw_SetTextAlign(hDraw, textAlignFlag_vcenter);

  if pInfo.nState = menu_item_flag_disable then
  begin
    XDraw_SetBrushColor(hDraw, RGBA(255, 255, 255, 55))
  end
  else
  begin
    XDraw_SetBrushColor(hDraw, Theme_TextColor_Leave);
    XDraw_DrawText(hDraw, pInfo.pText, -1, Rc);
  end;

  if pInfo.nState = menu_item_flag_separator then
  begin
    XDraw_SetBrushColor(hDraw, RGBA(120, 120, 120, 60));
    XDraw_DrawLine(hDraw, pInfo.rcItem.Left , pInfo.rcItem.top+1, pInfo.rcItem.Right , pInfo.rcItem.top+1);
  end;
end;

class function TPopupMenuUI.OnWndMenuDrawBackground(Parent: Integer; hDraw: Integer; var pInfo: Tmenu_drawBackground_; pbHandled: PBoolean): Integer; stdcall;
var
  Rc: TRect;
  BkImage: Integer;
begin
  Result := 0;
  BkImage := XRes_GetImage('圆角阴影6px');

  if XC_GetObjectType(BkImage) = XC_IMAGE then
  begin
    XImage_SetDrawType(BkImage, image_draw_type_adaptive_border);
    XImage_SetDrawTypeAdaptive(BkImage, 25, 25, 35, 25);
    XWnd_GetClientRect(pInfo.hWindow, Rc);
    XDraw_ImageSuper(hDraw, BkImage, Rc, False);
  end;

  Rc.Left := Rc.Left + 10;
  Rc.Top := Rc.top + 10;
  Rc.width := Rc.width - 10;
  Rc.height := Rc.height - 10;

  XDraw_SetBrushColor(hDraw, Theme_Window_BkColor);
  XDraw_FillRoundRectEx(hDraw, Rc, 6, 6, 6, 6);
  XDraw_SetBrushColor(hDraw, Theme_Window_BorderColor);
  XDraw_DrawRoundRectEx(hDraw, Rc, 6, 6, 6, 6);
end;

end.








