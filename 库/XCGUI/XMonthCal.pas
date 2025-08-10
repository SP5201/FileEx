unit XMonthCal;

interface

uses
  Winapi.Windows, System.SysUtils, XElement, XCGUI, XWidget;

type
  TXMonthCal = class(TXEle)
  private
    // 可添加私有成员变量
  protected
    procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); override;
  public
    // 获取内部按钮元素
    function GetButton(nType: monthCal_button_type_): HELE;
    // 设置月历当前年月日
    procedure SetToday(nYear, nMonth, nDay: Integer);
    // 获取月历当前年月日
    procedure GetToday(var pnYear, pnMonth, pnDay: Integer);
    // 设置月历选中的年月日
    procedure SetSelDate(nYear, nMonth, nDay: Integer);
    // 获取月历选中的年月日
    procedure GetSelDate(var pnYear, pnMonth, pnDay: Integer);
    // 设置月历文本颜色
    procedure SetTextColor(nFlag: Integer; color: Integer);
  end;

implementation

{ TXMonthCal }

procedure TXMonthCal.CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  Handle := XMonthCal_Create(x, y, cx, cy, hParent.Handle);
end;

function TXMonthCal.GetButton(nType: monthCal_button_type_): HELE;
begin
  Result := XMonthCal_GetButton(Handle, nType);
end;

procedure TXMonthCal.SetToday(nYear, nMonth, nDay: Integer);
begin
  XMonthCal_SetToday(Handle, nYear, nMonth, nDay);
end;

procedure TXMonthCal.GetToday(var pnYear, pnMonth, pnDay: Integer);
begin
  XMonthCal_GetToday(Handle, pnYear, pnMonth, pnDay);
end;

procedure TXMonthCal.SetSelDate(nYear, nMonth, nDay: Integer);
begin
  XMonthCal_SeSelDate(Handle, nYear, nMonth, nDay);
end;

procedure TXMonthCal.GetSelDate(var pnYear, pnMonth, pnDay: Integer);
begin
  XMonthCal_GetSelDate(Handle, pnYear, pnMonth, pnDay);
end;

procedure TXMonthCal.SetTextColor(nFlag: Integer; color: Integer);
begin
  XMonthCal_SetTextColor(Handle, nFlag, color);
end;

end.

