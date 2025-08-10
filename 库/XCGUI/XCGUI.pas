unit xcgui;

interface

uses
  Windows,System.Types, SysUtils, System.Variants, D2D1;

const
  XCGUI_DLL = 'XCGUI.dll';
  // 定义一个常量 XC_ID_ROOT，值为 0，用于表示根节点
  XC_ID_ROOT = 0;
  // 定义一个常量 XC_ID_ERROR，值为 -1，用于表示 ID 错误
  XC_ID_ERROR = -1;
  // 定义一个常量 XC_ID_FIRST，值为 -2，用于表示插入开始位置（当前层）
  XC_ID_FIRST = -2;
  // 定义一个常量 XC_ID_LAST，值为 -3，用于表示插入末尾位置（当前层）
  XC_ID_LAST = -3;
    // 不调整，值为 $00
  adjustLayout_no = $00;
    // 强制调整全部，值为 $01
  adjustLayout_all = $01;
    // 只调整自身，值为 $02
  adjustLayout_self = $02;

const
//窗口事件
  XWM_REDRAW_ELE = $7000 + 1;
  XWM_WINDPROC = $7000 + 2;
  XWM_DRAW_T = $7000 + 3;
  XWM_TIMER_T = $7000 + 4;
  XWM_XC_TIMER = $7000 + 5;
  XWM_CLOUDUI_DOWNLOADFILE_COMPLETE = $7000 + 6;
  XWM_CLOUNDUI_OPENURL_WAIT = $7000 + 7;
  XWM_CALL_UI_THREAD = $7000 + 8;
  XWM_SETFOCUS_ELE = $7000 + 9;
  XWM_TRAYICON = $7000 + 10;
  XWM_MENU_POPUP = $7000 + 11;
  XWM_MENU_POPUP_WND = $7000 + 12;
  XWM_MENU_SELECT = $7000 + 13;
  XWM_MENU_EXIT = $7000 + 14;
  XWM_MENU_DRAW_BACKGROUND = $7000 + 15;
  XWM_MENU_DRAWITEM = $7000 + 16;
  XWM_COMBOBOX_POPUP_DROPLIST = $7000 + 17;
  XWM_FLOAT_PANE = $7000 + 18;
  XWM_PAINT_END = $7000 + 19;
  XWM_PAINT_DISPLAY = $7000 + 20;
  XWM_DOCK_POPUP = $7000 + 21;
  XWM_FLOATWND_DRAG = $7000 + 22;
  XWM_PANE_SHOW = $7000 + 23;
  XWM_BODYVIEW_RECT = $7000 + 24;
//元素事件
  XE_ELEPROCE = 1; //
  XE_PAINT_END = 3; //
  XE_MOUSESTAY = 6; //
  XE_MOUSEHOVER = 7; //
  XE_MOUSELEAVE = 8; //
  XE_MOUSEWHEEL = 9; //
  XE_PAINT = 2; //
  XE_PAINT_SCROLLVIEW = 4; //
  XE_MOUSEMOVE = 5; //

  XE_LBUTTONDOWN = 10; //
  XE_LBUTTONUP = 11; //
  XE_RBUTTONDOWN = 12; //
  XE_RBUTTONUP = 13; //
  XE_LBUTTONDBCLICK = 14; //
  XE_RBUTTONDBCLICK = 15; //
  XE_XC_TIMER = 16; //
  XE_ADJUSTLAYOUT_END = 18;
  XE_SETFOCUS = 31; //
  XE_KILLFOCUS = 32; //
  XE_DESTROY = 33; //
  XE_BNCLICK = 34; //
  XE_BUTTON_CHECK = 35; //
  XE_EDIT_CHANGED = 182;
  XE_EDIT_POS_CHANGED = 183;
  XE_SIZE = 36; //
  XE_SHOW = 37; //
  XE_SETFONT = 38; //
  XE_KEYDOWN = 39; //
  XE_KEYUP = 40; //
  XE_CHAR = 41; //
  XE_DESTROY_END = 42;
  XE_SETCAPTURE = 51; //
  XE_KILLCAPTURE = 52; //
  XE_SETCURSOR = 53; //
  XE_SCROLLVIEW_SCROLL_H = 54; //
  XE_SCROLLVIEW_SCROLL_V = 55; //
  XE_SBAR_SCROLL = 56; //
  XE_MENU_POPUP = 57; //
  XE_MENU_POPUP_WND = 58; //
  XE_MENU_SELECT = 59; //
  XE_MENU_DRAW_BACKGROUND = 60; //
  XE_MENU_DRAWITEM = 61; //
  XE_MENU_EXIT = 62; //
  XE_SLIDERBAR_CHANGE = 63; //
  XE_PROGRESSBAR_CHANGE = 64; //
  XE_COMBOBOX_SELECT = 71; //
  XE_COMBOBOX_SELECT_END = 74; //
  XE_COMBOBOX_POPUP_LIST = 72; //
  XE_COMBOBOX_EXIT_LIST = 73; //
  XE_LISTBOX_TEMP_CREATE = 81; //
  XE_LISTBOX_TEMP_CREATE_END = 82; //
  XE_LISTBOX_TEMP_DESTROY = 83; //
  XE_LISTBOX_TEMP_ADJUST_COORDINATE = 84; //
  XE_LISTBOX_DRAWITEM = 85; //
  XE_LISTBOX_SELECT = 86; //
  XE_LIST_TEMP_CREATE = 101; //
  XE_LIST_TEMP_CREATE_END = 102; //
  XE_LIST_TEMP_DESTROY = 103; //
  XE_LIST_TEMP_ADJUST_COORDINATE = 104; //
  XE_LIST_DRAWITEM = 105; //
  XE_LIST_SELECT = 106; //
  XE_LIST_HEADER_DRAWITEM = 107; //
  XE_LIST_HEADER_CLICK = 108; //
  XE_LIST_HEADER_WIDTH_CHANGE = 109; //
  XE_LIST_HEADER_TEMP_CREATE = 110; //
  XE_LIST_HEADER_TEMP_CREATE_END = 111; //
  XE_LIST_HEADER_TEMP_DESTROY = 112; //
  XE_LIST_HEADER_TEMP_ADJUST_COORDINATE = 113; //
  XE_TREE_TEMP_CREATE = 121; //
  XE_TREE_TEMP_CREATE_END = 122; //
  XE_TREE_TEMP_DESTROY = 123; //
  XE_TREE_TEMP_ADJUST_COORDINATE = 124; //
  XE_TREE_DRAWITEM = 125; //
  XE_TREE_SELECT = 126; //
  XE_TREE_EXPAND = 127; //
  XE_TREE_DRAG_ITEM_ING = 128; //
  XE_TREE_DRAG_ITEM = 129; //
  XE_LISTVIEW_TEMP_CREATE = 141; //
  XE_LISTVIEW_TEMP_CREATE_END = 142; //
  XE_LISTVIEW_TEMP_DESTROY = 143; //
  XE_LISTVIEW_TEMP_ADJUST_COORDINATE = 144; //
  XE_LISTVIEW_DRAWITEM = 145; //
  XE_LISTVIEW_SELECT = 146; //
  XE_LISTVIEW_EXPAND = 147; //
  XE_PGRID_VALUE_CHANGE = 151; //
  XE_PGRID_ITEM_SET = 152; //
  XE_PGRID_ITEM_SELECT = 153; //
  XE_PGRID_ITEM_ADJUST_COORDINATE = 154; //
  XE_PGRID_ITEM_DESTROY = 155; //
  XE_RICHEDIT_CHANGE = 161; //
  XE_RICHEDIT_SET = 162; //
  XE_TABBAR_SELECT = 221; //
  XE_TABBAR_DELETE = 222; //
  XE_MONTHCAL_CHANGE = 231; //
  XE_DATETIME_CHANGE = 241; //
  XE_DATETIME_POPUP_MONTHCAL = 242; //
  XE_DATETIME_EXIT_MONTHCAL = 243; //
  XE_DROPFILES = 250; //

type
{$IFDEF WIN64}
  vint = Integer;
{$ELSE}

  vint = Integer;
{$ENDIF}

type
  // 炫彩句柄，使用 Integer 表示资源句柄
  HXCGUI = Integer;
  // 窗口资源句柄，使用 Integer，具体类型可能由 DECLARE_HANDLEX 宏定义，这里假设为 Integer

  HWINDOW = Integer;
  // 元素资源句柄，使用 Integer，具体类型可能由 DECLARE_HANDLEX 宏定义，这里假设为 Integer

  HELE = Integer;
  // 菜单资源句柄，使用 Integer，具体类型可能由 DECLARE_HANDLEX 宏定义，这里假设为 Integer

  HMENUX = Integer;
  // 图形绘制资源句柄，使用 Integer，具体类型可能由 DECLARE_HANDLEX 宏定义，这里假设为 Integer

  HDRAW = Integer;
  // 图片资源句柄，使用 Integer，具体类型可能由 DECLARE_HANDLEX 宏定义，这里假设为 Integer

  HIMAGE = Integer;
  // 炫彩字体句柄，使用 Integer，具体类型可能由 DECLARE_HANDLEX 宏定义，这里假设为 Integer

  HFONTX = Integer;
  // 背景内容管理器句柄，使用 Integer，具体类型可能由 DECLARE_HANDLEX 宏定义，这里假设为 Integer

  HBKM = Integer;
  // 模板句柄，使用 Integer，具体类型可能由 DECLARE_HANDLEX 宏定义，这里假设为 Integer

  HTEMP = Integer;
  // SVG 句柄，使用 Integer，具体类型可能由 DECLARE 宏定义，这里假设为 Integer

  HSVG = Integer;

type
  XC_OBJECT_TYPE = Integer;

const
    // @别名  错误
  XC_ERROR = -1;          // <错误类型
    // @别名  啥也不是
  XC_NOTHING = 0;         // <啥也不是
    // @别名  窗口
  XC_WINDOW = 1;          // <窗口
    // @别名  模态窗口
  XC_MODALWINDOW = 2;      // <模态窗口
    // @别名  框架窗口
  XC_FRAMEWND = 3;         // <框架窗口
    // @别名  浮动窗口
  XC_FLOATWND = 4;       // <浮动窗口
    // @别名  组合框下拉窗口
  XC_COMBOBOXWINDOW = 11;  // <组合框弹出下拉列表窗口 comboBoxWindow_
    // @别名  菜单主窗口
  XC_POPUPMENUWINDOW = 12;  // <弹出菜单主窗口 popupMenuWindow_
    // @别名  菜单子窗口
  XC_POPUPMENUCHILDWINDOW = 13; // <弹出菜单子窗口 popupMenuChildWindow_
    // @别名  可视对象
  XC_OBJECT_UI = 19;       // <可视对象
    // @别名  窗口组件
  XC_WIDGET_UI = 20;       // <窗口组件
    // @别名  基础元素
  XC_ELE = 21;            // <基础元素
    // @别名  布局元素
  XC_ELE_LAYOUT = 53;      // <布局元素
    // @别名  布局框架
  XC_LAYOUT_FRAME = 54;    // <布局框架;流式布局
    // @别名  按钮
  XC_BUTTON = 22;         // <按钮
    // @别名  编辑框
  XC_EDIT = 45;           // <编辑框
    // @别名  代码编辑框
  XC_EDITOR = 46;         // <代码编辑框
    // @别名  富文本编辑框(已废弃); 请使用XC_EDIT
  XC_RICHEDIT = 23;       // <富文本编辑框(已废弃); 请使用XC_EDIT
    // @别名  下拉组合框
  XC_COMBOBOX = 24;       // <下拉组合框
    // @别名  滚动条
  XC_SCROLLBAR = 25;      // <滚动条
    // @别名  滚动视图
  XC_SCROLLVIEW = 26;     // <滚动视图
    // @别名  列表
  XC_LIST = 27;          // <列表
    // @别名  列表框
  XC_LISTBOX = 28;        // <列表框
    // @别名  列表视图
  XC_LISTVIEW = 29;       // <列表视图;大图标
    // @别名  列表树
  XC_TREE = 30;          // <列表树
    // @别名  菜单条
  XC_MENUBAR = 31;        // <菜单条
    // @别名  滑动条
  XC_SLIDERBAR = 32;      // <滑动条
    // @别名  进度条
  XC_PROGRESSBAR = 33;    // <进度条
    // @别名  工具条
  XC_TOOLBAR = 34;        // <工具条
    // @别名  月历卡片
  XC_MONTHCAL = 35;       // <月历卡片
    // @别名  日期时间
  XC_DATETIME = 36;       // <日期时间
    // @别名  属性网格
  XC_PROPERTYGRID = 37;   // <属性网格
    // @别名  颜色选择框
  XC_EDIT_COLOR = 38;     // <颜色选择框
    // @别名  设置编辑框
  XC_EDIT_SET = 39;       // <设置编辑框
    // @别名  TAB条
  XC_TABBAR = 40;        // <tab条
    // @别名  文本链接按钮
  XC_TEXTLINK = 41;       // <文本链接按钮
    // @别名  窗格
  XC_PANE = 42;          // <窗格
    // @别名  窗格分割条
  XC_PANE_SPLIT = 43;     // <窗格拖动分割条
    // @别名  菜单条上按钮
  XC_MENUBAR_BUTTON = 44;  // <菜单条上的按钮
    // @别名  文件选择编辑框
  XC_EDIT_FILE = 50;      // <EditFile 文件选择编辑框
    // @别名  文件夹选择编辑框
  XC_EDIT_FOLDER = 51;    // <EditFolder 文件夹选择编辑框
    // @别名  列表头元素
  XC_LIST_HEADER = 52;    // <列表头元素
    // @别名  形状对象
  XC_SHAPE = 61;         // <形状对象
    // @别名  形状对象文本
  XC_SHAPE_TEXT = 62;     // <形状对象-文本
    // @别名  形状对象图片
  XC_SHAPE_PICTURE = 63;   // <形状对象-图片
    // @别名  形状对象矩形
  XC_SHAPE_RECT = 64;     // <形状对象-矩形
    // @别名  形状对象圆形
  XC_SHAPE_ELLIPSE = 65;   // <形状对象-圆形
    // @别名  形状对象直线
  XC_SHAPE_LINE = 66;     // <形状对象-直线
    // @别名  形状对象组框
  XC_SHAPE_GROUPBOX = 67;  // <形状对象-组框
    // @别名  形状对象GIF
  XC_SHAPE_GIF = 68;     // <形状对象-GIF
    // @别名  形状对象表格
  XC_SHAPE_TABLE = 69;    // <形状对象-表格
    // @别名  弹出菜单
  XC_MENU = 81;         // <弹出菜单
    // @别名  图片源
  XC_IMAGE_TEXTURE = 82;  // <图片纹理;图片源;图片素材
    // @别名  绘图
  XC_HDRAW = 83;         // <绘图操作
    // @别名  字体
  XC_FONT = 84;          // <炫彩字体
    // @别名  图片帧
  XC_IMAGE_FRAME = 88;    // <图片帧;指定图片的渲染属性
  XC_IMAGE = 88;
    // @别名  SVG
  XC_SVG = 89;           // <SVG矢量图形
    // @别名  布局对象LayoutObject; 已废弃
  XC_LAYOUT_OBJECT = 101;  // <布局对象LayoutObject; 已废弃
    // @别名  数据适配器
  XC_ADAPTER = 102;       // <数据适配器Adapter
    // @别名  数据适配器表
  XC_ADAPTER_TABLE = 103; // <数据适配器AdapterTable
    // @别名  数据适配器树
  XC_ADAPTER_TREE = 104;  // <数据适配器AdapterTree
    // @别名  数据适配器列表视图
  XC_ADAPTER_LISTVIEW = 105; // <数据适配器AdapterListView
    // @别名  数据适配器MAP
  XC_ADAPTER_MAP = 106;   // <数据适配器AdapterMap
    // @别名  背景管理器
  XC_BKINFOM = 116;       // <背景管理器
    // 无实体对象;只是用来判断布局
  XC_LAYOUT_LISTVIEW = 111;  // <内部使用
  XC_LAYOUT_LIST = 112;    // <内部使用
  XC_LAYOUT_OBJECT_GROUP = 113; // <内部使用
  XC_LAYOUT_OBJECT_ITEM = 114;  // <内部使用
  XC_LAYOUT_PANEL = 115;       // <内部使用
    // @别名  布局盒子
  XC_LAYOUT_BOX = 124;        // <布局盒子;复合类型
    // @别名  动画序列
  XC_ANIMATION_SEQUENCE = 131; // <动画序列
    // @别名  动画组
  XC_ANIMATION_GROUP = 132;   // <动画同步组
    // @别名  动画项
  XC_ANIMATION_ITEM = 133;   // <动画项

type
  XC_OBJECT_TYPE_EX = Integer;

const
  xc_ex_error = -1;        // <错误类型
  button_type_default = 0;  // <默认类型
  button_type_radio = 1;    // <单选按钮
  button_type_check = 2;    // <多选按钮
  button_type_close = 3;    // <窗口关闭按钮
  button_type_min = 4;      // <窗口最小化按钮
  button_type_max = 5;      // <窗口最大化还原按钮
  element_type_layout = 6;  // <布局元素，启用布局功能的元素

type
  // 定义菜单弹出窗口结构
  Tmenu_popupWnd_ = record
    // 别名：窗口句柄
    hWindow: HWINDOW;  // 窗口句柄
    // 别名：父项ID
    nParentID: Integer; // 父项ID
  end;

type
  // 定义菜单绘制项结构
  Tmenu_drawItem_ = record
    // 别名：菜单句柄
    hMenu: HMENUX;       // 菜单句柄
    // 别名：窗口句柄
    hWindow: HWINDOW;    // 当前弹出菜单项的窗口句柄
    // 别名：项ID
    nID: Integer;        // ID
    // 别名：状态
    nState: Integer;     // 状态 @ref menu_item_flag_
    // 别名：右侧快捷键占位宽度
    nShortcutKeyWidth: Integer; // 右侧快捷键占位宽度
    // 别名：项坐标
    rcItem: TRect;       // 坐标
    // 别名：项图标
    hIcon: HIMAGE;       // 菜单项图标
    // 别名：文本
    pText: PWideChar;    // 文本
  end;

type
  Tmenu_drawBackground_ = record
    hMenu: HMENUX;      // 菜单句柄
    hWindow: HWINDOW;   // 当前弹出菜单项的窗口句柄
    nParentID: Integer; // 父项ID
  end;

type
  POINT = record
    x: Integer;
    y: Integer;
  end;

  PPOINT = ^POINT;

type
  POINTF = record
    x: Single;
    y: Single;
  end;

  PPOINTF = ^POINTF;

type
  // 定义一个结构体 borderSize_，用于存储四条边的大小
  TborderSize_ = record
    // 左边的大小，使用 Integer 类型
    leftSize: Integer;
    // 上边的大小，使用 Integer 类型
    topSize: Integer;
    // 右边的大小，使用 Integer 类型
    rightSize: Integer;
    // 下边的大小，使用 Integer 类型
    bottomSize: Integer;
  end;

// 将 borderSize_ 类型定义为 spaceSize_ 的别名
type
  TspaceSize_ = TborderSize_;
// 将 borderSize_ 类型定义为 paddingSize_ 的别名

type
  TpaddingSize_ = TborderSize_;
// 将 borderSize_ 类型定义为 marginSize_ 的别名

type
  TmarginSize_ = TborderSize_;

type
  // 定义一个枚举类型 window_state_flag_，表示窗口状态
  window_state_flag_ = Integer;

const
    // 无状态，值为 0
  window_state_flag_nothing = $0000;
    // 整个窗口状态，值为 1
  window_state_flag_leave = $0001;
    // 内容区状态，值为 2
  window_state_flag_body_leave = $0002;
    // 顶部状态，值为 4
  window_state_flag_top_leave = $0004;
    // 底部状态，值为 8
  window_state_flag_bottom_leave = $0008;
    // 左侧状态，值为 16
  window_state_flag_left_leave = $0010;
    // 右侧状态，值为 32
  window_state_flag_right_leave = $0020;
    // 布局内容区状态，值为 $20000000
  window_state_flag_layout_body = $20000000;

type
  // 定义一个枚举类型 window_transparent_，表示窗口透明标识
  window_transparent_ = (
    // 不透明，值为 0
    window_transparent_false = 0,
    // 透明窗口，带透明通道，异型，将自动赋值为 1
    window_transparent_shaped,
    // 阴影窗口，带透明通道，边框阴影，窗口透明或半透明，将自动赋值为 2
    window_transparent_shadow,
    // 透明窗口，不带透明通道，指定半透明度，指定透明色，将自动赋值为 3
    window_transparent_simple,
    // WIN7 玻璃窗口，需要 WIN7 开启特效，当前未启用，将自动赋值为 4
    window_transparent_win7);

type
  // 定义一个枚举类型 window_style_，表示炫彩窗口样式
  window_style_ = Integer;

const
    // 什么也没有，值为 $0000
  window_style_nothing = $0000;
    // 标题栏，值为 $0001
  window_style_caption = $0001;
    // 边框，值为 $0002，如果没有指定，那么边框大小为 0
  window_style_border = $0002;
    // 窗口居中，值为 $0004
  window_style_center = $0004;
    // 拖动窗口边框，值为 $0008
  window_style_drag_border = $0008;
    // 拖动窗口，值为 $0010
  window_style_drag_window = $0010;
    // 允许窗口最大化，值为 $0020
  window_style_allow_maxWindow = $0020;
    // 图标，值为 $0040
  window_style_icon = $0040;
    // 标题，值为 $0080
  window_style_title = $0080;
    // 控制按钮-最小化，值为 $0100
  window_style_btn_min = $0100;
    // 控制按钮-最大化，值为 $0200
  window_style_btn_max = $0200;
    // 控制按钮-关闭，值为 $0400
  window_style_btn_close = $0400;
    // 默认窗口样式，是多个样式的组合，值为相应样式的按位或
  window_style_default = (window_style_caption or window_style_border or window_style_center or window_style_drag_border or window_style_allow_maxWindow or window_style_icon or window_style_title or window_style_btn_min or window_style_btn_max or window_style_btn_close);
    // 简单窗口样式，是多个样式的组合，值为相应样式的按位或
  window_style_simple = (window_style_caption or window_style_border or window_style_center or window_style_drag_border or window_style_allow_maxWindow);
    // 弹出窗口样式，是多个样式的组合，值为相应样式的按位或
  window_style_pop = (window_style_caption or window_style_border or window_style_center or window_style_drag_border or window_style_allow_maxWindow or window_style_icon or window_style_title or window_style_btn_close);
    // 模态窗口样式，是多个样式的组合，值为相应样式的按位或
  window_style_modal = (window_style_caption or window_style_border or window_style_center or window_style_icon or window_style_title or window_style_btn_close);
    // 模态简单窗口样式，是多个样式的组合，值为相应样式的按位或
  window_style_modal_simple = (window_style_caption or window_style_border or window_style_center);

type
  XC_OBJECT_STYLE = (xc_style_default = 0,
    // @别名  按钮样式_默认
    button_style_default = xc_style_default,  // <默认风格
    // @别名  按钮样式_单选
    button_style_radio,                  // <单选按钮
    // @别名  按钮样式_多选
    button_style_check,                 // <多选按钮
    // @别名  按钮样式_图标
    button_style_icon,                  // <图标按钮
    // @别名  按钮样式_展开
    button_style_expand,                // <展开按钮
    // @别名  按钮样式_关闭
    button_style_close,                // <关闭按钮
    // @别名  按钮样式_最大化
    button_style_max,                  // <最大化按钮
    // @别名  按钮样式_最小化
    button_style_min,                  // <最小化按钮
    // @别名  水平滚动条-左按钮
    button_style_scrollbar_left,         // <水平滚动条-左按钮
    // @别名  水平滚动条-右按钮
    button_style_scrollbar_right,        // <水平滚动条-右按钮
    // @别名  垂直滚动条-上按钮
    button_style_scrollbar_up,           // <垂直滚动条-上按钮
    // @别名  垂直滚动条-下按钮
    button_style_scrollbar_down,         // <垂直滚动条-下按钮
    // @别名  水平滚动条-滑块
    button_style_scrollbar_slider_h,     // <水平滚动条-滑块
    // @别名  垂直滚动条-滑块
    button_style_scrollbar_slider_v,     // <垂直滚动条-滑块
    // @别名  Tab条-按钮
    button_style_tabBar,               // <Tab条-按钮
    // @别名  滑动条-滑块
    button_style_slider,               // <滑动条-滑块
    // @别名  工具条-按钮
    button_style_toolBar,              // <工具条-按钮
    // @别名  工具条-左滚动按钮
    button_style_toolBar_left,          // <工具条-左滚动按钮
    // @别名  工具条-右滚动按钮
    button_style_toolBar_right,         // <工具条-右滚动按钮
    // @别名  窗格-关闭按钮
    button_style_pane_close,           // <窗格-关闭按钮
    // @别名  窗格-锁定按钮
    button_style_pane_lock,            // <窗格-锁定按钮
    // @别名  窗格-菜单按钮
    button_style_pane_menu,            // <窗格-菜单按钮
    // @别名  窗格-码头按钮左
    button_style_pane_dock_left,        // <窗格-码头按钮左
    // @别名  窗格-码头按钮上
    button_style_pane_dock_top,         // <窗格-码头按钮上
    // @别名  窗格-码头按钮右
    button_style_pane_dock_right,       // <窗格-码头按钮右
    // @别名  窗格-码头按钮下
    button_style_pane_dock_bottom,      // <窗格-码头按钮下
    // @别名  框架窗口-停靠码头左
    element_style_frameWnd_dock_left,   // <框架窗口-停靠码头左
    // @别名  框架窗口-停靠码头上
    element_style_frameWnd_dock_top,    // <框架窗口-停靠码头上
    // @别名  框架窗口-停靠码头右
    element_style_frameWnd_dock_right,  // <框架窗口-停靠码头右
    // @别名  框架窗口-停靠码头下
    element_style_frameWnd_dock_bottom, // <框架窗口-停靠码头下
    // @别名  工具条-分割线
    element_style_toolBar_separator,    // <工具条-分割线
    // @别名  组合框-下拉列表框 ,下拉组合框弹出的ListBox
    listBox_style_comboBox           // <组合框-下拉列表框 ,下拉组合框弹出的ListBox
  );

type
  // 定义一个枚举类型 element_state_flag_，表示元素状态
  element_state_flag_ = Integer;

const
    // 无状态，其值与 window_state_flag_nothing 相同
  element_state_flag_nothing = $0000;
    // 启用状态，值为 1
  element_state_flag_enable = $0001;
    // 禁用状态，值为 2
  element_state_flag_disable = $0002;
    // 焦点状态，值为 4
  element_state_flag_focus = $0004;
    // 无焦点状态，值为 8
  element_state_flag_focus_no = $0008;
  element_state_flag_focusEx = $40000000;
    // 无焦点扩展状态，值为 $80000000
//    element_state_flag_focusEx_no = $80000000;
    // 布局内容区状态，其值与 window_state_flag_layout_body 相同
  layout_state_flag_layout_body = $20000000;
    // 鼠标离开状态，值为 16
  element_state_flag_leave = $0010;
  element_state_flag_stay = $0020;
    // 鼠标按下状态，值为 64
  element_state_flag_down = $0040;

type
  // 定义一个枚举类型 common_state3_，表示普通三种状态
  common_state3_ = Integer;

const
    // 离开状态，值为 0
  common_state3_leave = 0;
    // 停留状态，默认值为 1
  common_state3_stay = 1;
    // 按下状态，默认值为 2
  common_state3_down = 2;

type
  button_state_ = integer;

const
  button_state_leave = 0;    // 鼠标离开状态
  button_state_stay = 1;     // 鼠标悬停状态
  button_state_down = 2;     // 鼠标按下状态
  button_state_check = 3;    // 选中状态（如单选/多选按钮）
  button_state_disable = 4;  // 禁用状态

type
  // 定义一个枚举类型 button_icon_align_，表示按钮图标对齐方式
  button_icon_align_ = (
    // 图标在左边，值为 0
    button_icon_align_left = 0,
    // 图标在顶部，默认值为 1
    button_icon_align_top,
    // 图标在右边，默认值为 2
    button_icon_align_right,
    // 图标在底部，默认值为 3
    button_icon_align_bottom);

type
  // 定义一个枚举类型 comboBox_state_flag_，表示组合框的状态标识
  comboBox_state_flag_ = (
    // 鼠标离开状态，其值与 element_state_flag_leave 相同
    comboBox_state_flag_leave = $0010,
    // 鼠标停留状态，其值与 element_state_flag_stay 相同
    comboBox_state_flag_stay = $0020,
    // 鼠标按下状态，其值与 element_state_flag_down 相同
    comboBox_state_flag_down = $0040);

type
  // 定义一个枚举类型 comboBox_state_，用于表示组合框的状态
  comboBox_state_ = (
    // 鼠标离开状态，值为 0
    comboBox_state_leave = 0,
    // 鼠标停留状态，值为 1
    comboBox_state_stay = 1,
    // 按下状态，值为 2
    comboBox_state_down = 2);

type
  // 定义一个枚举类型 adapter_date_type_，用于表示数据适配器的数据类型
  adapter_date_type_ = (
    // 错误类型，值为 -1
    adapter_date_type_error = -1,
    // 整型，值为 0
    adapter_date_type_int = 0,
    // 浮点型，值为 1
    adapter_date_type_float = 1,
    // 字符串型，值为 2
    adapter_date_type_string = 2,
    // 图片类型，值为 3
    adapter_date_type_image = 3);

type
  // 定义一个枚举类型 ease_type_，表示缓动类型
  ease_type_ = (
    // 从慢到快
    easeIn,
    // 从快到慢
    easeOut,
    // 从慢到快再到慢
    easeInOut);

type
  // 定义一个枚举类型 ease_flag_，表示缓动标识
  ease_flag_ = Integer;

const
  ease_flag_linear = 0;
  ease_flag_quad = 1;
  ease_flag_cubic = 2;
  ease_flag_quart = 3;
  ease_flag_quint = 4;
  ease_flag_sine = 5;
  ease_flag_expo = 6;
  ease_flag_circ = 7;
  ease_flag_elastic = 8;
  ease_flag_back = 9;
  ease_flag_bounce = 10;
  ease_flag_in = $010000;
  ease_flag_out = $020000;
  ease_flag_inOut = $030000;

type
  // 定义一个枚举类型 edit_type_，表示编辑框类型
  edit_type_ = (
    // 普通编辑框，值为 0，每行高度相同
    edit_type_none = 0,
    // 代码编辑框，每行高度相同，功能继承普通编辑框
    edit_type_editor,
    // 富文本编辑框，每行高度可能不同
    edit_type_richedit,
    // 聊天气泡，每行高度可能不同，功能继承富文本编辑框
    edit_type_chat,
    // 代码表格，内部使用，每行高度相同，未使用
    edit_type_codeTable);

type
  // 定义一个枚举类型 edit_style_type_，表示编辑框样式类型
  Tedit_style_type_ = (
    // 字体，值为 1
    edit_style_type_font_color = 1,
    // 图片
    edit_style_type_image,
    // UI 对象
    edit_style_type_obj);

type
  // 定义一个记录类型 edit_data_copy_style_
  Tedit_data_copy_style_ = record
    // 句柄（字体、图片、UI 对象），使用 Cardinal 类型，当 64 位时可节省 4 字节内存
    hFont_image_obj: Cardinal;
    // 颜色，使用 TColor 类型
    color: Integer;
    // 是否使用颜色，使用 Boolean 类型
    bColor: Boolean;
  end;

type
  // 定义一个记录类型 edit_data_copy_
  Tedit_data_copy_ = record
    // 内容数量，使用 Integer 类型
    nCount: Integer;
    // 样式数量，使用 Integer 类型
    nStyleCount: Integer;
    // 样式数组，使用指针类型，指向 edit_data_copy_style_ 记录类型
    pStyle: ^Tedit_data_copy_style_;
    // 数据，使用指针类型，指向 Cardinal 类型
    pData: ^Cardinal;
  end;

  Pedit_data_copy_ = ^Tedit_data_copy_;

type
  // 定义一个记录类型 edit_style_info_
  Tedit_style_info_ = record
    // 样式类型，使用 Word 类型
    type_: Word;
    // 引用计数，使用 Word 类型
    nRef: Word;
    // 句柄（字体、图片、UI 对象），使用 THandle 类型
    hFont_image_obj: THandle;
    // 颜色，使用 TColor 类型
    color: Integer;
    // 是否使用颜色，使用 Boolean 类型
    bColor: Boolean;
  end;

type
  // 定义一个记录类型 position_，用于存储位置信息
  Tposition_ = record
    // 行索引，使用 Integer 类型
    iRow: Integer;
    // 列索引，使用 Integer 类型
    iColumn: Integer;
  end;

type
  // 定义一个枚举类型 zorder_，表示 Z 序位置
  zorder_ = (
    // 最上面
    zorder_top,
    // 最下面
    zorder_bottom,
    // 指定目标下面
    zorder_before,
    // 指定目标上面
    zorder_after);

