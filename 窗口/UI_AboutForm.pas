unit UI_AboutForm;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, XCGUI, XLayout, XWidget,
  XElement, UI_Resource, XForm, Ui_Color, UI_Form, UI_Button, UI_Edit, XTextLink,UI_Label,
  UI_Element,IconExtractorUnit;

type
  TAboutFormUI = class(TFormUI)
  private
    FICON:Integer;
    FCloseBtnUI: TSvgBtnUI; {关闭按钮}
    FConfirmBtnUI: TSvgBtnUI; {确认按钮}
    FTextLinkUI: TXTextLink; {文本链接}
    FEdit1: TEditUI;
    FEdit2: TEditUI;
    FEdit3: TEditUI;
    FStyle1: Integer;
    FStyle2: Integer; {库名高亮样式}
    FStyle3: Integer; {版权信息样式}
    FStyle4: Integer; {版权信息样式}
  protected
    procedure Init; override;
    function CreateTextLink(const Text: string): TXTextLink;
    class function OnTextLinkClick(hEle: Integer; var pbHandled: Boolean): Integer; stdcall; static;
    function GetDllInfo: string;
  public
    property Edit1: TEditUI read FEdit1;
    property Edit2: TEditUI read FEdit2;
    property Edit3: TEditUI read FEdit3;
    // 公共方法和属性
  end;

implementation

uses
  Winapi.Messages, Winapi.ShellAPI;

{ TAboutFormUI }

procedure TAboutFormUI.Init;
var
  hIcon: Integer;
  hImg:Integer;
