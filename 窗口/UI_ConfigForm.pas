unit UI_ConfigForm;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, XCGUI, XLayout, XWidget,
  XElement, UI_Resource, XForm, Ui_Color, UI_Form, UI_Button, UI_Edit, XTextLink,
  UI_Label, UI_Element, UI_List, Ui_Layout, UI_SliderBar;

type
  TConfigFormUI = class(TFormUI)
  private
    procedure SetupElementStyles(AParentEle: HELE);
    class function OnNavListSelect(hEle: HELE; iItem: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function SelectPlayerPathBtnClick(hEle: HELE; pbHandled: PBoolean): Integer; stdcall; static;
  protected
    FContentLayout: TLayoutUI;
    FNavList: TListUI;
    FCloseBtnUI: TSvgBtnUI; // 关闭按钮
    FConfirmBtnUI: TSvgBtnUI; // 确认按钮
    FCancelBtnUI: TSvgBtnUI; // 取消按钮
    FPageLayouts: array[0..3] of HELE;

    // 常规设置
    FAutoRunBtnUI: TMultiSelectBtnUI;
    FMinimizeToTrayBtnUI: TMultiSelectBtnUI;
    FScanFormatEditUI: TEditUI;
    FExcludePathEditUI: TEditUI;
    FExcludeSizeEditUI: TEditUI;
    FPlayerPathEditUI: TEditUI;
    FSelectPlayerPathBtnUI: TSvgBtnUI;
    // 网络设置

    // 媒体库
    FAddBtnUI: TSvgBtnUI;
    FDeleteBtnUI: TSvgBtnUI;
    FClearBtnUI: TSvgBtnUI;
    FMediaLibraryPathEditUI: TEditUI;
    // 网络设置
    FProxyAddressEditUI: TEditUI;
    FProxyPortEditUI: TEditUI;
    FNoProxyBtnUI: TRadioBtnUI;
    FHttpProxyBtnUI: TRadioBtnUI;
    FSocks5ProxyBtnUI: TRadioBtnUI;
    procedure Init; override;
  public
    property NavList: TListUI read FNavList;
    property CloseBtnUI: TSvgBtnUI read FCloseBtnUI;
    property ConfirmBtnUI: TSvgBtnUI read FConfirmBtnUI;
    property CancelBtnUI: TSvgBtnUI read FCancelBtnUI;
    property AutoRunBtnUI: TMultiSelectBtnUI read FAutoRunBtnUI;
    property MinimizeToTrayBtnUI: TMultiSelectBtnUI read FMinimizeToTrayBtnUI;
    property ScanFormatEditUI: TEditUI read FScanFormatEditUI;
    property ExcludePathEditUI: TEditUI read FExcludePathEditUI;
    property ExcludeSizeEditUI: TEditUI read FExcludeSizeEditUI;
    property PlayerPathEditUI: TEditUI read FPlayerPathEditUI;
    property SelectPlayerPathBtnUI: TSvgBtnUI read FSelectPlayerPathBtnUI;
    property AddBtnUI: TSvgBtnUI read FAddBtnUI;
    property DeleteBtnUI: TSvgBtnUI read FDeleteBtnUI;
    property ClearBtnUI: TSvgBtnUI read FClearBtnUI;
    property MediaLibraryPathEditUI: TEditUI read FMediaLibraryPathEditUI;
    property ProxyAddressEditUI: TEditUI read FProxyAddressEditUI;
    property ProxyPortEditUI: TEditUI read FProxyPortEditUI;
    property NoProxyBtnUI: TRadioBtnUI read FNoProxyBtnUI;
    property HttpProxyBtnUI: TRadioBtnUI read FHttpProxyBtnUI;
    property Socks5ProxyBtnUI: TRadioBtnUI read FSocks5ProxyBtnUI;
    // 公共方法和属性
  end;

implementation

uses
  Winapi.Messages, Winapi.ShellAPI, FileHelpers;

{ TConfigFormUI }

class function TConfigFormUI.SelectPlayerPathBtnClick(hEle: hEle; pbHandled: PBoolean): Integer;
var
  Form: TConfigFormUI;
  SelectedFile: string;
begin
  Form := TConfigFormUI.GetClassFormHandle(XWidget_GetHWINDOW(hEle));
  SelectedFile := SelectFile('选择播放器', '可执行文件 (*.exe)|*.exe', XWidget_GetHWND(hEle));
  if SelectedFile <> '' then
  begin
    Form.FPlayerPathEditUI.Text := SelectedFile;
    Form.FPlayerPathEditUI.Redraw();
  end;
  pbHandled^ := True;
  Result := 0;
end;

class function TConfigFormUI.OnNavListSelect(hEle: hEle; iItem: Integer; pbHandled: PBoolean): Integer;
var
  Form: TConfigFormUI;
  i: Integer;
begin
  Result := 0;
  Form := TConfigFormUI.GetClassFormHandle(XWidget_GetHWINDOW(hEle));
  if Assigned(Form) then
  begin
    for i := 0 to High(Form.FPageLayouts) do
    begin
      XWidget_Show(Form.FPageLayouts[i], i = iItem);
    end;

    XWnd_AdjustLayout(Form.Handle);
    Form.Redraw();
  end;
  pbHandled^ := True;
end;

procedure TConfigFormUI.SetupElementStyles(AParentEle: hEle);
var
  i: Integer;
  hChild: hEle;
  Widget: TObject;
  ObjType: XC_OBJECT_TYPE;
begin
  if AParentEle = 0 then
    Exit;

  for i := 0 to XEle_GetChildCount(AParentEle) - 1 do
  begin
    hChild := XEle_GetChildByIndex(AParentEle, i);
    ObjType := XC_GetObjectType(hChild);

    if ObjType = XC_EDIT then
    begin
      Widget := GetClassFormHandle(hChild);
      if Assigned(Widget) and (Widget is TEditUI) then
        TEditUI(Widget).EnableBorder := True;
    end
    else if ObjType = XC_SLIDERBAR then
    begin
      Widget := GetClassFormHandle(hChild);
      if Assigned(Widget) and (Widget is TSliderBarUI) then
      begin
        // 在这里可以为 TSliderBarUI 设置特定的样式
        // 由于样式已在 TSliderBarUI.Init 中通过主题加载，
        // 这里通常不需要额外代码，除非有特殊需求。
      end;
    end
    else if ObjType = XC_SHAPE_TEXT then
    begin
      XShapeText_SetTextColor(hChild, Theme_TextColor_Leave);
    end else if  ObjType = XC_SHAPE_RECT then
    begin
      XShapeRect_SetFillColor(hChild,RGBA(255,255,255,15));
    end;

    // 只对容器元素进行递归
    case ObjType of
      XC_ELE_LAYOUT, XC_LAYOUT_FRAME, XC_LAYOUT_BOX:
        SetupElementStyles(hChild);
    end;
  end;
end;

procedure TConfigFormUI.Init;
var
  i: integer;
begin
  inherited;
  FCloseBtnUI := TSvgBtnUI.FromXmlName('设置窗口_关闭按钮');
  FCloseBtnUI.Style('窗口组件\关闭.svg', '关闭', 16, 16, True);

  FConfirmBtnUI := TSvgBtnUI.FromXmlName('设置窗口_确认按钮');
  FConfirmBtnUI.BackgroundColor := Theme_PrimaryColor; // 使用主题主色调作为背景高亮色
  FConfirmBtnUI.CornerRadius := 4; // 设置较小的圆角

  FNavList := TListUI.FromXmlName('设置窗口_导航列表');
  FNavList.SetItemTemplateXML('List.xml');
  FNavList.SetHeaderHeight(0); // 不显示表头
  FNavList.ShowSBarH(False); // 不显示横向滚动条
  FNavList.SetRowHeightDefault(36, 36); // 设置默认行高
  FNavList.SetRowSpace(2);

  FNavList.AddItemText('常规设置');
  FNavList.AddItemText('扫描设置');
  FNavList.AddItemText('媒体库');
  FNavList.AddItemText('网络设置');
  FNavList.RegEvent(XE_LIST_SELECT, @TConfigFormUI.OnNavListSelect);
  FNavList.SetSelectRow(0);

  FContentLayout := TLayoutUI.FromXmlName('设置窗口_内容布局');
  FPageLayouts[0] := FContentLayout.LoadLayout('设置窗口\page0.xml');
  FPageLayouts[1] := FContentLayout.LoadLayout('设置窗口\page1.xml');
  FPageLayouts[2] := FContentLayout.LoadLayout('设置窗口\page2.xml');
  FPageLayouts[3] := FContentLayout.LoadLayout('设置窗口\page3.xml');

  XWidget_Show(FPageLayouts[0], True);
  XWidget_Show(FPageLayouts[1], False);
  XWidget_Show(FPageLayouts[2], False);
  XWidget_Show(FPageLayouts[3], False);

  FAutoRunBtnUI := TMultiSelectBtnUI.FromXmlName('设置窗口_常规设置_开机启动');
  FMinimizeToTrayBtnUI := TMultiSelectBtnUI.FromXmlName('设置窗口_常规设置_最小化到托盘');


  FAutoRunBtnUI.Style('', '', '', 14, 14);
  FMinimizeToTrayBtnUI.Style('', '', '', 14, 14);


  FAddBtnUI := TSvgBtnUI.FromXmlName('设置窗口_媒体库_添加按钮');
  FAddBtnUI.EnableBorder := True;
  FDeleteBtnUI := TSvgBtnUI.FromXmlName('设置窗口_媒体库_删除按钮');
  FDeleteBtnUI.EnableBorder := True;
  FClearBtnUI := TSvgBtnUI.FromXmlName('设置窗口_媒体库_清空按钮');
  FClearBtnUI.EnableBorder := True;

  FScanFormatEditUI := TEditUI.FromXmlName('设置窗口_常规设置_扫描格式编辑框');
  FExcludePathEditUI := TEditUI.FromXmlName('设置窗口_常规设置_排除文件编辑框');
  FExcludeSizeEditUI := TEditUI.FromXmlName('设置窗口_常规设置_排除大小编辑框');
  FExcludeSizeEditUI.EnableNumberOnly := True;
  FPlayerPathEditUI := TEditUI.FromXmlName('设置窗口_常规设置_播放器路径编辑框');
  FSelectPlayerPathBtnUI := TSvgBtnUI.FromXmlName('设置窗口_常规设置_播放器路径选择按钮');
  FSelectPlayerPathBtnUI.RegEvent(XE_BNCLICK, @TConfigFormUI.SelectPlayerPathBtnClick);
  FSelectPlayerPathBtnUI.EnableBorder := True;
  FMediaLibraryPathEditUI := TEditUI.FromXmlName('设置窗口_媒体库_路径编辑框');
  FProxyAddressEditUI := TEditUI.FromXmlName('设置窗口_网络设置_代理地址编辑框');
  FProxyPortEditUI := TEditUI.FromXmlName('设置窗口_网络设置_代理端口编辑框');

  FNoProxyBtnUI := TRadioBtnUI.FromXmlName('设置窗口_网络设置_不使用代理');
  FHttpProxyBtnUI := TRadioBtnUI.FromXmlName('设置窗口_网络设置_HTTP代理');
  FSocks5ProxyBtnUI := TRadioBtnUI.FromXmlName('设置窗口_网络设置_SOCKS5代理');

  FNoProxyBtnUI.Style('', '', '', 14, 14);
  FHttpProxyBtnUI.Style('', '', '', 14, 14);
  FSocks5ProxyBtnUI.Style('', '', '', 14, 14);

  for i := 0 to High(FPageLayouts) do
    SetupElementStyles(FPageLayouts[i]);

  FCancelBtnUI := TSvgBtnUI.FromXmlName('设置窗口_取消按钮');
  FCancelBtnUI.EnableBorder := True;
end;
end.