type
  // 定义一个枚举类型 fontStyle_，表示字体样式
  fontStyle_ = (
    // 正常，值为 0
    fontStyle_regular = 0,
    // 粗体，值为 1
    fontStyle_bold = 1,
    // 斜体，值为 2
    fontStyle_italic = 2,
    // 粗斜体，值为 3
    fontStyle_boldItalic = 3,
    // 下划线，值为 4
    fontStyle_underline = 4,
    // 删除线，值为 8
    fontStyle_strikeout = 8);

type
  // 定义一个记录类型 font_info_，用于存储字体信息
  font_info_ = record
    // 字体大小，使用 Integer 类型，单位为 pt（磅）
    nSize: Integer;
    // 字体样式，使用 Integer 类型，可能需要与之前的 fontStyle_ 枚举关联
    nStyle: Integer;
    // 字体名称，使用宽字符数组，长度为 LF_FACESIZE
    name: array[0..LF_FACESIZE - 1] of WideChar;
  end;

type
  // 定义一个枚举类型 pane_align_，表示窗格对齐方式
  pane_align_ = (
    // 错误，值为 -1
    pane_align_error = -1,
    // 左侧，值为 0
    pane_align_left = 0,
    // 顶部，由于未指定值，将自动赋值为 1
    pane_align_top,
    // 右侧，将自动赋值为 2
    pane_align_right,
    // 底部，将自动赋值为 3
    pane_align_bottom,
    // 居中，将自动赋值为 4
    pane_align_center);

type
  // 定义一个枚举类型 image_draw_type_，表示图片绘制类型
  image_draw_type_ = (
    // 默认，值为 0
    image_draw_type_default = 0,
    // 拉伸，由于未指定值，将自动赋值为 1
    image_draw_type_stretch,
    // 自适应（九宫格），将自动赋值为 2
    image_draw_type_adaptive,
    // 平铺，将自动赋值为 3
    image_draw_type_tile,
    // 固定比例，将自动赋值为 4
    image_draw_type_fixed_ratio,
    // 九宫格外围，将自动赋值为 5
    image_draw_type_adaptive_border);

type
  // 布局对齐
  layout_align_ = (
    // 左侧，值为 0
    layout_align_left = 0,
    // 顶部，将自动赋值为 1
    layout_align_top,
    // 右侧，将自动赋值为 2
    layout_align_right,
    // 底部，将自动赋值为 3
    layout_align_bottom,
    // 居中，将自动赋值为 4
    layout_align_center,
    // 等距，将自动赋值为 5
    layout_align_equidistant);

type
  // 布局大小类型
  layout_size_ = Integer;

const
  layout_size_fixed = 0;
  layout_size_fill = 1;
  layout_size_auto = 2;
  layout_size_weight = 3;
  layout_size_percent = 4;
  layout_size_disable = 5;

type
  // 布局轴对齐
  layout_align_axis_ = (
    // 无，值为 0
    layout_align_axis_auto = 0,
    // 开始，将自动赋值为 1
    layout_align_axis_start,
    // 居中，将自动赋值为 2
    layout_align_axis_center,
    // 末尾，将自动赋值为 3
    layout_align_axis_end);

type// 编辑框文本对齐
  edit_textAlign_flag_ = Integer;

const
    // 左侧，值为 $0
  edit_textAlign_flag_left = $0;
    // 右侧，值为 $1
  edit_textAlign_flag_right = $1;
    // 水平居中，值为 $2
  edit_textAlign_flag_center = $2;
    // 顶部，值为 $0
  edit_textAlign_flag_top = $0;
    // 底部，值为 $4
  edit_textAlign_flag_bottom = $4;
    // 垂直居中，值为 $8
  edit_textAlign_flag_center_v = $8;

type
  // 窗格状态
  pane_state_ = (
    // 错误，值为 -1
    pane_state_error = -1,
    // 任意，值为 0
    pane_state_any = 0,
    // 锁定，将自动赋值为 1
    pane_state_lock,
    // 停靠码头，将自动赋值为 2
    pane_state_dock,
    // 浮动窗格，将自动赋值为 3
    pane_state_float);

  // 文本对齐
  textFormatFlag_ = Integer;

const
  // 左对齐，值为 0
  textAlignFlag_left = 0;
  // 顶对齐，值为 0
  textAlignFlag_top = 0;
  // 内部保留，值为 $4000
  textAlignFlag_left_top = $4000;
  // 水平居中，值为 $1
  textAlignFlag_center = $1;
  // 右对齐，值为 $2
  textAlignFlag_right = $2;
  // 垂直居中，值为 $4
  textAlignFlag_vcenter = $4;
  // 底对齐，值为 $8
  textAlignFlag_bottom = $8;
  // 从右向左顺序显示文本，值为 $10
  textFormatFlag_DirectionRightToLeft = $10;
  // 禁止换行，值为 $20
  textFormatFlag_NoWrap = $20;
  // 垂直显示文本，值为 $40
  textFormatFlag_DirectionVertical = $40;
  // 允许部分字符延伸该字符串的布局矩形，值为 $80
  textFormatFlag_NoFitBlackBox = $80;
  // 控制字符（如从左到右标记）随具有代表性的标志符号一起显示在输出中，值为 $100
  textFormatFlag_DisplayFormatControl = $100;
  // 对于请求的字体中不支持的字符，禁用回退到可选字体，值为 $200
  textFormatFlag_NoFontFallback = $200;
  // 包括每一行结尾处的尾随空格，值为 $400
  textFormatFlag_MeasureTrailingSpaces = $400;
  // 如果内容显示高度不够一行，那么不显示，值为 $800
  textFormatFlag_LineLimit = $800;
  // 允许显示标志符号的伸出部分和延伸到边框外的未换行文本，值为 $1000
  textFormatFlag_NoClip = $1000;
  // 以字符为单位去尾，值为 $40000
  textTrimming_Character = $40000;
  // 以单词为单位去尾，值为 $80000
  textTrimming_Word = $80000;
  // 以字符为单位去尾，省略部分使用省略号表示，值为 $8000
  textTrimming_EllipsisCharacter = $8000;
  // 以单词为单位去尾，省略部分使用省略号表示，值为 $10000
  textTrimming_EllipsisWord = $10000;
  // 略去字符串中间部分，保证字符的首尾都能够显示，值为 $20000
  textTrimming_EllipsisPath = $20000;

type

  // D2D 文本渲染模式
  XC_DWRITE_RENDERING_MODE = (
    // 指定根据字体和大小自动确定呈现模式，值为 0
    XC_DWRITE_RENDERING_MODE_DEFAULT = 0,
    // 指定不执行抗锯齿，值为 1
    XC_DWRITE_RENDERING_MODE_ALIASED,
    // 使用与别名文本相同的度量指定 ClearType 呈现，值为 2
    XC_DWRITE_RENDERING_MODE_CLEARTYPE_GDI_CLASSIC,
    // 使用使用 CLEARTYPE_NATURAL_QUALITY 创建的字体，使用与使用 GDI 的文本呈现相同的指标指定 ClearType 呈现，值为 3
    XC_DWRITE_RENDERING_MODE_CLEARTYPE_GDI_NATURAL,
    // 仅在水平维度中指定具有抗锯齿功能的 ClearType 渲染，值为 4
    XC_DWRITE_RENDERING_MODE_CLEARTYPE_NATURAL,
    // 指定渲染应绕过光栅化器并直接使用轮廓，值为 6
    XC_DWRITE_RENDERING_MODE_OUTLINE);

type
  // 定义一个枚举类型 list_item_state_，表示列表项的状态

  list_item_state_ = Integer;

const
    // 项鼠标离开状态，值为 0
  list_item_state_leave = 0;
    // 项鼠标停留状态，值为 1
  list_item_state_stay = 1;
    // 项选择状态，值为 2
  list_item_state_select = 2;
    // 缓存的项，值为 3
  list_item_state_cache = 3;

type
  // 列表项模板类型
  listItemTemp_type_ = Integer;

const
    // 列表树，值为 $01
  listItemTemp_type_tree = $01;
    // 列表框，值为 $02
  listItemTemp_type_listBox = $02;
    // 列表头，值为 $04
  listItemTemp_type_list_head = $04;
    // 列表项，值为 $08
  listItemTemp_type_list_item = $08;
    // 列表视图组，值为 $10
  listItemTemp_type_listView_group = $10;
    // 列表视图项，值为 $20
  listItemTemp_type_listView_item = $20;
    // list (列表头)与(列表项)组合，值为 $0C
  listItemTemp_type_list = $0C;
    // listView (列表视组)与(列表视项)组合，值为 $30
  listItemTemp_type_listView = $30;

type
  // 定义一个枚举类型 tree_item_state_，表示列表树项的状态
  Ttree_item_state_ = (
    // 项鼠标离开状态，值为 0
    tree_item_state_leave = 0,
    // 项鼠标停留状态，值为 1
    tree_item_state_stay = 1,
    // 项选择状态，值为 2
    tree_item_state_select = 2);

  // 定义一个记录类型 listBox_item_info_，用于存储列表框项的信息
  TlistBox_item_info_ = record
    // 用户绑定数据，使用 vint 类型，可能需要根据实际情况确定 vint 的定义
    nUserData: vint;
    // 项的高度，使用 Integer 类型，-1 表示使用默认高度
    nHeight: Integer;
    // 项被选中时的高度，使用 Integer 类型，-1 表示使用默认高度
    nSelHeight: Integer;
  end;

type
  TlistBox_item_ = record
    //@别名  项索引
    index: Integer;      //项索引
    //@别名  用户数据
    nUserData: vint;     //用户绑定数据
    //@别名  项默认高度
    nHeight: Integer;    //项默认高度
    //@别名  项选中时高度
    nSelHeight: Integer; //项选中时高度
    //@别名  状态
    nState: list_item_state_;  //状态
    //@别名  项坐标
    rcItem: TRect;       //项坐标
    //@别名  布局元素
    hLayout: HELE;       //布局元素
    //@别名  项模板
    hTemp: HTEMP;        //列表项模板
  end;

type
  // 定义一个结构体 listView_item_id_，用于存储列表视图项的 ID 信息
  TlistView_item_id_ = record
    // 组索引，使用 Integer 类型
    iGroup: Integer;
    // 项索引，使用 Integer 类型
    iItem: Integer;
  end;

  // 定义一个结构体 list_item_，用于存储列表项的信息
  Tlist_item_ = record
    // 项索引（行索引），使用 Integer 类型
    index: Integer;
    // 子项索引（列索引），使用 Integer 类型
    iSubItem: Integer;
    // 用户数据，使用 vint 类型，可能需要根据实际情况确定 vint 的定义
    nUserData: vint;
    // 状态，使用 list_item_state_ 类型，需要确保该类型已经在代码中定义
    nState: list_item_state_;
    // 项的坐标，使用 TRect 类型，需要确保 TRect 类型已经在代码中定义
    rcItem: TRect;
    // 布局元素，使用 HELE 类型，需要确保该类型已经在代码中定义
    hLayout: HELE;
    // 列表项模板，使用 HTEMP 类型，需要确保该类型已经在代码中定义
    hTemp: HTEMP;
  end;

  // 定义一个结构体 list_header_item_，用于存储列表头项的信息
  Tlist_header_item_ = record
    // 项索引，使用 Integer 类型
    index: Integer;
    // 用户数据，使用 vint 类型，可能需要根据实际情况确定 vint 的定义
    nUserData: vint;
    // 是否支持排序，使用 BOOL 类型
    bSort: BOOL;
    // 排序方式，使用 Integer 类型，0 表示无效，1 表示升序，2 表示降序
    nSortType: Integer;
    // 对应数据适配器中的列索引，使用 Integer 类型
    iColumnAdapter: Integer;
    // 状态，使用 common_state3_ 类型，需要确保该类型已经在代码中定义
    nState: common_state3_;
    // 项的坐标，使用 TRect 类型，需要确保 TRect 类型已经在代码中定义
    rcItem: TRect;
    // 布局元素，使用 HELE 类型，需要确保该类型已经在代码中定义
    hLayout: HELE;
    // 列表项模板，使用 HTEMP 类型，需要确保该类型已经在代码中定义
    hTemp: HTEMP;
  end;

  // 定义一个结构体 tree_item_，用于存储树项的信息
  Ttree_item_ = record
    // 项 ID，使用 Integer 类型
    nID: Integer;
    // 深度，使用 Integer 类型
    nDepth: Integer;
    // 项的高度，使用 Integer 类型
    nHeight: Integer;
    // 项选中时的高度，使用 Integer 类型
    nSelHeight: Integer;
    // 用户数据，使用 vint 类型，可能需要根据实际情况确定 vint 的定义
    nUserData: vint;
    // 是否展开，使用 BOOL 类型
    bExpand: BOOL;
    // 状态，使用 tree_item_state_ 类型，需要确保该类型已经在代码中定义
    nState: Ttree_item_state_;
    // 项的坐标，使用 TRect 类型，需要确保 TRect 类型已经代码中定义
    rcItem: TRect;
    // 布局元素，使用 HELE 类型，需要确保该类型已经在代码中定义
    hLayout: HELE;
    // 列表项模板，使用 HTEMP 类型，需要确保该类型已经在代码中定义
    hTemp: HTEMP;
  end;

  // 定义一个结构体 listView_item_，用于存储列表视图项的信息
  TlistView_item_ = record
    // 项所属组索引，-1 表示没有组，使用 Integer 类型
    iGroup: Integer;
    // 项在组中的位置索引，如果为 -1 则为组，使用 Integer 类型
    iItem: Integer;
    // 用户绑定数据，使用 vint 类型，可能需要根据实际情况确定 vint 的定义
    nUserData: vint;
    // 状态，使用 list_item_state_ 类型，需要确保该类型已经在代码中定义
    nState: list_item_state_;
    // 项的坐标，使用 TRect 类型，需要确保 TRect 类型已经在代码中定义
    rcItem: TRect;
    // 布局元素，使用 HELE 类型，需要确保该类型已经在代码中定义
    hLayout: HELE;
    // 列表项模板，使用 HTEMP 类型，需要确保该类型已经在代码中定义
    hTemp: HTEMP;
  end;

type
  // 定义一个枚举类型 menu_popup_position_，表示弹出菜单的方向
  Tmenu_popup_position_ = Integer;

const
    // 左上角，值为 0
  menu_popup_position_left_top = 0;
    // 左下角，将自动赋值为 1
  menu_popup_position_left_bottom = 1;
    // 右上角，将自动赋值为 2
  menu_popup_position_right_top = 2;
    // 右下角，将自动赋值为 3
  menu_popup_position_right_bottom = 3;
    // 左居中，将自动赋值为 4
  menu_popup_position_center_left = 4;
    // 上居中，将自动赋值为 5
  menu_popup_position_center_top = 5;
    // 右居中，将自动赋值为 6
  menu_popup_position_center_right = 6;
    // 下居中，将自动 赋值为 7
  menu_popup_position_center_bottom = 7;

type
  menu_item_flag_ = Integer;

const
  menu_item_flag_Normal = $00;  // 正常
  menu_item_flag_Select = $01;  // 选择或鼠标停留
  menu_item_flag_Stay = $01;  // 选择或鼠标停留 等于 mifSelect
  menu_item_flag_Check = $02;  // 勾选
  menu_item_flag_Popup = $04;  // 弹出
  menu_item_flag_Separator = $08;  // 分隔栏 ID号任意,ID号被忽略
  menu_item_flag_Disable = $10;  // 禁用

type
  messageBox_flag_ = (
    // @别名  其他
    messageBox_flag_other = $00,  // 其他
    // @别名  确定按钮
    messageBox_flag_ok = $01,    // 确定按钮
    // @别名  取消按钮
    messageBox_flag_cancel = $02, // 取消按钮
    // @别名  图标应用程序
    messageBox_flag_icon_appicon = $01000, // 图标 应用程序  IDI_APPLICATION
    // @别名  图标信息
    messageBox_flag_icon_info = $02000,  // 图标 信息     IDI_ASTERISK
    // @别名  图标问询
    messageBox_flag_icon_question = $04000, // 图标 问询/帮助/提问   IDI_QUESTION
    // @别名  图标错误
    messageBox_flag_icon_error = $08000,  // 图标 错误/拒绝/禁止  IDI_ERROR
    // @别名  图标警告
    messageBox_flag_icon_warning = $10000, // 图标 警告       IDI_WARNING
    // @别名  图标安全
    messageBox_flag_icon_shield = $20000  // 图标 盾牌/安全   IDI_SHIELD
  );

type
  notifyMsg_skin_ = (
    // @别名  默认
    notifyMsg_skin_no,         // 默认
    // @别名  成功
    notifyMsg_skin_success,    // 成功
    // @别名  警告
    notifyMsg_skin_warning,    // 警告
    // @别名  消息
    notifyMsg_skin_message,   // 消息
    // @别名  错误
    notifyMsg_skin_error     // 错误
  );

type
  monthCal_button_type_ = Integer;

const
  monthCal_button_type_today = 0;
  monthCal_button_type_last_year = 1;
  monthCal_button_type_next_year = 2;
  monthCal_button_type_last_month = 3;
  monthCal_button_type_next_month = 4;
  monthCal_state_flag_leave = element_state_flag_leave;
  monthCal_state_flag_item_leave = $0080;
  monthCal_state_flag_item_stay = $0100;
  monthCal_state_flag_item_down = $0200;
  monthCal_state_flag_item_select = $0400;
  monthCal_state_flag_item_select_no = $0800;
  monthCal_state_flag_item_today = $1000;
  monthCal_state_flag_item_last_month = $2000;
  monthCal_state_flag_item_cur_month = $4000;
  monthCal_state_flag_item_next_month = $8000;

function XC_UnicodeToAnsi(pIn: PWideChar; inLen: Integer; pOut: PAnsiChar; outLen: Integer): Integer; stdcall; external XCGUI_DLL;

function XC_AnsiToUnicode(pIn: PAnsiChar; inLen: Integer; pOut: PWideChar; outLen: Integer): Integer; stdcall; external XCGUI_DLL;

