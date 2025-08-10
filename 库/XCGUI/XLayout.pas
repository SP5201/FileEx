unit XLayout;

interface

uses
  Windows, Messages, XCGUI, XScrollView, XWidget;

type
  TXLayout = class(TXSView)
  private
  protected
    procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);  override;
  public
    constructor Create(x: Integer = 0; y: Integer = 0; cx: Integer = 0; cy: Integer = 0; hParent: TXWidget = nil);
    destructor Destroy; override;
    procedure EnableLayout(bEnable: Boolean);
    function IsEnableLayout: Boolean;
    procedure ShowLayoutFrame(bEnable: Boolean);
    function GetWidthIn: Integer;
    function GetHeightIn: Integer;
  end;

implementation

{ TXLayout }

constructor TXLayout.Create(x: Integer = 0; y: Integer = 0; cx: Integer = 0; cy: Integer = 0; hParent: TXWidget = nil);
begin
  inherited Create(x, y, cx, cy, hParent);
end;

procedure TXLayout.CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  Handle := XLayout_Create(x, y, cx, cy, hParent.Handle);
  Init;
end;

destructor TXLayout.Destroy;
begin
  inherited;
end;

procedure TXLayout.EnableLayout(bEnable: Boolean);
begin
  XLayout_EnableLayout(Handle, bEnable);
end;

function TXLayout.IsEnableLayout: Boolean;
begin
  Result := XLayout_IsEnableLayout(Handle);
end;

procedure TXLayout.ShowLayoutFrame(bEnable: Boolean);
begin
  XLayout_ShowLayoutFrame(Handle, bEnable);
end;

function TXLayout.GetWidthIn: Integer;
begin
  Result := XLayout_GetWidthIn(Handle);
end;

function TXLayout.GetHeightIn: Integer;
begin
  Result := XLayout_GetHeightIn(Handle);
end;

end.

