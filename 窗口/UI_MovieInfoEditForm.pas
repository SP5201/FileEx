unit UI_MovieInfoEditForm;

interface

uses
  Windows, Messages, XCGUI, UI_Button, UI_Resource, UI_Form, UI_Edit, UI_Color,
  UI_DateTime, UI_ComboBox, UI_Label;

type
  TVideoEditFormUI = class(TFormUI)
  private
    procedure SetLabelsColor;
    procedure SetLabelsColorChild(Element: Integer);
    class function OnPAINT(hEle, hDraw: Integer; pbHandle: PBoolean): Integer; stdcall; static;
    class function OnBtnCLICK(Btn: Integer; var bHandled: Boolean): Integer; stdcall; static;
  protected
    FTitleSvgLabelUI: TSvgLabelUI; {窗口标题}
    FCloseBtnUI: TSvgBtnUI; {关闭按钮}
    FPathEditUI: TEditUI;     {文件路径}
    FTitleEditUI: TEditUI;    {电影标题}
    FOldTitleEditUI: TEditUI; {原始标题}
    FCountryEditUI: TEditUI;  {国家/地区}
    FGenresEditUI: TEditUI;   {电影类型}
    FDirectorEditUI: TEditUI; {导演}
    FActorsEditUI: TEditUI;   {演员（多人用逗号分隔）}
    FPlotEditUI: TEditUI;     {简介}
    FRunTimeEditUI: TEditUI; {时长}
    FRatingEditUI: TEditUI;  {评分}
    FSvgLabelUI: TSvgLabelUI;
    FPlotImgeBox: Integer;

    FLoadFileBtn: TSvgBtnUI;
    FDownloadBtn: TSvgBtnUI;
    FBlackWhiteBtn: TSvgBtnUI;
    FCropBtn: TSvgBtnUI;
    FClipboardBtn: TSvgBtnUI;

    FDownloadInfoBtnUI: TSvgBtnUI;
    FTranslateBtnUI: TSvgBtnUI;
    FCacheMetadataBtnUI: TSvgBtnUI;  // ID 11: 缓存元数据目录
    FCachePosterBtnUI: TSvgBtnUI;    // ID 12: 缓存海报目录
    FOpenFolderBtnUI: TSvgBtnUI;
    FSetFileNameBtnUI: TSvgBtnUI;

    FDateTimeUI: TDateTimeUI;
    FComboBoxUI: TComboBoxUI;

    FSaveMediaDataBtnUI: TMultiSelectBtnUI;
    FOKBtnUI: TSvgBtnUI;
    FCancelBtnUI: TSvgBtnUI;
    procedure Init; override;
    procedure BtnCLICK(BtnUI: TSvgBtnUI); virtual;
  public
  end;

implementation

{ TVideoEditFormUI }

procedure TVideoEditFormUI.Init;
var
  HintText: string;
