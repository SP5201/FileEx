unit UI_MainForm;

interface

uses
  Windows, Classes, Messages, ShellAPI, SysUtils, UI_Form, {$I  XCGuiStyle.inc},
  SystemInfo, XWidget;

type
  TMainFormUI = class(TFormUI)
  private
    FLoadBtnUI: TSvgBtnUI; {加载按钮}
    FSkinBtnUI: TSvgBtnUI; {皮肤按钮}
    FCloseBtnUI: TSvgBtnUI; {关闭按钮}
    FMaxBtnUI: TSvgBtnUI; {最大化按钮}
    FMinBtnUI: TSvgBtnUI; {最小化按钮}
    FMenuBtnUI: TSvgBtnUI; {菜单按钮}
    FBcakBtnUI: TSvgBtnUI; {返回按钮}
    FMaskUI: TMaskLoadUI;
    FMuteBtnUI: TMultiSelectBtnUI; {静音按钮}
    FPlayBtnUI: TSvgBtnUI;
    FPlayBtnVisible: Boolean;
    FPreviewBtnUI: TMultiSelectBtnUI; {预览按钮}

    FMoviePanelUI: TMoviePanelUI;
    FMovieListViewUI: TMovieListViewUI;
    FMovieListView_SearchUI: TMovieListViewUI;
    FSearchEdit: TSearchEditUI;

    FDownloadLabelUI: TSvgLabelUI;
    FUploadLabelUI: TSvgLabelUI;
    FSystemInfoLabelUI: TSvgLabelUI;
    FStatusBarLabelUI: TSvgLabelUI;
    FFavoriteCountLabelUI: TSvgLabelUI;

    FSearchMode: Boolean;
    procedure SetSearchMode(const Value: Boolean);
    procedure SetStatusBarText(const Value: string);
    procedure SetPlayBtnVisible(const Value: Boolean);
  protected
    class function OnBtnCLICK(Btn: Integer; var bHandled: Boolean): LRESULT; stdcall; static;
    class function OnBUTTONCHECK(hBtn: Integer; bCheck: Boolean; pbHandled: PBoolean): Integer;stdcall; static;
    procedure OnWinProc(AMessage: UINT; wParam: wParam; lParam: lParam; var bHandled: Boolean); override;
    procedure Init; override;

    procedure SearchEditEvents(const SearchEdit: TSearchEditUI; EventType: UINT; SearchText: PWideChar; UserData: lParam); virtual; abstract;
    procedure MenuEvents(EventType: UINT; MenuID: wParam; UserData: lParam); virtual; abstract;
    procedure ButtonClick(const Button: TSvgBtnUI); virtual; abstract;
    procedure ButtonCheck(const Button: TSvgBtnUI); virtual; abstract;
  public
    procedure ShowLoading(const AText: string = '正在加载...');
    procedure SetLoadingText(const AText: string);
    procedure HideLoading;
    procedure UpdateNetworkSpeeds(DownloadSpeed, UploadSpeed: UInt64);
    procedure UpdateSystemInfo(SystemInfo: string);
    property LoadBtn: TSvgBtnUI read FLoadBtnUI write FLoadBtnUI;
    property BackdBtn: TSvgBtnUI read FBcakBtnUI write FBcakBtnUI;
    property MovieListViewUI: TMovieListViewUI read FMovieListViewUI write FMovieListViewUI;
    property MovieListView_SearchUI: TMovieListViewUI read FMovieListView_SearchUI write FMovieListView_SearchUI;
    property MoviePanelUI: TMoviePanelUI read FMoviePanelUI write FMoviePanelUI;
    property SearchMode: Boolean read FSearchMode write SetSearchMode;
    property StatusBarText: string write SetStatusBarText;
    property PlayBtnVisible: Boolean read FPlayBtnVisible write SetPlayBtnVisible;
    property PreviewBtn: TMultiSelectBtnUI read FPreviewBtnUI write FPreviewBtnUI;
    property MuteBtn: TMultiSelectBtnUI read FMuteBtnUI write FMuteBtnUI;
    property FavoriteCountLabel: TSvgLabelUI read FFavoriteCountLabelUI;

    // 配置相关方法
    procedure SetMutedState(AMuted: Boolean);
    procedure SetPreviewState(AEnabled: Boolean);
  end;

implementation


{ TMainFormFormUI }

