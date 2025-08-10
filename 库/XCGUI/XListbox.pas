unit XListbox;

interface

uses
  Winapi.Windows, System.Classes, Winapi.Messages, XScrollView,XCGUI, XWidget;

type
  TXListBox = class(TXSView)
  private
    protected
       procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); override;
  public
    destructor Destroy; override;
    // 添加 XCGUI.pas 中的 listbox 接口方法声明
    procedure EnableFixedRowHeight(bEnable: BOOL);
    procedure EnableTemplateReuse(bEnable: BOOL);
    procedure EnableVirtualTable(bEnable: BOOL);
    procedure SetVirtualRowCount(nRowCount: Integer);
    procedure SetDrawItemBkFlags(nFlags: Integer);
    function SetItemData(iItem: Integer; nUserData: vint): BOOL;
    function GetItemData(iItem: Integer): vint;
    function SetItemInfo(iItem: Integer; pItem: TlistBox_item_info_): BOOL;
    function GetItemInfo(iItem: Integer; out pItem: TlistBox_item_info_): BOOL;
    function SetSelectItem(iItem: Integer): BOOL;
    function GetSelectItem: Integer;
    function AddSelectItem(iItem: Integer): BOOL;
    function CancelSelectItem(iItem: Integer): BOOL;
    function CancelSelectAll: BOOL;
    function GetSelectAll(out pArray: Integer; nArraySize: Integer): Integer;
    function GetSelectCount: Integer;
    function GetItemMouseStay: Integer;
    function SelectAll: BOOL;
    procedure VisibleItem(iItem: Integer);
    procedure GetVisibleRowRange(out piStart: Integer; out piEnd: Integer);
    procedure SetItemHeightDefault(nHeight: Integer; nSelHeight: Integer);
    procedure GetItemHeightDefault(out pHeight: Integer; out pSelHeight: Integer);
    function GetItemIndexFromHXCGUI(hXCGUI: HXCGUI): Integer;
    procedure SetRowSpace(nSpace: Integer);
    function GetRowSpace: Integer;
    function HitTest(pPt: PPoint): Integer;
    function HitTestOffset(var pPt: TPoint): Integer;
    function SetItemTemplateXML(pXmlFile: PWideChar): BOOL;
    function SetItemTemplateXMLFromString(pStringXML: PAnsiChar): BOOL;
    function SetItemTemplate(hTemp: HTEMP): BOOL;
    function GetTemplateObject(iItem: Integer; nTempItemID: Integer): HXCGUI;
    procedure EnableMultiSel(bEnable: BOOL);
    function CreateAdapter: HXCGUI;
    procedure BindAdapter(hAdapter: HXCGUI);
    function GetAdapter: HXCGUI;
    procedure Sort(iColumnAdapter: Integer; bAscending: BOOL);
    procedure RefreshData;
    procedure RefreshItem(iItem: Integer);
    function AddItemText(pText: PWideChar): Integer;
    function AddItemTextEx(pName: PWideChar; pText: PWideChar): Integer;
    function AddItemImage(hImage: HIMAGE): Integer;
    function AddItemImageEx(pName: PWideChar; hImage: HIMAGE): Integer;
    function InsertItemText(iItem: Integer; pValue: PWideChar): Integer;
    function InsertItemTextEx(iItem: Integer; pName: PWideChar; pValue: PWideChar): Integer;
    function InsertItemImage(iItem: Integer; hImage: HIMAGE): Integer;
    function InsertItemImageEx(iItem: Integer; pName: PWideChar; hImage: HIMAGE): Integer;
    function SetItemText(iItem: Integer; iColumn: Integer; pText: PWideChar): BOOL;
    function SetItemTextEx(iItem: Integer; pName: PWideChar; pText: PWideChar): BOOL;
    function SetItemImage(iItem: HELE; iColumn: Integer; hImage: HIMAGE): BOOL;
    function SetItemImageEx(iItem: Integer; pName: PWideChar; hImage: HIMAGE): BOOL;
    function SetItemInt(iItem: Integer; iColumn: Integer; nValue: Integer): BOOL;
    function SetItemIntEx(iItem: Integer; pName: PWideChar; nValue: Integer): BOOL;
    function SetItemFloat(iItem: Integer; iColumn: Integer; fFloat: Single): BOOL;
    function SetItemFloatEx(iItem: Integer; pName: PWideChar; fFloat: Single): BOOL;
    function GetItemText(iItem: Integer; iColumn: Integer): PWideChar;
    function GetItemTextEx(iItem: Integer; pName: PWideChar): PWideChar;
    function GetItemImage(iItem: Integer; iColumn: Integer): HIMAGE;
    function GetItemImageEx(iItem: Integer; pName: PWideChar): HIMAGE;
    function GetItemInt(iItem: Integer; iColumn: Integer; out pOutValue: Integer): BOOL;
    function GetItemIntEx(iItem: Integer; pName: PWideChar; out pOutValue: Integer): BOOL;
    function GetItemFloat(iItem: HELE; iColumn: Integer; out pOutValue: Single): BOOL;
    function GetItemFloatEx(iItem: Integer; pName: PWideChar; out pOutValue: Single): BOOL;
    function DeleteItem(iItem: Integer): BOOL;
    function DeleteItemEx(iItem: Integer; nCount: Integer): BOOL;
    procedure DeleteItemAll;
    procedure DeleteColumnAll;
    function GetCount_AD: Integer;
    function GetCountColumn_AD: Integer;
  end;

