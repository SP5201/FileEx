{*******************************************************************************
  网络速度监控单元
  功能：实时监控系统网络接口的下载和上传速度
  
  主要功能：
  - 监控以太网和WiFi接口的网络流量
  - 计算实时下载和上传速度（字节/秒）
  - 支持多网络接口聚合统计
  - 后台线程监控，不阻塞主线程
  - 可配置监控间隔时间
  - 线程安全的速度数据访问

  监控接口：
  - 以太网接口 (MIB_IF_TYPE_ETHERNET)
  - WiFi接口 (MIB_IF_TYPE_IEEE80211)
  - 自动过滤无效MAC地址的接口

  使用Windows API：IpHlpApi, IpRtrMib

  Copyright (c) 2025 zotptptp
  Email: zoutp@qq.com
  All rights reserved.
*******************************************************************************}

unit NetworkSpeedMonitor;

interface

uses
  Windows, SysUtils, Classes, SyncObjs, IpHlpApi, IpTypes, IpRtrMib;

const
  MIB_IF_TYPE_ETHERNET = 6;
  MIB_IF_TYPE_IEEE80211 = 71;

  IF_MAX_STRING_SIZE = 256;
  IF_MAX_PHYS_ADDRESS_LENGTH = 32;
  ANY_SIZE = 1;

type
  NET_LUID = record
    Value: UInt64;
  end;

  MIB_IF_ROW2 = record
    InterfaceLuid: NET_LUID;
    InterfaceIndex: LongWord;
    InterfaceGuid: TGuid;
    Alias: array[0..IF_MAX_STRING_SIZE] of WideChar;
    Description: array[0..IF_MAX_STRING_SIZE] of WideChar;
    PhysicalAddressLength: LongWord;
    PhysicalAddress: array[0..IF_MAX_PHYS_ADDRESS_LENGTH - 1] of Byte;
    PermanentPhysicalAddress: array[0..IF_MAX_PHYS_ADDRESS_LENGTH - 1] of Byte;
    Mtu: LongWord;
    IfType: LongWord; // IFTYPE
    TunnelType: Integer; // TUNNEL_TYPE
    MediaType: Integer; // NDIS_MEDIUM
    PhysicalMediumType: Integer; // NDIS_PHYSICAL_MEDIUM
    AccessType: Integer; // NET_IF_ACCESS_TYPE
    DirectionType: Integer; // NET_IF_DIRECTION_TYPE
    InterfaceAndOperStatusFlags: record
      Flags: Byte;
    end;
    OperStatus: Integer; // IF_OPER_STATUS
    AdminStatus: Integer; // NET_IF_ADMIN_STATUS
    MediaConnectState: Integer; // NET_IF_MEDIA_CONNECT_STATE
    NetworkGuid: TGuid;
    ConnectionType: Integer; // NET_IF_CONNECTION_TYPE
    TransmitLinkSpeed: UInt64;
    ReceiveLinkSpeed: UInt64;
    InOctets: UInt64;
    InUcastPkts: UInt64;
    InNUcastPkts: UInt64;
    InDiscards: UInt64;
    InErrors: UInt64;
    InUnknownProtos: UInt64;
    InUcastOctets: UInt64;
    InMulticastOctets: UInt64;
    InBroadcastOctets: UInt64;
    OutOctets: UInt64;
    OutUcastPkts: UInt64;
    OutNUcastPkts: UInt64;
    OutDiscards: UInt64;
    OutErrors: UInt64;
    OutUcastOctets: UInt64;
    OutMulticastOctets: UInt64;
    OutBroadcastOctets: UInt64;
    OutQLen: UInt64;
  end;
  PMIB_IF_ROW2 = ^MIB_IF_ROW2;

  MIB_IF_TABLE2 = record
    NumEntries: LongWord;
    Table: array[0..ANY_SIZE-1] of MIB_IF_ROW2;
  end;
  PMIB_IF_TABLE2 = ^MIB_IF_TABLE2;

  // 网络接口类型
  TNetworkInterfaceType = (nitEthernet, nitWifi, nitOther);
  
  // 网络接口信息
  TNetworkInterfaceInfo = record
    Index: DWORD;              // 接口索引
    Name: string;              // 接口名称
    Description: string;       // 接口描述
    InterfaceType: TNetworkInterfaceType; // 接口类型
    MacAddress: string;        // MAC地址
    BytesReceived: UInt64;      // 接收字节数
    BytesSent: UInt64;          // 发送字节数
    PreviousBytesReceived: UInt64; // 上次接收字节数
    PreviousBytesSent: UInt64;  // 上次发送字节数
    DownloadSpeed: UInt64;      // 下载速度 (bytes/s)
    UploadSpeed: UInt64;        // 上传速度 (bytes/s)
  end;
  PNetworkInterfaceInfo = ^TNetworkInterfaceInfo;

  // 网络速度更新事件
  TSpeedUpdatedEvent = procedure(DownloadSpeed, UploadSpeed: UInt64) of object;

  // 网络速度监控类
  TNetworkSpeedMonitor = class(TComponent)
  private
    FInterfaces: TList;        // 网络接口列表
    FMonitorThread: TThread;   // 监控线程
    FUpdateInterval: Integer;  // 更新间隔(毫秒)
    FLock: TCriticalSection;   // 线程同步锁
    FStopEvent: TEvent;        // 线程停止事件
    FTotalDownloadSpeed: UInt64; // 总下载速度
    FTotalUploadSpeed: UInt64;  // 总上传速度
    FOnSpeedUpdated: TSpeedUpdatedEvent; // 速度更新事件
    FActive: Boolean;          // 监控是否激活
    
    procedure SetUpdateInterval(const Value: Integer);
    procedure SetActive(const Value: Boolean);
    function GetTotalDownloadSpeed: UInt64;
    function GetTotalUploadSpeed: UInt64;
    
    procedure UpdateNetworkInterfaces;
    procedure UpdateNetworkSpeeds;
    procedure DoSpeedUpdated;
    
  protected
    procedure Loaded; override;
    
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    
    procedure Start;
    procedure Stop;
    
    // 获取格式化的速度字符串 (如: 1.2 MB/s)
    function GetFormattedDownloadSpeed: string;
    function GetFormattedUploadSpeed: string;
    
    property TotalDownloadSpeed: UInt64 read GetTotalDownloadSpeed;
    property TotalUploadSpeed: UInt64 read GetTotalUploadSpeed;
    
  published
    property UpdateInterval: Integer read FUpdateInterval write SetUpdateInterval default 1000;
    property Active: Boolean read FActive write SetActive default False;
    property OnSpeedUpdated: TSpeedUpdatedEvent read FOnSpeedUpdated write FOnSpeedUpdated;
  end;

