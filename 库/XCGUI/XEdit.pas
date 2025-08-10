unit XEdit;

interface

uses
  Windows, Classes, SysUtils, XCGUI, XScrollView, XWidget;

type
  // �༭���װ��
  TXEdit = class(TXSView)
  protected
    procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); override;
  public
    procedure EnableAutoWrap(bEnable: BOOL);
    procedure EnableReadOnly(bEnable: BOOL);
    procedure EnableMultiLine(bEnable: BOOL);
    procedure EnablePassword(bEnable: BOOL);
    procedure EnableAutoSelAll(bEnable: BOOL);
    procedure EnableAutoCancelSel(bEnable: BOOL);
    function IsReadOnly: BOOL;
    function IsMultiLine: BOOL;
    function IsPassword: BOOL;
    function IsAutoWrap: BOOL;
    function IsEmpty: BOOL;
    function IsInSelect(iRow, iCol: Integer): BOOL;
    function GetRowCount: Integer;
    function GetRowCountEx: Integer;
    procedure SetDefaultText(const pString: PChar);
    procedure SetDefaultTextColor(color: TColorRef);
    procedure SetPasswordCharacter(ch: WideChar);
    procedure SetTextAlign(align: Integer);
    procedure SetTabSpace(nSpace: Integer);
    procedure SetBackFont(hFont: HFONTX);
    procedure SetSpaceSize(size: Integer);
    procedure SetCharSpaceSize(size, sizeZh: Integer);
    procedure SetText(const AText: string);
    procedure SetTextInt(nValue: Integer);
    function GetText(pOut: PWideChar; nOutLen: Integer): Integer;
    function GetText_Temp: string;
    function GetTextRow(iRow: Integer; pOut: PWideChar; nOutLen: Integer): Integer;
    function GetTextRow_Temp(iRow: Integer): Pchar;
    function GetLength: Integer;
    function GetLengthRow(iRow: Integer): Integer;
    function GetAt(iRow, iCol: Integer): WideChar;
    procedure InsertText(iRow, iCol: Integer; const pString: Pchar);
    procedure InsertTextEx(iRow, iCol: Integer; const pString: Pchar; iStyle: Integer);
    procedure InsertObject(iRow, iCol: Integer; hObj: HELE);
    procedure AddText(const pString: Pchar);
    procedure AddTextUser(const pString: Pchar);
    procedure AddTextEx(const pString: Pchar; iStyle: Integer);
    function AddObject(hObj: HELE): Integer;
    procedure AddByStyle(iStyle: Integer);
    function AddStyle(hFont_image_Obj: HELE; color: TColorRef; bColor: BOOL): Integer;
    function AddStyleEx(fontName: Pchar; fontSize, fontStyle: Integer; color: TColorRef; bColor: BOOL): Integer;
    function ModifyStyle(iStyle: Integer; hFont: HFONTX; color: TColorRef; bColor: BOOL): Integer;
    function ReleaseStyle(iStyle: Integer): BOOL;
    function GetStyleInfo(iStyle: Integer; out info: Tedit_style_info_): BOOL;
    procedure SetCurStyle(iStyle: Integer);
    procedure SetSelectTextStyle(iStyle: Integer);
    procedure SetCaretColor(color: TColorRef);
    procedure SetCaretWidth(nWidth: Integer);
    procedure SetSelectBkColor(color: TColorRef);
    procedure SetRowHeight(nHeight: Integer);
    procedure SetRowHeightEx(iRow: Integer; nHeight: Integer);
    procedure SetRowSpace(nSpace: Integer);
    function SetCurPos(pos: Integer): BOOL;
    function GetCurPos: Integer;
    procedure SetCurPosEx(iRow, iCol: Integer);
    procedure GetCurPosEx(out iRow, iCol: Integer);
    function GetCurRow: Integer;
    function GetCurCol(iRow: Integer): Integer;
    procedure MoveEnd;
    procedure GetPoint(iRow, iCol: Integer; out pOut: TPoint);
    function AutoScroll: BOOL;
    function AutoScrollEx(iRow, iCol: Integer): BOOL;
    procedure PosToRowCol(iPos: Integer; out pInfo: Tposition_);
    function RowColToPos(iRow, iCol: Integer): Integer;
    function SelectAll: BOOL;
    function CancelSelect: BOOL;
    function DeleteSelect: BOOL;
    function SetSelect(iStartRow, iStartCol, iEndRow, iEndCol: Integer): BOOL;
    function GetSelectText(pOut: PWideChar; nOutLen: Integer): Integer;
    function GetSelectText_Temp: Pchar;
    function GetSelectTextLength: Integer;
    function GetSelectRange(out pBegin, pEnd: Tposition_): BOOL;
    procedure GetVisibleRowRange(out piStart, piEnd: Integer);
    function Delete(iStartRow, iStartCol, iEndRow, iEndCol: Integer): BOOL;
    function DeleteRow(iRow: Integer): BOOL;
    function ClipboardCut: BOOL;
    function ClipboardCopy: BOOL;
    function ClipboardCopyAll: BOOL;
    function ClipboardPaste: BOOL;
    function Undo: BOOL;
    procedure AddChatBegin(hImageAvatar, hImageBubble: HIMAGE; nFlag: Integer);
    procedure AddChatEnd;
    procedure SetChatIndentation(nIndentation: Integer);
    procedure SetChatMaxWidth(nWidth: Integer);
    function GetChatFlags(iRow: Integer): Integer;
    property Text: string read GetText_Temp write SetText;
  end;

