unit UI_MovieInfoDownloadForm;

interface

uses
  Windows, Messages, XCGUI, UI_Button, UI_Resource, UI_Form, UI_Edit, UI_Color,
  UI_DateTime, UI_ComboBox, UI_Label, UI_SearchEdit, UI_List;

type
  TMovieInfoDownloadFormUI = class(TFormUI)
  private
    class function OnPaint(hEle, hDraw: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    class function OnListUISelect(hList,iItem: Integer; var pbHandled: BOOL): Integer; stdcall; static;
  protected
    FWindowTitleUI: TSvgLabelUI; {���ڱ���}
    FCloseBtnUI: TSvgBtnUI; {�رհ�ť}
    FSearchEditUI: TSearchEditUI;
    FSearchListUI: TListUI;
    FMovieTitleUI: TSvgLabelUI;    {���ڱ���}
    FMovieGenreUI: TSvgLabelUI; {��������}
    FDirectorLabelUI : TSvgLabelUI;
    FActorLabelUI : TSvgLabelUI;
    FPlotEdit1UI:TEditUI;
    procedure Init; override;
    procedure OnListSelect(ListUI: TListUI;iItem: Integer); virtual;
    procedure Clear;
  public
  end;

var
  Form: TMovieInfoDownloadFormUI;

implementation
{ TVideoEditFormUI }

procedure TMovieInfoDownloadFormUI.Init;
begin
  inherited;
  SetMinimumSize(980, 660);
  SetBorderSize(6, 6, 0, 0);
  FCloseBtnUI := TSvgBtnUI.FromXmlName('������Ϣ����_�رհ�ť');
  FCloseBtnUI.Style('�������\�ر�.svg', '�ر�', 16, 16, True);
  FWindowTitleUI := TSvgLabelUI.FromXmlName('������Ϣ����_����');
  FWindowTitleUI.TextAlign := textAlignFlag_left or textAlignFlag_top;
  FSearchEditUI := TSearchEditUI.FromXmlName('������Ϣ����_������');
  FSearchEditUI.SetRadius(6,6,0,0);
  FSearchListUI := TListUI.FromXmlName('������Ϣ����_�����б�');
  FSearchListUI.ShowSBarH(False);
  FSearchListUI.RegEvent(XE_PAINT, @OnPAINT);
  FSearchListUI.RegEvent(XE_LIST_SELECT, @OnListUISELECT);

  FMovieTitleUI := TSvgLabelUI.FromXmlName('������Ϣ����_ӰƬ����');
  FMovieGenreUI := TSvgLabelUI.FromXmlName('������Ϣ����_ӰƬ����');
  FDirectorLabelUI := TSvgLabelUI.FromXmlName('������Ϣ����_ӰƬ����');
  FActorLabelUI := TSvgLabelUI.FromXmlName('������Ϣ����_ӰƬ��Ա');
  FPlotEdit1UI := TEditUI.FromXmlName('������Ϣ����_ӰƬ���');
end;

procedure TMovieInfoDownloadFormUI.Clear;
begin
  FMovieTitleUI.Text := '';
  FMovieGenreUI.Text := '';
  FDirectorLabelUI.Text := '';
  FActorLabelUI.Text := '';
  FPlotEdit1UI.SetText('');
end;


class function TMovieInfoDownloadFormUI.OnListUISelect(hList,iItem: Integer; var pbHandled: BOOL): Integer;
var
  ListUI: TListUI;
  MovieInfoDownloadFormUI:TMovieInfoDownloadFormUI;
begin
  Result:=0;
  ListUI := TListUI.FromHandle(hList);
  MovieInfoDownloadFormUI := TMovieInfoDownloadFormUI.GetClassFormHandle(ListUI.GetHWINDOW);
  MovieInfoDownloadFormUI.OnListSelect(ListUI, iItem);
end;

procedure TMovieInfoDownloadFormUI.OnListSelect(ListUI: TListUI;
  iItem: Integer);
begin

end;


class function TMovieInfoDownloadFormUI.OnPaint(hEle, hDraw: Integer; pbHandled: PBoolean): Integer;
var
  RC: TRect;
begin
  XEle_GetClientRect(hEle, RC);
  XDraw_SetBrushColor(hDraw, Theme_Edit_BorderColor_focus_no);
  XDraw_DrawRoundRect(hDraw, RC, 4, 4);
  Result := 0;
end;

end.

