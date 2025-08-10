unit XMonthCal;

interface

uses
  Winapi.Windows, System.SysUtils, XElement, XCGUI, XWidget;

type
  TXMonthCal = class(TXEle)
  private
    // �����˽�г�Ա����
  protected
    procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); override;
  public
    // ��ȡ�ڲ���ťԪ��
    function GetButton(nType: monthCal_button_type_): HELE;
    // ����������ǰ������
    procedure SetToday(nYear, nMonth, nDay: Integer);
    // ��ȡ������ǰ������
    procedure GetToday(var pnYear, pnMonth, pnDay: Integer);
    // ��������ѡ�е�������
    procedure SetSelDate(nYear, nMonth, nDay: Integer);
    // ��ȡ����ѡ�е�������
    procedure GetSelDate(var pnYear, pnMonth, pnDay: Integer);
    // ���������ı���ɫ
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

