unit XScrollView;

interface

uses
  Windows, Messages, XCGUI, XElement, XWidget;

type
  TXSView = class(TXEle)
  private
  protected
    procedure CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget); override;
  public
    constructor Create(x: Integer = 0; y: Integer = 0; cx: Integer = 0; cy: Integer = 0; hParent: TXWidget = nil);
    destructor Destroy; override;
    function GetPosH: Integer;
    function GetPosV: Integer;
    function GetWidth: Integer;
    function GetHeight: Integer;
    procedure SetTotalSize(const cx, cy: Integer);
    procedure GetTotalSize(out pSize: SIZE);
    procedure SetLineSize(const nWidth, nHeight: Integer);
    procedure GetLineSize(out pSize: SIZE);
    procedure SetScrollBarSize(const size: Integer);
    procedure GetRect(out pRect: TRect);
    function GetScrollBarH: HELE;
    function GetScrollBarV: HELE;
    procedure ShowSBarH(const bShow: BOOL);
    procedure ShowSBarV(const bShow: BOOL);
    procedure EnableAutoShowScrollBar(const bEnable: BOOL);

    property PosH: Integer read GetPosH; // �ӿ�ԭ��X����
    property PosV: Integer read GetPosV; // �ӿ�ԭ��Y����
    property Width: Integer read GetWidth; // �ӿڿ���
    property Height: Integer read GetHeight; // �ӿڸ߶�


    property ScrollBarH: HELE read GetScrollBarH; // ˮƽ������
    property ScrollBarV: HELE read GetScrollBarV; // ��ֱ������


    function ScrollPosH(const pos: Integer): BOOL;
    function ScrollPosV(const pos: Integer): BOOL;
    function ScrollPosXH(const posX: Integer): BOOL;
    function ScrollPosYV(const posY: Integer): BOOL;
    function ScrollLeftLine: BOOL;
    function ScrollRightLine: BOOL;
    function ScrollTopLine: BOOL;
    function ScrollBottomLine: BOOL;
    function ScrollLeft: BOOL;
    function ScrollRight: BOOL;
    function ScrollTop: BOOL;
    function ScrollBottom: BOOL;
  end;

implementation

constructor TXSView.Create(x, y, cx, cy: Integer; hParent: TXWidget);
begin
 inherited Create(x, y, cx, cy,hParent);
end;

procedure TXSView.CreateHandle(x, y, cx, cy: Integer; hParent: TXWidget);
begin
  Handle := XSView_Create(x, y, cx, cy, hParent.Handle);
end;

destructor TXSView.Destroy;
begin
  inherited;
end;

function TXSView.GetPosH: Integer;
begin
  Result := XSView_GetViewPosH(Handle);
end;

function TXSView.GetPosV: Integer;
begin
  Result := XSView_GetViewPosV(Handle);
end;

function TXSView.GetWidth: Integer;
begin
  Result := XSView_GetViewWidth(Handle);
end;

function TXSView.GetHeight: Integer;
begin
  Result := XSView_GetViewHeight(Handle);
end;

procedure TXSView.SetTotalSize(const cx, cy: Integer);
begin
  XSView_SetTotalSize(Handle, cx, cy);
end;

procedure TXSView.GetTotalSize(out pSize: SIZE);
begin
  XSView_GetTotalSize(Handle, pSize);
end;

procedure TXSView.SetLineSize(const nWidth, nHeight: Integer);
begin
  XSView_SetLineSize(Handle, nWidth, nHeight);
end;

procedure TXSView.GetLineSize(out pSize: SIZE);
begin
  XSView_GetLineSize(Handle, pSize);
end;

procedure TXSView.SetScrollBarSize(const size: Integer);
begin
  XSView_SetScrollBarSize(Handle, size);
end;

procedure TXSView.GetRect(out pRect: TRect);
begin
  XSView_GetViewRect(Handle, pRect);
end;

function TXSView.GetScrollBarH: HELE;
begin
  Result := XSView_GetScrollBarH(Handle);
end;

function TXSView.GetScrollBarV: HELE;
begin
  Result := XSView_GetScrollBarV(Handle);
end;

procedure TXSView.ShowSBarH(const bShow: BOOL);
begin
  XSView_ShowSBarH(Handle, bShow);
end;

procedure TXSView.ShowSBarV(const bShow: BOOL);
begin
  XSView_ShowSBarV(Handle, bShow);
end;

procedure TXSView.EnableAutoShowScrollBar(const bEnable: BOOL);
begin
  XSView_EnableAutoShowScrollBar(Handle, bEnable);
end;

function TXSView.ScrollPosH(const pos: Integer): BOOL;
begin
  Result := XSView_ScrollPosH(Handle, pos);
end;

function TXSView.ScrollPosV(const pos: Integer): BOOL;
begin
  Result := XSView_ScrollPosV(Handle, pos);
end;

function TXSView.ScrollPosXH(const posX: Integer): BOOL;
begin
  Result := XSView_ScrollPosXH(Handle, posX);
end;

function TXSView.ScrollPosYV(const posY: Integer): BOOL;
begin
  Result := XSView_ScrollPosYV(Handle, posY);
end;

function TXSView.ScrollLeftLine: BOOL;
begin
  Result := XSView_ScrollLeftLine(Handle);
end;

function TXSView.ScrollRightLine: BOOL;
begin
  Result := XSView_ScrollRightLine(Handle);
end;

function TXSView.ScrollTopLine: BOOL;
begin
  Result := XSView_ScrollTopLine(Handle);
end;

function TXSView.ScrollBottomLine: BOOL;
begin
  Result := XSView_ScrollBottomLine(Handle);
end;

function TXSView.ScrollLeft: BOOL;
begin
  Result := XSView_ScrollLeft(Handle);
end;

function TXSView.ScrollRight: BOOL;
begin
  Result := XSView_ScrollRight(Handle);
end;

function TXSView.ScrollTop: BOOL;
begin
  Result := XSView_ScrollTop(Handle);
end;

function TXSView.ScrollBottom: BOOL;
begin
  Result := XSView_ScrollBottom(Handle);
end;

end.

