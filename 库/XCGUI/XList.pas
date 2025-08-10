unit XList;

interface

uses
  Winapi.Windows, System.Classes, Winapi.Messages, XScrollView, XCGUI, XWidget;

type
  TXList = class(TXSView)
  private
  protected
    procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); override;
  public
    destructor Destroy; override;

    // 创建列表
    class function CreateEx(x, y, cx, cy: Integer; hParent: TXWidget; col_extend_count: Integer): TXList;

    // 列操作
    function AddColumn(width: Integer): Integer;
    function InsertColumn(width: Integer; iCol: Integer): Integer;
    function DeleteColumn(iColumn: Integer): BOOL;
    procedure DeleteColumnAll;
    procedure SetColumnWidth(iColumn: Integer; width: Integer); // Modified iRow to iColumn
    procedure SetColumnMinWidth(iColumn: Integer; width: Integer); // Modified iRow to iColumn
    procedure SetColumnWidthFixed(iColumn: Integer; bFixed: BOOL);
    function GetColumnWidth(iColumn: Integer): Integer;
    function GetColumnCount: Integer;
    procedure DeleteItemAll;


    // 多选和拖动功能
    procedure EnableMultiSel(bEnable: BOOL);
    procedure EnableDragChangeColumnWidth(bEnable: BOOL);
    procedure EnableVScrollBarTop(bTop: BOOL);
    procedure EnableRowBkFull(bFull: BOOL);
    procedure EnableFixedRowHeight(bEnable: BOOL);
    procedure EnableTemplateReuse(bEnable: BOOL);
    procedure EnableVirtualTable(bEnable: BOOL);

    // 虚表和排序
    procedure SetVirtualRowCount(nRowCount: Integer);
    procedure SetSort(iColumn, iColumnAdapter: Integer; bEnable: BOOL);
    procedure SetDrawRowBkFlags(nFlags: Integer);
    procedure SetSplitLineColor(color: COLORREF);

    // 项数据操作
    function SetItemData(iRow, iColumn: Integer; data: vint): BOOL;
    function GetItemData(iRow, iColumn: Integer): vint;
    function GetCount_AD: Integer;
    function GetCountColumn_AD: Integer;

    // 选择行操作
    function SetSelectRow(iRow: Integer): BOOL; // Modified from procedure to function returning BOOL
    function GetSelectRow: Integer;
    function GetSelectRowCount: Integer;
    function AddSelectRow(iRow: Integer): BOOL;
    procedure SetSelectAll;
    function GetSelectAll(out pArray: Integer; nArraySize: Integer): Integer; // Modified pArray type
    procedure VisibleRow(iRow: Integer);
    function CancelSelectRow(iRow: Integer): BOOL;
    procedure CancelSelectAll;
    function DeleteItem(iItem: Integer): BOOL;

    // 行高度设置
    procedure SetRowHeightDefault(nHeight, nSelHeight: Integer);
    procedure GetRowHeightDefault(out pHeight, pSelHeight: Integer);
    procedure SetRowHeight(iRow, nHeight, nSelHeight: Integer);
    procedure GetRowHeight(iRow: Integer; out pHeight, pSelHeight: Integer);
    procedure SetRowSpace(nSpace: Integer);
    function GetRowSpace: Integer;

    // 可视行范围
    procedure GetVisibleRowRange(out piStart, piEnd: Integer);

    // 列表头操作
    function GetHeaderHELE: HELE;
    procedure SetHeaderHeight(height: Integer);
    function GetHeaderHeight: Integer;

    // 测试和索引
    function HitTest(pPt: PPoint; out piRow, piColumn: Integer): BOOL;
    function GetRowIndexFromHXCGUI(hXCGUI: HXCGUI): Integer;
    function GetHeaderColumnIndexFromHXCGUI(hXCGUI: HXCGUI): Integer;

    // 模板操作
    function SetItemTemplateXML(pXmlFile: PWideChar): BOOL;
    function SetItemTemplateXMLFromMem(data: Integer; length: Integer): BOOL;
    function SetItemTemplateXMLFromZipRes(id: Integer; pFileName, pPassword: PWideChar; hModule: HMODULE): BOOL;
    function SetItemTemplateXMLFromString(pStringXML: PAnsiChar): BOOL;
    function SetItemTemplate(hTemp: HTEMP): BOOL;
    function GetItemTemplate: HTEMP;
    function GetItemTemplateHeader: HTEMP;
    function GetTemplateObject(iRow, iColumn, nTempItemID: Integer): HXCGUI;
    function GetHeaderTemplateObject(iColumn, nTempItemID: Integer): HXCGUI;

    // 数据适配器
    procedure BindAdapter(hAdapter: HXCGUI);
    procedure BindAdapterHeader(hAdapter: HXCGUI);
    function CreateAdapter(colExtend_count: Integer): HXCGUI;
    function CreateAdapterHeader: HXCGUI;
    function CreateAdapters(col_extend_count: Integer): BOOL;
    function GetAdapter: HXCGUI;
    function GetAdapterHeader: HXCGUI;

    // 列和项文本操作
    function SetItemText(iRow, iColumn: Integer; pText: PWideChar): BOOL;
    function SetItemTextEx(iRow: Integer; pName, pText: PWideChar): BOOL; // 移除了 iColumn 参数
    function SetItemImage(iRow, iColumn: Integer; hImage: HIMAGE): BOOL;
    function SetItemImageEx(iRow: Integer; pName: PWideChar; hImage: hImage): BOOL;
    function GetItemText(iRow, iColumn: Integer): PWideChar;
