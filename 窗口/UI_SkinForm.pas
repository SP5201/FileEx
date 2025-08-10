unit UI_SkinForm;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, XCGUI, XLayout, XWidget,
  UI_Resource, XForm, Ui_Color, UI_Form, UI_Button, UI_SliderBar, UI_Element,
  ConfigUnit;

type
  TSkinFormUI = class(TFormUI)
  private
    FCloseBtnUI: TSvgBtnUI;
    FThemeColor1Bg: TEleUI;
    FThemeColor2Bg: TEleUI;
    FThemeColor1Btn: TRadioBtnUI;  // 主题颜色1按钮
    FThemeColor2Btn: TRadioBtnUI;  // 主题颜色2按钮
    FHighlightColorBtns: array[0..5] of TRadioBtnUI; // 高亮颜色单选按钮数组
    procedure SetupElementStyles(AParentEle: hEle);
    class function OnThemeColorCheck(hEle: Integer; bCheck: Boolean; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnHighlightColorCheck(hEle: Integer; bCheck: Boolean; pbHandled: PBoolean): Integer; stdcall; static;
    procedure LoadThemeFromConfig;    // 根据配置设置主题选择
    procedure SaveThemeToConfig;      // 保存主题选择到配置
  protected
    procedure Init; override;
    class function OnDestroy(hEle: Integer; pbHandled: PBoolean): Integer; stdcall; static;
  public
    // 公共方法和属性
  end;

implementation

uses
  Winapi.Messages, Winapi.ShellAPI;

{ TSkinFormUI }

procedure TSkinFormUI.Init;
var
  i: integer;
begin
  inherited;
  FCloseBtnUI := TSvgBtnUI.FromXmlID(Handle, 2);
  FCloseBtnUI.Style('窗口组件\关闭.svg', '关闭', 16, 16, True);

  FThemeColor1Bg := TEleUI.GetObjectFromXmlName('主题颜色1背景');
  FThemeColor1Bg.BackgroundColor := RGBA(0, 0, 0, 155);      // 黑色
  FThemeColor1Bg.CornerRadius := 6;
  FThemeColor2Bg := TEleUI.GetObjectFromXmlName('主题颜色2背景');
  FThemeColor2Bg.BackgroundColor := RGBA(255, 255, 255, 245); // 白色
  FThemeColor2Bg.CornerRadius := 6;
  FThemeColor1Btn := TRadioBtnUI.FromXmlName('主题颜色1');
  FThemeColor2Btn := TRadioBtnUI.FromXmlName('主题颜色2');
  FThemeColor1Btn.Style('', '', '', 16, 16);
  FThemeColor2Btn.Style('', '', '', 16, 16);


  // 设置高亮图标颜色
  FThemeColor1Btn.IconColor := Theme_PrimaryColor;     // 主色调高亮
  FThemeColor2Btn.IconColor := Theme_PrimaryColor;     // 主色调高亮
  for i := 0 to 5 do
  begin
    FHighlightColorBtns[i] := TRadioBtnUI.FromHandle(XEle_GetChildByIndex(XC_GetObjectByID(Handle, 3),i));
    FHighlightColorBtns[i].Style('', '', '', 16, 16);
    FHighlightColorBtns[i].IconColor := TeHme_PrimaryColors[i];
    FHighlightColorBtns[i].SetGroupID(22);
    FHighlightColorBtns[i].RegEvent(XE_BUTTON_CHECK, @OnHighlightColorCheck);
  end;


  // 注册事件
  FThemeColor1Btn.RegEvent(XE_BUTTON_CHECK, @OnThemeColorCheck);
  FThemeColor2Btn.RegEvent(XE_BUTTON_CHECK, @OnThemeColorCheck);
  RegEvent(WM_DESTROY, @OnDestroy);
  // 根据配置设置主题选择
  LoadThemeFromConfig;

  SetupElementStyles(XC_GetObjectByID(Handle, 1));
end;

procedure TSkinFormUI.SetupElementStyles(AParentEle: hEle);
var
  i: Integer;
  hChild: hEle;
  ObjType: XC_OBJECT_TYPE;
begin
  if AParentEle = 0 then
    Exit;
  for i := 0 to XEle_GetChildCount(AParentEle) - 1 do
  begin
    hChild := XEle_GetChildByIndex(AParentEle, i);
    ObjType := XC_GetObjectType(hChild);

    if ObjType = XC_SHAPE_TEXT then
    begin
      XShapeText_SetTextColor(hChild, Theme_TextColor_Leave);
    end
    else if ObjType = XC_SHAPE_RECT then
    begin
      XShapeRect_SetFillColor(hChild, RGBA(255, 255, 255, 25));
    end
    else if ObjType = XC_SLIDERBAR then
    begin
      TSliderBarUI.GetObjectFromHandle(hChild);
    end;
    // 只对容器元素进行递归
    case ObjType of
      XC_ELE_LAYOUT, XC_LAYOUT_FRAME, XC_LAYOUT_BOX:
        SetupElementStyles(hChild);
    end;
  end;
end;

class function TSkinFormUI.OnDestroy(hEle: Integer; pbHandled: PBoolean): Integer;
var
  SkinFormUI: TSkinFormUI;
begin
  Result := 0;
  SkinFormUI := TXWidget.GetClassFormHandle(hEle);
  if Assigned(SkinFormUI) then
  begin
    // 保存主题选择到配置
    SkinFormUI.SaveThemeToConfig;
  end;
end;

class function TSkinFormUI.OnThemeColorCheck(hEle: Integer; bCheck: Boolean; pbHandled: PBoolean): Integer;
var
  BtnName: string;
begin
  Result := 0;
  if bCheck then
  begin
    // 通过按钮名称判断是哪个主题颜色
    BtnName := string(XWidget_GetName(hEle));
    if BtnName = '主题颜色1' then
      Config.SetThemeColorIndex(1)
    else if BtnName = '主题颜色2' then
      Config.SetThemeColorIndex(2);
  end;
end;

class function TSkinFormUI.OnHighlightColorCheck(hEle: Integer; bCheck: Boolean; pbHandled: PBoolean): Integer;
var
  SkinFormUI: TSkinFormUI;
  i: Integer;
begin
  Result := 0;
  if bCheck then
  begin
    // 获取 SkinFormUI 实例
    SkinFormUI := GetClassFormHandle(XWidget_GetHWND(hEle));
    if Assigned(SkinFormUI) then
    begin
      // 查找是哪个高亮颜色按钮被选中
      for i := 0 to 5 do
      begin
        if SkinFormUI.FHighlightColorBtns[i].Handle = hEle then
        begin
          // 设置主色调为选中的颜色
          XTheme_SetPrimaryColor(i);
          // 保存到配置
          Theme_PrimaryColor:= TeHme_PrimaryColors[i];
          Config.SetHighlightColorIndex(i);
          SkinFormUI.Redraw;
          Break;
        end;
      end;
    end;
  end;
end;

procedure TSkinFormUI.LoadThemeFromConfig;
var
  HighlightIndex: Integer;
begin
  // 根据配置设置主题颜色选中状态
  case Config.ConfigData.ThemeColorIndex of
    1:
      FThemeColor1Btn.Check := True;
    2:
      FThemeColor2Btn.Check := True;
  else
    FThemeColor1Btn.Check := True; // 默认选择主题颜色1
  end;
  
  // 根据配置设置高亮颜色选中状态
  HighlightIndex := Config.ConfigData.HighlightColorIndex;
  if (HighlightIndex >= 0) and (HighlightIndex <= 5) then
  begin
    FHighlightColorBtns[HighlightIndex].Check := True;
    // 设置主色调
    XTheme_SetPrimaryColor(HighlightIndex);
  end
  else
  begin
    // 默认选择索引1（蓝色）
    FHighlightColorBtns[1].Check := True;
    XTheme_SetPrimaryColor(1);
  end;
end;

procedure TSkinFormUI.SaveThemeToConfig;
var
  i: Integer;
begin
  // 保存当前选中的主题到配置
  if FThemeColor1Btn.Check then
    Config.SetThemeColorIndex(1)
  else if FThemeColor2Btn.Check then
    Config.SetThemeColorIndex(2);

  // 保存当前选中的高亮颜色到配置
  for i := 0 to 5 do
  begin
    if FHighlightColorBtns[i].Check then
    begin
      Config.SetHighlightColorIndex(i);
      Break;
    end;
  end;

  // 立即保存配置到文件
  Config.SaveToFile;
end;

end.