procedure TMainFormUI.Init;
begin
  inherited;
  SetTheme(thDark);
  DragAcceptFiles(GetHWND, True);
  SetDragBorderSize(1,1,1,1);
  FCloseBtnUI := TSvgBtnUI.FromXmlName('关闭按钮');
  FMinBtnUI := TSvgBtnUI.FromXmlName('最小化按钮');
  FMaxBtnUI := TSvgBtnUI.FromXmlName('最大化按钮');
  FMenuBtnUI := TSvgBtnUI.FromXmlName('菜单按钮');
  FLoadBtnUI := TSvgBtnUI.FromXmlName('重载按钮');
  FSkinBtnUI := TSvgBtnUI.FromXmlName('换肤按钮');
  FBcakBtnUI := TSvgBtnUI.FromXmlName('返回主视频按钮');
  FPlayBtnUI:= TSvgBtnUI.FromXmlName('左侧展示_播放按钮');
  FPlayBtnUI.Style('窗口组件\播放.svg','',16,16);
  FPlayBtnUI.BackgroundColor := Theme_PrimaryColor; // 使用主题主色调
  FPlayBtnUI.RegEvent(XE_BNCLICK, @OnBtnCLICK);
  FPlayBtnVisible := XWidget_IsShow(FPlayBtnUI.Handle); // 默认显示播放按钮
  

  FSkinBtnUI.Style('窗口组件\换肤.svg', '换肤', 16, 16);
  FLoadBtnUI.Style('窗口组件\重载.svg', '重载媒体库' + sLineBreak + '下个版本在写', 16, 16, True);
  FMenuBtnUI.Style('窗口组件\菜单.svg', '设置', 16, 16, True);
  FCloseBtnUI.Style('窗口组件\关闭.svg', '关闭', 16, 16, True);
  FMinBtnUI.Style('窗口组件\最小化.svg', '最小化', 16, 16, True);
  FMaxBtnUI.Style('窗口组件\最大化.svg', '最大化', 16, 16, True);
  FBcakBtnUI.Style('窗口组件\返回.svg', '返回', 15, 15);
  FMuteBtnUI:= TMultiSelectBtnUI.FromXmlName('左侧展示_静音按钮');
  FMuteBtnUI.Style('窗口组件\声音播放.svg','窗口组件\声音禁止.svg','',18,18);
  FMuteBtnUI.RegEvent(XE_BUTTON_CHECK, @OnBUTTONCHECK);
  FPreviewBtnUI := TMultiSelectBtnUI.FromXmlName('左侧展示_ 预览按钮');
  FPreviewBtnUI.Style('窗口组件\预览_启用.svg', '窗口组件\预览_停止.svg', '', 18, 18);
  FPreviewBtnUI.RegEvent(XE_BUTTON_CHECK, @OnBUTTONCHECK);
  FSearchEdit := TSearchEditUI.FromXmlName('搜索框');
  FMoviePanelUI := TMoviePanelUI.FromXmlName('主窗口_左侧布局');
  FMovieListViewUI := TMovieListViewUI.FromXmlName('主窗口_视频列表');
  FMovieListView_SearchUI := TMovieListViewUI.FromXmlName('主窗口_视频列表_搜索');
  MovieListViewUI.ItemRadius:=8;
  MovieListView_SearchUI.ItemRadius:=8;
  FDownloadLabelUI := TSvgLabelUI.FromXmlName('下载网速图标');
  FDownloadLabelUI.Style('窗口组件\下载网速.svg', '', '',16,16);
  FDownloadLabelUI.TextAlign:=textAlignFlag_left;
  FUploadLabelUI := TSvgLabelUI.FromXmlName('上传网速图标');
  FUploadLabelUI.Style('窗口组件\上传网速.svg', '', '', 16, 16);

  FUploadLabelUI.TextAlign:=textAlignFlag_left;
  FSystemInfoLabelUI := TSvgLabelUI.FromXmlName('底部栏_我的电脑图标');
  FSystemInfoLabelUI.Style('窗口组件\底部栏_系统.svg', GetWindowsVersionString + ' ' + GetOSBitsString, GetFullSystemInfoString, 16, 16);
  FSystemInfoLabelUI.TextAlign:=textAlignFlag_left;
  FStatusBarLabelUI := TSvgLabelUI.FromXmlName('状态栏提示组件');
  FStatusBarLabelUI.Style('窗口组件\状态栏提示.svg', '', '',18, 18);
  FStatusBarLabelUI.Show(False);

  FFavoriteCountLabelUI := TSvgLabelUI.FromXmlName('收藏总数');
  FFavoriteCountLabelUI.Style('窗口组件\收藏数.svg', '', '', 18, 18, Integer(Position_Flag_Top) or Integer(Position_Flag_Left), 0, 0);
  FFavoriteCountLabelUI.AutoSize:= True;

  FBcakBtnUI.RegEvent(XE_BNCLICK, @OnBtnCLICK);
  FSkinBtnUI.RegEvent(XE_BNCLICK,@OnBtnCLICK);
  FMenuBtnUI.RegEvent(XE_BNCLICK,@OnBtnCLICK);
  FMaskUI := TMaskLoadUI.Create(0, 0, 0, 0, TXWidget.GetClassFormHandle(Handle));
  FMaskUI.Show(False);
  MuteBtn.Show(False);
  FPreviewBtnUI.Show(False);
end;

class function TMainFormUI.OnBtnCLICK(Btn: Integer; var bHandled: Boolean): LRESULT;
begin
  Result := 0;
  bHandled := True;
  SendMessage(XWidget_GetHWND(Btn), XE_BNCLICK, Btn, 0);
end;

class function TMainFormUI.OnBUTTONCHECK(hBtn: Integer; bCheck: Boolean; pbHandled: PBoolean): Integer;
begin
  Result := 0;
  pbHandled^ := True;
  SendMessage(XWidget_GetHWND(hBtn), XE_BUTTON_CHECK, hBtn, Ord(bCheck));
