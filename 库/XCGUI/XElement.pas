unit XElement;

interface

uses
  Windows, SysUtils, System.Types, XCGUI, XWidget;

type
  TXEle = class(TXWidget)
  private
  protected
    class function OnDESTROY(hEle: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); virtual;
    procedure Init; override;
  public
    class function FromXmlName(const Name: string): Pointer; virtual;
    class function FromXmlID(const hWindow: Integer; const ID: Integer): Pointer; virtual;
    class function FromHandle(const Handle: Integer): Pointer; virtual;
    constructor Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: TXWidget); overload;
    destructor Destroy; override;
    function GetObjectHandleByName(const Name: string): Integer;
    function GetWidth: Integer;
    procedure SetWidth(const Value: Integer);
    function GetHeight: Integer;
    procedure SetHeight(const Value: Integer);
    function GetTextColor: Integer;
    procedure SetTextColor(const Value: Integer);
    function GetFocusBorderColor: Integer;
    procedure SetFocusBorderColor(const Value: Integer);
    function GetAlpha: BYTE;
    procedure SetAlpha(const Value: BYTE);
    function GetUserData: vint;
    procedure SetUserData(const Value: vint);
    procedure GetPadding(out pPadding: TpaddingSize_);
    function RegEvent(nEvent: Integer; pFun: Pointer): Boolean;
    function RemoveEvent(nEvent: Integer; pFun: Pointer): Boolean;
    function SendEvent(nEvent: Integer; wParam: WPARAM; lParam: LPARAM): Integer;
    function PostEvent(nEvent: Integer; wParam: WPARAM; lParam: LPARAM): Boolean;
    procedure GetRect(out XRect: TRect);
    procedure GetRectLogic(out XRect: TRect);
    procedure GetClientRect(out XRect: TRect);
    procedure RectWndClientToEleClient(var XRect: TRect);
    procedure PointWndClientToEleClient(var pPt: TPoint);
    procedure RectClientToWndClient(var XRect: TRect);
    procedure RectClientToWndClientDPI(var XRect: TRect);
    procedure PointClientToWndClient(var pPt: TPoint);
    procedure PointClientToWndClientDPI(var pPt: TPoint);
    procedure GetWndClientRect(out XRect: TRect);
    procedure GetWndClientRectDPI(out XRect: TRect);
    function GetCursor: HCURSOR;
    procedure SetCursor(hCursor: HCURSOR);
    function AddChild(hChild: HXCGUI): Boolean;
    function InsertChild(hChild: HXCGUI; index: Integer): Boolean;
    function SetRect(XRect: TRect; bRedraw: Boolean; nFlags: Integer; nAdjustNo: UINT): Integer;
    function SetRectEx(x, y, cx, cy: Integer; bRedraw: Boolean; nFlags: Integer; nAdjustNo: UINT): Integer;
    function SetRectLogic(XRect: TRect; bRedraw: Boolean; nFlags: Integer; nAdjustNo: UINT): Integer;
    function SetPosition(x, y: Integer; bRedraw: Boolean; nFlags: Integer; nAdjustNo: UINT): Integer;
    function SetPositionLogic(x, y: Integer; bRedraw: Boolean; nFlags: Integer; nAdjustNo: UINT): Integer;
    procedure GetPosition(out pOutX, pOutY: Integer);
    function SetSize(nWidth, nHeight: Integer; bRedraw: Boolean; nFlags: Integer; nAdjustNo: UINT): Integer;
    procedure GetSize(out pOutWidth, pOutHeight: Integer);
    function IsDrawFocus: Boolean;
    function IsEnable: Boolean;
    function IsEnableFocus: Boolean;
    function IsMouseThrough: Boolean;
    function HitChildEle(pPt: TPoint): HELE;
    function IsBkTransparent: Boolean;
    function IsEnableEvent_XE_PAINT_END: Boolean;
    function IsKeyTab: Boolean;
    function IsSwitchFocus: Boolean;
    function IsEnable_XE_MOUSEWHEEL: Boolean;
    function IsChildEle(hChildEle: HELE): Boolean;
    function IsEnableCanvas: Boolean;
    function IsFocus: Boolean;
    function IsFocusEx: Boolean;
    procedure Enable(bEnable: Boolean);
    procedure EnableFocus(bEnable: Boolean);
    procedure EnableDrawFocus(bEnable: Boolean);
    procedure EnableDrawBorder(bEnable: Boolean);
    procedure EnableCanvas(bEnable: Boolean);
    procedure EnableEvent_XE_PAINT_END(bEnable: Boolean);
    procedure EnableBkTransparent(bEnable: Boolean);
    procedure EnableMouseThrough(bEnable: Boolean);
    procedure EnableKeyTab(bEnable: Boolean);
    procedure EnableSwitchFocus(bEnable: Boolean);
    procedure EnableEvent_XE_MOUSEWHEEL(bEnable: Boolean);
    procedure Remove;
    function SetZOrder(index: Integer): Boolean;
    function SetZOrderEx(hDestEle: HELE; nType: zorder_): Boolean;
    function GetZOrder: Integer;
    procedure EnableTopmost(bTopmost: Boolean);
    procedure Redraw(bImmediate: Boolean = false);
    procedure RedrawRect(XRect: TRect; bImmediate: Boolean);
    function GetChildCount: Integer;
    function GetChildByIndex(index: Integer): HXCGUI;
    function GetChildByID(nID: Integer): HXCGUI;
    procedure SetBorderSize(left, top, right, bottom: Integer);
    procedure GetBorderSize(out Border: TborderSize_);
    procedure SetPadding(left, top, right, bottom: Integer);
    procedure SetDragBorder(nFlags: Integer);
    procedure SetDragBorderBindEle(nFlags: Integer; hBindEle: HELE; nSpace: Integer);
    procedure SetMinSize(nWidth, nHeight: Integer);
    procedure SetMaxSize(nWidth, nHeight: Integer);
    procedure SetLockScroll(bHorizon, bVertical: Boolean);
    function GetTextColorEx: Integer;
    procedure SetFont(hFontx: HFONTX);
    function GetFont: HFONTX;
    function GetFontEx: HFONTX;
    procedure DestroyEle;
    function GetBkManager: HBKM;
    function GetBkManagerEx: HBKM;
    procedure SetBkManager(hBkInfoM: HBKM);
    function GetStateFlags: Integer;
    function DrawFocus(hDraw: HDRAW; XRect: TRect): Boolean;
    procedure DrawEle(hDraw: HDRAW);
    procedure GetContentSize(bHorizon: Boolean; cx, cy: Integer; out pSize: TSize);
    procedure SetCapture(b: Boolean);
    procedure EnableTransparentChannel(bEnable: Boolean);
    function SetXCTimer(nIDEvent, uElapse: UINT): Boolean;
    function KillXCTimer(nIDEvent: UINT): Boolean;
    procedure SetToolTip(pText: PWideChar);
    procedure SetToolTipEx(pText: PWideChar; nTextAlign: Integer);
    function GetToolTip: PWideChar;
    procedure PopupToolTip(x, y: Integer);
    procedure AdjustLayout(nAdjustNo: UINT);
    procedure AdjustLayoutEx(nFlags: Integer; nAdjustNo: UINT);
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property TextColor: Integer read GetTextColor write SetTextColor;
    property FocusBorderColor: Integer read GetFocusBorderColor write SetFocusBorderColor;
    property Alpha: BYTE read GetAlpha write SetAlpha;
    property UserData: vint read GetUserData write SetUserData;
  end;