function GetItemTextEx(iRow: Integer; pName: PWideChar ): PWideChar;
    function GetItemImage(iRow, iColumn: Integer): HIMAGE;
function GetItemImageEx(iRow: Integer; pName: PWideChar): hImage;
   function AddRowTextEx(pName, pText: PWideChar): Integer;


    // 添加和插入项操作
    function AddItemText(pText: PWideChar): Integer;
    function AddItemTextEx(pName, pText: PWideChar): Integer;
    function AddItemImage(hImage: HIMAGE): Integer;
    function AddItemImageEx(pName: PWideChar; hImage: HIMAGE): Integer;
    function InsertItemText(iRow: Integer; pText: PWideChar): Integer;
    function InsertItemTextEx(iRow: Integer; pName, pText: PWideChar): Integer;
    function InsertItemImage(iRow: Integer; hImage: HIMAGE): Integer;
    function InsertItemImageEx(iRow: Integer; pName: PWideChar; hImage: HIMAGE): Integer;

  end;

implementation

procedure TXList.CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  Handle := XList_Create(x, y, cx, cy, hParent.Handle);
end;

destructor TXList.Destroy;
begin
  inherited Destroy;
end;

class function TXList.CreateEx(x, y, cx, cy: Integer; hParent: TXWidget; col_extend_count: Integer): TXList;
var
  List: TXList;
begin
  List := TXList.Create;
  List.Handle := XList_CreateEx(x, y, cx, cy, hParent.Handle, col_extend_count);
  Result := List;
end;

function TXList.AddColumn(width: Integer): Integer;
begin
  Result := XList_AddColumn(Handle, width);
end;

function TXList.InsertColumn(width, iCol: Integer): Integer;
begin
  Result := XList_InsertColumn(Handle, width, iCol);
end;

procedure TXList.EnableMultiSel(bEnable: BOOL);
begin
  XList_EnableMultiSel(Handle, bEnable);
end;

procedure TXList.EnableDragChangeColumnWidth(bEnable: BOOL);
begin
  XList_EnableDragChangeColumnWidth(Handle, bEnable);
end;

procedure TXList.EnableVScrollBarTop(bTop: BOOL);
begin
  XList_EnableVScrollBarTop(Handle, bTop);
end;

procedure TXList.EnableRowBkFull(bFull: BOOL);
begin
  XList_EnableRowBkFull(Handle, bFull);
end;

