unit XComboBox;

interface

uses
  Winapi.Windows, System.Classes, XCGUI, XElement, XWidget;

type
  TXComboBox = class(TXEle)
  protected
    procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); override;
  public
    procedure SetSelItem(iIndex: Integer);
    function CreateAdapter: Integer;
    procedure BindAdapter(hAdapter: Integer);
    function GetAdapter: Integer;
    procedure SetBindName(const pName: string);
    procedure GetButtonRect(var pRect: TRect);
    procedure SetButtonSize(size: Integer);
    procedure SetDropHeight(height: Integer);
    function GetDropHeight: Integer;
    procedure SetItemTemplateXML(const pXmlFile: string);
    procedure SetItemTemplateXMLFromString(const pStringXML: string);
    function SetItemTemplateXMLFromMem(data: Integer; length: Integer): Boolean;
    function SetItemTemplateXMLFromZipRes(id: Integer; const pFileName, pPassword: string; hModule: Integer): Boolean;
    function SetItemTemplate(hTemp: Integer): Boolean;
    function GetItemTemplate: Integer;
    procedure EnableDrawButton(bEnable: Boolean);
    procedure EnableEdit(bEdit: Boolean);
    procedure EnableDropHeightFixed(bEnable: Boolean);
    procedure PopupDropList;

    // ���������
    function AddItemText(const pText: string): Integer;
    function AddItemTextEx(const pName, pText: string): Integer;
    function AddItemImage(hImage: Integer): Integer;
    function AddItemImageEx(const pName: string; hImage: Integer): Integer;
    function InsertItemText(iItem: Integer; const pText: string): Integer;
    function InsertItemTextEx(iItem: Integer; const pName, pText: string): Integer;
    function InsertItemImage(iItem: Integer; hImage: Integer): Integer;
    function InsertItemImageEx(iItem: Integer; const pName: string; hImage: Integer): Integer;
    function SetItemText(iItem, iColumn: Integer; const pText: string): Boolean;
    function SetItemTextEx(iItem: Integer; const pName, pText: string): Boolean;
    function SetItemImage(iItem, iColumn: Integer; hImage: Integer): Boolean;
    function SetItemImageEx(iItem: Integer; const pName: string; hImage: Integer): Boolean;
    function SetItemInt(iItem, iColumn: Integer; nValue: Integer): Boolean;
    function SetItemIntEx(iItem: Integer; const pName: string; nValue: Integer): Boolean;
    function SetItemFloat(iItem, iColumn: Integer; fFloat: Single): Boolean;
    function SetItemFloatEx(iItem: Integer; const pName: string; fFloat: Single): Boolean;
    function GetItemText(iItem, iColumn: Integer): string;
    function GetItemTextEx(iItem: Integer; const pName: string): string;
    function GetItemImage(iItem, iColumn: Integer): Integer;
    function GetItemImageEx(iItem: Integer; const pName: string): Integer;
    function GetItemInt(iItem, iColumn: Integer; out pOutValue: Integer): Boolean;
    function GetItemIntEx(iItem: Integer; const pName: string; out pOutValue: Integer): Boolean;
    function GetItemFloat(iItem, iColumn: Integer; out pOutValue: Single): Boolean;
    function GetItemFloatEx(iItem: Integer; const pName: string; out pOutValue: Single): Boolean;
    function DeleteItem(iItem: Integer): Boolean;
    function DeleteItemEx(iItem, nCount: Integer): Boolean;
    procedure DeleteItemAll;
    procedure DeleteColumnAll;
  end;

implementation

procedure TXComboBox.CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  Handle := XComboBox_Create(x, y, cx, cy, hParent.Handle);
end;

procedure TXComboBox.SetSelItem(iIndex: Integer);
begin
  XComboBox_SetSelItem(Handle, iIndex);
end;

function TXComboBox.CreateAdapter: Integer;
begin
  Result := XComboBox_CreateAdapter(Handle);
end;

procedure TXComboBox.BindAdapter(hAdapter: Integer);
begin
  XComboBox_BindAdapter(Handle, hAdapter);
end;

