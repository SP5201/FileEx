unit XWidget;

interface

uses
  Windows, Messages, Generics.Collections, XCGUI;

type
  TXWidget = class abstract(TObject)
  private
    FHandle: HXCGUI;
    FPopupMenu: Pointer;
    FTooltip: Pointer;
    FDraw: Integer;
    class var
      FHandleMap: TDictionary<Integer, Pointer>;
    procedure SetHandle(const Value: HELE);
  protected
    procedure Init; virtual;
  public
    class function IsReused(const Handle: Integer): Boolean;
    class function GetObjectFromXmlName(const Name: string): Pointer;
    class function GetObjectFromXmlID(const hWindow: Integer; const ID: Integer): Pointer;
    class function GetObjectFromHandle(const Handle: Integer): Pointer;
    class function GetClassFormHandle(Handle: Integer): Pointer;
    constructor Create;
    destructor Destroy; override;
    property Handle: HXCGUI read FHandle write SetHandle;
    property PopupMenu: Pointer read FPopupMenu write FPopupMenu;
    property Tooltip: Pointer read FTooltip write FTooltip;
    function GetIsShow: BOOL;
    function GetIsLayoutControl: BOOL;
    function GetParentEle: HELE;
    function GetParent: HXCGUI;
    function GetHWND: Integer;
    function GetHWINDOW: HWINDOW; virtual;
    function GetID: Integer;
    function GetUID: Integer;
    function GetName: PChar;
    function GetDPI: Integer;
    function GetDpiScale: Single;
    property DPI: Integer read GetDPI;
    property DpiScale: Single read GetDpiScale;

    procedure SetID(const nID: Integer);
    procedure SetUID(const nUID: Integer);
    procedure SetName(const pName: PChar);
    function GetDraw: Integer;
    procedure SetDraw(const hDraw: Integer);
    property IsShow: BOOL read GetIsShow;
    property IsLayoutControl: BOOL read GetIsLayoutControl;
    property ParentEle: HELE read GetParentEle;
    property Parent: HXCGUI read GetParent;
    property HWND: Integer read GetHWND;
    property HWINDOW: HWINDOW read GetHWINDOW;
    property ID: Integer read GetID write SetID;
    property UID: Integer read GetUID write SetUID;
    property Name: PChar read GetName write SetName;
    property Draw: Integer read GetDraw write SetDraw;

    procedure Show(const bShow: BOOL);
    procedure EnableLayoutControl(const bEnable: BOOL);
    procedure LayoutItem_EnableWrap(const bWrap: BOOL);
    procedure LayoutItem_EnableSwap(const bEnable: BOOL);
    procedure LayoutItem_EnableFloat(const bFloat: BOOL);
    procedure LayoutItem_SetWidth(nType: layout_size_; nWidth: Integer);
    procedure LayoutItem_SetHeight(nType: layout_size_; nHeight: Integer);
    procedure LayoutItem_GetWidth(out pType: layout_size_; out pWidth: Integer);
    procedure LayoutItem_GetHeight(out pType: layout_size_; out pHeight: Integer);
    procedure LayoutItem_SetAlign(nAlign: layout_align_axis_);
    procedure LayoutItem_SetMargin(left, top, right, bottom: Integer);
    procedure LayoutItem_GetMargin(out pMargin: TmarginSize_);
    procedure LayoutItem_SetMinSize(width, height: Integer);
    procedure LayoutItem_SetPosition(left, top, right, bottom: Integer);
    function IsSViewExtend(hEle: HELE): Boolean;
    function GetObjectType: Integer;
    function GetObjectByUID(nUID: Integer): HXCGUI;
    function GetObjectByUIDName(const pName: PChar): HXCGUI;
    function GetObjectByName(const pName: PChar): HXCGUI;
    function IsHELE: Boolean;
    function IsHWINDOW: Boolean;
    function IsShape: Boolean;
    function IsHXCGUI(hXCGUI: HXCGUI; nType: XC_OBJECT_TYPE): Boolean;
  end;

implementation

constructor TXWidget.Create;
begin
  inherited Create;
end;

destructor TXWidget.Destroy;
begin
  if Assigned(FHandleMap) and FHandleMap.ContainsKey(FHandle) then
    FHandleMap.Remove(FHandle);
  inherited;
