unit Ui_Layout;

interface

uses
  XCGUI, XLayout, XWidget,UI_Resource;

type
  TLayoutUI = class(TXLayout)
  public
    function LoadLayout(const AFileName: string): Integer;
  end;

implementation

{ TLayoutUI }



function TLayoutUI.LoadLayout(const AFileName: string): Integer;
begin
  Result := XResource_LoadZipLayout(PChar(AFileName), nil, Handle, HWINDOW);
end;

end.
