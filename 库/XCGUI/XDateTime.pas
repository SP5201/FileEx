unit XDateTime;

interface

uses
  Winapi.Windows, System.SysUtils, XElement, XCGUI, XWidget; // ����XCGUI������������Ͷ���

type
  TXDateTime = class(TXEle)
  private
  protected
    procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); override;
  public

    // ������ʽ
    procedure SetStyle(nStyle: Integer);
    // ��ȡ��ʽ
    function GetStyle: Integer;
    // �л��ָ���Ϊ:б�߻����
    procedure EnableSplitSlash(bSlash: Boolean);
    // ��ȡ�ڲ���ťԪ��
    function GetButton(nType: Integer): HELE;
    // ��ȡ��ѡ�����ֵı�����ɫ
    function GetSelBkColor: Integer;
    // ���ñ�ѡ�����ֵı�����ɫ
    procedure SetSelBkColor(crSelectBk: Integer);
    // ��ȡ��ǰ����
    procedure GetDate(var pnYear, pnMonth, pnDay: Integer);
    // ���õ�ǰ����
    procedure SetDate(nYear, nMonth, nDay: Integer);
    // ��ȡ��ǰʱ��
    procedure GetTime(var pnHour, pnMinute, pnSecond: Integer);
    // ���õ�ǰʱ����
    procedure SetTime(nHour, nMinute, nSecond: Integer);
    // ����������Ƭ
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

