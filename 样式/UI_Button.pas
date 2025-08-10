unit UI_Button;

interface

uses
  Windows, Math, XCGUI, XBUTTON, UI_Resource, UI_Color, UI_Animation, SysUtils,
  XWidget, UI_Tooltip, Types;

const
  // 默认值常量
  DEFAULT_SVG_WIDTH = 16;              // 默认SVG宽度
  DEFAULT_SVG_HEIGHT = 16;             // 默认SVG高度
  DEFAULT_SPACE = 4;                   // 默认间距
  DEFAULT_ANIMATION_DURATION = 400;    // 默认动画持续时间(毫秒)
  DEFAULT_ANIMATION_ANGLE = 180;       // 默认动画旋转角度

  // 动画相关常量
  ANIMATION_TIMER_ID = 1;              // 动画定时器ID
  ANIMATION_FPS = 20;                  // 动画帧率
  
  // 单选框动画相关常量
  RADIO_ANIMATION_DURATION = 72;      // 单选框动画持续时间(毫秒)
  RADIO_ANIMATION_TIMER_ID = 2;        // 单选框动画定时器ID

  // 样式相关常量
  MIN_CORNER_RADIUS = 0;               // 最小圆角半径
  MAX_CORNER_RADIUS = 50;              // 最大圆角半径
  TRANSPARENT_COLOR = 0;               // 透明颜色值

