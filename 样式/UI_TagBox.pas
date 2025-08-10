unit UI_TagBox;

interface

uses
  Windows, SysUtils, Classes, ShellAPI, XCGUI, UI_Edit, UI_Label, UI_Messages,
  Winapi.D2D1;

const
  // 按钮类型常量
  BTN_TYPE_NORMAL = 0;    // 普通按钮
  BTN_TYPE_RATING = 1;    // 评分按钮
  BTN_TYPE_YEAR = 2;      // 年份按钮

  // 五角星绘制常量
  STAR_OUTER_RADIUS = 10.0;    // 外圈半径（调整为10）
  STAR_INNER_RADIUS = 4.8;     // 内圈半径
  STAR_SPACING = 22;          // 星星间距
  STAR_LEFT_OFFSET = 9;       // 左侧偏移

  // 评分相关常量
  RATING_STARS_COUNT = 5;     // 星星总数
  RATING_PER_STAR = 2.0;      // 每颗星代表的评分


  // 圆角边框常量
  YEAR_BUTTON_RADIUS = 4;     // 年份按钮圆角半径

type
  TTagBoxUI = class(TEditUI)
  private
    FTagText: string;
    FStyle1: Integer;
    FActorText: string;
    FPlotText: string;
    FYear: Integer;
    FTagList: TStringList;
    FDefaultFont: Integer;
    FRatingFont: Integer; // 新增：评分按钮专用字体
    FRating: Single;
    FResolution: string;
    FDuration: Double;
    FFileFormat: string;
    FFrameRate: string;
    FBitrate: Int64;
    class function OnBtnPAINT(Btn: Integer; hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnBtnCLICK(Btn: Integer; pbHandled: PBoolean): Integer; stdcall; static;
  protected
    procedure SetTagText(const Value: string);
    procedure Init(); override;
  public
    destructor Destroy; override;
    procedure SplitString(const Input: string; Delimiter: Char);
    function FormatDuration(Seconds: Double): string; // 格式化时长为时分秒
    property TagText: string read FTagText write SetTagText;
    property ActorsText: string read FActorText write FActorText;
    property PlotText: string read FPlotText write FPlotText;
    property Year: Integer read FYear write FYear;
    property Rating: Single read FRating write FRating;
    property Resolution: string read FResolution write FResolution;
    property Duration: Double read FDuration write FDuration;
    property FileFormat: string read FFileFormat write FFileFormat;
    property FrameRate: string read FFrameRate write FFrameRate;
    property Bitrate: Int64 read FBitrate write FBitrate;
  end;

implementation

uses
  UI_Color, UI_Resource, System.Math;

destructor TTagBoxUI.Destroy;
begin
  inherited;
  FTagList.Free;
end;

procedure TTagBoxUI.Init;
var
  sz: TSize;
begin
  inherited;
  SetBorderSize(0, 0, 0, 0);
  FTagList := TStringList.Create;
  FDefaultFont := XRes_GetFont('微软雅黑10常规');
  FRatingFont := XRes_GetFont('微软雅黑9常规'); // 初始化评分按钮专用字体

  FStyle1 := XEdit_AddStyle(Handle, XRes_GetFont('微软雅黑10常规'), RGBA(255, 255, 255, 255), TRUE);
  SetFont(FDefaultFont);
  XC_GetTextShowSize(PChar('测试AB123'), -1, FDefaultFont, sz);
  SetRowHeight(sz.cy);
  FRating := -2; // 默认评分为-2，不显示评分按钮
  EnableReadOnly(False); // 修改：设置为可编辑
  SetCaretWidth(0);     // 新增：隐藏插入符
end;

class function TTagBoxUI.OnBtnPAINT(Btn, hDraw: Integer; pbHandled: PBoolean): Integer;
var
  RC: TRect;
  PText: PChar;
  SZ: TSize;
  RenderTarget: ID2D1RenderTarget;
  lBrush: ID2D1SolidColorBrush;
  lColor: D2D1_COLOR_F;
  D2DRC: TRect;
  Rating: Single;
  buttonType: Integer;
  buttonText: string;
  isRatingButton: Boolean;
  hasValidRating: Boolean;
  isYearButton: Boolean;
  i: Integer;
  lPathGeometry: ID2D1PathGeometry;
  lGeometrySink: ID2D1GeometrySink;
  lPoint: TD2D1Point2F;
  lAngle: Single;
  lFactory: ID2D1Factory;
  lHR: HRESULT;
  starCenter: TD2D1Point2F;
  isOuterVertex: Boolean;
  j: Integer;
  fullStars: Integer;
  halfStar: Boolean;
  halfColor: TD2D1ColorF;
  halfBrush: ID2D1SolidColorBrush;
  starRect: D2D1_RECT_F;
  TagBox: TTagBoxUI;
  scale: Single;
  outerRadius, innerRadius, starSpacing, starLeftOffset, yearButtonRadius: Single;
begin
  Result := 0;
  pbHandled^ := True;

  // 获取按钮信息
  PText := XBtn_GetText(Btn);
  buttonText := string(PText);
  buttonType := XEle_GetUserData(Btn);
  isRatingButton := (buttonType = BTN_TYPE_RATING);
  isYearButton := (buttonType = BTN_TYPE_YEAR);
  hasValidRating := isRatingButton and (buttonText <> '暂未评分');

  // 获取TagBox实例以访问字体和DPI缩放
  TagBox := TTagBoxUI(GetClassFormHandle(XWidget_GetParent(Btn)));
  scale := 1.0;
  if Assigned(TagBox) then
    scale := TagBox.DpiScale;

  // DPI自适应常量
  outerRadius := STAR_OUTER_RADIUS * scale;
  innerRadius := STAR_INNER_RADIUS * scale;
  starSpacing := STAR_SPACING * scale;
  starLeftOffset := STAR_LEFT_OFFSET * scale;
  yearButtonRadius := YEAR_BUTTON_RADIUS * scale;

  XEle_GetClientRect(Btn, RC);

    // 设置按钮背景色和绘制圆角边框
  if isYearButton then
  begin
    // 年份按钮：绘制圆角边框，使用文字颜色
    XDraw_EnableSmoothingMode(hDraw, True);
    XDraw_SetBrushColor(hDraw, Theme_SvgLabel_TextColor);
    XDraw_DrawRoundRectEx(hDraw, RC, Round(yearButtonRadius), Round(yearButtonRadius), Round(yearButtonRadius), Round(yearButtonRadius));
  end
  else if buttonType <> BTN_TYPE_NORMAL then
  begin
    // 如果是评分按钮且文本为"暂未评分"，使用普通颜色
    if isRatingButton and (buttonText = '暂未评分') then
      XDraw_SetBrushColor(hDraw, Theme_EDit_TextColor)
    else
      XDraw_SetBrushColor(hDraw, Theme_PrimaryColor);
  end
  else
    XDraw_SetBrushColor(hDraw, Theme_EDit_TextColor);

  // 如果是评分按钮且有有效评分，绘制五角星
  if isRatingButton and (buttonText <> '暂未评分') then
  begin
    RenderTarget := ID2D1RenderTarget(XDraw_GetD2dRenderTarget(hDraw));
    if Assigned(RenderTarget) then
    begin
      XEle_GetWndClientRectDPI(Btn, D2DRC);
      Rating := StrToFloatDef(buttonText, -1.0);
      if Rating < 0 then
        Rating := 0;
      if Rating > RATING_STARS_COUNT * RATING_PER_STAR then
        Rating := RATING_STARS_COUNT * RATING_PER_STAR;
      // 计算主色星星数量和半星
      fullStars := Trunc(Rating / RATING_PER_STAR);
      halfStar := (Frac(Rating / RATING_PER_STAR) >= 0.5);
      for i := 1 to RATING_STARS_COUNT do
      begin
        // 选择颜色
        if i <= fullStars then
          lColor := RGBAToD2D1ColorF(Theme_PrimaryColor)
        else
        begin
          lColor := RGBAToD2D1ColorF(Theme_SvgLabel_TextColor);
          lColor.a := 0.26; // 90%不透明
        end;
        if SUCCEEDED(RenderTarget.CreateSolidColorBrush(lColor, nil, lBrush)) and Assigned(lBrush) then
        try
          // 计算五角星中心
          starCenter.x := D2DRC.Left + starLeftOffset + ((i - 1) * starSpacing);
          starCenter.y := D2DRC.Top + (D2DRC.Height / 2);
          // 创建路径几何体
          lFactory := ID2D1Factory(XC_GetD2dFactory);
          if not Assigned(lFactory) then
            Continue;
          lHR := lFactory.CreatePathGeometry(lPathGeometry);
          if not SUCCEEDED(lHR) or (not Assigned(lPathGeometry)) then
            Continue;
          try
            lHR := lPathGeometry.Open(lGeometrySink);
            if not SUCCEEDED(lHR) or (not Assigned(lGeometrySink)) then
              Continue;
            try
              lAngle := -Pi / 2;
              lPoint.x := starCenter.x + Cos(lAngle) * outerRadius;
              lPoint.y := starCenter.y + Sin(lAngle) * outerRadius;
              lGeometrySink.BeginFigure(lPoint, D2D1_FIGURE_BEGIN_FILLED);
              for j := 1 to 9 do
              begin
                lAngle := lAngle + (Pi / 5.0);
                isOuterVertex := (j mod 2 = 0);
                if isOuterVertex then
                begin
                  lPoint.x := starCenter.x + Cos(lAngle) * outerRadius;
                  lPoint.y := starCenter.y + Sin(lAngle) * outerRadius;
                end
                else
                begin
                  lPoint.x := starCenter.x + Cos(lAngle) * innerRadius;
                  lPoint.y := starCenter.y + Sin(lAngle) * innerRadius;
                end;
                lGeometrySink.AddLine(lPoint);
              end;
              lGeometrySink.EndFigure(D2D1_FIGURE_END_CLOSED);
            finally
              lGeometrySink.Close;
            end;
            // 填充五角星
            if (i = fullStars + 1) and halfStar then
            begin
              // 半星填充
              // 先用年份色填充整星
              RenderTarget.FillGeometry(lPathGeometry, lBrush, nil);
              // 再用主色填充左半边
              halfColor := RGBAToD2D1ColorF(Theme_PrimaryColor);
              if SUCCEEDED(RenderTarget.CreateSolidColorBrush(halfColor, nil, halfBrush)) and Assigned(halfBrush) then
              try
                // 只填充左半边
                starRect := D2D1RectF(starCenter.x - outerRadius, starCenter.y - outerRadius, starCenter.x, starCenter.y + outerRadius);
                RenderTarget.PushAxisAlignedClip(starRect, D2D1_ANTIALIAS_MODE_PER_PRIMITIVE);
                RenderTarget.FillGeometry(lPathGeometry, halfBrush, nil);
                RenderTarget.PopAxisAlignedClip();
              finally
                halfBrush := nil;
              end;
            end
            else
            begin
              RenderTarget.FillGeometry(lPathGeometry, lBrush, nil);
            end;
          finally
            lPathGeometry := nil;
          end;
        finally
          lBrush := nil;
        end;
      end;
    end;
  end;

  // 绘制文本
  if isRatingButton and Assigned(TagBox) then
  begin
    XDraw_SetFont(hDraw, TagBox.FRatingFont);
    XC_GetTextShowSize(PText, -1, TagBox.FRatingFont, SZ);
  end
  else
  begin
    XDraw_SetFont(hDraw, XEle_GetFont(Btn));
    XC_GetTextShowSize(PText, -1, XEle_GetFont(Btn), SZ);
  end;

  // 设置文本颜色
  if isYearButton then
    XDraw_SetBrushColor(hDraw, Theme_SvgLabel_TextColor);

  // 计算文本位置
  if isRatingButton and hasValidRating then
  begin
    XDraw_SetTextAlign(hDraw, textAlignFlag_left or textAlignFlag_vcenter);
    // 文本位于最后一颗星右侧5个物理像素处
    RC.Left := Round((starLeftOffset + (RATING_STARS_COUNT - 1) * starSpacing + outerRadius + 5) / scale);
  end
  else
  begin
    XDraw_SetTextAlign(hDraw, textAlignFlag_center or textAlignFlag_vcenter);
    RC.Left := Round(((RC.width - RC.Left) - SZ.cx) / 2);  // 无评分时, 文本居中
  end;

  XDraw_DrawText(hDraw, PText, -1, RC);
end;

class function TTagBoxUI.OnBtnCLICK(Btn: Integer; pbHandled: PBoolean): Integer;
var
  Text: string;
begin
  Result := 0;
  pbHandled^ := True;
  Text := XBtn_GetText(Btn);
  SendMessage(XWidget_GetHWND(Btn), XE_TAGBOX_BUTTON_CLICK, Integer(PChar(Text)), Integer(GetClassFormHandle(Btn)));
end;

procedure TTagBoxUI.SplitString(const Input: string; Delimiter: Char);
begin
  FTagList.Clear;
  FTagList.Delimiter := Delimiter;
  FTagList.StrictDelimiter := True;
  FTagList.DelimitedText := Input;
end;

function TTagBoxUI.FormatDuration(Seconds: Double): string;
var
  Hours, Minutes, Secs: Integer;
begin
  if Seconds <= 0 then
  begin
    Result := '';
    Exit;
  end;

  Hours := Trunc(Seconds) div 3600;
  Minutes := (Trunc(Seconds) mod 3600) div 60;
  Secs := Trunc(Seconds) mod 60;
  Result := Format('%.2d:%.2d:%.2d', [Hours, Minutes, Secs]);
end;

procedure TTagBoxUI.SetTagText(const Value: string);
var
  s: string;
  Btn: Integer;
  sz: TSize;
  i: Integer;
  YearText: string;
  RatingText: string;
  InfoText: string; // 新增，兼容XE那你
  InfoLabel: TSvgLabelUI;
begin
  SetText('');
  FTagText := Value;

  AddText('');
  if FYear > 0 then
  begin
    YearText := Format('%d', [FYear]);
    XC_GetTextShowSize(PChar(YearText), -1, FDefaultFont, sz);
    Btn := XBtn_Create(0, 0, sz.cx, sz.cy - 2, PChar(YearText), Handle);
    XEle_SetFont(Btn, FDefaultFont);
    XEle_SetUserData(Btn, BTN_TYPE_YEAR);
    XEle_RegEvent(Btn, XE_PAINT, @OnBtnPAINT);
    AddObject(Btn);
    AddText(' ');
  end;

  // 评分为-2时，评分按钮完全不显示
  if FRating > -2 then
  begin
    if FRating < 0 then
    begin
      RatingText := '暂未评分';
      XC_GetTextShowSize(PChar(RatingText), -1, FDefaultFont, sz);
      Btn := XBtn_Create(0, 0, sz.cx, sz.cy - 2, PChar(RatingText), Handle);
    end
    else
    begin
      RatingText := Format('%.1f', [FRating]);
      XC_GetTextShowSize(PChar(RatingText), -1, FDefaultFont, sz);
      Btn := XBtn_Create(0, 0, Round(STAR_LEFT_OFFSET + (RATING_STARS_COUNT - 1) * STAR_SPACING + STAR_OUTER_RADIUS + (5 / DpiScale) + sz.cx + STAR_LEFT_OFFSET), sz.cy - 2, PChar(RatingText), Handle);
    end;
    XEle_SetFont(Btn, FDefaultFont);
    XEle_SetUserData(Btn, BTN_TYPE_RATING);
    XEle_RegEvent(Btn, XE_PAINT, @OnBtnPAINT);
    AddObject(Btn);
  end;

  AddText(#13#10);

  // 合并分辨率、时长、码率、帧率、格式为一个按钮
  InfoText := '';
  if (FResolution <> '') then
    InfoText := InfoText + FResolution + ' ';
  if (FDuration > 0) then
    InfoText := InfoText + FormatDuration(FDuration) + ' ';
  if (FBitrate > 0) then
    InfoText := InfoText + Format('%dkbps', [FBitrate div 1000]) + ' ';
  if (FFrameRate <> '') and (FFrameRate <> 'N/A') then
    InfoText := InfoText + FFrameRate + 'fps ';
  if (FFileFormat <> '') then
    InfoText := InfoText + FFileFormat + ' ';
  InfoText := Trim(InfoText);
  XC_GetTextShowSize(PChar(InfoText), -1, FDefaultFont, sz);
  InfoLabel := TSvgLabelUI.Create(0, 0, 0, 0, Self);
  InfoLabel.SvgFile := '窗口组件\标签.svg';
  InfoLabel.AutoSize := True;
  InfoLabel.Text := InfoText;

  if InfoText <> '' then
  begin
    AddObject(InfoLabel.Handle);
    AddText(#13#10);

  end;

  if FTagText <> '' then
  begin
    SplitString(FTagText, '/');
    for i := 0 to FTagList.Count - 1 do
    begin
      s := FTagList[i];
      XC_GetTextShowSize(PChar(s), -1, FDefaultFont, sz);
      Btn := XBtn_Create(0, 0, sz.cx - 2, sz.cy - 2, PChar(s), Handle);
      XEle_SetFont(Btn, FDefaultFont);
      XEle_SetCursor(Btn, LoadCursor(0, IDC_HAND));
      XEle_RegEvent(Btn, XE_PAINT, @OnBtnPAINT);
      XEle_RegEvent(Btn, XE_BNCLICK, @OnBtnCLICK);
      AddObject(Btn);
    end;
  end;

  if (FTagText <> '') and (FActorText <> '') then
  begin
    AddText(#13#10);

    AddText(#13#10);

  end;

  if FActorText <> '' then
  begin
    XC_GetTextShowSize(PChar('演员: '), -1, FDefaultFont, sz);
    Btn := XBtn_Create(0, 0, sz.cx - 2, sz.cy - 2, PChar('演员: '), Handle);
    XEle_SetFont(Btn, FDefaultFont);
    XEle_RegEvent(Btn, XE_PAINT, @OnBtnPAINT);
    AddObject(Btn);
    SplitString(FActorText, '/');
    for i := 0 to FTagList.Count - 1 do
    begin
      s := FTagList[i];
      XC_GetTextShowSize(PChar(s), -1, FDefaultFont, sz);
      Btn := XBtn_Create(0, 0, sz.cx - 2, sz.cy - 2, PChar(s), Handle);
      XEle_SetFont(Btn, FDefaultFont);
      XEle_SetCursor(Btn, LoadCursor(0, IDC_HAND));
      XEle_RegEvent(Btn, XE_PAINT, @OnBtnPAINT);
     // XEle_RegEvent(Btn, XE_BNCLICK, @OnBtnCLICK);
      AddObject(Btn);
    end;
  end;

  if FPlotText <> '' then
  begin
    AddText(#13#10);

    AddText(#13#10);

    AddTextEx('简介: ', FStyle1);
    AddText(PChar(FPlotText));
  end;

end;

end.