implementation

constructor TXEle.Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: TXWidget);
begin
  inherited Create;
  CreateHandle(x, y, cx, cy, hParent);
end;

procedure TXEle.CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  Handle := XEle_Create(x, y, cx, cy, hParent.Handle);
  Init;
end;

destructor TXEle.Destroy;
begin
  if IsHELE then
    XEle_Destroy(Handle);
  inherited;
end;

class function TXEle.FromHandle(const Handle: Integer): Pointer;
begin
  Result := GetObjectFromHandle(Handle);
end;

class function TXEle.FromXmlID(const hWindow, ID: Integer): Pointer;
begin
  Result := GetObjectFromXmlID(hWindow, ID);
end;

class function TXEle.FromXmlName(const Name: string): Pointer;
begin
  Result := GetObjectFromXmlName(Name);
end;

function TXEle.RegEvent(nEvent: Integer; pFun: Pointer): Boolean;
begin
  Result := XEle_RegEvent(Handle, nEvent, pFun);
end;

function TXEle.RemoveEvent(nEvent: Integer; pFun: Pointer): Boolean;
begin
  Result := XEle_RemoveEvent(Handle, nEvent, pFun);
end;

function TXEle.SendEvent(nEvent: Integer; wParam: wParam; lParam: lParam): Integer;
begin
  Result := XEle_SendEvent(Handle, nEvent, wParam, lParam);
