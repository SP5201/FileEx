unit UI_Window;

interface

uses
  Windows, Classes, Messages, XCGUI, SysUtils;

const
  Window_Border_left: Integer = 19 - 4;
  Window_Border_top: Integer = 16 - 4;
  Window_Border_right: Integer = 19 - 4;
  Window_Border_bottom: Integer = 24 - 4;

type
  TWindowData = record
    dwHandle: Integer;      // 窗口句柄
    dwUserData: Integer; // 对应的用户数据
  end;

function GetWindowSize(hWnd: HWND; var Width, Height: Integer): Boolean;

procedure ResizeWindow(hWnd: Integer; NewWidth, NewHeight: Integer);

procedure ShadowWindow(hWnd: Integer);

procedure XWindow_SetDefStyle(hWindow: Integer);

procedure XWnd_SetUserData(hWindow: Integer; UserData: Integer);

function XWnd_GetUserData(hWindow: Integer; UserData: Integer): Integer;

implementation

uses
  UI_Color;

var
  WindowDataArray: array of TWindowData;

function XWnd_FindWindowDataIndex(hWindow: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(WindowDataArray) - 1 do
    if WindowDataArray[I].dwHandle = hWindow then
      Exit(I);
end;

procedure XWnd_RemoveWindowData(hWindow: HWND);
var
  I, Index: Integer;
begin
  Index := XWnd_FindWindowDataIndex(hWindow);
  if Index <> -1 then
  begin
    for I := Index to Length(WindowDataArray) - 2 do
      WindowDataArray[I] := WindowDataArray[I + 1]; // 将后面的元素前移
    SetLength(WindowDataArray, Length(WindowDataArray) - 1); // 缩小数组长度 end;
  end;
end;

function OnWMDESTROY(hWindow: Integer; pbHandle: PBoolean): Integer; stdcall;
begin
  Result := 0;
  XWnd_RemoveWindowData(hWindow);
end;

procedure XWnd_SetUserData(hWindow: Integer; UserData: Integer);
var
  Count: Integer;
  Index: Integer;
begin
  if not XC_IsHWINDOW(hWindow) then
    Exit;

  Index := XWnd_FindWindowDataIndex(hWindow);
  Count := Length(WindowDataArray);
  if Index = -1 then
  begin
    SetLength(WindowDataArray, Count + 1);
    WindowDataArray[Count].dwHandle := hWindow;
    WindowDataArray[Count].dwUserData := UserData;
    XWnd_RegEvent(hWindow, WM_DESTROY, @OnWMDESTROY);
  end
  else
    WindowDataArray[Index].dwUserData := UserData;
end;

function XWnd_GetUserData(hWindow: Integer; UserData: Integer): Integer;
var
  Index: Integer;
begin
  if not XC_IsHWINDOW(hWindow) then
    Exit;

  Index := XWnd_FindWindowDataIndex(hWindow);
  if Index = -1 then
    Result := 0
  else
    Result := WindowDataArray[Index].dwUserData;
end;

function GetWindowSize(hWnd: hWnd; var Width, Height: Integer): Boolean;
var
  Rect: TRect;
begin
  Result := False;
  if IsWindow(hWnd) then
  begin
    if GetWindowRect(hWnd, Rect) then
    begin
      Width := Rect.Right - Rect.Left;
      Height := Rect.Bottom - Rect.Top;
      Result := True;
    end;
  end;
end;

procedure ResizeWindow(hWnd: Integer; NewWidth, NewHeight: Integer);
var
  WindowRect: Windows.TRECT;
begin
  GetWindowRect(XWnd_GetHWND(hWnd), WindowRect);
  MoveWindow(XWnd_GetHWND(hWnd), WindowRect.Left - Window_Border_left - 4, WindowRect.Top - Window_Border_top + 6, NewWidth, NewHeight, True);
end;

procedure ShadowWindow(hWnd: Integer);
begin
  ResizeWindow(hWnd, 220 + Window_Border_left + Window_Border_right, 184 + Window_Border_top + Window_Border_bottom);
  XWnd_SetBorderSize(hWnd, Window_Border_left, Window_Border_top, Window_Border_right, Window_Border_bottom);
  XWnd_SetTransparentType(hWnd, window_transparent_shaped);
  XWnd_SetTransparentAlpha(hWnd, 255);
  XWnd_SetBkInfo(hWnd, '{99:1.9.9;98:1(0);3:2(15)4(@6px 白);}');
end;

function OnWMPAINT(hWindow: Integer; hDraw: Integer; pbHandled: PBoolean): Integer; stdcall;
var
  Rc: TRect;
  hBkImage: Integer;
begin
  Result := 0;
  XDraw_EnableSmoothingMode(hDraw, True);
  hBkImage := XRes_GetImage('圆角阴影6px');
  if XC_GetObjectType(hBkImage) = XC_IMAGE then
  begin
    XWnd_GetClientRect(hWindow, Rc);
    XDraw_ImageSuper(hDraw, hBkImage, Rc, False);
    XDraw_SetBrushColor(hDraw, Theme_Window_BkColor);
    Rc := tRect.Create(Rc.Left + 10, Rc.Top + 10, Rc.width - 10, Rc.height - 10);
    XDraw_FillRoundRectEx(hDraw, Rc, 6, 6, 6, 6);
    XDraw_SetBrushColor(hDraw, RGBA(72, 72, 72, 150));
    XDraw_DrawRoundRectEx(hDraw, Rc, 6, 6, 6, 6);
  end;
end;

procedure XWindow_SetDefStyle(hWindow: Integer);
begin
  XWnd_SetBorderSize(hWindow, 10, 10, 10, 10);
  XWnd_SetTransparentAlpha(hWindow, 255);
  XWnd_RegEvent(hWindow, WM_PAINT, @OnWMPAINT);
end;

end.