function TXComboBox.GetAdapter: Integer;
begin
  Result := XComboBox_GetAdapter(Handle);
end;

procedure TXComboBox.SetBindName(const pName: string);
begin
  XComboBox_SetBindName(Handle, PWideChar(pName));
end;

procedure TXComboBox.GetButtonRect(var pRect: TRect);
begin
  XComboBox_GetButtonRect(Handle, pRect);
end;

procedure TXComboBox.SetButtonSize(size: Integer);
begin
  XComboBox_SetButtonSize(Handle, size);
end;

procedure TXComboBox.SetDropHeight(height: Integer);
begin
  XComboBox_SetDropHeight(Handle, height);
end;

function TXComboBox.GetDropHeight: Integer;
begin
  Result := XComboBox_GetDropHeight(Handle);
end;

procedure TXComboBox.SetItemTemplateXML(const pXmlFile: string);
begin
  XComboBox_SetItemTemplateXML(Handle, PWideChar(pXmlFile));
end;

procedure TXComboBox.SetItemTemplateXMLFromString(const pStringXML: string);
begin
  XComboBox_SetItemTemplateXMLFromString(Handle, PAnsiChar(AnsiString(pStringXML)));
end;

function TXComboBox.SetItemTemplateXMLFromMem(data: Integer; length: Integer): Boolean;
begin
  Result := XComboBox_SetItemTemplateXMLFromMem(Handle, data, length);
end;

function TXComboBox.SetItemTemplateXMLFromZipRes(id: Integer; const pFileName, pPassword: string; hModule: Integer): Boolean;
begin
  Result := XComboBox_SetItemTemplateXMLFromZipRes(Handle, id, PWideChar(pFileName), PWideChar(pPassword), hModule);
end;

function TXComboBox.SetItemTemplate(hTemp: Integer): Boolean;
begin
  Result := XComboBox_SetItemTemplate(Handle, hTemp);
end;

function TXComboBox.GetItemTemplate: Integer;
begin
  Result := XComboBox_GetItemTemplate(Handle);
end;

procedure TXComboBox.EnableDrawButton(bEnable: Boolean);
begin
  XComboBox_EnableDrawButton(Handle, bEnable);
end;

procedure TXComboBox.EnableEdit(bEdit: Boolean);
begin
  XComboBox_EnableEdit(Handle, bEdit);
end;

procedure TXComboBox.EnableDropHeightFixed(bEnable: Boolean);
begin
  XComboBox_EnableDropHeightFixed(Handle, bEnable);
end;

procedure TXComboBox.PopupDropList;
begin
  XComboBox_PopupDropList(Handle);
end;

function TXComboBox.AddItemText(const pText: string): Integer;
begin
  Result := XComboBox_AddItemText(Handle, PWideChar(pText));
end;

function TXComboBox.AddItemTextEx(const pName, pText: string): Integer;
begin
  Result := XComboBox_AddItemTextEx(Handle, PWideChar(pName), PWideChar(pText));
end;

function TXComboBox.AddItemImage(hImage: Integer): Integer;
begin
  Result := XComboBox_AddItemImage(Handle, hImage);
end;

function TXComboBox.AddItemImageEx(const pName: string; hImage: Integer): Integer;
begin
  Result := XComboBox_AddItemImageEx(Handle, PWideChar(pName), hImage);
end;

function TXComboBox.InsertItemText(iItem: Integer; const pText: string): Integer;
begin
  Result := XComboBox_InsertItemText(Handle, iItem, PWideChar(pText));
end;

function TXComboBox.InsertItemTextEx(iItem: Integer; const pName, pText: string): Integer;
begin
  Result := XComboBox_InsertItemTextEx(Handle, iItem, PWideChar(pName), PWideChar(pText));
end;

function TXComboBox.InsertItemImage(iItem: Integer; hImage: Integer): Integer;
begin
  Result := XComboBox_InsertItemImage(Handle, iItem, hImage);
end;

function TXComboBox.InsertItemImageEx(iItem: Integer; const pName: string; hImage: Integer): Integer;
begin
  Result := XComboBox_InsertItemImageEx(Handle, iItem, PWideChar(pName), hImage);
