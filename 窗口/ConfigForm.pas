unit ConfigForm;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, XCGUI, XLayout, XWidget, XElement, UI_Resource, XForm,
  Ui_Color, UI_ConfigForm, ConfigUnit;

type
  TConfigForm = class(TConfigFormUI)
  private
    FConfig: TConfig;
    class function OnConfirmBtnClick(hBtn: Integer; pbHandled: PBoolean): Integer; stdcall; static;
    // 私有成员变量
  protected
    procedure Init; override;
  public
        constructor  Create(hParent: integer);
  end;

implementation

uses
  Winapi.Messages, Winapi.ShellAPI, System.UITypes, XBUTTON;

{ TConfigForm }

constructor TConfigForm.Create(hParent: integer);
var
  Form: TConfigForm;
begin
  Form := TConfigForm.FromXml('设置窗口\ConfigForm.xml', hParent) as TConfigForm;
  Form.Show;
end;

procedure TConfigForm.Init;
begin
  inherited;
  FConfig := Config;
  ScanFormatEditUI.Text := FConfig.ConfigData.ScanFormats;
  ExcludePathEditUI.Text := FConfig.ConfigData.ExcludePaths;
  ExcludeSizeEditUI.Text := IntToStr(FConfig.ConfigData.ExcludeSize);
  PlayerPathEditUI.Text := FConfig.ConfigData.PlayerPath;
  ConfirmBtnUI.RegEvent(XE_BNCLICK, @OnConfirmBtnClick);

  // 加载代理设置
  case FConfig.ConfigData.ProxyType of
    ptNoProxy: XBtn_SetCheck(NoProxyBtnUI.Handle, True);
    ptHttpProxy: XBtn_SetCheck(HttpProxyBtnUI.Handle, True);
    ptSocks5Proxy: XBtn_SetCheck(Socks5ProxyBtnUI.Handle, True);
  end;
  ProxyAddressEditUI.Text := FConfig.ConfigData.ProxyAddress;
  ProxyPortEditUI.Text := IntToStr(FConfig.ConfigData.ProxyPort);

end;

class function TConfigForm.OnConfirmBtnClick(hBtn: Integer; pbHandled: PBoolean): Integer;
var
  Form: TConfigForm;
  ExcludeSize: Integer;
begin
  Result := 0;
  Form := TConfigForm(GetClassFormHandle(XWidget_GetHWINDOW(hBtn)));
  if Assigned(Form) then
  begin
    Form.FConfig.SetScanFormats(Form.ScanFormatEditUI.Text);
    Form.FConfig.SetExcludePaths(Form.ExcludePathEditUI.Text);
    if TryStrToInt(Form.ExcludeSizeEditUI.Text, ExcludeSize) then
      Form.FConfig.SetExcludeSize(ExcludeSize);
    Form.FConfig.SetPlayerPath(Form.PlayerPathEditUI.Text);

    // 保存代理设置
    if XBtn_IsCheck(Form.NoProxyBtnUI.Handle) then
      Form.FConfig.SetProxyType(ptNoProxy)
    else if XBtn_IsCheck(Form.HttpProxyBtnUI.Handle) then
      Form.FConfig.SetProxyType(ptHttpProxy)
    else if XBtn_IsCheck(Form.Socks5ProxyBtnUI.Handle) then
      Form.FConfig.SetProxyType(ptSocks5Proxy);

    Form.FConfig.SetProxyAddress(Form.ProxyAddressEditUI.Text);
    if TryStrToInt(Form.ProxyPortEditUI.Text, ExcludeSize) then // reuse ExcludeSize var
      Form.FConfig.SetProxyPort(ExcludeSize);

    Form.FConfig.SaveToFile;
    XModalWnd_EndModal(Form.Handle, 1); // mrOk
  end;
  pbHandled^ := True;
end;


end. 