end;

function TXEle.PostEvent(nEvent: Integer; wParam: wParam; lParam: lParam): Boolean;
begin
  Result := XEle_PostEvent(Handle, nEvent, wParam, lParam);
end;

procedure TXEle.GetRect(out XRect: TRect);
begin
  XEle_GetRect(Handle, XRect);
end;

procedure TXEle.GetRectLogic(out XRect: TRect);
begin
  XEle_GetRectLogic(Handle, XRect);
end;

procedure TXEle.GetClientRect(out XRect: TRect);
begin
  XEle_GetClientRect(Handle, XRect);
end;

procedure TXEle.SetWidth(const Value: Integer);
begin
  XEle_SetWidth(Handle, Value);
end;

procedure TXEle.SetHeight(const Value: Integer);
begin
  XEle_SetHeight(Handle, Value);
end;

function TXEle.GetWidth: Integer;
begin
   Result := XEle_GetWidth(Handle);
end;

function TXEle.GetHeight: Integer;
begin
  Result := XEle_GetHeight(Handle);
end;

function TXEle.GetObjectHandleByName(const Name: string): Integer;
begin
  Result := XC_GetObjectByName(PChar(Name));
end;

procedure TXEle.RectWndClientToEleClient(var XRect: TRect);
begin
  XEle_RectWndClientToEleClient(Handle, XRect);
end;

procedure TXEle.PointWndClientToEleClient(var pPt: TPoint);
begin
  XEle_PointWndClientToEleClient(Handle, pPt);
end;

procedure TXEle.RectClientToWndClient(var xRect: TRect);
begin
  XEle_RectClientToWndClient(Handle, xRect);
end;

procedure TXEle.RectClientToWndClientDPI(var xRect: TRect);
begin
  XEle_RectClientToWndClientDPI(Handle, xRect);
end;

procedure TXEle.PointClientToWndClient(var pPt: TPoint);
begin
  XEle_PointClientToWndClient(Handle, pPt);
end;

procedure TXEle.PointClientToWndClientDPI(var pPt: TPoint);
begin
  XEle_PointClientToWndClientDPI(Handle, pPt);
end;

procedure TXEle.GetWndClientRect(out XRect: TRect);
begin
  XEle_GetWndClientRect(Handle, XRect);
end;

procedure TXEle.GetWndClientRectDPI(out XRect: TRect);
begin
  XEle_GetWndClientRectDPI(Handle, XRect);
end;

function TXEle.GetCursor: HCURSOR;
begin
  Result := XEle_GetCursor(Handle);
end;

procedure TXEle.SetCursor(hCursor: hCursor);
begin
  XEle_SetCursor(Handle, hCursor);
end;

function TXEle.AddChild(hChild: HXCGUI): Boolean;
begin
  Result := XEle_AddChild(Handle, hChild);
end;

function TXEle.InsertChild(hChild: HXCGUI; index: Integer): Boolean;
begin
  Result := XEle_InsertChild(Handle, hChild, index);
end;

function TXEle.SetRect(XRect: TRect; bRedraw: Boolean; nFlags: Integer; nAdjustNo: UINT): Integer;
begin
  Result := XEle_SetRect(Handle, XRect, bRedraw, nFlags, nAdjustNo);
end;

function TXEle.SetRectEx(x, y, cx, cy: Integer; bRedraw: Boolean; nFlags: Integer; nAdjustNo: UINT): Integer;
begin
  Result := XEle_SetRectEx(Handle, x, y, cx, cy, bRedraw, nFlags, nAdjustNo);
