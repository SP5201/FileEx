{*******************************************************************************
  桌面管理器主窗口单元
  功能：提供视频文件管理的主界面，包括文件拖拽、视频预览、搜索、编辑等功能
  支持视频格式：mp4, avi, mkv, mov, wmv, flv, webm, mpg, mpeg, m4v, 3gp, ts, m2ts, vob, ogv, divx

  主要功能：
  - 视频文件扫描和数据库管理
  - 视频预览播放（支持静音、循环播放）
  - 文件拖拽导入
  - 按演员、类型、关键词搜索
  - 右键菜单操作（播放、编辑、删除等）
  - 网络速度监控显示

  Copyright (c) 2025 zotptptp
  Email: zoutp@qq.com
  All rights reserved.
*******************************************************************************}

unit MainForm;

interface

uses
  SysUtils, Messages, ShellAPI, Math, {$I  XCGuiStyle.inc}, UI_MainForm,
  NetworkSpeedMonitor, MovieManager, Windows, Classes, Wincodec,
  MovieInfoEditForm, AboutForm, MovieSearch, MovieInfoUnit, FileHelpers,
  VideoDurationUnit, ConfigUnit, ConfigForm, SkinForm;

function LoadMainForm: Integer;

function OnVideoSearchComplete(Data: Integer): Integer; stdcall;

type
  TMainForm = class(TMainFormUI)
  private
    FMenuUI: TPopupMenuUI;
    FCurrentVideoFile: TVideoFile;
  protected
    procedure OnDroppedFiles(const FilePaths: TArray<string>); override;
    procedure OnVideoFrameDecoded(const AFrameData: Pointer; AWidth, AHeight: Integer; APtsSec: Double; AUserData: Pointer);
    procedure OnVideoDecodeComplete(AUserData: Pointer);
    procedure OnVideoDecodeError(const AErrorMessage: string; AUserData: Pointer);

    procedure OnMovieListViewSelectItem(Sender: TObject; const Path: string);
    procedure OnMovieListViewRButtonDown(Sender: TObject; const Path: string);
    procedure OnMovieListViewItemRename(Sender: TObject; const Path, NewTitle: string);


    // 重写UI单元的事件处理方法
    procedure SearchEditEvents(const SearchEdit: TSearchEditUI; EventType: UINT; SearchText: PWideChar; UserData: lParam); override;
    procedure MenuEvents(EventType: UINT; MenuID: wParam; UserData: lParam); override;
    procedure ButtonClick(const Button: TSvgBtnUI); override;
    procedure ButtonCheck(const Button: TSvgBtnUI); override;
  public
    destructor Destroy; override;
    procedure UpdateMovieListView(const FilePath: string; const MovieTitle: string; Status: TMovieOperationStatus; IsComplete: Boolean);
    procedure SetConfig;
    procedure LoadConfig;
  end;

implementation

var
  Form: TMainForm;
  SpeedManager: TNetworkSpeedMonitor;
  MovieSQLManager: TMovieSQLManager;
  SearchThread: TVideoSearchThread;

function LoadMainForm;
var
  ConfigFile: string;
begin
  InitializeDirectories;

  // 创建配置对象
  Config := TConfig.Create;
  ConfigFile := IncludeTrailingPathDelimiter(GetCurrentDir) + 'config.json';
  Config.LoadFromFile(ConfigFile);

  Form := TMainForm.FromXml('main.xml') as TMainForm;
  Form.SetMinimumSize(1190, 825);
  Form.LoadConfig;
  Form.MovieListViewUI.OnSelectItem := Form.OnMovieListViewSelectItem;
  Form.MovieListView_SearchUI.OnSelectItem := Form.OnMovieListViewSelectItem;
  Form.MovieListViewUI.OnRButtonDown := Form.OnMovieListViewRButtonDown;
  Form.MovieListView_SearchUI.OnRButtonDown := Form.OnMovieListViewRButtonDown;
  Form.MovieListViewUI.OnItemRename := Form.OnMovieListViewItemRename;
  Form.MovieListView_SearchUI.OnItemRename := Form.OnMovieListViewItemRename;

  Form.Show;
  Result := Form.Handle;
  SpeedManager := TNetworkSpeedMonitor.Create(nil);
  SpeedManager.OnSpeedUpdated := Form.UpdateNetworkSpeeds;
  SpeedManager.Active := True;

  MovieSQLManager := TMovieSQLManager.Create(IncludeTrailingPathDelimiter(GetCurrentDir) + 'Data\Movie.DB');
  MovieSQLManager.SetOperationCallback(Form.UpdateMovieListView);
  // 加载电影列表
  MovieSQLManager.GetAllMovies;

  SearchThread := TVideoSearchThread.Create;
  SearchThread.OnComplete := Integer(@OnVideoSearchComplete);
