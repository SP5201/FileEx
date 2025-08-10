unit UI_Animation;

interface

uses
  Windows, Classes, XCGUI;

type
  TIntegerArr = array of Integer;

  PIntegerArr = ^TIntegerArr;

var
  AnimaList: TIntegerArr;

procedure AddAnima(Anima: Integer);

procedure ReleaseAnima(hXCGUI: Integer);

procedure XAnima_SetRotateStyle(hXCGUI: Integer; nTime: Integer; Angle: Single; nLoopCount: Integer = 1; Parent: Integer = 0);

/// <summary>�ؼ��ƶ�λ�ö���</summary>
/// <param name="hXCGUI">���ھ������ͼƬ������߿ؼ������</param>
/// <param name="nTime">������ʱ</param>
/// <param name="x">ԭʼ����X</param>
/// <param name="y">ԭʼ����Y</param>
/// <param name="newx">�ƶ��������X</param>
/// <param name="newy">�ƶ��������Y</param>
/// <param name="Parent">����ִ����Ҫˢ�µĿؼ� һ�������ڸ��ؼ� �����0����ˢ������</param>
/// <param name="duration">����ִ�д��� Ĭ��ֵ1</param>
/// <param name="bGoBack">�����Ƿ񷵻�ԭ���� Ĭ��ֵΪFalse ���ΪTrue�Ϳ������ص�����</param>
procedure XAnima_SetMoveStyle(hXCGUI: Integer; nTime: Integer; x, y, newx, newy: Single; Parent: Integer = 0; duration: Integer = 1; bGoBack: Boolean = False);

procedure XAnima_SetWidthStyle(hXCGUI: Integer; nTime: Integer; nType: Integer; Width: Single; Parent: Integer = 0);

procedure XAnima_SetColorStyle(hXCGUI: Integer; nTime: Integer; Color: Integer; Parent: Integer = 0);

procedure XAnima_SetWindowAlphaScale(hXCGUI: Integer; nTime: Integer; StartAlpha, EndAlpha: Byte; ScaleX, ScaleY: Single);

procedure XAnima_SetCallbackStyle(hXCGUI: Integer; nTime: Single; funAnima: Integer; Parent: Integer = 0);

implementation

procedure DeleteArrItem(var arr: TIntegerArr; Index: Integer);
var
  Count: Integer;
  p: pIntegerArr;
begin
  p := @arr;
  Count := Length(p^);
  if (Count = 0) or (Index < 0) or (Index >= Count) then
    Exit;
  Move(p^[Index + 1], p^[Index], (Count - Index) * SizeOf(p^[0]));
  SetLength(p^, Count - 1);
end;

procedure AddAnimaListItem(var arr: TIntegerArr; item: Integer);
var
  Count: Integer;
begin
  Count := Length(arr);
  SetLength(arr, Count + 1);
  arr[Count] := item;
end;

procedure AddAnima(Anima: Integer);
begin
  AddAnimaListItem(AnimaList, Anima);
end;

procedure ReleaseAnima(hXCGUI: Integer);
var
  i: Integer;
  ObjectUI: Integer;
begin
  for i := High(AnimaList) downto Low(AnimaList) do
  begin
    ObjectUI := XAnima_GetObjectUI(AnimaList[i]);
    if ObjectUI = 0 then
      DeleteArrItem(AnimaList, i) else
    if ObjectUI = hXCGUI then
    begin
      XAnima_Release(AnimaList[i], False);
      DeleteArrItem(AnimaList, i);
    end;
  end;
end;

procedure XAnima_SetRotateStyle(hXCGUI: Integer; nTime: Integer; Angle: Single; nLoopCount: Integer = 1; Parent: Integer = 0);
var
  Anima: Integer;
begin
  ReleaseAnima(hXCGUI);
  Anima := XAnima_Create(hXCGUI, 1);
  XAnima_Rotate(Anima, nTime, Angle, nLoopCount, ease_flag_in, False);
  AddAnima(Anima);

  if XC_GetObjectType(Parent) = XC_NOTHING then
    Parent := hXCGUI;
  XAnima_Run(Anima, Parent);
end;

