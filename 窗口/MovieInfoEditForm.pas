{*******************************************************************************
  影片信息编辑窗口单元
  功能：提供影片信息的本地编辑界面，支持手动修改和网络获取

  主要功能：
  - 显示和编辑影片基本信息（标题、演员、类型、剧情等）
  - 集成网络信息下载功能
  - 影片海报预览显示
  - 支持打开影片所在文件夹
  - 本地影片信息管理

  编辑字段：
  - 影片标题、原始标题
  - 国家、演员、类型
  - 剧情简介、导演
  - 评分、时长

  Copyright (c) 2025 zotptptp
  Email: zoutp@qq.com
  All rights reserved.
*******************************************************************************}

unit MovieInfoEditForm;

interface

uses
  Windows, SysUtils, Classes, UI_MovieInfoEditForm, MovieInfoDownloadForm,
  UI_Form, MovieInfoUnit, {$I XCGuiStyle.inc}, FileHelpers, IOUtils, ShellAPI,
  CryptoUtils;

type
  TVideoEditForm = class(TVideoEditFormUI)
  private
    FMoviePath: string;
    FImage: Integer;
    FMovieInfo: TMovieInfo;
    class function OnPaint(hEle, hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
  protected
    procedure BtnCLICK(BtnUI: TSvgBtnUI); override;
  public
    constructor Create(hParent: integer; MoviePath: string);
    procedure SetMoviePath(MoviePath: string);
    destructor Destroy; override;
  end;

function SplitString(const S: string; Delimiter: Char): TArray<string>;

implementation

// 字符串分割函数实现

function SplitString(const S: string; Delimiter: Char): TArray<string>;
var
  SL: TStringList;
  i, ValidCount: Integer;
begin
  SL := TStringList.Create;
  try
    SL.StrictDelimiter := True;
    SL.Delimiter := Delimiter;
    SL.DelimitedText := S;

    // 过滤空字符串
    ValidCount := 0;
    for i := 0 to SL.Count - 1 do
    begin
      if Trim(SL[i]) <> '' then
        Inc(ValidCount);
    end;

    SetLength(Result, ValidCount);
    ValidCount := 0;
    for i := 0 to SL.Count - 1 do
    begin
      if Trim(SL[i]) <> '' then
      begin
        Result[ValidCount] := Trim(SL[i]);
        Inc(ValidCount);
      end;
    end;
  finally
    SL.Free;
  end;
end;

{ TVideoEditForm }

constructor TVideoEditForm.Create(hParent: integer; MoviePath: string);
var
  Form: TVideoEditForm;
begin
  Form := TVideoEditForm.FromXml('MovieInfoEditForm.xml', hParent) as TVideoEditForm;
  Form.FMoviePath := MoviePath;
  Form.SetMoviePath(MoviePath);
  Form.Show;
end;

procedure TVideoEditForm.SetMoviePath(MoviePath: string);
begin
  FMovieInfo := GetMovieInfo(MoviePath);
  FImage := XImage_LoadFile(PChar(GetAssociatedImagePath(MoviePath)));
  FTitleSvgLabelUI.EnableMouseThrough(True);
  FTitleSvgLabelUI.Text := Format('影片信息编辑<color=#FFFFFFFF>%s</color>', [MoviePath]);
  FPathEditUI.SetText(PChar(MoviePath));
  FTitleEditUI.SetText(PChar(FMovieInfo.Title));
  FOldTitleEditUI.SetText(PChar(FMovieInfo.OriginalTitle));
  FCountryEditUI.SetText(PChar(FMovieInfo.CountrysText));
  FActorsEditUI.SetText(PChar(FMovieInfo.ActorsText));
  FGenresEditUI.SetText(PChar(FMovieInfo.GenresText));
  FPlotEditUI.SetText(PChar(FMovieInfo.Plot));
  FDirectorEditUI.SetText(PChar(FMovieInfo.DirectorsText));
  FRatingEditUI.SetText(PChar(Format('%.1f', [FMovieInfo.Rating])));
  FRunTimeEditUI.SetText(PChar(FMovieInfo.RunTime));

  XEle_RegEvent(XC_GetObjectByID(Handle, 300), XE_PAINT, @OnPAINT);
end;

class function TVideoEditForm.OnPaint(hEle, hDraw: Integer; pbHandled: PBoolean): Integer;
var
  rc: TRect;
begin
  Result := 0;
  pbHandled^ := True;
  XEle_GetClientRect(hEle, rc);
  XDraw_ImageEX(hDraw, TVideoEditForm(GetClassFormHandle(XWidget_GetHWINDOW(hEle))).FImage, 0, 0, rc.width, rc.height);
end;

procedure TVideoEditForm.BtnCLICK(BtnUI: TSvgBtnUI);
var
  NfoPath, PosterPath: string;
begin
  if BtnUI = FDownloadInfoBtnUI then
    LoadMovieInfoDownloadForm(Handle, FMovieInfo.Title);

  if BtnUI = FTranslateBtnUI then
  begin
    // ID 10: 翻译为中文按钮处理
    // TODO: 实现翻译功能
    // 可以调用翻译API或本地翻译服务
  end;

  if BtnUI = FCacheMetadataBtnUI then
  begin
    // ID 11: 缓存元数据目录按钮处理
    // 打开缓存元数据目录并选中当前影片的NFO文件
    NfoPath := GetTempNfoPath(FMoviePath);
    if FileExists(NfoPath) then
    begin
      if not OpenMovieFolder(NfoPath) then
        MessageBox(hWnd, '无法打开缓存元数据文件！', '错误', MB_OK or MB_ICONERROR);
    end;
  end;

  if BtnUI = FCachePosterBtnUI then
  begin
    // ID 12: 缓存海报目录按钮处理
    // 打开缓存海报目录并选中当前影片的海报文件
    PosterPath := GetTempPosterPath(FMoviePath);
    if FileExists(PosterPath) then
    begin
      if not OpenMovieFolder(PosterPath) then
        MessageBox(hWnd, '无法打开缓存海报文件！', '错误', MB_OK or MB_ICONERROR);
    end;
  end;

  if BtnUI = FOpenFolderBtnUI then
    OpenMovieFolder(FMoviePath);

  if BtnUI = FSetFileNameBtnUI then
  begin
    // ID 901: 使用文件名按钮处理
    // 将文件名（不含扩展名）设置为标题
    FTitleEditUI.SetText(PChar(TPath.GetFileNameWithoutExtension(FMoviePath)));
    FTitleEditUI.Redraw();
  end;

  if BtnUI = FOKBtnUI then
  begin
    // 从UI控件更新FMovieInfo对象
    FMovieInfo.Title := WideString(FTitleEditUI.GetText_Temp);
    FMovieInfo.OriginalTitle := WideString(FOldTitleEditUI.GetText_Temp);
    FMovieInfo.Plot := WideString(FPlotEditUI.GetText_Temp);
    FMovieInfo.RunTime := WideString(FRunTimeEditUI.GetText_Temp);
    FMovieInfo.Rating := StrToFloatDef(WideString(FRatingEditUI.GetText_Temp), 0);

    // 更新字符串数组，使用'/'作为分隔符
    FMovieInfo.SetGenres(WideString(FGenresEditUI.GetText_Temp), '/');
    FMovieInfo.SetActors(WideString(FActorsEditUI.GetText_Temp), '/');
    FMovieInfo.SetDirectors(WideString(FDirectorEditUI.GetText_Temp), '/');
    FMovieInfo.SetCountrys(WideString(FCountryEditUI.GetText_Temp), '/');


    // 保存到临时nfo文件
    try
      FMovieInfo.SaveToFile(GetTempNfoPath(FMoviePath));
      MessageBox(Handle, '保存成功！', '提示', MB_OK or MB_ICONINFORMATION);
    except
      on E: Exception do
        MessageBox(Handle, PChar('保存失败：' + E.Message), '错误', MB_OK or MB_ICONERROR);
    end;
  end;
end;

destructor TVideoEditForm.Destroy;
begin
  if XC_IMAGE = XC_GetObjectType(FImage) then
    XImage_Release(FImage);
  inherited;
end;

end.