implementation

procedure TXListBox.CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);
begin
   Handle := XListBox_Create(x, y, cx, cy, hParent.Handle);
end;

destructor TXListBox.Destroy;
begin
  inherited Destroy;
end;

// 实现 XCGUI.pas 中的 listbox 接口方法
procedure TXListBox.EnableFixedRowHeight(bEnable: BOOL);
begin
  XListBox_EnableFixedRowHeight(Self.Handle, bEnable);
end;

procedure TXListBox.EnableTemplateReuse(bEnable: BOOL);
begin
  XListBox_EnableTemplateReuse(Self.Handle, bEnable);
end;

procedure TXListBox.EnableVirtualTable(bEnable: BOOL);
begin
  XListBox_EnableVirtualTable(Self.Handle, bEnable);
end;

procedure TXListBox.SetVirtualRowCount(nRowCount: Integer);
begin
  XListBox_SetVirtualRowCount(Self.Handle, nRowCount);
end;

procedure TXListBox.SetDrawItemBkFlags(nFlags: Integer);
begin
  XListBox_SetDrawItemBkFlags(Self.Handle, nFlags);
end;

function TXListBox.SetItemData(iItem: Integer; nUserData: vint): BOOL;
begin
  Result := XListBox_SetItemData(Self.Handle, iItem, nUserData);
end;

function TXListBox.GetItemData(iItem: Integer): vint;
begin
  Result := XListBox_GetItemData(Self.Handle, iItem);
end;

function TXListBox.SetItemInfo(iItem: Integer; pItem: TlistBox_item_info_): BOOL;
begin
  Result := XListBox_SetItemInfo(Self.Handle, iItem, pItem);
end;

function TXListBox.GetItemInfo(iItem: Integer; out pItem: TlistBox_item_info_): BOOL;
begin
  Result := XListBox_GetItemInfo(Handle, iItem, pItem);
end;

function TXListBox.SetSelectItem(iItem: Integer): BOOL;
begin
  Result := XListBox_SetSelectItem(Self.Handle, iItem);
end;

function TXListBox.GetSelectItem: Integer;
begin
  Result := XListBox_GetSelectItem(Self.Handle);
end;

function TXListBox.AddSelectItem(iItem: Integer): BOOL;
begin
  Result := XListBox_AddSelectItem(Self.Handle, iItem);
end;

function TXListBox.CancelSelectItem(iItem: Integer): BOOL;
begin
  Result := XListBox_CancelSelectItem(Self.Handle, iItem);
end;

function TXListBox.CancelSelectAll: BOOL;
begin
  Result := XListBox_CancelSelectAll(Self.Handle);
end;

function TXListBox.GetSelectAll(out pArray: Integer; nArraySize: Integer): Integer;
begin
  Result := XListBox_GetSelectAll(Self.Handle, pArray, nArraySize);
end;

function TXListBox.GetSelectCount: Integer;
begin
  Result := XListBox_GetSelectCount(Self.Handle);
end;

function TXListBox.GetItemMouseStay: Integer;
begin
  Result := XListBox_GetItemMouseStay(Self.Handle);
end;

function TXListBox.SelectAll: BOOL;
begin
  Result := XListBox_SelectAll(Self.Handle);
end;

procedure TXListBox.VisibleItem(iItem: Integer);
begin
  XListBox_VisibleItem(Self.Handle, iItem);
end;

procedure TXListBox.GetVisibleRowRange(out piStart: Integer; out piEnd: Integer);
begin
  XListBox_GetVisibleRowRange(Self.Handle, piStart, piEnd);
end;