procedure TXList.EnableFixedRowHeight(bEnable: BOOL);
begin
  XList_EnableFixedRowHeight(Handle, bEnable);
end;

procedure TXList.EnableTemplateReuse(bEnable: BOOL);
begin
  XList_EnableTemplateReuse(Handle, bEnable);
end;

procedure TXList.EnableVirtualTable(bEnable: BOOL);
begin
  XList_EnableVirtualTable(Handle, bEnable);
end;

procedure TXList.SetVirtualRowCount(nRowCount: Integer);
begin
  XList_SetVirtualRowCount(Handle, nRowCount);
end;

procedure TXList.SetSort(iColumn, iColumnAdapter: Integer; bEnable: BOOL);
begin
  XList_SetSort(Handle, iColumn, iColumnAdapter, bEnable);
end;

procedure TXList.SetDrawRowBkFlags(nFlags: Integer);
begin
  XList_SetDrawRowBkFlags(Handle, nFlags);
end;

procedure TXList.SetSplitLineColor(color: COLORREF);
begin
  XList_SetSplitLineColor(Handle, color);
end;

procedure TXList.SetColumnWidth(iColumn, width: Integer); // Modified iRow to iColumn
begin
  XList_SetColumnWidth(Handle, iColumn, width); // Modified iRow to iColumn
end;

procedure TXList.SetColumnMinWidth(iColumn, width: Integer); // Modified iRow to iColumn
begin
  XList_SetColumnMinWidth(Handle, iColumn, width); // Modified iRow to iColumn
end;

procedure TXList.SetColumnWidthFixed(iColumn: Integer; bFixed: BOOL);
begin
  XList_SetColumnWidthFixed(Handle, iColumn, bFixed);
end;

function TXList.GetColumnWidth(iColumn: Integer): Integer;
begin
  Result := XList_GetColumnWidth(Handle, iColumn);
end;

function TXList.GetColumnCount: Integer;
begin
  Result := XList_GetColumnCount(Handle);
end;

function TXList.SetItemData(iRow, iColumn: Integer; data: vint): BOOL;
begin
  Result := XList_SetItemData(Handle, iRow, iColumn, data);
end;

function TXList.GetItemData(iRow, iColumn: Integer): vint;
begin
  Result := XList_GetItemData(Handle, iRow, iColumn);
end;

function TXList.SetSelectRow(iRow: Integer): BOOL;
begin
  Result := XList_SetSelectRow(Handle, iRow);
end;

function TXList.GetSelectRow: Integer;
begin
  Result := XList_GetSelectRow(Handle);
end;

function TXList.GetSelectRowCount: Integer;
begin
  Result := XList_GetSelectRowCount(Handle);
end;

function TXList.AddSelectRow(iRow: Integer): BOOL;
begin
  Result := XList_AddSelectRow(Handle, iRow);
end;

procedure TXList.SetSelectAll;
begin
  XList_SetSelectAll(Handle);
end;

function TXList.GetSelectAll(out pArray: Integer; nArraySize: Integer): Integer; // Modified pArray type
begin
  Result := XList_GetSelectAll(Handle, pArray, nArraySize);
end;

procedure TXList.VisibleRow(iRow: Integer);
begin
  XList_VisibleRow(Handle, iRow);
end;

function TXList.CancelSelectRow(iRow: Integer): BOOL;
begin
  Result := XList_CancelSelectRow(Handle, iRow);
end;

procedure TXList.CancelSelectAll;
begin
  XList_CancelSelectAll(Handle);
end;

function TXList.GetHeaderHELE: HELE;
begin
  Result := XList_GetHeaderHELE(Handle);
end;

procedure TXList.BindAdapter(hAdapter: HXCGUI);
begin
  XList_BindAdapter(Handle, hAdapter);
end;

procedure TXList.BindAdapterHeader(hAdapter: HXCGUI);
begin
  XList_BindAdapterHeader(Handle, hAdapter);
end;

function TXList.CreateAdapter(colExtend_count: Integer): HXCGUI;
begin
  Result := XList_CreateAdapter(Handle, colExtend_count);