begin
  inherited;
  FCloseBtnUI := TSvgBtnUI.FromXmlID(Handle, 2);
  FCloseBtnUI.Style('窗口组件\关闭.svg', '关闭', 16, 16, True);
  FICON:=XC_GetObjectByName('关于窗口_图标');
  hIcon := ExtractHighestResolutionIcon(ParamStr(0)); // 如果资源名为 MAINICON
  if hIcon <> 0 then
  begin
    hImg := XImage_LoadFromHICON(hIcon);
    XImage_SetDrawType(hImg,image_draw_type_stretch);
    XShapePic_SetImage(FICON, hImg);
    DestroyIcon(hIcon);
  end
  else
    XShapePic_SetImage(FICON, 0); // 或者设置为默认图片
  FConfirmBtnUI := TSvgBtnUI.FromXmlName('关于窗口_确认按钮');
  FConfirmBtnUI.BackgroundColor := Theme_PrimaryColor; // 使用主题主色调作为背景高亮色
  FConfirmBtnUI.CornerRadius := 4; // 设置较小的圆角
  FEdit1 := TEditUI.FromXmlName('关于窗口_编辑框1');
  FEdit2 := TEditUI.FromXmlName('关于窗口_编辑框2');
  FEdit3 := TEditUI.FromXmlName('关于窗口_编辑框3');
  FStyle1 := XEdit_AddStyle(FEdit1.Handle, XRes_GetFont('微软雅黑15'), RGBA(255, 255, 255, 255), TRUE);
  FStyle2 := XEdit_AddStyle(FEdit2.Handle, XC_GetDefaultFont, RGBA(255, 255, 255, 240), TRUE);
  FStyle3 := XEdit_AddStyle(FEdit1.Handle, XC_GetDefaultFont, RGBA(255, 255, 255, 225), TRUE);
  FStyle4 := XEdit_AddStyle(FEdit3.Handle, XC_GetDefaultFont, RGBA(255, 255, 255, 225), TRUE);
  FEdit1.EnableReadOnly(True);
  FEdit1.SetCaretWidth(0); // 设置光标宽度为0，隐藏光标
  FEdit1.SetSelectBkColor(RGBA(0, 0, 0, 0)); // 设置光标宽度为0，隐藏光标
  FEdit2.EnableReadOnly(True);
  FEdit2.SetCaretWidth(0); // 设置光标宽度为0，隐藏光标
  FEdit2.SetSelectBkColor(RGBA(0, 0, 0, 0)); // 设置光标宽度为0，隐藏光标
  FEdit2.EnableBorder := True;
  FEdit3.EnableReadOnly(True);
  FEdit3.ShowSBarV(False);
  FEdit3.SetCaretWidth(0); // 设置光标宽度为0，隐藏光标
  FEdit3.SetSelectBkColor(RGBA(0, 0, 0, 0)); // 设置光标宽度为0，隐藏光标
  // 在标题编辑框中添加标题
  Edit1.AddTextEx('关于影片管理器' + #13#10, FStyle1);
  Edit1.AddText(#13#10);
  // 在内容编辑框中添加详细信息
  Edit1.AddTextEx('本程序是一款影片管理工具，支持影片信息自动获取、海报下载、分类管理等功能。', FStyle3);


  // 添加库介绍标题
  FEdit2.AddTextEx('内置开源库：' + #13#10, FStyle2);
  // 创建各种库的链接
  FEdit2.AddText('+ ');
  FTextLinkUI := CreateTextLink('FFmpeg');
  FEdit2.AddText('多媒体处理库，用于视频信息提取和格式转换；' + #13#10);

  FEdit2.AddText('+ ');
  FTextLinkUI := CreateTextLink('SQLite3');
  FEdit2.AddText('数据库引擎，用于本地影片信息存储和管理；' + #13#10);

  FEdit2.AddText('+ ');
  FTextLinkUI := CreateTextLink('XCGUI');
  FEdit2.AddText('界面库，提供现代化的用户界面组件；' + #13#10);

  FEdit2.AddText('+ ');
  FTextLinkUI := CreateTextLink('SuperObject');
  FEdit2.AddText('JSON库，用于网络数据解析和处理；' + #13#10);

  FEdit2.AddText('+ ');
  FTextLinkUI := CreateTextLink('NativeXml');
  FEdit2.AddText('XML库，用于NFO文件读写和解析；' + #13#10);

  FEdit2.AddText('+ ');
  FTextLinkUI := CreateTextLink('Indy');
  FEdit2.AddText('网络库，用于HTTP请求和网络通信。' + #13#10);
  FEdit2.AddText(#13#10);
  
  // 添加动态DLL信息
  FEdit2.AddTextEx('程序所需动态数据库：' + #13#10, FStyle2);
  FEdit2.AddText(PChar(GetDllInfo));
  FEdit3.AddTextEx(PChar('本程序已授权给：' + GetEnvironmentVariable('USERNAME') + #13#10), FStyle4);

  FEdit3.AddTextEx('Email：zoutp@qq.com  QQ：296212440' + #13#10, FStyle4);
  FEdit3.AddText(#13#10);
  FEdit3.AddTextEx('警告：', FStyle2);
  FEdit3.AddTextEx('本计算机程序受著作权法和国际公约的保护，未经授权擅自复制或传播本程序的部分或全部，可能受到严厉的民事及刑事制裁，并将在法律许可的范围内受到最大可能的起诉。', FStyle4);
end;

function TAboutFormUI.CreateTextLink(const Text: string): TXTextLink;
var
  TextSize: TSize;
begin
  // 获取文本显示尺寸
  XC_GetTextShowSize(PWideChar(Text), -1, XC_GetDefaultFont, TextSize);

  Result := TXTextLink.Create(0, 0, TextSize.Width-1, 20, Text, FEdit2);
  Result.TextColor := RGBA(255, 255, 255, 255);
  Result.TextColorStay := RGBA(255, 255, 255, 255);
  Result.EnableUnderlineStay := False; // 禁用离开时的下划线
  Result.EnableUnderlineLeave := False; // 禁用离开时的下划线
  Result.EnableDrawFocus(False); // 禁用焦点边框绘制
  Result.SetCursor(LoadCursor(0, IDC_HAND)); // 设置手型光标
  Result.RegEvent(XE_BNCLICK, @OnTextLinkClick); // 注册点击事件
  FEdit2.AddObject(Result.Handle);
end;

function TAboutFormUI.GetDllInfo: string;
var
  ExePath: string;
  DllName: string;
  VersionInfo: string;
  SearchHandle: THandle;
  FindData: TWin32FindData;
  DllPath: string;
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: Pointer;
  Dummy: DWORD;
  Major, Minor, Build, Revision: Word;
  DllPurpose: string;
  DllList: TStringList;
  i: Integer;
begin
  Result := '';
  ExePath := ExtractFilePath(ParamStr(0));
  DllList := TStringList.Create;
  
  try
    SearchHandle := FindFirstFile(PChar(ExePath + '*.dll'), FindData);
    if SearchHandle <> INVALID_HANDLE_VALUE then
    try
      repeat
        DllName := string(FindData.cFileName);
        DllPath := ExePath + DllName;
        VersionInfo := '';
        DllPurpose := '';

        // 根据DLL名称确定用途
        if Pos('avcodec', LowerCase(DllName)) > 0 then
          DllPurpose := ' - 视频编解码'
        else if Pos('avformat', LowerCase(DllName)) > 0 then
          DllPurpose := ' - 媒体格式处理'
        else if Pos('avutil', LowerCase(DllName)) > 0 then
          DllPurpose := ' - 音视频工具库'
        else if Pos('swresample', LowerCase(DllName)) > 0 then
          DllPurpose := ' - 音频重采样'
        else if Pos('swscale', LowerCase(DllName)) > 0 then
          DllPurpose := ' - 视频缩放'
        else if Pos('avfilter', LowerCase(DllName)) > 0 then
          DllPurpose := ' - 音视频滤镜'
        else if Pos('avdevice', LowerCase(DllName)) > 0 then
          DllPurpose := ' - 设备访问'
        else if Pos('sqlite', LowerCase(DllName)) > 0 then
          DllPurpose := ' - 数据库引擎'
        else if Pos('xcgui', LowerCase(DllName)) > 0 then
          DllPurpose := ' - 界面库'
        else if Pos('soundtouch', LowerCase(DllName)) > 0 then
          DllPurpose := ' - 音频处理';

        // 获取文件版本信息
        VerInfoSize := GetFileVersionInfoSize(PChar(DllPath), Dummy);
        if VerInfoSize > 0 then
        begin
          GetMem(VerInfo, VerInfoSize);
          try
            if GetFileVersionInfo(PChar(DllPath), 0, VerInfoSize, VerInfo) then
            begin
              if VerQueryValue(VerInfo, '\', VerValue, VerValueSize) then
              begin
                with PVSFixedFileInfo(VerValue)^ do
                begin
                  Major := HiWord(dwFileVersionMS);
                  Minor := LoWord(dwFileVersionMS);
                  Build := HiWord(dwFileVersionLS);
                  Revision := LoWord(dwFileVersionLS);
                  VersionInfo := Format('%d.%d.%d.%d', [Major, Minor, Build, Revision]);
                end;
              end;
            end;
          finally
            FreeMem(VerInfo);
          end;
        end;

        if VersionInfo <> '' then
          DllList.Add('- '+DllName + ' (v' + VersionInfo + ')' + DllPurpose)
        else
          DllList.Add('- '+DllName + DllPurpose);
      until not FindNextFile(SearchHandle, FindData);
    finally
      FindClose(SearchHandle);
    end;
    
    // 构建结果字符串，最后一行不加换行
    for i := 0 to DllList.Count - 1 do
    begin
      if i < DllList.Count - 1 then
        Result := Result + DllList[i] + #13#10
      else
        Result := Result + DllList[i]; // 最后一行不加换行
    end;
  except
    Result := '无法读取DLL文件信息';
  end;
  
  DllList.Free;
  
  if Result = '' then
    Result := '未找到DLL文件';
end;

class function TAboutFormUI.OnTextLinkClick(hEle: Integer; var pbHandled: Boolean): Integer;
var
  TextLink: TXTextLink;
  LinkText: string;
  URL: string;
begin
  Result := 0;
  pbHandled := True;

  TextLink := TXTextLink.GetClassFormHandle(hEle);
  if Assigned(TextLink) then
  begin
    LinkText := TextLink.Text;

    // 根据链接文本确定要打开的网址
    if LinkText = 'FFmpeg' then
      URL := 'https://ffmpeg.org/'
    else if LinkText = 'SQLite3' then
      URL := 'https://www.sqlite.org/'
    else if LinkText = 'XCGUI' then
      URL := 'https://www.xcgui.com/'
    else if LinkText = 'SuperObject' then
      URL := 'https://github.com/hgourvest/superobject'
    else if LinkText = 'NativeXml' then
      URL := 'https://github.com/simdesign/nativexml'
    else if LinkText = 'Indy' then
      URL := 'https://www.indyproject.org/'
    else
      URL := '';

    // 如果找到对应的网址，则打开它
    if URL <> '' then
    begin
      ShellExecute(0, 'open', PWideChar(URL), nil, nil, SW_SHOWNORMAL);
    end;
  end;
end;

end.

