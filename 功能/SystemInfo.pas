unit SystemInfo;
//获取系统版本等

interface

uses
  Windows, SysUtils,Classes;

type
  TWindowsVersion = (wvUnknown, wvWinXP, wvWinVista, wvWin7, wvWin8, wvWin8_1, wvWin10, wvWin11);
  TOSBits = (os32bit, os64bit);
  

type
  TCPUInfo = record
    ProcessorName: string;
    NumberOfCores: Cardinal;
    NumberOfLogicalProcessors: Cardinal;
    ClockSpeed: Cardinal;
    Temperature: Double; // 添加CPU温度字段(摄氏度)
  end;
  
  // 内存信息结构
  TMemoryInfo = record
    TotalPhysical: Int64;    // 总物理内存 (字节)
    AvailablePhysical: Int64; // 可用物理内存 (字节)
    TotalVirtual: Int64;     // 总虚拟内存 (字节)
    AvailableVirtual: Int64;  // 可用虚拟内存 (字节)
  end;

    HMONITOR = THandle;
  
  // 显示器信息结构
  TMonitorInfo = record
    Count: Integer;
    PrimaryWidth: Integer;
    PrimaryHeight: Integer;
    PrimaryBitsPerPixel: Integer;
    VirtualWidth: Integer;
    VirtualHeight: Integer;
  end;
  
  // 磁盘信息结构
  TDriveInfo = record
    Letter: Char;
    DriveType: Integer;
    VolumeName: string;
    FileSystem: string;
    TotalSize: Int64;
    FreeSize: Int64;
  end;
  TDriveInfoArray = array of TDriveInfo;
  
  // 网络信息结构
  TNetworkInfo = record
    ComputerName: string;
    UserName: string;
    IPAddress: string;
    MACAddress: string;
  end;

// 操作系统信息函数
function GetWindowsVersion: TWindowsVersion;
function GetWindowsVersionString: string;
function GetOSBits: TOSBits;
function GetOSBitsString: string;


// 内存信息函数
function GetMemoryInfo: TMemoryInfo;
function GetMemoryInfoString: string;
function FormatByteSize(const bytes: UInt64): string;

// 显示器信息函数
function GetMonitorInfo: TMonitorInfo;
function GetMonitorInfoString: string;

// 磁盘信息函数
function GetDriveInfoArray: TDriveInfoArray;
function GetDriveInfoString: string;
function GetDriveTypeString(DriveType: Integer): string;

// 综合系统信息获取函数
function GetFullSystemInfoString: string;

implementation

type
  _OSVERSIONINFOEXW = record
    dwOSVersionInfoSize: DWORD;
    dwMajorVersion: DWORD;
    dwMinorVersion: DWORD;
    dwBuildNumber: DWORD;
    dwPlatformId: DWORD;
    szCSDVersion: array[0..127] of WCHAR;
    wServicePackMajor: WORD;
    wServicePackMinor: WORD;
    wSuiteMask: WORD;
    wProductType: BYTE;
    wReserved: BYTE;
  end;

  RTL_OSVERSIONINFOEXW = _OSVERSIONINFOEXW;
  PRTL_OSVERSIONINFOEXW = ^RTL_OSVERSIONINFOEXW;
  
  // 内存状态结构
  TMemoryStatusEx = record
    dwLength: DWORD;
    dwMemoryLoad: DWORD;
    ullTotalPhys: Int64;
    ullAvailPhys: Int64;
    ullTotalPageFile: Int64;
    ullAvailPageFile: Int64;
    ullTotalVirtual: Int64;
    ullAvailVirtual: Int64;
    ullAvailExtendedVirtual: Int64;
  end;

function RtlGetVersion(lpVersionInformation: PRTL_OSVERSIONINFOEXW): Longint; stdcall; external 'ntdll.dll';
function GlobalMemoryStatusEx(var lpBuffer: TMemoryStatusEx): BOOL; stdcall; external 'kernel32.dll';
function EnumDisplayMonitors(hdc: HDC; lprcClip: PRect; lpfnEnum: TFarProc; dwData: LPARAM): BOOL; stdcall; external 'user32.dll';

function GetRealOSVersion(var Major, Minor, Build: DWORD): Boolean;
var
  osvi: RTL_OSVERSIONINFOEXW;
begin
  ZeroMemory(@osvi, SizeOf(osvi));
  osvi.dwOSVersionInfoSize := SizeOf(osvi);

  if RtlGetVersion(@osvi) = 0 then
  begin
    Major := osvi.dwMajorVersion;
    Minor := osvi.dwMinorVersion;
    Build := osvi.dwBuildNumber;
    Result := True;
  end
  else
    Result := False;
end;

function GetWindowsVersion: TWindowsVersion;
var
  Major, Minor, Build: DWORD;
