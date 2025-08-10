unit XBUTTON;

interface

uses
  Windows, Classes, XCGUI, XElement, XWidget;

type
  TXBtn = class(TXEle)
  private
    FText: string;
    function GetText: string;
  protected
    procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); override;
  public
    constructor Create(x, y, cx, cy: Integer; const pName: string; hParent: TXWidget); reintroduce; overload;
    destructor Destroy; override;
    procedure SetText(const Value: string);
    function GetCheck: Boolean;
    procedure SetCheck(const Value: Boolean);
    function GetGroupID: Integer;
    procedure SetGroupID(const Value: Integer);
    function GetBindEle: HELE;
    procedure SetBindEle(const Value: HELE);
    function GetTextAlign: Integer;
    procedure SetTextAlign(const Value: Integer);
    // 属性
    property Text: string read GetText write SetText;
    property Check: Boolean read GetCheck write SetCheck;
    property GroupID: Integer read GetGroupID write SetGroupID;
    property BindEle: HELE read GetBindEle write SetBindEle;
    property TextAlign: Integer read GetTextAlign write SetTextAlign;

    // 方法
    procedure EnableHotkeyPrefix(bEnable: Boolean);
    function GetState: common_state3_;
    function GetStateEx: button_state_;
    procedure SetState(nState: common_state3_);
    procedure SetTypeEx(nType: XC_OBJECT_TYPE_EX);
    procedure SetIconAlign(align: button_icon_align_);
    procedure SetOffset(x, y: Integer);
    procedure SetOffsetIcon(x, y: Integer);
    procedure SetIconSpace(size: Integer);
    procedure SetIcon(hImage: HIMAGE);
    procedure SetIconDisable(hImage: HIMAGE);
    function GetIcon(nType: Integer): HIMAGE;
    procedure AddAnimationFrame(hImage: HIMAGE; uElapse: UINT);
    procedure EnableAnimation(bEnable, bLoopPlay: Boolean);
  end;

implementation

constructor TXBtn.Create(x, y, cx, cy: Integer; const pName: string; hParent: TXWidget);
begin
  FText := pName;
  inherited Create(x, y, cx, cy, hParent);
end;

procedure TXBtn.CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  Handle := XBtn_Create(x, y, cx, cy, PChar(FText), hParent.Handle);
end;

destructor TXBtn.Destroy;
begin
  inherited;
end;

function TXBtn.GetText: string;
begin
  Result := XBtn_GetText(Handle);
end;

procedure TXBtn.SetText(const Value: string);
begin
  XBtn_SetText(Handle, PWideChar(Value));
end;

function TXBtn.GetCheck: Boolean;
begin
  Result := XBtn_IsCheck(Handle);
end;

procedure TXBtn.SetCheck(const Value: Boolean);
begin
  XBtn_SetCheck(Handle, Value);
end;

function TXBtn.GetGroupID: Integer;
begin
  Result := XBtn_GetGroupID(Handle);
end;

procedure TXBtn.SetGroupID(const Value: Integer);
begin
  XBtn_SetGroupID(Handle, Value);
end;

function TXBtn.GetBindEle: HELE;
begin
  Result := XBtn_GetBindEle(Handle);
end;

procedure TXBtn.SetBindEle(const Value: HELE);
begin
  XBtn_SetBindEle(Handle, Value);
end;

function TXBtn.GetTextAlign: Integer;
begin
  Result := XBtn_GetTextAlign(Handle);
end;

procedure TXBtn.SetTextAlign(const Value: Integer);
begin
  XBtn_SetTextAlign(Handle, Value);
end;

// 方法实现
procedure TXBtn.EnableHotkeyPrefix(bEnable: Boolean);
begin
  XBtn_EnableHotkeyPrefix(Handle, bEnable);
end;

function TXBtn.GetState: common_state3_;
begin
  Result := XBtn_GetState(Handle);
end;

function TXBtn.GetStateEx: button_state_;
begin
  Result := XBtn_GetStateEx(Handle);
end;

procedure TXBtn.SetState(nState: common_state3_);
begin
  XBtn_SetState(Handle, nState);
end;

procedure TXBtn.SetTypeEx(nType: XC_OBJECT_TYPE_EX);
begin
  XBtn_SetTypeEx(Handle, nType);
end;

procedure TXBtn.SetIconAlign(align: button_icon_align_);
begin
  XBtn_SetIconAlign(Handle, align);
end;

procedure TXBtn.SetOffset(x, y: Integer);
begin
  XBtn_SetOffset(Handle, x, y);
end;

procedure TXBtn.SetOffsetIcon(x, y: Integer);
begin
  XBtn_SetOffsetIcon(Handle, x, y);
end;

procedure TXBtn.SetIconSpace(size: Integer);
begin
  XBtn_SetIconSpace(Handle, size);
end;

procedure TXBtn.SetIcon(hImage: hImage);
begin
  XBtn_SetIcon(Handle, hImage);
end;

procedure TXBtn.SetIconDisable(hImage: hImage);
begin
  XBtn_SetIconDisable(Handle, hImage);
end;

function TXBtn.GetIcon(nType: Integer): hImage;
begin
  Result := XBtn_GetIcon(Handle, nType);
end;

procedure TXBtn.AddAnimationFrame(hImage: hImage; uElapse: UINT);
begin
  XBtn_AddAnimationFrame(Handle, hImage, uElapse);
end;

procedure TXBtn.EnableAnimation(bEnable, bLoopPlay: Boolean);
begin
  XBtn_EnableAnimation(Handle, bEnable, bLoopPlay);
end;

end.


