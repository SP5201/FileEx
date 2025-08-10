unit ConfigUnit;

interface

uses
  System.SysUtils, superobject;

type
  TProxyType = (ptNoProxy, ptHttpProxy, ptSocks5Proxy);

  // 配置数据结构体
  TAppConfig = record
    WindowWidth: Integer;
    WindowHeight: Integer;
    VideoMuted: Boolean;
    ScanFormats: string;
    ExcludePaths: string;
    ExcludeSize: Integer;
    PlayerPath: string;
    ProxyType: TProxyType;
    ProxyAddress: string;
    ProxyPort: Integer;
    ThemeColorIndex: Integer; // 主题颜色索引：1=主题颜色1，2=主题颜色2
    HighlightColorIndex: Integer; // 高亮颜色索引：0-5对应6个高亮颜色

    // 默认值
    class function Default: TAppConfig; static;
  end;

type
  TConfig = class
  private
    FJson: ISuperObject;
    FConfigData: TAppConfig;
    FConfigFile: string;
    FIsModified: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    
    // 配置数据访问
    property ConfigData: TAppConfig read FConfigData;
    property IsModified: Boolean read FIsModified;
    
    // 配置数据更新方法
    procedure SetWindowSize(AWidth, AHeight: Integer);
    procedure SetVideoMuted(AMuted: Boolean);
    procedure SetScanFormats(AScanFormats: string);
    procedure SetExcludePaths(AExcludePaths: string);
    procedure SetExcludeSize(AExcludeSize: Integer);
    procedure SetPlayerPath(APlayerPath: string);
    procedure SetProxyType(AProxyType: TProxyType);
    procedure SetProxyAddress(AProxyAddress: string);
    procedure SetProxyPort(AProxyPort: Integer);
    procedure SetThemeColorIndex(AThemeColorIndex: Integer);
    procedure SetHighlightColorIndex(AHighlightColorIndex: Integer);

    // 文件操作
    function LoadFromFile(const AFileName: string): Boolean;
    procedure SaveToFile(const AFileName: string = '');
    
    // 便捷方法
    procedure MarkModified;
    procedure LoadFromJson;
    procedure SaveToJson;
    
    // 兼容性方法（保留原有接口）
    function GetString(const APath: string; const ADefault: string = ''): string;
    function GetInteger(const APath: string; const ADefault: Integer = 0): Integer;
    function GetBoolean(const APath: string; const ADefault: Boolean = False): Boolean;
    procedure SetString(const APath, AValue: string);
    procedure SetInteger(const APath: string; AValue: Integer);
    procedure SetBoolean(const APath: string; AValue: Boolean);
  end;

var
  Config: TConfig;

implementation

uses
  System.Classes, System.IOUtils;

{ TAppConfig }

class function TAppConfig.Default: TAppConfig;
begin
  Result.WindowWidth := 1199;
  Result.WindowHeight := 793;
  Result.VideoMuted := False;
  Result.ScanFormats := '*.mp4;*.avi;*.mkv;*.mov;*.wmv;*.flv;*.webm;*.mpg;*.mpeg;*.m4v;*.3gp;*.ts;*.m2ts;*.vob;*.ogv;*.divx';
  Result.ExcludePaths := '';
  Result.ExcludeSize := 0;
  Result.PlayerPath := '';
  Result.ProxyType := ptNoProxy;
  Result.ProxyAddress := '';
  Result.ProxyPort := 0;
  Result.ThemeColorIndex := 1; // 默认选择主题颜色1
  Result.HighlightColorIndex := 1; // 默认高亮颜色为索引1（蓝色）
end;

{ TConfig }

constructor TConfig.Create;
begin
  FJson := SO; // 创建一个空的JSON对象 {}
  FConfigData := TAppConfig.Default;
  FIsModified := False;
end;

destructor TConfig.Destroy;
begin
  // 退出时自动保存
  if FIsModified then
    SaveToFile;
  inherited;
