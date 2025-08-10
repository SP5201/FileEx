unit XMenu;

interface

uses
  Windows, Classes, SysUtils, XCGUI, XWidget;

type
  TXMenu = class(TXWidget)
  private
  public
    constructor Create;
    destructor Destroy; override;

    // 基本操作
    procedure AddItem(nID: Integer; const pText: WideString; nParentID: Integer = 0; nFlags: Integer = 0);
    procedure AddItemIcon(nID: Integer; const pText: WideString; nParentID: Integer; hIcon: HIMAGE; nFlags: Integer);
    procedure InsertItem(nID: Integer; const pText: WideString; nFlags: Integer; insertID: Integer);
    procedure InsertItemIcon(nID: Integer; const pText: WideString; hIcon: HIMAGE; nFlags: Integer; insertID: Integer);

    // 菜单项导航
    function GetFirstChildItem(nID: Integer): Integer;
    function GetEndChildItem(nID: Integer): Integer;
    function GetPrevSiblingItem(nID: Integer): Integer;
    function GetNextSiblingItem(nID: Integer): Integer;
    function GetParentItem(nID: Integer): Integer;

    // 菜单显示控制
    function Popup(hParentWnd: HWND; x, y: Integer; hParentEle: HELE; nPosition: Integer): Boolean;
    procedure CloseMenu;
    procedure SetAutoDestroy(bAuto: Boolean);
    procedure EnableDrawBackground(bEnable: Boolean);
    procedure EnableDrawItem(bEnable: Boolean);

    // 菜单项属性
    function SetItemText(nID: Integer; const pText: WideString): Boolean;
    function GetItemText(nID: Integer): WideString;
    function GetItemTextLength(nID: Integer): Integer;
    function SetItemIcon(nID: Integer; hIcon: HIMAGE): Boolean;
    function SetItemFlags(nID: Integer; uFlags: Integer): Boolean;
    procedure SetItemHeight(height: Integer);
    function GetItemHeight: Integer;
    function SetItemWidth(nID: Integer; nWidth: Integer): Boolean;
    function SetItemCheck(nID: Integer; bCheck: Boolean): Boolean;
    function IsItemCheck(nID: Integer): Boolean;

    // 菜单外观
    procedure SetBkImage(hImage: HIMAGE);
    procedure SetBorderColor(crColor: COLORREF);
    procedure SetBorderSize(nLeft, nTop, nRight, nBottom: Integer);
    function GetLeftWidth: Integer;
    function GetLeftSpaceText: Integer;
    function GetItemCount: Integer;
  end;

implementation

{ TXMenu }

constructor TXMenu.Create;
begin
  Handle := XMenu_Create;
end;

destructor TXMenu.Destroy;
begin
  inherited;
end;


procedure TXMenu.AddItem(nID: Integer; const pText: WideString; nParentID: Integer; nFlags: Integer);
begin
  XMenu_AddItem(Handle, nID, PWideChar(pText), nParentID, nFlags);
end;

procedure TXMenu.AddItemIcon(nID: Integer; const pText: WideString; nParentID: Integer; hIcon: HIMAGE; nFlags: Integer);
begin
  XMenu_AddItemIcon(Handle, nID, PWideChar(pText), nParentID, hIcon, nFlags);
end;

procedure TXMenu.InsertItem(nID: Integer; const pText: WideString; nFlags: Integer; insertID: Integer);
begin
  XMenu_InsertItem(Handle, nID, PWideChar(pText), nFlags, insertID);
end;

procedure TXMenu.InsertItemIcon(nID: Integer; const pText: WideString; hIcon: HIMAGE; nFlags: Integer; insertID: Integer);
begin
  XMenu_InsertItemIcon(Handle, nID, PWideChar(pText), hIcon, nFlags, insertID);
end;

function TXMenu.GetFirstChildItem(nID: Integer): Integer;
begin
  Result := XMenu_GetFirstChildItem(Handle, nID);