begin
  inherited;
  SetMinimumSize(980, 660);
  SetBorderSize(6, 6, 0, 0);
  FTitleSvgLabelUI := TSvgLabelUI.FromXmlID(Handle, 1);
  FTitleSvgLabelUI.SvgFile := '窗口组件\编辑文件.svg';
  FCloseBtnUI := TSvgBtnUI.FromXmlID(Handle, 2);
  FCloseBtnUI.Style('窗口组件\关闭.svg', '关闭', 16, 16, True);
  FPathEditUI := TEditUI.FromXmlID(Handle, 99);
  FPathEditUI.EnableBorder := True;
  FPathEditUI.EnableReadOnly(True);  // 禁用编辑，设为只读
  FPathEditUI.Enable(False);  // 禁用编辑框
  FTitleEditUI := TEditUI.FromXmlID(Handle, 100);
  FTitleEditUI.EnableBorder := True;
  FOldTitleEditUI := TEditUI.FromXmlID(Handle, 101);
  FOldTitleEditUI.EnableBorder := True;
  FCountryEditUI := TEditUI.FromXmlID(Handle, 103);
  FCountryEditUI.EnableBorder := True;
  FGenresEditUI := TEditUI.FromXmlID(Handle, 104);
  FGenresEditUI.EnableBorder := True;
  FDirectorEditUI := TEditUI.FromXmlID(Handle, 105);
  FDirectorEditUI.EnableBorder := True;
  FActorsEditUI := TEditUI.FromXmlID(Handle, 106);
  FActorsEditUI.EnableBorder := True;
  FPlotEditUI := TEditUI.FromXmlID(Handle, 107);
  FPlotEditUI.EnableBorder := True;
  FPlotEditUI.EnableMultiLine(True);
  FPlotEditUI.EnableAutoWrap(True);
  FRunTimeEditUI := TEditUI.FromXmlID(Handle, 108);
  FRunTimeEditUI.EnableBorder := True;

  // 初始化评分编辑框
  FRatingEditUI := TEditUI.FromXmlID(Handle, 84);
  FRatingEditUI.EnableBorder := True;

  FDownloadInfoBtnUI := TSvgBtnUI.FromXmlID_EX(Handle, 9, @OnBtnCLICK);
  FDownloadInfoBtnUI.EnableBorder := True;
  FDownloadInfoBtnUI.SvgFile := '窗口组件\网络获取.svg';
  FDownloadInfoBtnUI.SetOffsetText(-2, 0);

  FTranslateBtnUI := TSvgBtnUI.FromXmlID_EX(Handle, 10, @OnBtnCLICK);
  FTranslateBtnUI.EnableBorder := True;
  FTranslateBtnUI.SvgFile := '窗口组件\翻译.svg';

  FCacheMetadataBtnUI := TSvgBtnUI.FromXmlID_EX(Handle, 11, @OnBtnCLICK);
  FCacheMetadataBtnUI.EnableBorder := True;

  FCachePosterBtnUI := TSvgBtnUI.FromXmlID_EX(Handle, 12, @OnBtnCLICK);
  FCachePosterBtnUI.EnableBorder := True;

  FOpenFolderBtnUI := TSvgBtnUI.FromXmlID_EX(Handle, 900, @OnBtnCLICK);
  FOpenFolderBtnUI.EnableBorder := True;
  FOpenFolderBtnUI.SvgFile := '窗口组件\文件夹.svg';

  FSetFileNameBtnUI := TSvgBtnUI.FromXmlID_EX(Handle, 901, @OnBtnCLICK);
  FSetFileNameBtnUI.EnableBorder := True;
  FSaveMediaDataBtnUI := TMultiSelectBtnUI.FromXmlID(Handle, 1002);
  FSaveMediaDataBtnUI.Style('', '','', 14, 14);
  FOKBtnUI := TSvgBtnUI.FromXmlID_EX(Handle, 1000, @OnBtnCLICK);
  FOKBtnUI.EnableBorder := True;
  FCancelBtnUI := TSvgBtnUI.FromXmlID_EX(Handle, 1001, nil);
  FCancelBtnUI.EnableBorder := True;

  FSvgLabelUI := TSvgLabelUI.FromXmlID(Handle, 82);
  HintText := 'G（General Audience）' + sLineBreak + '全年龄可看，无暴力、裸露或不当内容（如迪士尼动画）。' + sLineBreak + sLineBreak + 'PG（Parental Guidance Suggested）' + sLineBreak + '建议家长陪同，可能有轻微暴力或幽默粗话（如《哈利·波特》系列）。' + sLineBreak + sLineBreak + 'PG-13（Parents Strongly Cautioned）' + sLineBreak + '13岁以下需家长陪同，含中度暴力、简短裸露或少量脏话（如《复仇者联盟》）。' + sLineBreak + sLineBreak + 'R（Restricted）' + sLineBreak + '17岁以下需成人陪同，含强烈暴力、性场景、大量脏话或毒品内容（如《死侍》）。' + sLineBreak + sLineBreak + 'NC-17（Adults Only）' + sLineBreak + '仅限18岁以上，含极端暴力、裸露或性内容（如《色，戒》未删减版）。';
  FSvgLabelUI.Style('窗口组件\问号提示.svg', '', HintText, 16, 16);

  FSvgLabelUI := TSvgLabelUI.FromXmlID(Handle, 83);
  HintText := '提示评分范围为1.0至10.0分，支持一位小数。具体评级说明如下：' + sLineBreak + '≥ 9.0 分：被视为神作级别影片，代表电影在剧情、制作、表演等多方面达到极高水准，如《霸王别姬》（评分 9.6 分）。' + sLineBreak + '7.0 - 8.9 分：值得一看的影片，在各方面表现较为出色，具有较高的观赏性和艺术价值。' + sLineBreak + '＜ 5.0 分：存在较多问题，观影体验可能不佳，需谨慎观看。';

  FSvgLabelUI.Style('窗口组件\问号提示.svg', '', HintText, 16, 16);

  FDateTimeUI := TDateTimeUI.FromXmlID(Handle, 80);
  FComboBoxUI := TComboBoxUI.FromXmlID(Handle, 81);

  FComboBoxUI.AddItemTextEx('name1', '未分级');
  FComboBoxUI.AddItemTextEx('name1', 'G');
  FComboBoxUI.AddItemTextEx('name1', 'PG');
  FComboBoxUI.AddItemTextEx('name1', 'PG-13');
  FComboBoxUI.AddItemTextEx('name1', 'R');
  FComboBoxUI.AddItemTextEx('name1', 'NC-17');
  FComboBoxUI.SetSelItem(0);
  XEdit_SetDefaultTextColor(FComboBoxUI.Handle, Theme_TextColor_Leave);

  FLoadFileBtn := TSvgBtnUI.FromXmlID_EX(Handle, 241, @OnBtnCLICK);
  FLoadFileBtn.Style('窗口组件\文件.svg', '从路径加载海报',16, 16);
  FDownloadBtn := TSvgBtnUI.FromXmlID_EX(Handle, 242, @OnBtnCLICK);
  FDownloadBtn.Style('窗口组件\下载.svg', '从网络下载海报', 20, 20);
  FBlackWhiteBtn := TSvgBtnUI.FromXmlID_EX(Handle, 243, @OnBtnCLICK);
  FBlackWhiteBtn.Style('窗口组件\黑白.svg', '海报去色', 20, 20);
  FCropBtn := TSvgBtnUI.FromXmlID_EX(Handle, 244, @OnBtnCLICK);
  FCropBtn.Style('窗口组件\裁剪.svg', '裁剪海报', 20, 20);
  FClipboardBtn := TSvgBtnUI.FromXmlID_EX(Handle, 245, @OnBtnCLICK);
  FClipboardBtn.Style('窗口组件\剪切板.svg', '从剪切板读取海报', 20, 20);

  SetLabelsColor;
  XEle_RegEvent(XC_GetObjectByID(Handle, 299), XE_PAINT, @OnPAINT);