implementation

uses
  FormatHelpers;

function GetIfTable2(var Table: PMIB_IF_TABLE2): DWord; stdcall; external 'iphlpapi.dll' name 'GetIfTable2';
procedure FreeMibTable(Table: Pointer); stdcall; external 'iphlpapi.dll' name 'FreeMibTable';


{ TNetworkMonitorThread }
type
  TNetworkMonitorThread = class(TThread)
  private
    FMonitor: TNetworkSpeedMonitor;
  protected
    procedure Execute; override;
  public
    constructor Create(AMonitor: TNetworkSpeedMonitor);
  end;

{ TNetworkMonitorThread }

constructor TNetworkMonitorThread.Create(AMonitor: TNetworkSpeedMonitor);
begin
  FMonitor := AMonitor;
  FreeOnTerminate := False;
  inherited Create(False);
end;

procedure TNetworkMonitorThread.Execute;
begin
  while not Terminated do
  begin
    // 更新网络接口列表
    FMonitor.UpdateNetworkInterfaces;
    
    // 更新网络速度
    FMonitor.UpdateNetworkSpeeds;
    
    // 触发速度更新事件 - 必须在主线程中同步以安全更新UI
    FMonitor.DoSpeedUpdated;
    
    // 等待指定时间或停止事件
    FMonitor.FStopEvent.WaitFor(FMonitor.UpdateInterval);
  end;
end;

{ TNetworkSpeedMonitor }

constructor TNetworkSpeedMonitor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FInterfaces := TList.Create;
  FLock := TCriticalSection.Create;
  FStopEvent := TEvent.Create(nil, True, False, ''); // Manual-reset, non-signaled
  FUpdateInterval := 1000; // 默认1秒更新一次
  FActive := False;
  FTotalDownloadSpeed := 0;
  FTotalUploadSpeed := 0;
end;

