unit UI_List;

interface

uses
  Windows, Classes, XCGUI, XList;

type
  TListUI = class(TXList)
  private
    class function ListDRAWITEMPAINT(List: Integer; hDraw: Integer; var pItem: TList_item_; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnListHeaderDrawItem(List: Integer; hDraw: HDRAW; var pItem: Tlist_header_item_; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnListHeaderTemplateCreateEnd(List: Integer; var pItem: Tlist_header_item_; pbHandled: PBoolean): Integer; stdcall; stdcall; static;
    class function OnListTemplateCreateEnd(List: Integer; var pItem: Tlist_item_; nFlag: Integer; pbHandled: PBoolean): Integer; stdcall; stdcall; static;
  protected
  public
    procedure Init; override;
    function AddItem(MovieTitle, ReleaseYear: PWideChar): Integer;
  end;

implementation

uses
  UI_ScrollBar, UI_Resource, UI_Color;

procedure TListUI.Init;
var
  hAdapterHeader, hAdapter: HXCGUI;
begin
  inherited;
  EnableBkTransparent(True);
  XEle_EnableBkTransparent(GetHeaderHELE, True);
  SetRowHeightDefault(26, 26);
  SetRowSpace(0);
  EnableMultiSel(False);
  XScrollBa_SetDefStyle(Handle);

  AddColumn(210);
  AddColumn(86);
  hAdapterHeader := XAdMap_Create();
  BindAdapterHeader(hAdapterHeader);
  XAdMap_AddItemText(hAdapterHeader, 'name1', '影片名称');
  XAdMap_AddItemText(hAdapterHeader, 'name2', '上市时间');

  hAdapter := XAdTable_Create();
  BindAdapter(hAdapter);
  XAdTable_AddColumn(hAdapter, 'name1');
  XAdTable_AddColumn(hAdapter, 'name2');

  RegEvent(XE_LIST_HEADER_DRAWITEM, @OnListHeaderDrawItem);
  RegEvent(XE_LIST_HEADER_TEMP_CREATE_END, @OnListHeaderTemplateCreateEnd);
  RegEvent(XE_LIST_TEMP_CREATE_END, @OnListTemplateCreateEnd);
  RegEvent(XE_List_DRAWITEM, @ListDRAWITEMPAINT);
end;

function TListUI.AddItem(MovieTitle, ReleaseYear: PWideChar): Integer;
begin
  Result := AddRowTextEx('name1', MovieTitle);  // 第一列：影片标题
  SetItemText(Result, 1, ReleaseYear);          // 第二列：上市年份
end;

class function TListUI.OnListHeaderDrawItem(List: Integer; hDraw: hDraw; var pItem: Tlist_header_item_; pbHandled: PBoolean): Integer; stdcall;
begin
  Result := 0;
  pbHandled^ := True;
end;

class function TListUI.OnListHeaderTemplateCreateEnd(List: Integer; var pItem: Tlist_header_item_; pbHandled: PBoolean): Integer;
var
  hShapeText: Integer;
begin
  Result := 0;
  pbHandled^ := True;
  hShapeText := XList_GetHeaderTemplateObject(List, 0, 1);
  XShapeText_SetTextColor(hShapeText, Theme_TextColor_Leave);
  hShapeText := XList_GetHeaderTemplateObject(List, 1, 1);
  XShapeText_SetTextColor(hShapeText, Theme_TextColor_Leave);
end;

class function TListUI.OnListTemplateCreateEnd(List: Integer; var pItem: Tlist_item_; nFlag: Integer; pbHandled: PBoolean): Integer;
var
  hShapeText: Integer;
begin
  Result := 0;
  if nFlag = 2 then
    Exit;
  
 // pbHandled^ := True;
  hShapeText := XList_GetTemplateObject(List, pItem.index, 0, 1);
  XShapeText_SetTextColor(hShapeText, Theme_TextColor_Leave);
  XWidget_LayoutItem_SetMargin(hShapeText,10,0,10,0);
  hShapeText := XList_GetTemplateObject(List, pItem.index, 1, 1);
  XShapeText_SetTextColor(hShapeText, Theme_TextColor_Leave);
end;

class function TListUI.ListDRAWITEMPAINT(List: Integer; hDraw: Integer; var pItem: TList_item_; pbHandled: PBoolean): Integer; stdcall;
var
  rc: TRect;
begin
  Result := 0;
  pbHandled^ := True;
  if pItem.nState = list_item_state_leave then
    XDraw_SetBrushColor(hDraw, 0)
  else if pItem.nState = list_item_state_stay then
    XDraw_SetBrushColor(hDraw, Theme_ItemBkColor_Stay)
  else if pItem.nState = list_item_state_select then
    XDraw_SetBrushColor(hDraw, Theme_ItemBkColor_Select);
  rc := pItem.rcItem;
  rc.Width := XEle_GetWidth(List) - 20;
  XDraw_FillRoundRectEx(hDraw, rc, 6, 6, 6, 6);

  //XDraw_SetBrushColor(hDraw, Theme_TextColor_Leave);
 // XDraw_DrawText(hDraw, XList_GetItemTextEx(List, pItem.index, 'name1'), -1, pItem.rcItem);
end;

end.