end;

function TXList.CreateAdapterHeader: HXCGUI;
begin
  Result := XList_CreateAdapterHeader(Handle);
end;

function TXList.CreateAdapters(col_extend_count: Integer): BOOL;
begin
  Result := XList_CreateAdapters(Handle, col_extend_count);
end;

function TXList.GetAdapter: HXCGUI;
begin
  Result := XList_GetAdapter(Handle);
end;

function TXList.GetAdapterHeader: HXCGUI;
begin
  Result := XList_GetAdapterHeader(Handle);
end;

function TXList.SetItemTemplateXML(pXmlFile: PWideChar): BOOL;
begin
  Result := XList_SetItemTemplateXML(Handle, pXmlFile);
end;

function TXList.SetItemTemplateXMLFromMem(data: Integer; length: Integer): BOOL;
begin
  Result := XList_SetItemTemplateXMLFromMem(Handle, Integer(data), length);
end;

function TXList.SetItemTemplateXMLFromZipRes(id: Integer; pFileName, pPassword: PWideChar; hModule: hModule): BOOL;
begin
  Result := XList_SetItemTemplateXMLFromZipRes(Handle, id, pFileName, pPassword, hModule);
end;

function TXList.SetItemTemplateXMLFromString(pStringXML: PAnsiChar): BOOL;
begin
  Result := XList_SetItemTemplateXMLFromString(Handle, pStringXML);
end;

function TXList.SetItemTemplate(hTemp: hTemp): BOOL;
begin
  Result := XList_SetItemTemplate(Handle, hTemp);
end;

function TXList.GetItemTemplate: hTemp;
begin
  Result := XList_GetItemTemplate(Handle);
end;

function TXList.GetItemTemplateHeader: hTemp;
begin
  Result := XList_GetItemTemplateHeader(Handle);
end;

function TXList.GetTemplateObject(iRow, iColumn, nTempItemID: Integer): HXCGUI;
begin
  Result := XList_GetTemplateObject(Handle, iRow, iColumn, nTempItemID);
end;

function TXList.GetRowIndexFromHXCGUI(hXCGUI: hXCGUI): Integer;
begin
  Result := XList_GetRowIndexFromHXCGUI(Handle, hXCGUI);
end;

function TXList.GetHeaderTemplateObject(iColumn, nTempItemID: Integer): hXCGUI;
begin
  Result := XList_GetHeaderTemplateObject(Handle, iColumn, nTempItemID);
end;

function TXList.GetHeaderColumnIndexFromHXCGUI(hXCGUI: hXCGUI): Integer;
begin
  Result := XList_GetHeaderColumnIndexFromHXCGUI(Handle, hXCGUI);
end;

procedure TXList.SetHeaderHeight(height: Integer);
begin
  XList_SetHeaderHeight(Handle, height);
end;

function TXList.GetHeaderHeight: Integer;
begin
  Result := XList_GetHeaderHeight(Handle);
end;

procedure TXList.GetVisibleRowRange(out piStart, piEnd: Integer);
begin
  XList_GetVisibleRowRange(Handle, piStart, piEnd);
end;

procedure TXList.SetRowHeightDefault(nHeight, nSelHeight: Integer);
begin
  XList_SetRowHeightDefault(Handle, nHeight, nSelHeight);
end;

procedure TXList.GetRowHeightDefault(out pHeight, pSelHeight: Integer);
begin
  XList_GetRowHeightDefault(Handle, pHeight, pSelHeight);
end;

procedure TXList.SetRowHeight(iRow, nHeight, nSelHeight: Integer);
begin
  XList_SetRowHeight(Handle, iRow, nHeight, nSelHeight);
end;

procedure TXList.GetRowHeight(iRow: Integer; out pHeight, pSelHeight: Integer);
begin
  XList_GetRowHeight(Handle, iRow, pHeight, pSelHeight);
end;

procedure TXList.SetRowSpace(nSpace: Integer);
begin
  XList_SetRowSpace(Handle, nSpace);
end;

