unit UI_TipBox;

interface

uses
  Windows, Classes, Messages, XCGUI, SysUtils;

/// <summary> ��ʾ��</summary>
/// <param name="hParent">��Ҫ������Ϣ�Ĵ��ھ�� ֧��ģ̬���ں���ͨ����</param>
/// <param name="pText">��ʾ����</param>
/// <param name="nTime">��ʾ��ά�ּ�����</param>
procedure XTipBox_Show(hParent: Integer; pText: string; nTime: Integer = 3000);

implementation

uses
  UI_Animation;

var
  TipBox: Integer;
  nFont: Integer;
  nShadowImage: Integer;
  nTipSvg: Integer;

function TipBoxDESTROY(hEle: Integer; pbHandle: PBoolean): Integer; stdcall;
begin
  Result := 0;
  TipBox := 0;
  if XC_GetObjectType(nTipSvg) = XC_SVG then
  begin
    XSvg_Release(nTipSvg);
  end;
  nTipSvg := 0;
end;

function XTipBox_Init(hParent: Integer): Boolean;
var
  RC: TRect;
begin
  if (XC_GetObjectType(hParent) <> XC_Window) and (XC_GetObjectType(hParent) <> XC_MODALWINDOW) then
    Exit(False);
  if XC_GetObjectType(TipBox) = XC_ELE then
  begin
    XEle_GetRect(TipBox, RC);
    XEle_Destroy(TipBox);
    XWnd_RedrawRect(hParent, RC, False);
  end;
  if XC_GetObjectType(nFont) <> XC_FONT then
    nFont := XRes_GetFont('΢���ź�10����');
  if XC_GetObjectType(nShadowImage) <> XC_IMAGE then
    nShadowImage := XRes_GetImage('������ʾ��Ӱ');
  if XC_GetObjectType(nTipSvg) <> XC_SVG then
    nTipSvg := XSvg_LoadFile('Skin\�������\��ʾ.svg');
  Result := True;
end;

function TipBoxPaint(TipBox, hDraw: Integer; pbHandle: PBoolean): Integer; stdcall;
var
  RC: TRect;
  pText: PWideChar;
begin
  Result := 0;
  pbHandle^ := True;

  XEle_GetClientRect(TipBox, RC);
  pText := XC_GetProperty(TipBox, 'Text');
  XDraw_ImageAdaptive(hDraw, nShadowImage, RC, False);

  if XC_GetObjectType(nTipSvg) = XC_SVG then
  begin
    XSvg_SetUserFillColor(nTipSvg, RGBA(0, 0, 0, 120), True);
    XDraw_DrawSvgEx(hDraw, nTipSvg, 14, 14, 14, 14);
  end;
  XDraw_SetFont(hDraw, nFont);
  XDraw_SetBrushColor(hDraw, RGBA(0, 0, 0, 120));
  XDraw_SetTextAlign(hDraw, textAlignFlag_vcenter);
  RC.Left := RC.Left + 18 + 16;
  RC.Top := RC.Top - 4;
  XDraw_DrawText(hDraw, pText, -1, RC);
end;

procedure XTipBox_Show(hParent: Integer; pText: string; nTime: Integer = 3000);
var
  RC: TRect;
  Sz: TSize;
  nLef, nTop: Integer;
  nWidth, nHeight: Integer;
  hAnimaGroup: Integer;
  hAnima: Integer;
begin
  if not XTipBox_Init(hParent) then
    Exit;

  XC_GetTextShowSize(PChar(pText), -1, nFont, Sz);
  GetWindowRect(XWnd_GetHWND(hParent), RC);
  nTop := 34;
  nWidth := Sz.cx + 40 + 10;
  nHeight := 30 + 16;
  nLef := (RC.Right - RC.Left - nWidth) div 2 ;
  TipBox := XEle_Create(nLef, nTop, nWidth, nHeight, hParent);
  XEle_EnableBkTransparent(TipBox, True);
  XEle_EnableMouseThrough(TipBox, True);
  XC_SetProperty(TipBox, 'Text', PChar(pText));
  XEle_RegEventC1(TipBox, XE_PAINT, Integer(@TipBoxPaint));
  Xele_RegEventC1(TipBox, XE_DESTROY, Integer(@TipBoxDESTROY));

  hAnimaGroup := XAnimaGroup_Create(1);
  hAnima := XAnima_Create(TipBox, 1);
  XAnima_MoveEx(hAnima, 900, nLef, nTop - 20, nLef, nTop, 1, Ease_Flag_Out or ease_flag_elastic, False);
  XAnimaGroup_AddItem(hAnimaGroup, hAnima);
  XAnima_DestroyObjectUI(hAnima, nTime);
  hAnima := XAnima_Create(nTipSvg, 1);
  XAnima_AlphaEx(hAnima, 1200, 30, 255, 1, ease_flag_in, False);
  XAnimaGroup_AddItem(hAnimaGroup, hAnima);
  hAnima := XAnima_Create(TipBox, 1);
  XAnima_AlphaEx(hAnima, 800, 30, 255, 1, ease_flag_in, False);
  XAnimaGroup_AddItem(hAnimaGroup, hAnima);
  XAnima_Run(hAnimaGroup, hParent);
end;

end.

