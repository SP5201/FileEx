unit IconExtractorUnit;

interface

uses
  Winapi.Windows, System.SysUtils;

function ExtractHighestResolutionIcon(const AFileName: string): HICON;

implementation

uses
  System.Classes;

type
  PGrpIconDirEntry = ^TGrpIconDirEntry;
  TGrpIconDirEntry = packed record
    bWidth: Byte;
    bHeight: Byte;
    bColorCount: Byte;
    bReserved: Byte;
    wPlanes: Word;
    wBitCount: Word;
    dwBytesInRes: DWord;
    nID: Word;
  end;

  PGrpIconDir = ^TGrpIconDir;
  TGrpIconDir = packed record
    idReserved: Word;
    idType: Word;
    idCount: Word;
    idEntries: array[0..0] of TGrpIconDirEntry;
  end;

function EnumResNameCallback(hModule: HMODULE; lpszType: PChar; lpszName: PChar; lParam: LPARAM): BOOL; stdcall;
begin
  PPointer(lParam)^ := lpszName;
  Result := FALSE;
end;

function ExtractHighestResolutionIcon(const AFileName: string): HICON;
var
  hLibrary: HMODULE;
  hResInfo: HRSRC;
  hResData: HGLOBAL;
  pIconDir: PGrpIconDir;
  pIconData: Pointer;
  IconName: PChar;
  BestEntry: PGrpIconDirEntry;
  i, currentSize, bestSize, nIconID, w, h: Integer;
begin
  Result := 0;
  if (AFileName = '') or (not FileExists(AFileName)) then
    Exit;

  hLibrary := LoadLibraryEx(PChar(AFileName), 0, LOAD_LIBRARY_AS_DATAFILE or DONT_RESOLVE_DLL_REFERENCES);
  if hLibrary = 0 then
    Exit;

  try
    // 优先尝试寻找名为 'MAINICON' 的图标资源, 这是一个常见的程序主图标名称约定.
    // 这通常是文件资源管理器会显示的图标.
    IconName := 'MAINICON';
    hResInfo := FindResource(hLibrary, IconName, RT_GROUP_ICON);

    // 如果找不到 'MAINICON', 则回退到枚举第一个可用的图标组.
    if hResInfo = 0 then
    begin
      IconName := nil;
      EnumResourceNames(hLibrary, RT_GROUP_ICON, @EnumResNameCallback, LPARAM(@IconName));

      if IconName = nil then
        Exit;

      hResInfo := FindResource(hLibrary, IconName, RT_GROUP_ICON);
      if hResInfo = 0 then
        Exit;
    end;

    hResData := LoadResource(hLibrary, hResInfo);
    if hResData = 0 then
      Exit;

    pIconDir := PGrpIconDir(LockResource(hResData));
    if pIconDir = nil then
      Exit;

    if pIconDir.idCount = 0 then
      Exit;

    // 在图标组中查找分辨率最高的图标.
    BestEntry := @pIconDir.idEntries[0];
    w := BestEntry.bWidth;
    h := BestEntry.bHeight;
    if w = 0 then w := 256; // 对于大图标, 宽度和高度字段可能为0, 表示256x256
    if h = 0 then h := 256;
    bestSize := w * h;

    for i := 1 to pIconDir.idCount - 1 do
    begin
      w := pIconDir.idEntries[i].bWidth;
      h := pIconDir.idEntries[i].bHeight;
      if w = 0 then w := 256;
      if h = 0 then h := 256;
      currentSize := w * h;

      if currentSize > bestSize then
      begin
        BestEntry := @pIconDir.idEntries[i];
        bestSize := currentSize;
      end;
    end;

    nIconID := BestEntry.nID;
    hResInfo := FindResource(hLibrary, MAKEINTRESOURCE(nIconID), RT_ICON);
    if hResInfo = 0 then
      Exit;

    hResData := LoadResource(hLibrary, hResInfo);
    if hResData = 0 then
      Exit;

    pIconData := LockResource(hResData);
    if pIconData = nil then
      Exit;

    Result := CreateIconFromResourceEx(pIconData, SizeofResource(hLibrary, hResInfo), True, $00030000, 0, 0, LR_DEFAULTCOLOR);
  finally
    FreeLibrary(hLibrary);
  end;
end;

end. 