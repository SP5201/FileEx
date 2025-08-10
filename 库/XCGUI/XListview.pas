unit XListview;

interface

uses
  Windows, Classes, Messages, XCGUI, XScrollView, XWidget;

type
  TXListView = class(TXSView)
  private
    protected
       procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); override;
  public
    destructor Destroy; override;
    procedure BindAdapter(hAdapter: HXCGUI);
    function GetAdapter: HXCGUI;

    procedure SetItemTemplateXML(const pXmlFile: WideString);
    procedure SetItemTemplateXMLFromString(const pStringXML: AnsiString);
    procedure SetItemTemplateXMLFromMem(data: Pointer; length: Integer);
    procedure SetItemTemplateXMLFromZipRes(id: Integer; const pFileName, pPassword: WideString; hModule: HMODULE);
    procedure SetItemTemplate(hTemp: HTEMP);
    function GetItemTemplate: HTEMP;
    function GetItemTemplateGroup: HTEMP;
    function GetTemplateObject(iGroup, iItem, nTempItemID: Integer): HXCGUI;
    function GetTemplateObjectGroup(iGroup, nTempItemID: Integer): HXCGUI;
    function GetItemIDFromHXCGUI(hXCGUI: HXCGUI; out piGroup, piItem: Integer): Boolean;
    function HitTest(const pPt: TPoint; out pOutGroup, pOutItem: Integer): Boolean;
    function HitTestOffset(pPt: TPoint; out pOutGroup, pOutItem: Integer): Boolean;
    procedure EnableMultiSel(bEnable: Boolean);
    procedure EnableTemplateReuse(bEnable: Boolean);
    procedure EnableVirtualTable(bEnable: Boolean);
    function SetVirtualItemCount(iGroup, nCount: Integer): Boolean;
    procedure SetDrawItemBkFlags(nFlags: Integer);
    function SetSelectItem(iGroup, iItem: Integer): Boolean;
    function GetSelectItem(out piGroup, piItem: Integer): Boolean;
    function AddSelectItem(iGroup, iItem: Integer): Boolean;
    procedure VisibleItem(iGroup, iItem: Integer);
    procedure GetVisibleItemRange(out piGroup1, piGroup2, piStartGroup, piStartItem, piEndGroup, piEndItem: Integer);
    function GetSelectItemCount: Integer;
    function GetSelectAll(pArray: Pointer; nArraySize: Integer): Integer;
    procedure SetSelectAll;
    procedure CancelSelectAll;
    procedure SetColumnSpace(space: Integer);
    procedure SetRowSpace(space: Integer);
    procedure SetItemSize(Size: TSize);
    function GetItemSize: TSize;
    procedure SetGroupHeight(height: Integer);
    function GetGroupHeight: Integer;
    procedure SetGroupUserData(iGroup: Integer; nData: vint);
    procedure SetItemUserData(iGroup, iItem: Integer; nData: vint);
    function GetGroupUserData(iGroup: Integer): vint;
    function GetItemUserData(iGroup, iItem: Integer): vint;
    procedure SetDragRectColor(color: COLORREF; width: Integer);
    procedure RefreshData;
    procedure RefreshItem(iGroup, iItem: Integer);
    function ExpandGroup(iGroup: Integer; bExpand: Boolean): Boolean;

    // Group Operations
    function Group_AddColumn(const pName: WideString): Integer;
    function Group_AddItemText(const pValue: WideString; iPos: Integer): Integer;
    function Group_AddItemTextEx(const pName, pValue: WideString; iPos: Integer): Integer;
    function Group_AddItemImage(hImage: HIMAGE; iPos: Integer): Integer;
    function Group_AddItemImageEx(const pName: WideString; hImage: HIMAGE; iPos: Integer): Integer;
    function Group_SetText(iGroup, iColumn: Integer; const pValue: WideString): Boolean;
    function Group_SetTextEx(iGroup: Integer; const pName, pValue: WideString): Boolean;
    function Group_SetImage(iGroup, iColumn: Integer; hImage: HIMAGE): Boolean;
    function Group_SetImageEx(iGroup: Integer; const pName: WideString; hImage: HIMAGE): Boolean;
    function Group_GetText(iGroup, iColumn: Integer): WideString;
    function Group_GetTextEx(iGroup: Integer; const pName: WideString): WideString;
    function Group_GetImage(iGroup, iColumn: Integer): HIMAGE;
    function Group_GetImageEx(iGroup: Integer; const pName: WideString): HIMAGE;
    function Group_GetCount: Integer;
    function Group_DeleteItem(iGroup: Integer): Boolean;
    procedure Group_DeleteAllChildItem(iGroup: Integer);

    // Item Operations
    function Item_GetCount(iGroup: Integer): Integer;
    function Item_AddColumn(const pName: WideString): Integer;
    function Item_AddItemText(iGroup: Integer; const pValue: WideString; iPos: Integer): Integer;
    function Item_AddItemTextEx(iGroup: Integer; const pName, pValue: WideString; iPos: Integer): Integer;
    function Item_AddItemImage(iGroup: Integer; hImage: HIMAGE; iPos: Integer): Integer;
    function Item_AddItemImageEx(iGroup: Integer; const pName: WideString; hImage: HIMAGE; iPos: Integer): Integer;
    function Item_SetText(iGroup, iItem, iColumn: Integer; const pValue: WideString): Boolean;
    function Item_SetTextEx(iGroup, iItem: Integer; const pName, pValue: WideString): Boolean;
    function Item_SetImage(iGroup, iItem, iColumn: Integer; hImage: HIMAGE): Boolean;
    function Item_SetImageEx(iGroup, iItem: Integer; const pName: WideString; hImage: HIMAGE): Boolean;
    function Item_GetText(iGroup, iItem, iColumn: Integer): WideString;
    function Item_GetTextEx(iGroup, iItem: Integer; const pName: WideString): WideString;
    function Item_GetImage(iGroup, iItem, iColumn: Integer): HIMAGE;
    function Item_GetImageEx(iGroup, iItem: Integer; const pName: WideString): HIMAGE;
    function Item_DeleteItem(iGroup, iItem: Integer): Boolean;
    procedure DeleteAll;
    procedure DeleteAllGroup;
    procedure DeleteAllItem;
    procedure DeleteColumnGroup(iColumn: Integer);
    procedure DeleteColumnItem(iColumn: Integer);
    property ItemSize: TSize read GetItemSize write SetItemSize;
  end;

