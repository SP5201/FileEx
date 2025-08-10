unit XEventBase;

interface

uses
  Windows, SysUtils, Classes, XCGUI, XElement, XForm, System.Generics.Collections;

type
  // 事件参数记录
  TXEventParams = record
    hEle: HELE;
    hWindow: HWINDOW;
    hDraw: HDRAW;
    wParam: WPARAM;
    lParam: LPARAM;
    pbHandled: PBoolean;
    case Integer of
      0: ();
      1: ();
      2: (x, y: Integer);
      3: (bCheck: Boolean);
      4: ();
  end;

  // 事件处理函数类型
  TXEventHandler = function(const Params: TXEventParams): Integer of object;

  // 事件处理器类
  TXEventHandlerClass = class
  private
    FEventMap: TDictionary<Integer, TXEventHandler>;
    FDefaultHandler: TXEventHandler;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterEvent(EventType: Integer; Handler: TXEventHandler);
    procedure RegisterDefaultHandler(Handler: TXEventHandler);
    function HandleEvent(EventType: Integer; const Params: TXEventParams): Integer;
    procedure ClearEvents;
  end;

  // 事件管理器类
  TXEventManager = class
  private
    FHandlers: TDictionary<string, TXEventHandlerClass>;
    FDefaultHandler: TXEventHandlerClass;
    class var FInstance: TXEventManager;
    class function GetInstance: TXEventManager; static;
  public
    constructor Create;
    destructor Destroy; override;
    function GetHandler(const Name: string): TXEventHandlerClass;
    procedure RegisterHandler(const Name: string; Handler: TXEventHandlerClass);
    function HandleEvent(const Name: string; EventType: Integer; const Params: TXEventParams): Integer;
    class property Instance: TXEventManager read GetInstance;
  end;

  // 事件辅助类
  TXEventHelper = class
  public
    class function CreateEventParams(hEle: HELE; hWindow: HWINDOW; hDraw: HDRAW; wParam: WPARAM; lParam: LPARAM; pbHandled: PBoolean): TXEventParams;
    class procedure RegisterElementEvents(hEle: HELE; Handler: TXEventHandlerClass);
    class procedure RegisterWindowEvents(hWindow: HWINDOW; Handler: TXEventHandlerClass);
  end;

  // 事件处理基类
  TXEventBase = class
  private
    FEventHandler: TXEventHandlerClass;
    FHandle: Integer;
    FHandleType: Integer; // 0=Element, 1=Window
  protected
    function OnDestroy(const Params: TXEventParams): Integer; virtual;
    function OnPaint(const Params: TXEventParams): Integer; virtual;
    function OnMouseStay(const Params: TXEventParams): Integer; virtual;
    function OnMouseLeave(const Params: TXEventParams): Integer; virtual;
    function OnMouseMove(const Params: TXEventParams): Integer; virtual;
    function OnLButtonDown(const Params: TXEventParams): Integer; virtual;
    function OnLButtonUp(const Params: TXEventParams): Integer; virtual;
    function OnRButtonDown(const Params: TXEventParams): Integer; virtual;
    function OnRButtonUp(const Params: TXEventParams): Integer; virtual;
    function OnLButtonDblClick(const Params: TXEventParams): Integer; virtual;
    function OnRButtonDblClick(const Params: TXEventParams): Integer; virtual;
    function OnSetFocus(const Params: TXEventParams): Integer; virtual;
    function OnKillFocus(const Params: TXEventParams): Integer; virtual;
    function OnSize(const Params: TXEventParams): Integer; virtual;
    function OnShow(const Params: TXEventParams): Integer; virtual;
    function OnKeyDown(const Params: TXEventParams): Integer; virtual;
    function OnKeyUp(const Params: TXEventParams): Integer; virtual;
    function OnChar(const Params: TXEventParams): Integer; virtual;
    function OnButtonClick(const Params: TXEventParams): Integer; virtual;
    function OnButtonCheck(const Params: TXEventParams): Integer; virtual;
    function OnEditChanged(const Params: TXEventParams): Integer; virtual;
    function OnEditPosChanged(const Params: TXEventParams): Integer; virtual;
    function DefaultEventHandler(const Params: TXEventParams): Integer; virtual;
    procedure RegisterEvents;
    function GetSelf: TXEventBase;
  public
    constructor Create(hHandle: Integer; HandleType: Integer = 0);
    destructor Destroy; override;
    property Handle: Integer read FHandle;
    property HandleType: Integer read FHandleType;
    property EventHandler: TXEventHandlerClass read FEventHandler;
  end;

  // 元素事件基类
  TXElementEventBase = class(TXEventBase)
  public
    constructor Create(hElement: HELE);
  end;

  // 窗口事件基类
  TXWindowEventBase = class(TXEventBase)
  public
    constructor Create(hWindow: HWINDOW);
  end;

// 全局事件处理函数（用于XCGUI回调）
function GlobalEventHandler(hEle: HELE; nEvent: Integer; wParam: WPARAM; lParam: LPARAM; pbHandled: PBoolean): Integer; stdcall;