begin
  if not GetRealOSVersion(Major, Minor, Build) then
    Exit(wvUnknown);

  if (Major = 10) and (Build >= 22000) then
    Exit(wvWin11)
  else if (Major = 10) and (Build < 22000) then
    Exit(wvWin10)
  else if (Major = 6) then
  begin
    case Minor of
      0: Result := wvWinVista;    // Windows Vista
      1: Result := wvWin7;        // Windows 7
      2: Result := wvWin8;        // Windows 8
      3: Result := wvWin8_1;      // Windows 8.1
      else Result := wvUnknown;
    end;
  end
  else if (Major = 5) and (Minor = 1) then
    Result := wvWinXP            // Windows XP
  else
    Result := wvUnknown;
end;

function GetWindowsVersionString: string;
begin
  case GetWindowsVersion of
    wvWinXP:    Result := 'Windows XP';
    wvWinVista: Result := 'Windows Vista';
    wvWin7:     Result := 'Windows 7';
    wvWin8:     Result := 'Windows 8';
    wvWin8_1:   Result := 'Windows 8.1';
    wvWin10:    Result := 'Windows 10';
    wvWin11:    Result := 'Windows 11';
    else        Result := 'Unknown Windows';
  end;
end;

function Is64BitOS: Boolean;
var
  IsWow64: BOOL;
  ProcessHandle: THandle;
begin
  // 在32位系统上，返回False
  Result := False;

  // 检测是否是WOW64进程（32位程序运行在64位系统上）
  if CheckWin32Version(5, 1) then  // 需要Windows XP或更高版本
  begin
    ProcessHandle := GetCurrentProcess;
    if Assigned(GetProcAddress(GetModuleHandle(kernel32), 'IsWow64Process')) then
    begin
      if IsWow64Process(ProcessHandle, IsWow64) then
        Result := IsWow64;
    end;
  end;
end;

function GetOSBits: TOSBits;
begin
  if Is64BitOS then
    Result := os64bit
  else
    Result := os32bit;
end;

function GetOSBitsString: string;
begin
  case GetOSBits of
    os32bit: Result := '32位';
    os64bit: Result := '64位';
  end;
end;


function GetMemoryInfo: TMemoryInfo;
var
  MemoryStatus: TMemoryStatusEx;
begin
  ZeroMemory(@MemoryStatus, SizeOf(MemoryStatus));
  MemoryStatus.dwLength := SizeOf(MemoryStatus);
  
  if GlobalMemoryStatusEx(MemoryStatus) then
  begin
    Result.TotalPhysical := MemoryStatus.ullTotalPhys;
    Result.AvailablePhysical := MemoryStatus.ullAvailPhys;
    Result.TotalVirtual := MemoryStatus.ullTotalVirtual;
    Result.AvailableVirtual := MemoryStatus.ullAvailVirtual;
  end
  else
  begin
    Result.TotalPhysical := 0;
    Result.AvailablePhysical := 0;
    Result.TotalVirtual := 0;
    Result.AvailableVirtual := 0;
  end;
end;

function FormatByteSize(const bytes: UInt64): string;
const
  Units: array[0..5] of string = ('B', 'KB', 'MB', 'GB', 'TB', 'PB');
var
  i: Integer;
  value: Extended;
begin
  if bytes = 0 then
    Exit('0B/s');

  i := 0;
  value := bytes;

  while (i < High(Units)) and (value >= 1024) do
  begin
    value := value / 1024;
    Inc(i);
  end;

  Result := Format('%.0f%s/s', [value, Units[i]]);
end;

function GetMemoryInfoString: string;
var
  MemInfo: TMemoryInfo;
  UsedPercent: Double;
  AvailGB, TotalGB: Double;
begin
  MemInfo := GetMemoryInfo;
  AvailGB := MemInfo.AvailablePhysical / 1024 / 1024 / 1024;
  TotalGB := MemInfo.TotalPhysical / 1024 / 1024 / 1024;
  if MemInfo.TotalPhysical > 0 then
    UsedPercent := (MemInfo.AvailablePhysical / MemInfo.TotalPhysical) * 100
  else
    UsedPercent := 0;
  Result := Format('内存: %.0f/%.0f GB（%.0f%%）', [AvailGB, TotalGB, UsedPercent]);
end;

function EnumDisplayMonitorsProc(hMonitor: HMONITOR; hdcMonitor: HDC;
  lprcMonitor: PRect; dwData: LPARAM): BOOL; stdcall;
var
  Count: PInteger;
begin
  Count := PInteger(dwData);
  Inc(Count^);
  Result := True;
end;

function GetMonitorInfo: TMonitorInfo;
var
  DC: HDC;
begin
  Result.Count := 0;
  EnumDisplayMonitors(0, nil, @EnumDisplayMonitorsProc, LPARAM(@Result.Count));
  
  // 获取主显示器信息
  DC := GetDC(0);
  try
    Result.PrimaryWidth := GetDeviceCaps(DC, HORZRES);
    Result.PrimaryHeight := GetDeviceCaps(DC, VERTRES);
    Result.PrimaryBitsPerPixel := GetDeviceCaps(DC, BITSPIXEL);
    
    // 获取虚拟屏幕尺寸
    Result.VirtualWidth := GetSystemMetrics(SM_CXVIRTUALSCREEN);
    Result.VirtualHeight := GetSystemMetrics(SM_CYVIRTUALSCREEN);
  finally
    ReleaseDC(0, DC);
  end;
