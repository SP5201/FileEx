unit UI_MonthCal;

interface

uses
  Windows, Math, XCGUI, XBUTTON, UI_Resource, UI_Color,
  UI_Animation, SysUtils, XWidget, XMonthCal, UI_Button;

type
  TMonthCalUI = class(TXBtn)
  private
  FTodayBtn:TSvgBtnUI;
  FLastyearBtn:TSvgBtnUI;
  FNextyearBtn:TSvgBtnUI;
  FLastmonthBtn:TSvgBtnUI;
  FNextmonthBtn:TSvgBtnUI;
  protected
    procedure Init; override;
  public
  end;


implementation

{ TMonthCalUI }

procedure TMonthCalUI.Init;
begin
  inherited;
  FTodayBtn:=TSvgBtnUI.FromHandle(XMonthCal_GetButton(Handle,monthCal_button_type_today));
  FLastyearBtn:=TSvgBtnUI.FromHandle(XMonthCal_GetButton(Handle,monthCal_button_type_last_year));
  FNextyearBtn:=TSvgBtnUI.FromHandle(XMonthCal_GetButton(Handle,monthCal_button_type_next_year));
  FLastmonthBtn:=TSvgBtnUI.FromHandle(XMonthCal_GetButton(Handle,monthCal_button_type_last_month));
  FNextmonthBtn:=TSvgBtnUI.FromHandle(XMonthCal_GetButton(Handle,monthCal_button_type_next_month));
end;

end.
