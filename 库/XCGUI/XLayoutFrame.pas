unit XLayoutFrame;

interface

uses
  Winapi.Windows, XCGUI, XWidget, XLayout;

type
  TXLayoutFrame = class(TXLayout)
  private
  protected
    procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); override;
  public
    constructor CreateEx(hParent: TXWidget); overload;
    procedure EnableLayout(bEnable: BOOL);
    function IsEnableLayout: BOOL;
    procedure ShowLayoutFrame(bEnable: BOOL);
    function GetWidthIn: Integer;
    function GetHeightIn: Integer;
  end;

implementation

constructor TXLayoutFrame.CreateEx(hParent: TXWidget);
begin
  inherited Create;
  CreateHandle(0, 0, 0, 0, hParent);
end;

procedure TXLayoutFrame.CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  inherited;
  Handle := XLayoutFrame_Create(x, y, cx, cy, hParent.Handle);
end;


procedure TXLayoutFrame.EnableLayout(bEnable: BOOL);
begin
  XLayoutFrame_EnableLayout(Handle, bEnable);
end;

function TXLayoutFrame.IsEnableLayout: BOOL;
begin
  Result := XLayoutFrame_IsEnableLayout(Handle);
end;

procedure TXLayoutFrame.ShowLayoutFrame(bEnable: BOOL);
begin
  XLayoutFrame_ShowLayoutFrame(Handle, bEnable);
end;

function TXLayoutFrame.GetWidthIn: Integer;
begin
  Result := XLayoutFrame_GetWidthIn(Handle);
end;

function TXLayoutFrame.GetHeightIn: Integer;
begin
  Result := XLayoutFrame_GetHeightIn(Handle);
end;

end.