implementation

procedure TXEdit.AddByStyle(iStyle: Integer);
begin
  XEdit_AddByStyle(Handle, iStyle);
end;

procedure TXEdit.AddChatBegin(hImageAvatar, hImageBubble: HIMAGE; nFlag: Integer);
begin
  XEdit_AddChatBegin(Handle, hImageAvatar, hImageBubble, nFlag);
end;

procedure TXEdit.AddChatEnd;
begin
  XEdit_AddChatEnd(Handle);
end;

function TXEdit.AddObject(hObj: HELE): Integer;
begin
  Result := XEdit_AddObject(Handle, hObj);
end;

function TXEdit.AddStyle(hFont_image_Obj: HELE; color: TColorRef; bColor: BOOL): Integer;
begin
  Result := XEdit_AddStyle(Handle, hFont_image_Obj, color, bColor);
end;

function TXEdit.AddStyleEx(fontName: Pchar; fontSize, fontStyle: Integer; color: TColorRef; bColor: BOOL): Integer;
begin
  Result := XEdit_AddStyleEx(Handle, PWideChar(WideString(fontName)), fontSize, fontStyle, color, bColor);
end;

procedure TXEdit.AddText(const pString: Pchar);
begin
  XEdit_AddText(Handle, PWideChar(WideString(pString)));
end;

procedure TXEdit.AddTextEx(const pString: Pchar; iStyle: Integer);
begin
  XEdit_AddTextEx(Handle, PWideChar(WideString(pString)), iStyle);
end;

procedure TXEdit.AddTextUser(const pString: Pchar);
begin
  XEdit_AddTextUser(Handle, PWideChar(WideString(pString)));
end;

function TXEdit.AutoScroll: BOOL;
begin
  Result := XEdit_AutoScroll(Handle);
end;

function TXEdit.AutoScrollEx(iRow, iCol: Integer): BOOL;
begin
  Result := XEdit_AutoScrollEx(Handle, iRow, iCol);
end;

function TXEdit.CancelSelect: BOOL;
begin
  Result := XEdit_CancelSelect(Handle);
end;

function TXEdit.ClipboardCopy: BOOL;
begin
  Result := XEdit_ClipboardCopy(Handle);
end;

function TXEdit.ClipboardCopyAll: BOOL;
begin
  Result := XEdit_ClipboardCopyAll(Handle);
end;

function TXEdit.ClipboardCut: BOOL;
begin
  Result := XEdit_ClipboardCut(Handle);
end;

function TXEdit.ClipboardPaste: BOOL;
begin
  Result := XEdit_ClipboardPaste(Handle);
end;

procedure TXEdit.CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  Handle := XEdit_Create(x, y, cx, cy, hParent.Handle);
end;

procedure TXEdit.EnableAutoWrap(bEnable: BOOL);
begin
  XEdit_EnableAutoWrap(Handle, bEnable);
end;

procedure TXEdit.EnableReadOnly(bEnable: BOOL);
begin
  XEdit_EnableReadOnly(Handle, bEnable);
end;

procedure TXEdit.EnableMultiLine(bEnable: BOOL);
begin
  XEdit_EnableMultiLine(Handle, bEnable);
end;

procedure TXEdit.EnablePassword(bEnable: BOOL);
begin
  XEdit_EnablePassword(Handle, bEnable);
end;

procedure TXEdit.EnableAutoSelAll(bEnable: BOOL);
begin
  XEdit_EnableAutoSelAll(Handle, bEnable);
end;

function TXEdit.Delete(iStartRow, iStartCol, iEndRow, iEndCol: Integer): BOOL;
begin
  Result := XEdit_Delete(Handle, iStartRow, iStartCol, iEndRow, iEndCol);
end;

function TXEdit.DeleteRow(iRow: Integer): BOOL;
begin
  Result := XEdit_DeleteRow(Handle, iRow);
end;

function TXEdit.DeleteSelect: BOOL;
begin
  Result := XEdit_DeleteSelect(Handle);