end;


procedure TMainFormUI.SetSearchMode(const Value: Boolean);
var
  selIdx: Integer;
  selPath: string;
begin
  if Value = FSearchMode then
    Exit;
  FSearchMode := Value;
  if FSearchMode then
  begin
    // 搜索模式：显示搜索列表，隐藏主列表
    MovieListViewUI.Show(False);
    MovieListView_SearchUI.Show(True);
    FBcakBtnUI.Show(True);
    // 自动选中第一项
    if (MovieListView_SearchUI.Item_GetCount(0) > 0) and (MovieListView_SearchUI.GetItemSelect(0) = -1) then
      MovieListView_SearchUI.SetSelectItem(0, 0);
    // 检查选中项path和MoviePanelUI.MoviePath是否一致，不一致则发消息
    selIdx := MovieListView_SearchUI.GetItemSelect(0);
    if (selIdx >= 0) then
    begin
      selPath := MovieListView_SearchUI.GetPathFromItem(selIdx);
      if (selPath <> '') and (selPath <> MoviePanelUI.MoviePath) then
        MovieListView_SearchUI.SendEvent(XE_LISTVIEW_SELECT, 0, selIdx);
    end;
  end
  else
  begin
    // 普通模式：显示主列表，隐藏搜索列表
    MovieListViewUI.Show(True);
    MovieListView_SearchUI.Show(False);
    FBcakBtnUI.Show(False);
    // 检查选中项path和MoviePanelUI.MoviePath是否一致，不一致则发消息
    selIdx := MovieListViewUI.GetItemSelect(0);
    if (selIdx >= 0) then
    begin
      selPath := MovieListViewUI.GetPathFromItem(selIdx);
      if (selPath <> '') and (selPath <> MoviePanelUI.MoviePath) then
        MovieListViewUI.SendEvent(XE_LISTVIEW_SELECT, 0, selIdx);
    end;
  end;
  XEle_Redraw(FBcakBtnUI.GetParent);
  AdjustLayout;
  if MovieListViewUI.IsShow then
    MovieListViewUI.Redraw;
  if MovieListView_SearchUI.IsShow then
    MovieListView_SearchUI.Redraw;
end;

procedure TMainFormUI.UpdateNetworkSpeeds(DownloadSpeed, UploadSpeed: UInt64);
begin
  FDownloadLabelUI.Text :=FormatByteSize(DownloadSpeed) ;
  FUploadLabelUI.Text := FormatByteSize(UploadSpeed) ;
end;

procedure TMainFormUI.UpdateSystemInfo(SystemInfo: string);
begin
  FSystemInfoLabelUI.Text := SystemInfo;
end;

procedure TMainFormUI.ShowLoading(const AText: string = '正在加载...');
begin
    FMaskUI.ShowLoading(AText);
end;

procedure TMainFormUI.SetLoadingText(const AText: string);
begin
  FMaskUI.Text:= AText;
end;

procedure TMainFormUI.HideLoading;
begin
  FMaskUI.HideLoading;
end;

procedure TMainFormUI.SetStatusBarText(const Value: string);
begin
  FStatusBarLabelUI.Show(Value <> '');
  if Assigned(FStatusBarLabelUI) then
    FStatusBarLabelUI.Text := Value;
end;

procedure TMainFormUI.SetMutedState(AMuted: Boolean);
begin
  if Assigned(FMuteBtnUI) then
  begin
    XBtn_SetCheck(FMuteBtnUI.Handle, AMuted);
  end;
end;

procedure TMainFormUI.SetPreviewState(AEnabled: Boolean);
begin
  if Assigned(FPreviewBtnUI) then
  begin
    XBtn_SetCheck(FPreviewBtnUI.Handle, AEnabled);
  end;
end;

procedure TMainFormUI.SetPlayBtnVisible(const Value: Boolean);
begin
  if FPlayBtnVisible <> Value then
  begin
    FPlayBtnVisible := Value;
    FPlayBtnUI.Show(Value);
  end;
end;

procedure TMainFormUI.OnWinProc(AMessage: UINT; wParam: wParam; lParam: lParam; var bHandled: Boolean);
begin
  try
    case AMessage of
      WM_SYSCOMMAND:
        if (wParam and $FFF0) = SC_CLOSE then
          CloseAllModalForms;

      XE_MENU_SELECT:
        MenuEvents(AMessage, wParam, lParam);

      XE_TAGBOX_BUTTON_CLICK,
      XE_SEARCH_EDIT_RETURN:
        SearchEditEvents(FSearchEdit, AMessage, PWideChar(wParam), lParam);

      XE_BUTTON_CHECK:
        ButtonCheck(TSvgBtnUI.FromHandle(wParam));
      XE_BNCLICK:
        ButtonClick(TSvgBtnUI.FromHandle(wParam));
    end;
  except
    on E: Exception do
    begin
      if Assigned(FStatusBarLabelUI) then
        FStatusBarLabelUI.Text := Format('全局错误: [%s] %s 在单元: %s', 
          [E.ClassName, E.Message, 'UI_MainForm']);
    end;
  end;
end;



end.