procedure TXListBox.SetItemHeightDefault(nHeight: Integer; nSelHeight: Integer);
begin
  XListBox_SetItemHeightDefault(Self.Handle, nHeight, nSelHeight);
end;

procedure TXListBox.GetItemHeightDefault(out pHeight: Integer; out pSelHeight: Integer);
begin
  XListBox_GetItemHeightDefault(Self.Handle, pHeight, pSelHeight);
end;

function TXListBox.GetItemIndexFromHXCGUI(hXCGUI: HXCGUI): Integer;
begin
  Result := XListBox_GetItemIndexFromHXCGUI(Self.Handle, hXCGUI);
end;

procedure TXListBox.SetRowSpace(nSpace: Integer);
begin
  XListBox_SetRowSpace(Self.Handle, nSpace);
end;

function TXListBox.GetRowSpace: Integer;
begin
  Result := XListBox_GetRowSpace(Self.Handle);
end;

function TXListBox.HitTest(pPt: PPoint): Integer;
begin
  Result := XListBox_HitTest(Self.Handle, pPt);
end;

function TXListBox.HitTestOffset(var pPt: TPoint): Integer;
begin
  Result := XListBox_HitTestOffset(Self.Handle, pPt);
end;

function TXListBox.SetItemTemplateXML(pXmlFile: PWideChar): BOOL;
begin
  Result := XListBox_SetItemTemplateXML(Self.Handle, pXmlFile);
end;

function TXListBox.SetItemTemplateXMLFromString(pStringXML: PAnsiChar): BOOL;
begin
  Result := XListBox_SetItemTemplateXMLFromString(Self.Handle, pStringXML);
end;

function TXListBox.SetItemTemplate(hTemp: HTEMP): BOOL;
begin
  Result := XListBox_SetItemTemplate(Self.Handle, hTemp);
end;

function TXListBox.GetTemplateObject(iItem: Integer; nTempItemID: Integer): HXCGUI;
begin
  Result := XListBox_GetTemplateObject(Self.Handle, iItem, nTempItemID);
end;

procedure TXListBox.EnableMultiSel(bEnable: BOOL);
begin
  XListBox_EnableMultiSel(Self.Handle, bEnable);
end;

function TXListBox.CreateAdapter: HXCGUI;
begin
  Result := XListBox_CreateAdapter(Self.Handle);
end;

procedure TXListBox.BindAdapter(hAdapter: HXCGUI);
begin
  XListBox_BindAdapter(Self.Handle, hAdapter);
end;

function TXListBox.GetAdapter: HXCGUI;
begin
  Result := XListBox_GetAdapter(Self.Handle);
end;

procedure TXListBox.Sort(iColumnAdapter: Integer; bAscending: BOOL);
begin
  XListBox_Sort(Self.Handle, iColumnAdapter, bAscending);
end;

procedure TXListBox.RefreshData;
begin
  XListBox_RefreshData(Self.Handle);
end;

procedure TXListBox.RefreshItem(iItem: Integer);
begin
  XListBox_RefreshItem(Self.Handle, iItem);
end;

function TXListBox.AddItemText(pText: PWideChar): Integer;
begin
  Result := XListBox_AddItemText(Self.Handle, pText);
end;

function TXListBox.AddItemTextEx(pName: PWideChar; pText: PWideChar): Integer;
begin
  Result := XListBox_AddItemTextEx(Self.Handle, pName, pText);
end;

function TXListBox.AddItemImage(hImage: HIMAGE): Integer;
begin
  Result := XListBox_AddItemImage(Self.Handle, hImage);
end;

function TXListBox.AddItemImageEx(pName: PWideChar; hImage: HIMAGE): Integer;
begin
  Result := XListBox_AddItemImageEx(Self.Handle, pName, hImage);
end;

function TXListBox.InsertItemText(iItem: Integer; pValue: PWideChar): Integer;
begin
  Result := XListBox_InsertItemText(Self.Handle, iItem, pValue);
end;

function TXListBox.InsertItemTextEx(iItem: Integer; pName: PWideChar; pValue: PWideChar): Integer;
begin
  Result := XListBox_InsertItemTextEx(Self.Handle, iItem, pName, pValue);
end;

function TXListBox.InsertItemImage(iItem: Integer; hImage: HIMAGE): Integer;
begin
  Result := XListBox_InsertItemImage(Self.Handle, iItem, hImage);
end;

function TXListBox.InsertItemImageEx(iItem: Integer; pName: PWideChar; hImage: HIMAGE): Integer;
begin
  Result := XListBox_InsertItemImageEx(Self.Handle, iItem, pName, hImage);