implementation


procedure TXListView.CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  Handle := XListView_Create(x, y, cx, cy, hParent.Handle);
end;

destructor TXListView.Destroy;
begin
  inherited Destroy;
end;

procedure TXListView.CancelSelectAll;
begin
  XListView_CancelSelectAll(Handle);
end;

procedure TXListView.DeleteAll;
begin
  XListView_DeleteAll(Handle);
end;

procedure TXListView.DeleteAllGroup;
begin
  XListView_DeleteAllGroup(Handle);
end;

procedure TXListView.DeleteAllItem;
begin
  XListView_DeleteAllItem(Handle);
end;

procedure TXListView.DeleteColumnGroup(iColumn: Integer);
begin
  XListView_DeleteColumnGroup(Handle, iColumn);
end;

procedure TXListView.DeleteColumnItem(iColumn: Integer);
begin
  XListView_DeleteColumnItem(Handle, iColumn);
end;

function TXListView.AddSelectItem(iGroup, iItem: Integer): Boolean;
begin
  Result := XListView_AddSelectItem(Handle, iGroup, iItem);
end;

procedure TXListView.EnableMultiSel(bEnable: Boolean);
begin
  XListView_EnableMultiSel(Handle, bEnable);
end;

procedure TXListView.EnableTemplateReuse(bEnable: Boolean);
begin
  XListView_EnableTemplateReuse(Handle, bEnable);
end;

procedure TXListView.EnableVirtualTable(bEnable: Boolean);
begin
  XListView_EnableVirtualTable(Handle, bEnable);
end;

function TXListView.ExpandGroup(iGroup: Integer; bExpand: Boolean): Boolean;
begin
  Result := XListView_ExpandGroup(Handle, iGroup, bExpand);
end;

procedure TXListView.BindAdapter(hAdapter: HXCGUI);
begin
  XListView_BindAdapter(Handle, hAdapter);
