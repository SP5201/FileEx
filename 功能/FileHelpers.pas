unit FileHelpers;

interface

uses
  SysUtils, Windows, Classes, ShellAPI,
  IOUtils, ShlObj, Registry, ShLwApi, CryptoUtils;

type
  TAssociatedProgram = record
    Path: string;       // 程序完整路径
    DisplayName: string;  // 在打开方式中显示的名称
    Icon: HICON;      // 程序图标位图
  end;
  TAssociatedPrograms = TArray<TAssociatedProgram>;

const
  TEMP_POSTER_DIR = 'Data\Temp\Poster';
  TEMP_INFO_DIR = 'Data\Temp\Nfo';
  IMAGE_EXTENSIONS: array[0..3] of string = ('-poster.jpg', '-poster.png', '-fanart.jpg', '-fanart.png');

function OpenMovieFile(const FilePath: string): Boolean;

function OpenMovieFolder(const FilePath: string): Boolean;

function OpenFolder(const FolderPath: string): Boolean; overload;
function OpenFolder(const FolderPath: string; const SelectPath: string): Boolean; overload;

function OpenWithDialog(const FileName: string; ParentHandle: HWND = 0): Boolean;

function OpenWithProgram(const FilePath, ProgramPath: string): Boolean;

procedure InitializeDirectories;

function GetAssociatedPrograms(const FilePath: string): TAssociatedPrograms;

// 新增：获取临时文件路径的统一函数
function GetTempFilePath(const FilePath: string; const TempDir: string; const Extension: string): string;

// 新增：获取NFO临时文件路径
function GetTempNfoPath(const FilePath: string): string;

// 新增：获取海报临时文件路径
function GetTempPosterPath(const FilePath: string): string;

// 从MovieImageUtils移植：查找带特定扩展名的文件
function FindFileWithExtensions(const BasePath, BaseName: string; const Extensions: array of string): string;

function GetMovieImagePath(const FilePath: string): string;

function GetAssociatedImagePath(const FilePath: string): string;

function SelectFile(const ATitle, AFilter: string; AParentWnd: HWND): string;

implementation

uses
  WICImageHelper, XCGUI, CommDlg, ConfigUnit;


// 将常量定义移至接口部分，以便其他单元使用
// const
//   TEMP_POSTER_DIR = 'Data\Temp\Poster';
//   TEMP_INFO_DIR = 'Data\Temp\Nfo';

function OpenMovieFile(const FilePath: string): Boolean;
var
  PlayerPath: string;
  S: array[0..MAX_PATH] of Char;
begin
  Result := False;
  // 使用ConfigUnit中的全局Config对象
  if Assigned(Config) and (Config.ConfigData.PlayerPath <> '') and FileExists(Config.ConfigData.PlayerPath) then
  begin
      Result := OpenWithProgram(FilePath, Config.ConfigData.PlayerPath);
      if Result then
        Exit;
  end;

  // 2. 其次使用系统关联的播放器
  Result := ShellExecute(0, 'open', PChar(FilePath), nil, nil, SW_SHOW) > 32;
  if Result then
    Exit;

  // 3. 最后尝试使用 Windows Media Player
  GetWindowsDirectory(S, MAX_PATH);
  PlayerPath := TPath.Combine(S, 'system32\wmplayer.exe');

  if not FileExists(PlayerPath) then // 64位系统下可能在Program Files
  begin
      if SHGetFolderPath(0, CSIDL_PROGRAM_FILES, 0, SHGFP_TYPE_CURRENT, S) = S_OK then
          PlayerPath := TPath.Combine(S, 'Windows Media Player\wmplayer.exe');
  end;

  if not FileExists(PlayerPath) then // 32位系统 Program Files (x86)
  begin
      if SHGetFolderPath(0, CSIDL_PROGRAM_FILESX86, 0, SHGFP_TYPE_CURRENT, S) = S_OK then
          PlayerPath := TPath.Combine(S, 'Windows Media Player\wmplayer.exe');
  end;

  if FileExists(PlayerPath) then
  begin
    Result := OpenWithProgram(FilePath, PlayerPath);
  end;
