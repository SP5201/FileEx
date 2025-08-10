unit UI_Color;

interface

uses
  Windows, System.Generics.Collections, XCGUI;

type
  TTheme = (thLight, thDark); // 定义了2种主题：亮色和暗色主题

  TThemeChangeEvent = procedure of object;

var
  ThTheme: TTheme;
  Theme_Window_BkColor: Integer;
  Theme_Window_BkColor_Title: Integer;
  Theme_Window_BkColor_Left: Integer;
  Theme_Window_BkColor_Bottom: Integer;
  Theme_Window_BorderColor: Integer;
  Theme_Edit_BorderColor_focus: Integer;
  Theme_Edit_BorderColor_focus_no: Integer;
  Theme_TextColor_Leave: Integer;
  Theme_TextColor_Stay: Integer;
  Theme_TextColor_Down: Integer;
  Theme_EleBkColor_Leave: Integer;
  Theme_BtnBkColor_Leave: Integer;
  Theme_BtnBkColor_Stay: Integer;
  Theme_BtnBkColor_Down: Integer;
  Theme_EleBorderColor: Integer;
  Theme_ItemBkColor_Leave: Integer;
  Theme_ItemBkColor_Stay: Integer;
  Theme_ItemBkColor_Select: Integer;
  Theme_ItemBkColor_Cache: Integer;
  Theme_SvgColor_Leave: Integer;
  Theme_SvgColor_Stay: Integer;
  Theme_SvgColor_Down: Integer;
  Theme_MenuBkColor_Stay: Integer;
  Theme_EDit_TextColor: Integer;
  Theme_EDit_CaretColor: Integer;
  Theme_EDit_Default: Integer;
  Theme_SvgLabel_TextColor: Integer; // SvgLabel 文字颜色
  Theme_PrimaryColor: Integer; // 主色调 - 用于重要组件的高亮背景色
  Theme_Window_CornerRadius: Integer; // 窗口圆角大小
  Theme_Button_CornerRadius: Integer; // 按钮圆角大小
  Theme_Edit_CornerRadius: Integer; // 编辑框圆角大小
  TeHme_PrimaryColors: array[0..5] of Integer; // 主色调数组，包含6个成员
  ThemeChangeCallbacks: TList<TThemeChangeEvent>;

procedure XTheme_SetTheme(const Theme: TTheme);

function XTheme_GetTheme: TTheme;

procedure XTheme_SetPrimaryColor(const ColorIndex: Integer);

procedure XTheme_AddChangeCallback(Callback: TThemeChangeEvent);

procedure XTheme_RemoveThemeChangeCallback(Callback: TThemeChangeEvent);

implementation

uses
  Ui_Layout;

procedure XTheme_AddChangeCallback(Callback: TThemeChangeEvent);
begin
  if Assigned(Callback) and (ThemeChangeCallbacks.IndexOf(Callback) = -1) then
    ThemeChangeCallbacks.Add(Callback);
end;

// 移除主题变化回调
procedure XTheme_RemoveThemeChangeCallback(Callback: TThemeChangeEvent);
begin
  ThemeChangeCallbacks.Remove(Callback);
end;

