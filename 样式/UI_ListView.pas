unit UI_ListView;

interface

uses
  Windows, Classes, Messages, XCGUI, SysUtils,
  XListview, UI_Messages, System.Generics.Collections;

type

  TListViewSelectItemEvent = procedure(Sender: TObject; const Path: string) of object;
  TRightButtonDownEvent = procedure(Sender: TObject; const Path: string) of object;
  TListViewItemRenameEvent = procedure(Sender: TObject; const Path, NewTitle: string) of object;

type
  TListViewItemData = record
    dwName: string;
    dwSubTitle: string; // 新增副标题字段
    dwImage: Integer;
    ListViewHandle: Integer; // 记录TListViewUI.handle
  end;

  PListViewItemData = ^TListViewItemData;

type
  TPathMap = TDictionary<string, PListViewItemData>;

type
  TListViewUI = class(TXListView)
  private
    FItemTextAlign: Integer;
    FItemFont: Integer;
    FRightClickGroup: Integer;
    FRightClickItem: Integer;
    FOnSelectItem: TListViewSelectItemEvent;
    FCurrentSelectPath: string;
    FOnRButtonDown: TRightButtonDownEvent;
  protected
    FOnItemRename: TListViewItemRenameEvent;
    FPathMap: TPathMap; // 直接使用TPathMap类型
    class function OnListViewDRAWITEMPAINT(ListView: Integer; hDraw: Integer; var pItem: TlistView_item_; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnListViewLBUTTONUP(ListView: Integer; nFlags: Cardinal; var pPt: TPoint; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnListViewRBUTTONUP(ListView: Integer; nFlags: Cardinal; var pPt: TPoint; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnListViewBUTTONDOWN(ListView: Integer; nFlags: Cardinal; var pPt: TPoint; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnListViewSELECT(ListView: Integer; iGroup: Integer; iItem: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnListViewTemplateCreateEnd(hListView: Integer; var pItem: TlistView_item_; nFlag: Integer; pbHandled: PBoolean): Integer; stdcall;  static;
    class function OnButtonDown(hEle: Integer; nFlags: UINT; var pPt: TPOINT; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnRButtonUP(hEle: Integer; nFlags: Cardinal; var pPt: TPoint; pbHandled: PBoolean): Integer; stdcall; static;
    procedure OnViewTemplateCreateEnd(pItem: TlistView_item_; nFlag: Integer; pbHandled: PBoolean);  virtual;
    procedure Init();override;
    procedure OnDrawItemPaint(hDraw: Integer; var pItem: Tlistview_item_); virtual;
    procedure OnBUTTONUPItem(nFlags: Cardinal; iGroup, iItem: Integer); virtual;
    procedure OnListViewItemSELECT(iGroup: Integer; iItem: Integer); virtual;
    function GetPathByIndex(index: Integer): string; // 新增：通过索引获取路径
  public
    destructor Destroy; override;
    function ItemUserData(nitem: Integer): PListViewItemData;
    function GetPathFromItem(nItem: Integer): string; // 新增：获取项目对应的路径
    procedure AddItem(hImage: Integer; pTitle, pSubTitle, pFilePath: string);
    procedure DeleteItem(nGroup: Integer; nItem: Integer);
    procedure DeleteItemByPath(Path: string);
    procedure DeleteItemAll;
    function GetItemSelect(nGroup: Integer = 0): Integer;
    function GetItemSelectUserData: PListViewItemData;
    function GetItemSelectPath: string; // 新增：获取选中项的路径
    function GetItemRightClickUserData: PListViewItemData;
    function GetItemRightClickPath: string; // 新增：获取右键点击项的路径
    procedure UpdateTitle(const FilePath: string; const NewTitle: string); // 新增：更新标题
    property ItemTextAlign: Integer read FItemTextAlign write FItemTextAlign default textFormatFlag_NoWrap or textFormatFlag_LineLimit;
    property ItemFont: Integer read FItemFont write FItemFont;
    property RightClickGroup: Integer read FRightClickGroup;
    property RightClickItem: Integer read FRightClickItem;
    property OnSelectItem: TListViewSelectItemEvent read FOnSelectItem write FOnSelectItem;
    property OnRButtonDown: TRightButtonDownEvent read FOnRButtonDown write FOnRButtonDown;
    property OnItemRename: TListViewItemRenameEvent read FOnItemRename write FOnItemRename;
  end;

implementation

uses
  UI_Resource, UI_Color, UI_ScrollBar, UI_Menu, UI_Element;

{ TListViewUI }

destructor TListViewUI.Destroy;
begin
  FOnSelectItem :=nil;
  FOnRButtonDown := nil;
  FOnItemRename := nil;
  DeleteItemAll;
  FPathMap.Free;
  inherited;
end;


procedure TListViewUI.Init;
var
  Sz: TSize;
begin
  inherited;
  FPathMap := TPathMap.Create;
  FCurrentSelectPath := '';
  ItemFont := XRes_GetFont('微软雅黑10加粗');
  EnableBkTransparent(True);

  Sz.cx := 147;
  Sz.cy := 200 + 26;
  ItemSize := Sz;
  SetGroupHeight(-20);
  SetColumnSpace(15);
  SetRowSpace(10);
  EnableMultiSel(False);
  SetItemTemplate(XResource_LoadZipTemp(listItemTemp_type_listView_item, 'ListView_Item.xml'));
  XListView_CreateAdapter(Handle);
  Group_AddItemText('', -1);
  XScrollBa_SetDefStyle(Handle);
  EnableTemplateReuse(True);
  EnableVirtualTable(True);
  ItemTextAlign := textFormatFlag_NoWrap or textFormatFlag_LineLimit or textTrimming_EllipsisCharacter or  textAlignFlag_center;
  RegEvent(XE_LISTVIEW_DRAWITEM, @OnListViewDRAWITEMPAINT);
  RegEvent(XE_LBUTTONUP, @OnListViewLBUTTONUP);
  RegEvent(XE_RBUTTONUP, @OnListViewRBUTTONUP);
  RegEvent(XE_RBUTTONDOWN, @OnListViewBUTTONDOWN);
  RegEvent(XE_LBUTTONDOWN, @OnListViewBUTTONDOWN);
  RegEvent(XE_LISTVIEW_TEMP_CREATE_END,@OnListViewTemplateCreateEnd) ;
  RegEvent(XE_LISTVIEW_SELECT, @OnListViewSELECT);
end;

class function TListViewUI.OnListViewTemplateCreateEnd(hListView: Integer; var pItem: TlistView_item_; nFlag: Integer; pbHandled: PBoolean): Integer; stdcall;
var
  ListViewUI: TListViewUI;
begin
  Result := 0;
  ListViewUI := GetClassFormHandle(hListView);
  ListViewUI.OnViewTemplateCreateEnd(pItem, nFlag, pbHandled);
end;

procedure  TListViewUI.OnViewTemplateCreateEnd(pItem: TlistView_item_; nFlag: Integer; pbHandled: PBoolean);
var
  hEle: Integer;
  EleUI: TEleUI;
  ItemData: PListViewItemData;
begin
  if nFlag = 2 then
    Exit;

  if (pItem.iItem >= 0) and (pItem.iGroup >= 0) then
  begin
    hEle := XListView_GetTemplateObject(Handle, pItem.iGroup, pItem.iItem, 33);
    EleUI := TEleUI.FromHandle(hEle);
    if EleUI.IsHELE then
    begin
      ItemData := Self.ItemUserData(pItem.iItem);
      if ItemData = nil then
        Exit;
      XEle_SetUserData(hEle, Integer(ItemData));
      EleUI.SetCursor(LoadCursor(0, IDC_HAND));
      EleUI.RegEvent(XE_LBUTTONDOWN, @OnButtonDown);
      EleUI.RegEvent(XE_RBUTTONDOWN, @OnButtonDown);
      EleUI.RegEvent(XE_RBUTTONUP, @OnRButtonUP);
    end;
  end;
end;

function TListViewUI.GetPathByIndex(index: Integer): string;
var
  i: Integer;
  key: string;
begin
  Result := '';
  if (index < 0) or (index >= FPathMap.Count) then
    Exit;
    
  i := 0;
  for key in FPathMap.Keys do
  begin
    if i = index then
    begin
      Result := key;
      Exit;
    end;
    Inc(i);
  end;
end;

function TListViewUI.GetPathFromItem(nItem: Integer): string;
begin
  Result := GetPathByIndex(nItem);
end;

function TListViewUI.ItemUserData(nitem: Integer): PListViewItemData;
var
  path: string;
begin
  Result := nil;
  path := GetPathByIndex(nItem);
  if path <> '' then
    FPathMap.TryGetValue(path, Result);
end;

class function TListViewUI.OnButtonDown(hEle: Integer; nFlags: UINT; var pPt: TPOINT; pbHandled: PBoolean): Integer;
var
  HParent: Integer;
  iGroup, iItem: Integer;
  ListView: TListViewUI;
begin
  Result := 0;
  HParent := hEle;
  repeat
    HParent := XWidget_GetParentEle(HParent);
  until XC_GetObjectType(HParent) = XC_LISTVIEW;

  XListView_GetItemIDFromHXCGUI(HParent, hEle, iGroup, iItem);
  ListView := TListViewUI.FromHandle(HParent);
  ListView.SetSelectItem(iGroup, iItem);
  XEle_SendEvent(HParent, XE_LISTVIEW_SELECT, iGroup, iItem);
end;

class function TListViewUI.OnRButtonUP(hEle: Integer; nFlags: Cardinal; var pPt: TPoint; pbHandled: PBoolean): Integer;
var
  HParent: Integer;
begin
  Result := 0;
  HParent := hEle;
  repeat
    HParent := XWidget_GetParentEle(HParent);
  until XC_GetObjectType(HParent) = XC_LISTVIEW;

  XEle_PointClientToWndClient(hEle, pPt);
  XEle_PointWndClientToEleClient(HParent, pPt);

  XEle_SendEvent(HParent, XE_RBUTTONUP, 0, Integer(@pPt));
end;

procedure TListViewUI.DeleteItem(nGroup, nItem: Integer);
var
  PItemdata: PListViewItemData;
  path: string;
  selectIndex: Integer;
begin
  path := GetPathByIndex(nItem);
  if path = '' then Exit;
  
  if FPathMap.TryGetValue(path, PItemdata) then
  begin
    if XC_GetObjectType(PItemdata^.dwImage) = XC_IMAGE then
      XImage_Release(PItemdata^.dwImage);
    Dispose(PItemdata);
    FPathMap.Remove(path);
  end;
  
  SetVirtualItemCount(0, FPathMap.Count);
  RefreshData;
  // 自动选中上一项
  if FPathMap.Count > 0 then
  begin
    if nItem > 0 then
      selectIndex := nItem - 1
    else
      selectIndex := 0;
    SetSelectItem(0, selectIndex);
    PostEvent(XE_LISTVIEW_SELECT, 0, selectIndex);
  end
  else
  begin
    // List is now empty, trigger select event with empty path
    OnListViewItemSELECT(0, -1);
  end;
end;

procedure TListViewUI.DeleteItemAll;
var
  ItemData: PListViewItemData;
  paths: TArray<string>;
  i: Integer;
  path: string;
begin
  // 先收集所有的键，避免在遍历过程中修改集合
  SetLength(paths, FPathMap.Count);
  i := 0;
  
  // 使用for..in收集所有键
  for path in FPathMap.Keys do
  begin
    if i < Length(paths) then
    begin
      paths[i] := path;
      Inc(i);
    end;
  end;
  // 调整为实际获取的键数量
  SetLength(paths, i);
  
  // 清理所有项目
  for i := 0 to Length(paths) - 1 do
  begin
    if FPathMap.TryGetValue(paths[i], ItemData) then
    begin
      if XC_GetObjectType(ItemData^.dwImage) = XC_IMAGE then
        XImage_Release(ItemData^.dwImage);
      Dispose(ItemData);
    end;
  end;
  
  FPathMap.Clear;
  SetVirtualItemCount(0, 0);
  RefreshData;

  // 列表为空，通知更新
  OnListViewItemSELECT(0, -1);
end;

procedure TListViewUI.DeleteItemByPath(Path: string);
var
  ItemData: PListViewItemData;
  ItemIndex: Integer;
  i: Integer;
  currentPath: string;
begin
  if not FPathMap.TryGetValue(Path, ItemData) then
    Exit;
    
  // 查找索引
  ItemIndex := -1;
  
  // 手动查找索引
  i := 0;
  for currentPath in FPathMap.Keys do
  begin
    if currentPath = Path then
    begin
      ItemIndex := i;
      Break;
    end;
    Inc(i);
  end;
    
  if ItemIndex > -1 then
    DeleteItem(0, ItemIndex);
end;

class function TListViewUI.OnListViewDRAWITEMPAINT(ListView: Integer; hDraw: Integer; var pItem: TlistView_item_; pbHandled: PBoolean): Integer; stdcall;
var
  ListViewUI: TListViewUI;
begin
  Result := 0;
  pbHandled^ := True;

  if pItem.iItem = -1 then
    Exit;

  ListViewUI := GetClassFormHandle(ListView);
  ListViewUI.OnDrawItemPaint(hDraw, pItem);
end;

procedure TListViewUI.OnDrawItemPaint(hDraw: Integer; var pItem: Tlistview_item_);
begin
end;

class function TListViewUI.OnListViewSELECT(ListView, iGroup, iItem: Integer; pbHandled: PBoolean): Integer;
var
  ListViewUI: TListViewUI;
begin
  Result := 0;
  ListViewUI := GetClassFormHandle(ListView);
  ListViewUI.OnListViewItemSELECT(iGroup, iItem);
end;

procedure TListViewUI.OnListViewItemSELECT(iGroup: Integer; iItem: Integer);
var
  path: string;
begin
  if iItem < 0 then
    path := ''
  else
    path := GetPathByIndex(iItem);

  if Assigned(FOnSelectItem) and (path <> FCurrentSelectPath) then
  begin
    FCurrentSelectPath := path;
    FOnSelectItem(Self, path);
  end;
end;

function TListViewUI.GetItemRightClickPath: string;
begin
  Result := GetPathByIndex(FRightClickItem);
end;

function TListViewUI.GetItemRightClickUserData: PListViewItemData;
var
  path: string;
begin
  Result := nil;
  path := GetPathByIndex(FRightClickItem);
  if path <> '' then
    FPathMap.TryGetValue(path, Result);
end;

function TListViewUI.GetItemSelect(nGroup: Integer = 0): Integer;
begin
  GetSelectItem(nGroup, Result);
end;

function TListViewUI.GetItemSelectPath: string;
var
  nItem: Integer;
begin
  Result := '';
  nItem := GetItemSelect;
  if nItem >= 0 then
    Result := GetPathByIndex(nItem);
end;

function TListViewUI.GetItemSelectUserData: PListViewItemData;
var
  path: string;
begin
  Result := nil;
  path := GetItemSelectPath;
  if path <> '' then
    FPathMap.TryGetValue(path, Result);
end;

class function TListViewUI.OnListViewBUTTONDOWN(ListView: Integer; nFlags: Cardinal; var pPt: TPoint; pbHandled: PBoolean): Integer;
var
  ListViewUI: TListViewUI;
  iGroup, iItem: Integer;
begin
  Result := 0;
  XListView_HitTestOffset(ListView, pPt, iGroup, iItem);
  if (iItem < 0) or (iGroup < 0) then
  begin
    pbHandled^ := True;
    Exit;
  end;

  ListViewUI := GetClassFormHandle(ListView);
  if nFlags = 1 then
  begin
    ListViewUI.OnBUTTONUPItem(nFlags, iGroup, iItem);
    Exit;
  end;
  ListViewUI.SendEvent(XE_LISTVIEW_SELECT, iGroup, iItem);
  ListViewUI.SetSelectItem(iGroup, iItem);
end;

class function TListViewUI.OnListViewLBUTTONUP(ListView: Integer; nFlags: Cardinal; var pPt: TPoint; pbHandled: PBoolean): Integer; stdcall;
var
  nGroup, nItem: Integer;
begin
  Result := 0;
  XListView_HitTestOffset(ListView, pPt, nGroup, nItem);
  if (nItem < 0) or (nGroup < 0) then
  begin
    pbHandled^ := True;
    Exit;
  end;
  TListViewUI(GetClassFormHandle(ListView)).OnBUTTONUPItem(1, nGroup, nItem);
end;

class function TListViewUI.OnListViewRBUTTONUP(ListView: Integer; nFlags: Cardinal; var pPt: TPoint; pbHandled: PBoolean): Integer; stdcall;
var
  ListViewUI: TListViewUI;
  nGroup, nItem: Integer;
begin
  Result := 0;
  XListView_HitTestOffset(ListView, pPt, nGroup, nItem);
  ListViewUI := GetClassFormHandle(ListView);
  ListViewUI.FRightClickGroup := nGroup;
  ListViewUI.FRightClickItem := nItem;
  if (nItem < 0) or (nGroup < 0) then
  begin
    pbHandled^ := True;
    Exit;
  end;
  ListViewUI.OnBUTTONUPItem(2, nGroup, nItem);
end;

procedure TListViewUI.OnBUTTONUPItem(nFlags: Cardinal; iGroup, iItem: Integer);
var
  path: string;
begin
  if nFlags = 2 then // Right-click
  begin
    if Assigned(FOnRButtonDown) then
    begin
      path := GetPathFromItem(iItem);
      if path <> '' then
        FOnRButtonDown(Self, path);
    end;
  end;
end;

procedure TListViewUI.AddItem(hImage: Integer; pTitle, pSubTitle, pFilePath: string);
var
  PItemdata: PListViewItemData;
begin
  if XC_IMAGE = XC_GetObjectType(hImage) then
    XImage_SetDrawType(hImage, image_draw_type_fixed_ratio);

  New(PItemdata);
  PItemdata^.dwName := pTitle;
  PItemdata^.dwSubTitle := pSubTitle;
  PItemdata^.dwImage := hImage;
  PItemdata^.ListViewHandle := Handle;
  FPathMap.AddOrSetValue(pFilePath, PItemdata);
  SetVirtualItemCount(0, FPathMap.Count);
  RefreshData;
  // 自动选中第一项
  if (FPathMap.Count > 0) and (GetItemSelect(0) = -1) then
  begin
    SetSelectItem(0, 0);
    PostEvent(XE_LISTVIEW_SELECT, 0, 0);
  end;
end;

procedure TListViewUI.UpdateTitle(const FilePath: string; const NewTitle: string);
var
  ItemData: PListViewItemData;
begin
  if FPathMap.TryGetValue(FilePath, ItemData) then
  begin
    ItemData^.dwName := NewTitle;
    RefreshData;
  end;
end;

end.