destructor TNetworkSpeedMonitor.Destroy;
begin
  Stop;
  
  // 清理接口列表
  FLock.Enter;
  try
    while FInterfaces.Count > 0 do
    begin
      Dispose(PNetworkInterfaceInfo(FInterfaces[0]));
      FInterfaces.Delete(0);
    end;
    FInterfaces.Free;
  finally
    FLock.Leave;
  end;
  
  FLock.Free;
  FStopEvent.Free;
  inherited Destroy;
end;

procedure TNetworkSpeedMonitor.Loaded;
begin
  inherited Loaded;
  if FActive and not (csDesigning in ComponentState) then
    Start;
end;

procedure TNetworkSpeedMonitor.SetUpdateInterval(const Value: Integer);
begin
  if Value <> FUpdateInterval then
  begin
    FUpdateInterval := Value;
    if FUpdateInterval < 100 then
      FUpdateInterval := 100; // 最小100毫秒
  end;
end;

procedure TNetworkSpeedMonitor.SetActive(const Value: Boolean);
begin
  if Value <> FActive then
  begin
    FActive := Value;
    if FActive then
      Start
    else
      Stop;
  end;
end;

function TNetworkSpeedMonitor.GetTotalDownloadSpeed: UInt64;
begin
  FLock.Enter;
  try
    Result := FTotalDownloadSpeed;
  finally
    FLock.Leave;
  end;
end;

function TNetworkSpeedMonitor.GetTotalUploadSpeed: UInt64;
begin
  FLock.Enter;
  try
    Result := FTotalUploadSpeed;
  finally
    FLock.Leave;
  end;
end;

procedure TNetworkSpeedMonitor.Start;
begin
  if (FMonitorThread = nil) and not (csDesigning in ComponentState) then
  begin
    // 创建并启动监控线程
    FStopEvent.ResetEvent;
    FMonitorThread := TNetworkMonitorThread.Create(Self);
    FActive := True;
  end;
end;

procedure TNetworkSpeedMonitor.Stop;
begin
  if FMonitorThread <> nil then
  begin
    // 停止监控线程
    TThread(FMonitorThread).Terminate;
    FStopEvent.SetEvent; // 发送信号以唤醒等待中的线程
    FMonitorThread.WaitFor;
    FreeAndNil(FMonitorThread);
    FActive := False;
  end;
end;

function GetMacAddressStr(AdapterInfo: PMIB_IF_ROW2): string;
var
  I: Integer;
begin
  Result := '';
  if AdapterInfo.PhysicalAddressLength = 6 then
  begin
    for I := 0 to 5 do
    begin
      if I > 0 then
        Result := Result + '-';
      Result := Result + IntToHex(AdapterInfo.PhysicalAddress[I], 2);
    end;
  end;
end;

function IsValidMacAddress(const MacAddress: string): Boolean;
begin
  // 过滤无效MAC地址，如全0或全F
  Result := (MacAddress <> '') and
            (MacAddress <> '00-00-00-00-00-00') and
            (MacAddress <> 'FF-FF-FF-FF-FF-FF');
end;

procedure TNetworkSpeedMonitor.UpdateNetworkInterfaces;
var
  Table2: PMIB_IF_TABLE2;
  I, J: Integer;
  InterfaceInfo: PNetworkInterfaceInfo;
  Found: Boolean;
  InterfaceType: TNetworkInterfaceType;
  MacAddress: string;