end;

function TXWidget.GetIsShow: BOOL;
begin
  Result := XWidget_IsShow(FHandle);
end;

function TXWidget.GetIsLayoutControl: BOOL;
begin
  Result := XWidget_IsLayoutControl(FHandle);
end;

function TXWidget.GetParentEle: HELE;
begin
  Result := XWidget_GetParentEle(FHandle);
end;

function TXWidget.GetParent: HXCGUI;
begin
  Result := XWidget_GetParent(FHandle);
end;

function TXWidget.GetHWND: Integer;
begin
  if IsHWINDOW then
    Result := XWnd_GetHWND(Handle)
  else if IsHELE then
    Result := XWidget_GetHWND(Handle)
  else
    Result := 0;
end;

function TXWidget.GetHWINDOW: HWINDOW;
begin
  if IsHELE then
    Result := XWidget_GetHWINDOW(FHandle)
  else if IsHWINDOW then
    Result := FHandle
  else
    Result := 0;
end;

function TXWidget.GetID: Integer;
begin
  Result := XWidget_GetID(FHandle);
end;

function TXWidget.GetUID: Integer;
begin
  Result := XWidget_GetUID(FHandle);
end;

function TXWidget.GetName: PChar;
begin
  Result := XWidget_GetName(FHandle);
end;

function TXWidget.GetDPI: Integer;
begin
  if IsHWINDOW then
    Result := XWnd_GetDPI(Handle)
  else if IsHELE then
    Result := XWnd_GetDPI(GetHWINDOW)
  else
    Result := 0;
end;

function TXWidget.GetDpiScale: Single;
begin
  Result := DPI / 96;
end;

procedure TXWidget.SetDraw(const hDraw: Integer);
begin
  if FDraw <> 0 then
    XDraw_Destroy(FDraw);
  FDraw := hDraw;
end;

function TXWidget.GetDraw: Integer;
begin
  if IsHELE then
    Result := TXWidget(GetClassFormHandle(XWidget_GetHWINDOW(Handle))).FDraw
  else
    Result := FDraw;
end;

procedure TXWidget.SetHandle(const Value: HELE);
begin
  FHandle := Value;
  if XC_GetObjectType(Handle) <= 0 then
    Exit;
  FHandleMap.Add(FHandle, Pointer(Self));
end;

procedure TXWidget.SetID(const nID: Integer);
begin
  XWidget_SetID(FHandle, nID);
end;

procedure TXWidget.SetUID(const nUID: Integer);
begin
  XWidget_SetUID(FHandle, nUID);
end;

procedure TXWidget.SetName(const pName: PChar);
begin
  XWidget_SetName(FHandle, PWideChar(pName));
end;

procedure TXWidget.Show(const bShow: BOOL);
begin
  XWidget_Show(FHandle, bShow);
  XWnd_AdjustLayout(HWINDOW);
end;

procedure TXWidget.EnableLayoutControl(const bEnable: BOOL);
begin
  XWidget_EnableLayoutControl(FHandle, bEnable);
end;

procedure TXWidget.LayoutItem_EnableWrap(const bWrap: BOOL);
begin
  XWidget_LayoutItem_EnableWrap(FHandle, bWrap);
end;

procedure TXWidget.LayoutItem_EnableSwap(const bEnable: BOOL);
begin
  XWidget_LayoutItem_EnableSwap(FHandle, bEnable);
end;

procedure TXWidget.LayoutItem_EnableFloat(const bFloat: BOOL);
begin
  XWidget_LayoutItem_EnableFloat(FHandle, bFloat);
end;

procedure TXWidget.LayoutItem_SetWidth(nType: layout_size_; nWidth: Integer);
begin
  XWidget_LayoutItem_SetWidth(FHandle, nType, nWidth);
end;

procedure TXWidget.LayoutItem_SetHeight(nType: layout_size_; nHeight: Integer);
begin
  XWidget_LayoutItem_SetHeight(FHandle, nType, nHeight);
end;

procedure TXWidget.LayoutItem_GetWidth(out pType: layout_size_; out pWidth: Integer);
begin
  XWidget_LayoutItem_GetWidth(FHandle, pType, pWidth);