end;

function TXEle.SetRectLogic(XRect: TRect; bRedraw: Boolean; nFlags: Integer; nAdjustNo: UINT): Integer;
begin
  Result := XEle_SetRectLogic(Handle, XRect, bRedraw, nFlags, nAdjustNo);
end;

function TXEle.SetPosition(x, y: Integer; bRedraw: Boolean; nFlags: Integer; nAdjustNo: UINT): Integer;
begin
  Result := XEle_SetPosition(Handle, x, y, bRedraw, nFlags, nAdjustNo);
end;

function TXEle.SetPositionLogic(x, y: Integer; bRedraw: Boolean; nFlags: Integer; nAdjustNo: UINT): Integer;
begin
  Result := XEle_SetPositionLogic(Handle, x, y, bRedraw, nFlags, nAdjustNo);
end;

procedure TXEle.GetPosition(out pOutX, pOutY: Integer);
begin
  XEle_GetPosition(Handle, @pOutX, @pOutY);
end;

function TXEle.SetSize(nWidth, nHeight: Integer; bRedraw: Boolean; nFlags: Integer; nAdjustNo: UINT): Integer;
begin
  Result := XEle_SetSize(Handle, nWidth, nHeight, bRedraw, nFlags, nAdjustNo);
end;

procedure TXEle.GetSize(out pOutWidth, pOutHeight: Integer);
begin
  XEle_GetSize(Handle, pOutWidth, pOutHeight);
end;

function TXEle.IsDrawFocus: Boolean;
begin
  Result := XEle_IsDrawFocus(Handle);
end;

function TXEle.IsEnable: Boolean;
begin
  Result := XEle_IsEnable(Handle);
end;

function TXEle.IsEnableFocus: Boolean;
begin
  Result := XEle_IsEnableFocus(Handle);
end;

function TXEle.IsMouseThrough: Boolean;
begin
  Result := XEle_IsMouseThrough(Handle);
end;

function TXEle.HitChildEle(pPt: TPoint): HELE;
begin
  Result := XEle_HitChildEle(Handle, pPt);
end;

function TXEle.IsBkTransparent: Boolean;
begin
  Result := XEle_IsBkTransparent(Handle);
end;

function TXEle.IsEnableEvent_XE_PAINT_END: Boolean;
begin
  Result := XEle_IsEnableEvent_XE_PAINT_END(Handle);
end;

function TXEle.IsKeyTab: Boolean;
begin
  Result := XEle_IsKeyTab(Handle);
end;

function TXEle.IsSwitchFocus: Boolean;
begin
  Result := XEle_IsSwitchFocus(Handle);
end;

function TXEle.IsEnable_XE_MOUSEWHEEL: Boolean;
begin
  Result := XEle_IsEnable_XE_MOUSEWHEEL(Handle);
end;

function TXEle.IsChildEle(hChildEle: HELE): Boolean;
begin
  Result := XEle_IsChildEle(Handle, hChildEle);
end;

function TXEle.IsEnableCanvas: Boolean;
begin
  Result := XEle_IsEnableCanvas(Handle);
end;

function TXEle.IsFocus: Boolean;
begin
  Result := XEle_IsFocus(Handle);
end;

function TXEle.IsFocusEx: Boolean;
begin
  Result := XEle_IsFocusEx(Handle);
end;

procedure TXEle.Enable(bEnable: Boolean);
begin
  XEle_Enable(Handle, bEnable);
end;

procedure TXEle.EnableFocus(bEnable: Boolean);
begin
  XEle_EnableFocus(Handle, bEnable);
end;

procedure TXEle.EnableDrawFocus(bEnable: Boolean);
begin
  XEle_EnableDrawFocus(Handle, bEnable);
end;

procedure TXEle.EnableDrawBorder(bEnable: Boolean);
begin
  XEle_EnableDrawBorder(Handle, bEnable);
end;

procedure TXEle.EnableCanvas(bEnable: Boolean);
begin
  XEle_EnableCanvas(Handle, bEnable);
end;