end;

function TConfig.LoadFromFile(const AFileName: string): Boolean;
var
  LJsonString: string;
begin
  Result := False;
  FConfigFile := AFileName;
  
  if TFile.Exists(AFileName) then
  begin
    try
      LJsonString := TFile.ReadAllText(AFileName, TEncoding.UTF8);
      FJson := SO(LJsonString);
      // 从JSON加载到结构体
      LoadFromJson;
      Result := True;
    except
      FJson := SO; // 如果解析出错, 创建一个空对象
      FConfigData := TAppConfig.Default;
    end;
  end
  else
  begin
     FJson := SO; // 如果文件不存在, 创建一个空对象
     FConfigData := TAppConfig.Default;
  end;
  FIsModified := False;
end;

procedure TConfig.SetWindowSize(AWidth, AHeight: Integer);
begin
  if (FConfigData.WindowWidth <> AWidth) or (FConfigData.WindowHeight <> AHeight) then
  begin
    FConfigData.WindowWidth := AWidth;
    FConfigData.WindowHeight := AHeight;
    FIsModified := True;
  end;
end;

procedure TConfig.SetVideoMuted(AMuted: Boolean);
begin
  if FConfigData.VideoMuted <> AMuted then
  begin
    FConfigData.VideoMuted := AMuted;
    FIsModified := True;
  end;
end;


procedure TConfig.SetExcludePaths(AExcludePaths: string);
begin
  if FConfigData.ExcludePaths <> AExcludePaths then
  begin
    FConfigData.ExcludePaths := AExcludePaths;
    FIsModified := True;
  end;
end;

procedure TConfig.SetScanFormats(AScanFormats: string);
begin
  if FConfigData.ScanFormats <> AScanFormats then
  begin
    FConfigData.ScanFormats := AScanFormats;
    FIsModified := True;
  end;
end;

procedure TConfig.SetExcludeSize(AExcludeSize: Integer);
begin
  if FConfigData.ExcludeSize <> AExcludeSize then
  begin
    FConfigData.ExcludeSize := AExcludeSize;
    FIsModified := True;
  end;
end;

procedure TConfig.SetPlayerPath(APlayerPath: string);
begin
  if FConfigData.PlayerPath <> APlayerPath then
  begin
    FConfigData.PlayerPath := APlayerPath;
    FIsModified := True;
  end;
end;

procedure TConfig.SetProxyAddress(AProxyAddress: string);
begin
  if FConfigData.ProxyAddress <> AProxyAddress then
  begin
    FConfigData.ProxyAddress := AProxyAddress;
    FIsModified := True;
  end;
end;

procedure TConfig.SetProxyPort(AProxyPort: Integer);
begin
  if FConfigData.ProxyPort <> AProxyPort then
  begin
    FConfigData.ProxyPort := AProxyPort;
    FIsModified := True;
  end;
end;

procedure TConfig.SetProxyType(AProxyType: TProxyType);
begin
  if FConfigData.ProxyType <> AProxyType then
  begin
    FConfigData.ProxyType := AProxyType;
    FIsModified := True;
  end;
end;

procedure TConfig.SetThemeColorIndex(AThemeColorIndex: Integer);
begin
  if FConfigData.ThemeColorIndex <> AThemeColorIndex then
  begin
    FConfigData.ThemeColorIndex := AThemeColorIndex;
    FIsModified := True;
  end;
end;

procedure TConfig.SetHighlightColorIndex(AHighlightColorIndex: Integer);
begin
  if FConfigData.HighlightColorIndex <> AHighlightColorIndex then
  begin
    FConfigData.HighlightColorIndex := AHighlightColorIndex;
    FIsModified := True;
  end;
end;

procedure TConfig.MarkModified;
begin
  FIsModified := True;
end;