end;

function GetMonitorInfoString: string;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo := GetMonitorInfo;
  Result := Format('显示器数量: %d'#13#10'主显示器分辨率: %d×%d(%d位)'#13#10'虚拟屏幕: %d×%d',
    [MonInfo.Count, MonInfo.PrimaryWidth, MonInfo.PrimaryHeight,
     MonInfo.PrimaryBitsPerPixel, MonInfo.VirtualWidth, MonInfo.VirtualHeight]);
end;

function GetDriveInfoArray: TDriveInfoArray;
var
  DriveBits: DWORD;
  Drive: Char;
  DriveRoot: string;
  VolumeName: array[0..MAX_PATH] of Char;
  FileSystemName: array[0..MAX_PATH] of Char;
  VolumeSerialNumber: DWORD;
  MaxComponentLength: DWORD;
  FileSystemFlags: DWORD;
  FreeBytesAvailable: Int64;
  TotalBytes: Int64;
  TotalFreeBytes: Int64;
  DriveCount: Integer;
  i: Integer;
begin
  DriveBits := GetLogicalDrives;
  DriveCount := 0;
  
  // 计算驱动器数量
  for i := 0 to 25 do
    if (DriveBits and (1 shl i)) <> 0 then
      Inc(DriveCount);
      
  SetLength(Result, DriveCount);
  
  i := 0;
  for Drive := 'A' to 'Z' do
  begin
    if (DriveBits and (1 shl (Ord(Drive) - Ord('A')))) <> 0 then
    begin
      DriveRoot := Drive + ':\';
      Result[i].Letter := Drive;
      Result[i].DriveType := GetDriveType(PChar(DriveRoot));
      
      // 获取卷标和文件系统信息
      if GetVolumeInformation(PChar(DriveRoot), VolumeName, MAX_PATH,
         @VolumeSerialNumber, MaxComponentLength, FileSystemFlags,
         FileSystemName, MAX_PATH) then
      begin
        Result[i].VolumeName := VolumeName;
        Result[i].FileSystem := FileSystemName;
      end
      else
      begin
        Result[i].VolumeName := '';
        Result[i].FileSystem := '';
      end;
      
      // 获取磁盘空间信息
      if GetDiskFreeSpaceEx(PChar(DriveRoot), FreeBytesAvailable,
         TotalBytes, @TotalFreeBytes) then
      begin
        Result[i].TotalSize := TotalBytes;
        Result[i].FreeSize := FreeBytesAvailable;
      end
      else
      begin
        Result[i].TotalSize := 0;
        Result[i].FreeSize := 0;
      end;
      
      Inc(i);
    end;
  end;
end;

function GetDriveTypeString(DriveType: Integer): string;
begin
  case DriveType of
    DRIVE_UNKNOWN:     Result := '未知';
    DRIVE_NO_ROOT_DIR: Result := '无效';
    DRIVE_REMOVABLE:   Result := '可移动磁盘';
    DRIVE_FIXED:       Result := '固定磁盘';
    DRIVE_REMOTE:      Result := '网络磁盘';
    DRIVE_CDROM:       Result := '光盘';
    DRIVE_RAMDISK:     Result := '内存盘';
    else               Result := '未知类型';
  end;
end;

function GetDriveInfoString: string;
var
  DriveInfoArray: TDriveInfoArray;
  i: Integer;
  DriveInfo: string;
begin
  Result := '';
  DriveInfoArray := GetDriveInfoArray;
  
  for i := 0 to Length(DriveInfoArray) - 1 do
  begin
    if DriveInfoArray[i].DriveType in [DRIVE_FIXED, DRIVE_REMOVABLE, DRIVE_REMOTE] then
    begin
      DriveInfo := Format('%s: (%s) %s'#13#10'  文件系统: %s'#13#10'  总大小: %s'#13#10'  可用空间: %s',
        [DriveInfoArray[i].Letter, GetDriveTypeString(DriveInfoArray[i].DriveType),
         DriveInfoArray[i].VolumeName, DriveInfoArray[i].FileSystem,
         FormatByteSize(DriveInfoArray[i].TotalSize),
         FormatByteSize(DriveInfoArray[i].FreeSize)]);
         
      if Result <> '' then
        Result := Result + #13#10#13#10;
      Result := Result + DriveInfo;
    end;
  end;
end;


function GetFullSystemInfoString: string;
begin
  Result := Result + GetWindowsVersionString + ' ' + GetOSBitsString + sLineBreak;
  Result := Result + GetMemoryInfoString + sLineBreak;
  Result := Result + GetMonitorInfoString;
end;

end.