end;

function TXListView.GetAdapter: HXCGUI;
begin
  Result := XListView_GetAdapter(Handle);
end;

function TXListView.GetGroupHeight: Integer;
begin
  Result := XListView_GetGroupHeight(Handle);
end;

function TXListView.GetGroupUserData(iGroup: Integer): vint;
begin
  Result := XListView_GetGroupUserData(Handle, iGroup);
end;

function TXListView.GetItemIDFromHXCGUI(hXCGUI: hXCGUI; out piGroup, piItem: Integer): Boolean;
begin
  Result := XListView_GetItemIDFromHXCGUI(Handle, hXCGUI, piGroup, piItem);
end;

function TXListView.GetItemSize: TSize;
begin
  XListView_GetItemSize(Handle, Result);
end;

function TXListView.GetItemTemplate: HTEMP;
begin
  Result := XListView_GetItemTemplate(Handle);
end;

function TXListView.GetItemTemplateGroup: HTEMP;
begin
  Result := XListView_GetItemTemplateGroup(Handle);
end;

function TXListView.GetItemUserData(iGroup, iItem: Integer): vint;
begin
  Result := XListView_GetItemUserData(Handle, iGroup, iItem);
end;

function TXListView.GetSelectAll(pArray: Pointer; nArraySize: Integer): Integer;
begin
  Result := XListView_GetSelectAll(Handle, Integer(pArray), nArraySize);
end;

function TXListView.GetSelectItem(out piGroup, piItem: Integer): Boolean;
begin
  Result := XListView_GetSelectItem(Handle, piGroup, piItem);
end;

function TXListView.GetSelectItemCount: Integer;
begin
  Result := XListView_GetSelectItemCount(Handle);
end;

function TXListView.GetTemplateObject(iGroup, iItem, nTempItemID: Integer): hXCGUI;
begin
  Result := XListView_GetTemplateObject(Handle, iGroup, iItem, nTempItemID);
end;

function TXListView.GetTemplateObjectGroup(iGroup, nTempItemID: Integer): hXCGUI;
begin
  Result := XListView_GetTemplateObjectGroup(Handle, iGroup, nTempItemID);
end;

procedure TXListView.GetVisibleItemRange(out piGroup1, piGroup2, piStartGroup, piStartItem, piEndGroup, piEndItem: Integer);
begin
  XListView_GetVisibleItemRange(Handle, piGroup1, piGroup2, piStartGroup, piStartItem, piEndGroup, piEndItem);
end;

function TXListView.Group_AddColumn(const pName: WideString): Integer;
begin
  Result := XListView_Group_AddColumn(Handle, PWideChar(pName));
end;

function TXListView.Group_AddItemImage(hImage: hImage; iPos: Integer): Integer;
begin
  Result := XListView_Group_AddItemImage(Handle, hImage, iPos);
end;

function TXListView.Group_AddItemImageEx(const pName: WideString; hImage: hImage; iPos: Integer): Integer;
begin
  Result := XListView_Group_AddItemImageEx(Handle, PWideChar(pName), hImage, iPos);
end;

function TXListView.Group_AddItemText(const pValue: WideString; iPos: Integer): Integer;
begin
  Result := XListView_Group_AddItemText(Handle, PWideChar(pValue), iPos);
end;

function TXListView.Group_AddItemTextEx(const pName, pValue: WideString; iPos: Integer): Integer;
begin
  Result := XListView_Group_AddItemTextEx(Handle, PWideChar(pName), PWideChar(pValue), iPos);
end;

procedure TXListView.Group_DeleteAllChildItem(iGroup: Integer);
begin
  XListView_Group_DeleteAllChildItem(Handle, iGroup);
end;

function TXListView.Group_DeleteItem(iGroup: Integer): Boolean;
begin
  Result := XListView_Group_DeleteItem(Handle, iGroup);
end;

function TXListView.Group_GetCount: Integer;
begin
  Result := XListView_Group_GetCount(Handle);
end;

function TXListView.Group_GetImage(iGroup, iColumn: Integer): hImage;
begin
  Result := XListView_Group_GetImage(Handle, iGroup, iColumn);
end;