begin
  Table2 := nil;
  // 使用GetIfTable2获取支持64位计数器的接口信息
  if GetIfTable2(Table2) = NO_ERROR then
  try
    FLock.Enter;
    try
      // 遍历所有接口
      for I := 0 to Integer(Table2.NumEntries) - 1 do
      begin
        // 确定接口类型
        case Table2.Table[I].IfType of
          MIB_IF_TYPE_ETHERNET: InterfaceType := nitEthernet;
          MIB_IF_TYPE_IEEE80211: InterfaceType := nitWifi;
          else InterfaceType := nitOther;
        end;

        // 获取MAC地址
        MacAddress := GetMacAddressStr(@Table2.Table[I]);

        // 只处理以太网和WiFi接口，且MAC地址有效
        if ((InterfaceType = nitEthernet) or (InterfaceType = nitWifi)) and
           IsValidMacAddress(MacAddress) then
        begin
          // 查找是否已存在该接口
          Found := False;
          for J := 0 to FInterfaces.Count - 1 do
          begin
            InterfaceInfo := PNetworkInterfaceInfo(FInterfaces[J]);
            if InterfaceInfo.Index = Table2.Table[I].InterfaceIndex then
            begin
              // 更新接口信息
              InterfaceInfo.PreviousBytesReceived := InterfaceInfo.BytesReceived;
              InterfaceInfo.PreviousBytesSent := InterfaceInfo.BytesSent;
              InterfaceInfo.BytesReceived := Table2.Table[I].InOctets;
              InterfaceInfo.BytesSent := Table2.Table[I].OutOctets;
              Found := True;
              Break;
            end;
          end;

          // 如果不存在，添加新接口
          if not Found then
          begin
            New(InterfaceInfo);
            InterfaceInfo.Index := Table2.Table[I].InterfaceIndex;
            InterfaceInfo.Name := Format('接口 %d', [Table2.Table[I].InterfaceIndex]);
            InterfaceInfo.Description := string(Table2.Table[I].Description);
            InterfaceInfo.InterfaceType := InterfaceType;
            InterfaceInfo.MacAddress := MacAddress;
            InterfaceInfo.BytesReceived := Table2.Table[I].InOctets;
            InterfaceInfo.BytesSent := Table2.Table[I].OutOctets;
            InterfaceInfo.PreviousBytesReceived := InterfaceInfo.BytesReceived;
            InterfaceInfo.PreviousBytesSent := InterfaceInfo.BytesSent;
            InterfaceInfo.DownloadSpeed := 0;
            InterfaceInfo.UploadSpeed := 0;
            FInterfaces.Add(InterfaceInfo);
          end;
        end;
      end;
    finally
      FLock.Leave;
    end;
  finally
    // 释放GetIfTable2分配的内存
    if Table2 <> nil then
      FreeMibTable(Table2);
  end;
end;

procedure TNetworkSpeedMonitor.UpdateNetworkSpeeds;
var
  I: Integer;
  InterfaceInfo: PNetworkInterfaceInfo;
  TotalDownload, TotalUpload: UInt64;
  TimeInterval: Double;
begin
  TimeInterval := FUpdateInterval / 1000; // 转换为秒
  if TimeInterval <= 0 then
    TimeInterval := 1;

  TotalDownload := 0;
  TotalUpload := 0;

  FLock.Enter;
  try
    // 计算每个接口的速度
    for I := 0 to FInterfaces.Count - 1 do
    begin
      InterfaceInfo := PNetworkInterfaceInfo(FInterfaces[I]);

      // 使用64位计数器，不再需要处理溢出
      // 只有在新计数大于等于旧计数时才计算速度，以避免接口重置等异常情况
      if InterfaceInfo.BytesReceived >= InterfaceInfo.PreviousBytesReceived then
        InterfaceInfo.DownloadSpeed := Round((InterfaceInfo.BytesReceived - InterfaceInfo.PreviousBytesReceived) / TimeInterval)
      else
        InterfaceInfo.DownloadSpeed := 0; // 计数器异常，本次速度计为0

      if InterfaceInfo.BytesSent >= InterfaceInfo.PreviousBytesSent then
        InterfaceInfo.UploadSpeed := Round((InterfaceInfo.BytesSent - InterfaceInfo.PreviousBytesSent) / TimeInterval)
      else
        InterfaceInfo.UploadSpeed := 0; // 计数器异常，本次速度计为0

      // 累加总速度
      TotalDownload := TotalDownload + InterfaceInfo.DownloadSpeed;
      TotalUpload := TotalUpload + InterfaceInfo.UploadSpeed;
    end;

    // 更新总速度
    FTotalDownloadSpeed := TotalDownload;
    FTotalUploadSpeed := TotalUpload;
  finally
    FLock.Leave;
  end;
end;

procedure TNetworkSpeedMonitor.DoSpeedUpdated;
begin
  if Assigned(FOnSpeedUpdated) then
    FOnSpeedUpdated(FTotalDownloadSpeed, FTotalUploadSpeed);
end;

function TNetworkSpeedMonitor.GetFormattedDownloadSpeed: string;
begin
  Result := FormatByteSize(GetTotalDownloadSpeed) + '/s';
end;

function TNetworkSpeedMonitor.GetFormattedUploadSpeed: string;
begin
  Result := FormatByteSize(GetTotalUploadSpeed) + '/s';
end;

end.

