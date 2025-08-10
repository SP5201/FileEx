unit ImageCore;

interface

uses
  Windows, Messages, System.SysUtils, ActiveX, ComObj, Wincodec, D2D1, XCGUI;

var
  WICFactory: IWICImagingFactory;
  D2D1Factory: ID2D1Factory;
  DWriteFactory: IDWriteFactory;
  DefaultTextFormat: IDWriteTextFormat;

function InitializeRenderer: Boolean;

procedure ExitRenderer;

implementation

function InitializeRenderer: Boolean;
var
  hr: HRESULT;
  DisplayScale, DpiX, DpiY: Single;
begin
  CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
  D2D1Factory := ID2D1Factory(XC_GetD2dFactory);
  WICFactory := IWICImagingFactory(XC_GetWicFactory);
  DWriteFactory := IDWriteFactory(XC_GetDWriteFactory);
  D2D1Factory.GetDesktopDpi(DpiX, DpiY);

  DisplayScale := DpiX / 96.0;
  hr := DWriteFactory.CreateTextFormat('微软雅黑', nil, DWRITE_FONT_WEIGHT_NORMAL, DWRITE_FONT_STYLE_NORMAL, DWRITE_FONT_STRETCH_NORMAL, 13.8 * DisplayScale, 'zh-cn', DefaultTextFormat);
  Result := SUCCEEDED(hr);
end;

procedure ExitRenderer;
begin
  DefaultTextFormat := nil;
  if Assigned(WICFactory) then
    WICFactory := nil;
  if Assigned(D2D1Factory) then
    D2D1Factory := nil;
  if Assigned(DWriteFactory) then
    DWriteFactory := nil;
  CoUninitialize;
end;

end.

