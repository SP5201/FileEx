unit UI_MovieListView;

interface

uses
  Windows, Classes, Messages, XCGUI, SysUtils, XListview, UI_Messages,
  UI_ListView, UI_Edit, System.Math, XD2DRenderer, UI_Element, D2D1;

type
  TMovieListViewUI = class(TListViewUI)
  private
    FItemRadius: Integer;
    FRenameEdit: Integer;
    FRenameGroup: Integer;
    FRenameItem: Integer;
    FIsRenaming: Boolean; // 新增字段
    FItemRoundRC: TRect;
    FD2DRenderer: TXD2DRenderer;
    FBorderLightPos: Single; // 追光动画位置
    FBorderLightTimer: Integer;
    FPathPoints: TArray<D2D1_POINT_2F>;
    FPathDists: TArray<Single>;
    FPathTotalLength: Single;
    FStrokeStyle: ID2D1StrokeStyle;
    FDefaultSVG: Integer; // SVG图片句柄
    procedure SetItemRadius(AValue: Integer);
    function FindSegmentIndex(pos: Single): Integer;
    procedure UpdateCachedPathData;
    function CreateLightStreamGeometry(const Factory: ID2D1Factory; startPos, endPos: Single): ID2D1PathGeometry;
    class function LerpPoint(const a, b: D2D1_POINT_2F; t: Single): D2D1_POINT_2F; static;
  protected
    procedure Init(); override;
    procedure OnDrawItemPaint(hDraw: Integer; var pItem: Tlistview_item_); override;
    class function OnReNameKillFOCUS(FRenameEdit: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnReNameKeyDown(FRenameEdit: Integer; wParam: WPARAM; lParam: LPARAM; pbHandled: PBoolean): Integer; stdcall; static;
    procedure OnViewTemplateCreateEnd(pItem: TlistView_item_; nFlag: Integer; pbHandled: PBoolean); override;
    class function OnElePAINT(hEle, hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function TimerProc(hEle, nTimerID: Integer; pbHandled: PBoolean): Integer; stdcall; static;
  public
    destructor Destroy; override;
    procedure UpdateTitle(const FilePath, NewTitle: string);
    procedure ReName(iGroup: Integer; iItem: Integer);
    property ItemRadius: Integer read FItemRadius write SetItemRadius;
  end;

implementation

uses
  UI_Resource, UI_Color, UI_ScrollBar, UI_Menu, UI_Animation;

procedure TMovieListViewUI.SetItemRadius(AValue: Integer);
begin
  if FItemRadius <> AValue then
  begin
    FItemRadius := AValue;
    UpdateCachedPathData;
    Redraw;
  end;
end;

destructor TMovieListViewUI.Destroy;
begin
  FD2DRenderer.ReleaseDraw;
  XEle_KillXCTimer(Handle, FBorderLightTimer);
  FStrokeStyle := nil;
  if XC_GetObjectType(FDefaultSVG)=XC_SVG then
  begin
    XSvg_Destroy(FDefaultSVG);
    FDefaultSVG := 0;
  end;
  inherited;
end;

procedure TMovieListViewUI.Init;
begin
  inherited;
  ItemFont := XRes_GetFont('微软雅黑10常规');
  FItemRadius := 0;
  FRenameGroup := -1;
  FRenameItem := -1;
  SetColumnSpace(20);
  SetRowSpace(20);
  // 明确设置列表项宽度和高度，适应主副标题
  ItemSize := TSize.Create(147, 240); // 宽度147，高度250
  SetItemTemplate(XResource_LoadZipTemp(listItemTemp_type_listView_item, 'MovieListView_Item.xml'));
  FD2DRenderer := TXD2DRenderer.Create(Gethwindow);
  // 追光动画参数
  FBorderLightPos := 0;
  FBorderLightTimer := 1001;
  UpdateCachedPathData;
  XEle_SetXCTimer(Handle, FBorderLightTimer, 30); // 30ms刷新
  RegEvent(XE_XC_TIMER, @TimerProc);
  FDefaultSVG := XResource_LoadZipSvg('窗口组件\列表不存在.svg'); // 路径根据实际情况调整
  XSvg_SetUserFillColor(FDefaultSVG, RGBA(255, 255, 255, 15), True);
end;

procedure TMovieListViewUI.OnDrawItemPaint(hDraw: Integer; var pItem: Tlistview_item_);
var
  ItemData: PListViewItemData;
  RC, SubRC: TRect;
  ImgRect: TRect;
  SvgWidth, SvgHeight, SvgLeft, SvgTop: Integer;
begin
  ItemData := ItemUserData(pItem.iItem);

  FItemRoundRC := TRect.Create(FItemRadius, FItemRadius, FItemRadius, FItemRadius);
  // 图片绘制区域为147*200，居中于项
  ImgRect.Left := pItem.rcItem.Left + (pItem.rcItem.Width - 147) div 2;
  ImgRect.Top := pItem.rcItem.Top + 0;
  ImgRect.Right := ImgRect.Left + 147;
  ImgRect.Bottom := ImgRect.Top + 200;
  if XC_GetObjectType(ItemData.dwImage) = XC_IMAGE then
    XDraw_ImageMaskRect(hDraw, ItemData.dwImage, ImgRect, ImgRect, FItemRoundRC)
  else
  begin
    XDraw_SetBrushColor(hDraw, RGBA(255, 255, 255, 5));
    XDraw_FillRoundRectEx(hDraw, ImgRect, FItemRoundRC.Left, FItemRoundRC.Top, FItemRoundRC.Right, FItemRoundRC.Bottom);
    SvgWidth := 50;
    SvgHeight := 50;
    SvgLeft := ImgRect.Left + (ImgRect.Width - SvgWidth) div 2;
    SvgTop := ImgRect.Top + (ImgRect.Height - SvgHeight) div 2;
    XDraw_DrawSvgEx(hDraw, FDefaultSVG, SvgLeft, SvgTop, SvgWidth, SvgHeight);
  end;

  case pItem.nState of
    list_item_state_leave:
      XDraw_SetBrushColor(hDraw, Theme_TextColor_Leave);
    list_item_state_stay, list_item_state_select:
      XDraw_SetBrushColor(hDraw, Theme_TextColor_Stay);
  end;

  if (pItem.iGroup = FRenameGroup) and (pItem.iItem = FRenameItem) then
    Exit;

  XDraw_SetFont(hDraw, ItemFont);
  RC.Top := pItem.rcItem.Top + 200 + 4;
  RC.Bottom := RC.Top + 20;
  RC.Left := pItem.rcItem.Left + 4;
  RC.Right := pItem.rcItem.Right - 4;
  XDraw_SetTextAlign(hDraw, ItemTextAlign);
  XDraw_DrawText(hDraw, PWideChar(ItemData^.dwName), -1, RC);

  // 绘制副标题，居中
  SubRC := RC;
  SubRC.Top := RC.Bottom + 2;
  SubRC.Bottom := SubRC.Top + 16;
  XDraw_SetFont(hDraw, ItemFont); // 可自定义副标题字体/
  XDraw_SetTextAlign(hDraw, textAlignFlag_center or textAlignFlag_vcenter);
  XDraw_DrawText(hDraw, PWideChar(ItemData^.dwSubTitle), -1, SubRC);
end;

procedure TMovieListViewUI.ReName(iGroup, iItem: Integer);
var
  Parent: Integer;
begin
  FIsRenaming := True; // 标记进入重命名
  FRenameGroup := iGroup;
  FRenameItem := iItem;
  Parent := XWidget_GetParent(GetTemplateObject(iGroup, iItem, 33));
  FRenameEdit := XEdit_Create(0, GetItemSize.cy - 28, GetItemSize.cx, 30, Parent);
  XEdit_SetText(FRenameEdit, PChar(ItemUserData(iItem)^.dwName));
  XEdit_EnableAutoSelAll(FRenameEdit, True);
  XEdit_SetCaretColor(FRenameEdit, RGBA(255, 255, 255, 180));
  XEdit_SetSelectBkColor(FRenameEdit, Theme_TextColor_Stay);
  XWnd_SetFocusEle(XWidget_GetHWINDOW(FRenameEdit), FRenameEdit);
  XEle_SetUserData(FRenameEdit, Integer(Self));
  XEle_SetFont(FRenameEdit, ItemFont);
  XEle_EnableBkTransparent(FRenameEdit, True);
  XEle_SetTextColor(FRenameEdit, Theme_TextColor_Leave);
  XELE_RegEvent(FRenameEdit, XE_KILLFOCUS, @OnReNameKillFOCUS);
  XELE_RegEvent(FRenameEdit, XE_KEYDOWN, @OnReNameKeyDown);
end;

procedure TMovieListViewUI.UpdateTitle(const FilePath, NewTitle: string);
var
  PItemdata: PListViewItemData;
begin
  if FPathMap.TryGetValue(FilePath, PItemdata) then
  begin
    PItemdata^.dwName := NewTitle;
    Redraw;
  end;
end;

class function TMovieListViewUI.OnReNameKeyDown(FRenameEdit: Integer; wParam: wParam; lParam: lParam; pbHandled: PBoolean): Integer;
var
  Text: string;
  MovieListViewUI: TMovieListViewUI;
  path: string;
begin
  Result := 0;
  if wParam = VK_RETURN then
  begin
    MovieListViewUI := TMovieListViewUI(XEle_GetUserData(FRenameEdit));
    path := MovieListViewUI.GetPathFromItem(MovieListViewUI.FRenameItem);
    Text := XEdit_GetText_Temp(FRenameEdit);
    if MovieListViewUI.ItemUserData(MovieListViewUI.FRenameItem)^.dwName <> Text then
      if Assigned(MovieListViewUI.OnItemRename) then
        MovieListViewUI.OnItemRename(MovieListViewUI, path, Text);
    XWnd_SetFocusEle(XWidget_GetHWINDOW(FRenameEdit), XWidget_GetParent(FRenameEdit));
    MovieListViewUI.FIsRenaming := False; // 结束重命名
  end;
end;

class function TMovieListViewUI.OnReNameKillFOCUS(FRenameEdit: Integer; pbHandled: PBoolean): Integer;
var
  MovieListViewUI: TMovieListViewUI;
begin
  Result := 0;
  MovieListViewUI := TMovieListViewUI(XEle_GetUserData(FRenameEdit));
  MovieListViewUI.FRenameGroup := -1;
  MovieListViewUI.FRenameItem := -1;
  MovieListViewUI.FIsRenaming := False; // 结束重命名
  if XC_GetObjectType(FRenameEdit) = XC_EDIT then
    XEle_Destroy(FRenameEdit);
end;

procedure TMovieListViewUI.OnViewTemplateCreateEnd(pItem: TlistView_item_; nFlag: Integer; pbHandled: PBoolean);
var
  hEle: Integer;
  EleUI: TEleUI;
begin
  inherited OnViewTemplateCreateEnd(pItem, nFlag, pbHandled);

  if nFlag = 2 then
    Exit;

  if (pItem.iItem >= 0) and (pItem.iGroup >= 0) then
  begin
    hEle := XListView_GetTemplateObject(Handle, pItem.iGroup, pItem.iItem, 33);
    EleUI := TEleUI.FromHandle(hEle);
    if EleUI.IsHELE then
    begin
      EleUI.RegEvent(XE_PAINT, @OnElePAINT);
    end;
  end;
end;

class function TMovieListViewUI.OnElePAINT(hEle, hDraw: Integer; pbHandled: PBoolean): Integer; stdcall;
var
  RenderTarget: ID2D1RenderTarget;
  Factory: ID2D1Factory;
  LightGeometry1, LightGeometry2: ID2D1PathGeometry;
  Brush: ID2D1SolidColorBrush;
  ItemData: PListViewItemData;
  ListView: TMovieListViewUI;
  iGroup, iItem: Integer;
  lightLength, startPos1, endPos1, startPos2, endPos2, offsetX, offsetY: Single;
  rcEle: TRect;
  transform: D2D1_MATRIX_3X2_F;
  scaleX, scaleY, physicalWidth, physicalHeight, logicalWidth, logicalHeight: Single;
begin
  Result := 0;
  ItemData := PListViewItemData(XEle_GetUserData(hEle));
  if ItemData = nil then
    Exit;
  ListView := TMovieListViewUI.FromHandle(ItemData.ListViewHandle);
  XListView_GetItemIDFromHXCGUI(ItemData.ListViewHandle, hEle, iGroup, iItem);

  if (ListView.GetItemSelect(iGroup) <> iItem) or (ListView.FPathTotalLength = 0) then
  begin
    pbHandled^ := True;
    Exit;
  end;

  pbHandled^ := True;

  RenderTarget := ID2D1RenderTarget(XDraw_GetD2dRenderTarget(hDraw));
  Factory := ID2D1Factory(XC_GetD2dFactory);
  if (RenderTarget = nil) or (Factory = nil) or (ListView.FStrokeStyle = nil) then
    Exit;

  XEle_GetWndClientRectDPI(hEle, rcEle);
  offsetX := rcEle.Left;
  offsetY := rcEle.Top;

  physicalWidth := rcEle.Right - rcEle.Left;
  physicalHeight := rcEle.Bottom - rcEle.Top;
  logicalWidth := ListView.GetItemSize.Width;
  logicalHeight := ListView.GetItemSize.Height;

  if (logicalWidth > 0) and (logicalHeight > 0) then
  begin
    scaleX := physicalWidth / logicalWidth;
    scaleY := physicalHeight / logicalHeight;
  end
  else
  begin
    scaleX := 1.0;
    scaleY := 1.0;
  end;

  transform._11 := scaleX;
  transform._12 := 0.0;
  transform._21 := 0.0;
  transform._22 := scaleY;
  transform._31 := offsetX;
  transform._32 := offsetY;
  RenderTarget.SetTransform(transform);

  lightLength := ListView.FPathTotalLength / 6;
  startPos1 := ListView.FPathTotalLength * ListView.FBorderLightPos;
  endPos1 := startPos1 + lightLength;
  startPos2 := ListView.FPathTotalLength * Frac(ListView.FBorderLightPos + 0.5);
  endPos2 := startPos2 + lightLength;

  LightGeometry1 := ListView.CreateLightStreamGeometry(Factory, startPos1, endPos1);
  LightGeometry2 := ListView.CreateLightStreamGeometry(Factory, startPos2, endPos2);

  if (LightGeometry1 <> nil) or (LightGeometry2 <> nil) then
  begin
    RenderTarget.CreateSolidColorBrush(RGBAToD2D1ColorF(RGBA(255, 255, 255, 200)), nil, Brush);
    if Brush <> nil then
    begin
      if LightGeometry1 <> nil then
        RenderTarget.DrawGeometry(LightGeometry1, Brush, 1, ListView.FStrokeStyle);
      if LightGeometry2 <> nil then
        RenderTarget.DrawGeometry(LightGeometry2, Brush, 1, ListView.FStrokeStyle);
    end;
  end;

  transform._11 := 1.0;
  transform._12 := 0.0;
  transform._21 := 0.0;
  transform._22 := 1.0;
  transform._31 := 0.0;
  transform._32 := 0.0;
  RenderTarget.SetTransform(transform);
end;

class function TMovieListViewUI.TimerProc(hEle, nTimerID: Integer; pbHandled: PBoolean): Integer; stdcall;
var
  Self: TMovieListViewUI;
begin
  Result := 0;
  if nTimerID = 1001 then
  begin
    Self := TMovieListViewUI.GetClassFormHandle(hEle);
    Self.FBorderLightPos := Self.FBorderLightPos + 0.01;
    if Self.FBorderLightPos > 1 then
      Self.FBorderLightPos := Self.FBorderLightPos - 1;
    XEle_Redraw(hEle);
  end;
end;

function TMovieListViewUI.FindSegmentIndex(pos: Single): Integer;
var
  i: Integer;
begin
  for i := 0 to Length(FPathDists) - 2 do
  begin
    if (FPathDists[i] <= pos) and (FPathDists[i + 1] > pos) then
    begin
      Result := i;
      Exit;
    end;
  end;

  if pos >= FPathTotalLength then
    Result := Length(FPathDists) - 2
  else
    Result := -1;
end;

procedure TMovieListViewUI.UpdateCachedPathData;
var
  rcF: D2D1_RECT_F;
  radius, rIn, segLen, angle, t: Single;
  segs, i, segN, segIdx, iInSeg: Integer;
  Factory: ID2D1Factory;
  StrokeProps: D2D1_STROKE_STYLE_PROPERTIES;
  rcIn: D2D1_RECT_F;
begin
  // 只覆盖图片区域：0,0,147,200
  rcF := D2D1RectF(0, 0, 147, 200);
  radius := FItemRadius;
  segs := 128; // 必须是8的倍数
  segN := segs div 8;
  if segN = 0 then
    Exit;

  rcIn.left := Floor(rcF.left) + 0.5;
  rcIn.top := Floor(rcF.top) + 0.5;
  rcIn.right := Floor(rcF.right) - 0.5;
  rcIn.bottom := Floor(rcF.bottom) - 0.5;
  rIn := Floor(radius);

  SetLength(FPathPoints, segs + 1);

  for i := 0 to segs - 1 do
  begin
    segIdx := i div segN;
    iInSeg := i mod segN;
    if segN = 1 then
      t := 0
    else
      t := iInSeg / (segN - 1);

    case segIdx of
      0: // 上边
        begin
          FPathPoints[i].x := (rcIn.left + rIn) + t * (rcIn.right - rIn - (rcIn.left + rIn));
          FPathPoints[i].y := rcIn.top;
        end;
      1: // 右上角
        begin
          angle := -Pi / 2 + t * (Pi / 2);
          FPathPoints[i].x := rcIn.right - rIn + rIn * Cos(angle);
          FPathPoints[i].y := rcIn.top + rIn + rIn * Sin(angle);
        end;
      2: // 右边
        begin
          FPathPoints[i].x := rcIn.right;
          FPathPoints[i].y := (rcIn.top + rIn) + t * (rcIn.bottom - rIn - (rcIn.top + rIn));
        end;
      3: // 右下角
        begin
          angle := 0 + t * (Pi / 2);
          FPathPoints[i].x := rcIn.right - rIn + rIn * Cos(angle);
          FPathPoints[i].y := rcIn.bottom - rIn + rIn * Sin(angle);
        end;
      4: // 下边
        begin
          FPathPoints[i].x := (rcIn.right - rIn) + t * (rcIn.left + rIn - (rcIn.right - rIn));
          FPathPoints[i].y := rcIn.bottom;
        end;
      5: // 左下角
        begin
          angle := Pi / 2 + t * (Pi / 2);
          FPathPoints[i].x := rcIn.left + rIn + rIn * Cos(angle);
          FPathPoints[i].y := rcIn.bottom - rIn + rIn * Sin(angle);
        end;
      6: // 左边
        begin
          FPathPoints[i].x := rcIn.left;
          FPathPoints[i].y := (rcIn.bottom - rIn) + t * (rcIn.top + rIn - (rcIn.bottom - rIn));
        end;
      7: // 左上角
        begin
          angle := Pi + t * (Pi / 2);
          FPathPoints[i].x := rcIn.left + rIn + rIn * Cos(angle);
          FPathPoints[i].y := rcIn.top + rIn + rIn * Sin(angle);
        end;
    end;
  end;
  FPathPoints[segs] := FPathPoints[0];

  SetLength(FPathDists, segs + 1);
  FPathTotalLength := 0;
  FPathDists[0] := 0;
  for i := 0 to segs - 1 do
  begin
    segLen := Hypot(FPathPoints[i + 1].x - FPathPoints[i].x, FPathPoints[i + 1].y - FPathPoints[i].y);
    FPathTotalLength := FPathTotalLength + segLen;
    FPathDists[i + 1] := FPathTotalLength;
  end;

  Factory := ID2D1Factory(XC_GetD2dFactory);
  if Factory <> nil then
  begin
    FillChar(StrokeProps, SizeOf(StrokeProps), 0);
    StrokeProps.startCap := D2D1_CAP_STYLE_ROUND;
    StrokeProps.endCap := D2D1_CAP_STYLE_ROUND;
    StrokeProps.dashCap := D2D1_CAP_STYLE_ROUND;
    StrokeProps.lineJoin := D2D1_LINE_JOIN_MITER;
    StrokeProps.miterLimit := 10.0;
    StrokeProps.dashStyle := D2D1_DASH_STYLE_SOLID;
    StrokeProps.dashOffset := 0.0;
    Factory.CreateStrokeStyle(StrokeProps, nil, 0, FStrokeStyle);
  end;
end;

function TMovieListViewUI.CreateLightStreamGeometry(const Factory: ID2D1Factory; startPos, endPos: Single): ID2D1PathGeometry;
var
  LightSink: ID2D1GeometrySink;
  segStart, segEnd, i, segs: Integer;
  t: Single;
  currPoint: D2D1_POINT_2F;
  wrappedEndPos: Single;
begin
  Result := nil;
  if (Length(FPathPoints) = 0) or (Factory = nil) or (FPathTotalLength = 0) then
    Exit;

  segs := Length(FPathPoints) - 1;

  if Factory.CreatePathGeometry(Result) <> 0 then
    Exit;

  if Result.Open(LightSink) <> 0 then
  begin
    Result := nil;
    Exit;
  end;

  try
    // --- 查找起始点 ---
    segStart := FindSegmentIndex(startPos);
    if segStart = -1 then // 未找到, 可能 startPos 恰好是 totalLength
    begin
      if startPos >= FPathTotalLength then
        segStart := segs - 1
      else
        Exit;
    end;


    // --- 构造路径 ---
    if endPos <= FPathTotalLength then // --- 普通情况: 路径不跨越终点 ---
    begin
      segEnd := FindSegmentIndex(endPos);
      if segEnd = -1 then // endPos 可能恰好是 totalLength
        if endPos >= FPathTotalLength then
          segEnd := segs - 1
        else
          Exit;

      if (FPathDists[segStart + 1] - FPathDists[segStart]) > 0 then
        t := (startPos - FPathDists[segStart]) / (FPathDists[segStart + 1] - FPathDists[segStart])
      else
        t := 0;
      currPoint := LerpPoint(FPathPoints[segStart], FPathPoints[segStart + 1], t);
      LightSink.BeginFigure(currPoint, D2D1_FIGURE_BEGIN_HOLLOW);

      for i := segStart + 1 to segEnd do
        LightSink.AddLine(FPathPoints[i]);

      if (FPathDists[segEnd + 1] - FPathDists[segEnd]) > 0 then
      begin
        t := (endPos - FPathDists[segEnd]) / (FPathDists[segEnd + 1] - FPathDists[segEnd]);
        currPoint := LerpPoint(FPathPoints[segEnd], FPathPoints[segEnd + 1], t);
        LightSink.AddLine(currPoint);
      end
      else
        LightSink.AddLine(FPathPoints[segEnd + 1]);

      LightSink.EndFigure(D2D1_FIGURE_END_OPEN);
    end
    else // --- 跨越终点的情况 ---
    begin
      // 第一段: 从 startPos 到路径终点
      if (FPathDists[segStart + 1] - FPathDists[segStart]) > 0 then
        t := (startPos - FPathDists[segStart]) / (FPathDists[segStart + 1] - FPathDists[segStart])
      else
        t := 0;
      currPoint := LerpPoint(FPathPoints[segStart], FPathPoints[segStart + 1], t);
      LightSink.BeginFigure(currPoint, D2D1_FIGURE_BEGIN_HOLLOW);
      for i := segStart + 1 to segs do
        LightSink.AddLine(FPathPoints[i]);
      LightSink.EndFigure(D2D1_FIGURE_END_OPEN);

      // 第二段: 从路径起点到 wrappedEndPos
      wrappedEndPos := endPos - FPathTotalLength;
      segEnd := FindSegmentIndex(wrappedEndPos);

      if segEnd >= 0 then
      begin
        LightSink.BeginFigure(FPathPoints[0], D2D1_FIGURE_BEGIN_HOLLOW);
        for i := 1 to segEnd do
          LightSink.AddLine(FPathPoints[i]);

        if (FPathDists[segEnd + 1] - FPathDists[segEnd]) > 0 then
        begin
          t := (wrappedEndPos - FPathDists[segEnd]) / (FPathDists[segEnd + 1] - FPathDists[segEnd]);
          currPoint := LerpPoint(FPathPoints[segEnd], FPathPoints[segEnd + 1], t);
          LightSink.AddLine(currPoint);
        end
        else
          LightSink.AddLine(FPathPoints[segEnd + 1]);

        LightSink.EndFigure(D2D1_FIGURE_END_OPEN);
      end;
    end;
  finally
    LightSink.Close;
  end;
end;

class function TMovieListViewUI.LerpPoint(const a, b: D2D1_POINT_2F; t: Single): D2D1_POINT_2F;
begin
  Result.x := a.x + (b.x - a.x) * t;
  Result.y := a.y + (b.y - a.y) * t;
end;


end.