procedure XAnima_SetMoveStyle(hXCGUI: Integer; nTime: Integer; x, y, newx, newy: Single; Parent: Integer = 0; duration: Integer = 1; bGoBack: Boolean = False);
var
  Anima: Integer;
begin
  ReleaseAnima(hXCGUI);
  Anima := XAnima_Create(hXCGUI, duration);
  XAnima_MoveEx(Anima, nTime, x, y, newx, newy, 1, ease_flag_out, bGoBack);
  AddAnima(Anima);
  if XC_GetObjectType(Parent) = XC_NOTHING then
    Parent := hXCGUI;
  XAnima_Run(Anima, Parent);
end;

procedure XAnima_SetWidthStyle(hXCGUI: Integer; nTime: Integer; nType: Integer; Width: Single; Parent: Integer = 0);
var
  Anima: Integer;
begin
  ReleaseAnima(hXCGUI);
  Anima := XAnima_Create(hXCGUI, 1);
  XAnima_LayoutWidth(Anima, nTime, nType, Width, 1, ease_flag_out, False);
  AddAnima(Anima);
  if XC_GetObjectType(Parent) = XC_NOTHING then
    Parent := hXCGUI;
  XAnima_Run(Anima, Parent);
end;

procedure XAnima_SetColorStyle(hXCGUI: Integer; nTime: Integer; Color: Integer; Parent: Integer = 0);
var
  Anima: Integer;
begin
  ReleaseAnima(hXCGUI);
  Anima := XAnima_Create(hXCGUI, 1);
  XAnima_Color(Anima, nTime, Color, 1, ease_flag_quart, False);
  AddAnima(Anima);
  if XC_GetObjectType(Parent) = XC_NOTHING then
    Parent := hXCGUI;
  XAnima_Run(Anima, Parent);
end;

procedure XAnima_SetAlphaExStyle(hXCGUI: Integer; nTime: Integer; Alpha: Byte; NewAlpha: Byte; Parent: Integer = 0);
var
  Anima: Integer;
begin
  ReleaseAnima(hXCGUI);
  Anima := XAnima_Create(hXCGUI, 1);
  XAnima_AlphaEx(Anima, nTime, Alpha, NewAlpha, 1, ease_flag_out, False);
  AddAnima(Anima);
  if XC_GetObjectType(Parent) = XC_NOTHING then
    Parent := hXCGUI;
  XAnima_Run(Anima, Parent);
end;

procedure XAnima_SetWindowAlphaScale(hXCGUI: Integer; nTime: Integer; StartAlpha, EndAlpha: Byte; ScaleX, ScaleY: Single);
var
  AnimaGroup: Integer;
  Anima: Integer;
begin
  if XC_IsHWINDOW(hXCGUI) then
  begin
    AnimaGroup := XAnimaGroup_Create(1);
    Anima := XAnima_Create(hXCGUI, 1);
    XAnima_AlphaEx(Anima, nTime + 150, StartAlpha, EndAlpha, 1, ease_flag_inOut, False);
    AddAnima(Anima);
    XAnimaGroup_AddItem(AnimaGroup, Anima);
    Anima := XAnima_Create(hXCGUI, 1);
   // XAnima_ScaleSize(Anima, nTime, ScaleX, ScaleY, 1, ease_flag_out, True);
   // AddAnima(Anima);
    XAnimaGroup_AddItem(AnimaGroup, Anima);
    XAnima_Run(AnimaGroup, hXCGUI);
  end;
end;

procedure XAnima_SetCallbackStyle(hXCGUI: Integer; nTime: Single; funAnima: Integer; Parent: Integer = 0);
var
  Anima: Integer;
  AnimaItem: Integer;
begin
  ReleaseAnima(hXCGUI);
  Anima := XAnima_Create(hXCGUI, 1);
  AnimaItem := XAnima_DelayEx(Anima, nTime, 1,  ease_flag_quart, False);
  XAnimaItem_SetCallback(AnimaItem, funAnima);
  XAnimaItem_SetUserData(AnimaItem, hXCGUI);
  AddAnima(Anima);
  if XC_GetObjectType(Parent) = XC_NOTHING then
    Parent := hXCGUI;
  XAnima_Run(Anima, Parent);
end;

end.