end;

procedure TXEdit.EnableAutoCancelSel(bEnable: BOOL);
begin
  XEdit_EnableAutoCancelSel(Handle, bEnable);
end;

function TXEdit.IsReadOnly: BOOL;
begin
  Result := XEdit_IsReadOnly(Handle);
end;

function TXEdit.IsMultiLine: BOOL;
begin
  Result := XEdit_IsMultiLine(Handle);
end;

function TXEdit.IsPassword: BOOL;
begin
  Result := XEdit_IsPassword(Handle);
end;

procedure TXEdit.InsertObject(iRow, iCol: Integer; hObj: HELE);
begin
  XEdit_InsertObject(Handle, iRow, iCol, hObj);
end;

procedure TXEdit.InsertText(iRow, iCol: Integer; const pString: Pchar);
begin
  XEdit_InsertText(Handle, iRow, iCol, PWideChar(WideString(pString)));
end;

procedure TXEdit.InsertTextEx(iRow, iCol: Integer; const pString: Pchar; iStyle: Integer);
begin
  XEdit_InsertTextEx(Handle, iRow, iCol, PWideChar(WideString(pString)), iStyle);
end;

function TXEdit.IsAutoWrap: BOOL;
begin
  Result := XEdit_IsAutoWrap(Handle);
end;

function TXEdit.IsEmpty: BOOL;
begin
  Result := XEdit_IsEmpty(Handle);
end;

function TXEdit.IsInSelect(iRow, iCol: Integer): BOOL;
begin
  Result := XEdit_IsInSelect(Handle, iRow, iCol);
end;

function TXEdit.GetRowCount: Integer;
begin
  Result := XEdit_GetRowCount(Handle);
end;

function TXEdit.GetRowCountEx: Integer;
begin
  Result := XEdit_GetRowCountEx(Handle);
end;

procedure TXEdit.SetDefaultText(const pString: PChar);
begin
  XEdit_SetDefaultText(Handle, pString);
end;

procedure TXEdit.SetDefaultTextColor(color: TColorRef);
begin
  XEdit_SetDefaultTextColor(Handle, color);
end;

procedure TXEdit.SetPasswordCharacter(ch: WideChar);
begin
  XEdit_SetPasswordCharacter(Handle, ch);
end;

procedure TXEdit.SetRowHeight(nHeight: Integer);
begin
  XEdit_SetRowHeight(Handle, nHeight);
end;

procedure TXEdit.SetRowHeightEx(iRow, nHeight: Integer);
begin
  XEdit_SetRowHeightEx(Handle, iRow, nHeight);
end;

procedure TXEdit.SetRowSpace(nSpace: Integer);
begin
  XEdit_SetRowSpace(Handle, nSpace);
end;

procedure TXEdit.SetTextAlign(align: Integer);
begin
  XEdit_SetTextAlign(Handle, align);
end;

procedure TXEdit.SetTabSpace(nSpace: Integer);
begin
  XEdit_SetTabSpace(Handle, nSpace);
end;

function TXEdit.SelectAll: BOOL;
begin
  Result := XEdit_SelectAll(Handle);
end;

procedure TXEdit.SetBackFont(hFont: HFONTX);
begin
  XEdit_SetBackFont(Handle, hFont);
end;

function TXEdit.SetSelect(iStartRow, iStartCol, iEndRow, iEndCol: Integer): BOOL;
begin
  Result := XEdit_SetSelect(Handle, iStartRow, iStartCol, iEndRow, iEndCol);
end;

procedure TXEdit.SetSelectBkColor(color: TColorRef);
begin
  XEdit_SetSelectBkColor(Handle, color);
end;

procedure TXEdit.SetSelectTextStyle(iStyle: Integer);
begin
  XEdit_SetSelectTextStyle(Handle, iStyle);
end;

procedure TXEdit.SetSpaceSize(size: Integer);
begin
  XEdit_SetSpaceSize(Handle, size);
end;

procedure TXEdit.SetCaretColor(color: TColorRef);
begin
  XEdit_SetCaretColor(Handle, color);
end;

procedure TXEdit.SetCaretWidth(nWidth: Integer);
begin
   XEdit_SetCaretWidth(Handle, nWidth);
end;

procedure TXEdit.SetCharSpaceSize(size, sizeZh: Integer);
begin
  XEdit_SetCharSpaceSize(Handle, size, sizeZh);
end;

procedure TXEdit.SetChatIndentation(nIndentation: Integer);
begin
  XEdit_SetChatIndentation(Handle, nIndentation);
end;

procedure TXEdit.SetChatMaxWidth(nWidth: Integer);
begin
  XEdit_SetChatMaxWidth(Handle, nWidth);
end;

