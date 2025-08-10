unit UI_Form;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, XCGUI, XLayout, XWidget,
  XElement, UI_Resource, XForm, Ui_Color, System.UITypes, Winapi.D2D1,Types;

const
  WM_DPICHANGED = $02E0;

type
  TFormUI = class(TXForm)
  private
    FTheme: TTheme;
  protected
    procedure Init; override;
    class function OnPAINT(hWnd, hDraw: Integer; pbHandle: PBoolean): Integer; stdcall; static;
    class function OnWMBUTTDOWN(hWnd: Integer; nFlags: Cardinal; var pPt: TPoint; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnWndProc(AHandle: HWND; AMessage: UINT; wParam: wParam; lParam: lParam; var bHandled: Boolean): LRESULT; stdcall; static;
    procedure OnWinProc(AMessage: UINT; wParam: wParam; lParam: lParam; var bHandled: Boolean); virtual;
    class function OnDROPFILES(hWindow: Integer; hDropInfo: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnDPICHANGED(hWindow: Integer; wParam: wParam; lParam: lParam; var bHandled: Boolean): Integer; stdcall; static;
    procedure OnDroppedFiles(const FilePaths: TArray<string>); virtual;
  public
    destructor Destroy; override;
    class function FromXml(const Name: string; hParent: Integer = 0): TFormUI;
    procedure SetTheme(Theme: TTheme);
    procedure Show;
    property Theme: TTheme read FTheme write SetTheme;
    procedure CloseAllModalForms;
  end;

implementation

uses
  Winapi.Messages, Winapi.ShellAPI;

var
  GModalFormsStack: TArray<Integer>;

{ TFormUI }

procedure TFormUI.CloseAllModalForms;
var
  i: Integer;
begin
  // 从最上层的模态窗口开始，依次关闭
  for i := High(GModalFormsStack) downto 0 do
  begin
    XModalWnd_EndModal(GModalFormsStack[i], 0);
  end;
end;

destructor TFormUI.Destroy;
begin
  inherited;
end;

class function TFormUI.FromXml(const Name: string; hParent: Integer = 0): TFormUI;
var
  hWindow: Integer;
begin
  hWindow := XResource_LoadZipLayout(PChar(Name), '', hParent);
  Result := FormHandle(hWindow);
end;


procedure TFormUI.Init;
begin
  inherited;
  SetTransparentType(window_transparent_shadow);
  SetTransparentAlpha(255);
  SetShadowInfo(14, 150, Theme_Window_CornerRadius, False, RGBA(0, 0, 0, 0));
  RegEvent(WM_PAINT, @OnPAINT);
  RegEvent(WM_LBUTTONDOWN, @OnWMBUTTDOWN);
  RegEvent(WM_RBUTTONDOWN, @OnWMBUTTDOWN);
  RegEvent(WM_DROPFILES, @OnDROPFILES);
  RegEvent(XWM_WINDPROC, @OnWndProc);
  RegEvent(WM_DPICHANGED, @OnDPICHANGED);
  RegEvent(WM_DESTROY, @OnDestroy);
end;

//当鼠标按下其他非编辑框地区  编辑框失去焦点
class function TFormUI.OnWMBUTTDOWN(hWnd: Integer; nFlags: Cardinal; var pPt: TPoint; pbHandled: PBoolean): Integer;
var
  hEle: Integer;
begin
  Result := 0;
  hEle := XWnd_HitChildEle(hWnd, pPt);
  if (XC_GetObjectType(hEle) <> XC_EDIT) and (XC_GetObjectType(XWnd_GetFocusEle(hWnd)) = XC_EDIT) then
    XWnd_SetFocusEle(hWnd, XC_GetObjectByName('主窗口_视频列表'));
end;

class function TFormUI.OnWndProc(AHandle: hWnd; AMessage: UINT; wParam: wParam; lParam: lParam; var bHandled: Boolean): LRESULT; stdcall;
var
  FormUI: TFormUI;
begin
  Result := 0;
  FormUI := GetClassFormHandle(AHandle);
  if Assigned(FormUI) then
    FormUI.OnWinProc(AMessage, wParam, lParam, bHandled);
end;

procedure TFormUI.SetTheme(Theme: TTheme);
begin
  FTheme := Theme;
  XTheme_SetTheme(Theme);
end;

procedure TFormUI.Show;
begin
  if GetObjectType = XC_WINDOW then
    ShowWindow(SW_SHOW)
  else if GetObjectType = XC_MODALWINDOW then
  begin
    SetLength(GModalFormsStack, Length(GModalFormsStack) + 1);
    GModalFormsStack[High(GModalFormsStack)] := Handle;
    XModalWnd_DoModal(Handle);
  end;
end;

class function TFormUI.OnDPICHANGED(hWindow: Integer; wParam: wParam; lParam: lParam; var bHandled: Boolean): Integer;
begin
  Result := 0;
  XWnd_AdjustLayout(hWindow);
  XC_SendMessage(hWindow, WM_SIZE, 0, 0);
  XWnd_Redraw(hWindow);
end;

class function TFormUI.OnDROPFILES(hWindow, hDropInfo: Integer; pbHandled: PBoolean): Integer;
var
  MainFormUI: TFormUI;
  FileCount: Integer;
  FileName: array[0..MAX_PATH] of Char;
  I: Integer;
  FilePaths: TArray<string>;
begin
  Result := 0;
  try
    FileCount := DragQueryFile(hDropInfo, $FFFFFFFF, nil, 0);
    SetLength(FilePaths, FileCount);
    for I := 0 to FileCount - 1 do
    begin
      DragQueryFile(hDropInfo, I, FileName, SizeOf(FileName));
      FilePaths[I] := FileName;
    end;
    DragFinish(hDropInfo);
    MainFormUI := GetObjectFromHandle(hWindow);
    MainFormUI.OnDroppedFiles(FilePaths);
  finally
  end;
end;

procedure TFormUI.OnWinProc(AMessage: UINT; wParam: wParam; lParam: lParam; var bHandled: Boolean);
begin
end;

procedure TFormUI.OnDroppedFiles(const FilePaths: TArray<string>);
begin
end;

class function TFormUI.OnPAINT(hWnd, hDraw: Integer; pbHandle: PBoolean): Integer;
var
  RC: TRect;
  CornerRadius: Integer;
  RenderTarget: ID2D1HwndRenderTarget;
begin
  Result := 0;

  pbHandle^ := true; //接管绘制
  RenderTarget := ID2D1HwndRenderTarget(XDraw_GetD2dRenderTarget(hDraw));
  if Assigned(RenderTarget) then
    RenderTarget.SetAntialiasMode(D2D1_ANTIALIAS_MODE_PER_PRIMITIVE);

  XWnd_GetClientRect(hWnd, RC); //取窗口客户区坐标
  if IsZoomed(XWnd_GetHWND(hWnd)) then
    CornerRadius := 0
  else
    CornerRadius := Theme_Window_CornerRadius;

  XDraw_SetBrushColor(hDraw, Theme_Window_BkColor);
  XDraw_FillRoundRect(hDraw, RC, CornerRadius , CornerRadius );
  XDraw_SetBrushColor(hDraw, Theme_Window_BorderColor);
  XDraw_DrawRoundRect(hDraw, RC, CornerRadius , CornerRadius);

end;

end.