procedure TXEle.EnableEvent_XE_PAINT_END(bEnable: Boolean);
begin
  XEle_EnableEvent_XE_PAINT_END(Handle, bEnable);
end;

procedure TXEle.EnableBkTransparent(bEnable: Boolean);
begin
  XEle_EnableBkTransparent(Handle, bEnable);
end;

procedure TXEle.EnableMouseThrough(bEnable: Boolean);
begin
  XEle_EnableMouseThrough(Handle, bEnable);
end;

procedure TXEle.EnableKeyTab(bEnable: Boolean);
begin
  XEle_EnableKeyTab(Handle, bEnable);
end;

procedure TXEle.EnableSwitchFocus(bEnable: Boolean);
begin
  XEle_EnableSwitchFocus(Handle, bEnable);
end;

procedure TXEle.EnableEvent_XE_MOUSEWHEEL(bEnable: Boolean);
begin
  XEle_EnableEvent_XE_MOUSEWHEEL(Handle, bEnable);
end;

procedure TXEle.Remove;
begin
  XEle_Remove(Handle);
end;

function TXEle.SetZOrder(index: Integer): Boolean;
begin
  Result := XEle_SetZOrder(Handle, index);
end;

function TXEle.SetZOrderEx(hDestEle: HELE; nType: zorder_): Boolean;
begin
  Result := XEle_SetZOrderEx(Handle, hDestEle, nType);
end;

function TXEle.GetZOrder: Integer;
begin
  Result := XEle_GetZOrder(Handle);
end;

procedure TXEle.EnableTopmost(bTopmost: Boolean);
begin
  XEle_EnableTopmost(Handle, bTopmost);
end;

procedure TXEle.Redraw(bImmediate: Boolean);
begin
  XEle_Redraw(Handle, bImmediate);
end;

procedure TXEle.RedrawRect(xRect: TRect; bImmediate: Boolean);
begin
  XEle_RedrawRect(Handle, xRect, bImmediate);
end;

function TXEle.GetChildCount: Integer;
begin
  Result := XEle_GetChildCount(Handle);
end;

function TXEle.GetChildByIndex(index: Integer): HXCGUI;
begin
  Result := XEle_GetChildByIndex(Handle, index);
end;

function TXEle.GetChildByID(nID: Integer): HXCGUI;
begin
  Result := XEle_GetChildByID(Handle, nID);
end;

procedure TXEle.SetBorderSize(left, top, right, bottom: Integer);
begin
  XEle_SetBorderSize(Handle, left, top, right, bottom);
end;

procedure TXEle.GetBorderSize(out Border: TborderSize_);
begin
  XEle_GetBorderSize(Handle, Border);
end;

procedure TXEle.SetPadding(left, top, right, bottom: Integer);
begin
  XEle_SetPadding(Handle, left, top, right, bottom);
end;

procedure TXEle.GetPadding(out pPadding: TpaddingSize_);
begin
  XEle_GetPadding(Handle, pPadding);
end;

procedure TXEle.SetDragBorder(nFlags: Integer);
begin
  XEle_SetDragBorder(Handle, nFlags);
end;

procedure TXEle.SetDragBorderBindEle(nFlags: Integer; hBindEle: HELE; nSpace: Integer);
begin
  XEle_SetDragBorderBindEle(Handle, nFlags, hBindEle, nSpace);
end;

procedure TXEle.SetMinSize(nWidth, nHeight: Integer);
begin
  XEle_SetMinSize(Handle, nWidth, nHeight);
end;

procedure TXEle.SetMaxSize(nWidth, nHeight: Integer);
begin
  XEle_SetMaxSize(Handle, nWidth, nHeight);
end;

procedure TXEle.SetLockScroll(bHorizon, bVertical: Boolean);
begin
  XEle_SetLockScroll(Handle, bHorizon, bVertical);
end;

procedure TXEle.SetTextColor(const Value: Integer);
begin
  XEle_SetTextColor(Handle, Value);
end;

function TXEle.GetTextColor: Integer;
begin
  Result := XEle_GetTextColor(Handle);
end;

function TXEle.GetTextColorEx: Integer;
begin
  Result := XEle_GetTextColorEx(Handle);