end;

function OpenMovieFolder(const FilePath: string): Boolean;
begin
  Result := OpenFolder('', FilePath);
end;

function OpenFolder(const FolderPath: string): Boolean; overload;
var
  FullPath: string;
begin
  // 获取完整路径并标准化
  FullPath := TPath.GetFullPath(FolderPath);
  
  // 判断是文件还是文件夹
  if FileExists(FullPath) then
    // 如果是文件，直接使用文件路径作为选择路径
    Result := OpenFolder('', FullPath)
  else
    // 如果是文件夹，使用文件夹路径作为选择路径
    Result := OpenFolder(FullPath, FullPath);
end;

function OpenFolder(const FolderPath: string; const SelectPath: string): Boolean; overload;
var
  Params: string;
begin
  Result := False;

  try
    // 如果指定了文件夹路径，确保文件夹存在
    if (FolderPath <> '') and not DirectoryExists(FolderPath) then
    begin
      // 尝试创建目录
      if not ForceDirectories(FolderPath) then
        Exit;
    end;

    // 使用 /select 参数打开文件夹并选中指定路径
    Params := '/select,' + AnsiQuotedStr(SelectPath, '"');

    // 调用资源管理器打开文件夹并选中
    Result := ShellExecute(0,              // 父窗口句柄
      'open',         // 操作命令
      'explorer.exe', // 应用程序
      PChar(Params),  // 参数
      nil,            // 工作目录（不需要设置）
      SW_SHOWNORMAL   // 窗口显示方式
    ) > 32;  // 返回值大于32表示成功

  except
    Result := False;
  end;
end;


// 新增：提取文件的图标并转换为 HBITMAP
function ExtractFileIconAsBitmap(const APath: string): HICON;
var
  SI: TShFileInfo;
  LIcon: HICON;
begin
  Result := 0;
  if not FileExists(APath) then
    Exit;

  FillChar(SI, SizeOf(SI), 0);
  if SHGetFileInfo(PChar(APath), FILE_ATTRIBUTE_NORMAL, SI, SizeOf(SI), SHGFI_ICON or SHGFI_SMALLICON or SHGFI_USEFILEATTRIBUTES) <> 0 then
  begin
    LIcon := SI.hIcon;
    if LIcon <> 0 then
    begin
      Result := LIcon;
      //DestroyIcon(LIcon);
    end;
  end;
end;

// 新增：获取临时文件路径的统一函数
function GetTempFilePath(const FilePath: string; const TempDir: string; const Extension: string): string;
var
  FullPath: string;
  Hash: string;
  BaseDir: string;
  TempDirPath: string;
begin
  // 获取完整路径并标准化
  FullPath := TPath.GetFullPath(FilePath);
  
  // 使用完整路径生成SHA256哈希，确保唯一性
  Hash := SHA256Hash(FullPath);
  
  // 获取应用程序目录
  BaseDir := TPath.GetDirectoryName(ParamStr(0));
  
  // 生成临时文件路径
  TempDirPath := TPath.Combine(BaseDir, TempDir);
  
  // 确保目录存在
  if not DirectoryExists(TempDirPath) then
    ForceDirectories(TempDirPath);
    
  Result := TPath.Combine(TempDirPath, Hash + Extension);
end;

// 新增：获取NFO临时文件路径
function GetTempNfoPath(const FilePath: string): string;
begin
  Result := GetTempFilePath(FilePath, TEMP_INFO_DIR, '.nfo');
end;

// 新增：获取海报临时文件路径
function GetTempPosterPath(const FilePath: string): string;
begin
  Result := GetTempFilePath(FilePath, TEMP_POSTER_DIR, '.jpg');
end;

function OpenWithDialog(const FileName: string; ParentHandle: HWND = 0): Boolean;
var
  SEI: TShellExecuteInfo;
