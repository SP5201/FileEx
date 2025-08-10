unit XDateTime;

interface

uses
  Winapi.Windows, System.SysUtils, XElement, XCGUI, XWidget; // 假设XCGUI包含了相关类型定义

type
  TXDateTime = class(TXEle)
  private
  protected
    procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); override;
  public

    // 设置样式
    procedure SetStyle(nStyle: Integer);
    // 获取样式
    function GetStyle: Integer;
    // 切换分割栏为:斜线或横线
    procedure EnableSplitSlash(bSlash: Boolean);
    // 获取内部按钮元素
    function GetButton(nType: Integer): HELE;
    // 获取被选择文字的背景颜色
    function GetSelBkColor: Integer;
    // 设置被选择文字的背景颜色
    procedure SetSelBkColor(crSelectBk: Integer);
    // 获取当前日期
    procedure GetDate(var pnYear, pnMonth, pnDay: Integer);
    // 设置当前日期
    procedure SetDate(nYear, nMonth, nDay: Integer);
    // 获取当前时间
    procedure GetTime(var pnHour, pnMinute, pnSecond: Integer);
    // 设置当前时分秒
    procedure SetTime(nHour, nMinute, nSecond: Integer);
    // 弹出月历卡片
    procedure Popup;

  end;

implementation

{ TXDateTime }

procedure TXDateTime.SetStyle(nStyle: Integer);
begin
  XDateTime_SetStyle(Handle, nStyle);
end;

function TXDateTime.GetStyle: Integer;
begin
  Result := XDateTime_GetStyle(Handle);
end;

procedure TXDateTime.CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  Handle := XDateTime_Create(x, y, cx, cy, hParent.Handle);
end;

procedure TXDateTime.EnableSplitSlash(bSlash: Boolean);
begin
  XDateTime_EnableSplitSlash(Handle, bSlash);
end;

function TXDateTime.GetButton(nType: Integer): HELE;
begin
  Result := XDateTime_GetButton(Handle, nType);
end;

function TXDateTime.GetSelBkColor: Integer;
begin
  Result := XDateTime_GetSelBkColor(Handle);
end;

procedure TXDateTime.SetSelBkColor(crSelectBk: Integer);
begin
  XDateTime_SetSelBkColor(Handle, crSelectBk);
end;

procedure TXDateTime.GetDate(var pnYear, pnMonth, pnDay: Integer);
begin
  XDateTime_GetDate(Handle, pnYear, pnMonth, pnDay);
end;

procedure TXDateTime.SetDate(nYear, nMonth, nDay: Integer);
begin
  XDateTime_SetDate(Handle, nYear, nMonth, nDay);
end;

procedure TXDateTime.GetTime(var pnHour, pnMinute, pnSecond: Integer);
begin
  XDateTime_GetTime(Handle, pnHour, pnMinute, pnSecond);
end;

procedure TXDateTime.SetTime(nHour, nMinute, nSecond: Integer);
begin
  XDateTime_SetTime(Handle, nHour, nMinute, nSecond);
end;

procedure TXDateTime.Popup;
begin
  XDateTime_Popup(Handle);
end;

end.