end;

class function TVideoEditFormUI.OnBtnCLICK(Btn: Integer; var bHandled: Boolean): Integer;
var
  BtnUI: TSvgBtnUI;
  Form: TVideoEditFormUI;
begin
  Result := 0;
  bHandled := True;
  BtnUI := TSvgBtnUI.GetClassFormHandle(Btn);

  Form := GetClassFormHandle(XWidget_GetHWINDOW(BtnUI.Handle));
  Form.BtnCLICK(BtnUI);
end;

procedure TVideoEditFormUI.BtnCLICK(BtnUI: TSvgBtnUI);
begin
  // 按钮处理逻辑已移至窗口文件 MovieInfoEditForm.pas 中
end;

class function TVideoEditFormUI.OnPAINT(hEle, hDraw: Integer; pbHandle: PBoolean): Integer;
var
  RC: TRect;
begin
  XEle_GetClientRect(hEle, RC);
  XDraw_SetBrushColor(hDraw, Theme_Edit_BorderColor_focus_no);
  XDraw_DrawRoundRect(hDraw, RC, 4, 4);
  Result := 0;
end;

procedure TVideoEditFormUI.SetLabelsColor;
var
  ChildIndex: Integer;
  ChildElement: Integer;
  SubChildIndex: Integer;
  SubChildElement: Integer;
begin
  for ChildIndex := 0 to XWnd_GetChildCount(Handle) - 1 do
  begin
    ChildElement := XWnd_GetChildByIndex(Handle, ChildIndex);
    if XC_GetObjectType(ChildElement) = XC_SHAPE_TEXT then
    begin
      XShapeText_SetTextColor(ChildElement, Theme_TextColor_Leave);
    end
    else
    begin
      for SubChildIndex := 0 to XEle_GetChildCount(ChildElement) - 1 do
      begin
        SubChildElement := Xele_GetChildByIndex(ChildElement, SubChildIndex);
        if XC_GetObjectType(SubChildElement) = XC_SHAPE_TEXT then
        begin
          XShapeText_SetTextColor(SubChildElement, Theme_TextColor_Leave);
        end
        else if XEle_GetChildCount(SubChildElement) > 0 then
        begin
          // 递归处理子元素
          SetLabelsColorChild(SubChildElement);
        end;
      end;
    end;
  end;
end;

// 递归处理单个元素及其子元素
procedure TVideoEditFormUI.SetLabelsColorChild(Element: Integer);
var
  ChildIndex: Integer;
  ChildElement: Integer;
begin
  for ChildIndex := 0 to XEle_GetChildCount(Element) - 1 do
  begin
    ChildElement := Xele_GetChildByIndex(Element, ChildIndex);
    if XC_GetObjectType(ChildElement) = XC_SHAPE_TEXT then
    begin
      XShapeText_SetTextColor(ChildElement, Theme_TextColor_Leave);
    end
    else if XEle_GetChildCount(ChildElement) > 0 then
    begin
      // 递归处理子元素
      SetLabelsColorChild(ChildElement);
    end;
  end;
end;

end.