begin
  Result := False;
  if not FileExists(FileName) then Exit;

  ZeroMemory(@SEI, SizeOf(SEI));
  SEI.cbSize := SizeOf(SEI);
  SEI.fMask := SEE_MASK_INVOKEIDLIST or SEE_MASK_FLAG_NO_UI;
  SEI.Wnd := ParentHandle;
  SEI.lpVerb := 'openas';
  SEI.lpFile := PChar(FileName);
  SEI.nShow := SW_SHOWNORMAL;

  Result := ShellExecuteEx(@SEI);
end;

function OpenWithProgram(const FilePath, ProgramPath: string): Boolean;
begin
  Result := ShellExecute(0, nil, PChar(ProgramPath), PChar(FilePath), nil, SW_SHOW) > 32;
end;

procedure InitializeDirectories;
begin
  ForceDirectories(TPath.Combine(ExtractFilePath(ParamStr(0)), TEMP_POSTER_DIR));
  ForceDirectories(TPath.Combine(ExtractFilePath(ParamStr(0)), TEMP_INFO_DIR));
end;

function GetAssociatedPrograms(const FilePath: string): TAssociatedPrograms;
var
  RegCU, RegCR: TRegistry;
  FileExt, OpenWithKey, ProgID, AppName, AppPath, DisplayName, Cmd: string;
  Programs: TAssociatedPrograms;
  Values: TStringList;
  I: Integer;
  CmdBuffer: array[0..MAX_PATH] of Char;

  function ProgramExists(const Arr: TAssociatedPrograms; const Path: string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := 0 to High(Arr) do
      if SameText(Arr[I].Path, Path) then
        Exit(True);
  end;

  procedure AddProgramToList(const APath, ADisplayName: string);
  begin
    if not FileExists(APath) then Exit;
    if not ProgramExists(Programs, APath) then
    begin
      SetLength(Programs, Length(Programs) + 1);
      Programs[High(Programs)].Path := APath;
      Programs[High(Programs)].DisplayName := ADisplayName;
      Programs[High(Programs)].Icon := ExtractFileIconAsBitmap(APath);
    end;
  end;

  function GetDisplayName(const APath: string): string;
  var
    SI: TShFileInfo;
  begin
    Result := '';
    if APath = '' then Exit;

    FillChar(SI, SizeOf(SI), 0);
    if SHGetFileInfo(PChar(APath), 0, SI, SizeOf(SI), SHGFI_DISPLAYNAME) <> 0 then
    begin
      Result := SI.szDisplayName;
    end;
    
    if Result = '' then
      Result := ExtractFileName(APath);
  end;

begin
  SetLength(Programs, 0);
  Result := Programs;

  if not FileExists(FilePath) then
    Exit;

  FileExt := ExtractFileExt(FilePath);
  if FileExt = '' then
    Exit;

  Values := TStringList.Create;
  RegCU := TRegistry.Create(KEY_READ);
  RegCR := TRegistry.Create(KEY_READ);
  try
    RegCU.RootKey := HKEY_CURRENT_USER;
    RegCR.RootKey := HKEY_CLASSES_ROOT;

    // --- 1. 从用户的"打开方式"列表中获取程序 ---
    OpenWithKey := 'Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\' + FileExt + '\OpenWithList';
    if RegCU.OpenKeyReadOnly(OpenWithKey) then
    begin
      RegCU.GetValueNames(Values);
      for I := 0 to Values.Count - 1 do
      begin
        if SameText(Values[I], 'MRUList') or (Values[I] = '') then
          Continue;

        AppName := RegCU.ReadString(Values[I]);
        if AppName = '' then Continue;

        // 从 HKEY_CLASSES_ROOT\Applications\... 获取程序信息
        AppPath := '';
        DisplayName := '';
        if RegCR.OpenKeyReadOnly('Applications\' + AppName + '\shell\open\command') then
        begin
          Cmd := RegCR.ReadString('');
          StrPCopy(CmdBuffer, Cmd);
          PathRemoveArgs(CmdBuffer);
          AppPath := Trim(StrPas(CmdBuffer));
          if (Length(AppPath) > 1) and (AppPath[1] = '"') then
            AppPath := Copy(AppPath, 2, Length(AppPath) - 2);
          RegCR.CloseKey;
        end;

        if RegCR.OpenKeyReadOnly('Applications\' + AppName) then
        begin
            DisplayName := RegCR.ReadString('FriendlyAppName');
            RegCR.CloseKey;
        end;

        if DisplayName = '' then
            DisplayName := GetDisplayName(AppPath);
        
        AddProgramToList(AppPath, DisplayName);
      end;
      RegCU.CloseKey;
    end;

    // --- 2. 获取文件类型的默认程序 ---
    if RegCR.OpenKeyReadOnly(FileExt) then
    begin
      ProgID := RegCR.ReadString('');
      RegCR.CloseKey;
      
      if (ProgID <> '') and RegCR.OpenKeyReadOnly(ProgID + '\shell\open\command') then
      begin
        Cmd := RegCR.ReadString('');
        RegCR.CloseKey;

        StrPCopy(CmdBuffer, Cmd);
        PathRemoveArgs(CmdBuffer);
        AppPath := Trim(StrPas(CmdBuffer));
        if (Length(AppPath) > 1) and (AppPath[1] = '"') then
          AppPath := Copy(AppPath, 2, Length(AppPath) - 2);

        DisplayName := GetDisplayName(AppPath);
        AddProgramToList(AppPath, DisplayName);
      end;
    end;

    Result := Programs;
  finally
    Values.Free;
    RegCU.Free;
    RegCR.Free;
  end;
end;

// 从MovieImageUtils移植的函数
function FindFileWithExtensions(const BasePath, BaseName: string; const Extensions: array of string): string;
var
  I: Integer;
  CurrentPath: string;
begin
  Result := '';
  for I := Low(Extensions) to High(Extensions) do
  begin
    CurrentPath := TPath.Combine(BasePath, BaseName + Extensions[I]);
    if (FileExists(CurrentPath)) then
    begin
      Result := CurrentPath;
      Exit;
    end;
  end;
end;

function GetAssociatedImagePath(const FilePath: string): string;
begin
  if (FilePath = '') then
    Exit('');
  // 使用FileHelpers中的FindFileWithExtensions函数
  Result := FindFileWithExtensions(
    ExtractFilePath(FilePath),
    TPath.GetFileNameWithoutExtension(FilePath),
    IMAGE_EXTENSIONS);
end;

function GetMovieImagePath(const FilePath: string): string;
var
  SourceImagePath, TempImagePath: string;
begin
  Result := '';
  // 直接使用FileHelpers中的函数
  TempImagePath := GetTempPosterPath(FilePath);
  if (FileExists(TempImagePath)) then
    Exit(TempImagePath);
  SourceImagePath := GetAssociatedImagePath(FilePath);
  if (SourceImagePath <> '') then
  begin
    if (XWICImage_ScaleAndSaveToFile(SourceImagePath, TempImagePath, 147, 200)) then
      Exit(TempImagePath)
    else
      Exit(SourceImagePath);
  end;
end;

function SelectFile(const ATitle, AFilter: string; AParentWnd: HWND): string;
var
  OpenFileName: TOpenFileName;
  FileName: array[0..MAX_PATH] of Char;
  FilterStr: string;
begin
  Result := '';
  FillChar(FileName, SizeOf(FileName), 0);
  FillChar(OpenFileName, SizeOf(OpenFileName), 0);

  FilterStr := StringReplace(AFilter, '|', #0, [rfReplaceAll]) + #0;

  with OpenFileName do
  begin
    lStructSize := SizeOf(TOpenFileName);
    hwndOwner := AParentWnd;
    lpstrFile := FileName;
    nMaxFile := MAX_PATH;
    lpstrFilter := PChar(FilterStr);
    nFilterIndex := 1;
    lpstrTitle := PChar(ATitle);
    Flags := OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST;
  end;

  if GetOpenFileName(OpenFileName) then
  begin
    Result := FileName;
  end;
end;

end.