end;

procedure TXWidget.LayoutItem_GetHeight(out pType: layout_size_; out pHeight: Integer);
begin
  XWidget_LayoutItem_GetHeight(FHandle, pType, pHeight);
end;

procedure TXWidget.LayoutItem_SetAlign(nAlign: layout_align_axis_);
begin
  XWidget_LayoutItem_SetAlign(FHandle, nAlign);
end;

procedure TXWidget.LayoutItem_SetMargin(left, top, right, bottom: Integer);
begin
  XWidget_LayoutItem_SetMargin(FHandle, left, top, right, bottom);
end;

procedure TXWidget.LayoutItem_GetMargin(out pMargin: TmarginSize_);
begin
  XWidget_LayoutItem_GetMargin(FHandle, pMargin);
end;

procedure TXWidget.LayoutItem_SetMinSize(width, height: Integer);
begin
  XWidget_LayoutItem_SetMinSize(FHandle, width, height);
end;

procedure TXWidget.LayoutItem_SetPosition(left, top, right, bottom: Integer);
begin
  XWidget_LayoutItem_SetPosition(FHandle, left, top, right, bottom);
end;

function TXWidget.IsSViewExtend(hEle: hEle): Boolean;
begin
  Result := Boolean(XC_IsSViewExtend(hEle));
end;

function TXWidget.GetObjectType: Integer;
begin
  Result := XC_GetObjectType(FHandle);
end;

function TXWidget.GetObjectByUID(nUID: Integer): hXCGUI;
begin
  Result := XC_GetObjectByUID(nUID);
  FHandle := Result;
end;

function TXWidget.GetObjectByUIDName(const pName: PChar): hXCGUI;
begin
  Result := XC_GetObjectByUIDName(PWideChar(pName));
  FHandle := Result;
end;

function TXWidget.GetObjectByName(const pName: PChar): hXCGUI;
begin
  Result := XC_GetObjectByName(PWideChar(pName));
  FHandle := Result;
end;

function TXWidget.IsHELE: Boolean;
begin
  Result := XC_IsHELE(FHandle);
end;

function TXWidget.IsHWINDOW: Boolean;
begin
  Result := XC_IsHWINDOW(FHandle);
end;

function TXWidget.IsShape: Boolean;
begin
  Result := XC_IsShape(FHandle);
end;

function TXWidget.IsHXCGUI(hXCGUI: hXCGUI; nType: XC_OBJECT_TYPE): Boolean;
begin
  Result := XC_IsHXCGUI(hXCGUI, nType);
end;

class function TXWidget.IsReused(const Handle: Integer): Boolean;
begin
  Result := FHandleMap.ContainsKey(Handle);
end;

class function TXWidget.GetClassFormHandle(Handle: Integer): Pointer;
var
  Value: Pointer;
begin
  if FHandleMap.TryGetValue(Handle, Value) then
    Result := Value
  else
    Result := nil;
end;


class function TXWidget.GetObjectFromXmlName(const Name: string): Pointer;
var
  Handle: Integer;
begin
  Handle := XC_GetObjectByName(PChar(Name));
  if Handle = 0 then
    MessageBox(0,'�����ڸ�Ԫ��',PChar(Name), 0);
  Result := GetObjectFromHandle(Handle);
end;

class function TXWidget.GetObjectFromXmlID(const hWindow: Integer; const ID: Integer): Pointer;
var
  Handle: Integer;
begin
  Handle := XC_GetObjectByID(hWindow, ID);
  Result := GetObjectFromHandle(Handle);
end;

class function TXWidget.GetObjectFromHandle(const Handle: Integer): Pointer;
var
  Reused: Boolean;
begin
  Reused := IsReused(Handle);
  if not Reused then
  begin
    Result := Create;
    TXWidget(Result).Handle := Handle;
    TXWidget(Result).Init;
  end
  else
    Result := GetClassFormHandle(Handle);
end;

procedure TXWidget.Init;
begin

end;

initialization
  TXWidget.FHandleMap := TDictionary<Integer, Pointer>.Create;


finalization
  TXWidget.FHandleMap.Free;

end.
