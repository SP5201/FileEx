program QMovie;

{$IF CompilerVersion >= 21.0}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$IFEND}

{$R *.dres}
{$R *.res}

uses
  Windows,
  Classes,
  SysUtils,
  MainForm,
  XCGUI,
  UI_Resource,
  ImageCore;

var
  hMutex: THandle;
  MutexName: string = 'QMovie_SingleInstance_Mutex';
  PrevWnd: HWND;

begin
  hMutex := CreateMutex(nil, True, PChar(MutexName));
  if (hMutex = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    // 已有实例，尝试激活已有窗口
    PrevWnd := FindWindow(nil, 'QMovie'); // 假设主窗体标题为 QMenu，如有不同请修改
    if PrevWnd <> 0 then
    begin
      if IsIconic(PrevWnd) then
        ShowWindow(PrevWnd, SW_RESTORE);
      SetForegroundWindow(PrevWnd);
    end;
    ExitProcess(0);
  end;

  XInitXCGUI(True);
  InitializeRenderer;
  XResource_Init();
  XC_SetDefaultFont(XRes_GetFont('微软雅黑10常规'));
  XC_EnableDPI(True);
  //XC_EnableAutoDPI(True);
 // XC_EnableDebugFile(True);
  XC_SetPaintFrequency(20);

  LoadMainForm;

  XRunXCGUI();
  ExitRenderer;
  XResource_Release;
  XExitXCGUI();

  if hMutex <> 0 then
    CloseHandle(hMutex);
end.