procedure XTheme_SetTheme(const Theme: TTheme);
begin
  case Theme of
    thLight:
      begin
        Theme_PrimaryColor := TeHme_PrimaryColors[0]; // 主色调设置为数组第一个元素
        Theme_Window_BkColor := RGBA(255, 255, 255, 255);
        Theme_Window_BkColor_Title := RGBA(0, 0, 0, 5);
        Theme_Window_BkColor_Left := RGBA(0, 0, 0, 6);
        Theme_Window_BkColor_Bottom := RGBA(0, 0, 0, 3);
        Theme_Window_BorderColor := RGBA(0, 0, 0, 220);
        Theme_Edit_BorderColor_focus := RGBA(0, 0, 0, 140);
        Theme_Edit_BorderColor_focus_no := RGBA(0, 0, 0, 60);
        Theme_TextColor_Leave := RGBA(0, 0, 0, 200);
        // Theme_PrimaryColor 现在从 TeHme_PrimaryColors[0] 获取
        Theme_TextColor_Stay := Theme_PrimaryColor;
        Theme_TextColor_Down := Theme_PrimaryColor;
        Theme_EleBkColor_Leave := RGBA(0, 0, 0, 30);
        Theme_BtnBkColor_Leave := RGBA(0, 0, 0, 60);
        Theme_BtnBkColor_Stay := RGBA(0, 0, 0, 140);
        Theme_BtnBkColor_Down := RGBA(0, 0, 0, 140);
        Theme_EleBorderColor := RGBA(0, 0, 0, 80);
        Theme_ItemBkColor_Leave := RGBA(0, 0, 0, 0);
        Theme_ItemBkColor_Stay := RGBA(0, 0, 0, 20);
        Theme_ItemBkColor_Select := RGBA(0, 0, 0, 30);
        Theme_ItemBkColor_Cache := RGBA(0, 0, 0, 10);
        Theme_SvgColor_Leave := RGBA(0, 0, 0, 100);
        Theme_SvgColor_Stay := RGBA(0, 0, 0, 230);
        Theme_SvgColor_Down := RGBA(20, 0, 0, 160);
        Theme_MenuBkColor_Stay := RGBA(0, 0, 0, 30);
        Theme_EDit_TextColor := RGBA(0, 0, 0, 180);
        Theme_EDit_CaretColor := RGBA(0, 0, 0, 180);
        Theme_EDit_Default := RGBA(0, 0, 0, 60);
        Theme_SvgLabel_TextColor := RGBA(166, 173, 186, 200);
        // 初始化 TeHme_PrimaryColors 数组 - 亮色主题
        TeHme_PrimaryColors[0] := RGBA(210, 27, 70, 255);   // 红色
        TeHme_PrimaryColors[1] := RGBA(0, 122, 255, 255);   // 蓝色
        TeHme_PrimaryColors[2] := RGBA(52, 199, 89, 255);   // 绿色
        TeHme_PrimaryColors[3] := RGBA(255, 149, 0, 255);   // 橙色
        TeHme_PrimaryColors[4] := RGBA(175, 82, 222, 255);  // 紫色
        TeHme_PrimaryColors[5] := RGBA(255, 204, 0, 255);   // 黄色
      end;
    thDark:
      begin
        Theme_PrimaryColor := TeHme_PrimaryColors[0]; // 主色调设置为数组第一个元素
        Theme_Window_BkColor := RGBA(46, 47, 51, 255);
        Theme_Window_BkColor_Title := RGBA(255, 255, 255, 5);
        Theme_Window_BkColor_Left := RGBA(255, 255, 255, 5);
        Theme_Window_BkColor_Bottom := RGBA(0, 0, 0, 15);
        Theme_Window_BorderColor := RGBA(72, 72, 72, 220);
        Theme_Edit_BorderColor_focus := RGBA(255, 255, 255, 140);
        Theme_Edit_BorderColor_focus_no := RGBA(255, 255, 255, 60);
        Theme_TextColor_Leave := RGBA(255, 255, 255, 200);
        // Theme_PrimaryColor 现在从 TeHme_PrimaryColors[0] 获取
        Theme_TextColor_Stay := Theme_PrimaryColor;
        Theme_TextColor_Down := Theme_PrimaryColor;
        Theme_EleBkColor_Leave := RGBA(255, 255, 255, 30);
        Theme_BtnBkColor_Leave := RGBA(255, 255, 255, 60);
        Theme_BtnBkColor_Stay := RGBA(255, 255, 255, 140);
        Theme_BtnBkColor_Down := RGBA(255, 255, 255, 140);
        Theme_EleBorderColor := RGBA(255, 255, 255, 80);
        Theme_ItemBkColor_Leave := RGBA(0, 0, 0, 25);
        Theme_ItemBkColor_Stay := RGBA(255, 255, 255, 25);
        Theme_ItemBkColor_Select := RGBA(255, 255, 255, 35);
        Theme_ItemBkColor_Cache := RGBA(255, 255, 255, 10);
        Theme_SvgColor_Leave := RGBA(255, 255, 255, 140);
        Theme_SvgColor_Stay := RGBA(255, 255, 255, 230);
        Theme_SvgColor_Down := RGBA(255, 255, 255, 230);
        Theme_MenuBkColor_Stay := RGBA(255, 255, 255, 30);
        Theme_EDit_TextColor := RGBA(255, 255, 255, 180);
        Theme_EDit_CaretColor := RGBA(255, 255, 255, 180);
        Theme_EDit_Default := RGBA(255, 255, 255, 60);
        Theme_SvgLabel_TextColor := RGBA(166, 173, 186, 200);
        // 初始化 TeHme_PrimaryColors 数组 - 暗色主题
        TeHme_PrimaryColors[0] := RGBA(255, 69, 58, 255);   // 红色
        TeHme_PrimaryColors[1] := RGBA(10, 132, 255, 255);  // 蓝色
        TeHme_PrimaryColors[2] := RGBA(48, 209, 88, 255);   // 绿色
        TeHme_PrimaryColors[3] := RGBA(255, 159, 10, 255);  // 橙色
        TeHme_PrimaryColors[4] := RGBA(191, 90, 242, 255);  // 紫色
        TeHme_PrimaryColors[5] := RGBA(255, 214, 10, 255);  // 黄色

      end;
  end;

  // 固定值，不受主题影响 - 在最后设置
  Theme_Window_CornerRadius := 9;
  Theme_Button_CornerRadius := 4;
  Theme_Edit_CornerRadius := 4;

  ThTheme := Theme;
end;

function XTheme_GetTheme: TTheme;
begin
  Result := ThTheme;
end;

procedure XTheme_SetPrimaryColor(const ColorIndex: Integer);
begin
  // 确保颜色索引在有效范围内
  if (ColorIndex >= 0) and (ColorIndex <= 5) then
  begin
    // 设置主色调为选中的颜色
    Theme_PrimaryColor := TeHme_PrimaryColors[ColorIndex];

    // 更新依赖于主色调的其他颜色
    Theme_TextColor_Stay := Theme_PrimaryColor;
    Theme_TextColor_Down := Theme_PrimaryColor;
  end;
end;

initialization
  // 初始化回调列表
  ThemeChangeCallbacks := TList<TThemeChangeEvent>.Create;
  // 设置默认主题为亮色
  XTheme_SetTheme(thLight);


finalization
  // 释放回调列表
  ThemeChangeCallbacks.Free;

end.