function TXListView.Group_GetImageEx(iGroup: Integer; const pName: WideString): hImage;
begin
  Result := XListView_Group_GetImageEx(Handle, iGroup, PWideChar(pName));
end;

function TXListView.Group_GetText(iGroup, iColumn: Integer): WideString;
begin
  Result := XListView_Group_GetText(Handle, iGroup, iColumn);
end;

function TXListView.Group_GetTextEx(iGroup: Integer; const pName: WideString): WideString;
begin
  Result := XListView_Group_GetTextEx(Handle, iGroup, PWideChar(pName));
end;

function TXListView.Group_SetImage(iGroup, iColumn: Integer; hImage: hImage): Boolean;
begin
  Result := XListView_Group_SetImage(Handle, iGroup, iColumn, hImage);
end;

function TXListView.Group_SetImageEx(iGroup: Integer; const pName: WideString; hImage: hImage): Boolean;
begin
  Result := XListView_Group_SetImageEx(Handle, iGroup, PWideChar(pName), hImage);
end;

function TXListView.Group_SetText(iGroup, iColumn: Integer; const pValue: WideString): Boolean;
begin
  Result := XListView_Group_SetText(Handle, iGroup, iColumn, PWideChar(pValue));
end;

function TXListView.Group_SetTextEx(iGroup: Integer; const pName, pValue: WideString): Boolean;
begin
  Result := XListView_Group_SetTextEx(Handle, iGroup, PWideChar(pName), PWideChar(pValue));
end;

function TXListView.HitTest(const pPt: TPoint; out pOutGroup, pOutItem: Integer): Boolean;
begin
  Result := XListView_HitTest(Handle, pPt, pOutGroup, pOutItem);
end;

function TXListView.HitTestOffset(pPt: TPoint; out pOutGroup, pOutItem: Integer): Boolean;
begin
  Result := XListView_HitTestOffset(Handle, pPt, pOutGroup, pOutItem);
end;

function TXListView.Item_AddColumn(const pName: WideString): Integer;
begin
  Result := XListView_Item_AddColumn(Handle, PWideChar(pName));
end;

function TXListView.Item_AddItemImage(iGroup: Integer; hImage: hImage; iPos: Integer): Integer;
begin
  Result := XListView_Item_AddItemImage(Handle, iGroup, hImage, iPos);
end;

function TXListView.Item_AddItemImageEx(iGroup: Integer; const pName: WideString; hImage: hImage; iPos: Integer): Integer;
begin
  Result := XListView_Item_AddItemImageEx(Handle, iGroup, PWideChar(pName), hImage, iPos);
end;

function TXListView.Item_AddItemText(iGroup: Integer; const pValue: WideString; iPos: Integer): Integer;
begin
  Result := XListView_Item_AddItemText(Handle, iGroup, PWideChar(pValue), iPos);
end;

function TXListView.Item_AddItemTextEx(iGroup: Integer; const pName, pValue: WideString; iPos: Integer): Integer;
begin
  Result := XListView_Item_AddItemTextEx(Handle, iGroup, PWideChar(pName), PWideChar(pValue), iPos);
end;

function TXListView.Item_DeleteItem(iGroup, iItem: Integer): Boolean;
begin
  Result := XListView_Item_DeleteItem(Handle, iGroup, iItem);
end;

function TXListView.Item_GetCount(iGroup: Integer): Integer;
begin
  Result := XListView_Item_GetCount(Handle, iGroup);
end;

function TXListView.Item_GetImage(iGroup, iItem, iColumn: Integer): hImage;
begin
  Result := XListView_Item_GetImage(Handle, iGroup, iItem, iColumn);
end;

function TXListView.Item_GetImageEx(iGroup, iItem: Integer; const pName: WideString): hImage;
begin
  Result := XListView_Item_GetImageEx(Handle, iGroup, iItem, PWideChar(pName));
end;

function TXListView.Item_GetText(iGroup, iItem, iColumn: Integer): WideString;
begin
  Result := XListView_Item_GetText(Handle, iGroup, iItem, iColumn);
end;

function TXListView.Item_GetTextEx(iGroup, iItem: Integer; const pName: WideString): WideString;
begin
  Result := XListView_Item_GetTextEx(Handle, iGroup, iItem, PWideChar(pName));
