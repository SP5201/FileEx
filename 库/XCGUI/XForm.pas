unit XForm;

interface

uses
  Windows, Messages, SysUtils, Classes, XCGUI, XWidget;

type
  TXForm = class(TXWidget)
  private
  protected
    class function OnDESTROY(hWnd: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    procedure Init; override;
  public
      // ��������
    class function FormHandle(Handle: Integer): Pointer; virtual;
    constructor Create(x, y, cx, cy: Integer; pTitle: PWideChar; hWndParent: HWND = 0; XCStyle: Integer = 0); reintroduce;
    constructor CreateEx(dwExStyle, dwStyle: DWORD; lpClassName: PWideChar; x, y, cx, cy: Integer; pTitle: PWideChar; hWndParent: HWND = 0; XCStyle: Integer = 0);
    function Attach(hWnd: HWND; XCStyle: Integer): Boolean;
    // �Ӷ������
    function AddChild(hChild: HXCGUI): Boolean;
    function InsertChild(hChild: HXCGUI; index: Integer): Boolean;
    function GetChildCount: Integer;
    function GetChildByIndex(index: Integer): HXCGUI;
    function GetChildByID(nID: Integer): HXCGUI;
    function GetChild(nID: Integer): HXCGUI;
    function HitChildEle(var pt: TPoint): HELE;
    // ���ڲ���
    procedure Redraw(bUpdate: Boolean = True);
    procedure RedrawRect(var pRect: TRect; bUpdate: Boolean = True);
    procedure Center;
    procedure CenterEx(width, height: Integer);
    procedure CloseWindow;
    procedure Show(bShow: Boolean = True);
    function ShowWindow(nCmdShow: Integer): Boolean;
    procedure SetPosition(x, y: Integer);
    procedure SetTop;
    procedure MaxWindow(bMaximize: Boolean = True);
    function SetWindowPos(hWndInsertAfter: HWND; X, Y, cx, cy: Integer; uFlags: UINT): Boolean;
    // �������
    procedure SetFocusEle(hFocusEle: HELE);
    function GetFocusEle: HELE;
    function GetStayEle: HELE;
    procedure SetCaptureEle(hEle: HELE);
    function GetCaptureEle: HELE;
    // ������
    procedure SetCursor(hCursor: HCURSOR);
    function GetCursor: HCURSOR;
    procedure SetCursorSys(hCursor: HCURSOR);
    // ���ƿ���
    procedure DrawWindow(hDraw: HDRAW);
    procedure GetDrawRect(var pRcPaint: TRect);
    procedure GetClientRect(var pRect: TRect);
    procedure GetBodyRect(var pRect: TRect);
    procedure GetLayoutRect(var pRect: TRect);
    procedure GetRect(var pRect: TRect);
    procedure SetRect(var pRect: TRect);
    // 
    procedure CreateCaret(hEle: HELE; x, y, width, height: Integer);
    procedure SetCaretPos(x, y, width, height: Integer; bUpdate: Boolean = True);
    procedure SetCaretColor(color: Integer);
    procedure ShowCaret(bShow: Boolean = True);
    function GetCaretHELE: HELE;
    function GetCaretInfo(var pX, pY, pWidth, pHeight: Integer): HELE;
    procedure DestroyCaret;
    function RegEvent(nEvent: Integer; pFun: Pointer): Boolean;
    function RemoveEvent(nEvent: Integer; pFun: Pointer): Boolean;
    // ����ת��
    function GetCursorPos(var pt: TPoint): Boolean;
    function ClientToScreen(var pt: TPoint): Boolean;
    function ScreenToClient(var pt: TPoint): Boolean;
    procedure RectToDPI(var pRect: TRect);
    procedure PointToDPI(var pt: TPoint);

    procedure EnableDragBorder(bEnable: Boolean = True);
    procedure EnableDragWindow(bEnable: Boolean = True);
    procedure EnableDragCaption(bEnable: Boolean = True);
    procedure EnableDrawBk(bEnable: Boolean = True);
    procedure EnableAutoFocus(bEnable: Boolean = True);
    procedure EnableMaxWindow(bEnable: Boolean = True);
    procedure EnableLimitWindowSize(bEnable: Boolean = True);
    procedure EnableDragFiles(bEnable: Boolean = True);
    procedure EnableLayout(bEnable: Boolean = True);
    procedure EnableLayoutOverlayBorder(bEnable: Boolean = True);
    procedure ShowLayoutFrame(bEnable: Boolean = True);
    function IsEnableLayout: Boolean;
    function IsMaxWindow: Boolean;
    function IsDragBorder: Boolean;
    function IsDragWindow: Boolean;
    function IsDragCaption: Boolean;
    // �ı�������
    procedure SetFont(hFontx: HFONTX);
    procedure SetTextColor(color: Integer);
    function GetTextColor: Integer;
    function GetTextColorEx: Integer;
    // ���ڱ�ʶ
    procedure SetID(nID: Integer);
    function GetID: Integer;
    procedure SetName(pName: PWideChar);
    function GetName: PWideChar;
    // �߿�ͱ߾�
    procedure SetBorderSize(left, top, right, bottom: Integer);
    procedure GetBorderSize(var pBorder: TborderSize_);
    procedure SetPadding(left, top, right, bottom: Integer);
    procedure SetDragBorderSize(left, top, right, bottom: Integer);
    procedure GetDragBorderSize(var pSize: TborderSize_);
    procedure SetCaptionMargin(left, top, right, bottom: Integer);
    procedure SetMinimumSize(width, height: Integer);
    // DPI����
    procedure SetDPI(nDPI: Integer);
    function GetDPI: Integer;
    // ����������
    procedure SetIcon(hImage: HIMAGE);
    procedure SetTitle(pTitle: PWideChar);
    procedure SetTitleColor(color: Integer);
    function GetButton(nFlag: Integer): HELE;
    function GetIcon: HIMAGE;
    function GetTitle: PWideChar;
    function GetTitleColor: Integer;
    // ���ֿ���
    procedure AdjustLayout;
    procedure AdjustLayoutEx(nFlags: Integer);
    // ��ʱ��
    function SetTimer(nIDEvent, uElapse: UINT): UINT;
    function KillTimer(nIDEvent: UINT): Boolean;
    function SetXCTimer(nIDEvent, uElapse: UINT): Integer;
    function KillXCTimer(nIDEvent: UINT): Boolean;
    // ��������
    procedure AddBkBorder(nState: Integer; color: Integer; width: Integer);
    procedure AddBkFill(nState: Integer; color: Integer);
    procedure AddBkImage(nState: Integer; hImage: HIMAGE);
    function SetBkInfo(pText: PWideChar): Integer;
    function GetBkInfoCount: Integer;
    procedure ClearBkInfo;
    function GetBkManager: HBKM;
    function GetBkManagerEx: HBKM;
    procedure SetBkMagager(hBkInfoM: HBKM);
    // ͸�����ڿ���
    procedure SetTransparentType(nType: window_transparent_);
    procedure SetTransparentAlpha(alpha: Byte);
    procedure SetTransparentColor(color: Integer);
    function GetTransparentType: window_transparent_;
    // ��Ӱ����
    procedure SetShadowInfo(nSize, nDepth, nAngeleSize: Integer; bRightAngle: Boolean; color: Integer);
    procedure GetShadowInfo(var pnSize, pnDepth, pnAngeleSize: Integer; var pbRightAngle: BOOL; var pColor: Integer);
  end;

implementation
{ TXForm }

constructor TXForm.Create(x, y, cx, cy: Integer; pTitle: PWideChar; hWndParent: HWND; XCStyle: Integer);
begin
  inherited Create;
  Handle := XWnd_Create(x, y, cx, cy, pTitle, hWndParent, XCStyle);
end;

constructor TXForm.CreateEx(dwExStyle, dwStyle: DWORD; lpClassName: PWideChar; x, y, cx, cy: Integer; pTitle: PWideChar; hWndParent: HWND; XCStyle: Integer);
begin
  inherited Create;
  Handle := XWnd_CreateEx(dwExStyle, dwStyle, lpClassName, x, y, cx, cy, pTitle, hWndParent, XCStyle);
end;

procedure TXForm.Init;
begin
  inherited;
  RegEvent(WM_DESTROY, @OnDESTROY);
end;

class function TXForm.FormHandle(Handle: Integer): Pointer;
begin
  Result := GetObjectFromHandle(Handle);
end;

class function TXForm.OnDESTROY(hWnd: Integer; pbHandled: PBoolean): Integer; stdcall;
begin
  Result := 0;
  TXForm(GetClassFormHandle(hWnd)).Free;
end;

function TXForm.Attach(hWnd: hWnd; XCStyle: Integer): Boolean;
begin
  Handle := XWnd_Attach(hWnd, XCStyle);
  Result := Handle <> 0;
end;
// �Ӷ������

function TXForm.AddChild(hChild: HXCGUI): Boolean;
begin
  Result := (Handle <> 0) and XWnd_AddChild(Handle, hChild);
end;

function TXForm.InsertChild(hChild: HXCGUI; index: Integer): Boolean;
begin
  Result := (Handle <> 0) and XWnd_InsertChild(Handle, hChild, index);
end;

function TXForm.GetChildCount: Integer;
begin
  Result := XWnd_GetChildCount(Handle)
end;

function TXForm.GetChildByIndex(index: Integer): HXCGUI;
begin
  Result := XWnd_GetChildByIndex(Handle, index)
end;

function TXForm.GetChildByID(nID: Integer): HXCGUI;
begin
  Result := XWnd_GetChildByID(Handle, nID)
end;

function TXForm.GetChild(nID: Integer): HXCGUI;
begin
  Result := XWnd_GetChild(Handle, nID)
end;

function TXForm.HitChildEle(var pt: TPoint): hEle;
begin
  Result := XWnd_HitChildEle(Handle, pt)
end;
// ���ڲ���

procedure TXForm.Redraw(bUpdate: Boolean);
begin
  XWnd_Redraw(Handle, bUpdate);
end;

procedure TXForm.RedrawRect(var pRect: TRect; bUpdate: Boolean);
begin
  XWnd_RedrawRect(Handle, pRect, bUpdate);
end;

function TXForm.RegEvent(nEvent: Integer; pFun: Pointer): Boolean;
begin
  Result := XWnd_RegEvent(Handle, nEvent, pFun);
end;

function TXForm.RemoveEvent(nEvent: Integer; pFun: Pointer): Boolean;
begin
  Result := XWnd_RemoveEvent(Handle, nEvent, pFun);
end;

procedure TXForm.Center;
begin
  XWnd_Center(Handle);
end;

procedure TXForm.CenterEx(width, height: Integer);
begin
  XWnd_CenterEx(Handle, width, height);
end;

procedure TXForm.CloseWindow;
begin
  XWnd_CloseWindow(Handle);
end;

procedure TXForm.Show(bShow: Boolean);
begin
  XWnd_Show(Handle, bShow);
end;

function TXForm.ShowWindow(nCmdShow: Integer): Boolean;
begin
  Result := XWnd_ShowWindow(Handle, nCmdShow)
end;

procedure TXForm.SetPosition(x, y: Integer);
begin
  XWnd_SetPosition(Handle, x, y);
end;

procedure TXForm.SetTop;
begin
  XWnd_SetTop(Handle);
end;

procedure TXForm.MaxWindow(bMaximize: Boolean);
begin
  XWnd_MaxWindow(Handle, bMaximize);
end;

function TXForm.SetWindowPos(hWndInsertAfter: hWnd; X, Y, cx, cy: Integer; uFlags: UINT): Boolean;
begin
  Result := XWnd_SetWindowPos(Handle, hWndInsertAfter, X, Y, cx, cy, uFlags)
end;
// �������

procedure TXForm.SetFocusEle(hFocusEle: hEle);
begin
  XWnd_SetFocusEle(Handle, hFocusEle);
end;

function TXForm.GetFocusEle: hEle;
begin
  Result := XWnd_GetFocusEle(Handle)
end;

function TXForm.GetStayEle: hEle;
begin
  Result := XWnd_GetStayEle(Handle)
end;

procedure TXForm.SetCaptureEle(hEle: hEle);
begin
  XWnd_SetCaptureEle(Handle, hEle);
end;

function TXForm.GetCaptureEle: hEle;
begin
  Result := XWnd_GetCaptureEle(Handle)
end;
// ������

procedure TXForm.SetCursor(hCursor: hCursor);
begin
  XWnd_SetCursor(Handle, hCursor);
end;

function TXForm.GetCursor: hCursor;
begin
  Result := XWnd_GetCursor(Handle)
end;

procedure TXForm.SetCursorSys(hCursor: hCursor);
begin
  XWnd_SetCursorSys(Handle, hCursor);
end;
// ���ƿ���

procedure TXForm.DrawWindow(hDraw: hDraw);
begin
  XWnd_DrawWindow(Handle, hDraw);
end;

procedure TXForm.GetDrawRect(var pRcPaint: TRect);
begin
  XWnd_GetDrawRect(Handle, pRcPaint);
end;

procedure TXForm.GetClientRect(var pRect: TRect);
begin
  XWnd_GetClientRect(Handle, pRect);
end;

procedure TXForm.GetBodyRect(var pRect: TRect);
begin
  XWnd_GetBodyRect(Handle, pRect);
end;

procedure TXForm.GetLayoutRect(var pRect: TRect);
begin
  XWnd_GetLayoutRect(Handle, pRect);
end;

procedure TXForm.GetRect(var pRect: TRect);
begin
  XWnd_GetRect(Handle, pRect);
end;

procedure TXForm.SetRect(var pRect: TRect);
begin
  XWnd_SetRect(Handle, pRect);
end;
// 

procedure TXForm.CreateCaret(hEle: hEle; x, y, width, height: Integer);
begin
  XWnd_CreateCaret(Handle, hEle, x, y, width, height);
end;

procedure TXForm.SetCaretPos(x, y, width, height: Integer; bUpdate: Boolean);
begin
  XWnd_SetCaretPos(Handle, x, y, width, height, bUpdate);
end;

procedure TXForm.SetCaretColor(color: Integer);
begin
  XWnd_SetCaretColor(Handle, color);
end;

procedure TXForm.ShowCaret(bShow: Boolean);
begin
  XWnd_ShowCaret(Handle, bShow);
end;

function TXForm.GetCaretHELE: hEle;
begin
  Result := XWnd_GetCaretHELE(Handle)
end;

function TXForm.GetCaretInfo(var pX, pY, pWidth, pHeight: Integer): hEle;
begin
  Result := XWnd_GetCaretInfo(Handle, pX, pY, pWidth, pHeight)
end;

procedure TXForm.DestroyCaret;
begin
  XWnd_DestroyCaret(Handle);
end;
// ����ת��

function TXForm.GetCursorPos(var pt: TPoint): Boolean;
begin
  Result := XWnd_GetCursorPos(Handle, pt)
end;

function TXForm.ClientToScreen(var pt: TPoint): Boolean;
begin
  Result := XWnd_ClientToScreen(Handle, pt)
end;

function TXForm.ScreenToClient(var pt: TPoint): Boolean;
begin
  Result := XWnd_ScreenToClient(Handle, pt)
end;

procedure TXForm.RectToDPI(var pRect: TRect);
begin
  XWnd_RectToDPI(Handle, pRect);
end;

procedure TXForm.PointToDPI(var pt: TPoint);
begin
  XWnd_PointToDPI(Handle, pt);
end;
// 


procedure TXForm.EnableDragBorder(bEnable: Boolean);
begin
  XWnd_EnableDragBorder(Handle, bEnable);
end;

procedure TXForm.EnableDragWindow(bEnable: Boolean);
begin
  XWnd_EnableDragWindow(Handle, bEnable);
end;

procedure TXForm.EnableDragCaption(bEnable: Boolean);
begin
  XWnd_EnableDragCaption(Handle, bEnable);
end;

procedure TXForm.EnableDrawBk(bEnable: Boolean);
begin
  XWnd_EnableDrawBk(Handle, bEnable);
end;

procedure TXForm.EnableAutoFocus(bEnable: Boolean);
begin
  XWnd_EnableAutoFocus(Handle, bEnable);
end;

procedure TXForm.EnableMaxWindow(bEnable: Boolean);
begin
  XWnd_EnableMaxWindow(Handle, bEnable);
end;

procedure TXForm.EnableLimitWindowSize(bEnable: Boolean);
begin
  XWnd_EnableLimitWindowSize(Handle, bEnable);
end;

procedure TXForm.EnableDragFiles(bEnable: Boolean);
begin
  XWnd_EnableDragFiles(Handle, bEnable);
end;

procedure TXForm.EnableLayout(bEnable: Boolean);
begin
  XWnd_EnableLayout(Handle, bEnable);
end;

procedure TXForm.EnableLayoutOverlayBorder(bEnable: Boolean);
begin
  XWnd_EnableLayoutOverlayBorder(Handle, bEnable);
end;

procedure TXForm.ShowLayoutFrame(bEnable: Boolean);
begin
  XWnd_ShowLayoutFrame(Handle, bEnable);
end;

function TXForm.IsEnableLayout: Boolean;
begin
  Result := XWnd_IsEnableLayout(Handle)
end;

function TXForm.IsMaxWindow: Boolean;
begin
  Result := XWnd_IsMaxWindow(Handle)
end;

function TXForm.IsDragBorder: Boolean;
begin
  Result := XWnd_IsDragBorder(Handle)
end;

function TXForm.IsDragWindow: Boolean;
begin
  Result := XWnd_IsDragWindow(Handle)
end;

function TXForm.IsDragCaption: Boolean;
begin
  Result := XWnd_IsDragCaption(Handle)
end;
// �ı�������

procedure TXForm.SetFont(hFontx: hFontx);
begin
  XWnd_SetFont(Handle, hFontx);
end;

procedure TXForm.SetTextColor(color: Integer);
begin
  XWnd_SetTextColor(Handle, color);
end;

function TXForm.GetTextColor: Integer;
begin
  Result := XWnd_GetTextColor(Handle)
end;

function TXForm.GetTextColorEx: Integer;
begin
  Result := XWnd_GetTextColorEx(Handle)
end;
// ���ڱ�ʶ

procedure TXForm.SetID(nID: Integer);
begin
  XWnd_SetID(Handle, nID);
end;

function TXForm.GetID: Integer;
begin
  Result := XWnd_GetID(Handle)
end;

procedure TXForm.SetName(pName: PWideChar);
begin
  XWnd_SetName(Handle, pName);
end;

function TXForm.GetName: PWideChar;
begin
  Result := XWnd_GetName(Handle)
end;
// �߿�ͱ߾�

procedure TXForm.SetBorderSize(left, top, right, bottom: Integer);
begin
  XWnd_SetBorderSize(Handle, left, top, right, bottom);
end;

procedure TXForm.GetBorderSize(var pBorder: TborderSize_);
begin
  XWnd_GetBorderSize(Handle, pBorder);
end;

procedure TXForm.SetPadding(left, top, right, bottom: Integer);
begin
  XWnd_SetPadding(Handle, left, top, right, bottom);
end;

procedure TXForm.SetDragBorderSize(left, top, right, bottom: Integer);
begin
  XWnd_SetDragBorderSize(Handle, left, top, right, bottom);
end;

procedure TXForm.GetDragBorderSize(var pSize: TborderSize_);
begin
  XWnd_GetDragBorderSize(Handle, pSize);
end;

procedure TXForm.SetCaptionMargin(left, top, right, bottom: Integer);
begin
  XWnd_SetCaptionMargin(Handle, left, top, right, bottom);
end;

procedure TXForm.SetMinimumSize(width, height: Integer);
begin
  XWnd_SetMinimumSize(Handle, width, height);
end;
// DPI����

procedure TXForm.SetDPI(nDPI: Integer);
begin
  XWnd_SetDPI(Handle, nDPI);
end;

function TXForm.GetDPI: Integer;
begin
  Result := XWnd_GetDPI(Handle)
end;
// ����������

procedure TXForm.SetIcon(hImage: hImage);
begin
  XWnd_SetIcon(Handle, hImage);
end;

procedure TXForm.SetTitle(pTitle: PWideChar);
begin
  XWnd_SetTitle(Handle, pTitle);
end;

procedure TXForm.SetTitleColor(color: Integer);
begin
  XWnd_SetTitleColor(Handle, color);
end;

function TXForm.GetButton(nFlag: Integer): hEle;
begin
  Result := XWnd_GetButton(Handle, nFlag)
end;

function TXForm.GetIcon: hImage;
begin
  Result := XWnd_GetIcon(Handle)
end;

function TXForm.GetTitle: PWideChar;
begin
  Result := XWnd_GetTitle(Handle)
end;

function TXForm.GetTitleColor: Integer;
begin
  Result := XWnd_GetTitleColor(Handle)
end;
// ���ֿ���

procedure TXForm.AdjustLayout;
begin
  XWnd_AdjustLayout(Handle);
end;

procedure TXForm.AdjustLayoutEx(nFlags: Integer);
begin
  XWnd_AdjustLayoutEx(Handle, nFlags);
end;
// ��ʱ��

function TXForm.SetTimer(nIDEvent, uElapse: UINT): UINT;
begin
  Result := XWnd_SetTimer(Handle, nIDEvent, uElapse)
end;

function TXForm.KillTimer(nIDEvent: UINT): Boolean;
begin
  Result := XWnd_KillTimer(Handle, nIDEvent)
end;

function TXForm.SetXCTimer(nIDEvent, uElapse: UINT): Integer;
begin
  Result := XWnd_SetXCTimer(Handle, nIDEvent, uElapse);
end;

function TXForm.KillXCTimer(nIDEvent: UINT): Boolean;
begin
  Result := XWnd_KillXCTimer(Handle, nIDEvent)
end;
// ��������

procedure TXForm.AddBkBorder(nState: Integer; color: Integer; width: Integer);
begin
  XWnd_AddBkBorder(Handle, nState, color, width);
end;

procedure TXForm.AddBkFill(nState: Integer; color: Integer);
begin
  XWnd_AddBkFill(Handle, nState, color);
end;

procedure TXForm.AddBkImage(nState: Integer; hImage: hImage);
begin
  XWnd_AddBkImage(Handle, nState, hImage);
end;

function TXForm.SetBkInfo(pText: PWideChar): Integer;
begin
  Result := XWnd_SetBkInfo(Handle, pText);
end;

function TXForm.GetBkInfoCount: Integer;
begin
  Result := XWnd_GetBkInfoCount(Handle)
end;

procedure TXForm.ClearBkInfo;
begin
  XWnd_ClearBkInfo(Handle);
end;

function TXForm.GetBkManager: HBKM;
begin
  Result := XWnd_GetBkManager(Handle)
end;

function TXForm.GetBkManagerEx: HBKM;
begin
  Result := XWnd_GetBkManagerEx(Handle)
end;

procedure TXForm.SetBkMagager(hBkInfoM: HBKM);
begin
  XWnd_SetBkMagager(Handle, hBkInfoM);
end;
// ͸�����ڿ���

procedure TXForm.SetTransparentType(nType: window_transparent_);
begin
  XWnd_SetTransparentType(Handle, nType);
end;

procedure TXForm.SetTransparentAlpha(alpha: Byte);
begin
  XWnd_SetTransparentAlpha(Handle, alpha);
end;

procedure TXForm.SetTransparentColor(color: Integer);
begin
  XWnd_SetTransparentColor(Handle, color);
end;

function TXForm.GetTransparentType: window_transparent_;
begin
  Result := XWnd_GetTransparentType(Handle);
end;
// ��Ӱ����

procedure TXForm.SetShadowInfo(nSize, nDepth, nAngeleSize: Integer; bRightAngle: Boolean; color: Integer);
begin
  XWnd_SetShadowInfo(Handle, nSize, nDepth, nAngeleSize, bRightAngle, color);
end;

procedure TXForm.GetShadowInfo(var pnSize, pnDepth, pnAngeleSize: Integer; var pbRightAngle: BOOL; var pColor: Integer);
begin
  XWnd_GetShadowInfo(Handle, pnSize, pnDepth, pnAngeleSize, pbRightAngle, pColor);
end;

end.