implementation

var
  GEventManager: TXEventManager;

function GlobalEventHandler(hEle: hEle; nEvent: Integer; wParam: wParam; lParam: lParam; pbHandled: PBoolean): Integer;
var
  Params: TXEventParams;
  Handler: TXEventHandlerClass;
begin
  Result := 0;
  Params := TXEventHelper.CreateEventParams(hEle, 0, 0, wParam, lParam, pbHandled);
  Handler := TXEventManager.Instance.GetHandler('Element_' + IntToStr(hEle));
  if Handler = nil then
    Handler := TXEventManager.Instance.FDefaultHandler;
  if Handler <> nil then
    Result := Handler.HandleEvent(nEvent, Params);
end;

{ TXEventHandlerClass }

constructor TXEventHandlerClass.Create;
begin
  inherited Create;
  FEventMap := TDictionary<Integer, TXEventHandler>.Create;
  FDefaultHandler := nil;
end;

destructor TXEventHandlerClass.Destroy;
begin
  FEventMap.Free;
  inherited;
end;

procedure TXEventHandlerClass.RegisterEvent(EventType: Integer; Handler: TXEventHandler);
begin
  FEventMap.AddOrSetValue(EventType, Handler);
end;

procedure TXEventHandlerClass.RegisterDefaultHandler(Handler: TXEventHandler);
begin
  FDefaultHandler := Handler;
end;

function TXEventHandlerClass.HandleEvent(EventType: Integer; const Params: TXEventParams): Integer;
var
  Handler: TXEventHandler;
begin
  Result := 0;
  if FEventMap.TryGetValue(EventType, Handler) then
  begin
    if Assigned(Handler) then
      Result := Handler(Params);
  end
  else if Assigned(FDefaultHandler) then
    Result := FDefaultHandler(Params);
end;

procedure TXEventHandlerClass.ClearEvents;
begin
  FEventMap.Clear;
  FDefaultHandler := nil;
end;

{ TXEventManager }

constructor TXEventManager.Create;
begin
  inherited Create;
  FHandlers := TDictionary<string, TXEventHandlerClass>.Create;
  FDefaultHandler := TXEventHandlerClass.Create;
end;

destructor TXEventManager.Destroy;
begin
  FHandlers.Clear;
  FHandlers.Free;
  FDefaultHandler.Free;
  inherited;
end;

class function TXEventManager.GetInstance: TXEventManager;
begin
  if FInstance = nil then
    FInstance := TXEventManager.Create;
  Result := FInstance;
end;

function TXEventManager.GetHandler(const Name: string): TXEventHandlerClass;
begin
  if FHandlers.ContainsKey(Name) then
    Result := FHandlers[Name]
  else
    Result := nil;
end;

procedure TXEventManager.RegisterHandler(const Name: string; Handler: TXEventHandlerClass);
begin
  if FHandlers.ContainsKey(Name) then
  begin
    if Assigned(FHandlers[Name]) then
      FHandlers[Name].Free;
    if Assigned(Handler) then
      FHandlers[Name] := Handler
    else
      FHandlers.Remove(Name);
  end
  else if Assigned(Handler) then
    FHandlers.Add(Name, Handler);
end;

function TXEventManager.HandleEvent(const Name: string; EventType: Integer; const Params: TXEventParams): Integer;
var
  Handler: TXEventHandlerClass;
begin
  Result := 0;
  Handler := GetHandler(Name);
  if Handler <> nil then
    Result := Handler.HandleEvent(EventType, Params);
end;

{ TXEventHelper }

class function TXEventHelper.CreateEventParams(hEle: hEle; hWindow: hWindow; hDraw: hDraw; wParam: wParam; lParam: lParam; pbHandled: PBoolean): TXEventParams;
begin
  Result.hEle := hEle;
  Result.hWindow := hWindow;
  Result.hDraw := hDraw;
  Result.wParam := wParam;
  Result.lParam := lParam;
  Result.pbHandled := pbHandled;
end;

class procedure TXEventHelper.RegisterElementEvents(hEle: hEle; Handler: TXEventHandlerClass);
begin
  XEle_RegEvent(hEle, XE_DESTROY, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_PAINT, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_MOUSESTAY, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_MOUSELEAVE, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_MOUSEMOVE, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_LBUTTONDOWN, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_LBUTTONUP, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_RBUTTONDOWN, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_RBUTTONUP, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_LBUTTONDBCLICK, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_RBUTTONDBCLICK, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_SETFOCUS, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_KILLFOCUS, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_SIZE, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_SHOW, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_KEYDOWN, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_KEYUP, @GlobalEventHandler);
  XEle_RegEvent(hEle, XE_CHAR, @GlobalEventHandler);
  TXEventManager.Instance.RegisterHandler('Element_' + IntToStr(hEle), Handler);
end;

