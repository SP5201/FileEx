unit XSliderBar;

interface

uses
  Windows, Classes, XCGUI, XElement, XWidget;

type
  TXSliderBar = class(TXEle)
  private
    function GetPos: Integer;
    procedure SetPos(iPos: Integer);
    function GetRangeMax: Integer;
    procedure SetRangeMax(Value: Integer);
    function GetButtonWidth: Integer;
    procedure SetButtonWidth(Value: Integer);
    function GetButtonHeight: Integer;
    procedure SetButtonHeight(Value: Integer);
  protected
    procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); override;
  public
    constructor Create(x, y, cx, cy: Integer; hParent: TXWidget); reintroduce; overload;
    destructor Destroy; override;

    procedure SetRange(iMax: Integer);
    function GetRange: Integer;
    procedure SetButtonSize(nWidth, nHeight: Integer);
    procedure GetButtonSize(out nWidth: Integer; out nHeight: Integer);

    property Pos: Integer read GetPos write SetPos;
    property RangeMax: Integer read GetRangeMax write SetRangeMax;
    property ButtonWidth: Integer read GetButtonWidth write SetButtonWidth;
    property ButtonHeight: Integer read GetButtonHeight write SetButtonHeight;
  end;

implementation

{ TXSliderBar }

constructor TXSliderBar.Create(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  inherited Create(x, y, cx, cy, hParent);
end;

procedure TXSliderBar.CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  Handle := XSliderBar_Create(x, y, cx, cy, hParent.Handle);
  Init;
end;

destructor TXSliderBar.Destroy;
begin
  inherited;
end;

procedure TXSliderBar.SetRange(iMax: Integer);
begin
  XSliderBar_SetRange(Handle, iMax);
end;

function TXSliderBar.GetRange: Integer;
begin
  Result := XSliderBar_GetRange(Handle);
end;

procedure TXSliderBar.SetPos(iPos: Integer);
begin
  XSliderBar_SetPos(Handle, iPos);
end;

function TXSliderBar.GetPos: Integer;
begin
  Result := XSliderBar_GetPos(Handle);
end;

procedure TXSliderBar.SetButtonSize(nWidth, nHeight: Integer);
begin
  XSliderBar_SetButtonWidth(Handle, nWidth);
  XSliderBar_SetButtonHeight(Handle, nHeight);
end;

procedure TXSliderBar.GetButtonSize(out nWidth: Integer; out nHeight: Integer);
var
  hButton: HELE;
begin
  hButton := XSliderBar_GetButton(Handle);
  if hButton <> 0 then
  begin
    nWidth := XEle_GetWidth(hButton);
    nHeight := XEle_GetHeight(hButton);
  end else
  begin
    nWidth := 0;
    nHeight := 0;
  end;
end;

function TXSliderBar.GetRangeMax: Integer;
begin
  Result := GetRange;
end;

procedure TXSliderBar.SetRangeMax(Value: Integer);
begin
  SetRange(Value);
end;

function TXSliderBar.GetButtonWidth: Integer;
var
  nWidth, nHeight: Integer;
begin
  GetButtonSize(nWidth, nHeight);
  Result := nWidth;
end;

procedure TXSliderBar.SetButtonWidth(Value: Integer);
begin
  XSliderBar_SetButtonWidth(Handle, Value);
end;

function TXSliderBar.GetButtonHeight: Integer;
var
  nWidth, nHeight: Integer;
begin
  GetButtonSize(nWidth, nHeight);
  Result := nHeight;
end;

procedure TXSliderBar.SetButtonHeight(Value: Integer);
begin
  XSliderBar_SetButtonHeight(Handle, Value);
end;

end. 