function XC_SendMessage(hWindow: Integer; msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall; external XCGUI_DLL;

function XC_PostMessage(hWindow: Integer; msg: UINT; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall; external XCGUI_DLL;

function XC_CallUiThread(pCall: Integer; data: vint): vint; stdcall; external XCGUI_DLL;

procedure XC_DebugToFileInfo(pInfo: PAnsiChar); stdcall; external XCGUI_DLL;

function XC_IsHELE(hEle: HXCGUI): BOOL; stdcall; external XCGUI_DLL;

function XC_IsHWINDOW(hWindow: HXCGUI): BOOL; stdcall; external XCGUI_DLL;

function XC_IsShape(hShape: HXCGUI): BOOL; stdcall; external XCGUI_DLL;

function XC_IsHXCGUI(hXCGUI: HXCGUI; nType: XC_OBJECT_TYPE): BOOL; stdcall; external XCGUI_DLL;

function XC_hWindowFromHWnd(hWnd: Integer): HWINDOW; stdcall; external XCGUI_DLL;

function XC_SetActivateTopWindow(): BOOL; stdcall; external XCGUI_DLL;

function XC_SetProperty(hXCGUI: HXCGUI; pName: PWideChar; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XC_GetProperty(hXCGUI: HXCGUI; pName: PWideChar): PWideChar; stdcall; external XCGUI_DLL;

function XC_RegisterWindowClassName(pClassName: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XC_IsSViewExtend(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XC_GetObjectType(hXCGUI: HXCGUI): XC_OBJECT_TYPE; stdcall; external XCGUI_DLL;

function XC_GetObjectByID(hWindow: HWINDOW; nID: Integer): HXCGUI; stdcall; external XCGUI_DLL;

function XC_GetObjectByIDName(hWindow: HWINDOW; pName: PWideChar): HXCGUI; stdcall; external XCGUI_DLL;

function XC_GetObjectByUID(nUID: Integer): HXCGUI; stdcall; external XCGUI_DLL;

function XC_GetObjectByUIDName(pName: PWideChar): HXCGUI; stdcall; external XCGUI_DLL;

function XC_GetObjectByName(pName: PWideChar): HXCGUI; stdcall; external XCGUI_DLL;

procedure XC_SetPaintFrequency(nMilliseconds: Integer); stdcall; external XCGUI_DLL;

procedure XC_SetTextRenderingHint(nType: Integer); stdcall; external XCGUI_DLL;

procedure XC_EnableGdiDrawText(bEnable: BOOL); stdcall; external XCGUI_DLL;

function XC_RectInRect(var Rect1: TRect; var Rect2: TRect): BOOL; stdcall; external XCGUI_DLL;

procedure XC_CombineRect(var pDest: TRect; var pSrc1: TRect; var pSrc2: TRect); stdcall; external XCGUI_DLL;

procedure XC_ShowLayoutFrame(bShow: BOOL); stdcall; external XCGUI_DLL;

procedure XC_EnableDebugFile(bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XC_EnableResMonitor(bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XC_SetLayoutFrameColor(color: Integer); stdcall; external XCGUI_DLL;

procedure XC_EnableErrorMessageBox(bEnabel: BOOL); stdcall; external XCGUI_DLL;

procedure XC_EnableAutoExitApp(bEnabel: BOOL); stdcall; external XCGUI_DLL;

function XC_LoadResource(pFileName: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XC_LoadResourceZip(pZipFileName: PWideChar; pFileName: PWideChar; pPassword: PWideChar = nil): BOOL; stdcall; external XCGUI_DLL;

function XC_LoadResourceZipMem(data: Integer; length: Integer; pFileName: PWideChar; pPassword: PWideChar = nil): BOOL; stdcall; external XCGUI_DLL;

function XC_LoadResourceFromString(pStringXML: PAnsiChar; pFileName: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XC_LoadResourceFromStringUtf8(pStringXML: PAnsiChar; pFileName: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XC_LoadStyle(pFileName: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XC_LoadStyleZip(pZipFile: PWideChar; pFileName: PWideChar; pPassword: PWideChar = nil): BOOL; stdcall; external XCGUI_DLL;

function XC_LoadStyleZipMem(data: Integer; length: Integer; pFileName: PWideChar; pPassword: PWideChar = nil): BOOL; stdcall; external XCGUI_DLL;

procedure XC_GetTextSize(pString: PWideChar; length: Integer; hFontX: HFONTX; out pOutSize: TSize); stdcall; external XCGUI_DLL;

procedure XC_GetTextShowSize(pString: PWideChar; length: Integer; hFontX: HFONTX; out pOutSize: TSize); stdcall; external XCGUI_DLL;

procedure XC_GetTextShowSizeEx(pString: PWideChar; length: Integer; hFontX: HFONTX; nTextAlign: Integer; out pOutSize: TSize); stdcall; external XCGUI_DLL;

procedure XC_GetTextShowRect(pString: PWideChar; length: Integer; hFontX: HFONTX; nTextAlign: Integer; width: Integer; out pOutSize: TSize); stdcall; external XCGUI_DLL;

function XC_GetDefaultFont(): HFONTX; stdcall; external XCGUI_DLL;

procedure XC_SetDefaultFont(hFontX: HFONTX); stdcall; external XCGUI_DLL;

procedure XC_AddFileSearchPath(pPath: PWideChar); stdcall; external XCGUI_DLL;

procedure XC_InitFont(pFont: PLOGFONTW; pName: PWideChar; size: Integer; bBold: BOOL = False; bItalic: BOOL = False; bUnderline: BOOL = False; bStrikeOut: BOOL = False); stdcall; external XCGUI_DLL;

function XC_Malloc(size: Integer): Pointer; stdcall; external XCGUI_DLL;

procedure XC_Free(p: Pointer); stdcall; external XCGUI_DLL;

procedure _XC_SetType(hXCGUI: HXCGUI; nType: XC_OBJECT_TYPE); stdcall; external XCGUI_DLL;

procedure _XC_AddType(hXCGUI: HXCGUI; nType: XC_OBJECT_TYPE); stdcall; external XCGUI_DLL;

procedure _XC_BindData(hXCGUI: HXCGUI; data: vint); stdcall; external XCGUI_DLL;

function _XC_GetBindData(hXCGUI: HXCGUI): vint; stdcall; external XCGUI_DLL;

procedure XC_Alert(pTitle: PWideChar; pText: PWideChar); stdcall; external XCGUI_DLL;

function XC_Sys_ShellExecute(hwnd: Integer; lpOperation: PWideChar; lpFile: PWideChar; lpParameters: PWideChar; lpDirectory: PWideChar; nShowCmd: Integer): Integer; stdcall; external XCGUI_DLL;

function XC_LoadLibrary(lpFileName: PWideChar): HMODULE; stdcall; external XCGUI_DLL;

function XC_GetProcAddress(hModule: Integer; lpProcName: PAnsiChar): FARPROC; stdcall; external XCGUI_DLL;

function XC_FreeLibrary(hModule: Integer): BOOL; stdcall; external XCGUI_DLL;

function XC_LoadDll(pDllFileName: PWideChar): HMODULE; stdcall; external XCGUI_DLL;

function XInitXCGUI(bD2D: BOOL): BOOL; stdcall; external XCGUI_DLL;

procedure XRunXCGUI(); stdcall; external XCGUI_DLL;

procedure XExitXCGUI(); stdcall; external XCGUI_DLL;

procedure XC_PostQuitMessage(nExitCode: Integer); stdcall; external XCGUI_DLL;

function XObj_GetType(hXCGUI: HXCGUI): XC_OBJECT_TYPE; stdcall; external XCGUI_DLL;

function XObj_GetTypeBase(hXCGUI: HXCGUI): XC_OBJECT_TYPE; stdcall; external XCGUI_DLL;

function XObj_GetTypeEx(hXCGUI: HXCGUI): XC_OBJECT_TYPE_EX; stdcall; external XCGUI_DLL;

procedure XUI_SetStyle(hXCGUI: HXCGUI; nStyle: XC_OBJECT_STYLE); stdcall; external XCGUI_DLL;

function XUI_GetStyle(hXCGUI: HXCGUI): XC_OBJECT_STYLE; stdcall; external XCGUI_DLL;

procedure XUI_EnableCSS(hXCGUI: HXCGUI; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XUI_SetCssName(hXCGUI: HXCGUI; pName: PWideChar); stdcall; external XCGUI_DLL;

function XUI_GetCssName(hXCGUI: HXCGUI): PWideChar; stdcall; external XCGUI_DLL;

function XWidget_IsShow(hXCGUI: HXCGUI): BOOL; stdcall; external XCGUI_DLL;

procedure XWidget_Show(hXCGUI: HXCGUI; bShow: BOOL); stdcall; external XCGUI_DLL;

procedure XWidget_EnableLayoutControl(hXCGUI: HXCGUI; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XWidget_IsLayoutControl(hXCGUI: HXCGUI): BOOL; stdcall; external XCGUI_DLL;

function XWidget_GetParentEle(hXCGUI: HXCGUI): HELE; stdcall; external XCGUI_DLL;

function XWidget_GetParent(hXCGUI: HXCGUI): HXCGUI; stdcall; external XCGUI_DLL;

function XWidget_GetHWND(hXCGUI: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XWidget_GetHWINDOW(hXCGUI: HXCGUI): HWINDOW; stdcall; external XCGUI_DLL;

procedure _XC_RegJsBind(pName: PAnsiChar; func: Integer); stdcall; external XCGUI_DLL;

procedure XC_RegFunExit(func: Pointer); stdcall; external XCGUI_DLL;

function XBkM_Create(): HBKM; stdcall; external XCGUI_DLL;

procedure XBkM_Destroy(hBkInfoM: HBKM); stdcall; external XCGUI_DLL;

function XBkM_SetBkInfo(hBkInfoM: HBKM; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XBkM_AddInfo(hBkInfoM: HBKM; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

procedure XBkM_AddBorder(hBkInfoM: HBKM; nState: Integer; color: Integer; width: Integer; id: Integer = 0); stdcall; external XCGUI_DLL;

procedure XBkM_AddFill(hBkInfoM: HBKM; nState: Integer; color: Integer; id: Integer = 0); stdcall; external XCGUI_DLL;

procedure XBkM_AddImage(hBkInfoM: HBKM; nState: Integer; hImage: HIMAGE; id: Integer = 0); stdcall; external XCGUI_DLL;

function XBkM_GetCount(hBkInfoM: HBKM): Integer; stdcall; external XCGUI_DLL;

procedure XBkM_Clear(hBkInfoM: HBKM); stdcall; external XCGUI_DLL;

function XBkM_Draw(hBkInfoM: HBKM; nState: Integer; hDraw: HDRAW; var Rect: TRect): BOOL; stdcall; external XCGUI_DLL;

function XBkM_DrawEx(hBkInfoM: HBKM; nState: Integer; hDraw: HDRAW; var Rect: TRect; nStateEx: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XBkM_EnableAutoDestroy(hBkInfoM: HBKM; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XBkM_AddRef(hBkInfoM: HBKM); stdcall; external XCGUI_DLL;

procedure XBkM_Release(hBkInfoM: HBKM); stdcall; external XCGUI_DLL;

function XBkM_GetRefCount(hBkInfoM: HBKM): Integer; stdcall; external XCGUI_DLL;

function XBtn_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; pName: PWideChar; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

function XBtn_IsCheck(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XBtn_SetCheck(hEle: HELE; bCheck: BOOL): BOOL; stdcall; external XCGUI_DLL;

procedure XBtn_SetState(hEle: HELE; nState: common_state3_); stdcall; external XCGUI_DLL;

function XBtn_GetState(hEle: HELE): common_state3_; stdcall; external XCGUI_DLL;

function XBtn_GetStateEx(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XBtn_SetTypeEx(hEle: HELE; nType: XC_OBJECT_TYPE_EX); stdcall; external XCGUI_DLL;

procedure XBtn_SetGroupID(hEle: HELE; nID: Integer); stdcall; external XCGUI_DLL;

function XBtn_GetGroupID(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XBtn_SetBindEle(hEle: HELE; hBindEle: HELE); stdcall; external XCGUI_DLL;

function XBtn_GetBindEle(hEle: HELE): HELE; stdcall; external XCGUI_DLL;

procedure XBtn_SetTextAlign(hEle: HELE; nFlags: Integer); stdcall; external XCGUI_DLL;

function XBtn_GetTextAlign(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XBtn_SetIconAlign(hEle: HELE; align: button_icon_align_); stdcall; external XCGUI_DLL;

procedure XBtn_SetOffset(hEle: HELE; x: Integer; y: Integer); stdcall; external XCGUI_DLL;

procedure XBtn_SetOffsetIcon(hEle: HELE; x: Integer; y: Integer); stdcall; external XCGUI_DLL;

procedure XBtn_SetIconSpace(hEle: HELE; size: Integer); stdcall; external XCGUI_DLL;

procedure XBtn_SetText(hEle: HELE; pName: PWideChar); stdcall; external XCGUI_DLL;

function XBtn_GetText(hEle: HELE): PWideChar; stdcall; external XCGUI_DLL;

procedure XBtn_SetIcon(hEle: HELE; hImage: HIMAGE); stdcall; external XCGUI_DLL;

procedure XBtn_SetIconDisable(hEle: HELE; hImage: HIMAGE); stdcall; external XCGUI_DLL;

function XBtn_GetIcon(hEle: HELE; nType: Integer): HIMAGE; stdcall; external XCGUI_DLL;

procedure XBtn_AddAnimationFrame(hEle: HELE; hImage: HIMAGE; uElapse: UINT); stdcall; external XCGUI_DLL;

procedure XBtn_EnableAnimation(hEle: HELE; bEnable: BOOL; bLoopPlay: BOOL = FALSE); stdcall; external XCGUI_DLL;

function XComboBox_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

function XComboBox_SetSelItem(hEle: HELE; iIndex: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XComboBox_GetButtonRect(hEle: HELE; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XComboBox_SetButtonSize(hEle: HELE; size: Integer); stdcall; external XCGUI_DLL;

procedure XComboBox_SetDropHeight(hEle: HELE; height: Integer); stdcall; external XCGUI_DLL;

function XComboBox_GetDropHeight(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XComboBox_CreateAdapter(hEle: HELE): HXCGUI; stdcall; external XCGUI_DLL;

procedure XComboBox_BindAdapter(hEle: HELE; hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

function XComboBox_GetAdapter(hEle: HELE): HXCGUI; stdcall; external XCGUI_DLL;

procedure XComboBox_SetBindName(hEle: HELE; pName: PWideChar); stdcall; external XCGUI_DLL;

procedure XComboBox_SetItemTemplateXML(hEle: HELE; pXmlFile: PWideChar); stdcall; external XCGUI_DLL;

procedure XComboBox_SetItemTemplateXMLFromString(hEle: HELE; pStringXML: PAnsiChar); stdcall; external XCGUI_DLL;

procedure XComboBox_EnableDrawButton(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XComboBox_EnableEdit(hEle: HELE; bEdit: BOOL); stdcall; external XCGUI_DLL;

procedure XComboBox_EnableDropHeightFixed(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XComboBox_GetSelItem(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XComboBox_GetState(hEle: HELE): comboBox_state_; stdcall; external XCGUI_DLL;

function XComboBox_AddItemText(hEle: HELE; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XComboBox_AddItemTextEx(hEle: HELE; pName: PWideChar; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XComboBox_AddItemImage(hEle: HELE; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XComboBox_AddItemImageEx(hEle: HELE; pName: PWideChar; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XComboBox_InsertItemText(hEle: HELE; iItem: Integer; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XComboBox_InsertItemTextEx(hEle: HELE; iItem: Integer; pName: PWideChar; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XComboBox_InsertItemImage(hEle: HELE; iItem: Integer; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XComboBox_InsertItemImageEx(hEle: HELE; iItem: Integer; pName: PWideChar; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XComboBox_SetItemText(hEle: HELE; iItem: Integer; iColumn: Integer; pText: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_SetItemTextEx(hEle: HELE; iItem: Integer; pName: PWideChar; pText: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_SetItemImage(hEle: HELE; iItem: Integer; iColumn: Integer; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_SetItemImageEx(hEle: HELE; iItem: Integer; pName: PWideChar; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_SetItemInt(hEle: HELE; iItem: Integer; iColumn: Integer; nValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_SetItemIntEx(hEle: HELE; iItem: Integer; pName: PWideChar; nValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_SetItemFloat(hEle: HELE; iItem: Integer; iColumn: Integer; fFloat: Single): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_SetItemFloatEx(hEle: HELE; iItem: Integer; pName: PWideChar; fFloat: Single): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_GetItemText(hEle: HELE; iItem: Integer; iColumn: Integer): PWideChar; stdcall; external XCGUI_DLL;

function XComboBox_GetItemTextEx(hEle: HELE; iItem: Integer; pName: PWideChar): PWideChar; stdcall; external XCGUI_DLL;

function XComboBox_GetItemImage(hEle: HELE; iItem: Integer; iColumn: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XComboBox_GetItemImageEx(hEle: HELE; iItem: Integer; pName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XComboBox_GetItemInt(hEle: HELE; iItem: Integer; iColumn: Integer; out pOutValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_GetItemIntEx(hEle: HELE; iItem: Integer; pName: PWideChar; out pOutValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_GetItemFloat(hEle: HELE; iItem: Integer; iColumn: Integer; out pOutValue: Single): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_GetItemFloatEx(hEle: HELE; iItem: Integer; pName: PWideChar; out pOutValue: Single): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_DeleteItem(hEle: HELE; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_DeleteItemEx(hEle: HELE; iItem: Integer; nCount: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XComboBox_DeleteItemAll(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XComboBox_DeleteColumnAll(hEle: HELE); stdcall; external XCGUI_DLL;

function XAd_AddRef(hAdapter: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XAd_Release(hAdapter: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XAd_GetRefCount(hAdapter: HXCGUI): Integer; stdcall; external XCGUI_DLL;

procedure XAd_Destroy(hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

procedure XAd_EnableAutoDestroy(hAdapter: HXCGUI; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XAdListView_Create(): HXCGUI; stdcall; external XCGUI_DLL;

function XAdListView_Group_AddColumn(hAdapter: HXCGUI; pName: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XAdListView_Group_AddItemText(hAdapter: HXCGUI; pValue: PWideChar; iPos: Integer = -1): Integer; stdcall; external XCGUI_DLL;

function XAdListView_Group_AddItemTextEx(hAdapter: HXCGUI; pName: PWideChar; pValue: PWideChar; iPos: Integer = -1): Integer; stdcall; external XCGUI_DLL;

function XAdListView_Group_AddItemImage(hAdapter: HXCGUI; hImage: HIMAGE; iPos: Integer = -1): Integer; stdcall; external XCGUI_DLL;

function XAdListView_Group_AddItemImageEx(hAdapter: HXCGUI; pName: PWideChar; hImage: HIMAGE; iPos: Integer = -1): Integer; stdcall; external XCGUI_DLL;

function XAdListView_Group_SetText(hAdapter: HXCGUI; iGroup: Integer; iColumn: Integer; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XAdListView_Group_SetTextEx(hAdapter: HXCGUI; iGroup: Integer; pName: PWideChar; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XAdListView_Group_SetImage(hAdapter: HXCGUI; iGroup: Integer; iColumn: Integer; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XAdListView_Group_SetImageEx(hAdapter: HXCGUI; iGroup: Integer; pName: PWideChar; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XAdListView_Group_GetCount(hAdapter: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XAdListView_Item_GetCount(hAdapter: HXCGUI; iGroup: Integer): Integer; stdcall; external XCGUI_DLL;

function XAdListView_Item_AddColumn(hAdapter: HXCGUI; pName: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XAdListView_Item_AddItemText(hAdapter: HXCGUI; iGroup: Integer; pValue: PWideChar; iPos: Integer = -1): Integer; stdcall; external XCGUI_DLL;

function XAdListView_Item_AddItemTextEx(hAdapter: HXCGUI; iGroup: Integer; pName: PWideChar; pValue: PWideChar; iPos: Integer = -1): Integer; stdcall; external XCGUI_DLL;

function XAdListView_Item_AddItemImage(hAdapter: HXCGUI; iGroup: Integer; hImage: HIMAGE; iPos: Integer = -1): Integer; stdcall; external XCGUI_DLL;

function XAdListView_Item_AddItemImageEx(hAdapter: HXCGUI; iGroup: Integer; pName: PWideChar; hImage: HIMAGE; iPos: Integer = -1): Integer; stdcall; external XCGUI_DLL;

function XAdListView_Item_SetText(hAdapter: HXCGUI; iGroup: Integer; iItem: Integer; iColumn: Integer; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XAdListView_Item_SetTextEx(hAdapter: HXCGUI; iGroup: Integer; iItem: Integer; pName: PWideChar; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XAdListView_Item_SetImage(hAdapter: HXCGUI; iGroup: Integer; iItem: Integer; iColumn: Integer; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XAdListView_Item_SetImageEx(hAdapter: HXCGUI; iGroup: Integer; iItem: Integer; pName: PWideChar; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XAdListView_Group_DeleteItem(hAdapter: HXCGUI; iGroup: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XAdListView_Group_DeleteAllChildItem(hAdapter: HXCGUI; iGroup: Integer); stdcall; external XCGUI_DLL;

function XAdListView_Item_DeleteItem(hAdapter: HXCGUI; iGroup: Integer; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XAdListView_DeleteAll(hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

procedure XAdListView_DeleteAllGroup(hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

procedure XAdListView_DeleteAllItem(hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

procedure XAdListView_DeleteColumnGroup(hAdapter: HXCGUI; iColumn: Integer); stdcall; external XCGUI_DLL;

procedure XAdListView_DeleteColumnItem(hAdapter: HXCGUI; iColumn: Integer); stdcall; external XCGUI_DLL;

function XAdListView_Item_GetTextEx(hAdapter: HXCGUI; iGroup: Integer; iItem: Integer; pName: PWideChar): PWideChar; stdcall; external XCGUI_DLL;

function XAdListView_Item_GetImageEx(hAdapter: HXCGUI; iGroup: Integer; iItem: Integer; pName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XAdTable_Create(): HXCGUI; stdcall; external XCGUI_DLL;

procedure XAdTable_Sort(hAdapter: HXCGUI; iColumn: Integer; bAscending: BOOL); stdcall; external XCGUI_DLL;

function XAdTable_GetItemDataType(hAdapter: HXCGUI; iItem: Integer; iColumn: Integer): adapter_date_type_; stdcall; external XCGUI_DLL;

function XAdTable_GetItemDataTypeEx(hAdapter: HXCGUI; iItem: Integer; pName: PWideChar): adapter_date_type_; stdcall; external XCGUI_DLL;

function XAdTable_AddColumn(hAdapter: HXCGUI; pName: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XAdTable_SetColumn(hAdapter: HXCGUI; pColName: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XAdTable_AddItemText(hAdapter: HXCGUI; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XAdTable_AddItemTextEx(hAdapter: HXCGUI; pName: PWideChar; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XAdTable_AddItemImage(hAdapter: HXCGUI; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XAdTable_AddItemImageEx(hAdapter: HXCGUI; pName: PWideChar; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XAdTable_InsertItemText(hAdapter: HXCGUI; iItem: Integer; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XAdTable_InsertItemTextEx(hAdapter: HXCGUI; iItem: Integer; pName: PWideChar; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XAdTable_InsertItemImage(hAdapter: HXCGUI; iItem: Integer; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XAdTable_InsertItemImageEx(hAdapter: HXCGUI; iItem: Integer; pName: PWideChar; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XAdTable_SetItemText(hAdapter: HXCGUI; iItem: Integer; iColumn: Integer; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XAdTable_SetItemTextEx(hAdapter: HXCGUI; iItem: Integer; pName: PWideChar; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XAdTable_SetItemInt(hAdapter: HXCGUI; iItem: Integer; iColumn: Integer; nValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XAdTable_SetItemIntEx(hAdapter: HXCGUI; iItem: Integer; pName: PWideChar; nValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XAdTable_SetItemFloat(hAdapter: HXCGUI; iItem: Integer; iColumn: Integer; nValue: Single): BOOL; stdcall; external XCGUI_DLL;

function XAdTable_SetItemFloatEx(hAdapter: HXCGUI; iItem: Integer; pName: PWideChar; nValue: Single): BOOL; stdcall; external XCGUI_DLL;

function XAdTable_SetItemImage(hAdapter: HXCGUI; iItem: Integer; iColumn: Integer; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XAdTable_SetItemImageEx(hAdapter: HXCGUI; iItem: Integer; pName: PWideChar; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XAdTable_DeleteItem(hAdapter: HXCGUI; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

function XAdTable_DeleteItemEx(hAdapter: HXCGUI; iItem: Integer; nCount: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XAdTable_DeleteItemAll(hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

procedure XAdTable_DeleteColumnAll(hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

function XAdTable_GetCount(hAdapter: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XAdTable_GetCountColumn(hAdapter: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XAdTable_GetItemText(hAdapter: HXCGUI; iItem: Integer; iColumn: Integer): PWideChar; stdcall; external XCGUI_DLL;

function XAdTable_GetItemTextEx(hAdapter: HXCGUI; iItem: Integer; pName: PWideChar): PWideChar; stdcall; external XCGUI_DLL;

function XAdTable_GetItemImage(hAdapter: HXCGUI; iItem: Integer; iColumn: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XAdTable_GetItemImageEx(hAdapter: HXCGUI; iItem: Integer; pName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XAdTable_GetItemInt(hAdapter: HXCGUI; iItem: Integer; iColumn: Integer; out pOutValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XAdTable_GetItemIntEx(hAdapter: HXCGUI; iItem: Integer; pName: PWideChar; out pOutValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XAdTable_GetItemFloat(hAdapter: HXCGUI; iItem: Integer; iColumn: Integer; out pOutValue: Single): BOOL; stdcall; external XCGUI_DLL;

function XAdTable_GetItemFloatEx(hAdapter: HXCGUI; iItem: Integer; pName: PWideChar; out pOutValue: Single): BOOL; stdcall; external XCGUI_DLL;

function XAdTree_Create(): HXCGUI; stdcall; external XCGUI_DLL;

function XAdTree_AddColumn(hAdapter: HXCGUI; pName: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XAdTree_SetColumn(hAdapter: HXCGUI; pColName: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XAdTree_InsertItemText(hAdapter: HXCGUI; pValue: PWideChar; nParentID: Integer = XC_ID_ROOT; insertID: Integer = XC_ID_LAST): Integer; stdcall; external XCGUI_DLL;

function XAdTree_InsertItemTextEx(hAdapter: HXCGUI; pName: PWideChar; pValue: PWideChar; nParentID: Integer = XC_ID_ROOT; insertID: Integer = XC_ID_LAST): Integer; stdcall; external XCGUI_DLL;

function XAdTree_InsertItemImage(hAdapter: HXCGUI; hImage: HIMAGE; nParentID: Integer = XC_ID_ROOT; insertID: Integer = XC_ID_LAST): Integer; stdcall; external XCGUI_DLL;

function XAdTree_InsertItemImageEx(hAdapter: HXCGUI; pName: PWideChar; hImage: HIMAGE; nParentID: Integer = XC_ID_ROOT; insertID: Integer = XC_ID_LAST): Integer; stdcall; external XCGUI_DLL;

function XAdTree_GetCount(hAdapter: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XAdTree_GetCountColumn(hAdapter: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XAdTree_SetItemText(hAdapter: HXCGUI; nID: Integer; iColumn: Integer; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XAdTree_SetItemTextEx(hAdapter: HXCGUI; nID: Integer; pName: PWideChar; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XAdTree_SetItemImage(hAdapter: HXCGUI; nID: Integer; iColumn: Integer; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XAdTree_SetItemImageEx(hAdapter: HXCGUI; nID: Integer; pName: PWideChar; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XAdTree_GetItemText(hAdapter: HXCGUI; nID: Integer; iColumn: Integer): PWideChar; stdcall; external XCGUI_DLL;

function XAdTree_GetItemTextEx(hAdapter: HXCGUI; nID: Integer; pName: PWideChar): PWideChar; stdcall; external XCGUI_DLL;

function XAdTree_GetItemImage(hAdapter: HXCGUI; nID: Integer; iColumn: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XAdTree_GetItemImageEx(hAdapter: HXCGUI; nID: Integer; pName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XAdTree_DeleteItem(hAdapter: HXCGUI; nID: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XAdTree_DeleteItemAll(hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

procedure XAdTree_DeleteColumnAll(hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

function XAdMap_Create(): HXCGUI; stdcall; external XCGUI_DLL;

function XAdMap_AddItemText(hAdapter: HXCGUI; pName: PWideChar; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XAdMap_AddItemImage(hAdapter: HXCGUI; pName: PWideChar; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XAdMap_DeleteItem(hAdapter: HXCGUI; pName: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XAdMap_GetCount(hAdapter: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XAdMap_GetItemText(hAdapter: HXCGUI; pName: PWideChar): PWideChar; stdcall; external XCGUI_DLL;

function XAdMap_GetItemImage(hAdapter: HXCGUI; pName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XAdMap_SetItemText(hAdapter: HXCGUI; pName: PWideChar; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XAdMap_SetItemImage(hAdapter: HXCGUI; pName: PWideChar; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

procedure XDebug_Print(level: Integer; pInfo: PWideChar); stdcall; external XCGUI_DLL;

procedure _xtrace(pFormat: PWideChar); cdecl; external XCGUI_DLL;

procedure _xtracew(pFormat: PWideChar); cdecl; external XCGUI_DLL;

procedure XDebug_OutputDebugStringA(pString: PWideChar); stdcall; external XCGUI_DLL;

procedure XDebug_OutputDebugStringW(pString: PWideChar); stdcall; external XCGUI_DLL;

procedure XDebug_Set_OutputDebugString_UTF8(bUTF8: BOOL); stdcall; external XCGUI_DLL;

function XEase_Linear(p: Single): Single; stdcall; external XCGUI_DLL;

function XEase_Quad(p: Single; flag: ease_type_): Single; stdcall; external XCGUI_DLL;

function XEase_Cubic(p: Single; flag: ease_type_): Single; stdcall; external XCGUI_DLL;

function XEase_Quart(p: Single; flag: ease_type_): Single; stdcall; external XCGUI_DLL;

function XEase_Quint(p: Single; flag: ease_type_): Single; stdcall; external XCGUI_DLL;

function XEase_Sine(p: Single; flag: ease_type_): Single; stdcall; external XCGUI_DLL;

function XEase_Expo(p: Single; flag: ease_type_): Single; stdcall; external XCGUI_DLL;

function XEase_Circ(p: Single; flag: ease_type_): Single; stdcall; external XCGUI_DLL;

function XEase_Elastic(p: Single; flag: ease_type_): Single; stdcall; external XCGUI_DLL;

function XEase_Back(p: Single; flag: ease_type_): Single; stdcall; external XCGUI_DLL;

function XEase_Bounce(p: Single; flag: ease_type_): Single; stdcall; external XCGUI_DLL;

function XEditor_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

procedure XEditor_EnableConvertChar(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XEidtor_IsEmptyRow(hEle: HELE; iRow: Integer): BOOL; stdcall; external XCGUI_DLL;

function XEditor_IsBreakpoint(hEle: HELE; iRow: Integer): BOOL; stdcall; external XCGUI_DLL;

function XEditor_SetBreakpoint(hEle: HELE; iRow: Integer; bActivate: BOOL = True): BOOL; stdcall; external XCGUI_DLL;

function XEditor_GetBreakpointCount(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XEditor_SetTipsDelay(hEle: HELE; nDelay: Integer); stdcall; external XCGUI_DLL;

procedure XEditor_SetAutoMatchSelectModel(hEle: HELE; model: Integer); stdcall; external XCGUI_DLL;

procedure XEditor_SetAutoMatchMode(hEle: HELE; mode: Integer); stdcall; external XCGUI_DLL;

function XEditor_GetBreakpoints(hEle: HELE; out out_buffer: Integer; nCount: Integer): Integer; stdcall; external XCGUI_DLL;

function XEditor_RemoveBreakpoint(hEle: HELE; iRow: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XEditor_ClearBreakpoint(hEle: HELE); stdcall; external XCGUI_DLL;

function XEditor_SetRunRow(hEle: HELE; iRow: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XEditor_GetColor(hEle: HELE; out pInfo: Integer); stdcall; external XCGUI_DLL;

procedure XEditor_SetColor(hEle: HELE; pInfo: Integer); stdcall; external XCGUI_DLL;

procedure XEditor_SetCurRow(hEle: HELE; iRow: Integer); stdcall; external XCGUI_DLL;

function XEditor_GetDepth(hEle: HELE; iRow: Integer): Integer; stdcall; external XCGUI_DLL;

function XEditor_GetDepthEx(hEle: HELE; iRow: Integer): Integer; stdcall; external XCGUI_DLL;

function XEditor_ToExpandRow(hEle: HELE; iRow: Integer): Integer; stdcall; external XCGUI_DLL;

procedure XEditor_ExpandAll(hEle: HELE; bExpand: BOOL); stdcall; external XCGUI_DLL;

procedure XEditor_Expand(hEle: HELE; iRow: Integer; bExpand: BOOL); stdcall; external XCGUI_DLL;

procedure XEditor_ExpandSwitch(hEle: HELE; iRow: Integer); stdcall; external XCGUI_DLL;

procedure XEditor_ExpandEx(hEle: HELE; iRow: Integer); stdcall; external XCGUI_DLL;

function XEditor_GetExpandState(hEle: HELE): PAnsiChar; stdcall; external XCGUI_DLL;

function XEditor_SetExpandState(hEle: HELE; pString: PAnsiChar): BOOL; stdcall; external XCGUI_DLL;

procedure XEditor_AddKeyword(hEle: HELE; pKey: PWideChar; iStyle: Integer); stdcall; external XCGUI_DLL;

procedure XEditor_AddConst(hEle: HELE; pKey: PWideChar); stdcall; external XCGUI_DLL;

procedure XEditor_AddFunction(hEle: HELE; pKey: PWideChar); stdcall; external XCGUI_DLL;

procedure XEditor_AddExcludeDefVarKeyword(hEle: HELE; pKeyword: PWideChar); stdcall; external XCGUI_DLL;

procedure XEditor_FunArgsExpand_AddArg(hEle: HELE; pTypeName: PWideChar; pArgName: PWideChar; pText: PWideChar); stdcall; external XCGUI_DLL;

procedure XEditor_FunArgsExpand_Expand(hEle: HELE; pFunName: PWideChar; iRow: Integer; iCol: Integer; iCol2: Integer; nDepth: Integer); stdcall; external XCGUI_DLL;

function XEdit_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

function XEdit_CreateEx(x: Integer; y: Integer; cx: Integer; cy: Integer; type_: edit_type_; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

procedure XEdit_EnableAutoWrap(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XEdit_EnableReadOnly(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XEdit_EnableMultiLine(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XEdit_EnablePassword(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XEdit_EnableAutoSelAll(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XEdit_EnableAutoCancelSel(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XEdit_IsReadOnly(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEdit_IsMultiLine(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEdit_IsPassword(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEdit_IsAutoWrap(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEdit_IsEmpty(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEdit_IsInSelect(hEle: HELE; iRow: Integer; iCol: Integer): BOOL; stdcall; external XCGUI_DLL;

function XEdit_GetRowCount(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XEdit_GetData(hEle: HELE): Pedit_data_copy_; stdcall; external XCGUI_DLL;

procedure XEdit_AddData(hEle: HELE; pData, styleTable: Tedit_data_copy_; nStyleCount: Integer); stdcall; external XCGUI_DLL;

procedure XEdit_FreeData(pData: Pedit_data_copy_); stdcall; external XCGUI_DLL;

procedure XEdit_SetDefaultText(hEle: HELE; pString: PWideChar); stdcall; external XCGUI_DLL;

procedure XEdit_SetDefaultTextColor(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

procedure XEdit_SetPasswordCharacter(hEle: HELE; ch: WideChar); stdcall; external XCGUI_DLL;

procedure XEdit_SetTextAlign(hEle: HELE; align: Integer); stdcall; external XCGUI_DLL;

procedure XEdit_SetTabSpace(hEle: HELE; nSpace: Integer); stdcall; external XCGUI_DLL;

procedure XEdit_SetText(hEle: HELE; pString: PWideChar); stdcall; external XCGUI_DLL;

procedure XEdit_SetTextInt(hEle: HELE; nValue: Integer); stdcall; external XCGUI_DLL;

function XEdit_GetText(hEle: HELE; pOut: PWideChar; nOutlen: Integer): Integer; stdcall; external XCGUI_DLL;

function XEdit_GetTextRow(hEle: HELE; iRow: Integer; out pOut: PWideChar; nOutlen: Integer): Integer; stdcall; external XCGUI_DLL;

function XEdit_GetLength(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XEdit_GetLengthRow(hEle: HELE; iRow: Integer): Integer; stdcall; external XCGUI_DLL;

function XEdit_GetAt(hEle: HELE; iRow: Integer; iCol: Integer): WideChar; stdcall; external XCGUI_DLL;

procedure XEdit_InsertText(hEle: HELE; iRow: Integer; iCol: Integer; pString: PWideChar); stdcall; external XCGUI_DLL;
//procedure XEdit_InsertTextUser(hEle: HELE; pString: PWideChar); stdcall; external XCGUI_DLL;

procedure XEdit_AddText(hEle: HELE; pString: PWideChar); stdcall; external XCGUI_DLL;

procedure XEdit_AddTextEx(hEle: HELE; pString: PWideChar; iStyle: Integer); stdcall; external XCGUI_DLL;

function XEdit_AddObject(hEle: HELE; hObj: HXCGUI): Integer; stdcall; external XCGUI_DLL;

procedure XEdit_AddByStyle(hEle: HELE; iStyle: Integer); stdcall; external XCGUI_DLL;

function XEdit_AddStyle(hEle: HELE; hFont_image_Obj: HXCGUI; color: Integer; bColor: BOOL): Integer; stdcall; external XCGUI_DLL;

function XEdit_AddStyleEx(hEle: HELE; fontName: PWideChar; fontSize: Integer; fontStyle: Integer; color: Integer; bColor: BOOL): Integer; stdcall; external XCGUI_DLL;

function XEdit_GetStyleInfo(hEle: HELE; iStyle: Integer; out info: Tedit_style_info_): BOOL; stdcall; external XCGUI_DLL;

procedure XEdit_SetCurStyle(hEle: HELE; iStyle: Integer); stdcall; external XCGUI_DLL;

procedure XEdit_SetCaretColor(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

procedure XEdit_SetCaretWidth(hEle: HELE; nWidth: Integer); stdcall; external XCGUI_DLL;

procedure XEdit_SetSelectBkColor(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

procedure XEdit_SetRowHeight(hEle: HELE; nHeight: Integer); stdcall; external XCGUI_DLL;

procedure XEdit_SetRowHeightEx(hEle: HELE; iRow: Integer; nHeight: Integer); stdcall; external XCGUI_DLL;
//procedure XEdit_SetCurPos(hEle: HELE; iRow: Integer; iCol: Integer); stdcall; external XCGUI_DLL;

function XEdit_GetCurPos(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XEdit_GetCurRow(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XEdit_GetCurCol(hEle: HELE; iRow: Integer): Integer; stdcall; external XCGUI_DLL;

procedure XEdit_GetPoint(hEle: HELE; iRow: Integer; iCol: Integer; out pOut: TPoint); stdcall; external XCGUI_DLL;

function XEdit_AutoScroll(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEdit_AutoScrollEx(hEle: HELE; iRow: Integer; iCol: Integer): BOOL; stdcall; external XCGUI_DLL;
//procedure XEdit_PositionToInfo(hEle: HELE; iPos: Integer; pInfo: position_); stdcall; external XCGUI_DLL;

function XEdit_SelectAll(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEdit_CancelSelect(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEdit_DeleteSelect(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEdit_SetSelect(hEle: HELE; iStartRow: Integer; iStartCol: Integer; iEndRow: Integer; iEndCol: Integer): BOOL; stdcall; external XCGUI_DLL;

function XEdit_GetSelectText(hEle: HELE; out pOut: PWideChar; nOutLen: Integer): Integer; stdcall; external XCGUI_DLL;

function XEdit_GetSelectRange(hEle: HELE; out pBegin: Tposition_; out pEnd: Tposition_): BOOL; stdcall; external XCGUI_DLL;

procedure XEdit_GetVisibleRowRange(hEle: HELE; out piStart: Integer; out piEnd: Integer); stdcall; external XCGUI_DLL;

function XEdit_Delete(hEle: HELE; iStartRow: Integer; iStartCol: Integer; iEndRow: Integer; iEndCol: Integer): BOOL; stdcall; external XCGUI_DLL;

function XEdit_DeleteRow(hEle: HELE; iRow: Integer): BOOL; stdcall; external XCGUI_DLL;

function XEdit_ClipboardCut(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEdit_ClipboardCopy(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEdit_ClipboardPaste(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEdit_Undo(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEdit_Redo(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

procedure XEdit_AddChatBegin(hEle: HELE; hImageAvatar: HIMAGE; hImageBubble: HIMAGE; nFlag: Integer); stdcall; external XCGUI_DLL;

procedure XEdit_AddChatEnd(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XEdit_SetChatIndentation(hEle: HELE; nIndentation: Integer); stdcall; external XCGUI_DLL;

function XEdit_CommentSelect(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEdit_IndentationSelect(hEle: HELE; bAdd: Integer): BOOL; stdcall; external XCGUI_DLL;

function XEle_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

function _XEle_RegEvent(hEle: HELE; nEvent: Integer; pEvent: Integer): BOOL; stdcall; external XCGUI_DLL;

function _XEle_RemoveEvent(hEle: HELE; nEvent: UINT; pEvent: Integer): BOOL; stdcall; external XCGUI_DLL;

function XEle_RegEventC(hEle: HELE; nEvent: Integer; pFun: Integer): BOOL; stdcall; external XCGUI_DLL;

function XEle_RegEventC1(hEle: HELE; nEvent: Integer; pFun: Integer): BOOL; stdcall; external XCGUI_DLL;

function XEle_RegEventC2(hEle: HELE; nEvent: Integer; pFun: Integer): BOOL; stdcall; external XCGUI_DLL;

function XEle_RemoveEventC(hEle: HELE; nEvent: Integer; pFun: Integer): BOOL; stdcall; external XCGUI_DLL;

function XEle_SendEvent(hEle: HELE; nEvent: Integer; wParam: WPARAM; lParam: LPARAM): Integer; stdcall; external XCGUI_DLL;

function XEle_PostEvent(hEle: HELE; nEvent: Integer; wParam: WPARAM; lParam: LPARAM): BOOL; stdcall; external XCGUI_DLL;

function XEle_IsShow(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEle_IsEnable(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEle_IsEnableFocus(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEle_IsDrawFocus(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEle_IsEnableEvent_XE_PAINT_END(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEle_IsMouseThrough(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEle_IsBkTransparent(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEle_IsKeyTab(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEle_IsSwitchFocus(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEle_IsEnable_XE_MOUSEWHEEL(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEle_IsChildEle(hEle: HELE; hChildEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEle_IsEnableCanvas(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEle_IsFocus(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XEle_IsFocusEx(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

procedure XEle_Enable(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XEle_EnableFocus(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XEle_EnableDrawFocus(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XEle_EnableDrawBorder(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XEle_EnableCanvas(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XEle_EnableBkTransparent(hEle: HELE; bEnable: BOOL = True); stdcall; external XCGUI_DLL;

procedure XEle_EnableMouseThrough(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XEle_EnableKeyTab(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XEle_EnableSwitchFocus(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XEle_EnableEvent_XE_PAINT_END(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XEle_EnableEvent_XE_MOUSEWHEEL(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XEle_SetRect(hEle: HELE; var Rect: TRect; bRedraw: BOOL = FALSE; nFlags: Integer = adjustLayout_all; nAdjustNo: Cardinal = 0): Integer; stdcall; external XCGUI_DLL;

function XEle_SetRectEx(hEle: HELE; x, y, cx, cy: Integer; bRedraw: BOOL = FALSE; nFlags: Integer = adjustLayout_all; nAdjustNo: Cardinal = 0): Integer; stdcall; external XCGUI_DLL;

function XEle_SetRectLogic(hEle: HELE; var Rect: TRect; bRedraw: BOOL = FALSE; nFlags: Integer = adjustLayout_all; nAdjustNo: Cardinal = 0): Integer; stdcall; external XCGUI_DLL;

procedure XEle_GetRect(hEle: HELE; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XEle_GetRectLogic(hEle: HELE; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XEle_GetClientRect(hEle: HELE; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XEle_GetWndClientRect(hEle: HELE; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XEle_SetWidth(hEle: HELE; nWidth: Integer); stdcall; external XCGUI_DLL;

procedure XEle_SetHeight(hEle: HELE; nHeight: Integer); stdcall; external XCGUI_DLL;

function XEle_GetWidth(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XEle_GetHeight(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XEle_RectWndClientToEleClient(hEle: HELE; var Rect: TRect); stdcall; external XCGUI_DLL;

procedure XEle_PointWndClientToEleClient(hEle: HELE; var pPt: TPoint); stdcall; external XCGUI_DLL;

procedure XEle_RectClientToWndClient(hEle: HELE; var Rect: TRect); stdcall; external XCGUI_DLL;

procedure XEle_PointClientToWndClient(hEle: HELE; var pPt: TPoint); stdcall; external XCGUI_DLL;

function XEle_AddChild(hEle: HELE; hChild: HXCGUI): BOOL; stdcall; external XCGUI_DLL;

function XEle_InsertChild(hEle: HELE; hChild: HXCGUI; index: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XEle_Remove(hEle: HELE); stdcall; external XCGUI_DLL;

function XEle_SetZOrder(hEle: HELE; index: Integer): BOOL; stdcall; external XCGUI_DLL;

function XEle_SetZOrderEx(hEle: HELE; hDestEle: HELE; nType: zorder_): BOOL; stdcall; external XCGUI_DLL;

function XEle_GetZOrder(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XEle_EnableTopmost(hEle: HELE; bTopmost: BOOL); stdcall; external XCGUI_DLL;

procedure XEle_SetCursor(hEle: HELE; hCursor: HCURSOR); stdcall; external XCGUI_DLL;

function XEle_GetCursor(hEle: HELE): HCURSOR; stdcall; external XCGUI_DLL;

procedure XEle_SetTextColor(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

function XEle_GetTextColor(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XEle_GetTextColorEx(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XEle_SetFocusBorderColor(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

function XEle_GetFocusBorderColor(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XEle_SetFont(hEle: HELE; hFontx: HFONTX); stdcall; external XCGUI_DLL;

function XEle_GetFont(hEle: HELE): HFONTX; stdcall; external XCGUI_DLL;

function XEle_GetFontEx(hEle: HELE): HFONTX; stdcall; external XCGUI_DLL;

procedure XEle_SetAlpha(hEle: HELE; alpha: BYTE); stdcall; external XCGUI_DLL;

function XEle_GetAlpha(hEle: HELE): Byte; stdcall; external XCGUI_DLL;

function XEle_GetChildCount(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XEle_GetChildByIndex(hEle: HELE; index: Integer): HXCGUI; stdcall; external XCGUI_DLL;

function XEle_GetChildByID(hEle: HELE; nID: Integer): HXCGUI; stdcall; external XCGUI_DLL;

procedure XEle_SetBorderSize(hEle: HELE; left: Integer; top: Integer; right: Integer; bottom: Integer); stdcall; external XCGUI_DLL;

procedure XEle_GetBorderSize(hEle: HELE; out pBorder: TborderSize_); stdcall; external XCGUI_DLL;

procedure XEle_SetPadding(hEle: HELE; left: Integer; top: Integer; right: Integer; bottom: Integer); stdcall; external XCGUI_DLL;

procedure XEle_GetPadding(hEle: HELE; out pPadding: TpaddingSize_); stdcall; external XCGUI_DLL;

procedure XEle_SetDragBorder(hEle: HELE; nFlags: Integer); stdcall; external XCGUI_DLL;

procedure XEle_SetDragBorderBindEle(hEle: HELE; nFlags: Integer; hBindEle: HELE; nSpace: Integer); stdcall; external XCGUI_DLL;

procedure XEle_SetMinSize(hEle: HELE; nWidth: Integer; nHeight: Integer); stdcall; external XCGUI_DLL;

procedure XEle_SetMaxSize(hEle: HELE; nWidth: Integer; nHeight: Integer); stdcall; external XCGUI_DLL;

procedure XEle_SetLockScroll(hEle: HELE; bHorizon: BOOL; bVertical: BOOL); stdcall; external XCGUI_DLL;

function XEle_HitChildEle(hEle: HELE; var pPt: TPOINT): HELE; stdcall; external XCGUI_DLL;

procedure XEle_SetUserData(hEle: HELE; nData: vint); stdcall; external XCGUI_DLL;

function XEle_GetUserData(hEle: HELE): vint; stdcall; external XCGUI_DLL;

procedure XEle_GetContentSize(hEle: HELE; bHorizon: BOOL; cx: Integer; cy: Integer; out pSize: TSize); stdcall; external XCGUI_DLL;

procedure XEle_SetCapture(hEle: HELE; b: BOOL); stdcall; external XCGUI_DLL;

procedure XEle_Redraw(hEle: HELE; bImmediate: BOOL = False); stdcall; external XCGUI_DLL;

procedure XEle_RedrawRect(hEle: HELE; var Rect: TRect; bImmediate: BOOL = False); stdcall; external XCGUI_DLL;

procedure XEle_Destroy(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XEle_AddBkBorder(hEle: HELE; nState: Integer; color: Integer; width: Integer); stdcall; external XCGUI_DLL;

procedure XEle_AddBkFill(hEle: HELE; nState: Integer; color: Integer); stdcall; external XCGUI_DLL;

procedure XEle_AddBkImage(hEle: HELE; nState: Integer; hImage: HIMAGE); stdcall; external XCGUI_DLL;

function XEle_GetBkInfoCount(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XEle_ClearBkInfo(hEle: HELE); stdcall; external XCGUI_DLL;

function XEle_GetBkManager(hEle: HELE): HBKM; stdcall; external XCGUI_DLL;

function XEle_GetBkManagerEx(hEle: HELE): HBKM; stdcall; external XCGUI_DLL;

procedure XEle_SetBkManager(hEle: HELE; hBkInfoM: HBKM); stdcall; external XCGUI_DLL;

function XEle_GetStateFlags(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XEle_DrawFocus(hEle: HELE; hDraw: HDRAW; var Rect: TRect): BOOL; stdcall; external XCGUI_DLL;

procedure XEle_DrawEle(hEle: HELE; hDraw: HDRAW); stdcall; external XCGUI_DLL;

procedure XEle_EnableTransparentChannel(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XEle_SetXCTimer(hEle: HELE; nIDEvent: UINT; uElapse: UINT): BOOL; stdcall; external XCGUI_DLL;

function XEle_KillXCTimer(hEle: HELE; nIDEvent: UINT): BOOL; stdcall; external XCGUI_DLL;

procedure XEle_SetToolTip(hEle: HELE; pText: PWideChar); stdcall; external XCGUI_DLL;

procedure XEle_SetToolTipEx(hEle: HELE; pText: PWideChar; nTextAlign: Integer); stdcall; external XCGUI_DLL;

function XEle_GetToolTip(hEle: HELE): PWideChar; stdcall; external XCGUI_DLL;

procedure XEle_PopupToolTip(hEle: HELE; x: Integer; y: Integer); stdcall; external XCGUI_DLL;

procedure XEle_AdjustLayout(hEle: HELE; nAdjustNo: UINT = 0); stdcall; external XCGUI_DLL;

procedure XEle_AdjustLayoutEx(hEle: HELE; nFlags: Integer = adjustLayout_self; nAdjustNo: UINT = 0); stdcall; external XCGUI_DLL;

function XFont_Create(size: Integer): HFONTX; stdcall; external XCGUI_DLL;

function XFont_CreateEx(pName: PWideChar; size: Integer = 12; style: fontStyle_ = fontStyle_regular): HFONTX; stdcall; external XCGUI_DLL;

function XFont_CreateFromLOGFONTW(pFontInfo: PLOGFONTW): HFONTX; stdcall; external XCGUI_DLL;

function XFont_CreateFromHFONT(hFont: HFONT): HFONTX; stdcall; external XCGUI_DLL;

function XFont_CreateFromFont(pFont: Pointer): HFONTX; stdcall; external XCGUI_DLL;

function XFont_CreateFromFile(pFontFile: PWideChar; size: Integer = 12; style: fontStyle_ = fontStyle_regular): HFONTX; stdcall; external XCGUI_DLL;

procedure XFont_EnableAutoDestroy(hFontX: HFONTX; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XFont_GetFont(hFontX: HFONTX): Pointer; stdcall; external XCGUI_DLL;

procedure XFont_GetFontInfo(hFontX: HFONTX; out pInfo: font_info_); stdcall; external XCGUI_DLL;

function XFont_GetLOGFONTW(hFontX: HFONTX; hdc: HDC; out pOut: PLOGFONTW): BOOL; stdcall; external XCGUI_DLL;

procedure XFont_AddRef(hFontX: HFONTX); stdcall; external XCGUI_DLL;

procedure XFont_Release(hFontX: HFONTX); stdcall; external XCGUI_DLL;

function XFont_GetRefCount(hFontX: HFONTX): Integer; stdcall; external XCGUI_DLL;

procedure XFont_Destroy(hFontX: HFONTX); stdcall; external XCGUI_DLL;

function XFrameWnd_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; pTitle: PWideChar; hWndParent: Integer; XCStyle: Integer): HWINDOW; stdcall; external XCGUI_DLL;

procedure XFrameWnd_GetLayoutAreaRect(hWindow: HWINDOW; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XFrameWnd_SetView(hWindow: HWINDOW; hEle: HELE); stdcall; external XCGUI_DLL;

procedure XFrameWnd_SetPaneSplitBarColor(hWindow: HWINDOW; color: Integer); stdcall; external XCGUI_DLL;

procedure XFrameWnd_SetTabBarHeight(hWindow: HWINDOW; nHeight: Integer); stdcall; external XCGUI_DLL;

function XFrameWnd_SaveLayoutToFile(hWindow: HWINDOW; pFileName: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XFrameWnd_LoadLayoutFile(hWindow: HWINDOW; out aPaneList: HELE; nEleCount: Integer; pFileName: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XFrameWnd_AddPane(hWindow: HWINDOW; hPaneDest: HELE; hPaneNew: HELE; align: pane_align_): BOOL; stdcall; external XCGUI_DLL;

function XFrameWnd_MergePane(hWindow: HWINDOW; hPaneDest: HELE; hPaneNew: HELE): BOOL; stdcall; external XCGUI_DLL;

function XImgSrc_LoadFile(pFileName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XImgSrc_LoadFileRect(pFileName: PWideChar; x: Integer; y: Integer; cx: Integer; cy: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XImgSrc_LoadRes(id: Integer; pType: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XImgSrc_LoadZip(pZipFileName: PWideChar; pFileName: PWideChar; pPassword: PWideChar = nil): HIMAGE; stdcall; external XCGUI_DLL;

function XImgSrc_LoadZipRect(pZipFileName: PWideChar; pFileName: PWideChar; pPassword: PWideChar; x: Integer; y: Integer; cx: Integer; cy: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XImgSrc_LoadZipMem(data: Integer; length: Integer; pFileName: PWideChar; pPassword: PWideChar = nil): HIMAGE; stdcall; external XCGUI_DLL;

function XImgSrc_LoadMemory(pBuffer: Pointer; nSize: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XImgSrc_LoadMemoryRect(pBuffer: Pointer; nSize: Integer; x: Integer; y: Integer; cx: Integer; cy: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XImgSrc_LoadFromImage(pImage: Pointer): HIMAGE; stdcall; external XCGUI_DLL;

function XImgSrc_LoadFromExtractIcon(pFileName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XImgSrc_LoadFromHICON(hIcon: HICON): HIMAGE; stdcall; external XCGUI_DLL;

function XImgSrc_LoadFromHBITMAP(hBitmap: HBITMAP): HIMAGE; stdcall; external XCGUI_DLL;

procedure XImgSrc_EnableAutoDestroy(hImage: HIMAGE; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XImgSrc_GetWidth(hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XImgSrc_GetHeight(hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XImgSrc_GetFile(hImage: HIMAGE): PWideChar; stdcall; external XCGUI_DLL;

procedure XImgSrc_AddRef(hImage: HIMAGE); stdcall; external XCGUI_DLL;

procedure XImgSrc_Release(hImage: HIMAGE); stdcall; external XCGUI_DLL;

function XImgSrc_GetRefCount(hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

procedure XImgSrc_Destroy(hImage: HIMAGE); stdcall; external XCGUI_DLL;

function XImage_LoadSrc(hImageSrc: HIMAGE): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadFile(pFileName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadFileAdaptive(pFileName: PWideChar; leftSize: Integer; topSize: Integer; rightSize: Integer; bottomSize: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadFileRect(pFileName: PWideChar; x: Integer; y: Integer; cx: Integer; cy: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadResAdaptive(id: Integer; pType: PWideChar; leftSize: Integer; topSize: Integer; rightSize: Integer; bottomSize: Integer; hInst: HMODULE = 0): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadRes(id: Integer; pType: PWideChar; hInst: HMODULE = 0): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadZip(pZipFileName: PWideChar; pFileName: PWideChar; pPassword: PWideChar = nil): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadZipAdaptive(pZipFileName: PWideChar; pFileName: PWideChar; pPassword: PWideChar; x1: Integer; x2: Integer; y1: Integer; y2: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadZipRect(pZipFileName: PWideChar; pFileName: PWideChar; pPassword: PWideChar; x: Integer; y: Integer; cx: Integer; cy: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadZipMem(data: Integer; length: Integer; pFileName: PWideChar; pPassword: PWideChar = nil): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadMemory(pBuffer: Integer; nSize: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadMemoryRect(pBuffer: Integer; nSize: Integer; x: Integer; y: Integer; cx: Integer; cy: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadMemoryAdaptive(pBuffer: Integer; nSize: Integer; leftSize: Integer; topSize: Integer; rightSize: Integer; bottomSize: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadFromImage(pImage: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadFromExtractIcon(pFileName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadFromHICON(hIcon: HICON): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadFromHBITMAP(hBitmap: HBITMAP): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_IsStretch(hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XImage_IsAdaptive(hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XImage_IsTile(hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XImage_SetDrawType(hImage: HIMAGE; nType: image_draw_type_): BOOL; stdcall; external XCGUI_DLL;

function XImage_SetDrawTypeAdaptive(hImage: HIMAGE; leftSize: Integer; topSize: Integer; rightSize: Integer; bottomSize: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XImage_SetTranColor(hImage: HIMAGE; color: Integer); stdcall; external XCGUI_DLL;

procedure XImage_SetTranColorEx(hImage: HIMAGE; color: Integer; tranColor: Byte); stdcall; external XCGUI_DLL;

function XImage_SetRotateAngle(hImage: HIMAGE; fAngle: Single): Single; stdcall; external XCGUI_DLL;

procedure XImage_SetSplitEqual(hImage: HIMAGE; nCount: Integer; iIndex: Integer); stdcall; external XCGUI_DLL;

procedure XImage_EnableTranColor(hImage: HIMAGE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XImage_EnableAutoDestroy(hImage: HIMAGE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XImage_EnableCenter(hImage: HIMAGE; bCenter: BOOL); stdcall; external XCGUI_DLL;

function XImage_IsCenter(hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XImage_GetDrawType(hImage: HIMAGE): image_draw_type_; stdcall; external XCGUI_DLL;

function XImage_GetWidth(hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XImage_GetHeight(hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XImage_GetImageSrc(hImage: HIMAGE): HIMAGE; stdcall; external XCGUI_DLL;

procedure XImage_AddRef(hImage: HIMAGE); stdcall; external XCGUI_DLL;

procedure XImage_Release(hImage: HIMAGE); stdcall; external XCGUI_DLL;

function XImage_GetRefCount(hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

procedure XImage_Destroy(hImage: HIMAGE); stdcall; external XCGUI_DLL;

function XLayout_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI): HELE; stdcall; external XCGUI_DLL;

function XLayout_CreateEx(hParent: HXCGUI): HELE; stdcall; external XCGUI_DLL;

function XLayout_IsEnableLayout(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

procedure XLayout_EnableLayout(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XLayout_ShowLayoutFrame(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XLayout_GetWidthIn(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XLayout_GetHeightIn(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XLayoutBox_EnableHorizon(hLayoutBox: HXCGUI; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XLayoutBox_EnableAutoWrap(hLayoutBox: HXCGUI; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XLayoutBox_EnableOverflowHide(hLayoutBox: HXCGUI; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XLayoutBox_SetAlignH(hLayoutBox: HXCGUI; nAlign: layout_align_); stdcall; external XCGUI_DLL;

procedure XLayoutBox_SetAlignV(hLayoutBox: HXCGUI; nAlign: layout_align_); stdcall; external XCGUI_DLL;

procedure XLayoutBox_SetAlignBaseline(hLayoutBox: HXCGUI; nAlign: layout_align_axis_); stdcall; external XCGUI_DLL;

procedure XLayoutBox_SetSpace(hLayoutBox: HXCGUI; nSpace: Integer); stdcall; external XCGUI_DLL;

procedure XLayoutBox_SetSpaceRow(hLayoutBox: HXCGUI; nSpace: Integer); stdcall; external XCGUI_DLL;

function XLayoutFrame_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI): HELE; stdcall; external XCGUI_DLL;

procedure XLayoutFrame_ShowLayoutFrame(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XListBox_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

procedure XListBox_EnableFixedRowHeight(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XListBox_EnableTemplateReuse(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XListBox_EnableVirtualTable(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XListBox_SetVirtualRowCount(hEle: HELE; nRowCount: Integer); stdcall; external XCGUI_DLL;

procedure XListBox_SetDrawItemBkFlags(hEle: HELE; nFlags: Integer); stdcall; external XCGUI_DLL;

function XListBox_SetItemData(hEle: HELE; iItem: Integer; nUserData: vint): BOOL; stdcall; external XCGUI_DLL;

function XListBox_GetItemData(hEle: HELE; iItem: Integer): vint; stdcall; external XCGUI_DLL;

function XListBox_SetItemInfo(hEle: HELE; iItem: Integer; pItem: TlistBox_item_info_): BOOL; stdcall; external XCGUI_DLL;

function XListBox_GetItemInfo(hEle: HELE; iItem: Integer; out pItem: TlistBox_item_info_): BOOL; stdcall; external XCGUI_DLL;

function XListBox_SetSelectItem(hEle: HELE; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListBox_GetSelectItem(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XListBox_AddSelectItem(hEle: HELE; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListBox_CancelSelectItem(hEle: HELE; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListBox_CancelSelectAll(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XListBox_GetSelectAll(hEle: HELE; out pArray: Integer; nArraySize: Integer): Integer; stdcall; external XCGUI_DLL;

function XListBox_GetSelectCount(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XListBox_GetItemMouseStay(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XListBox_SelectAll(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

procedure XListBox_VisibleItem(hEle: HELE; iItem: Integer); stdcall; external XCGUI_DLL;

procedure XListBox_GetVisibleRowRange(hEle: HELE; out piStart: Integer; out piEnd: Integer); stdcall; external XCGUI_DLL;

procedure XListBox_SetItemHeightDefault(hEle: HELE; nHeight: Integer; nSelHeight: Integer); stdcall; external XCGUI_DLL;

procedure XListBox_GetItemHeightDefault(hEle: HELE; out pHeight: Integer; out pSelHeight: Integer); stdcall; external XCGUI_DLL;

function XListBox_GetItemIndexFromHXCGUI(hEle: HELE; hXCGUI: HXCGUI): Integer; stdcall; external XCGUI_DLL;

procedure XListBox_SetRowSpace(hEle: HELE; nSpace: Integer); stdcall; external XCGUI_DLL;

function XListBox_GetRowSpace(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XListBox_HitTest(hEle: HELE; pPt: PPoint): Integer; stdcall; external XCGUI_DLL;

function XListBox_HitTestOffset(hEle: HELE; var pPt: TPoint): Integer; stdcall; external XCGUI_DLL;

function XListBox_SetItemTemplateXML(hEle: HELE; pXmlFile: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XListBox_SetItemTemplateXMLFromString(hEle: HELE; pStringXML: PAnsiChar): BOOL; stdcall; external XCGUI_DLL;

function XListBox_SetItemTemplate(hEle: HELE; hTemp: HTEMP): BOOL; stdcall; external XCGUI_DLL;

function XListBox_GetTemplateObject(hEle: HELE; iItem: Integer; nTempItemID: Integer): HXCGUI; stdcall; external XCGUI_DLL;

procedure XListBox_EnableMultiSel(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XListBox_CreateAdapter(hEle: HELE): HXCGUI; stdcall; external XCGUI_DLL;

procedure XListBox_BindAdapter(hEle: HELE; hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

function XListBox_GetAdapter(hEle: HELE): HXCGUI; stdcall; external XCGUI_DLL;

procedure XListBox_Sort(hEle: HELE; iColumnAdapter: Integer; bAscending: BOOL); stdcall; external XCGUI_DLL;

procedure XListBox_RefreshData(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XListBox_RefreshItem(hEle: HELE; iItem: Integer); stdcall; external XCGUI_DLL;

function XListBox_AddItemText(hEle: HELE; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XListBox_AddItemTextEx(hEle: HELE; pName: PWideChar; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XListBox_AddItemImage(hEle: HELE; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XListBox_AddItemImageEx(hEle: HELE; pName: PWideChar; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XListBox_InsertItemText(hEle: HELE; iItem: Integer; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XListBox_InsertItemTextEx(hEle: HELE; iItem: Integer; pName: PWideChar; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XListBox_InsertItemImage(hEle: HELE; iItem: Integer; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XListBox_InsertItemImageEx(hEle: HELE; iItem: Integer; pName: PWideChar; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XListBox_SetItemText(hEle: HELE; iItem: Integer; iColumn: Integer; pText: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XListBox_SetItemTextEx(hEle: HELE; iItem: Integer; pName: PWideChar; pText: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XListBox_SetItemImage(hEle: HELE; iItem: HELE; iColumn: Integer; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XListBox_SetItemImageEx(hEle: HELE; iItem: Integer; pName: PWideChar; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XListBox_SetItemInt(hEle: HELE; iItem: Integer; iColumn: Integer; nValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListBox_SetItemIntEx(hEle: HELE; iItem: Integer; pName: PWideChar; nValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListBox_SetItemFloat(hEle: HELE; iItem: Integer; iColumn: Integer; fFloat: Single): BOOL; stdcall; external XCGUI_DLL;

function XListBox_SetItemFloatEx(hEle: HELE; iItem: Integer; pName: PWideChar; fFloat: Single): BOOL; stdcall; external XCGUI_DLL;

function XListBox_GetItemText(hEle: HELE; iItem: Integer; iColumn: Integer): PWideChar; stdcall; external XCGUI_DLL;

function XListBox_GetItemTextEx(hEle: HELE; iItem: Integer; pName: PWideChar): PWideChar; stdcall; external XCGUI_DLL;

function XListBox_GetItemImage(hEle: HELE; iItem: Integer; iColumn: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XListBox_GetItemImageEx(hEle: HELE; iItem: Integer; pName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XListBox_GetItemInt(hEle: HELE; iItem: Integer; iColumn: Integer; out pOutValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListBox_GetItemIntEx(hEle: HELE; iItem: Integer; pName: PWideChar; out pOutValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListBox_GetItemFloat(hEle: HELE; iItem: HELE; iColumn: Integer; out pOutValue: Single): BOOL; stdcall; external XCGUI_DLL;

function XListBox_GetItemFloatEx(hEle: HELE; iItem: Integer; pName: PWideChar; out pOutValue: Single): BOOL; stdcall; external XCGUI_DLL;

function XListBox_DeleteItem(hEle: HELE; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListBox_DeleteItemEx(hEle: HELE; iItem: Integer; nCount: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XListBox_DeleteItemAll(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XListBox_DeleteColumnAll(hEle: HELE); stdcall; external XCGUI_DLL;

function XListBox_GetCount_AD(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XListBox_GetCountColumn_AD(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XTemp_Load(nType: listItemTemp_type_; pFileName: PWideChar): HTEMP; stdcall; external XCGUI_DLL;

function XTemp_LoadZip(nType: listItemTemp_type_; pZipFile: PWideChar; pFileName: PWideChar; pPassword: PWideChar = nil): HTEMP; stdcall; external XCGUI_DLL;

function XTemp_LoadZipMem(nType: listItemTemp_type_; data: Integer; length: Integer; pFileName: PWideChar; pPassword: PWideChar = nil): HTEMP; stdcall; external XCGUI_DLL;

function XTemp_LoadEx(nType: listItemTemp_type_; pFileName: PWideChar; out pOutTemp1: HTEMP; out pOutTemp2: HTEMP): BOOL; stdcall; external XCGUI_DLL;

function XTemp_LoadZipEx(nType: listItemTemp_type_; pZipFile: PWideChar; pFileName: PWideChar; pPassword: PWideChar; out pOutTemp1: HTEMP; out pOutTemp2: HTEMP): BOOL; stdcall; external XCGUI_DLL;

function XTemp_LoadZipMemEx(nType: listItemTemp_type_; data: Integer; length: Integer; pFileName: PWideChar; pPassword: PWideChar; out pOutTemp1: HTEMP; out pOutTemp2: HTEMP): BOOL; stdcall; external XCGUI_DLL;

function XTemp_LoadFromString(nType: listItemTemp_type_; pStringXML: PAnsiChar): HTEMP; stdcall; external XCGUI_DLL;

function XTemp_LoadFromStringEx(nType: listItemTemp_type_; pStringXML: PAnsiChar; out pOutTemp1: HTEMP; out pOutTemp2: HTEMP): BOOL; stdcall; external XCGUI_DLL;

function XTemp_GetType(hTemp: HTEMP): listItemTemp_type_; stdcall; external XCGUI_DLL;

function XTemp_Destroy(hTemp: HTEMP): BOOL; stdcall; external XCGUI_DLL;

function XTemp_Create(nType: listItemTemp_type_): HTEMP; stdcall; external XCGUI_DLL;

function XTemp_AddNodeRoot(hTemp: HTEMP; pNode: Pointer): BOOL; stdcall; external XCGUI_DLL;

function XTemp_AddNode(pParentNode: Pointer; pNode: Pointer): BOOL; stdcall; external XCGUI_DLL;

function XTemp_CreateNode(nType: XC_OBJECT_TYPE): Pointer; stdcall; external XCGUI_DLL;

function XTemp_SetNodeAttribute(pNode: Pointer; pName: PWideChar; pAttr: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XTemp_SetNodeAttributeEx(pNode: Pointer; itemID: Integer; pName: PWideChar; pAttr: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XTemp_List_GetNode(hTemp: HTEMP; index: Integer): Pointer; stdcall; external XCGUI_DLL;

function XTemp_GetNode(pNode: Pointer; itemID: Integer): Pointer; stdcall; external XCGUI_DLL;

function XTemp_CloneNode(pNode: Pointer): Pointer; stdcall; external XCGUI_DLL;

function XList_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

function XList_AddColumn(hEle: HELE; width: Integer): Integer; stdcall; external XCGUI_DLL;

function XList_InsertColumn(hEle: HELE; width: Integer; iItem: Integer): Integer; stdcall; external XCGUI_DLL;

procedure XList_EnableMultiSel(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XList_EnableDragChangeColumnWidth(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XList_EnableVScrollBarTop(hEle: HELE; bTop: BOOL); stdcall; external XCGUI_DLL;

procedure XList_EnableItemBkFullRow(hEle: HELE; bFull: BOOL); stdcall; external XCGUI_DLL;

procedure XList_EnableFixedRowHeight(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XList_EnableTemplateReuse(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XList_EnableVirtualTable(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XList_SetVirtualRowCount(hEle: HELE; nRowCount: Integer); stdcall; external XCGUI_DLL;

procedure XList_SetSort(hEle: HELE; iColumn: Integer; iColumnAdapter: Integer; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XList_SetDrawItemBkFlags(hEle: HELE; style: Integer); stdcall; external XCGUI_DLL;

procedure XList_SetColumnWidth(hEle: HELE; iItem: Integer; width: Integer); stdcall; external XCGUI_DLL;

procedure XList_SetColumnMinWidth(hEle: HELE; iItem: Integer; width: Integer); stdcall; external XCGUI_DLL;

procedure XList_SetColumnWidthFixed(hEle: HELE; iColumn: Integer; bFixed: BOOL); stdcall; external XCGUI_DLL;

function XList_GetColumnWidth(hEle: HELE; iColumn: Integer): Integer; stdcall; external XCGUI_DLL;

function XList_GetColumnCount(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XList_DeleteColumn(hEle: HELE; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XList_DeleteColumnAll(hEle: HELE); stdcall; external XCGUI_DLL;

function XList_SetItemData(hEle: HELE; iItem: Integer; iSubItem: Integer; data: vint): BOOL; stdcall; external XCGUI_DLL;

function XList_GetItemData(hEle: HELE; iItem: Integer; iSubItem: Integer): vint; stdcall; external XCGUI_DLL;

function XList_SetSelectItem(hEle: HELE; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

function XList_GetSelectItem(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XList_GetSelectItemCount(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XList_AddSelectItem(hEle: HELE; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XList_SetSelectAll(hEle: HELE); stdcall; external XCGUI_DLL;

function XList_GetSelectAll(hEle: HELE; out pArray: Integer; nArraySize: Integer): Integer; stdcall; external XCGUI_DLL;

procedure XList_VisibleItem(hEle: HELE; iItem: Integer); stdcall; external XCGUI_DLL;

function XList_CancelSelectItem(hEle: HELE; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XList_CancelSelectAll(hEle: HELE); stdcall; external XCGUI_DLL;

function XList_GetHeaderHELE(hEle: HELE): HELE; stdcall; external XCGUI_DLL;

procedure XList_BindAdapter(hEle: HELE; hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

procedure XList_BindAdapterHeader(hEle: HELE; hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

function XList_CreateAdapter(hEle: HELE; col_extend_count: Integer = 3): HXCGUI; stdcall; external XCGUI_DLL;

function XList_CreateAdapterHeader(hEle: HELE): HXCGUI; stdcall; external XCGUI_DLL;

function XList_GetAdapter(hEle: HELE): HXCGUI; stdcall; external XCGUI_DLL;

function XList_GetAdapterHeader(hEle: HELE): HXCGUI; stdcall; external XCGUI_DLL;

function XList_SetItemTemplateXML(hEle: HELE; pXmlFile: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XList_SetItemTemplateXMLFromString(hEle: HELE; pStringXML: PAnsiChar): BOOL; stdcall; external XCGUI_DLL;

function XList_SetItemTemplate(hEle: HELE; hTemp: HTEMP): BOOL; stdcall; external XCGUI_DLL;

function XList_GetTemplateObject(hEle: HELE; iItem: Integer; iSubItem: Integer; nTempItemID: Integer): HXCGUI; stdcall; external XCGUI_DLL;

function XList_GetItemIndexFromHXCGUI(hEle: HELE; hXCGUI: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XList_GetHeaderTemplateObject(hEle: HELE; iItem: Integer; nTempItemID: Integer): HXCGUI; stdcall; external XCGUI_DLL;

function XList_GetHeaderItemIndexFromHXCGUI(hEle: HELE; hXCGUI: HXCGUI): Integer; stdcall; external XCGUI_DLL;

procedure XList_SetHeaderHeight(hEle: HELE; height: Integer); stdcall; external XCGUI_DLL;

function XList_GetHeaderHeight(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XList_GetVisibleRowRange(hEle: HELE; out piStart: Integer; out piEnd: Integer); stdcall; external XCGUI_DLL;

procedure XList_SetItemHeightDefault(hEle: HELE; nHeight: Integer; nSelHeight: Integer); stdcall; external XCGUI_DLL;

procedure XList_GetItemHeightDefault(hEle: HELE; out pHeight: Integer; out pSelHeight: Integer); stdcall; external XCGUI_DLL;

procedure XList_SetRowSpace(hEle: HELE; nSpace: Integer); stdcall; external XCGUI_DLL;

function XList_GetRowSpace(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XList_SetLockColumnLeft(hEle: HELE; iColumn: Integer); stdcall; external XCGUI_DLL;

procedure XList_SetLockColumnRight(hEle: HELE; iColumn: Integer); stdcall; external XCGUI_DLL;

procedure XList_SetLockRowBottom(hEle: HELE; bLock: BOOL); stdcall; external XCGUI_DLL;

procedure XList_SetLockRowBottomOverlap(hEle: HELE; bOverlap: BOOL); stdcall; external XCGUI_DLL;

function XList_HitTest(hEle: HELE; pPt: PPoint; out piItem: Integer; out piSubItem: Integer): BOOL; stdcall; external XCGUI_DLL;

function XList_HitTestOffset(hEle: HELE; pPt: PPoint; out piItem: Integer; out piSubItem: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XList_RefreshData(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XList_RefreshItem(hEle: HELE; iItem: Integer); stdcall; external XCGUI_DLL;

function XList_AddColumnText(hEle: HELE; nWidth: Integer; pName: PWideChar; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XList_AddColumnImage(hEle: HELE; nWidth: Integer; pName: PWideChar; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XList_AddItemText(hEle: HELE; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XList_AddItemTextEx(hEle: HELE; pName: PWideChar; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XList_AddItemImage(hEle: HELE; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XList_AddItemImageEx(hEle: HELE; pName: PWideChar; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XList_InsertItemText(hEle: HELE; iItem: Integer; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XList_InsertItemTextEx(hEle: HELE; iItem: Integer; pName: PWideChar; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XList_InsertItemImage(hEle: HELE; iItem: HELE; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XList_InsertItemImageEx(hEle: HELE; iItem: Integer; pName: PWideChar; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XList_SetItemText(hEle: HELE; iItem: Integer; iColumn: Integer; pText: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XList_SetItemTextEx(hEle: HELE; iItem: Integer; pName: PWideChar; pText: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XList_SetItemImage(hEle: HELE; iItem: Integer; iColumn: Integer; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XList_SetItemImageEx(hEle: HELE; iItem: Integer; pName: PWideChar; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XList_SetItemInt(hEle: HELE; iItem: Integer; iColumn: Integer; nValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XList_SetItemIntEx(hEle: HELE; iItem: Integer; pName: PWideChar; nValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XList_SetItemFloat(hEle: HELE; iItem: Integer; iColumn: Integer; fFloat: Single): BOOL; stdcall; external XCGUI_DLL;

function XList_SetItemFloatEx(hEle: HELE; iItem: HELE; pName: PWideChar; fFloat: Single): BOOL; stdcall; external XCGUI_DLL;

function XList_GetItemText(hEle: HELE; iItem: Integer; iColumn: Integer): PWideChar; stdcall; external XCGUI_DLL;

function XList_GetItemTextEx(hEle: HELE; iItem: Integer; pName: PWideChar): PWideChar; stdcall; external XCGUI_DLL;

function XList_GetItemImage(hEle: HELE; iItem: Integer; iColumn: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XList_GetItemImageEx(hEle: HELE; iItem: Integer; pName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XList_GetItemInt(hEle: HELE; iItem: Integer; iColumn: Integer; out pOutValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XList_GetItemIntEx(hEle: HELE; iItem: Integer; pName: PWideChar; out pOutValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XList_GetItemFloat(hEle: HELE; iItem: Integer; iColumn: Integer; out pOutValue: Single): BOOL; stdcall; external XCGUI_DLL;

function XList_GetItemFloatEx(hEle: HELE; iItem: Integer; pName: PWideChar; out pOutValue: Single): BOOL; stdcall; external XCGUI_DLL;

function XList_DeleteItem(hEle: HELE; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

function XList_DeleteItemEx(hEle: HELE; iItem: Integer; nCount: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XList_DeleteItemAll(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XList_DeleteColumnAll_AD(hEle: HELE); stdcall; external XCGUI_DLL;

function XList_GetCount_AD(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XList_GetCountColumn_AD(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XListView_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

function XListView_CreateAdapter(hEle: HELE): HXCGUI; stdcall; external XCGUI_DLL;

procedure XListView_BindAdapter(hEle: HELE; hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

function XListView_GetAdapter(hEle: HELE): HXCGUI; stdcall; external XCGUI_DLL;

function XListView_SetItemTemplateXML(hEle: HELE; pXmlFile: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XListView_SetItemTemplateXMLFromString(hEle: HELE; pStringXML: PAnsiChar): BOOL; stdcall; external XCGUI_DLL;

function XListView_SetItemTemplate(hEle: HELE; hTemp: HTEMP): BOOL; stdcall; external XCGUI_DLL;

function XListView_GetTemplateObject(hEle: HELE; iGroup: Integer; iItem: Integer; nTempItemID: Integer): HXCGUI; stdcall; external XCGUI_DLL;

function XListView_GetTemplateObjectGroup(hEle: HELE; iGroup: Integer; nTempItemID: Integer): HXCGUI; stdcall; external XCGUI_DLL;

function XListView_GetItemIDFromHXCGUI(hEle: HELE; hXCGUI: HXCGUI; out piGroup: Integer; out piItem: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListView_HitTest(hEle: HELE; pPt: TPoint; out pOutGroup: Integer; out pOutItem: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListView_HitTestOffset(hEle: HELE; var pPt: TPoint; out pOutGroup: Integer; out pOutItem: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XListView_EnableMultiSel(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XListView_EnableTemplateReuse(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XListView_EnableVirtualTable(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XListView_SetVirtualItemCount(hEle: HELE; iGroup: Integer; nCount: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XListView_SetDrawItemBkFlags(hEle: HELE; nFlags: Integer); stdcall; external XCGUI_DLL;

function XListView_SetSelectItem(hEle: HELE; iGroup: Integer; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListView_GetSelectItem(hEle: HELE; out piGroup: Integer; out piItem: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListView_AddSelectItem(hEle: HELE; iGroup: Integer; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XListView_VisibleItem(hEle: HELE; iGroup: Integer; iItem: Integer); stdcall; external XCGUI_DLL;

procedure XListView_GetVisibleItemRange(hEle: HELE; out piGroup1: Integer; out piGroup2: Integer; out piStartGroup: Integer; out piStartItem: Integer; out piEndGroup: Integer; out piEndItem: Integer); stdcall; external XCGUI_DLL;

function XListView_GetSelectItemCount(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XListView_GetSelectAll(hEle: HELE; out pArray: Integer; nArraySize: Integer): Integer; stdcall; external XCGUI_DLL;

procedure XListView_SetSelectAll(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XListView_CancelSelectAll(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XListView_SetColumnSpace(hEle: HELE; space: Integer); stdcall; external XCGUI_DLL;

procedure XListView_SetRowSpace(hEle: HELE; space: Integer); stdcall; external XCGUI_DLL;

procedure XListView_SetItemSize(hEle: HELE; width: Integer; height: Integer); stdcall; external XCGUI_DLL;

procedure XListView_GetItemSize(hEle: HELE; width: Integer; height: Integer); stdcall; overload; external XCGUI_DLL;

procedure XListView_GetItemSize(hEle: HELE; out pSize: TSize); stdcall; overload; external XCGUI_DLL;

procedure XListView_SetGroupHeight(hEle: HELE; height: Integer); stdcall; external XCGUI_DLL;

function XListView_GetGroupHeight(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XListView_SetGroupUserData(hEle: HELE; iGroup: Integer; nData: vint); stdcall; external XCGUI_DLL;

procedure XListView_SetItemUserData(hEle: HELE; iGroup: Integer; iItem: Integer; nData: vint); stdcall; external XCGUI_DLL;

function XListView_GetGroupUserData(hEle: HELE; iGroup: Integer): vint; stdcall; external XCGUI_DLL;

function XListView_GetItemUserData(hEle: HELE; iGroup: Integer; iItem: Integer): vint; stdcall; external XCGUI_DLL;

procedure XListView_RefreshData(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XListView_RefreshItem(hEle: HELE; iGroup: Integer; iItem: Integer); stdcall; external XCGUI_DLL;

function XListView_ExpandGroup(hEle: HELE; iGroup: Integer; bExpand: BOOL): BOOL; stdcall; external XCGUI_DLL;

function XListView_Group_AddColumn(hEle: HELE; pName: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XListView_Group_AddItemText(hEle: HELE; pValue: PWideChar; iPos: Integer): Integer; stdcall; external XCGUI_DLL;

function XListView_Group_AddItemTextEx(hEle: HELE; pName: PWideChar; pValue: PWideChar; iPos: Integer): Integer; stdcall; external XCGUI_DLL;

function XListView_Group_AddItemImage(hEle: HELE; hImage: HIMAGE; iPos: Integer): Integer; stdcall; external XCGUI_DLL;

function XListView_Group_AddItemImageEx(hEle: HELE; pName: PWideChar; hImage: HIMAGE; iPos: Integer): Integer; stdcall; external XCGUI_DLL;

function XListView_Group_SetText(hEle: HELE; iGroup: Integer; iColumn: Integer; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XListView_Group_SetTextEx(hEle: HELE; iGroup: Integer; pName: PWideChar; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XListView_Item_AddItemTextEx(hEle: HELE; iGroup: Integer; pName: PWideChar; pValue: PWideChar; iPos: Integer): Integer; stdcall; external XCGUI_DLL;

function XListView_Group_GetCount(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XListView_Item_GetCount(hEle: HELE; iGroup: Integer): Integer; stdcall; external XCGUI_DLL;

function XListView_Item_SetImage(hEle: HELE; iGroup: Integer; iItem: Integer; iColumn: Integer; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XListView_Item_SetImageEx(hEle: HELE; iGroup: Integer; iItem: Integer; pName: PWideChar; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XListView_Item_SetTextEx(hEle: HELE; iGroup, iItem: Integer; const pName, pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XListView_Item_AddItemImage(hEle: HELE; iGroup: Integer; hImage: HIMAGE; iPos: Integer): Integer; stdcall; external XCGUI_DLL;

function XListView_Group_DeleteItem(hEle: HELE; iGroup: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XListView_Group_DeleteAllChildItem(hEle: HELE; iGroup: Integer); stdcall; external XCGUI_DLL;

function XListView_Item_DeleteItem(hEle: HELE; iGroup: Integer; iItem: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XListView_DeleteAll(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XListView_DeleteAllGroup(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XListView_DeleteAllItem(hEle: HELE); stdcall; external XCGUI_DLL;

function XListView_Group_SetImage(hEle: HELE; iGroup, iColumn: Integer; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XListView_Group_SetImageEx(hEle: HELE; iGroup: Integer; const pName: PWideChar; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XListView_Item_AddColumn(hEle: HELE; const pName: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XListView_Item_AddItemText(hEle: HELE; iGroup: Integer; const pValue: PWideChar; iPos: Integer): Integer; stdcall; external XCGUI_DLL;

function XListView_Item_AddItemImageEx(hEle: HELE; iGroup: Integer; const pName: PWideChar; hImage: HIMAGE; iPos: Integer): Integer; stdcall; external XCGUI_DLL;

function XListView_Item_SetText(hEle: HELE; iGroup, iItem, iColumn: Integer; const pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

procedure XListView_DeleteColumnGroup(hEle: HELE; iColumn: Integer); stdcall; external XCGUI_DLL;

procedure XListView_DeleteColumnItem(hEle: HELE; iColumn: Integer); stdcall; external XCGUI_DLL;

function XListView_Item_GetTextEx(hEle: HELE; iGroup: Integer; iItem: Integer; pName: PWideChar): PWideChar; stdcall; external XCGUI_DLL;

function XListView_Item_GetImageEx(hEle: HELE; iGroup: Integer; iItem: Integer; pName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XMenuBar_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

function XMenuBar_AddButton(hEle: HELE; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

procedure XMenuBar_SetButtonHeight(hEle: HELE; height: Integer); stdcall; external XCGUI_DLL;

function XMenuBar_GetMenu(hEle: HELE; nIndex: Integer): HMENUX; stdcall; external XCGUI_DLL;

function XMenuBar_DeleteButton(hEle: HELE; nIndex: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XMenuBar_EnableAutoWidth(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XMenu_Create(): HMENUX; stdcall; external XCGUI_DLL;

procedure XMenu_AddItem(hMenu: HMENUX; nID: Integer; pText: PWideChar; parentId: Integer = XC_ID_ROOT; nFlags: Integer = 0); stdcall; external XCGUI_DLL;

procedure XMenu_AddItemIcon(hMenu: HMENUX; nID: Integer; pText: PWideChar; nParentID: Integer; hImage: HIMAGE; nFlags: Integer = 0); stdcall; external XCGUI_DLL;

procedure XMenu_InsertItem(hMenu: HMENUX; nID: Integer; pText: PWideChar; nFlags: Integer; insertID: Integer); stdcall; external XCGUI_DLL;

procedure XMenu_InsertItemIcon(hMenu: HMENUX; nID: Integer; pText: PWideChar; hIcon: HIMAGE; nFlags: Integer; insertID: Integer); stdcall; external XCGUI_DLL;

function XMenu_GetFirstChildItem(hMenu: HMENUX; nID: Integer): Integer; stdcall; external XCGUI_DLL;

function XMenu_GetEndChildItem(hMenu: HMENUX; nID: Integer): Integer; stdcall; external XCGUI_DLL;

function XMenu_GetPrevSiblingItem(hMenu: HMENUX; nID: Integer): Integer; stdcall; external XCGUI_DLL;

function XMenu_GetNextSiblingItem(hMenu: HMENUX; nID: Integer): Integer; stdcall; external XCGUI_DLL;

function XMenu_GetParentItem(hMenu: HMENUX; nID: Integer): Integer; stdcall; external XCGUI_DLL;

procedure XMenu_SetAutoDestroy(hMenu: HMENUX; bAuto: BOOL); stdcall; external XCGUI_DLL;

procedure XMenu_EnableDrawBackground(hMenu: HMENUX; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XMenu_EnableDrawItem(hMenu: HMENUX; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XMenu_Popup(hMenu: HMENUX; hParentWnd: Integer; x: Integer; y: Integer; hParentEle: HELE = 0; nPosition: Tmenu_popup_position_ = menu_popup_position_left_top): BOOL; stdcall; external XCGUI_DLL;

procedure XMenu_DestroyMenu(hMenu: HMENUX); stdcall; external XCGUI_DLL;

procedure XMenu_CloseMenu(hMenu: HMENUX); stdcall; external XCGUI_DLL;

procedure XMenu_SetBkImage(hMenu: HMENUX; hImage: HIMAGE); stdcall; external XCGUI_DLL;

function XMenu_SetItemText(hMenu: HMENUX; nID: Integer; pText: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XMenu_GetItemText(hMenu: HMENUX; nID: Integer): PWideChar; stdcall; external XCGUI_DLL;

function XMenu_GetItemTextLength(hMenu: HMENUX; nID: Integer): Integer; stdcall; external XCGUI_DLL;

function XMenu_SetItemIcon(hMenu: HMENUX; nID: Integer; hIcon: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XMenu_SetItemFlags(hMenu: HMENUX; nID: Integer; uFlags: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XMenu_SetItemHeight(hMenu: HMENUX; height: Integer); stdcall; external XCGUI_DLL;

function XMenu_GetItemHeight(hMenu: HMENUX): Integer; stdcall; external XCGUI_DLL;

procedure XMenu_SetBorderColor(hMenu: HMENUX; crColor: Integer); stdcall; external XCGUI_DLL;

procedure XMenu_SetBorderSize(hMenu: HMENUX; nLeft: Integer; nTop: Integer; nRight: Integer; nBottom: Integer); stdcall; external XCGUI_DLL;

function XMenu_GetLeftWidth(hMenu: HMENUX): Integer; stdcall; external XCGUI_DLL;

function XMenu_GetLeftSpaceText(hMenu: HMENUX): Integer; stdcall; external XCGUI_DLL;

function XMenu_GetItemCount(hMenu: HMENUX): Integer; stdcall; external XCGUI_DLL;

function XMenu_SetItemCheck(hMenu: HMENUX; nID: Integer; bCheck: BOOL): BOOL; stdcall; external XCGUI_DLL;

function XMenu_IsItemCheck(hMenu: HMENUX; nID: Integer): BOOL; stdcall; external XCGUI_DLL;

function XModalWnd_Create(nWidth: Integer; nHeight: Integer; pTitle: PWideChar; hWndParent: Integer; XCStyle: window_style_ = window_style_modal): HWINDOW; stdcall; external XCGUI_DLL;

procedure XModalWnd_EnableAutoClose(hWindow: HWINDOW; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XModalWnd_EnableEscClose(hWindow: HWINDOW; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XModalWnd_DoModal(hWindow: HWINDOW): Integer; stdcall; external XCGUI_DLL;

procedure XModalWnd_EndModal(hWindow: HWINDOW; nResult: Integer); stdcall; external XCGUI_DLL;

function XPane_Create(pName: PWideChar; nWidth: Integer; nHeight: Integer; hFrameWnd: HWINDOW = 0): HELE; stdcall; external XCGUI_DLL;

procedure XPane_SetView(hEle: HELE; hView: HELE); stdcall; external XCGUI_DLL;

function XPane_IsShowPane(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

procedure XPane_SetSize(hEle: HELE; nWidth: Integer; nHeight: Integer); stdcall; external XCGUI_DLL;

function XPane_GetState(hEle: HELE): pane_state_; stdcall; external XCGUI_DLL;

procedure XPane_GetViewRect(hEle: HELE; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XPane_SetTitle(hEle: HELE; pTitle: PWideChar); stdcall; external XCGUI_DLL;

function XPane_GetTitle(hEle: HELE): PWideChar; stdcall; external XCGUI_DLL;

procedure XPane_SetCaptionHeight(hEle: HELE; nHeight: Integer); stdcall; external XCGUI_DLL;

function XPane_GetCaptionHeight(hEle: HELE): Integer; stdcall; external XCGUI_DLL;
//procedure XPane_HidePane(hEle: HELE); stdcall; external XCGUI_DLL;
//procedure XPane_ShowPane(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XPane_DockPane(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XPane_LockPane(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XPane_FloatPane(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XPane_DrawPane(hEle: HELE; hDraw: HDRAW); stdcall; external XCGUI_DLL;

function XPane_SetSelect(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XFloatWnd_EnableCaptionContent(hWindow: HWINDOW; bEnable: BOOL): BOOL; stdcall; external XCGUI_DLL;

function XFloatWnd_GetCaptionLayout(hWindow: HWINDOW): HXCGUI; stdcall; external XCGUI_DLL;

function XFloatWnd_GetCaptionShapeText(hWindow: HWINDOW): HXCGUI; stdcall; external XCGUI_DLL;

function XFloatWnd_GetCaptionButtonClose(hWindow: HWINDOW): HELE; stdcall; external XCGUI_DLL;

procedure XFloatWnd_SetTitle(hWindow: HWINDOW; pTitle: PWideChar); stdcall; external XCGUI_DLL;

function XFloatWnd_GetTitle(hWindow: HWINDOW): PWideChar; stdcall; external XCGUI_DLL;

function XProgBar_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

procedure XProgBar_SetRange(hEle: HELE; range: Integer); stdcall; external XCGUI_DLL;

function XProgBar_GetRange(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XProgBar_SetPos(hEle: HELE; pos: Integer); stdcall; external XCGUI_DLL;

function XProgBar_GetPos(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XProgBar_EnableHorizon(hEle: HELE; bHorizon: BOOL); stdcall; external XCGUI_DLL;

procedure XProgBar_SetImageLoad(hEle: HELE; hImage: HIMAGE); stdcall; external XCGUI_DLL;

function XPGrid_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

procedure XPGrid_DeleteAll(hEle: HELE); stdcall; external XCGUI_DLL;

function XPGrid_GetItemHELE(hEle: HELE; nItemID: Integer): HELE; stdcall; external XCGUI_DLL;

procedure XPGrid_SetWidth(hEle: HELE; nWidth: Integer); stdcall; external XCGUI_DLL;

function XPGrid_SetItemValue(hEle: HELE; nItemID: Integer; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XPGrid_SetItemValueInt(hEle: HELE; nItemID: Integer; nValue: Integer): BOOL; stdcall; external XCGUI_DLL;

function XPGrid_SetItemData(hEle: HELE; nItemID: Integer; nUserData: vint): BOOL; stdcall; external XCGUI_DLL;

function XPGrid_GetItemData(hEle: HELE; nItemID: Integer): vint; stdcall; external XCGUI_DLL;

function XPGrid_GetItemValue(hEle: HELE; nItemID: Integer): PWideChar; stdcall; external XCGUI_DLL;

function XPGrid_HitTest(hEle: HELE; pPt: PPoint; pbExpandButton: PBOOL): Integer; stdcall; external XCGUI_DLL;

function XPGrid_HitTestOffset(hEle: HELE; pPt: PPoint; pbExpandButton: PBOOL): Integer; stdcall; external XCGUI_DLL;

function XPGrid_ExpandItem(hEle: HELE; nItemID: Integer; bExpand: BOOL): BOOL; stdcall; external XCGUI_DLL;

function XPGrid_GetSelItem(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XPGrid_SetSelItem(hEle: HELE; nItemID: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XPGrid_SetDrawItemBkFlags(hEle: HELE; nFlags: Integer); stdcall; external XCGUI_DLL;

procedure XRes_EnableDelayLoad(bEnable: BOOL); stdcall; external XCGUI_DLL;

function XRes_GetIDValue(pName: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XRes_GetImage(pName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XRes_GetImageEx(pFileName: PWideChar; pName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XRes_GetColor(pName: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XRes_GetFont(pName: PWideChar): HFONTX; stdcall; external XCGUI_DLL;

function XRes_GetBkM(pName: PWideChar): HBKM; stdcall; external XCGUI_DLL;

function XEditColor_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI): HELE; stdcall; external XCGUI_DLL;

procedure XEditColor_SetColor(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

function XEditColor_GetColor(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XEditSet_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI): HELE; stdcall; external XCGUI_DLL;

function XEditFile_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

procedure XEditFile_SetOpenFileType(hEle: HELE; pType: PWideChar); stdcall; external XCGUI_DLL;

procedure XEditFile_SetDefaultFile(hEle: HELE; pFile: PWideChar); stdcall; external XCGUI_DLL;

procedure XEditFile_SetRelativeDir(hEle: HELE; pDir: PWideChar); stdcall; external XCGUI_DLL;

function XEditFolder_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI): HELE; stdcall; external XCGUI_DLL;

procedure XEditFolder_SetDefaultDir(hEle: HELE; pDir: PWideChar); stdcall; external XCGUI_DLL;

function XSBar_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

procedure XSBar_SetRange(hEle: HELE; range: Integer); stdcall; external XCGUI_DLL;

function XSBar_GetRange(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XSBar_ShowButton(hEle: HELE; bShow: BOOL); stdcall; external XCGUI_DLL;

procedure XSBar_SetSliderLength(hEle: HELE; length: Integer); stdcall; external XCGUI_DLL;

procedure XSBar_SetSliderMinLength(hEle: HELE; minLength: Integer); stdcall; external XCGUI_DLL;

procedure XSBar_SetSliderPadding(hEle: HELE; nPadding: Integer); stdcall; external XCGUI_DLL;

function XSBar_EnableHorizon(hEle: HELE; bHorizon: BOOL): BOOL; stdcall; external XCGUI_DLL;

function XSBar_GetSliderMaxLength(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XSBar_ScrollUp(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XSBar_ScrollDown(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XSBar_ScrollTop(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XSBar_ScrollBottom(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XSBar_ScrollPos(hEle: HELE; pos: Integer): BOOL; stdcall; external XCGUI_DLL;

function XSBar_GetButtonUp(hEle: HELE): HELE; stdcall; external XCGUI_DLL;

function XSBar_GetButtonDown(hEle: HELE): HELE; stdcall; external XCGUI_DLL;

function XSBar_GetButtonSlider(hEle: HELE): HELE; stdcall; external XCGUI_DLL;

function XSView_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

function XSView_SetTotalSize(hEle: HELE; cx: Integer; cy: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XSView_GetTotalSize(hEle: HELE; out pSize: TSize); stdcall; external XCGUI_DLL;

function XSView_SetLineSize(hEle: HELE; nWidth: Integer; nHeight: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XSView_GetLineSize(hEle: HELE; out pSize: TSize); stdcall; external XCGUI_DLL;

procedure XSView_SetScrollBarSize(hEle: HELE; size: Integer); stdcall; external XCGUI_DLL;

function XSView_GetViewPosH(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XSView_GetViewPosV(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XSView_GetViewWidth(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XSView_GetViewHeight(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XSView_GetViewRect(hEle: HELE; out Rect: TRect); stdcall; external XCGUI_DLL;

function XSView_GetScrollBarH(hEle: HELE): HELE; stdcall; external XCGUI_DLL;

function XSView_GetScrollBarV(hEle: HELE): HELE; stdcall; external XCGUI_DLL;

function XSView_ScrollPosH(hEle: HELE; pos: Integer): BOOL; stdcall; external XCGUI_DLL;

function XSView_ScrollPosV(hEle: HELE; pos: Integer): BOOL; stdcall; external XCGUI_DLL;

function XSView_ScrollPosXH(hEle: HELE; posX: Integer): BOOL; stdcall; external XCGUI_DLL;

function XSView_ScrollPosYV(hEle: HELE; posY: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XSView_ShowSBarH(hEle: HELE; bShow: BOOL); stdcall; external XCGUI_DLL;

procedure XSView_ShowSBarV(hEle: HELE; bShow: BOOL); stdcall; external XCGUI_DLL;

procedure XSView_EnableAutoShowScrollBar(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XSView_ScrollLeftLine(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XSView_ScrollRightLine(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XSView_ScrollTopLine(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XSView_ScrollBottomLine(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XSView_ScrollLeft(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XSView_ScrollRight(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XSView_ScrollTop(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XSView_ScrollBottom(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

procedure XShape_RemoveShape(hShape: HXCGUI); stdcall; external XCGUI_DLL;

function XShape_GetZOrder(hShape: HXCGUI): Integer; stdcall; external XCGUI_DLL;

procedure XShape_Redraw(hShape: HXCGUI); stdcall; external XCGUI_DLL;

function XShape_GetWidth(hShape: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XShape_GetHeight(hShape: HXCGUI): Integer; stdcall; external XCGUI_DLL;

procedure XShape_GetRect(hShape: HXCGUI; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XShape_SetRect(hShape: HXCGUI; var Rect: TRect); stdcall; external XCGUI_DLL;

function XShape_SetRectLogic(hShape: HXCGUI; var Rect: TRect; bRedraw: BOOL): BOOL; stdcall; external XCGUI_DLL;

procedure XShape_GetRectLogic(hShape: HXCGUI; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XShape_GetWndClientRect(hShape: HXCGUI; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XShape_GetContentSize(hShape: HXCGUI; out pSize: TSize); stdcall; external XCGUI_DLL;

procedure XShape_ShowLayout(hShape: HXCGUI; bShow: BOOL); stdcall; external XCGUI_DLL;

procedure XShape_AdjustLayout(hShape: HXCGUI); stdcall; external XCGUI_DLL;

procedure XShape_Destroy(hShape: HXCGUI); stdcall; external XCGUI_DLL;

function XShapeText_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; pName: PWideChar; hParent: HXCGUI = 0): HXCGUI; stdcall; external XCGUI_DLL;

procedure XShapeText_SetText(hTextBlock: HXCGUI; pName: PWideChar); stdcall; external XCGUI_DLL;

function XShapeText_GetText(hTextBlock: HXCGUI): PWideChar; stdcall; external XCGUI_DLL;

function XShapeText_GetTextLength(hTextBlock: HXCGUI): Integer; stdcall; external XCGUI_DLL;

procedure XShapeText_SetFont(hTextBlock: HXCGUI; hFontx: HFONTX); stdcall; external XCGUI_DLL;

function XShapeText_GetFont(hTextBlock: HXCGUI): HFONTX; stdcall; external XCGUI_DLL;

procedure XShapeText_SetTextColor(hTextBlock: HXCGUI; color: Integer); stdcall; external XCGUI_DLL;

function XShapeText_GetTextColor(hTextBlock: HXCGUI): Integer; stdcall; external XCGUI_DLL;

procedure XShapeText_SetTextAlign(hTextBlock: HXCGUI; align: Integer); stdcall; external XCGUI_DLL;

procedure XShapeText_SetOffset(hTextBlock: HXCGUI; x: Integer; y: Integer); stdcall; external XCGUI_DLL;

function XShapePic_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HXCGUI; stdcall; external XCGUI_DLL;

procedure XShapePic_SetImage(hShape: HXCGUI; hImage: HIMAGE); stdcall; external XCGUI_DLL;

function XShapePic_GetImage(hShape: HXCGUI): HIMAGE; stdcall; external XCGUI_DLL;

function XShapeGif_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HXCGUI; stdcall; external XCGUI_DLL;

procedure XShapeGif_SetImage(hShape: HXCGUI; hImage: HIMAGE); stdcall; external XCGUI_DLL;

function XShapeGif_GetImage(hShape: HXCGUI): HIMAGE; stdcall; external XCGUI_DLL;

function XShapeRect_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HXCGUI; stdcall; external XCGUI_DLL;

procedure XShapeRect_SetBorderColor(hShape: HXCGUI; color: Integer); stdcall; external XCGUI_DLL;

procedure XShapeRect_SetFillColor(hShape: HXCGUI; color: Integer); stdcall; external XCGUI_DLL;

procedure XShapeRect_SetRoundAngle(hShape: HXCGUI; nWidth: Integer; nHeight: Integer); stdcall; external XCGUI_DLL;

procedure XShapeRect_GetRoundAngle(hShape: HXCGUI; out pWidth: Integer; out pHeight: Integer); stdcall; external XCGUI_DLL;

procedure XShapeRect_EnableBorder(hShape: HXCGUI; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XShapeRect_EnableFill(hShape: HXCGUI; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XShapeRect_EnableRoundAngle(hShape: HXCGUI; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XShapeEllipse_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HXCGUI; stdcall; external XCGUI_DLL;

procedure XShapeEllipse_SetBorderColor(hShape: HXCGUI; color: Integer); stdcall; external XCGUI_DLL;

procedure XShapeEllipse_SetFillColor(hShape: HXCGUI; color: Integer); stdcall; external XCGUI_DLL;

procedure XShapeEllipse_EnableBorder(hShape: HXCGUI; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XShapeEllipse_EnableFill(hShape: HXCGUI; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XShapeGroupBox_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; pName: PWideChar; hParent: HXCGUI = 0): HXCGUI; stdcall; external XCGUI_DLL;

procedure XShapeGroupBox_SetBorderColor(hShape: HXCGUI; color: Integer); stdcall; external XCGUI_DLL;

procedure XShapeGroupBox_SetTextColor(hShape: HXCGUI; color: Integer); stdcall; external XCGUI_DLL;

procedure XShapeGroupBox_SetFontX(hShape: HXCGUI; hFontX: HFONTX); stdcall; external XCGUI_DLL;

procedure XShapeGroupBox_SetTextOffset(hShape: HXCGUI; offsetX: Integer; offsetY: Integer); stdcall; external XCGUI_DLL;

procedure XShapeGroupBox_SetRoundAngle(hShape: HXCGUI; nWidth: Integer; nHeight: Integer); stdcall; external XCGUI_DLL;

procedure XShapeGroupBox_SetText(hShape: HXCGUI; pText: PWideChar); stdcall; external XCGUI_DLL;

procedure XShapeGroupBox_GetTextOffset(hShape: HXCGUI; out pOffsetX: Integer; out pOffsetY: Integer); stdcall; external XCGUI_DLL;

procedure XShapeGroupBox_GetRoundAngle(hShape: HXCGUI; out pWidth: Integer; out pOffsetY: Integer); stdcall; external XCGUI_DLL;

procedure XShapeGroupBox_EnableRoundAngle(hShape: HXCGUI; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XShapeLine_Create(x1: Integer; y1: Integer; x2: Integer; y2: Integer; hParent: HXCGUI = 0): HXCGUI; stdcall; external XCGUI_DLL;

procedure XShapeLine_SetPosition(hShape: HXCGUI; x1: Integer; y1: Integer; x2: Integer; y2: Integer); stdcall; external XCGUI_DLL;

procedure XShapeLine_SetColor(hShape: HXCGUI; color: Integer); stdcall; external XCGUI_DLL;

function XSliderBar_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

procedure XSliderBar_SetRange(hEle: HELE; range: Integer); stdcall; external XCGUI_DLL;

function XSliderBar_GetRange(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XSliderBar_SetButtonWidth(hEle: HELE; width: Integer); stdcall; external XCGUI_DLL;

procedure XSliderBar_SetButtonHeight(hEle: HELE; height: Integer); stdcall; external XCGUI_DLL;

procedure XSliderBar_SetPos(hEle: HELE; pos: Integer); stdcall; external XCGUI_DLL;

function XSliderBar_GetPos(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XSliderBar_GetButton(hEle: HELE): HELE; stdcall; external XCGUI_DLL;

procedure XSliderBar_EnableHorizon(hEle: HELE; bHorizon: BOOL); stdcall; external XCGUI_DLL;

procedure XSliderBar_SetImageLoad(hEle: HELE; hImage: HIMAGE); stdcall; external XCGUI_DLL;

function XC_itoa(nValue: Integer): PChar; stdcall; external XCGUI_DLL;

function XC_itow(nValue: Integer): PWideChar; stdcall; external XCGUI_DLL;

function XC_i64tow(nValue: Int64): PWideChar; stdcall; external XCGUI_DLL;

function XC_ftoa(fValue: Single): PChar; stdcall; external XCGUI_DLL;

function XC_ftow(fValue: Single): PWideChar; stdcall; external XCGUI_DLL;

function XC_fftow(fValue: Double): PWideChar; stdcall; external XCGUI_DLL;

function XC_atow(pValue: PChar): PWideChar; stdcall; external XCGUI_DLL;

function XC_wtoa(pValue: PWideChar): PChar; stdcall; external XCGUI_DLL;

function XC_utf8tow(pUtf8: PChar): PWideChar; stdcall; external XCGUI_DLL;

function XC_utf8towEx(pUtf8: PChar; length: Integer): PWideChar; stdcall; external XCGUI_DLL;

function XC_utf8toa(pUtf8: PChar): PChar; stdcall; external XCGUI_DLL;

function XC_atoutf8(pValue: PChar): PChar; stdcall; external XCGUI_DLL;

function XC_wtoutf8(pValue: PWideChar): PChar; stdcall; external XCGUI_DLL;

function XC_wtoutf8Ex(pValue: PWideChar; length: Integer): PChar; stdcall; external XCGUI_DLL;

function XTabBar_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

function XTabBar_AddLabel(hEle: HELE; pName: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XTabBar_InsertLabel(hEle: HELE; index: Integer; pName: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XTabBar_MoveLabel(hEle: HELE; iSrc: Integer; iDest: Integer): BOOL; stdcall; external XCGUI_DLL;

function XTabBar_DeleteLabel(hEle: HELE; index: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XTabBar_DeleteLabelAll(hEle: HELE); stdcall; external XCGUI_DLL;

function XTabBar_GetLabel(hEle: HELE; index: Integer): HELE; stdcall; external XCGUI_DLL;

function XTabBar_GetLabelClose(hEle: HELE; index: Integer): HELE; stdcall; external XCGUI_DLL;

function XTabBar_GetButtonLeft(hEle: HELE): HELE; stdcall; external XCGUI_DLL;

function XTabBar_GetButtonRight(hEle: HELE; index: Integer): HELE; stdcall; external XCGUI_DLL;

function XTabBar_GetButtonDropMenu(hEle: HELE): HELE; stdcall; external XCGUI_DLL;

function XTabBar_GetSelect(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XTabBar_GetLabelSpacing(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XTabBar_GetLabelCount(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XTabBar_GetindexByEle(hEle: HELE; hLabel: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XTabBar_SetLabelSpacing(hEle: HELE; spacing: Integer); stdcall; external XCGUI_DLL;

procedure XTabBar_SetPadding(hEle: HELE; left: Integer; top: Integer; right: Integer; bottom: Integer); stdcall; external XCGUI_DLL;

procedure XTabBar_SetSelect(hEle: HELE; index: Integer); stdcall; external XCGUI_DLL;

procedure XTabBar_SetUp(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XTabBar_SetDown(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XTabBar_EnableTile(hEle: HELE; bTile: BOOL); stdcall; external XCGUI_DLL;

procedure XTabBar_EnableDropMenu(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XTabBar_EnableClose(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XTabBar_SetCloseSize(hEle: HELE; pSize: TSize); stdcall; external XCGUI_DLL;

procedure XTabBar_SetTurnButtonSize(hEle: HELE; pSize: TSize); stdcall; external XCGUI_DLL;

procedure XTabBar_SetLabelWidth(hEle: HELE; index: Integer; nWidth: Integer); stdcall; external XCGUI_DLL;

function XTabBar_ShowLabel(hEle: HELE; index: Integer; bShow: BOOL): BOOL; stdcall; external XCGUI_DLL;

function XTable_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HXCGUI; stdcall; external XCGUI_DLL;

procedure XTable_Reset(hShape: HXCGUI; nRow: Integer; nCol: Integer); stdcall; external XCGUI_DLL;

procedure XTable_ComboRow(hShape: HXCGUI; iRow: Integer; iCol: Integer; count: Integer); stdcall; external XCGUI_DLL;

procedure XTable_ComboCol(hShape: HXCGUI; iRow: Integer; iCol: Integer; count: Integer); stdcall; external XCGUI_DLL;

procedure XTable_SetColWidth(hShape: HXCGUI; iCol: Integer; width: Integer); stdcall; external XCGUI_DLL;

procedure XTable_SetRowHeight(hShape: HXCGUI; iRow: Integer; height: Integer); stdcall; external XCGUI_DLL;

procedure XTable_SetBorderColor(hShape: HXCGUI; color: Integer); stdcall; external XCGUI_DLL;

procedure XTable_SetTextColor(hShape: HXCGUI; color: Integer); stdcall; external XCGUI_DLL;

procedure XTable_SetFont(hShape: HXCGUI; hFont: HFONTX); stdcall; external XCGUI_DLL;

procedure XTable_SetItemPadding(hShape: HXCGUI; leftSize: Integer; topSize: Integer; rightSize: Integer; bottomSize: Integer); stdcall; external XCGUI_DLL;

procedure XTable_SetItemText(hShape: HXCGUI; iRow: Integer; iCol: Integer; pText: PWideChar); stdcall; external XCGUI_DLL;

procedure XTable_SetItemFont(hShape: HXCGUI; iRow: Integer; iCol: Integer; hFont: HFONTX); stdcall; external XCGUI_DLL;

procedure XTable_SetItemTextAlign(hShape: HXCGUI; iRow: Integer; iCol: Integer; nAlign: Integer); stdcall; external XCGUI_DLL;

procedure XTable_SetItemTextColor(hShape: HXCGUI; iRow: Integer; iCol: Integer; color: Integer; bColor: BOOL); stdcall; external XCGUI_DLL;

procedure XTable_SetItemBkColor(hShape: HXCGUI; iRow: Integer; iCol: Integer; color: Integer; bColor: BOOL); stdcall; external XCGUI_DLL;

procedure XTable_SetItemLine(hShape: HXCGUI; iRow1: Integer; iCol1: Integer; iRow2: Integer; iCol2: Integer; nFlag: Integer; color: Integer); stdcall; external XCGUI_DLL;

procedure XTable_SetItemFlag(hShape: HXCGUI; iRow: Integer; iCol: Integer; flag: Integer); stdcall; external XCGUI_DLL;

function XTable_GetItemRect(hShape: HXCGUI; iRow: Integer; iCol: Integer; out Rect: TRect): BOOL; stdcall; external XCGUI_DLL;

function XTextLink_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; pName: PWideChar; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

procedure XTextLink_EnableUnderlineLeave(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XTextLink_EnableUnderlineStay(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XTextLink_SetTextColorStay(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

procedure XTextLink_SetUnderlineColorLeave(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

procedure XTextLink_SetUnderlineColorStay(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

function XToolBar_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

function XToolBar_InsertEle(hEle: HELE; hNewEle: HELE; index: Integer = -1): Integer; stdcall; external XCGUI_DLL;

function XToolBar_InsertSeparator(hEle: HELE; index: Integer = -1; color: Integer = 0): Integer; stdcall; external XCGUI_DLL;

procedure XToolBar_EnableButtonMenu(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XToolBar_GetEle(hEle: HELE; index: Integer): HELE; stdcall; external XCGUI_DLL;

function XToolBar_GetButtonLeft(hEle: HELE): HELE; stdcall; external XCGUI_DLL;

function XToolBar_GetButtonRight(hEle: HELE): HELE; stdcall; external XCGUI_DLL;

function XToolBar_GetButtonMenu(hEle: HELE): HELE; stdcall; external XCGUI_DLL;

procedure XToolBar_SetSpace(hEle: HELE; nSize: Integer); stdcall; external XCGUI_DLL;

procedure XToolBar_DeleteEle(hEle: HELE; index: Integer); stdcall; external XCGUI_DLL;

procedure XToolBar_DeleteAllEle(hEle: HELE); stdcall; external XCGUI_DLL;

function XTree_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

procedure XTree_EnableDragItem(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XTree_EnableConnectLine(hEle: HELE; bEnable: BOOL; bSolid: BOOL); stdcall; external XCGUI_DLL;

procedure XTree_EnableExpand(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XTree_EnableTemplateReuse(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XTree_SetConnectLineColor(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

procedure XTree_SetExpandButtonSize(hEle: HELE; nWidth: Integer; nHeight: Integer); stdcall; external XCGUI_DLL;

procedure XTree_SetConnectLineLength(hEle: HELE; nLength: Integer); stdcall; external XCGUI_DLL;

procedure XTree_SetDragInsertPositionColor(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

function XTree_SetItemTemplateXML(hEle: HELE; pXmlFile: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XTree_SetItemTemplateXMLSel(hEle: HELE; pXmlFile: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XTree_SetItemTemplate(hEle: HELE; hTemp: HTEMP): BOOL; stdcall; external XCGUI_DLL;

function XTree_SetItemTemplateSel(hEle: HELE; hTemp: HTEMP): BOOL; stdcall; external XCGUI_DLL;

function XTree_SetItemTemplateXMLFromString(hEle: HELE; pStringXML: PChar): BOOL; stdcall; external XCGUI_DLL;

function XTree_SetItemTemplateXMLSelFromString(hEle: HELE; pStringXML: PChar): BOOL; stdcall; external XCGUI_DLL;

procedure XTree_SetDrawItemBkFlags(hEle: HELE; nFlags: Integer); stdcall; external XCGUI_DLL;

function XTree_SetItemData(hEle: HELE; nID: Integer; nUserData: vint): BOOL; stdcall; external XCGUI_DLL;

function XTree_GetItemData(hEle: HELE; nID: Integer): vint; stdcall; external XCGUI_DLL;

function XTree_SetSelectItem(hEle: HELE; nID: Integer): BOOL; stdcall; external XCGUI_DLL;

function XTree_GetSelectItem(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XTree_VisibleItem(hEle: HELE; nID: Integer); stdcall; external XCGUI_DLL;

function XTree_IsExpand(hEle: HELE; nID: Integer): BOOL; stdcall; external XCGUI_DLL;

function XTree_ExpandItem(hEle: HELE; nID: Integer; bExpand: BOOL): BOOL; stdcall; external XCGUI_DLL;

function XTree_ExpandAllChildItem(hEle: HELE; nID: Integer; bExpand: BOOL): BOOL; stdcall; external XCGUI_DLL;

function XTree_HitTest(hEle: HELE; pPt: PPoint): Integer; stdcall; external XCGUI_DLL;

function XTree_HitTestOffset(hEle: HELE; pPt: PPoint): Integer; stdcall; external XCGUI_DLL;

function XTree_GetFirstChildItem(hEle: HELE; nID: Integer): Integer; stdcall; external XCGUI_DLL;

function XTree_GetEndChildItem(hEle: HELE; nID: Integer): Integer; stdcall; external XCGUI_DLL;

function XTree_GetPrevSiblingItem(hEle: HELE; nID: Integer): Integer; stdcall; external XCGUI_DLL;

function XTree_GetNextSiblingItem(hEle: HELE; nID: Integer): Integer; stdcall; external XCGUI_DLL;

function XTree_GetParentItem(hEle: HELE; nID: Integer): Integer; stdcall; external XCGUI_DLL;

procedure XTree_SetIndentation(hEle: HELE; nWidth: Integer); stdcall; external XCGUI_DLL;

function XTree_GetIndentation(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XTree_SetItemHeight(hEle: HELE; nID: Integer; nHeight: Integer; nSelHeight: Integer); stdcall; external XCGUI_DLL;

procedure XTree_GetItemHeight(hEle: HELE; nID: Integer; out pHeight: Integer; out pSelHeight: Integer); stdcall; external XCGUI_DLL;

procedure XTree_SetRowSpace(hEle: HELE; nSpace: Integer); stdcall; external XCGUI_DLL;

function XTree_GetRowSpace(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XTree_MoveItem(hEle: HELE; nMoveItem: Integer; nDestItem: Integer; nFlag: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XTree_SetItemHeightDefault(hEle: HELE; nHeight: Integer; nSelHeight: Integer); stdcall; external XCGUI_DLL;

procedure XTree_GetItemHeightDefault(hEle: HELE; out pHeight: Integer; out pSelHeight: Integer); stdcall; external XCGUI_DLL;

function XTree_GetTemplateObject(hEle: HELE; nID: Integer; nTempItemID: Integer): HXCGUI; stdcall; external XCGUI_DLL;

function XTree_GetItemIDFromHXCGUI(hEle: HELE; hXCGUI: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XTree_CreateAdapter(hEle: HELE): HXCGUI; stdcall; external XCGUI_DLL;

procedure XTree_BindAdapter(hEle: HELE; hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

function XTree_GetAdapter(hEle: HELE): HXCGUI; stdcall; external XCGUI_DLL;

procedure XTree_RefreshData(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XTree_RefreshItem(hEle: HELE; nID: Integer); stdcall; external XCGUI_DLL;

function XTree_InsertItemText(hEle: HELE; pValue: PWideChar; nParentID: Integer = XC_ID_ROOT; insertID: Integer = XC_ID_LAST): Integer; stdcall; external XCGUI_DLL;

function XTree_InsertItemTextEx(hEle: HELE; pName: PWideChar; pValue: PWideChar; nParentID: Integer = XC_ID_ROOT; insertID: Integer = XC_ID_LAST): Integer; stdcall; external XCGUI_DLL;

function XTree_InsertItemImage(hEle: HELE; hImage: HIMAGE; nParentID: Integer = XC_ID_ROOT; insertID: Integer = XC_ID_LAST): Integer; stdcall; external XCGUI_DLL;

function XTree_InsertItemImageEx(hEle: HELE; pName: PWideChar; hImage: HIMAGE; nParentID: Integer = XC_ID_ROOT; insertID: Integer = XC_ID_LAST): Integer; stdcall; external XCGUI_DLL;

function XTree_GetCount(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XTree_GetCountColumn(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XTree_SetItemText(hEle: HELE; nID: Integer; iColumn: Integer; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XTree_SetItemTextEx(hEle: HELE; nID: Integer; pName: PWideChar; pValue: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XTree_SetItemImage(hEle: HELE; nID: Integer; iColumn: Integer; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XTree_SetItemImageEx(hEle: HELE; nID: Integer; pName: PWideChar; hImage: HIMAGE): BOOL; stdcall; external XCGUI_DLL;

function XTree_GetItemText(hEle: HELE; nID: Integer; iColumn: Integer): PWideChar; stdcall; external XCGUI_DLL;

function XTree_GetItemTextEx(hEle: HELE; nID: Integer; pName: PWideChar): PWideChar; stdcall; external XCGUI_DLL;

function XTree_GetItemImage(hEle: HELE; nID: Integer; iColumn: Integer): HIMAGE; stdcall; external XCGUI_DLL;

function XTree_GetItemImageEx(hEle: HELE; nID: Integer; pName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XTree_DeleteItem(hEle: HELE; nID: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XTree_DeleteItemAll(hEle: HELE); stdcall; external XCGUI_DLL;

procedure XTree_DeleteColumnAll(hEle: HELE); stdcall; external XCGUI_DLL;

function XWnd_RegEventC(hWindow: HWINDOW; nEvent: Integer; pFun: Integer): BOOL; stdcall; external XCGUI_DLL;

function XWnd_RegEventC1(hWindow: HWINDOW; nEvent: Integer; pFun: Integer): BOOL; stdcall; external XCGUI_DLL;

function XWnd_RemoveEventC(hWindow: HWINDOW; nEvent: Integer; pFun: Integer): BOOL; stdcall; external XCGUI_DLL;

function XWnd_Create(x: Integer; y: Integer; cx: Integer; cy: Integer; pTitle: PWideChar; hWndParent: Integer = 0; XCStyle: window_style_ = window_style_default): HWINDOW; stdcall; external XCGUI_DLL;

function XWnd_AddChild(hWindow: HWINDOW; hChild: HXCGUI): BOOL; stdcall; external XCGUI_DLL;

function XWnd_InsertChild(hWindow: HWINDOW; hChild: HXCGUI; index: Integer): BOOL; stdcall; external XCGUI_DLL;

function XWnd_GetHWND(hWindow: HWINDOW): Integer; stdcall; external XCGUI_DLL;

procedure XWnd_EnableDragBorder(hWindow: HWINDOW; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XWnd_EnableDragWindow(hWindow: HWINDOW; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XWnd_EnableDragCaption(hWindow: HWINDOW; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XWnd_EnableDrawBk(hWindow: HWINDOW; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XWnd_EnableAutoFocus(hWindow: HWINDOW; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XWnd_EnableMaxWindow(hWindow: HWINDOW; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XWnd_EnableLimitWindowSize(hWindow: HWINDOW; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XWnd_EnableLayout(hWindow: HWINDOW; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XWnd_EnableLayoutOverlayBorder(hWindow: HWINDOW; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XWnd_ShowLayoutFrame(hWindow: HWINDOW; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XWnd_IsEnableLayout(hWindow: HWINDOW): BOOL; stdcall; external XCGUI_DLL;

function XWnd_IsMaxWindow(hWindow: HWINDOW): BOOL; stdcall; external XCGUI_DLL;

procedure XWnd_Redraw(hWindow: HWINDOW; bImmediate: BOOL = FALSE); stdcall; external XCGUI_DLL;

procedure XWnd_RedrawRect(hWindow: HWINDOW; var Rect: TRect; bImmediate: BOOL = FALSE); stdcall; external XCGUI_DLL;

procedure XWnd_SetFocusEle(hWindow: HWINDOW; hFocusEle: HELE); stdcall; external XCGUI_DLL;

function XWnd_GetFocusEle(hWindow: HWINDOW): HELE; stdcall; external XCGUI_DLL;

function XWnd_GetStayEle(hWindow: HWINDOW): HELE; stdcall; external XCGUI_DLL;

procedure XWnd_DrawWindow(hWindow: HWINDOW; hDraw: HDRAW); stdcall; external XCGUI_DLL;

procedure XWnd_Center(hWindow: HWINDOW); stdcall; external XCGUI_DLL;

procedure XWnd_CenterEx(hWindow: HWINDOW; width: Integer; height: Integer); stdcall; external XCGUI_DLL;

procedure XWnd_SetCursor(hWindow: HWINDOW; hCursor: HCURSOR); stdcall; external XCGUI_DLL;

function XWnd_GetCursor(hWindow: HWINDOW): HCURSOR; stdcall; external XCGUI_DLL;

function XWnd_SetCursorSys(hWindow: HWINDOW; hCursor: HCURSOR): HCURSOR; stdcall; external XCGUI_DLL;

procedure XWnd_SetFont(hWindow: HWINDOW; hFontx: HFONTX); stdcall; external XCGUI_DLL;

procedure XWnd_SetTextColor(hWindow: HWINDOW; color: Integer); stdcall; external XCGUI_DLL;

function XWnd_GetTextColor(hWindow: HWINDOW): Integer; stdcall; external XCGUI_DLL;

function XWnd_GetTextColorEx(hWindow: HWINDOW): Integer; stdcall; external XCGUI_DLL;

procedure XWnd_SetID(hWindow: HWINDOW; nID: Integer); stdcall; external XCGUI_DLL;

function XWnd_GetID(hWindow: HWINDOW): Integer; stdcall; external XCGUI_DLL;

procedure XWnd_SetName(hWindow: HWINDOW; pName: PWideChar); stdcall; external XCGUI_DLL;

function XWnd_GetName(hWindow: HWINDOW): PWideChar; stdcall; external XCGUI_DLL;

procedure XWnd_SetCaptureEle(hWindow: HWINDOW; hEle: HELE); stdcall; external XCGUI_DLL;

function XWnd_GetCaptureEle(hWindow: HWINDOW): HELE; stdcall; external XCGUI_DLL;

procedure XWnd_SetBorderSize(hWindow: HWINDOW; left: Integer; top: Integer; right: Integer; bottom: Integer); stdcall; external XCGUI_DLL;

procedure XWnd_GetBorderSize(hWindow: HWINDOW; out pBorder: TborderSize_); stdcall; external XCGUI_DLL;

procedure XWnd_SetPadding(hWindow: HWINDOW; left: Integer; top: Integer; right: Integer; bottom: Integer); stdcall; external XCGUI_DLL;

procedure XWnd_GetPadding(hWindow: HWINDOW; out pPadding: TpaddingSize_); stdcall; external XCGUI_DLL;

procedure XWnd_SetDragBorderSize(hWindow: HWINDOW; left: Integer; top: Integer; right: Integer; bottom: Integer); stdcall; external XCGUI_DLL;

procedure XWnd_GetDragBorderSize(hWindow: HWINDOW; out pSize: TborderSize_); stdcall; external XCGUI_DLL;

procedure XWnd_SetMinimumSize(hWindow: HWINDOW; width: Integer; height: Integer); stdcall; external XCGUI_DLL;

function XWnd_HitChildEle(hWindow: HWINDOW; var pPt: TPoint): HELE; stdcall; external XCGUI_DLL;

function XWnd_GetChildCount(hWindow: HWINDOW): Integer; stdcall; external XCGUI_DLL;

function XWnd_GetChildByIndex(hWindow: HWINDOW; index: Integer): HXCGUI; stdcall; external XCGUI_DLL;

function XWnd_GetChildByID(hWindow: HWINDOW; nID: Integer): HXCGUI; stdcall; external XCGUI_DLL;

function XWnd_GetChild(hWindow: HWINDOW; nID: Integer): HXCGUI; stdcall; external XCGUI_DLL;

procedure XWnd_GetDrawRect(hWindow: HWINDOW; var pRcPaint: TRect); stdcall; external XCGUI_DLL;

function XWnd_ShowWindow(hWindow: HWINDOW; nCmdShow: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XWnd_AdjustLayout(hWindow: HWINDOW); stdcall; external XCGUI_DLL;

procedure XWnd_AdjustLayoutEx(hWindow: HWINDOW; nFlags: Integer = adjustLayout_self); stdcall; external XCGUI_DLL;

procedure XWnd_CloseWindow(hWindow: HWINDOW); stdcall; external XCGUI_DLL;

procedure XWnd_CreateCaret(hWindow: HWINDOW; hEle: HELE; x: Integer; y: Integer; width: Integer; height: Integer); stdcall; external XCGUI_DLL;

function XWnd_GetCaretHELE(hWindow: HWINDOW): HELE; stdcall; external XCGUI_DLL;

procedure XWnd_SetCaretColor(hWindow: HWINDOW; color: Integer); stdcall; external XCGUI_DLL;

procedure XWnd_ShowCaret(hWindow: HWINDOW; bShow: BOOL); stdcall; external XCGUI_DLL;

procedure XWnd_DestroyCaret(hWindow: HWINDOW); stdcall; external XCGUI_DLL;

procedure XWnd_SetCaretPos(hWindow: HWINDOW; x: Integer; y: Integer; width: Integer; height: Integer; bUpdate: BOOL = FALSE); stdcall; external XCGUI_DLL;

function XWnd_GetCaretInfo(hWindow: HWINDOW; var pX: Integer; var pY: Integer; var Width: Integer; var Height: Integer): HELE; stdcall; external XCGUI_DLL;

function XWnd_GetClientRect(hWindow: HWINDOW; out Rect: TRect): BOOL; stdcall; external XCGUI_DLL;

procedure XWnd_GetBodyRect(hWindow: HWINDOW; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XWnd_GetLayoutRect(hWindow: HWINDOW; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XWnd_GetRect(hWindow: HWINDOW; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XWnd_SetRect(hWindow: HWINDOW; var Rect: TRect); stdcall; external XCGUI_DLL;

procedure XWnd_SetTop(hWindow: HWINDOW); stdcall; external XCGUI_DLL;

procedure XWnd_MaxWindow(hWindow: HWINDOW; bMaximize: BOOL); stdcall; external XCGUI_DLL;

function XWnd_SetTimer(hWindow: HWINDOW; nIDEvent: UINT; uElapse: UINT): UINT; stdcall; external XCGUI_DLL;

function XWnd_KillTimer(hWindow: HWINDOW; nIDEvent: UINT): BOOL; stdcall; external XCGUI_DLL;

function XWnd_SetXCTimer(hWindow: HWINDOW; nIDEvent: UINT; uElapse: UINT): UINT; stdcall; external XCGUI_DLL;

function XWnd_KillXCTimer(hWindow: HWINDOW; nIDEvent: UINT): BOOL; stdcall; external XCGUI_DLL;

function XWnd_GetBkManager(hWindow: HWINDOW): HBKM; stdcall; external XCGUI_DLL;

function XWnd_GetBkManagerEx(hWindow: HWINDOW): HBKM; stdcall; external XCGUI_DLL;

procedure XWnd_SetBkMagager(hWindow: HWINDOW; hBkInfoM: HBKM); stdcall; external XCGUI_DLL;

procedure XWnd_SetTransparentType(hWindow: HWINDOW; nType: window_transparent_); stdcall; external XCGUI_DLL;

procedure XWnd_SetTransparentAlpha(hWindow: HWINDOW; alpha: BYTE); stdcall; external XCGUI_DLL;

procedure XWnd_SetTransparentColor(hWindow: HWINDOW; color: Integer); stdcall; external XCGUI_DLL;

procedure XWnd_SetShadowInfo(hWindow: HWINDOW; nSize: Integer; nDepth: Integer; nAngeleSize: Integer; bRightAngle: BOOL; color: Integer); stdcall; external XCGUI_DLL;

function XWnd_GetTransparentType(hWindow: HWINDOW): window_transparent_; stdcall; external XCGUI_DLL;

procedure XWnd_GetShadowInfo(hWindow: HWINDOW; var pnSize: Integer; var pnDepth: Integer; var pnAngeleSize: Integer; var pbRightAngle: BOOL; var pColor: Integer); stdcall; external XCGUI_DLL;

//布局
procedure XWidget_LayoutItem_EnableWrap(hXCGUI: HXCGUI; bWrap: BOOL); stdcall; external XCGUI_DLL;

procedure XWidget_LayoutItem_EnableSwap(hXCGUI: HXCGUI; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XWidget_LayoutItem_EnableFloat(hXCGUI: HXCGUI; bFloat: BOOL); stdcall; external XCGUI_DLL;

procedure XWidget_LayoutItem_SetWidth(hXCGUI: HXCGUI; nType: layout_size_; nWidth: Integer); stdcall; external XCGUI_DLL;

procedure XWidget_LayoutItem_SetHeight(hXCGUI: HXCGUI; nType: layout_size_; nHeight: Integer); stdcall; external XCGUI_DLL;

procedure XWidget_LayoutItem_GetWidth(hXCGUI: HXCGUI; var pType: layout_size_; var pWidth: Integer); stdcall; external XCGUI_DLL;

procedure XWidget_LayoutItem_GetHeight(hXCGUI: HXCGUI; var pType: layout_size_; var pHeight: Integer); stdcall; external XCGUI_DLL;

procedure XWidget_LayoutItem_SetAlign(hXCGUI: HXCGUI; nAlign: layout_align_axis_); stdcall; external XCGUI_DLL;

procedure XWidget_LayoutItem_SetMargin(hXCGUI: HXCGUI; left, top, right, bottom: Integer); stdcall; external XCGUI_DLL;

procedure XWidget_LayoutItem_GetMargin(hXCGUI: HXCGUI; var pMargin: TmarginSize_); stdcall; external XCGUI_DLL;

procedure XWidget_LayoutItem_SetMinSize(hXCGUI: HXCGUI; width, height: Integer); stdcall; external XCGUI_DLL;

procedure XWidget_LayoutItem_SetPosition(hXCGUI: HXCGUI; left, top, right, bottom: Integer); stdcall; external XCGUI_DLL;

function XWnd_Attach(hWnd: Integer; XCStyle: Integer): HWINDOW; stdcall; external XCGUI_DLL;

function XModalWnd_Attach(hWnd: Integer; XCStyle: Integer): HWINDOW; stdcall; external XCGUI_DLL;

function XFrameWnd_Attach(hWnd: Integer; XCStyle: Integer): HWINDOW; stdcall; external XCGUI_DLL;

procedure XWnd_EnableDragFiles(hWindow: HWINDOW; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XMenuBar_GetButton(hEle: HELE; nIndex: Integer): HELE; stdcall; external XCGUI_DLL;

procedure XObj_SetTypeEx(hXCGUI: HXCGUI; nType: XC_OBJECT_TYPE_EX); stdcall; external XCGUI_DLL;

procedure XWnd_Show(hWindow: HWINDOW; bShow: BOOL); stdcall; external XCGUI_DLL;

procedure XProgBar_EnableShowText(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XWidget_SetID(hXCGUI: HXCGUI; nID: Integer); stdcall; external XCGUI_DLL;

function XWidget_GetID(hXCGUI: HXCGUI): Integer; stdcall; external XCGUI_DLL;

procedure XWidget_SetUID(hXCGUI: HXCGUI; nUID: Integer); stdcall; external XCGUI_DLL;

function XWidget_GetUID(hXCGUI: HXCGUI): Integer; stdcall; external XCGUI_DLL;

procedure XWidget_SetName(hXCGUI: HXCGUI; pName: PWideChar); stdcall; external XCGUI_DLL;

function XWidget_GetName(hXCGUI: HXCGUI): PWideChar; stdcall; external XCGUI_DLL;

function XDraw_Create(hWindow: HWINDOW): HDRAW; stdcall; external XCGUI_DLL; //创建

function XDraw_CreateGDI(hWindow: HWINDOW; hdc: HDC): HDRAW; stdcall; external XCGUI_DLL;

procedure XDraw_Destroy(hDraw: HDRAW); stdcall; external XCGUI_DLL; //销毁

procedure XDraw_SetOffset(hDraw: HDRAW; x, y: Integer); stdcall; external XCGUI_DLL; //设置坐标偏移量

procedure XDraw_GetOffset(hDraw: HDRAW; var pX, pY: Integer); stdcall; external XCGUI_DLL; //获取坐标偏移量

function XDraw_GetHDC(hDraw: HDRAW): HDC; stdcall; external XCGUI_DLL;

procedure XDraw_SetBrushColor(hDraw: HDRAW; color: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_SetTextAlign(hDraw: HDRAW; nFlag: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_SetTextVertical(hDraw: HDRAW; bVertical: BOOL); stdcall; external XCGUI_DLL;

procedure XDraw_SetFont(hDraw: HDRAW; hFontx: HFONTX); stdcall; external XCGUI_DLL;

procedure XDraw_SetLineWidth(hDraw: HDRAW; width: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_SetLineWidthF(hDraw: HDRAW; width: Single); stdcall; external XCGUI_DLL;

procedure XDraw_SetCliRect(hDraw: HDRAW; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XDraw_ClearClip(hDraw: HDRAW); stdcall; external XCGUI_DLL;

procedure XDraw_EnableSmoothingMode(hDraw: HDRAW; bEnable: BOOL); stdcall; external XCGUI_DLL;   //启用平滑模式

procedure XDraw_EnableWndTransparent(hDraw: HDRAW; bTransparent: BOOL); stdcall; external XCGUI_DLL;

//GDI:
procedure XDraw_GDI_RestoreGDIOBJ(hDraw: HDRAW); stdcall; external XCGUI_DLL;  //还原状态,释放用户绑定的GDI对象

function XDraw_GDI_SetBkMode(hDraw: HDRAW; bTransparent: BOOL): Integer; stdcall; external XCGUI_DLL;

function XDraw_GDI_SelectClipRgn(hDraw: HDRAW; hRgn: HRGN): Integer; stdcall; external XCGUI_DLL;

function XDraw_GDI_CreateSolidBrush(hDraw: HDRAW; crColor: Integer): HBRUSH; stdcall; external XCGUI_DLL;

function XDraw_GDI_CreatePen(hDraw: HDRAW; fnPenStyle, width: Integer; crColor: Integer): HPEN; stdcall; external XCGUI_DLL;

function XDraw_GDI_CreateRectRgn(hDraw: HDRAW; nLeftRect, nTopRect, nRightRect, nBottomRect: Integer): HRGN; stdcall; external XCGUI_DLL;

function XDraw_GDI_CreateRoundRectRgn(hDraw: HDRAW; nLeftRect, nTopRect, nRightRect, nBottomRect, nWidthEllipse, nHeightEllipse: Integer): HRGN; stdcall; external XCGUI_DLL;

function XDraw_GDI_CreatePolygonRgn(hDraw: HDRAW; pPt: PPOINT; cPoints: Integer; fnPolyFillMode: Integer): HRGN; stdcall; external XCGUI_DLL;

function XDraw_GDI_Rectangle(hDraw: HDRAW; nLeftRect, nTopRect, nRightRect, nBottomRect: Integer): BOOL; stdcall; external XCGUI_DLL;

function XDraw_GDI_FillRgn(hDraw: HDRAW; hrgn: HRGN; hbr: HBRUSH): BOOL; stdcall; external XCGUI_DLL;

function XDraw_GDI_Ellipse(hDraw: HDRAW; var Rect: TRect): BOOL; stdcall; external XCGUI_DLL;

function XDraw_GDI_FrameRgn(hDraw: HDRAW; hrgn: HRGN; hbr: HBRUSH; width, nHeight: Integer): BOOL; stdcall; external XCGUI_DLL;

function XDraw_GDI_MoveToEx(hDraw: HDRAW; X, Y: Integer; pPoint: PPOINT): BOOL; stdcall; external XCGUI_DLL;

function XDraw_GDI_LineTo(hDraw: HDRAW; nXEnd, nYEnd: Integer): BOOL; stdcall; external XCGUI_DLL;

function XDraw_GDI_Polyline(hDraw: HDRAW; pArrayPt: PPOINT; arrayPtSize: Integer): BOOL; stdcall; external XCGUI_DLL;

function XDraw_GDI_DrawIconEx(hDraw: HDRAW; xLeft, yTop: Integer; hIcon: HICON; cxWidth, cyWidth: Integer; istepIfAniCur: UINT; hbrFlickerFreeDraw: HBRUSH; diFlags: UINT): BOOL; stdcall; external XCGUI_DLL;

function XDraw_GDI_BitBlt(hDrawDest: HDRAW; nXDest, nYDest, width, nHeight: Integer; hdcSrc: HDC; nXSrc, nYSrc: Integer; dwRop: DWORD): BOOL; stdcall; external XCGUI_DLL;

function XDraw_GDI_BitBlt2(hDrawDest: HDRAW; nXDest, nYDest, width, nHeight: Integer; hDrawSrc: HDRAW; nXSrc, nYSrc: Integer; dwRop: DWORD): BOOL; stdcall; external XCGUI_DLL;

function XDraw_GDI_AlphaBlend(hDraw: HDRAW; nXOriginDest, nYOriginDest, nWidthDest, nHeightDest: Integer; hdcSrc: HDC; nXOriginSrc, nYOriginSrc, nWidthSrc, nHeightSrc: Integer; alpha: Integer): BOOL; stdcall; external XCGUI_DLL;

function XDraw_GDI_SetPixel(hDraw: HDRAW; X, Y: Integer; crColor: Integer): Integer; stdcall; external XCGUI_DLL;

//-----------------
procedure XDraw_FillRect(hDraw: HDRAW; var Rect: TRect); stdcall; external XCGUI_DLL;

procedure XDraw_FillRectF(hDraw: HDRAW; var Rect: TRectF); stdcall; external XCGUI_DLL;

procedure XDraw_FillRectColor(hDraw: HDRAW; var Rect: TRect; color: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_FillRectColorF(hDraw: HDRAW; var Rect: TRectF; color: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_DrawRect(hDraw: HDRAW; var Rect: TRect); stdcall; external XCGUI_DLL;

procedure XDraw_DrawRectF(hDraw: HDRAW; var Rect: TRectF); stdcall; external XCGUI_DLL;

procedure XDraw_FillEllipse(hDraw: HDRAW; var Rect: TRect); stdcall; external XCGUI_DLL;

procedure XDraw_FillEllipseF(hDraw: HDRAW; var Rect: TRectF); stdcall; external XCGUI_DLL;

procedure XDraw_DrawEllipse(hDraw: HDRAW; var Rect: TRect); stdcall; external XCGUI_DLL;

procedure XDraw_DrawEllipseF(hDraw: HDRAW; var Rect: TRectF); stdcall; external XCGUI_DLL;

procedure XDraw_FillRoundRect(hDraw: HDRAW; var Rect: TRect; width: Integer; nHeight: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_FillRoundRectF(hDraw: HDRAW; var Rect: TRectF; width: Single; height: Single); stdcall; external XCGUI_DLL;

procedure XDraw_DrawRoundRect(hDraw: HDRAW; var Rect: TRect; width: Integer; nHeight: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_DrawRoundRectF(hDraw: HDRAW; var Rect: TRectF; width: Single; height: Single); stdcall; external XCGUI_DLL;

procedure XDraw_FillRoundRectEx(hDraw: HDRAW; var Rect: TRect; leftTop: Integer; rightTop: Integer; rightBottom: Integer; leftBottom: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_FillRoundRectExF(hDraw: HDRAW; var Rect: TRectF; leftTop: Single; rightTop: Single; rightBottom: Single; leftBottom: Single); stdcall; external XCGUI_DLL;

procedure XDraw_DrawRoundRectEx(hDraw: HDRAW; var Rect: TRect; leftTop: Integer; rightTop: Integer; rightBottom: Integer; leftBottom: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_GradientFill2F(hDraw: HDRAW; var Rect: TRectF; color1: Integer; color2: Integer; mode: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_GradientFill4(hDraw: HDRAW; var Rect: TRect; color1: Integer; color2: Integer; color3: Integer; color4: Integer; mode: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_GradientFill4F(hDraw: HDRAW; var Rect: TRectF; color1: Integer; color2: Integer; color3: Integer; color4: Integer; mode: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_FocusRect(hDraw: HDRAW; var Rect: TRect); stdcall; external XCGUI_DLL;

procedure XDraw_FocusRectF(hDraw: HDRAW; var Rect: TRectF); stdcall; external XCGUI_DLL;

procedure XDraw_DrawLine(hDraw: HDRAW; x1: Integer; y1: Integer; x2: Integer; y2: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_DrawLineF(hDraw: HDRAW; x1: Single; y1: Single; x2: Single; y2: Single); stdcall; external XCGUI_DLL;

procedure XDraw_Dottedline(hDraw: HDRAW; x1: Integer; y1: Integer; x2: Integer; y2: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_DottedlineF(hDraw: HDRAW; x1: Single; y1: Single; x2: Single; y2: Single); stdcall; external XCGUI_DLL;

procedure XDraw_DrawCurve(hDraw: HDRAW; points: PPOINT; count: Integer; tension: Single); stdcall; external XCGUI_DLL;

procedure XDraw_DrawCurveF(hDraw: HDRAW; points: PPOINTF; count: Integer; tension: Single); stdcall; external XCGUI_DLL;

// 绘制圆弧
procedure XDraw_DrawArc(hDraw: HDRAW; x: Integer; y: Integer; width: Integer; nHeight: Integer; startAngle: Single; sweepAngle: Single); stdcall; external XCGUI_DLL;

procedure XDraw_DrawArcF(hDraw: HDRAW; x: Single; y: Single; width: Single; height: Single; startAngle: Single; sweepAngle: Single); stdcall; external XCGUI_DLL;

// 绘制多边形
procedure XDraw_DrawPolygon(hDraw: HDRAW; points: PPOINT; nCount: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_DrawPolygonF(hDraw: HDRAW; points: PPOINTF; nCount: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_FillPolygon(hDraw: HDRAW; points: PPOINT; nCount: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_FillPolygonF(hDraw: HDRAW; points: PPOINTF; nCount: Integer); stdcall; external XCGUI_DLL;

// 图片
procedure XDraw_Image(hDraw: HDRAW; hImageFrame: HIMAGE; x: Integer; y: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_ImageF(hDraw: HDRAW; hImageFrame: HIMAGE; x: Single; y: Single); stdcall; external XCGUI_DLL;

procedure XDraw_ImageEx(hDraw: HDRAW; hImageFrame: HIMAGE; x: Integer; y: Integer; width: Integer; height: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_ImageExF(hDraw: HDRAW; hImageFrame: HIMAGE; x: Single; y: Single; width: Single; height: Single); stdcall; external XCGUI_DLL;

procedure XDraw_ImageAdaptive(hDraw: HDRAW; hImageFrame: HIMAGE; var Rect: TRect; bOnlyBorder: BOOL = FALSE); stdcall; external XCGUI_DLL;

procedure XDraw_ImageAdaptiveF(hDraw: HDRAW; hImageFrame: HIMAGE; var Rect: TRectF; bOnlyBorder: BOOL = FALSE); stdcall; external XCGUI_DLL;

// 从左下角往右上角铺，现在平铺区域
// flag: 平板类型，0 左上角，1 左左下角
procedure XDraw_ImageTile(hDraw: HDRAW; hImageFrame: HIMAGE; var Rect: TRect; flag: Integer = 0); stdcall; external XCGUI_DLL;

procedure XDraw_ImageTileF(hDraw: HDRAW; hImageFrame: HIMAGE; var Rect: TRectF; flag: Integer = 0); stdcall; external XCGUI_DLL;

procedure XDraw_ImageSuper(hDraw: HDRAW; hImageFrame: HIMAGE; var Rect: TRect; bClip: BOOL = FALSE); stdcall; external XCGUI_DLL;

procedure XDraw_ImageSuperF(hDraw: HDRAW; hImageFrame: HIMAGE; var Rect: TRectF; bClip: BOOL = FALSE); stdcall; external XCGUI_DLL;

procedure XDraw_ImageSuperEx(hDraw: HDRAW; hImageFrame: HIMAGE; var pRcDest: TRect; var pRcSrc: TRect); stdcall; external XCGUI_DLL;

procedure XDraw_ImageSuperExF(hDraw: HDRAW; hImageFrame: HIMAGE; pRcDest: TRectF; pRcSrc: TRectF); stdcall; external XCGUI_DLL;

procedure XDraw_ImageSuperMask(hDraw: HDRAW; hImageFrame: HIMAGE; hImageFrameMask: HIMAGE; var Rect: TRect; var RectMask: TRect; bClip: BOOL = FALSE); stdcall; external XCGUI_DLL;

// 文本
procedure XDraw_DrawText(hDraw: HDRAW; pString: PWideChar; nCount: Integer; var Rect: TRect); stdcall; external XCGUI_DLL;

procedure XDraw_DrawTextF(hDraw: HDRAW; pString: PWideChar; nCount: Integer; var Rect: TRectF); stdcall; external XCGUI_DLL;

procedure XDraw_DrawTextUnderline(hDraw: HDRAW; pString: PWideChar; nCount: Integer; var Rect: TRect; colorLine: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_DrawTextUnderlineF(hDraw: HDRAW; pString: PWideChar; nCount: Integer; var Rect: TRectF; colorLine: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_TextOut(hDraw: HDRAW; xStart: Integer; yStart: Integer; pString: PWideChar; cbString: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_TextOutF(hDraw: HDRAW; xStart: Single; yStart: Single; pString: PWideChar; cbString: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_TextOutEx(hDraw: HDRAW; xStart: Integer; yStart: Integer; pString: PWideChar); stdcall; external XCGUI_DLL;

procedure XDraw_TextOutExF(hDraw: HDRAW; xStart: Single; yStart: Single; pString: PWideChar); stdcall; external XCGUI_DLL;

procedure XDraw_TextOutA(hDraw: HDRAW; xStart: Integer; yStart: Integer; pString: PChar); stdcall; external XCGUI_DLL;

procedure XDraw_TextOutAF(hDraw: HDRAW; xStart: Single; yStart: Single; pString: PChar); stdcall; external XCGUI_DLL;

// v3.1.1
procedure XWnd_SetIcon(hWindow: HWINDOW; hImage: HIMAGE); stdcall; external XCGUI_DLL;

procedure XWnd_SetTitle(hWindow: HWINDOW; pTitle: PWideChar); stdcall; external XCGUI_DLL;

procedure XWnd_SetTitleColor(hWindow: HWINDOW; color: Integer); stdcall; external XCGUI_DLL;

function XWnd_GetButton(hWindow: HWINDOW; nFlag: Integer): HELE; stdcall; external XCGUI_DLL;

function XWnd_GetIcon(hWindow: HWINDOW): HIMAGE; stdcall; external XCGUI_DLL;

function XWnd_GetTitle(hWindow: HWINDOW): PWideChar; stdcall; external XCGUI_DLL;

function XWnd_GetTitleColor(hWindow: HWINDOW): Integer; stdcall; external XCGUI_DLL;

function XC_GetD2dFactory(): vint; stdcall; external XCGUI_DLL;

function XC_GetWicFactory(): vint; stdcall; external XCGUI_DLL;

function XC_GetDWriteFactory(): vint; stdcall; external XCGUI_DLL;

procedure XC_SetD2dTextRenderingMode(mode: XC_DWRITE_RENDERING_MODE); stdcall; external XCGUI_DLL;

function XDraw_GetD2dRenderTarget(hDraw: HDRAW): vint; stdcall; external XCGUI_DLL;

function XDraw_GetD2dWriteFactory(hDraw: HDRAW): vint; stdcall; external XCGUI_DLL;

procedure XDraw_SetD2dTextRenderingMode(hDraw: HDRAW; mode: XC_DWRITE_RENDERING_MODE); stdcall; external XCGUI_DLL;

function XLayoutFrame_CreateEx(hParent: HXCGUI): HELE; stdcall; external XCGUI_DLL;

procedure XLayoutFrame_EnableLayout(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XLayoutFrame_IsEnableLayout(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XLayoutFrame_GetWidthIn(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XLayoutFrame_GetHeightIn(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XDraw_SetTextRenderingHint(hDraw: HDRAW; nType: Integer); stdcall; external XCGUI_DLL;

function XFont_CreateFromMem(data: Integer; length: UINT; fontSize: Integer = 12; style: fontStyle_ = fontStyle_regular): HFONTX; stdcall; external XCGUI_DLL;

procedure XComboBox_PopupDropList(hEle: HELE); stdcall; external XCGUI_DLL;

function XComboBox_SetItemTemplate(hEle: HELE; hTemp: HTEMP): BOOL; stdcall; external XCGUI_DLL;

function XC_IsEnableD2D(): BOOL; stdcall; external XCGUI_DLL;

function XFont_CreateFromRes(id: Integer; pType: PWideChar; fontSize: Integer; style: Integer; hModule: Integer = 0): HFONTX; stdcall; external XCGUI_DLL;

function XC_MessageBox(pTitle: PWideChar; pText: PWideChar; nFlags: Integer; hWndParent: Integer = 0; XCStyle: window_style_ = window_style_modal): Integer; stdcall; external XCGUI_DLL;

function XMsg_Create(pTitle: PWideChar; pText: PWideChar; nFlags: Integer; hWndParent: Integer = 0; XCStyle: window_style_ = window_style_modal): HWINDOW; stdcall; external XCGUI_DLL;

// 3.2.0--------------------------
// 修改:
function XC_LoadStyleFromStringW(pString: PWideChar; pFileName: PWideChar): BOOL; stdcall; external XCGUI_DLL;
// 增加:

function XC_LoadStyleFromString(pString: PChar; pFileName: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XC_LoadStyleFromStringUtf8(pString: PChar; pFileName: PWideChar): BOOL; stdcall; external XCGUI_DLL;

function XImage_LoadSvg(hSvg: HSVG): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadSvgFile(pFileName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_GetSvg(hImage: HIMAGE): HSVG; stdcall; external XCGUI_DLL;

// SVG 合并到 3.3.0

procedure XDraw_DrawSvgSrc(hDraw: HDRAW; hSvg: HSVG); stdcall; external XCGUI_DLL;

procedure XDraw_DrawSvg(hDraw: HDRAW; hSvg: HSVG; x: Integer; y: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_DrawSvgEx(hDraw: HDRAW; hSvg: HSVG; x: Integer; y: Integer; nWidth: Integer; nHeight: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_DrawSvgSize(hDraw: HDRAW; hSvg: HSVG; nWidth: Integer; nHeight: Integer); stdcall; external XCGUI_DLL;

procedure XC_ShowSvgFrame(bShow: BOOL); stdcall; external XCGUI_DLL;

procedure XWnd_AddBkBorder(hWindow: HWINDOW; nState: Integer; color: Integer; width: Integer); stdcall; external XCGUI_DLL;

procedure XWnd_AddBkFill(hWindow: HWINDOW; nState: Integer; color: Integer); stdcall; external XCGUI_DLL;

procedure XWnd_AddBkImage(hWindow: HWINDOW; nState: Integer; hImage: HIMAGE); stdcall; external XCGUI_DLL;

function XWnd_GetBkInfoCount(hWindow: HWINDOW): Integer; stdcall; external XCGUI_DLL;

procedure XWnd_ClearBkInfo(hWindow: HWINDOW); stdcall; external XCGUI_DLL;


// 3.3.0----------------------------------------

// 移除:
// XEle_Move
// XEle_MoveLogic
// XShape_Move
// XSvg_GetOffset
// XSvg_SetOffset
// XWnd_Move
// XSvg_LoadString
// XImage_LoadSvgString

// 增加:
procedure XWnd_SetPosition(hWindow: HWINDOW; x: Integer; y: Integer); stdcall; external XCGUI_DLL;

function XEle_SetPosition(hEle: HELE; x: Integer; y: Integer; bRedraw: BOOL = FALSE; nFlags: Integer = adjustLayout_all; nAdjustNo: UINT = 0): Integer; stdcall; external XCGUI_DLL;

function XEle_SetPositionLogic(hEle: HELE; x: Integer; y: Integer; bRedraw: BOOL = FALSE; nFlags: Integer = adjustLayout_all; nAdjustNo: UINT = 0): Integer; stdcall; external XCGUI_DLL;

procedure XEle_GetPosition(hEle: HELE; pOutX: PInteger; pOutY: PInteger); stdcall; external XCGUI_DLL;

function XEle_SetSize(hEle: HELE; nWidth: Integer; nHeight: Integer; bRedraw: BOOL = FALSE; nFlags: Integer = adjustLayout_all; nAdjustNo: UINT = 0): Integer; stdcall; external XCGUI_DLL;

procedure XEle_GetSize(hEle: HELE; out pOutWidth: Integer; out pOutHeight: Integer); stdcall; external XCGUI_DLL;

procedure XShape_SetPosition(hShape: HXCGUI; x: Integer; y: Integer); stdcall; external XCGUI_DLL;

procedure XShape_GetPosition(hShape: HXCGUI; out pOutX: Integer; out pOutY: Integer); stdcall; external XCGUI_DLL;

procedure XShape_SetSize(hShape: HXCGUI; nWidth: Integer; nHeight: Integer); stdcall; external XCGUI_DLL;

procedure XShape_GetSize(hShape: HXCGUI; pOutWidth: PInteger; pOutHeight: PInteger); stdcall; external XCGUI_DLL;

procedure XShape_SetAlpha(hShape: HXCGUI; alpha: BYTE); stdcall; external XCGUI_DLL;

function XShape_GetAlpha(hShape: HXCGUI): BYTE; stdcall; external XCGUI_DLL;

function XImage_LoadSvgString(pString: PChar): HIMAGE; stdcall; external XCGUI_DLL; // 修改

function XImage_LoadSvgStringW(pString: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XImage_LoadSvgStringUtf8(pString: PChar): HIMAGE; stdcall; external XCGUI_DLL;

function XEase_Ex(pos: Single; flag: Integer): Single; stdcall; external XCGUI_DLL;

// -----SVG---------------------------------------------------------------
function XSvg_LoadFile(pFileName: PWideChar): HSVG; stdcall; external XCGUI_DLL;

function XSvg_LoadString(pString: PChar): HSVG; stdcall; external XCGUI_DLL;

function XSvg_LoadStringW(pString: PWideChar): HSVG; stdcall; external XCGUI_DLL;

function XSvg_LoadStringUtf8(pString: PChar): HSVG; stdcall; external XCGUI_DLL;

function XSvg_LoadZip(pZipFileName: PWideChar; pFileName: PWideChar; pPassword: PWideChar = nil): HSVG; stdcall; external XCGUI_DLL;

function XSvg_LoadRes(id: Integer; pType: PWideChar; hModule: Integer = 0): HSVG; stdcall; external XCGUI_DLL;

procedure XSvg_SetSize(hSvg: HSVG; nWidth: Integer; nHeight: Integer); stdcall; external XCGUI_DLL;

procedure XSvg_GetSize(hSvg: HSVG; out pWidth: Integer; out pHeight: Integer); stdcall; external XCGUI_DLL;

function XSvg_GetWidth(hSvg: HSVG): Integer; stdcall; external XCGUI_DLL;

function XSvg_GetHeight(hSvg: HSVG): Integer; stdcall; external XCGUI_DLL;

procedure XSvg_SetPosition(hSvg: HSVG; x: Integer; y: Integer); stdcall; external XCGUI_DLL;

procedure XSvg_GetPosition(hSvg: HSVG; out pX: Integer; out pY: Integer); stdcall; external XCGUI_DLL;

procedure XSvg_SetPositionF(hSvg: HSVG; x: Single; y: Single); stdcall; external XCGUI_DLL;

procedure XSvg_GetPositionF(hSvg: HSVG; out pX: Single; out pY: Single); stdcall; external XCGUI_DLL;

procedure XSvg_GetViewBox(hSvg: HSVG; out pViewBox: TRect); stdcall; external XCGUI_DLL;

procedure XSvg_SetAlpha(hSvg: HSVG; alpha: BYTE); stdcall; external XCGUI_DLL;

function XSvg_GetAlpha(hSvg: HSVG): BYTE; stdcall; external XCGUI_DLL;

procedure XSvg_SetUserFillColor(hSvg: HSVG; color: Integer; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XSvg_SetUserStrokeColor(hSvg: HSVG; color: Integer; strokeWidth: Single; bEnable: BOOL); stdcall; external XCGUI_DLL;

function XSvg_GetUserFillColor(hSvg: HSVG; out pColor: Integer): BOOL; stdcall; external XCGUI_DLL;

function XSvg_GetUserStrokeColor(hSvg: HSVG; out pColor: Integer; out pStrokeWidth: Single): BOOL; stdcall; external XCGUI_DLL;

procedure XSvg_SetRotateAngle(hSvg: HSVG; angle: Single); stdcall; external XCGUI_DLL;

function XSvg_GetRotateAngle(hSvg: HSVG): Single; stdcall; external XCGUI_DLL;

procedure XSvg_SetRotate(hSvg: HSVG; angle: Single; x: Single; y: Single; bOffset: BOOL = FALSE); stdcall; external XCGUI_DLL;

procedure XSvg_GetRotate(hSvg: HSVG; out pAngle: Single; out pX: Single; out pY: Single; out pbOffset: BOOL); stdcall; external XCGUI_DLL;

procedure XSvg_Show(hSvg: HSVG; bShow: BOOL); stdcall; external XCGUI_DLL;

procedure XSvg_EnableAutoDestroy(hSvg: HSVG; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XSvg_AddRef(hSvg: HSVG); stdcall; external XCGUI_DLL;

procedure XSvg_Release(hSvg: HSVG); stdcall; external XCGUI_DLL;

function XSvg_GetRefCount(hSvg: HSVG): Integer; stdcall; external XCGUI_DLL;

procedure XSvg_Destroy(hSvg: HSVG); stdcall; external XCGUI_DLL;

//动画特效------------------------------------------------
procedure XAnima_Run(hAnimation, hRedrawObjectUI: HXCGUI); stdcall; external XCGUI_DLL;

function XAnima_Release(hAnimation: HXCGUI; bEnd: Boolean = True): Boolean; stdcall; external XCGUI_DLL;

function XAnima_ReleaseEx(hObjectUI: HXCGUI; bEnd: Boolean): Integer; stdcall; external XCGUI_DLL;

function XAnima_Create(hObjectUI: HXCGUI; nLoopCount: Integer = 0): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_Move(hSequence: HXCGUI; duration: Cardinal; x, y: Single; nLoopCount: Integer = 1; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_MoveEx(hSequence: HXCGUI; duration: Cardinal; from_x, from_y, to_x, to_y: Single; nLoopCount: Integer = 1; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function Anima_MoveExT(hSequence: HXCGUI; duration: Cardinal; from_x, from_y, to_x, to_y: Single; nLoopCount: Integer = 1; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False; bFrom: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_Rotate(hSequence: HXCGUI; duration: Cardinal; angle: Single; nLoopCount: Integer = 1; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_RotateEx(hSequence: HXCGUI; duration: Cardinal; from, toEnd: Single; nLoopCount: Integer = 1; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function Anima_RotateExT(hSequence: HXCGUI; duration: Cardinal; from, toEnd: Single; nLoopCount: Integer = 1; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False; bFrom: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_Scale(hSequence: HXCGUI; duration: Cardinal; scaleX, scaleY: Single; nLoopCount: Integer = 0; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = True): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_ScaleSize(hSequence: HXCGUI; duration: Cardinal; width, height: Single; nLoopCount: Integer = 1; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_Alpha(hSequence: HXCGUI; duration: Cardinal; alpha: Byte; nLoopCount: Integer = 0; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_AlphaEx(hSequence: HXCGUI; duration: Cardinal; from_alpha, to_alpha: Byte; nLoopCount: Integer = 0; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function Anima_AlphaExT(hSequence: HXCGUI; duration: Cardinal; from_alpha, to_alpha: Byte; nLoopCount: Integer = 0; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False; bFrom: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_Color(hSequence: HXCGUI; duration: Cardinal; color: LongInt; nLoopCount: Integer = 0; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_ColorEx(hSequence: HXCGUI; duration: Cardinal; from, toEnd: LongInt; nLoopCount: Integer = 0; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function Anima_ColorExT(hSequence: HXCGUI; duration: Cardinal; from, toEnd: LongInt; nLoopCount: Integer = 0; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False; bFrom: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_LayoutWidth(hSequence: HXCGUI; duration: Cardinal; nType: Integer; width: Single; nLoopCount: Integer = 1; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_LayoutHeight(hSequence: HXCGUI; duration: Cardinal; nType: Integer; height: Single; nLoopCount: Integer = 1; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_LayoutSize(hSequence: HXCGUI; duration: Cardinal; nWidthType: Integer; width: Single; nHeightType: Integer; height: Single; nLoopCount: Integer = 0; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = True): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_Delay(hSequence: HXCGUI; duration: Single): HXCGUI; stdcall; external XCGUI_DLL;

function XAnima_Show(hSequence: HXCGUI; duration: Single; bShow: Boolean): HXCGUI; stdcall; external XCGUI_DLL;

function XAnimaGroup_Create(nLoopCount: Integer = 0): HXCGUI; stdcall; external XCGUI_DLL;

procedure XAnimaGroup_AddItem(hGroup, hSequence: HXCGUI); stdcall; external XCGUI_DLL;

procedure XAnimaItem_EnableCompleteRelease(hAnimationItem: HXCGUI; bEnable: Boolean); stdcall; external XCGUI_DLL;

procedure XAnimaRotate_SetCenter(hAnimationRotate: HXCGUI; x, y: Single; bOffset: Boolean = False); stdcall; external XCGUI_DLL;

procedure XAnimaScale_SetPosition(hAnimationScale: HXCGUI; position: Integer); stdcall; external XCGUI_DLL;

function XAnima_GetObjectUI(hAnimation: HXCGUI): HXCGUI; stdcall; external XCGUI_DLL;

procedure XAnima_EnableAutoDestroy(hAnimation: HXCGUI; bEnable: Boolean); stdcall; external XCGUI_DLL;


//v3.3.1---------------------------------------------------------
function XWnd_CreateEx(dwExStyle, dwStyle: DWORD; lpClassName: PWideChar; x, y, cx, cy: Integer; pTitle: PWideChar; hWndParent: Integer = 0; XCStyle: window_style_ = window_style_default): HWINDOW; stdcall; external XCGUI_DLL;

function XModalWnd_CreateEx(dwExStyle, dwStyle: DWORD; lpClassName: PWideChar; x, y, cx, cy: Integer; pTitle: PWideChar; hWndParent: Integer; XCStyle: window_style_ = window_style_modal): HWINDOW; stdcall; external XCGUI_DLL;

function XFrameWnd_CreateEx(dwExStyle, dwStyle: DWORD; lpClassName: PWideChar; x, y, cx, cy: Integer; pTitle: PWideChar; hWndParent: Integer; XCStyle: window_style_): HWINDOW; stdcall; external XCGUI_DLL;

function XAnima_DestroyObjectUI(hSequence: HXCGUI; duration: Single): HXCGUI; stdcall; external XCGUI_DLL;

procedure XAnima_SetCallback(hAnimation: HXCGUI; callback: Integer); stdcall; external XCGUI_DLL;

procedure XAnima_SetUserData(hAnimation: HXCGUI; nUserData: vint); stdcall; external XCGUI_DLL;

function XAnima_GetUserData(hAnimation: HXCGUI): vint; stdcall; external XCGUI_DLL;

function XAnima_Stop(hAnimation: HXCGUI): Boolean; stdcall; external XCGUI_DLL;

function XAnima_Start(hAnimation: HXCGUI): Boolean; stdcall; external XCGUI_DLL;

function XAnima_Pause(hAnimation: HXCGUI): Boolean; stdcall; external XCGUI_DLL;

procedure XAnimaItem_SetCallback(hAnimationItem: HXCGUI; callback: Integer); stdcall; external XCGUI_DLL;

procedure XAnimaItem_SetUserData(hAnimationItem: HXCGUI; nUserData: vint); stdcall; external XCGUI_DLL;

function XAnimaItem_GetUserData(hAnimationItem: HXCGUI): vint; stdcall; external XCGUI_DLL;

procedure XAnimaItem_EnableAutoDestroy(hAnimationItem: HXCGUI; bEnable: Boolean); stdcall; external XCGUI_DLL;

function XNotifyMsg_WindowPopup(hWindow: HWINDOW; position: Integer; pTitle, pText: PWideChar; hIcon: HIMAGE; skin: notifyMsg_skin_ = notifyMsg_skin_no): HELE; stdcall; external XCGUI_DLL;

function XNotifyMsg_WindowPopupEx(hWindow: HWINDOW; position: Integer; pTitle, pText: PWideChar; hIcon: HIMAGE = 0; skin: notifyMsg_skin_ = notifyMsg_skin_no; bBtnClose: Boolean = True; bAutoClose: Boolean = True; nWidth: Integer = -1; nHeight: Integer = -1): HELE; stdcall; external XCGUI_DLL;

function XNotifyMsg_Popup(position: Integer; pTitle, pText: PWideChar; hIcon: HIMAGE; skin: notifyMsg_skin_ = notifyMsg_skin_no): HWINDOW; stdcall; external XCGUI_DLL;

function XNotifyMsg_PopupEx(position: Integer; pTitle, pText: PWideChar; hIcon: HIMAGE = 0; skin: notifyMsg_skin_ = notifyMsg_skin_no; bBtnClose: Boolean = True; bAutoClose: Boolean = True; nWidth: Integer = -1; nHeight: Integer = -1): HWINDOW; stdcall; external XCGUI_DLL;

procedure XNotifyMsg_SetDuration(hWindow: HWINDOW; duration: Cardinal); stdcall; external XCGUI_DLL;

procedure XNotifyMsg_SetCaptionHeight(hWindow: HWINDOW; nHeight: Integer); stdcall; external XCGUI_DLL;

procedure XNotifyMsg_SetWidth(hWindow: HWINDOW; nWidth: Integer); stdcall; external XCGUI_DLL;

procedure XNotifyMsg_SetSpace(hWindow: HWINDOW; nSpace: Integer); stdcall; external XCGUI_DLL;

procedure XNotifyMsg_SetBorderSize(hWindow: HWINDOW; left, top, right, bottom: Integer); stdcall; external XCGUI_DLL;

procedure XNotifyMsg_SetParentMargin(hWindow: HWINDOW; left, top, right, bottom: Integer); stdcall; external XCGUI_DLL;

function XMsg_CreateEx(dwExStyle, dwStyle: DWORD; lpClassName, pTitle, pText: PWideChar; nFlags: Integer; hWndParent: Integer = 0; XCStyle: window_style_ = window_style_modal): HWINDOW; stdcall; external XCGUI_DLL;

function XAnima_DelayEx(hSequence: HXCGUI; duration: Single; nLoopCount: Integer = 1; ease_flag: ease_flag_ = ease_flag_linear; bGoBack: Boolean = False): HXCGUI; stdcall; external XCGUI_DLL;

procedure XAnimaMove_SetFlag(hAnimationMove: HXCGUI; flags: Integer); stdcall; external XCGUI_DLL;

function XEle_SetBkInfo(hEle: HELE; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XWnd_SetBkInfo(hWindow: HWINDOW; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XBkM_SetInfo(hBkInfoM: HBKM; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XC_LoadLayout(pFileName: PWideChar; hParent: HXCGUI = 0; hAttachWnd: Integer = 0): HXCGUI; stdcall; external XCGUI_DLL;

function XC_LoadLayoutZip(pZipFileName, pFileName, pPassword: PWideChar; hParent: HXCGUI = 0; hAttachWnd: Integer = 0): HXCGUI; stdcall; external XCGUI_DLL;

function XC_LoadLayoutZipMem(data: Integer; length: Integer; pFileName, pPassword: PWideChar; hParent: HXCGUI = 0; hAttachWnd: Integer = 0): HXCGUI; stdcall; external XCGUI_DLL;

function XC_LoadLayoutFromString(pStringXML: PChar; hParent: HXCGUI = 0; hAttachWnd: Integer = 0): HXCGUI; stdcall; external XCGUI_DLL;

function XC_LoadLayoutFromStringUtf8(pStringXML: PChar; hParent: HXCGUI = 0; hAttachWnd: Integer = 0): HXCGUI; stdcall; external XCGUI_DLL;

procedure XWnd_SetCaptionMargin(hWindow: HWINDOW; left, top, right, bottom: Integer); stdcall; external XCGUI_DLL;

function XWnd_IsDragBorder(hWindow: HWINDOW): Boolean; stdcall; external XCGUI_DLL;

function XWnd_IsDragWindow(hWindow: HWINDOW): Boolean; stdcall; external XCGUI_DLL;

function XWnd_IsDragCaption(hWindow: HWINDOW): Boolean; stdcall; external XCGUI_DLL;
// v3.3.3-------------------------------------------------------

procedure XList_SetSplitLineColor(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

procedure XListBox_SetSplitLineColor(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

procedure XTree_SetSplitLineColor(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_D2D_Clear(hDraw: HDRAW; color: Integer); stdcall; external XCGUI_DLL;

function XBkM_GetStateTextColor(hBkInfoM: HBKM; nState: Integer; out color: Integer): BOOL; stdcall; external XCGUI_DLL;

function XBkM_GetObject(hBkInfoM: HBKM; id: Integer): vint; stdcall; external XCGUI_DLL;

function XMenu_SetItemWidth(hMenu: HMENUX; nID: Integer; nWidth: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XBkObj_SetMargin(hObj: vint; left: Integer; top: Integer; right: Integer; bottom: Integer); stdcall; external XCGUI_DLL;

procedure XBkObj_SetAlign(hObj: vint; nFlags: Integer); stdcall; external XCGUI_DLL; // bkInfo_align_flags_

procedure XBkObj_SetImage(hObj: vint; hImage: HIMAGE); stdcall; external XCGUI_DLL;

procedure XBkObj_SetRotate(hObj: vint; angle: Single); stdcall; external XCGUI_DLL;

procedure XBkObj_SetFillColor(hObj: vint; color: Integer); stdcall; external XCGUI_DLL;

procedure XBkObj_SetBorderWidth(hObj: vint; width: Integer); stdcall; external XCGUI_DLL;

procedure XBkObj_SetBorderColor(hObj: vint; color: Integer); stdcall; external XCGUI_DLL;

procedure XBkObj_SetRectRoundAngle(hObj: vint; leftTop: Integer; leftBottom: Integer; rightTop: Integer; rightBottom: Integer); stdcall; external XCGUI_DLL;

procedure XBkObj_EnableFill(hObj: vint; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XBkObj_EnableBorder(hObj: vint; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XBkObj_SetText(hObj: vint; pText: PWideChar); stdcall; external XCGUI_DLL;

procedure XBkObj_SetFont(hObj: vint; hFont: HFONTX); stdcall; external XCGUI_DLL;

procedure XBkObj_SetTextAlign(hObj: vint; nAlign: Integer); stdcall; external XCGUI_DLL;

procedure XBkObj_GetMargin(hObj: vint; out pMargin: TmarginSize_); stdcall; external XCGUI_DLL;

function XBkObj_GetAlign(hObj: vint): Integer; stdcall; external XCGUI_DLL;

function XBkObj_GetImage(hObj: vint): HIMAGE; stdcall; external XCGUI_DLL;

function XBkObj_GetRotate(hObj: vint): Integer; stdcall; external XCGUI_DLL;

function XBkObj_GetFillColor(hObj: vint): Integer; stdcall; external XCGUI_DLL;

function XBkObj_GetBorderColor(hObj: vint): Integer; stdcall; external XCGUI_DLL;

function XBkObj_GetBorderWidth(hObj: vint): Integer; stdcall; external XCGUI_DLL;

procedure XBkObj_GetRectRoundAngle(hObj: vint; out Rect: TRect); stdcall; external XCGUI_DLL;

function XBkObj_IsFill(hObj: vint): BOOL; stdcall; external XCGUI_DLL;

function XBkObj_IsBorder(hObj: vint): BOOL; stdcall; external XCGUI_DLL;

function XBkObj_GetText(hObj: vint): PWideChar; stdcall; external XCGUI_DLL;

function XBkObj_GetFont(hObj: vint): HFONTX; stdcall; external XCGUI_DLL;

function XBkObj_GetTextAlign(hObj: vint): Integer; stdcall; external XCGUI_DLL;

// v3.3.4---------------------------------
procedure XEdit_SetRowSpace(hEle: HELE; nSpace: Integer); stdcall; external XCGUI_DLL;

procedure XEdit_SetBackFont(hEle: HELE; hFont: HFONTX); stdcall; external XCGUI_DLL;

function XEdit_ReleaseStyle(hEle: HELE; iStyle: Integer): BOOL; stdcall; external XCGUI_DLL;

function XEdit_ModifyStyle(hEle: HELE; iStyle: Integer; hFont: HFONTX; color: Integer; bColor: BOOL): Integer; stdcall; external XCGUI_DLL;

procedure XEdit_SetSpaceSize(hEle: HELE; size: Integer); stdcall; external XCGUI_DLL;

procedure XEdit_SetCharSpaceSize(hEle: HELE; size: Integer; sizeZh: Integer); stdcall; external XCGUI_DLL;

function XEdit_GetSelectTextLength(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XEdit_SetSelectTextStyle(hEle: HELE; iStyle: Integer); stdcall; external XCGUI_DLL;

procedure XEdit_AddTextUser(hEle: HELE; pString: PWideChar); stdcall; external XCGUI_DLL;

procedure XEdit_PosToRowCol(hEle: HELE; iPos: Integer; out pInfo: Tposition_); stdcall; external XCGUI_DLL;

function XEdit_RowColToPos(hEle: HELE; iRow: Integer; iCol: Integer): Integer; stdcall; external XCGUI_DLL;

procedure XEdit_SetCurPosEx(hEle: HELE; iRow: Integer; iCol: Integer); stdcall; external XCGUI_DLL;// 新增

procedure XEdit_GetCurPosEx(hEle: HELE; out iRow: Integer; out iCol: Integer); stdcall; external XCGUI_DLL; // 新增

function XEdit_SetCurPos(hEle: HELE; pos: Integer): BOOL; stdcall; external XCGUI_DLL;  // 修改

procedure XEdit_MoveEnd(hEle: HELE); stdcall; external XCGUI_DLL;// 新增

// 增加参数

procedure XPane_ShowPane(hEle: HELE; bActivate: BOOL); stdcall; external XCGUI_DLL;

procedure XPane_HidePane(hEle: HELE; bGroupDelay: BOOL = FALSE); stdcall; external XCGUI_DLL;
// 新增:

function XPane_IsGroupActivate(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;



// 新增:
procedure XList_SetItemHeight(hEle: HELE; iItem: Integer; nHeight: Integer; nSelHeight: Integer); stdcall; external XCGUI_DLL;

procedure XList_GetItemHeight(hEle: HELE; iItem: Integer; out pHeight: Integer; out pSelHeight: Integer); stdcall; external XCGUI_DLL;

// 弹出菜单修复 对背景管理器支持，对窗口隐藏支持

// 句柄上限增加到 20 万

// 增加列表视图 取数据接口
function XAdListView_Group_GetText(hAdapter: HXCGUI; iGroup: Integer; iColumn: Integer): PWideChar; stdcall; external XCGUI_DLL; // new

function XAdListView_Group_GetTextEx(hAdapter: HXCGUI; iGroup: Integer; pName: PWideChar): PWideChar; stdcall; external XCGUI_DLL; // new

function XAdListView_Group_GetImage(hAdapter: HXCGUI; iGroup: Integer; iColumn: Integer): HIMAGE; stdcall; external XCGUI_DLL; // new

function XAdListView_Group_GetImageEx(hAdapter: HXCGUI; iGroup: Integer; pName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL; // new

function XAdListView_Item_GetText(hAdapter: HXCGUI; iGroup: Integer; iItem: Integer; iColumn: Integer): PWideChar; stdcall; external XCGUI_DLL;

function XAdListView_Item_GetImage(hAdapter: HXCGUI; iGroup: Integer; iItem: Integer; pName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL;

function XListView_Group_GetText(hEle: HELE; iGroup: Integer; iColumn: Integer): PWideChar; stdcall; external XCGUI_DLL; // new

function XListView_Group_GetTextEx(hEle: HELE; iGroup: Integer; pName: PWideChar): PWideChar; stdcall; external XCGUI_DLL; // new

function XListView_Group_GetImage(hEle: HELE; iGroup: Integer; iColumn: Integer): HIMAGE; stdcall; external XCGUI_DLL; // new

function XListView_Group_GetImageEx(hEle: HELE; iGroup: Integer; pName: PWideChar): HIMAGE; stdcall; external XCGUI_DLL; // new

function XListView_Item_GetText(hEle: HELE; iGroup: Integer; iItem: Integer; iColumn: Integer): PWideChar; stdcall; external XCGUI_DLL;

function XListView_Item_GetImage(hEle: HELE; iGroup: Integer; iItem: Integer; iColumn: Integer): HIMAGE; stdcall; external XCGUI_DLL;

procedure XDraw_ImageMask(hDraw: HDRAW; hImageFrame: HIMAGE; hImageFrameMask: HIMAGE; var Rect: TRect; x2: Integer; y2: Integer); stdcall; external XCGUI_DLL;

procedure XDraw_ImageMaskRect(hDraw: HDRAW; hImageFrame: HIMAGE; var Rect: TRect; var pRcMask: TRect; var pRcRoundAngle: TRect); stdcall; external XCGUI_DLL;

procedure XDraw_ImageMaskEllipse(hDraw: HDRAW; hImageFrame: HIMAGE; var Rect: TRect; var pRcMask: TRect); stdcall; external XCGUI_DLL;

function XTemp_Clone(hTemp: HTEMP): HTEMP; stdcall; external XCGUI_DLL;

procedure XFrameWnd_GetDragFloatWndTopFlag(hWindow: HWINDOW); stdcall; external XCGUI_DLL;

// 3.3.5
procedure XImage_SetScaleSize(hImage: HIMAGE; width: Integer; height: Integer); stdcall; external XCGUI_DLL;
//--------------------------

procedure XListView_SetDragRectColor(hEle: HELE; color: Integer; width: Integer); stdcall; external XCGUI_DLL;

procedure XListBox_SetDragRectColor(hEle: HELE; color: Integer; width: Integer); stdcall; external XCGUI_DLL;

procedure XList_SetDragRectColor(hEle: HELE; color: Integer; width: Integer); stdcall; external XCGUI_DLL;

function XSvg_LoadZipMem(data: Integer; length: Integer; pFileName: PWideChar; pPassword: PWideChar): HSVG; stdcall; external XCGUI_DLL;

function XFont_CreateFromZip(pZipFileName: PWideChar; pFileName: PWideChar; pPassword: PWideChar; fontSize: Integer; style: Integer): HFONTX; stdcall; external XCGUI_DLL;

function XFont_CreateFromZipMem(data: Integer; length: Integer; pFileName: PWideChar; pPassword: PWideChar; fontSize: Integer; style: Integer): HFONTX; stdcall; external XCGUI_DLL;

// 增加参数 col_extend_count  列表项模板支持列延伸
// function XList_CreateAdapter(hEle: HELE; col_extend_count: Integer = 0): HXCGUI; stdcall; external XCGUI_DLL;

//--------------------------------------
procedure XListBox_SetItemHeight(hEle: HELE; iItem: Integer; nHeight: Integer; nSelHeight: Integer); stdcall; external XCGUI_DLL;

procedure XListBox_GetItemHeight(hEle: HELE; iItem: Integer; out pHeight: Integer; out pSelHeight: Integer); stdcall; external XCGUI_DLL;

function XEdit_GetRowCountEx(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XUI_EnableCssEx(hXCGUI: HXCGUI; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XBtn_EnableHotkeyPrefix(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

procedure XFont_SetUnderlineEdit(hFontX: HFONTX; bUnderline: BOOL; bStrikeout: BOOL); stdcall; external XCGUI_DLL;

procedure XFont_GetUnderlineEdit(hFontX: HFONTX; out bUnderline: BOOL; out bStrikeout: BOOL); stdcall; external XCGUI_DLL;

// 3.3.6
function XEdit_GetText_Temp(hEle: HELE): PWideChar; stdcall; external XCGUI_DLL;

function XEdit_GetTextRow_Temp(hEle: HELE; iRow: Integer): PWideChar; stdcall; external XCGUI_DLL;

function XEdit_GetSelectText_Temp(hEle: HELE): PWideChar; stdcall; external XCGUI_DLL;

function XList_GetItemTemplate(hEle: HELE): HTEMP; stdcall; external XCGUI_DLL;

function XList_GetItemTemplateHeader(hEle: HELE): HTEMP; stdcall; external XCGUI_DLL;

procedure XList_RefreshDataHeader(hEle: HELE); stdcall; external XCGUI_DLL;

function XTemp_List_InsertNode(hTemp: HTEMP; index: Integer; pNode: Pointer): BOOL; stdcall; external XCGUI_DLL;

function XTemp_List_DeleteNode(hTemp: HTEMP; index: Integer): BOOL; stdcall; external XCGUI_DLL;

function XTemp_List_GetCount(hTemp: HTEMP): Integer; stdcall; external XCGUI_DLL;

function XTemp_List_MoveColumn(hTemp: HTEMP; iColDest: Integer; iColSrc: Integer): BOOL; stdcall; external XCGUI_DLL;

// 3.3.7
// 增加事件: XE_TOOLTIP_POPUP
// 结构体 menu_drawItem_ 增加成员 nShortcutKeyWidth

function XC_LoadLayoutEx(pFileName: PWideChar; pPrefixName: PWideChar = nil; hParent: HXCGUI = 0; hParentWnd: Integer = 0; hAttachWnd: Integer = 0): HXCGUI; stdcall; external XCGUI_DLL;

function XC_LoadLayoutZipEx(pZipFileName: PWideChar; pFileName: PWideChar; pPassword: PWideChar = nil; pPrefixName: PWideChar = nil; hParent: HXCGUI = 0; hParentWnd: Integer = 0; hAttachWnd: Integer = 0): HXCGUI; stdcall; external XCGUI_DLL;

function XC_LoadLayoutZipMemEx(data: Integer; length: Integer; pFileName: PWideChar; pPassword: PWideChar = nil; pPrefixName: PWideChar = nil; hParent: HXCGUI = 0; hParentWnd: Integer = 0; hAttachWnd: Integer = 0): HXCGUI; stdcall; external XCGUI_DLL;

function XC_LoadLayoutFromStringEx(pStringXML: PChar; pPrefixName: PWideChar = nil; hParent: HXCGUI = 0; hParentWnd: Integer = 0; hAttachWnd: Integer = 0): HXCGUI; stdcall; external XCGUI_DLL;

function XC_LoadLayoutFromStringUtf8Ex(pStringXML: PChar; pPrefixName: PWideChar = nil; hParent: HXCGUI = 0; hParentWnd: Integer = 0; hAttachWnd: Integer = 0): HXCGUI; stdcall; external XCGUI_DLL;

procedure XEdit_InsertChatBegin(hEle: HELE; hImageAvatar: HIMAGE; hImageBubble: HIMAGE; nFlag: Integer); stdcall; external XCGUI_DLL;

function XDraw_GetFont(hDraw: HDRAW): HFONTX; stdcall; external XCGUI_DLL;


// v3.3.8
// 用户数据改为 vint 类型 XList_SetItemData() XList_GetItemData()

procedure XC_EnableAutoDPI(bEnabel: BOOL); stdcall; external XCGUI_DLL;

procedure XWnd_SetDPI(hWindow: HWINDOW; nDPI: Integer); stdcall; external XCGUI_DLL;

function XC_LoadLayoutZipResEx(id: Integer; pFileName: PWideChar; pPassword: PWideChar = nil; pPrefixName: PWideChar = nil; hParent: HXCGUI = 0; hParentWnd: Integer = 0; hAttachWnd: Integer = 0; hModule: Integer = 0): HXCGUI; stdcall; external XCGUI_DLL;

function XC_LoadResourceZipRes(id: Integer; pFileName: PWideChar; pPassword: PWideChar = nil; hModule: Integer = 0): BOOL; stdcall; external XCGUI_DLL;

function XC_LoadStyleZipRes(id: Integer; pFileName: PWideChar; pPassword: PWideChar = nil; hModule: Integer = 0): BOOL; stdcall; external XCGUI_DLL;

function XTemp_LoadFromMem(nType: listItemTemp_type_; data: Integer; length: Integer): HTEMP; stdcall; external XCGUI_DLL;

function XTemp_LoadFromMemEx(nType: listItemTemp_type_; data: Integer; length: Integer; out pOutTemp1: HTEMP; out pOutTemp2: HTEMP): BOOL; stdcall; external XCGUI_DLL;

function XTemp_LoadZipRes(nType: listItemTemp_type_; id: Integer; pFileName: PWideChar; pPassword: PWideChar = nil; hModule: Integer = 0): HTEMP; stdcall; external XCGUI_DLL;

function XTemp_LoadZipResEx(nType: listItemTemp_type_; id: Integer; pFileName: PWideChar; pPassword: PWideChar; out pOutTemp1: HTEMP; out pOutTemp2: HTEMP; hModule: Integer = 0): BOOL; stdcall; external XCGUI_DLL;

function XImage_LoadZipRes(id: Integer; pFileName: PWideChar; pPassword: PWideChar = nil; hModule: Integer = 0): HIMAGE; stdcall; external XCGUI_DLL;

function XImgSrc_LoadZipRes(id: Integer; pFileName: PWideChar; pPassword: PWideChar = nil; hModule: Integer = 0): HIMAGE; stdcall; external XCGUI_DLL;

function XSvg_LoadZipRes(id: Integer; pFileName: PWideChar; pPassword: PWideChar = nil; hModule: Integer = 0): HSVG; stdcall; external XCGUI_DLL;

function XListBox_SetItemTemplateXMLFromMem(hEle: HELE; data: Integer; length: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListBox_SetItemTemplateXMLFromZipRes(hEle: HELE; id: Integer; pFileName: PWideChar; pPassword: PWideChar = nil; hModule: Integer = 0): BOOL; stdcall; external XCGUI_DLL;

function XListBox_GetItemTemplate(hEle: HELE): HTEMP; stdcall; external XCGUI_DLL;

function XList_SetItemTemplateXMLFromMem(hEle: HELE; data: Integer; length: Integer): BOOL; stdcall; external XCGUI_DLL;

function XList_SetItemTemplateXMLFromZipRes(hEle: HELE; id: Integer; pFileName: PWideChar; pPassword: PWideChar = nil; hModule: Integer = 0): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_SetItemTemplateXMLFromMem(hEle: HELE; data: Integer; length: Integer): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_SetItemTemplateXMLFromZipRes(hEle: HELE; id: Integer; pFileName: PWideChar; pPassword: PWideChar = nil; hModule: Integer = 0): BOOL; stdcall; external XCGUI_DLL;

function XComboBox_GetItemTemplate(hEle: HELE): HTEMP; stdcall; external XCGUI_DLL;

function XTree_SetItemTemplateXMLFromMem(hEle: HELE; data: Integer; length: Integer): BOOL; stdcall; external XCGUI_DLL;

function XTree_SetItemTemplateXMLFromZipRes(hEle: HELE; id: Integer; pFileName: PWideChar; pPassword: PWideChar = nil; hModule: Integer = 0): BOOL; stdcall; external XCGUI_DLL;

function XTree_GetItemTemplate(hEle: HELE): HTEMP; stdcall; external XCGUI_DLL;

function XListView_SetItemTemplateXMLFromMem(hEle: HELE; data: Integer; length: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListView_SetItemTemplateXMLFromZipRes(hEle: HELE; id: Integer; pFileName: PWideChar; pPassword: PWideChar; hModule: Integer): BOOL; stdcall; external XCGUI_DLL;

function XListView_GetItemTemplate(hEle: HELE): HTEMP; stdcall; external XCGUI_DLL;

function XListView_GetItemTemplateGroup(hEle: HELE): HTEMP; stdcall; external XCGUI_DLL;

function XDateTime_Create(x, y, cx, cy: Integer; hParent: HXCGUI): Integer; stdcall; external XCGUI_DLL;

procedure XDateTime_SetStyle(hEle: HELE; nStyle: Integer); stdcall; external XCGUI_DLL;

function XDateTime_GetStyle(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XDateTime_EnableSplitSlash(hEle: HELE; bSlash: Boolean); stdcall; external XCGUI_DLL;

function XDateTime_GetButton(hEle: HELE; nType: Integer): Integer; stdcall; external XCGUI_DLL;

function XDateTime_GetSelBkColor(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

procedure XDateTime_SetSelBkColor(hEle: HELE; crSelectBk: Integer); stdcall; external XCGUI_DLL;

procedure XDateTime_GetDate(hEle: HELE; var pnYear, pnMonth, pnDay: Integer); stdcall; external XCGUI_DLL;

procedure XDateTime_SetDate(hEle: HELE; nYear, nMonth, nDay: Integer); stdcall; external XCGUI_DLL;

procedure XDateTime_GetTime(hEle: HELE; var pnHour, pnMinute, pnSecond: Integer); stdcall; external XCGUI_DLL;

procedure XDateTime_SetTime(hEle: HELE; nHour, nMinute, nSecond: Integer); stdcall; external XCGUI_DLL;

procedure XDateTime_Popup(hEle: HELE); stdcall; external XCGUI_DLL;

// 外部函数声明
function XMonthCal_Create(x, y, cx, cy: Integer; hParent: HXCGUI): HELE; stdcall; external XCGUI_DLL;

function XMonthCal_GetButton(hEle: HELE; nType: monthCal_button_type_): HELE; stdcall; external XCGUI_DLL;

procedure XMonthCal_SetToday(hEle: HELE; nYear, nMonth, nDay: Integer); stdcall; external XCGUI_DLL;

procedure XMonthCal_GetToday(hEle: HELE; var pnYear, pnMonth, pnDay: Integer); stdcall; external XCGUI_DLL;

procedure XMonthCal_SeSelDate(hEle: HELE; nYear, nMonth, nDay: Integer); stdcall; external XCGUI_DLL;

procedure XMonthCal_GetSelDate(hEle: HELE; var pnYear, pnMonth, pnDay: Integer); stdcall; external XCGUI_DLL;

procedure XMonthCal_SetTextColor(hEle: HELE; nFlag: Integer; color: Integer); stdcall; external XCGUI_DLL;

// 增加 DPI 支持
// UI 设计器增加撤销重做
// XMsg_Create 图标继承父

// XListView_EnablemTemplateReuse, XListBox_EnablemTemplateReuse, XTree_EnablemTemplateReuse, XWnd_EnablemLimitWindowSize,
// _Enablem* 改为 *_Enable*

procedure XC_SetWindowIcon(hImage: HIMAGE); stdcall; external XCGUI_DLL;

procedure XProgBar_SetColorLoad(hEle: HELE; color: Integer); stdcall; external XCGUI_DLL;

function XEdit_GetChatFlags(hEle: HELE; iRow: Integer): Integer; stdcall; external XCGUI_DLL;

procedure XEdit_InsertTextEx(hEle: HELE; iRow: Integer; iCol: Integer; pString: PWideChar; iStyle: Integer); stdcall; external XCGUI_DLL;

procedure XEdit_InsertObject(hEle: HELE; iRow: Integer; iCol: Integer; hObj: HXCGUI); stdcall; external XCGUI_DLL;

procedure XEle_GetWndClientRectDPI(hEle: HELE; out Rect: TRect); stdcall; external XCGUI_DLL;

procedure XEle_PointClientToWndClientDPI(hEle: HELE; var pPt: TPOINT); stdcall; external XCGUI_DLL;

procedure XEle_RectClientToWndClientDPI(hEle: HELE; var Rect: TRect); stdcall; external XCGUI_DLL;

function XWnd_SetWindowPos(hWindow: HWINDOW; hWndInsertAfter: Integer; X: Integer; Y: Integer; cx: Integer; cy: Integer; uFlags: UINT): BOOL; stdcall; external XCGUI_DLL;

function XWnd_GetDPI(hWindow: HWINDOW): Integer; stdcall; external XCGUI_DLL;

procedure XWnd_RectToDPI(hWindow: HWINDOW; var Rect: TRect); stdcall; external XCGUI_DLL;

procedure XWnd_PointToDPI(hWindow: HWINDOW; var pPt: TPOINT); stdcall; external XCGUI_DLL;

function XWnd_GetCursorPos(hWindow: HWINDOW; out pPt: TPOINT): BOOL; stdcall; external XCGUI_DLL;

function XWnd_ClientToScreen(hWindow: HWINDOW; var pPt: TPOINT): BOOL; stdcall; external XCGUI_DLL;

function XWnd_ScreenToClient(hWindow: HWINDOW; var pPt: TPOINT): BOOL; stdcall; external XCGUI_DLL;

// 2023-09-25
procedure XFrameWnd_GetViewRect(hWindow: HWINDOW; out Rect: TRect); stdcall; external XCGUI_DLL;

function XList_CreateEx(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI; col_extend_count: Integer): HELE; stdcall; external XCGUI_DLL;

function XListBox_CreateEx(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

function XListView_CreateEx(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

function XTree_CreateEx(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: HXCGUI = 0): HELE; stdcall; external XCGUI_DLL;

//------------------------------------------------------------------
procedure XEdit_SetChatMaxWidth(hEle: HELE; nWidth: Integer); stdcall; external XCGUI_DLL;

procedure XFrameWnd_SetPaneSplitBarWidth(hWindow: HWINDOW; nWidth: Integer); stdcall; external XCGUI_DLL;

function XFrameWnd_GetPaneSplitBarWidth(hWindow: HWINDOW): Integer; stdcall; external XCGUI_DLL;

function XC_EnableDPI(bEnable: BOOL): BOOL; stdcall; external XCGUI_DLL;

// 2023-10-11
function XMenu_GetMenuBar(hMenu: HMENUX): HELE; stdcall; external XCGUI_DLL;

function XMenuBar_GetSelect(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

// 2023-10-11
procedure XTrayIcon_Reset(); stdcall; external XCGUI_DLL;

function XTrayIcon_Add(hWindow: HWINDOW; id: Integer): BOOL; stdcall; external XCGUI_DLL;

function XTrayIcon_Del(): BOOL; stdcall; external XCGUI_DLL;

function XTrayIcon_Modify(): BOOL; stdcall; external XCGUI_DLL;

procedure XTrayIcon_SetIcon(hIcon: HICON); stdcall; external XCGUI_DLL;

function XTrayIcon_SetFocus(): BOOL; stdcall; external XCGUI_DLL;

procedure XTrayIcon_SetTips(pTips: PWideChar); stdcall; external XCGUI_DLL;

procedure XTrayIcon_SetPopupBalloon(pTitle: PWideChar; pText: PWideChar; hBalloonIcon: HICON = 0; flags: Integer = 0); stdcall; external XCGUI_DLL;

procedure XTrayIcon_SetCallbackMessage(user_message: UINT); stdcall; external XCGUI_DLL;


// 2024-01-29
// 界面库更新:
// 加载布局文件,首次自动处理按钮绑定的元素显示隐藏
// 按钮绑定元素,新增支持[名称],以前只支持 ID
// 布局属性,固定坐标, 支持负数

procedure XFrameWnd_SetLayoutMargin(hWindow: HWINDOW; left: Integer; top: Integer; right: Integer; bottom: Integer); stdcall; external XCGUI_DLL;// 设置框架窗口布局区域外间距

function XEdit_ClipboardCopyAll(hEle: HELE): BOOL; stdcall; external XCGUI_DLL;

function XList_AddColumnText2(hEle: HELE; nWidth: Integer; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XList_AddColumnImage2(hEle: HELE; nWidth: Integer; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XList_CreateAdapters(hEle: HELE; col_extend_count: Integer = 3): BOOL; stdcall; external XCGUI_DLL;

procedure XC_EnableAutoRedrawUI(bEnable: BOOL); stdcall; external XCGUI_DLL; // 启用自动重绘 UI, 默认关闭


// 2024-04-07
// UI 设计器属性视图->补齐属性
// UI 设计器属性视图->可指定模板文件自动创建数据适配器
// 开放虚表功能
// 列表将先前接口项改为行(item->row), 子项不变,保留旧版接口命名

function XC_GetHandleCount(): Integer; stdcall; external XCGUI_DLL;

function XList_AddRowText(hEle: HELE; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XList_AddRowTextEx(hEle: HELE; pName: PWideChar; pText: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XList_AddRowImage(hEle: HELE; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XList_AddRowImageEx(hEle: HELE; pName: PWideChar; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XList_InsertRowText(hEle: HELE; iRow: Integer; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XList_InsertRowTextEx(hEle: HELE; iRow: Integer; pName: PWideChar; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XList_InsertRowImage(hEle: HELE; iRow: Integer; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XList_InsertRowImageEx(hEle: HELE; iRow: Integer; pName: PWideChar; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XList_DeleteRow(hEle: HELE; iRow: Integer): BOOL; stdcall; external XCGUI_DLL;

function XList_DeleteRowEx(hEle: HELE; iRow: Integer; nCount: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XList_DeleteRowAll(hEle: HELE); stdcall; external XCGUI_DLL;

function XList_SetSelectRow(hEle: HELE; iRow: Integer): BOOL; stdcall; external XCGUI_DLL;

function XList_GetSelectRow(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XList_GetSelectRowCount(hEle: HELE): Integer; stdcall; external XCGUI_DLL;

function XList_AddSelectRow(hEle: HELE; iRow: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XList_VisibleRow(hEle: HELE; iRow: Integer); stdcall; external XCGUI_DLL;

function XList_CancelSelectRow(hEle: HELE; iRow: Integer): BOOL; stdcall; external XCGUI_DLL;

function XList_GetRowIndexFromHXCGUI(hEle: HELE; hXCGUI: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XList_GetHeaderColumnIndexFromHXCGUI(hEle: HELE; hXCGUI: HXCGUI): Integer; stdcall; external XCGUI_DLL;

procedure XList_SetRowHeightDefault(hEle: HELE; nHeight: Integer; nSelHeight: Integer); stdcall; external XCGUI_DLL;

procedure XList_GetRowHeightDefault(hEle: HELE; out pHeight: Integer; out pSelHeight: Integer); stdcall; external XCGUI_DLL;

procedure XList_SetRowHeight(hEle: HELE; iRow: Integer; nHeight: Integer; nSelHeight: Integer); stdcall; external XCGUI_DLL;

procedure XList_GetRowHeight(hEle: HELE; iRow: Integer; out pHeight: Integer; out pSelHeight: Integer); stdcall; external XCGUI_DLL;

procedure XList_EnableRowBkFull(hEle: HELE; bFull: BOOL); stdcall; external XCGUI_DLL;

procedure XList_SetDrawRowBkFlags(hEle: HELE; style: Integer); stdcall; external XCGUI_DLL;

procedure XList_RefreshRow(hEle: HELE; iRow: Integer); stdcall; external XCGUI_DLL;

function XAdTable_AddRowText(hAdapter: HXCGUI; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XAdTable_AddRowTextEx(hAdapter: HXCGUI; pName: PWideChar; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XAdTable_AddRowImage(hAdapter: HXCGUI; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XAdTable_AddRowImageEx(hAdapter: HXCGUI; pName: PWideChar; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XAdTable_InsertRowText(hAdapter: HXCGUI; iRow: Integer; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XAdTable_InsertRowTextEx(hAdapter: HXCGUI; iRow: Integer; pName: PWideChar; pValue: PWideChar): Integer; stdcall; external XCGUI_DLL;

function XAdTable_InsertRowImage(hAdapter: HXCGUI; iRow: Integer; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XAdTable_InsertRowImageEx(hAdapter: HXCGUI; iRow: Integer; pName: PWideChar; hImage: HIMAGE): Integer; stdcall; external XCGUI_DLL;

function XAdTable_DeleteRow(hAdapter: HXCGUI; iRow: Integer): BOOL; stdcall; external XCGUI_DLL;

function XAdTable_DeleteRowEx(hAdapter: HXCGUI; iRow: Integer; nCount: Integer): BOOL; stdcall; external XCGUI_DLL;

procedure XAdTable_DeleteRowAll(hAdapter: HXCGUI); stdcall; external XCGUI_DLL;

function XAdTable_GetCountRow(hAdapter: HXCGUI): Integer; stdcall; external XCGUI_DLL;

procedure XPGrid_EnableExpandCurGroupOnly(hEle: HELE; bEnable: BOOL); stdcall; external XCGUI_DLL;

// 2024-07-30
procedure XWnd_DestroyWindow(hWindow: HWINDOW); stdcall; external XCGUI_DLL;

procedure XC_SetD2dTextAntialiasMode(mode: Integer); stdcall; external XCGUI_DLL;

procedure XTable_SetItemTextEx(hShape: HXCGUI; iRow: Integer; iCol: Integer; pText: PWideChar; textColor: Integer; bkColor: Integer; bTextColor: BOOL = TRUE; bBkColor: BOOL = TRUE; hFont: HFONTX = 0); stdcall; external XCGUI_DLL;

// 2024-12-31
function XTable_GetRowCount(hShape: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XTable_GetColCount(hShape: HXCGUI): Integer; stdcall; external XCGUI_DLL;

function XC_IsInit(): BOOL; stdcall; external XCGUI_DLL;

function XEditor_IsEmptyRow(hEle: HELE; iRow: Integer): BOOL; stdcall; external XCGUI_DLL;

function XDraw_GetD2dBitmap(hDraw: HDRAW; hImage: HIMAGE): Vint; stdcall; external XCGUI_DLL;

function RGBA(r, g, b, a: Byte): DWORD;

function HexToRGBA(const HexColor: string): DWORD;

function RGBAToHex(const RGBA: DWORD; const Digits: Integer = 8): string;

function XWnd_RegEvent(hWindow: Integer; nEvent: Integer; pFun: Pointer): Boolean;

function XWnd_RemoveEvent(hWindow: Integer; nEvent: Integer; pFun: Pointer): Boolean;

function XEle_RegEvent(hEle: Integer; nEvent: Integer; pFun: Pointer): Boolean;

function XEle_RemoveEvent(hEle: Integer; nEvent: Integer; pFun: Pointer): Boolean;

procedure MBox(const Msg: Variant);

function RGBAToD2D1ColorF(Color: Integer): TD2D1ColorF;

implementation

function RGBAToD2D1ColorF(Color: Integer): TD2D1ColorF;
begin
  Result.r := Byte(Color) / 255.0;
  Result.g := Byte(Color shr 8) / 255.0;
  Result.b := Byte(Color shr 16) / 255.0;
  Result.a := Byte(Color shr 24) / 255.0;
end;

function RGBA(r, g, b, a: Byte): DWORD;
begin
  Result := (a shl 24) or (b shl 16) or (g shl 8) or r;
end;

function HexToRGBA(const HexColor: string): DWORD;
var
  HexStr: string;
  A, R, G, B: Byte;
begin
  // 去除 # 符号（如果存在）
  if (Length(HexColor) > 0) and (HexColor[1] = '#') then
    HexStr := Copy(HexColor, 2, MaxInt)
  else
    HexStr := HexColor;

  // 处理不同长度的格式
  case Length(HexStr) of
    3:
      begin  // #RGB → AARRGGBB（透明度默认FF）
        HexStr := 'FF' +                // Alpha=255（不透明）
          HexStr[1] + HexStr[1] +  // R → RR
          HexStr[2] + HexStr[2] +  // G → GG
          HexStr[3] + HexStr[3];   // B → BB
      end;
    4:
      begin  // #ARGB → AARRGGBB
        HexStr := HexStr[1] + HexStr[1] +  // A → AA
          HexStr[2] + HexStr[2] +  // R → RR
          HexStr[3] + HexStr[3] +  // G → GG
          HexStr[4] + HexStr[4];   // B → BB
      end;
    6:
      begin  // #RRGGBB → AARRGGBB（透明度默认FF）
        HexStr := 'FF' + HexStr;
      end;
    8:
      ;      // #AARRGGBB → 直接使用
  else
    raise Exception.Create('Invalid hex color format. Expected "#RGB", "#ARGB", "#RRGGBB", or "#AARRGGBB"');
  end;

  // 解析分量（必须确保HexStr长度=8）
  A := StrToInt('$' + Copy(HexStr, 1, 2));  // Alpha
  R := StrToInt('$' + Copy(HexStr, 3, 2));  // Red
  G := StrToInt('$' + Copy(HexStr, 5, 2));  // Green
  B := StrToInt('$' + Copy(HexStr, 7, 2));  // Blue

  // 返回RGBA格式的DWORD
  Result := (A shl 24) or (R shl 16) or (G shl 8) or B;
end;

function RGBAToHex(const RGBA: DWORD; const Digits: Integer = 8): string;
var
  A, R, G, B: Byte;
begin
  // 从RGBA DWORD中提取各个分量
  A := Byte(RGBA shr 24);  // Alpha
  R := Byte(RGBA shr 16);  // Red
  G := Byte(RGBA shr 8);   // Green
  B := Byte(RGBA);         // Blue

  // 根据Digits参数返回不同格式的十六进制字符串
  case Digits of
    3:
      begin  // RGB格式（3位）
        Result := Format('%.2x%.2x%.2x', [R, G, B]);
      end;
    4:
      begin  // ARGB格式（4位）
        Result := Format('%.2x%.2x%.2x%.2x', [A, R, G, B]);
      end;
    6:
      begin  // RRGGBB格式（6位）
        Result := Format('%.2x%.2x%.2x', [R, G, B]);
      end;
    8:
      begin  // AARRGGBB格式（8位，默认）
        Result := Format('%.2x%.2x%.2x%.2x', [A, R, G, B]);
      end;
  else
    // 默认返回8位格式
    Result := Format('%.2x%.2x%.2x%.2x', [A, R, G, B]);
  end;
end;

function XWnd_RegEvent(hWindow: Integer; nEvent: Integer; pFun: Pointer): Boolean;
begin
  Result := XWnd_RegEventC1(hWindow, nEvent, Integer(pFun));
end;

function XWnd_RemoveEvent(hWindow: Integer; nEvent: Integer; pFun: Pointer): Boolean;
begin
  Result := XWnd_RemoveEventC(hWindow, nEvent, Integer(pFun));
end;

function XEle_RegEvent(hEle: Integer; nEvent: Integer; pFun: Pointer): Boolean;
begin
  Result := XEle_RegEventC1(hEle, nEvent, Integer(pFun));
end;

function XEle_RemoveEvent(hEle: Integer; nEvent: Integer; pFun: Pointer): Boolean;
begin
  Result := XEle_RemoveEventC(hEle, nEvent, Integer(pFun));
end;

procedure MBox(const Msg: Variant);
var
  MsgStr: string;
begin
  // 根据变体类型进行转换
  case VarType(Msg) of
    varString, varUString:
      MsgStr := string(Msg);
    varInteger, varByte, varSmallint, varShortInt, varWord, varLongWord:
      MsgStr := IntToStr(Msg);
    varSingle, varDouble, varCurrency:
      MsgStr := FloatToStr(Msg);
    varBoolean:
      MsgStr := BoolToStr(Msg, True);
    varOleStr:
      MsgStr := string(Msg);
  else
    MsgStr := 'Unsupported type';
  end;

  MessageBox(0, PChar(MsgStr), '信息', MB_OK or MB_ICONINFORMATION);
end;

end.


