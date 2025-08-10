unit UI_ListBox;

interface

uses
  Windows, Classes, XCGUI, XListbox;

type
  TListBoxUI = class(TXListBox)
  public
    procedure Init; override;
    function XListBox_AddItem(ListBox: Integer; pText: PWideChar; ID: Integer = -1): Integer;
    procedure XListBox_Deltem(ListBox: Integer; nItem: Integer);
    function XListBox_GetSelectItemGroupID(ListBox: Integer): Integer;
    class function ListBoxDRAWITEMPAINT(ListBox: Integer; hDraw: Integer; var pItem: TlistBox_item_; pbHandled: PBoolean): Integer; stdcall; static;
  end;

implementation

uses
  UI_ScrollBar, UI_Resource, UI_Color;

procedure TListBoxUI.Init;
begin
  inherited;
  EnableBkTransparent(True);
  SetItemHeightDefault(20, 20);
  SetRowSpace(0);
  XScrollBa_SetDefStyle(Handle);
  RegEvent(XE_LISTBOX_DRAWITEM, @ListBoxDRAWITEMPAINT);
end;

function TListBoxUI.XListBox_AddItem(ListBox: Integer; pText: PWideChar; ID: Integer = -1): Integer;
var
  nIndex: Integer;
begin
  nIndex := XListBox_AddItemTextEx(ListBox, 'name1', pText);
  XListBox_SetItemData(ListBox, nIndex, ID);
  Result := nIndex;
end;

procedure TListBoxUI.XListBox_Deltem(ListBox: Integer; nItem: Integer);
begin
  XListBox_DeleteItem(ListBox, nItem);
end;

function TListBoxUI.XListBox_GetSelectItemGroupID(ListBox: Integer): Integer;
var
  nItem: Integer;
begin
  if XListBox_GetCount_AD(ListBox) = 0 then
    Exit(-1);
  nItem := XListBox_GetSelectItem(ListBox);
  if nItem = -1 then
    Exit(-1);
  Result := XListBox_GetItemData(ListBox, nItem);
end;

class function TListBoxUI.ListBoxDRAWITEMPAINT(ListBox: Integer; hDraw: Integer; var pItem: TlistBox_item_; pbHandled: PBoolean): Integer; stdcall;
begin
  Result := 0;
  pbHandled^ := True;
  if pItem.nState = list_item_state_leave then
    XDraw_SetBrushColor(hDraw, Theme_ItemBkColor_Leave)
  else if pItem.nState = list_item_state_stay then
    XDraw_SetBrushColor(hDraw, Theme_ItemBkColor_Stay)
  else if pItem.nState = list_item_state_select then
    XDraw_SetBrushColor(hDraw, Theme_ItemBkColor_Select);
  XDraw_FillRect(hDraw, pItem.rcItem);

  //XDraw_SetBrushColor(hDraw, Theme_TextColor_Leave);
 // XDraw_DrawText(hDraw, XListBox_GetItemTextEx(ListBox, pItem.index, 'name1'), -1, pItem.rcItem);
end;

end.