end;

function TXComboBox.SetItemText(iItem, iColumn: Integer; const pText: string): Boolean;
begin
  Result := XComboBox_SetItemText(Handle, iItem, iColumn, PWideChar(pText));
end;

function TXComboBox.SetItemTextEx(iItem: Integer; const pName, pText: string): Boolean;
begin
  Result := XComboBox_SetItemTextEx(Handle, iItem, PWideChar(pName), PWideChar(pText));
end;

function TXComboBox.SetItemImage(iItem, iColumn: Integer; hImage: Integer): Boolean;
begin
  Result := XComboBox_SetItemImage(Handle, iItem, iColumn, hImage);
end;

function TXComboBox.SetItemImageEx(iItem: Integer; const pName: string; hImage: Integer): Boolean;
begin
  Result := XComboBox_SetItemImageEx(Handle, iItem, PWideChar(pName), hImage);
end;

function TXComboBox.SetItemInt(iItem, iColumn: Integer; nValue: Integer): Boolean;
begin
  Result := XComboBox_SetItemInt(Handle, iItem, iColumn, nValue);
end;

function TXComboBox.SetItemIntEx(iItem: Integer; const pName: string; nValue: Integer): Boolean;
begin
  Result := XComboBox_SetItemIntEx(Handle, iItem, PWideChar(pName), nValue);
end;

function TXComboBox.SetItemFloat(iItem, iColumn: Integer; fFloat: Single): Boolean;
begin
  Result := XComboBox_SetItemFloat(Handle, iItem, iColumn, fFloat);
end;

function TXComboBox.SetItemFloatEx(iItem: Integer; const pName: string; fFloat: Single): Boolean;
begin
  Result := XComboBox_SetItemFloatEx(Handle, iItem, PWideChar(pName), fFloat);
end;

function TXComboBox.GetItemText(iItem, iColumn: Integer): string;
begin
  Result := XComboBox_GetItemText(Handle, iItem, iColumn);
end;

function TXComboBox.GetItemTextEx(iItem: Integer; const pName: string): string;
begin
  Result := XComboBox_GetItemTextEx(Handle, iItem, PWideChar(pName));
end;

function TXComboBox.GetItemImage(iItem, iColumn: Integer): Integer;
begin
  Result := XComboBox_GetItemImage(Handle, iItem, iColumn);
end;

function TXComboBox.GetItemImageEx(iItem: Integer; const pName: string): Integer;
begin
  Result := XComboBox_GetItemImageEx(Handle, iItem, PWideChar(pName));
end;

function TXComboBox.GetItemInt(iItem, iColumn: Integer; out pOutValue: Integer): Boolean;
begin
  Result := XComboBox_GetItemInt(Handle, iItem, iColumn, pOutValue);
end;

function TXComboBox.GetItemIntEx(iItem: Integer; const pName: string; out pOutValue: Integer): Boolean;
begin
  Result := XComboBox_GetItemIntEx(Handle, iItem, PWideChar(pName), pOutValue);
end;

function TXComboBox.GetItemFloat(iItem, iColumn: Integer; out pOutValue: Single): Boolean;
begin
  Result := XComboBox_GetItemFloat(Handle, iItem, iColumn, pOutValue);
end;

function TXComboBox.GetItemFloatEx(iItem: Integer; const pName: string; out pOutValue: Single): Boolean;
begin
  Result := XComboBox_GetItemFloatEx(Handle, iItem, PWideChar(pName), pOutValue);
end;

function TXComboBox.DeleteItem(iItem: Integer): Boolean;
begin
  Result := XComboBox_DeleteItem(Handle, iItem);
end;

function TXComboBox.DeleteItemEx(iItem, nCount: Integer): Boolean;
begin
  Result := XComboBox_DeleteItemEx(Handle, iItem, nCount);
end;

procedure TXComboBox.DeleteItemAll;
begin
  XComboBox_DeleteItemAll(Handle);
end;

procedure TXComboBox.DeleteColumnAll;
begin
  XComboBox_DeleteColumnAll(Handle);
end;

end.