end;

function TXListView.Item_SetImage(iGroup, iItem, iColumn: Integer; hImage: hImage): Boolean;
begin
  Result := XListView_Item_SetImage(Handle, iGroup, iItem, iColumn, hImage);
end;

function TXListView.Item_SetImageEx(iGroup, iItem: Integer; const pName: WideString; hImage: hImage): Boolean;
begin
  Result := XListView_Item_SetImageEx(Handle, iGroup, iItem, PWideChar(pName), hImage);
end;

function TXListView.Item_SetText(iGroup, iItem, iColumn: Integer; const pValue: WideString): Boolean;
begin
  Result := XListView_Item_SetText(Handle, iGroup, iItem, iColumn, PWideChar(pValue));
end;

function TXListView.Item_SetTextEx(iGroup, iItem: Integer; const pName, pValue: WideString): Boolean;
begin
  Result := XListView_Item_SetTextEx(Handle, iGroup, iItem, PWideChar(pName), PWideChar(pValue));
end;

procedure TXListView.RefreshData;
begin
  XListView_RefreshData(Handle);
end;

procedure TXListView.RefreshItem(iGroup, iItem: Integer);
begin
  XListView_RefreshItem(Handle, iGroup, iItem);
end;

procedure TXListView.SetColumnSpace(space: Integer);
begin
  XListView_SetColumnSpace(Handle, space);
end;

procedure TXListView.SetDragRectColor(color: COLORREF; width: Integer);
begin
  XListView_SetDragRectColor(Handle, color, width);
end;

procedure TXListView.SetDrawItemBkFlags(nFlags: Integer);
begin
  XListView_SetDrawItemBkFlags(Handle, nFlags);
end;

procedure TXListView.SetGroupHeight(height: Integer);
begin
  XListView_SetGroupHeight(Handle, height);
end;

procedure TXListView.SetGroupUserData(iGroup: Integer; nData: vint);
begin
  XListView_SetGroupUserData(Handle, iGroup, nData);
end;

procedure TXListView.SetItemSize(Size: TSize);
begin
  XListView_SetItemSize(Handle, Size.cx, Size.cy);
end;

procedure TXListView.SetItemTemplate(hTemp: hTemp);
begin
  XListView_SetItemTemplate(Handle, hTemp);
end;

procedure TXListView.SetItemTemplateXML(const pXmlFile: WideString);
begin
  XListView_SetItemTemplateXML(Handle, PWideChar(pXmlFile));
end;

procedure TXListView.SetItemTemplateXMLFromMem(data: Pointer; length: Integer);
begin
  XListView_SetItemTemplateXMLFromMem(Handle, Integer(data), length);
end;

procedure TXListView.SetItemTemplateXMLFromString(const pStringXML: AnsiString);
begin
  XListView_SetItemTemplateXMLFromString(Handle, PAnsiChar(pStringXML));
end;

procedure TXListView.SetItemTemplateXMLFromZipRes(id: Integer; const pFileName, pPassword: WideString; hModule: hModule);
begin
  XListView_SetItemTemplateXMLFromZipRes(Handle, id, PWideChar(pFileName), PWideChar(pPassword), hModule);
end;

procedure TXListView.SetItemUserData(iGroup, iItem: Integer; nData: vint);
begin
  XListView_SetItemUserData(Handle, iGroup, iItem, nData);
end;

procedure TXListView.SetRowSpace(space: Integer);
begin
  XListView_SetRowSpace(Handle, space);
end;

procedure TXListView.SetSelectAll;
begin
  XListView_SetSelectAll(Handle);
end;

function TXListView.SetSelectItem(iGroup, iItem: Integer): Boolean;
begin
  Result := XListView_SetSelectItem(Handle, iGroup, iItem);
end;

function TXListView.SetVirtualItemCount(iGroup, nCount: Integer): Boolean;
begin
  Result := XListView_SetVirtualItemCount(Handle, iGroup, nCount);
end;

procedure TXListView.VisibleItem(iGroup, iItem: Integer);
begin
  XListView_VisibleItem(Handle, iGroup, iItem);
end;

end.