type
  TSvgBtnUI = class(TXBtn)
  private
    FSvg: Integer;
    FSvgFile: string;
    FSvgSize: TSize;
    FSpace: Integer;
    FSvgOffSetLeft: Integer;
    FSvgOffSetTop: Integer;
    FTextOffLeft: Integer;
    FTextOffTop: Integer;
    FEnableBorder: Boolean;
    FEnableAnima: Boolean;
    FHintText: string;
    FHint: THintUI;
    FFont: Integer;
    FBackgroundColor: Integer;
    FCornerRadius: Integer;
    FIconColor: Integer;  // 图标颜色
    FUseCustomIconColor: Boolean;  // 是否使用自定义图标颜色
    procedure SetSvgFile(const Value: string);
    procedure SetSvgSize(const Value: TSize);
    procedure SetEnableAnima(bEnable: Boolean);
    procedure SetHint(const Value: string);
    procedure SetBackgroundColor(const Value: Integer);
    procedure SetCornerRadius(const Value: Integer);
    procedure SetIconColor(const Value: Integer);
    procedure UpdateThemeStyle;
  protected
    class function OnDESTROY(hBtn: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnPAINT(hBtn: Integer; hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnMOUSESTAY(Btn: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnMOUSELEAVE(Btn, StayEle: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    procedure PAINT(hDraw: Integer); virtual;
    procedure Init; override;
    procedure PaintContent(hDraw: Integer; const AClientRect: TRect; const ATextSize: TSize; out AIconRect: TRect; out ATextLeft, ATextTop: Integer); virtual;
  public
    class function FromXmlID_EX(const hWindow, ID: Integer; fun: Pointer): TSvgBtnUI; stdcall; static;
    destructor Destroy; override;
    procedure Style(SvgFileName: string; BtnHintText: string; SvgWidth: integer = DEFAULT_SVG_WIDTH; SvgHeight: integer = DEFAULT_SVG_HEIGHT; SvgEnableAnima: Boolean = False);
    procedure SetOffsetSvg(left, Top: Integer);
    procedure SetOffsetText(left, Top: Integer);
    property SvgFile: string read FSvgFile write SetSvgFile;
    property SvgSize: TSize read FSvgSize write SetSvgSize;
    property EnableAnima: Boolean read FEnableAnima write SetEnableAnima default False;
    property EnableBorder: Boolean read FEnableBorder write FEnableBorder default False;
    property HintText: string read FHintText write SetHint;
    property Font: Integer read FFont write FFont;
    property BackgroundColor: Integer read FBackgroundColor write SetBackgroundColor;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius;
    property IconColor: Integer read FIconColor write SetIconColor;
  end;

  TCheckableBtnUI = class(TSvgBtnUI)
  private
    FUncheckedSvg: Integer;
    FCheckedSvg: Integer;
    FDrawUncheckedManually: Boolean;
    FDrawCheckedManually: Boolean;
  protected
    procedure Init; override;
    procedure PaintContent(hDraw: Integer; const AClientRect: TRect; const ATextSize: TSize; out AIconRect: TRect; out ATextLeft, ATextTop: Integer); override;
    procedure PaintManualIcon(hDraw: Integer; AIconRect: TRect; isChecked: Boolean; hTheme: Integer); virtual; abstract;
  public
    destructor Destroy; override;
    procedure Style(AUncheckedSvgFile, ACheckedSvgFile, BtnHintText: string; SvgWidth: integer = DEFAULT_SVG_WIDTH; SvgHeight: integer = DEFAULT_SVG_HEIGHT; SvgEnableAnima: Boolean = False);
  end;

  TMultiSelectBtnUI = class(TCheckableBtnUI)
  protected
    procedure PaintManualIcon(hDraw: Integer; AIconRect: TRect; isChecked: Boolean; hTheme: Integer); override;
  end;

  TRadioBtnUI = class(TCheckableBtnUI)
  private
    FAnimationProgress: Single;  // 动画进度 0.0-1.0
    FAnimationTimer: Integer;    // 动画定时器句柄
    FTargetChecked: Boolean;     // 目标选中状态
    FLastChecked: Boolean;       // 上次的选中状态
    procedure StartAnimation(AChecked: Boolean);
    procedure StopAnimation;
    class function OnAnimationTimer(hEle: Integer; nID: Integer; pbHandled: PBoolean): Integer; stdcall; static;
  protected
    procedure Init; override;
    procedure PaintContent(hDraw: Integer; const AClientRect: TRect; const ATextSize: TSize; out AIconRect: TRect; out ATextLeft, ATextTop: Integer); override;
    procedure PaintManualIcon(hDraw: Integer; AIconRect: TRect; isChecked: Boolean; hTheme: Integer); override;
  public
    destructor Destroy; override;
  end;

implementation

uses
  Vcl.Graphics;

class function TSvgBtnUI.FromXmlID_EX(const hWindow, ID: Integer; fun: Pointer): TSvgBtnUI;
begin
  Result := FromXmlID(hWindow, ID);
  Result.RegEvent(XE_BNCLICK, fun);
end;

procedure TSvgBtnUI.Init;
begin
  inherited;
  FEnableAnima := False;
  FBackgroundColor := TRANSPARENT_COLOR; // 使用常量
  FIconColor := Theme_SvgColor_Leave; // 默认图标颜色
  FUseCustomIconColor := False; // 默认不使用自定义颜色
  EnableBkTransparent(True);
  TextAlign := textAlignFlag_left or textAlignFlag_left;
  EnableFocus(False);
  FFont := XRes_GetFont('微软雅黑10常规');
  SetCursor(LoadCursor(0, IDC_HAND));
  RegEvent(XE_DESTROY, @OnDESTROY);
  RegEvent(XE_PAINT, @OnPAINT);
  FEnableBorder := False;
  XTheme_AddChangeCallback(UpdateThemeStyle);
  UpdateThemeStyle;
end;

destructor TSvgBtnUI.Destroy;
begin
  XTheme_RemoveThemeChangeCallback(UpdateThemeStyle);
  if Assigned(FHint) then
    FHint.Free;
  if XC_GetObjectType(FSvg) = XC_SVG then
    XSvg_Release(FSvg);
  inherited;
end;

procedure TSvgBtnUI.SetEnableAnima(bEnable: Boolean);
begin
  FEnableAnima := bEnable;
  if FEnableAnima then
  begin
    RegEvent(XE_MOUSESTAY, @OnMOUSESTAY);
    RegEvent(XE_MOUSELEAVE, @OnMOUSELEAVE);
  end
  else
  begin
    RemoveEvent(XE_MOUSESTAY, @OnMOUSESTAY);
    RemoveEvent(XE_MOUSESTAY, @OnMOUSELEAVE);
  end;
end;

procedure TSvgBtnUI.SetBackgroundColor(const Value: Integer);
begin
  if FBackgroundColor <> Value then
  begin
    FBackgroundColor := Value;
    if IsHELE then
      Redraw;
  end;
end;

procedure TSvgBtnUI.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius <> Value then
  begin
    FCornerRadius := Value;
    if IsHELE then
      Redraw;
  end;
end;

procedure TSvgBtnUI.SetIconColor(const Value: Integer);
begin
  if FIconColor <> Value then
  begin
    FIconColor := Value;
    FUseCustomIconColor := True; // 设置自定义颜色时启用标志
    if IsHELE then
      Redraw;
  end;
end;



procedure TSvgBtnUI.UpdateThemeStyle;
begin
  SetCornerRadius(Theme_Button_CornerRadius);
end;

class function TSvgBtnUI.OnMOUSELEAVE(Btn, StayEle: Integer; pbHandled: PBoolean): Integer; stdcall;
var
  SvgBtnUI: TSvgBtnUI;
begin
  Result := 0;
  SvgBtnUI := GetClassFormHandle(Btn);
  if XC_GetObjectType(SvgBtnUI.FSvg) = XC_SVG then
    XAnima_SetRotateStyle(SvgBtnUI.FSvg, DEFAULT_ANIMATION_DURATION, 0, 1, Btn);
end;

class function TSvgBtnUI.OnMOUSESTAY(Btn: Integer; pbHandled: PBoolean): Integer; stdcall;
var
  SvgBtnUI: TSvgBtnUI;
begin
  Result := 0;
  SvgBtnUI := GetClassFormHandle(Btn);
  if XC_GetObjectType(SvgBtnUI.FSvg) = XC_SVG then
    XAnima_SetRotateStyle(SvgBtnUI.FSvg, DEFAULT_ANIMATION_DURATION, DEFAULT_ANIMATION_ANGLE, 1, Btn);
end;

procedure TSvgBtnUI.SetSvgFile(const Value: string);
begin
  FSvgFile := Value;
  FSvg := XResource_LoadZipSvg(PChar(FSvgFile));
end;

procedure TSvgBtnUI.SetSvgSize(const Value: TSize);
begin
  FSvgSize := Value;
  if XC_GetObjectType(FSvg) = XC_SVG then
    XSvg_SetSize(FSvg, Value.cx, Value.cy);
end;

procedure TSvgBtnUI.SetHint(const Value: string);
begin
  FHintText := Value;
  if Assigned(FHint) then
    FHint.Free;
  if (Value <> '') and (Tooltip = nil) then
  begin
    FHint := THintUI.RegisterHint(Handle, Value);
    FHint.EnableAnimation := True;
  end
  else if (Value = '') and (Tooltip <> nil) then
    FHint.UnregisterHint;
end;

procedure TSvgBtnUI.SetOffsetSvg(left, Top: Integer);
begin
  FSvgOffSetLeft := left;
  FSvgOffSetTop := Top;
  if Handle <> 0 then
    XEle_Redraw(Handle, True);
end;

procedure TSvgBtnUI.SetOffsetText(left, Top: Integer);
begin
  FTextOffLeft := left;
  FTextOffTop := Top;
  if Handle <> 0 then
    XEle_Redraw(Handle, True);
end;

procedure TSvgBtnUI.Style(SvgFileName, BtnHintText: string; SvgWidth, SvgHeight: integer; SvgEnableAnima: Boolean);
begin
  SvgFile := SvgFileName;
  HintText := BtnHintText; // 初始化 HintText
  SvgSize := Tsize.Create(SvgWidth, SvgHeight);
  EnableAnima := SvgEnableAnima;
end;

class function TSvgBtnUI.OnDESTROY(hBtn: Integer; pbHandled: PBoolean): Integer;
var
  SvgBtnUI: TSvgBtnUI;
begin
  Result := 0;
  SvgBtnUI := GetClassFormHandle(hBtn);
  SvgBtnUI.Free;
end;

class function TSvgBtnUI.OnPAINT(hBtn: Integer; hDraw: Integer; pbHandled: PBoolean): Integer;
var
  SvgBtnUI: TSvgBtnUI;
begin
  Result := 0;
  pbHandled^ := True;
  SvgBtnUI := GetClassFormHandle(hBtn);
  SvgBtnUI.PAINT(hDraw);
end;

procedure TSvgBtnUI.PAINT(hDraw: Integer);
var
  RC, IconRect: TRect;
  TextSize: TSize;
  TextLeft, TextTop: Integer;
begin
  // 1. Draw Background & Border
  GetClientRect(RC);
  if FBackgroundColor <> TRANSPARENT_COLOR then
  begin
    XDraw_SetBrushColor(hDraw, FBackgroundColor);
    if FCornerRadius > MIN_CORNER_RADIUS then
      XDraw_FillRoundRectEx(hDraw, RC, FCornerRadius, FCornerRadius, FCornerRadius, FCornerRadius)
    else
      XDraw_FillRect(hDraw, RC);
  end;

  if FEnableBorder then
  begin
    if GetState = common_state3_leave then
      XDraw_SetBrushColor(hDraw, Theme_BtnBkColor_Leave)
    else if GetState = common_state3_stay then
      XDraw_SetBrushColor(hDraw, Theme_BtnBkColor_stay)
    else if GetState = common_state3_down then
      XDraw_SetBrushColor(hDraw, Theme_BtnBkColor_down);
    XDraw_DrawRoundRectEx(hDraw, RC, FCornerRadius, FCornerRadius, FCornerRadius, FCornerRadius);
  end;

  // 2. Get Text Size
  XDraw_SetFont(hDraw, FFont);
  XC_GetTextShowRect(PWideChar(Text), -1, FFont, textAlignFlag_center or textAlignFlag_vcenter, RC.Width, TextSize);

  // 3. Draw the Icon and get positioning
  PaintContent(hDraw, RC, TextSize, IconRect, TextLeft, TextTop);

  // 4. Draw Text
  RC.Top := TextTop + FTextOffTop;
  RC.Left := TextLeft + FTextOffLeft;
  XDraw_SetTextAlign(hDraw, TextAlign);
  XDraw_SetBrushColor(hDraw, Theme_TextColor_Leave);
  XDraw_DrawText(hDraw, PWideChar(Text), -1, RC);
end;

procedure TSvgBtnUI.PaintContent(hDraw: Integer; const AClientRect: TRect; const ATextSize: TSize; out AIconRect: TRect; out ATextLeft, ATextTop: Integer);
var
  nWidth, nHeight: Integer;
  hSvg: Integer;
begin
  AIconRect := Rect(0, 0, 0, 0);
  hSvg := FSvg;
  XDraw_SetBrushColor(hDraw, Theme_TextColor_Leave);

  if XC_GetObjectType(hSvg) = XC_SVG then
  begin
    if FUseCustomIconColor then
    begin
      // 使用自定义图标颜色
      XSvg_SetUserFillColor(hSvg, FIconColor, True);
    end
    else
    begin
      // 使用默认主题颜色
      if GetState = common_state3_leave then
        XSvg_SetUserFillColor(hSvg, Theme_SvgColor_Leave, True)
      else if GetState = common_state3_stay then
        XSvg_SetUserFillColor(hSvg, Theme_SvgColor_Stay, True)
      else if GetState = common_state3_down then
        XSvg_SetUserFillColor(hSvg, Theme_SvgColor_Down, True);
    end;

    FSpace := Ord(Text <> '') * DEFAULT_SPACE;
    nWidth := XSvg_GetWidth(hSvg) + FSpace + ATextSize.cx;
    nHeight := XSvg_GetHeight(hSvg);
    ATextTop := AClientRect.Top + Round((AClientRect.Height - nHeight) / 2);
    ATextLeft := AClientRect.Left + Round((AClientRect.Width - nWidth) / 2);

    AIconRect := Rect(ATextLeft, ATextTop, ATextLeft + XSvg_GetWidth(hSvg), ATextTop + XSvg_GetHeight(hSvg));
    OffsetRect(AIconRect, FSvgOffSetLeft, FSvgOffSetTop);

    XDraw_DrawSvgEx(hDraw, hSvg, AIconRect.Left, AIconRect.Top, XSvg_GetWidth(hSvg), XSvg_GetHeight(hSvg));
    ATextLeft := AIconRect.Right + FSpace;
  end
  else
  begin
    ATextTop := AClientRect.Top + Round((AClientRect.Height - ATextSize.Height) / 2);
    ATextLeft := AClientRect.Left + Round((AClientRect.Width - ATextSize.Width) / 2);
  end;
end;

{ TCheckableBtnUI }

destructor TCheckableBtnUI.Destroy;
begin
  if XC_GetObjectType(FCheckedSvg) = XC_SVG then
    XSvg_Release(FCheckedSvg);
  if XC_GetObjectType(FUncheckedSvg) = XC_SVG then
    XSvg_Release(FUncheckedSvg);
  inherited;
end;

procedure TCheckableBtnUI.Init;
begin
  inherited;
  FDrawUncheckedManually := False;
  FDrawCheckedManually := False;
end;

procedure TCheckableBtnUI.PaintContent(hDraw: Integer; const AClientRect: TRect; const ATextSize: TSize; out AIconRect: TRect; out ATextLeft, ATextTop: Integer);
var
  isChecked: Boolean;
  nWidth, nHeight: Integer;
  IconSize: TSize;
  hTheme: Integer;
begin
  isChecked := XBtn_IsCheck(Handle);

  if (isChecked and FDrawCheckedManually) or ((not isChecked) and FDrawUncheckedManually) then
  begin
    IconSize := SvgSize;
    FSpace := Ord(Text <> '') * DEFAULT_SPACE;
    nWidth := IconSize.cx + FSpace + ATextSize.cx;
    nHeight := Max(IconSize.cy, ATextSize.cy);
    ATextTop := AClientRect.Top + Round((AClientRect.Height - nHeight) / 2);
    ATextLeft := AClientRect.Left + Round((AClientRect.Width - nWidth) / 2);

    AIconRect.Left := ATextLeft + FSvgOffSetLeft;
    AIconRect.Top := ATextTop + Round((nHeight - IconSize.cy) / 2) + FSvgOffSetTop;
    AIconRect.Right := AIconRect.Left + IconSize.cx;
    AIconRect.Bottom := AIconRect.Top + IconSize.cy;

    if FUseCustomIconColor then
    begin
      hTheme := FIconColor; // 使用自定义图标颜色
    end
    else
    begin
      hTheme := Theme_TextColor_Leave;
      if GetState = common_state3_stay then
        hTheme := Theme_SvgColor_Stay
      else if GetState = common_state3_down then
        hTheme := Theme_SvgColor_Down;
    end;

    PaintManualIcon(hDraw, AIconRect, isChecked, hTheme);

    ATextLeft := AIconRect.Right + FSpace;
  end
  else
  begin
    if isChecked then
      FSvg := FCheckedSvg
    else
      FSvg := FUncheckedSvg;
    inherited PaintContent(hDraw, AClientRect, ATextSize, AIconRect, ATextLeft, ATextTop);
  end;
end;

procedure TCheckableBtnUI.Style(AUncheckedSvgFile, ACheckedSvgFile, BtnHintText: string; SvgWidth, SvgHeight: integer; SvgEnableAnima: Boolean);
begin
  inherited Style('', BtnHintText, SvgWidth, SvgHeight, SvgEnableAnima);
  if XC_GetObjectType(FUncheckedSvg) = XC_SVG then
    XSvg_Release(FUncheckedSvg);
  if AUncheckedSvgFile = '' then
  begin
    FDrawUncheckedManually := True;
    FUncheckedSvg := 0;
  end
  else
  begin
    FDrawUncheckedManually := False;
    FUncheckedSvg := XResource_LoadZipSvg(PChar(AUncheckedSvgFile));
  end;

  if XC_GetObjectType(FCheckedSvg) = XC_SVG then
    XSvg_Release(FCheckedSvg);
  if ACheckedSvgFile = '' then
  begin
    FDrawCheckedManually := True;
    FCheckedSvg := 0;
  end
  else
  begin
    FDrawCheckedManually := False;
    FCheckedSvg := XResource_LoadZipSvg(PChar(ACheckedSvgFile));
  end;

  if XC_GetObjectType(FUncheckedSvg) = XC_SVG then
    XSvg_SetSize(FUncheckedSvg, SvgWidth, SvgHeight);
  if XC_GetObjectType(FCheckedSvg) = XC_SVG then
    XSvg_SetSize(FCheckedSvg, SvgWidth, SvgHeight);

  if XBtn_IsCheck(Handle) then
    FSvg := FCheckedSvg
  else
    FSvg := FUncheckedSvg;
end;


{ TMultiSelectBtnUI }

procedure TMultiSelectBtnUI.PaintManualIcon(hDraw: Integer; AIconRect: TRect; isChecked: Boolean; hTheme: Integer);
var
  CheckPoints: array[0..2] of TPoint;
begin
  XDraw_SetBrushColor(hDraw, hTheme);
  XDraw_DrawRoundRect(hDraw, AIconRect, 3, 3);
  if isChecked then
  begin
    // 绘制对勾
    XDraw_SetBrushColor(hDraw, RGBA(255, 255, 255, 255));
    // 定义对勾的三个点
    CheckPoints[0] := TPoint.Create(AIconRect.Left + 3, AIconRect.Top + AIconRect.Height div 2);
    CheckPoints[1] := TPoint.Create(AIconRect.Left + AIconRect.Width div 2 - 1, AIconRect.Bottom - 4);
    CheckPoints[2] := TPoint.Create(AIconRect.Right - 4, AIconRect.Top + 4);
    // 绘制两条线段组成对勾
    XDraw_DrawLine(hDraw, CheckPoints[0].X, CheckPoints[0].Y, CheckPoints[1].X, CheckPoints[1].Y);
    XDraw_DrawLine(hDraw, CheckPoints[1].X, CheckPoints[1].Y, CheckPoints[2].X, CheckPoints[2].Y);
  end;
end;

{ TRadioBtnUI }

destructor TRadioBtnUI.Destroy;
begin
  StopAnimation;
  inherited;
end;

procedure TRadioBtnUI.Init;
begin
  inherited;
  FAnimationProgress := 0;
  FAnimationTimer := 0;
  FTargetChecked := False;
  FLastChecked := False;
  // 强制使用手动绘制模式以支持动画
  FDrawUncheckedManually := True;
  FDrawCheckedManually := True;
  RegEvent(XE_XC_TIMER, @OnAnimationTimer);
end;

procedure TRadioBtnUI.StartAnimation(AChecked: Boolean);
begin
  FTargetChecked := AChecked;
  StopAnimation; // 停止之前的动画
  
  if AChecked then
  begin
    // 开始圆形展开动画
    FAnimationProgress := 0;
    if XEle_SetXCTimer(Handle, RADIO_ANIMATION_TIMER_ID, 1000 div ANIMATION_FPS) then
      FAnimationTimer := RADIO_ANIMATION_TIMER_ID
    else
      FAnimationTimer := 0;
  end
  else
  begin
    // 开始圆形收缩动画
    FAnimationProgress := 1.0; // 从完整大小开始收缩
    if XEle_SetXCTimer(Handle, RADIO_ANIMATION_TIMER_ID, 1000 div ANIMATION_FPS) then
      FAnimationTimer := RADIO_ANIMATION_TIMER_ID
    else
      FAnimationTimer := 0;
  end;
end;

procedure TRadioBtnUI.StopAnimation;
begin
  if FAnimationTimer <> 0 then
  begin
    XEle_KillXCTimer(Handle, RADIO_ANIMATION_TIMER_ID);
    FAnimationTimer := 0;
  end;
end;

class function TRadioBtnUI.OnAnimationTimer(hEle: Integer; nID: Integer; pbHandled: PBoolean): Integer; stdcall;
var
  RadioBtnUI: TRadioBtnUI;
  AnimationStep: Single;
begin
  Result := 0;
  pbHandled^ := True;
  RadioBtnUI := GetClassFormHandle(hEle);
  
  if nID = RADIO_ANIMATION_TIMER_ID then
  begin
    AnimationStep := (1000 div ANIMATION_FPS) / RADIO_ANIMATION_DURATION;
    
    if RadioBtnUI.FTargetChecked then
    begin
      // 展开动画：进度递增
      RadioBtnUI.FAnimationProgress := RadioBtnUI.FAnimationProgress + AnimationStep;
      if RadioBtnUI.FAnimationProgress >= 1.0 then
      begin
        RadioBtnUI.FAnimationProgress := 1.0;
        RadioBtnUI.StopAnimation;
      end;
    end
    else
    begin
      // 收缩动画：进度递减
      RadioBtnUI.FAnimationProgress := RadioBtnUI.FAnimationProgress - AnimationStep;
      if RadioBtnUI.FAnimationProgress <= 0.0 then
      begin
        RadioBtnUI.FAnimationProgress := 0.0;
        RadioBtnUI.StopAnimation;
      end;
    end;
    
    RadioBtnUI.Redraw;
  end;
end;

procedure TRadioBtnUI.PaintContent(hDraw: Integer; const AClientRect: TRect; const ATextSize: TSize; out AIconRect: TRect; out ATextLeft, ATextTop: Integer);
var
  CurrentChecked: Boolean;
begin
  CurrentChecked := XBtn_IsCheck(Handle);
  
  // 初始化时如果已经是选中状态，设置动画进度为完成
  if (FLastChecked = False) and CurrentChecked and (FAnimationProgress = 0) and (FAnimationTimer = 0) then
  begin
    FAnimationProgress := 1.0;
    FTargetChecked := True;
  end;
  
  // 检测状态变化，触发动画
  if CurrentChecked <> FLastChecked then
  begin
    FLastChecked := CurrentChecked;
    StartAnimation(CurrentChecked);
  end;
  
  // 调用父类方法
  inherited PaintContent(hDraw, AClientRect, ATextSize, AIconRect, ATextLeft, ATextTop);
end;

procedure TRadioBtnUI.PaintManualIcon(hDraw: Integer; AIconRect: TRect; isChecked: Boolean; hTheme: Integer);
var
  LRectF: TRectF;
  CenterX, CenterY: Single;
  MaxRadius, CurrentRadius: Single;
  AnimatedRect: TRect;
  ShouldDrawInnerCircle: Boolean;
begin
  // 绘制外圆框
  XDraw_SetBrushColor(hDraw, hTheme);
  XDraw_SetLineWidthF(hDraw, 1.2);
  XDraw_DrawArcF(hDraw, AIconRect.Left + 0.5, AIconRect.Top + 0.5, AIconRect.Width - 1, AIconRect.Height - 1, 0, 360);

  // 判断是否需要绘制内圆：选中状态、正在播放动画或者动画进度大于0
  ShouldDrawInnerCircle := isChecked or (FAnimationProgress > 0);
  
  if ShouldDrawInnerCircle then
  begin
    // 计算圆心坐标
    CenterX := AIconRect.Left + AIconRect.Width / 2;
    CenterY := AIconRect.Top + AIconRect.Height / 2;
    
    // 计算最大半径（内缩3px）
    MaxRadius := (Min(AIconRect.Width, AIconRect.Height) - 6) / 2;
    
    // 根据动画进度计算当前半径
    if FAnimationTimer <> 0 then
      // 正在播放动画，使用动画进度（二次缓动）
      CurrentRadius := MaxRadius * FAnimationProgress * FAnimationProgress 
    else if isChecked then
      // 选中状态但没有动画，显示完整大小
      CurrentRadius := MaxRadius
    else
      // 未选中且没有动画，不显示内圆
      CurrentRadius := 0;
    
    if CurrentRadius > 0 then
    begin
      // 计算动画矩形
      AnimatedRect.Left := Round(CenterX - CurrentRadius);
      AnimatedRect.Top := Round(CenterY - CurrentRadius);
      AnimatedRect.Right := Round(CenterX + CurrentRadius);
      AnimatedRect.Bottom := Round(CenterY + CurrentRadius);
      
      // 绘制动态内圆
      LRectF := RectF(AnimatedRect.Left, AnimatedRect.Top, AnimatedRect.Right, AnimatedRect.Bottom);
      XDraw_FillEllipseF(hDraw, LRectF);
    end;
  end;
end;

end.