function TXList.GetRowSpace: Integer;
begin
  Result := XList_GetRowSpace(Handle);
end;

function TXList.AddRowTextEx(pName, pText: PWideChar): Integer;
begin
  Result := XList_AddRowTextEx(Handle, pName, pText);
end;

function TXList.HitTest(pPt: PPoint; out piRow, piColumn: Integer): BOOL;
begin
  Result := XList_HitTest(Handle, pPt, piRow, piColumn);
end;

function TXList.DeleteColumn(iColumn: Integer): BOOL;
begin
  Result := XList_DeleteColumn(Handle, iColumn);
end;

procedure TXList.DeleteColumnAll;
begin
  XList_DeleteColumnAll(Handle);
end;

function TXList.DeleteItem(iItem: Integer): BOOL;
begin
  Result := XList_DeleteItem(Handle, iItem);
end;

procedure TXList.DeleteItemAll;
begin
  XList_DeleteItemAll(Handle);
end;

function TXList.GetCount_AD: Integer;
begin
  Result := XList_GetCount_AD(Handle);
end;

function TXList.GetCountColumn_AD: Integer;
begin
  Result := XList_GetCountColumn_AD(Handle);
end;

function TXList.SetItemText(iRow, iColumn: Integer; pText: PWideChar): BOOL;
begin
  Result := XList_SetItemText(Handle, iRow, iColumn, pText);
end;

function TXList.SetItemTextEx(iRow: Integer; pName, pText: PWideChar): BOOL;
begin
  Result := XList_SetItemTextEx(Handle, iRow, pName, pText);
end;

function TXList.SetItemImage(iRow, iColumn: Integer; hImage: hImage): BOOL;
begin
  Result := XList_SetItemImage(Handle, iRow, iColumn, hImage);
end;

function TXList.SetItemImageEx(iRow: Integer; pName: PWideChar; hImage: hImage): BOOL;
begin
  Result := XList_SetItemImageEx(Handle, iRow, pName, hImage);
end;

function TXList.GetItemText(iRow, iColumn: Integer): PWideChar  ;
begin
  Result := XList_GetItemText(Handle, iRow, iColumn);
end;

function TXList.GetItemTextEx(iRow: Integer; pName: PWideChar ): PWideChar;
begin
  Result := XList_GetItemTextEx(Handle, iRow, pName);
end;

function TXList.GetItemImage(iRow, iColumn: Integer): hImage;
begin
  Result := XList_GetItemImage(Handle, iRow, iColumn);
end;

function TXList.GetItemImageEx(iRow: Integer; pName: PWideChar): hImage;
begin
  Result := XList_GetItemImageEx(Handle, iRow, pName);
end;




function TXList.AddItemText(pText: PWideChar): Integer;
begin
  Result := XList_AddItemText(Handle, pText);
end;

function TXList.AddItemTextEx(pName, pText: PWideChar): Integer;
begin
  Result := XList_AddItemTextEx(Handle, pName, pText);
end;

function TXList.AddItemImage(hImage: hImage): Integer;
begin
  Result := XList_AddItemImage(Handle, hImage);
end;

function TXList.AddItemImageEx(pName: PWideChar; hImage: hImage): Integer;
begin
  Result := XList_AddItemImageEx(Handle, pName, hImage);
end;

function TXList.InsertItemText(iRow: Integer; pText: PWideChar): Integer;
begin
  Result := XList_InsertItemText(Handle, iRow, pText);
end;

function TXList.InsertItemTextEx(iRow: Integer; pName, pText: PWideChar): Integer;
begin
  Result := XList_InsertItemTextEx(Handle, iRow, pName, pText);
end;

function TXList.InsertItemImage(iRow: Integer; hImage: hImage): Integer;
begin
  Result := XList_InsertItemImage(Handle, iRow, hImage);
end;

function TXList.InsertItemImageEx(iRow: Integer; pName: PWideChar; hImage: hImage): Integer;
begin
  Result := XList_InsertItemImageEx(Handle, iRow, pName, hImage);
end;

end.