procedure TXEdit.SetText(const AText: string);
begin
  XEdit_SetText(Handle, PChar(AText));
end;

procedure TXEdit.SetTextInt(nValue: Integer);
begin
  XEdit_SetTextInt(Handle, nValue);
end;

function TXEdit.Undo: BOOL;
begin
  Result := XEdit_Undo(Handle);
end;

function TXEdit.GetText(pOut: PWideChar; nOutLen: Integer): Integer;
var
  Len: Integer;
  P: PChar;
begin
  Len := XEdit_GetLength(Handle);
  P := StrAlloc(Len);
  try
   Result := XEdit_GetText(Handle, P, Len);
  finally
    StrDispose(P);
  end;
end;

function TXEdit.GetTextRow(iRow: Integer; pOut: PWideChar; nOutLen: Integer): Integer;
begin
  Result := XEdit_GetTextRow(Handle, iRow, pOut, nOutLen);
end;

function TXEdit.GetTextRow_Temp(iRow: Integer): Pchar;
begin
  Result := XEdit_GetTextRow_Temp(Handle, iRow);
end;

function TXEdit.GetText_Temp: string;
begin
  Result := XEdit_GetText_Temp(Handle);
end;

procedure TXEdit.GetVisibleRowRange(out piStart, piEnd: Integer);
begin
  XEdit_GetVisibleRowRange(Handle, piStart, piEnd);
end;

function TXEdit.GetSelectRange(out pBegin, pEnd: Tposition_): BOOL;
begin
  Result := XEdit_GetSelectRange(Handle, pBegin, pEnd);
end;

function TXEdit.GetSelectText(pOut: PWideChar; nOutLen: Integer): Integer;
begin
  Result := XEdit_GetSelectText(Handle, pOut, nOutLen);
end;

function TXEdit.GetSelectText_Temp: Pchar;
begin
  Result := XEdit_GetSelectText_Temp(Handle);
end;

function TXEdit.GetStyleInfo(iStyle: Integer; out info: Tedit_style_info_): BOOL;
begin
  Result := XEdit_GetStyleInfo(Handle, iStyle, info);
end;

function TXEdit.GetSelectTextLength: Integer;
begin
  Result := XEdit_GetSelectTextLength(Handle);
end;

function TXEdit.ModifyStyle(iStyle: Integer; hFont: HFONTX; color: TColorRef; bColor: BOOL): Integer;
begin
  Result := XEdit_ModifyStyle(Handle, iStyle, hFont, color, bColor);
end;

procedure TXEdit.MoveEnd;
begin
  XEdit_MoveEnd(Handle);
end;

procedure TXEdit.PosToRowCol(iPos: Integer; out pInfo: Tposition_);
begin
  XEdit_PosToRowCol(Handle, iPos, pInfo);
end;

function TXEdit.ReleaseStyle(iStyle: Integer): BOOL;
begin
  Result := XEdit_ReleaseStyle(Handle, iStyle);
end;

function TXEdit.RowColToPos(iRow, iCol: Integer): Integer;
begin
  Result := XEdit_RowColToPos(Handle, iRow, iCol);
end;

function TXEdit.SetCurPos(pos: Integer): BOOL;
begin
  Result := XEdit_SetCurPos(Handle, pos);
end;

function TXEdit.GetAt(iRow, iCol: Integer): WideChar;
begin
  Result := XEdit_GetAt(Handle, iRow, iCol);
end;

function TXEdit.GetChatFlags(iRow: Integer): Integer;
begin
  Result := XEdit_GetChatFlags(Handle, iRow);
end;

function TXEdit.GetCurCol(iRow: Integer): Integer;
begin
  Result := XEdit_GetCurCol(Handle, iRow);
end;

procedure TXEdit.SetCurPosEx(iRow, iCol: Integer);
begin
  XEdit_SetCurPosEx(Handle, iRow, iCol);
end;

procedure TXEdit.SetCurStyle(iStyle: Integer);
begin

end;

function TXEdit.GetCurPos: Integer;
begin
  Result := XEdit_GetCurPos(Handle);
end;

procedure TXEdit.GetCurPosEx(out iRow, iCol: Integer);
begin
  XEdit_GetCurPosEx(Handle, iRow, iCol);
end;

function TXEdit.GetCurRow: Integer;
begin
  Result := XEdit_GetCurRow(Handle);
end;

function TXEdit.GetLength: Integer;
begin
  Result := XEdit_GetLength(Handle);
end;

function TXEdit.GetLengthRow(iRow: Integer): Integer;
begin
  Result := XEdit_GetLengthRow(Handle, iRow);
end;

procedure TXEdit.GetPoint(iRow, iCol: Integer; out pOut: TPoint);
begin
  XEdit_GetPoint(Handle, iRow, iCol, pOut);
end;



end.