end;

function TXListBox.SetItemText(iItem: Integer; iColumn: Integer; pText: PWideChar): BOOL;
begin
  Result := XListBox_SetItemText(Self.Handle, iItem, iColumn, pText);
end;

function TXListBox.SetItemTextEx(iItem: Integer; pName: PWideChar; pText: PWideChar): BOOL;
begin
  Result := XListBox_SetItemTextEx(Self.Handle, iItem, pName, pText);
end;

function TXListBox.SetItemImage(iItem: HELE; iColumn: Integer; hImage: HIMAGE): BOOL;
begin
  Result := XListBox_SetItemImage(Self.Handle, iItem, iColumn, hImage);
end;

function TXListBox.SetItemImageEx(iItem: Integer; pName: PWideChar; hImage: HIMAGE): BOOL;
begin
  Result := XListBox_SetItemImageEx(Self.Handle, iItem, pName, hImage);
end;

function TXListBox.SetItemInt(iItem: Integer; iColumn: Integer; nValue: Integer): BOOL;
begin
  Result := XListBox_SetItemInt(Self.Handle, iItem, iColumn, nValue);
end;

function TXListBox.SetItemIntEx(iItem: Integer; pName: PWideChar; nValue: Integer): BOOL;
begin
  Result := XListBox_SetItemIntEx(Self.Handle, iItem, pName, nValue);
end;

function TXListBox.SetItemFloat(iItem: Integer; iColumn: Integer; fFloat: Single): BOOL;
begin
  Result := XListBox_SetItemFloat(Self.Handle, iItem, iColumn, fFloat);
end;

function TXListBox.SetItemFloatEx(iItem: Integer; pName: PWideChar; fFloat: Single): BOOL;
begin
  Result := XListBox_SetItemFloatEx(Self.Handle, iItem, pName, fFloat);
end;

function TXListBox.GetItemText(iItem: Integer; iColumn: Integer): PWideChar;
begin
  Result := XListBox_GetItemText(Self.Handle, iItem, iColumn);
end;

function TXListBox.GetItemTextEx(iItem: Integer; pName: PWideChar): PWideChar;
begin
  Result := XListBox_GetItemTextEx(Self.Handle, iItem, pName);
end;

function TXListBox.GetItemImage(iItem: Integer; iColumn: Integer): HIMAGE;
begin
  Result := XListBox_GetItemImage(Self.Handle, iItem, iColumn);
end;

function TXListBox.GetItemImageEx(iItem: Integer; pName: PWideChar): HIMAGE;
begin
  Result := XListBox_GetItemImageEx(Self.Handle, iItem, pName);
end;

function TXListBox.GetItemInt(iItem: Integer; iColumn: Integer; out pOutValue: Integer): BOOL;
begin
  Result := XListBox_GetItemInt(Self.Handle, iItem, iColumn, pOutValue);
end;

function TXListBox.GetItemIntEx(iItem: Integer; pName: PWideChar; out pOutValue: Integer): BOOL;
begin
  Result := XListBox_GetItemIntEx(Self.Handle, iItem, pName, pOutValue);
end;

function TXListBox.GetItemFloat(iItem: HELE; iColumn: Integer; out pOutValue: Single): BOOL;
begin
  Result := XListBox_GetItemFloat(Self.Handle, iItem, iColumn, pOutValue);
end;

function TXListBox.GetItemFloatEx(iItem: Integer; pName: PWideChar; out pOutValue: Single): BOOL;
begin
  Result := XListBox_GetItemFloatEx(Self.Handle, iItem, pName, pOutValue);
end;

function TXListBox.DeleteItem(iItem: Integer): BOOL;
begin
  Result := XListBox_DeleteItem(Self.Handle, iItem);
end;

function TXListBox.DeleteItemEx(iItem: Integer; nCount: Integer): BOOL;
begin
  Result := XListBox_DeleteItemEx(Self.Handle, iItem, nCount);
end;

procedure TXListBox.DeleteItemAll;
begin
  XListBox_DeleteItemAll(Self.Handle);
end;

procedure TXListBox.DeleteColumnAll;
begin
  XListBox_DeleteColumnAll(Self.Handle);
end;

function TXListBox.GetCount_AD: Integer;
begin
  Result := XListBox_GetCount_AD(Self.Handle);
end;

function TXListBox.GetCountColumn_AD: Integer;
begin
  Result := XListBox_GetCountColumn_AD(Self.Handle);
end;

end.