end;

{ TMainForm }

destructor TMainForm.Destroy;
begin
  // 保存配置（只更新数据，不保存文件）
  SetConfig;

  if Assigned(FCurrentVideoFile) then
    FCurrentVideoFile.Free;
  if Assigned(SearchThread) then
    SearchThread.Free;
  if Assigned(SpeedManager) then
    SpeedManager.Free;
  if Assigned(MovieSQLManager) then
    MovieSQLManager.Free;
  if Assigned(Config) then
    Config.Free;
  inherited;
end;

function OnVideoSearchComplete(Data: Integer): Integer; stdcall;
var
  SearchData: PSearchResultsData;
begin
  SearchData := PSearchResultsData(Data);
  Form.SetLoadingText(Format('已扫描%d个文件' + #13#10 + '其中视频文件%d个', [SearchData.ScannedCount, SearchData.MatchedCount]));
  if SearchData.IsComplete then
  begin
    Form.SetLoadingText(Format('已扫描%d个文件' + #13#10 + '其中视频文件%d个' + #13#10 + '数据核对请稍等...', [SearchData.ScannedCount, SearchData.MatchedCount]));
    // 新增：扫描完成后，状态栏提示
    Form.StatusBarText := Format('扫描完成：共扫描%d个文件，视频文件%d个', [SearchData.ScannedCount, SearchData.MatchedCount]);
    MovieSQLManager.AddMovies(SearchData.Results);
    Form.HideLoading;
  end;
  Dispose(SearchData);
  Result := 0;
end;

procedure TMainForm.OnMovieListViewSelectItem(Sender: TObject; const Path: string);
var
  MovieInfo: TMovieInfo;
  targetWidth, targetHeight: Integer;
  aspectRatio: Double;
  panelRect: TRect;
begin
      // 清空MoviePanelUI
  if Assigned(MoviePanelUI) then
    MoviePanelUI.Clear;

  if Assigned(FCurrentVideoFile) and (Path = FCurrentVideoFile.FilePath) then
    Exit;

  try
    // 修正：彻底销毁旧的视频文件对象，确保线程和资源被释放
    if Assigned(FCurrentVideoFile) then
    begin
      FreeAndNil(FCurrentVideoFile);
    end;

    PlayBtnVisible := True;

    MovieInfo := GetMovieInfo(Path);
    try
      if Assigned(MoviePanelUI) then
      begin
        MoviePanelUI.MoviePath := Path;
        MoviePanelUI.TagBox.Rating := MovieInfo.Rating;
        MoviePanelUI.MarqueeText := MovieInfo.Title;
        MoviePanelUI.TagBox.Year := MovieInfo.Year;
        MoviePanelUI.PlotText := MovieInfo.Plot;
        MoviePanelUI.TagBox.ActorsText := MovieInfo.ActorsText;
      end;

      // 为新视频创建全新的 TVideoFile 实例
      FCurrentVideoFile := TVideoFile.Create(Path);

      // 以MoviePanelUI的宽度为基准进行缩放，以填充宽度
      XEle_GetWndClientRectDPI(MoviePanelUI.Handle, panelRect);
      targetWidth := panelRect.Width;

      // 计算目标高度，同时避免除零错误
      if FCurrentVideoFile.Info.Height > 0 then
      begin
        aspectRatio := FCurrentVideoFile.Info.Width / FCurrentVideoFile.Info.Height;
        targetHeight := Round(targetWidth / aspectRatio);
      end
      else // 对于没有视频或高度信息无效的情况，使用默认的16:9比例
      begin
        targetHeight := Round(targetWidth * 9 / 16);
      end;

      FCurrentVideoFile.VideoSize := TSize.Create(targetWidth, targetHeight);

      // 新增：同步静音按钮状态到新视频对象
      FCurrentVideoFile.Muted := XBtn_IsCheck(XC_GetObjectByName('左侧展示_静音按钮'));

      if (not FCurrentVideoFile.Info.HasVideo) and (not FCurrentVideoFile.Info.HasAudio) then
      begin
        if Assigned(MoviePanelUI) then
        begin
          MoviePanelUI.TagBox.Resolution := '非音视频文件';
          MoviePanelUI.TagBox.Duration := 0;
          MoviePanelUI.TagBox.FileFormat := '';
          MoviePanelUI.TagBox.FrameRate := '';
          MoviePanelUI.TagBox.Bitrate := 0;
        end;
        PlayBtnVisible := False;
      end
      else
      begin
        if Assigned(MoviePanelUI) then
        begin
          MoviePanelUI.TagBox.Resolution := FCurrentVideoFile.Info.Resolution;
          MoviePanelUI.TagBox.Duration := FCurrentVideoFile.Info.Duration;
          MoviePanelUI.TagBox.FileFormat := FCurrentVideoFile.Info.FileFormat;
          MoviePanelUI.TagBox.FrameRate := FCurrentVideoFile.Info.FrameRate;
          MoviePanelUI.TagBox.Bitrate := FCurrentVideoFile.Info.BitRate;
        end;
        PlayBtnVisible := FCurrentVideoFile.Info.HasVideo;
      end;

      if Assigned(MoviePanelUI) then
        MoviePanelUI.TagBox.TagText := MovieInfo.GenresText;
    finally
      MovieInfo.Free;
    end;

    if Assigned(FCurrentVideoFile) then
    begin
      FCurrentVideoFile.AudioPlaybackEnabled := True;
      if FCurrentVideoFile.Info.Duration > 240 then
        FCurrentVideoFile.StartTime := 200
      else
        FCurrentVideoFile.StartTime := 0;
      FCurrentVideoFile.LoopPlayback := True;
      FCurrentVideoFile.EndTime := 0;
      FCurrentVideoFile.DecodeAllFramesAsync(OnVideoFrameDecoded, FCurrentVideoFile, OnVideoDecodeComplete, OnVideoDecodeError, -1, 1.0);
    end;
  except
    on E: Exception do
    begin
      StatusBarText := '视频处理错误: ' + E.Message;
      if Assigned(FCurrentVideoFile) then
      begin
        FCurrentVideoFile.Free;
        FCurrentVideoFile := nil;
      end;
      if Assigned(MoviePanelUI) then
        MoviePanelUI.Clear;
      PlayBtnVisible := False;
    end;
  end;

  MuteBtn.Show(True);
end;

procedure TMainForm.OnMovieListViewRButtonDown(Sender: TObject; const Path: string);
var
  AssociatedPrograms: TAssociatedPrograms;
  i: Integer;
  ListView: TMovieListViewUI;
begin
  ListView := TMovieListViewUI(Sender);
  FMenuUI := TPopupMenuUI.Create(ListView.Handle);
  FMenuUI.AddItemSvg(200, '播放', 0, '窗口组件\运行.svg');
  FMenuUI.AddItem(201, '打开所在目录', 0);
  FMenuUI.AddItem(0, '', XC_ID_ROOT, menu_item_flag_separator);
  FMenuUI.AddItem(210, '视频工具', 0);
  FMenuUI.AddItem(205, '格式转换', 210);
  FMenuUI.AddItem(206, '视频编辑', 210);
  FMenuUI.AddItem(207, '字幕管理', 210);

  FMenuUI.AddItem(0, '', XC_ID_ROOT, menu_item_flag_separator);
  FMenuUI.AddItem(300, '打开方式', 0);
  AssociatedPrograms := GetAssociatedPrograms(Path);
  for i := 0 to Length(AssociatedPrograms) - 1 do
  begin
    if AssociatedPrograms[i].Icon <> 0 then
    begin
      FMenuUI.AddItemIcon(303 + i, PChar(AssociatedPrograms[i].DisplayName), 300, XImage_LoadFromHICON(AssociatedPrograms[i].Icon), 0);
      DestroyIcon(AssociatedPrograms[i].Icon);
    end
    else
      FMenuUI.AddItem(303 + i, PChar(AssociatedPrograms[i].DisplayName), 300);
  end;
  FMenuUI.AddItem(301, '选择其他应用', 300);
  FMenuUI.AddItemSvg(202, '编辑', 0, '窗口组件\编辑.svg', 15, 15);
  FMenuUI.AddItem(203, '重命名', 0);
  FMenuUI.AddItemSvg(204, '删除', 0, '窗口组件\删除.svg');
  FMenuUI.Popup(ListView, 0, 0);
end;

procedure TMainForm.OnMovieListViewItemRename(Sender: TObject; const Path, NewTitle: string);
begin
  MovieSQLManager.UpdateMovieTitle(Path, NewTitle);
end;

procedure TMainForm.OnDroppedFiles(const FilePaths: TArray<string>);
begin
  SearchThread.FilePaths := FilePaths;
  SearchThread.SearchPattern := Config.ConfigData.ScanFormats;
  SearchThread.ExcludePaths := Config.ConfigData.ExcludePaths;
  if SearchThread.Start then
  begin
    ShowLoading('正在加载...');
  end
  else
    MessageBox(Handle, '正忙', '提示', MB_OK);
end;

procedure TMainForm.UpdateMovieListView(const FilePath: string; const MovieTitle: string; Status: TMovieOperationStatus; IsComplete: Boolean);
var
  YearStr: string;
  MovieInfo: TMovieInfo;
begin
  if FilePath <> '' then
  begin
    case Status of
      mosQuerySuccess, mosInsertSuccess:
        begin
          MovieInfo := GetMovieInfo(FilePath);
          if Assigned(MovieInfo) and (MovieInfo.Year > 0) then
            YearStr := IntToStr(MovieInfo.Year)
          else
            YearStr := '';
          MovieListViewUI.AddItem(XImage_LoadFile(PChar(GetMovieImagePath(FilePath))), MovieTitle, YearStr, FilePath);
          MovieInfo.Free;
        end;
      mosDeleteSuccess:
        begin
          Form.MovieListViewUI.DeleteItemByPath(FilePath);
          if MovieListView_SearchUI.IsShow then
            Form.MovieListView_SearchUI.DeleteItemByPath(FilePath);
          DeleteTempInfo(FilePath);
        end;
      mosActorQuerySuccess:
        Form.MovieListView_SearchUI.AddItem(XImage_LoadFile(PChar(GetMovieImagePath(FilePath))), MovieTitle, '', FilePath);
      mosGenreQuerySuccess:
        Form.MovieListView_SearchUI.AddItem(XImage_LoadFile(PChar(GetMovieImagePath(FilePath))), MovieTitle, '', FilePath);
      mosKeywordQuerySuccess:
        Form.MovieListView_SearchUI.AddItem(XImage_LoadFile(PChar(GetMovieImagePath(FilePath))), MovieTitle, '', FilePath);
      // 合并原本多余的begin...end内容到此处
      mosUpdateTitleSuccess:
        begin
          Form.MovieListViewUI.UpdateTitle(FilePath, MovieTitle);
          if MovieListView_SearchUI.IsShow then
            Form.MovieListView_SearchUI.UpdateTitle(FilePath, MovieTitle);
          Exit;
        end;
      mosUnknownError:
        begin
          if FilePath = 'ERROR' then
            StatusBarText := MovieTitle;
        end;
    end;
  end;

  if IsComplete then
  begin
    if (MovieListViewUI.Item_GetCount(0) > 0) and (MovieListViewUI.IsShow) then
    begin
      MovieListViewUI.Redraw();
      MuteBtn.Show(True);
      PreviewBtn.Show(True);
    end
    else
      MuteBtn.Show(False);
    PreviewBtn.Show(False);
    FavoriteCountLabel.Text := Format('共收录<color=#%s>%d</color>个视频', [RGBAToHex(Theme_PrimaryColor, 8), MovieSQLManager.GetMovieCount]);
    if (MovieListView_SearchUI.Item_GetCount(0) > 0) and (MovieListView_SearchUI.IsShow) then
      MovieListView_SearchUI.Redraw();
  end;
end;

procedure TMainForm.OnVideoFrameDecoded(const AFrameData: Pointer; AWidth, AHeight: Integer; APtsSec: Double; AUserData: Pointer);
var
  VideoFile: TVideoFile;
begin
  // This is now very simple. The data is already scaled.
  if (AFrameData = nil) or (AWidth <= 0) or (AHeight <= 0) then
    Exit;

  // Only process frames for the currently active video file
  VideoFile := TVideoFile(AUserData);
  if not Assigned(FCurrentVideoFile) or (VideoFile <> FCurrentVideoFile) then
    Exit;

  if not Assigned(MoviePanelUI) then
    Exit;

  MoviePanelUI.UpdateVideoFrame(AFrameData, AWidth * AHeight * 4, AWidth, AHeight);
end;

procedure TMainForm.OnVideoDecodeComplete(AUserData: Pointer);
var
  VideoFile: TVideoFile;
begin
  VideoFile := TVideoFile(AUserData);
  // 只处理当前活动视频的事件，不再负责销毁旧对象
  if Assigned(FCurrentVideoFile) and (VideoFile = FCurrentVideoFile) then
  begin
    // 例如：可以在这里更新状态栏为"预览播放完成"
  end;
end;

procedure TMainForm.OnVideoDecodeError(const AErrorMessage: string; AUserData: Pointer);
var
  VideoFile: TVideoFile;
begin
  VideoFile := TVideoFile(AUserData);
  // 只处理当前活动视频的事件
  if Assigned(FCurrentVideoFile) and (VideoFile = FCurrentVideoFile) then
  begin
    StatusBarText := '获取视频解码失败: ' + AErrorMessage;
  end;
end;

procedure TMainForm.LoadConfig;
var
  WindowRect: TRect;
begin
  if Assigned(Config) then
  begin
    WindowRect.Right := Max(Config.ConfigData.WindowWidth, 1190);
    WindowRect.Bottom := Max(Config.ConfigData.WindowHeight, 825);
    SetRect(WindowRect);
    Center;
    Form.SetMutedState(Config.ConfigData.VideoMuted);
  end;
end;

procedure TMainForm.SetConfig;
var
  WindowRect: TRect;
begin
  if Assigned(Config) and Assigned(FCurrentVideoFile) then
  begin
    GetClientRect(WindowRect);
    Config.SetWindowSize(WindowRect.Right, WindowRect.Bottom);
    Config.SetVideoMuted(FCurrentVideoFile.Muted)
  end;
end;

procedure TMainForm.SearchEditEvents(const SearchEdit: TSearchEditUI; EventType: UINT; SearchText: PWideChar; UserData: lParam);
var
  GenreName: string;
  LSearchText: string;
begin
  case EventType of
    XE_SEARCH_EDIT_RETURN:
      begin
        // 处理搜索框事件
        if (SearchText = '') then
        begin
          SearchMode := False;
          MovieListView_SearchUI.DeleteItemAll;
        end
        else
        begin
          SearchMode := True;
          MovieListView_SearchUI.DeleteItemAll;
          // 执行搜索
          LSearchText := string(SearchEdit.GetText_Temp);
          MovieSQLManager.SearchByKeyword(LSearchText);
        end;
      end;
    XE_TAGBOX_BUTTON_CLICK:
      begin
        // 处理标签点击事件
        GenreName := string(PChar(SearchText));
        if GenreName <> '' then
        begin
          try
            SearchMode := True;
            MovieListView_SearchUI.DeleteItemAll;
            // 按类型搜索
            MovieSQLManager.GetAllMoviesByGenre(GenreName);
          except
            on E: Exception do
            begin
              StatusBarText := Format('搜索类型出错: [%s] %s', [E.ClassName, E.Message]);
            end;
          end;
        end;
      end;
  end;
end;

procedure TMainForm.MenuEvents(EventType: UINT; MenuID: wParam; UserData: lParam);
var
  MoviePath: string;
  AssociatedPrograms: TAssociatedPrograms;
  ListViewUI: TMovieListViewUI;
  SourceHandle: Integer;
begin
  SourceHandle := Integer(UserData);

  // 处理主菜单（菜单按钮）
  if XC_GetObjectByName('菜单按钮') = SourceHandle then
  begin
    case MenuID of
      499: // 设置菜单项
        TConfigForm.Create(Handle);
      501: // 关于菜单项
        TAboutForm.Create(Handle);
    end;
    Exit;
  end;

  // 处理视频列表右键菜单
  if (XC_GetObjectByName('主窗口_视频列表') = SourceHandle) or (XC_GetObjectByName('主窗口_视频列表_搜索') = SourceHandle) then
  begin
    // 根据当前模式选择正确的ListView实例
    if SearchMode then
      ListViewUI := MovieListView_SearchUI
    else
      ListViewUI := MovieListViewUI;

    MoviePath := ListViewUI.GetItemRightClickPath;

    case MenuID of
      200: // 播放
        begin
          if OpenMovieFile(MoviePath) then
            StatusBarText := '正在播放: ' + MoviePath
          else
            StatusBarText := '播放失败: ' + MoviePath;
        end;

      201: // 打开所在目录
        OpenMovieFolder(MoviePath);

      202: // 编辑
        TVideoEditForm.Create(Handle, MoviePath);

      203: // 重命名
        ListViewUI.ReName(ListViewUI.RightClickGroup, ListViewUI.RightClickItem);

      204: // 删除
        // 删除影片
        MovieSQLManager.RemoveMovie(MoviePath);

      205: // 显示时长
        begin
          // 显示时长的处理逻辑（待实现）
        end;

      301: // 选择其他应用打开
        OpenWithDialog(MoviePath, Form.HWND);

    else
      if MenuID >= 303 then
      begin
        // 处理关联程序打开
        AssociatedPrograms := GetAssociatedPrograms(MoviePath);
        if (Integer(MenuID) - 303) < Length(AssociatedPrograms) then
          OpenWithProgram(MoviePath, AssociatedPrograms[MenuID - 303].Path);
      end;
    end;
  end;
end;

procedure TMainForm.ButtonClick(const Button: TSvgBtnUI);
var
  MoviePath: string;
begin
  if Button.Name = '左侧展示_播放按钮' then
  begin
    MoviePath := MoviePanelUI.MoviePath;
    if OpenMovieFile(MoviePath) then
    begin
      StatusBarText := '正在播放: ' + MoviePath;
    end
    else
      StatusBarText := '播放失败: ' + MoviePath;
  end
  else if Button.Name = '返回主视频按钮' then
    SearchMode := False
  else if Button.Name = '换肤按钮' then
    TSkinForm.Create(Handle)
  else if Button.Name = '菜单按钮' then
  begin
    if Assigned(Button.Tooltip) then
      THintUI(Button.Tooltip).Close;   

    FMenuUI := TPopupMenuUI.Create(Button.Handle);
    FMenuUI.AddItemSvg(499, '设置', 0, '窗口组件\设置.svg', 16, 16);
    FMenuUI.AddItem(500, '帮助', 0);
    FMenuUI.AddItemSvg(501, '关于', 500, '窗口组件\提示.svg', 14, 14);
    FMenuUI.AddItemSvg(502, '版本更新', 500, '', 0, 0);
    FMenuUI.Popup(Button, 0, 4, menu_popup_position_center_top, True);
  end;
end;

procedure TMainForm.ButtonCheck(const Button: TSvgBtnUI);
var
  CurrentListView: TMovieListViewUI;
  SelectedPath: string;
begin
  if Assigned(FCurrentVideoFile) then
  begin
    // Video is playing/loaded
    if Button.Name = '左侧展示_静音按钮' then
    begin
      FCurrentVideoFile.Muted := Button.Check;
    end
    else if (Button.Name = '左侧展示_ 预览按钮') and Button.Check then // Stop preview
    begin
      FCurrentVideoFile.Terminate;
      FreeAndNil(FCurrentVideoFile);
      MoviePanelUI.ClearVideo;
      MoviePanelUI.Redraw;
    end;
  end
  else
  begin
    if (Button.Name = '左侧展示_ 预览按钮') and (not Button.Check) then
    begin
      if SearchMode then
        CurrentListView := MovieListView_SearchUI
      else
        CurrentListView := MovieListViewUI;

      SelectedPath := CurrentListView.GetItemSelectPath;
      if SelectedPath <> '' then
        OnMovieListViewSelectItem(CurrentListView, SelectedPath);
    end;
  end;
end;

end.

