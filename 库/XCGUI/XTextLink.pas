unit XTextLink;

interface

uses
  Windows, SysUtils, XCGUI, XBUTTON, XWidget;

type
  TXTextLink = class(TXBtn)
  private
    FTextColorStay: Integer;
    FUnderlineColorLeave: Integer;
    FUnderlineColorStay: Integer;
    FEnableUnderlineLeave: Boolean;
    FEnableUnderlineStay: Boolean;
    procedure SetTextColorStay(const Value: Integer);
    procedure SetUnderlineColorLeave(const Value: Integer);
    procedure SetUnderlineColorStay(const Value: Integer);
    procedure SetEnableUnderlineLeave(const Value: Boolean);
    procedure SetEnableUnderlineStay(const Value: Boolean);
  protected
    procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); override;
    procedure Init; override;
  public
    constructor Create(x: Integer; y: Integer; cx: Integer; cy: Integer; hParent: TXWidget); overload;
    constructor Create(x: Integer; y: Integer; cx: Integer; cy: Integer; const Name: string; hParent: TXWidget); overload;

    // 属性
    property TextColorStay: Integer read FTextColorStay write SetTextColorStay;
    property UnderlineColorLeave: Integer read FUnderlineColorLeave write SetUnderlineColorLeave;
    property UnderlineColorStay: Integer read FUnderlineColorStay write SetUnderlineColorStay;
    property EnableUnderlineLeave: Boolean read FEnableUnderlineLeave write SetEnableUnderlineLeave;
    property EnableUnderlineStay: Boolean read FEnableUnderlineStay write SetEnableUnderlineStay;
  end;

implementation

{ TXTextLink }

constructor TXTextLink.Create(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  inherited Create(x, y, cx, cy, hParent);
end;

constructor TXTextLink.Create(x, y, cx, cy: Integer; const Name: string; hParent: TXWidget);
begin
  inherited Create;
  Handle := XTextLink_Create(x, y, cx, cy, PWideChar(Name), hParent.Handle);
  Init;
end;

procedure TXTextLink.CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  Handle := XTextLink_Create(x, y, cx, cy, nil, hParent.Handle);
end;


procedure TXTextLink.Init;
begin
  inherited;
end;

procedure TXTextLink.SetEnableUnderlineLeave(const Value: Boolean);
begin
  XTextLink_EnableUnderlineLeave(Handle, Value);
end;

procedure TXTextLink.SetEnableUnderlineStay(const Value: Boolean);
begin
  XTextLink_EnableUnderlineStay(Handle, Value);
end;

procedure TXTextLink.SetTextColorStay(const Value: Integer);
begin
  XTextLink_SetTextColorStay(Handle, Value);
end;

procedure TXTextLink.SetUnderlineColorLeave(const Value: Integer);
begin
  if FUnderlineColorLeave <> Value then
  begin
    FUnderlineColorLeave := Value;
    if IsHELE then
      XTextLink_SetUnderlineColorLeave(Handle, Value);
  end;
end;

procedure TXTextLink.SetUnderlineColorStay(const Value: Integer);
begin
  XTextLink_SetUnderlineColorStay(Handle, Value);
end;

end.

