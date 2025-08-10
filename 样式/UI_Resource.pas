unit UI_Resource;

interface

uses
  Windows, Classes, XCGUI;

procedure XResource_Init();

procedure XResource_LoadZipRes(pResName: PWideChar; pPassword: PWideChar = nil);

function XResource_LoadZipLayout(pXmlName: PWideChar; pPassword: PWideChar = nil; hParent: Integer = 0; hAttachWnd: Integer = 0): Integer;

function XResource_LoadZipSvg(pFileName: PWideChar; pPassword: PWideChar = nil): Integer;

function XResource_LoadZipSvgEx(ResourceStream: TResourceStream; pFileName: PWideChar; pPassword: PWideChar = nil): Integer;

function XResource_LoadZipImage(pFileName: PWideChar; pPassword: PWideChar = nil): Integer;

function XResource_LoadZipTemp(nType: Integer; pFileName: PWideChar; pPassword: PWideChar = nil): Integer;

procedure XResource_Release();

implementation

var
  ResourceStream: TResourceStream;

procedure XResource_Init();
begin
  ResourceStream := TResourceStream.Create(HInstance, 'SkinZip', RT_RCDATA);
  XResource_LoadZipRes('Resource.res');
end;

procedure XResource_LoadZipRes(pResName: PWideChar; pPassword: PWideChar = nil);
begin
  XC_LoadResourceZipMem(Integer(ResourceStream.Memory), ResourceStream.Size, pResName, pPassword);
end;

function XResource_LoadZipLayout(pXmlName: PWideChar; pPassword: PWideChar = nil; hParent: Integer = 0; hAttachWnd: Integer = 0): Integer;
begin
  Result := XC_LoadLayoutZipMem(Integer(ResourceStream.Memory), ResourceStream.Size, pXmlName, pPassword, hParent, hAttachWnd);
end;

function XResource_LoadZipSvg(pFileName: PWideChar; pPassword: PWideChar = nil): Integer;
begin
    Result := XSvg_LoadZipMem(Integer(ResourceStream.Memory), ResourceStream.Size, pFileName, pPassword);
end;

function XResource_LoadZipSvgEx(ResourceStream: TResourceStream; pFileName: PWideChar; pPassword: PWideChar = nil): Integer;
begin
  Result := XSvg_LoadZipMem(Integer(ResourceStream.Memory), ResourceStream.Size, pFileName, pPassword);
end;

function XResource_LoadZipImage(pFileName: PWideChar; pPassword: PWideChar = nil): Integer;
begin
  Result := XImage_LoadZipMem(Integer(ResourceStream.Memory), ResourceStream.Size, pFileName, pPassword);
end;

function XResource_LoadZipTemp(nType: Integer; pFileName: PWideChar; pPassword: PWideChar = nil): Integer;
begin
  Result := XTemp_LoadZipMem(nType, Integer(ResourceStream.Memory), ResourceStream.Size, pFileName, pPassword);
end;

procedure XResource_Release();
begin
  ResourceStream.Free;
  ResourceStream := nil;
end;


end.