procedure TConfig.LoadFromJson;
begin
  FConfigData.WindowWidth := GetInteger('window.width', FConfigData.WindowWidth);
  FConfigData.WindowHeight := GetInteger('window.height', FConfigData.WindowHeight);
  FConfigData.VideoMuted := GetBoolean('video.muted', FConfigData.VideoMuted);
  FConfigData.ScanFormats := GetString('scan.formats', FConfigData.ScanFormats);
  FConfigData.ExcludePaths := GetString('scan.exclude_paths', FConfigData.ExcludePaths);
  FConfigData.ExcludeSize := GetInteger('scan.exclude_size', FConfigData.ExcludeSize);
  FConfigData.PlayerPath := GetString('player.path', FConfigData.PlayerPath);
  FConfigData.ProxyType := TProxyType(GetInteger('proxy.type', Ord(FConfigData.ProxyType)));
  FConfigData.ProxyAddress := GetString('proxy.address', FConfigData.ProxyAddress);
  FConfigData.ProxyPort := GetInteger('proxy.port', FConfigData.ProxyPort);
  FConfigData.ThemeColorIndex := GetInteger('theme.color_index', FConfigData.ThemeColorIndex);
  FConfigData.HighlightColorIndex := GetInteger('highlight.color_index', FConfigData.HighlightColorIndex);
end;

procedure TConfig.SaveToJson;
begin
  SetInteger('window.width', FConfigData.WindowWidth);
  SetInteger('window.height', FConfigData.WindowHeight);
  SetBoolean('video.muted', FConfigData.VideoMuted);
  SetString('scan.formats', FConfigData.ScanFormats);
  SetString('scan.exclude_paths', FConfigData.ExcludePaths);
  SetInteger('scan.exclude_size', FConfigData.ExcludeSize);
  SetString('player.path', FConfigData.PlayerPath);
  SetInteger('proxy.type', Ord(FConfigData.ProxyType));
  SetString('proxy.address', FConfigData.ProxyAddress);
  SetInteger('proxy.port', FConfigData.ProxyPort);
  SetInteger('theme.color_index', FConfigData.ThemeColorIndex);
  SetInteger('highlight.color_index', FConfigData.HighlightColorIndex);
end;

procedure TConfig.SaveToFile(const AFileName: string);
var
  FileName: string;
begin
  if AFileName <> '' then
    FileName := AFileName
  else
    FileName := FConfigFile;
    
  if FileName = '' then
    Exit;
    
  // 将结构体数据保存到JSON
  SaveToJson;
  
  // 保存到文件
  TFile.WriteAllText(FileName, FJson.AsJSON(True, False), TEncoding.UTF8);
  FIsModified := False;
end;

function TConfig.GetBoolean(const APath: string; const ADefault: Boolean): Boolean;
var
  Obj: ISuperObject;
begin
  Obj := FJson[APath];
  if Assigned(Obj) and (Obj.DataType <> stNull) then
    Result := Obj.AsBoolean
  else
    Result := ADefault;
end;

function TConfig.GetInteger(const APath: string; const ADefault: Integer): Integer;
var
  Obj: ISuperObject;
begin
  Obj := FJson[APath];
  if Assigned(Obj) and (Obj.DataType <> stNull) then
    Result := Obj.AsInteger
  else
    Result := ADefault;
end;

function TConfig.GetString(const APath: string; const ADefault: string): string;
var
  Obj: ISuperObject;
begin
  Obj := FJson[APath];
  if Assigned(Obj) and (Obj.DataType <> stNull) then
    Result := Obj.AsString
  else
    Result := ADefault;
end;

procedure TConfig.SetBoolean(const APath: string; AValue: Boolean);
begin
  FJson.B[APath] := AValue;
end;

procedure TConfig.SetInteger(const APath: string; AValue: Integer);
begin
  FJson.I[APath] := AValue;
end;

procedure TConfig.SetString(const APath, AValue: string);
begin
  FJson.S[APath] := AValue;
end;

end. 