end;

function TXMenu.GetEndChildItem(nID: Integer): Integer;
begin
  Result := XMenu_GetEndChildItem(Handle, nID);
end;

function TXMenu.GetPrevSiblingItem(nID: Integer): Integer;
begin
  Result := XMenu_GetPrevSiblingItem(Handle, nID);
end;

function TXMenu.GetNextSiblingItem(nID: Integer): Integer;
begin
  Result := XMenu_GetNextSiblingItem(Handle, nID);
end;

function TXMenu.GetParentItem(nID: Integer): Integer;
begin
  Result := XMenu_GetParentItem(Handle, nID);
end;

function TXMenu.Popup(hParentWnd: HWND; x, y: Integer; hParentEle: HELE; nPosition: Integer): Boolean;
begin
  Result := XMenu_Popup(Handle, hParentWnd, x, y, hParentEle, nPosition);
end;

procedure TXMenu.CloseMenu;
begin
  XMenu_CloseMenu(Handle);
end;

procedure TXMenu.SetAutoDestroy(bAuto: Boolean);
begin
  XMenu_SetAutoDestroy(Handle, bAuto);
end;

procedure TXMenu.EnableDrawBackground(bEnable: Boolean);
begin
  XMenu_EnableDrawBackground(Handle, bEnable);
end;

procedure TXMenu.EnableDrawItem(bEnable: Boolean);
begin
  XMenu_EnableDrawItem(Handle, bEnable);
end;

function TXMenu.SetItemText(nID: Integer; const pText: WideString): Boolean;
begin
  Result := XMenu_SetItemText(Handle, nID, PWideChar(pText));
end;

function TXMenu.GetItemText(nID: Integer): WideString;
begin
  Result := XMenu_GetItemText(Handle, nID);
end;

function TXMenu.GetItemTextLength(nID: Integer): Integer;
begin
  Result := XMenu_GetItemTextLength(Handle, nID);
end;

function TXMenu.SetItemIcon(nID: Integer; hIcon: HIMAGE): Boolean;
begin
  Result := XMenu_SetItemIcon(Handle, nID, hIcon);
end;

function TXMenu.SetItemFlags(nID: Integer; uFlags: Integer): Boolean;
begin
  Result := XMenu_SetItemFlags(Handle, nID, uFlags);
end;

procedure TXMenu.SetItemHeight(height: Integer);
begin
  XMenu_SetItemHeight(Handle, height);
end;

function TXMenu.GetItemHeight: Integer;
begin
  Result := XMenu_GetItemHeight(Handle);
end;

function TXMenu.SetItemWidth(nID: Integer; nWidth: Integer): Boolean;
begin
  Result := XMenu_SetItemWidth(Handle, nID, nWidth);
end;

function TXMenu.SetItemCheck(nID: Integer; bCheck: Boolean): Boolean;
begin
  Result := XMenu_SetItemCheck(Handle, nID, bCheck);
end;

function TXMenu.IsItemCheck(nID: Integer): Boolean;
begin
  Result := XMenu_IsItemCheck(Handle, nID);
end;

procedure TXMenu.SetBkImage(hImage: hImage);
begin
  XMenu_SetBkImage(Handle, hImage);
end;

procedure TXMenu.SetBorderColor(crColor: COLORREF);
begin
  XMenu_SetBorderColor(Handle, crColor);
end;

procedure TXMenu.SetBorderSize(nLeft, nTop, nRight, nBottom: Integer);
begin
  XMenu_SetBorderSize(Handle, nLeft, nTop, nRight, nBottom);
end;

function TXMenu.GetLeftWidth: Integer;
begin
  Result := XMenu_GetLeftWidth(Handle);
end;

function TXMenu.GetLeftSpaceText: Integer;
begin
  Result := XMenu_GetLeftSpaceText(Handle);
end;

function TXMenu.GetItemCount: Integer;
begin
  Result := XMenu_GetItemCount(Handle);
end;

end.