end;

procedure TXEle.SetFocusBorderColor(const Value: Integer);
begin
  XEle_SetFocusBorderColor(Handle, Value);
end;

function TXEle.GetFocusBorderColor: Integer;
begin
  Result := XEle_GetFocusBorderColor(Handle);
end;

procedure TXEle.SetFont(hFontx: hFontx);
begin
  XEle_SetFont(Handle, hFontx);
end;

function TXEle.GetFont: hFontx;
begin
  Result := XEle_GetFont(Handle);
end;

function TXEle.GetFontEx: hFontx;
begin
  Result := XEle_GetFontEx(Handle);
end;

procedure TXEle.SetAlpha(const Value: BYTE);
begin
  XEle_SetAlpha(Handle, Value);
end;

function TXEle.GetAlpha: BYTE;
begin
  Result := XEle_GetAlpha(Handle);
end;

procedure TXEle.DestroyEle;
begin
  XEle_Destroy(Handle);
end;

function TXEle.GetBkManager: HBKM;
begin
  Result := XEle_GetBkManager(Handle);
end;

function TXEle.GetBkManagerEx: HBKM;
begin
  Result := XEle_GetBkManagerEx(Handle);
end;

procedure TXEle.SetBkManager(hBkInfoM: HBKM);
begin
  XEle_SetBkManager(Handle, hBkInfoM);
end;

function TXEle.GetStateFlags: Integer;
begin
  Result := XEle_GetStateFlags(Handle);
end;

function TXEle.DrawFocus(hDraw: hDraw; XRect: TRect): Boolean;
begin
  Result := XEle_DrawFocus(Handle, hDraw, XRect);
end;

procedure TXEle.DrawEle(hDraw: hDraw);
begin
  XEle_DrawEle(Handle, hDraw);
end;

procedure TXEle.SetUserData(const Value: vint);
begin
  XEle_SetUserData(Handle, Value);
end;

function TXEle.GetUserData: vint;
begin
  Result := XEle_GetUserData(Handle);
end;

procedure TXEle.GetContentSize(bHorizon: Boolean; cx, cy: Integer; out pSize: TSize);
begin
  XEle_GetContentSize(Handle, bHorizon, cx, cy, pSize);
end;

procedure TXEle.SetCapture(b: Boolean);
begin
  XEle_SetCapture(Handle, b);
end;

procedure TXEle.EnableTransparentChannel(bEnable: Boolean);
begin
  XEle_EnableTransparentChannel(Handle, bEnable);
end;

function TXEle.SetXCTimer(nIDEvent, uElapse: UINT): Boolean;
begin
  Result := XEle_SetXCTimer(Handle, nIDEvent, uElapse);
end;

function TXEle.KillXCTimer(nIDEvent: UINT): Boolean;
begin
  Result := XEle_KillXCTimer(Handle, nIDEvent);
end;

class function TXEle.OnDESTROY(hEle: Integer; pbHandled: PBoolean): Integer;
begin
  TXEle(GetClassFormHandle(hEle)).Free;
  Result := 0;
end;

procedure TXEle.SetToolTip(pText: PWideChar);
begin
  XEle_SetToolTip(Handle, pText);
end;

procedure TXEle.SetToolTipEx(pText: PWideChar; nTextAlign: Integer);
begin
  XEle_SetToolTipEx(Handle, pText, nTextAlign);
end;

function TXEle.GetToolTip: PWideChar;
begin
  Result := XEle_GetToolTip(Handle);
end;

procedure TXEle.PopupToolTip(x, y: Integer);
begin
  XEle_PopupToolTip(Handle, x, y);
end;

procedure TXEle.AdjustLayout(nAdjustNo: UINT);
begin
  XEle_AdjustLayout(Handle, nAdjustNo);
end;

procedure TXEle.AdjustLayoutEx(nFlags: Integer; nAdjustNo: UINT);
begin
  XEle_AdjustLayoutEx(Handle, nFlags, nAdjustNo);
end;

procedure TXEle.Init;
begin
  inherited Init;
  RegEvent(XE_DESTROY, @OnDESTROY);
end;

end.