class procedure TXEventHelper.RegisterWindowEvents(hWindow: hWindow; Handler: TXEventHandlerClass);
begin
  XWnd_RegEvent(hWindow, XWM_REDRAW_ELE, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_WINDPROC, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_DRAW_T, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_TIMER_T, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_XC_TIMER, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_SETFOCUS_ELE, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_TRAYICON, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_MENU_POPUP, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_MENU_SELECT, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_MENU_EXIT, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_MENU_DRAW_BACKGROUND, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_MENU_DRAWITEM, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_COMBOBOX_POPUP_DROPLIST, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_FLOAT_PANE, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_PAINT_END, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_PAINT_DISPLAY, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_DOCK_POPUP, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_FLOATWND_DRAG, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_PANE_SHOW, @GlobalEventHandler);
  XWnd_RegEvent(hWindow, XWM_BODYVIEW_RECT, @GlobalEventHandler);
  TXEventManager.Instance.RegisterHandler('Window_' + IntToStr(hWindow), Handler);
end;

{ TXEventBase }

constructor TXEventBase.Create(hHandle: Integer; HandleType: Integer);
begin
  inherited Create;
  FHandle := hHandle;
  FHandleType := HandleType;
  FEventHandler := TXEventHandlerClass.Create;
  RegisterEvents;
  if HandleType = 0 then
    TXEventHelper.RegisterElementEvents(hHandle, FEventHandler)
  else
    TXEventHelper.RegisterWindowEvents(hHandle, FEventHandler);
end;

destructor TXEventBase.Destroy;
begin
  if Assigned(FEventHandler) then
  begin
    TXEventManager.Instance.RegisterHandler('Element_' + IntToStr(FHandle), nil);
    FEventHandler.Free;
  end;
  inherited;
end;

procedure TXEventBase.RegisterEvents;
begin
  FEventHandler.RegisterEvent(XE_DESTROY, Self.OnDestroy);
  FEventHandler.RegisterEvent(XE_PAINT, Self.OnPaint);
  FEventHandler.RegisterEvent(XE_MOUSESTAY, Self.OnMouseStay);
  FEventHandler.RegisterEvent(XE_MOUSELEAVE, Self.OnMouseLeave);
  FEventHandler.RegisterEvent(XE_MOUSEMOVE, Self.OnMouseMove);
  FEventHandler.RegisterEvent(XE_LBUTTONDOWN, Self.OnLButtonDown);
  FEventHandler.RegisterEvent(XE_LBUTTONUP, Self.OnLButtonUp);
  FEventHandler.RegisterEvent(XE_RBUTTONDOWN, Self.OnRButtonDown);
  FEventHandler.RegisterEvent(XE_RBUTTONUP, Self.OnRButtonUp);
  FEventHandler.RegisterEvent(XE_LBUTTONDBCLICK, Self.OnLButtonDblClick);
  FEventHandler.RegisterEvent(XE_RBUTTONDBCLICK, Self.OnRButtonDblClick);
  FEventHandler.RegisterEvent(XE_SETFOCUS, Self.OnSetFocus);
  FEventHandler.RegisterEvent(XE_KILLFOCUS, Self.OnKillFocus);
  FEventHandler.RegisterEvent(XE_SIZE, Self.OnSize);
  FEventHandler.RegisterEvent(XE_SHOW, Self.OnShow);
  FEventHandler.RegisterEvent(XE_KEYDOWN, Self.OnKeyDown);
  FEventHandler.RegisterEvent(XE_KEYUP, Self.OnKeyUp);
  FEventHandler.RegisterEvent(XE_CHAR, Self.OnChar);
  FEventHandler.RegisterEvent(XE_BNCLICK, Self.OnButtonClick);
  FEventHandler.RegisterEvent(XE_BUTTON_CHECK, Self.OnButtonCheck);
  FEventHandler.RegisterEvent(XE_EDIT_CHANGED, Self.OnEditChanged);
  FEventHandler.RegisterEvent(XE_EDIT_POS_CHANGED, Self.OnEditPosChanged);
  FEventHandler.RegisterDefaultHandler(Self.DefaultEventHandler);
end;

function TXEventBase.GetSelf: TXEventBase;
begin
  Result := Self;
end;

function TXEventBase.OnDestroy(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnPaint(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnMouseStay(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnMouseLeave(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnMouseMove(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnLButtonDown(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnLButtonUp(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnRButtonDown(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnRButtonUp(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnLButtonDblClick(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnRButtonDblClick(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnSetFocus(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnKillFocus(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnSize(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnShow(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnKeyDown(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnKeyUp(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnChar(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnButtonClick(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnButtonCheck(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnEditChanged(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.OnEditPosChanged(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

function TXEventBase.DefaultEventHandler(const Params: TXEventParams): Integer;
begin
  Result := 0;
end;

{ TXElementEventBase }

constructor TXElementEventBase.Create(hElement: HELE);
begin
  inherited Create(hElement, 0);
end;

{ TXWindowEventBase }

constructor TXWindowEventBase.Create(hWindow: HWINDOW);
begin
  inherited Create(hWindow, 1);
end;

initialization
  GEventManager := TXEventManager.Instance;

finalization
  if Assigned(GEventManager) then
    GEventManager.Free;

end. 