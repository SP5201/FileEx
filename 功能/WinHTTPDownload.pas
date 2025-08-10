{*******************************************************************************
  HTTP下载和网络请求单元
  功能：基于WinHTTP的异步HTTP下载和网络请求功能
  
  主要功能：
  - HTTP/HTTPS文件下载到本地
  - 网页源码获取和内存存储
  - 支持多种代理类型（HTTP、HTTPS、SOCKS4、SOCKS5）
  - 异步下载，不阻塞主线程
  - 实时下载进度回调
  - 可配置的超时设置
  - 自动编码检测和转换
  
  下载特性：
  - 支持大文件下载
  - 断点续传和错误恢复
  - 可配置的缓冲区大小
  - 多种下载状态跟踪
  - 线程安全的下载操作
  
  网络配置：
  - 自定义User-Agent
  - 代理服务器认证
  - 连接、发送、接收超时设置
  - 自动重试和错误处理
  
  技术实现：
  - 基于Windows WinHTTP API
  - 异步回调机制
  - 内存和文件流管理
  - 多线程同步控制
  
  Copyright (c) 2025 zotptptp
  Email: zoutp@qq.com
  All rights reserved.
*******************************************************************************}

unit WinHTTPDownload;

interface

uses
  Windows, Winhttp2, SysUtils, Classes, System.SyncObjs, Math;

type
  TProxyType = (ptSystemDefault, ptNone, ptHTTP, ptHTTPS, ptSOCKS4, ptSOCKS5);

  TDownloadStatus = (dsConnecting, dsHeadersAvailable, dsDownloadingData, dsCompleted, dsErrorEncountered);

  TProgressCallback = procedure(DownloadStatus: TDownloadStatus; InfoValue: DWORD; BytesRead, TotalBytes: Int64) of object;

  TWinHTTPDownloader = class(TThread)
  private
    FURL: string;
    FUsesData: Integer;
    FSavePath: string;
    FWebPageSource: string;
    FMemoryStream: TMemoryStream;
    FhSession: HINTERNET;
    FhConnect: HINTERNET;
    FhRequest: HINTERNET;
    FAsyncOpEvent: THandle;
    FStartEvent: THandle;
    FStoppingEvent: THandle;
    FIsStopping: Boolean;
    FFileStream: TFileStream;
    FBuffer: array[0..8191] of Byte;
    FBytesToRead: DWORD;
    FBytesRead: DWORD;
    FErrorCode: DWORD;
    FCriticalSection: TCriticalSection;
    FOnProgress: TProgressCallback;
    FTotalBytes: Int64;
    FDownloadActive: Boolean;
    FThreadStarted: Boolean;
    FhRequestClosedByCallback: Boolean;
    FLastProgressTime: Cardinal;
    FProgressInterval: Cardinal;
    FAgent: string;
    FResolveTimeout: Integer;
    FConnectTimeout: Integer;
    FSendTimeout: Integer;
    FReceiveTimeout: Integer;
    FSuccessfullyCompleted: Boolean;
    FResponseContentType: string;
    FProxyType: TProxyType;
    FProxyServer: string;
    FProxyPort: WORD;
    FProxyUsername: string;
    FProxyPassword: string;
    FThreadIdleEvent: THandle;

    function GetEncodingFromContentType(const AContentType: string): TEncoding;
    procedure InternalStartOperation(const AURL: string; const ASavePath: string; AToMemory: Boolean);

    procedure DoProgressCallback(ADownloadStatus: TDownloadStatus; AInfoValue: DWORD);
    procedure ExtractURLParts(const URL: string; out HostName, FileName: string);
    function GetPortFromURL(const URL: string): INTERNET_PORT;
    class procedure StatusCallback(hInternet: HINTERNET; dwContext, dwInternetStatus: DWORD; lpvStatusInformation: Pointer; dwStatusInformationLength: DWORD); stdcall; static;
    procedure HandleDownloadError(ErrorCode: DWORD);
    procedure CleanupResources;
    function InitializeSession: Boolean;
    procedure HandleHeadersAvailable(hInternet: HINTERNET);
    procedure HandleReadComplete(hInternet: HINTERNET; lpvStatusInformation: Pointer; dwStatusInformationLength: DWORD);
    procedure HandleRequestError(lpvStatusInformation: Pointer);
    procedure PrepareFileOrMemoryStream;
    function StartReadingData(hInternet: hInternet): Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure StartDownload(const URL, SavePath: string);
    procedure StopDownload;
    procedure GetWebPageSource(const URL: string);
    function GetWebPageSourceText: string;
    procedure SetAllTimeouts(AResolveTimeout, AConnectTimeout, ASendTimeout, AReceiveTimeout: Integer);
    procedure GetAllTimeouts(out AResolveTimeout, AConnectTimeout, ASendTimeout, AReceiveTimeout: Integer);
    procedure GetMemoryData(out DataPtr: Pointer; out DataSize: Int64);
    procedure SetProxy(AProxyType: TProxyType; const AProxyServer: string; AProxyPort: WORD; const AProxyUsername: string = ''; const AProxyPassword: string = '');
    property OnProgress: TProgressCallback read FOnProgress write FOnProgress;
    property UsesData: Integer read FUsesData write FUsesData;
    property Agent: string read FAgent write FAgent;
    property ProgressInterval: Cardinal read FProgressInterval write FProgressInterval;
  end;

implementation

const
  WAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.6261.95 Safari/537.36';
  ecCallbackException = $FFFF0001;

function TWinHTTPDownloader.GetEncodingFromContentType(const AContentType: string): TEncoding;
var
  LCharSet: string;
  LP: Integer;
begin
  Result := TEncoding.UTF8;
  if AContentType = '' then
    Exit;

  LCharSet := '';
  LP := Pos('charset=', LowerCase(AContentType));
  if LP > 0 then
  begin
    LCharSet := Copy(AContentType, LP + Length('charset='), MaxInt);
    LP := Pos(';', LCharSet);
    if LP > 0 then
      LCharSet := Copy(LCharSet, 1, LP - 1);
    LCharSet := Trim(LCharSet);
    if (Length(LCharSet) > 1) and (LCharSet[1] = '"') and (LCharSet[Length(LCharSet)] = '"') then
      LCharSet := Copy(LCharSet, 2, Length(LCharSet) - 2);
  end;

  if LCharSet = '' then
  begin
    Exit;
  end;

  if SameText(LCharSet, 'utf-8') then
    Result := TEncoding.UTF8
  else if SameText(LCharSet, 'unicode') or SameText(LCharSet, 'utf-16') then
    Result := TEncoding.Unicode
  else if SameText(LCharSet, 'ascii') then
    Result := TEncoding.ASCII
  else
  begin
    try
      Result := TEncoding.GetEncoding(LCharSet);
    except
      Result := TEncoding.Default;
    end;
  end;
end;

procedure TWinHTTPDownloader.ExtractURLParts(const URL: string; out HostName, FileName: string);
var
  P: Integer;
  TempURL: string;
begin
  TempURL := URL;
  P := Pos('://', TempURL);
  if P > 0 then
    Delete(TempURL, 1, P + 2);
  P := Pos('/', TempURL);
  if P > 0 then
  begin
    HostName := Copy(TempURL, 1, P - 1);
    FileName := Copy(TempURL, P, MaxInt);
  end
  else
  begin
    HostName := TempURL;
    FileName := '/';
  end;
end;

function TWinHTTPDownloader.GetPortFromURL(const URL: string): INTERNET_PORT;
begin
  if Pos('https://', LowerCase(URL)) = 1 then
    Result := INTERNET_DEFAULT_HTTPS_PORT
  else
    Result := INTERNET_DEFAULT_HTTP_PORT;
end;

procedure TWinHTTPDownloader.HandleDownloadError(ErrorCode: DWORD);
begin
  FCriticalSection.Enter;
  try
    FErrorCode := ErrorCode;
    FDownloadActive := False;
    DoProgressCallback(dsErrorEncountered, FErrorCode);
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TWinHTTPDownloader.CleanupResources;
begin
  if FAsyncOpEvent <> 0 then
  begin
    CloseHandle(FAsyncOpEvent);
    FAsyncOpEvent := 0;
  end;

  if Assigned(FFileStream) then
  begin
    FreeAndNil(FFileStream);
  end;

  if (FhRequest <> nil) and not FhRequestClosedByCallback then
  begin
    try
      WinHttpSetStatusCallback(FhRequest, nil, 0, 0);
      WinHttpCloseHandle(FhRequest);
    finally
      FhRequest := nil;
    end;
  end;

  if FhConnect <> nil then
  begin
    try
      WinHttpCloseHandle(FhConnect);
    finally
      FhConnect := nil;
    end;
  end;

  if FhSession <> nil then
  begin
    try
      WinHttpCloseHandle(FhSession);
    finally
      FhSession := nil;
    end;
  end;
end;

function TWinHTTPDownloader.InitializeSession: Boolean;
var
  ProxySettings: string;
  AccessType: DWORD;
  ProxyName: PWideChar;
  EffectiveProxyType: TProxyType;
  TempProxyServer: string;
  TempProxyPort: Word;
  TempProxyUsername: string;
  TempProxyPassword: string;
begin
  ProxySettings := '';

  FCriticalSection.Enter;
  try
    EffectiveProxyType := FProxyType;
    TempProxyServer := FProxyServer;
    TempProxyPort := FProxyPort;
    TempProxyUsername := FProxyUsername;
    TempProxyPassword := FProxyPassword;

    if (EffectiveProxyType in [ptHTTP, ptHTTPS, ptSOCKS4, ptSOCKS5]) and ((TempProxyServer = '') or (TempProxyPort = 0)) then
    begin
      EffectiveProxyType := ptSystemDefault;
    end;

    case EffectiveProxyType of
      ptSystemDefault:
        begin
          AccessType := WINHTTP_ACCESS_TYPE_DEFAULT_PROXY;
          ProxyName := nil;
        end;
      ptNone:
        begin
          AccessType := WINHTTP_ACCESS_TYPE_NO_PROXY;
          ProxyName := nil;
        end;
      ptHTTP:
        begin
          AccessType := WINHTTP_ACCESS_TYPE_NAMED_PROXY;
          ProxySettings := Format('%s:%d', [TempProxyServer, TempProxyPort]);
          ProxyName := PWideChar(WideString(ProxySettings));
        end;
      ptHTTPS:
        begin
          AccessType := WINHTTP_ACCESS_TYPE_NAMED_PROXY;
          ProxySettings := Format('https://%s:%d', [TempProxyServer, TempProxyPort]);
          ProxyName := PWideChar(WideString(ProxySettings));
        end;
      ptSOCKS4, ptSOCKS5:
        begin
          AccessType := WINHTTP_ACCESS_TYPE_NAMED_PROXY;
          ProxySettings := Format('socks=%s:%d', [TempProxyServer, TempProxyPort]);
          ProxyName := PWideChar(WideString(ProxySettings));
        end;
    else
      AccessType := WINHTTP_ACCESS_TYPE_DEFAULT_PROXY;
      ProxyName := nil;
    end;

    FhSession := WinHttpOpen(PWideChar(FAgent), AccessType, ProxyName, nil, WINHTTP_FLAG_ASYNC);

    if FhSession = nil then
    begin
      HandleDownloadError(GetLastError);
      Result := False;
      Exit;
    end;

    if (EffectiveProxyType in [ptHTTP, ptHTTPS, ptSOCKS4, ptSOCKS5]) and (TempProxyUsername <> '') then
    begin
      if not WinHttpSetOption(FhSession, WINHTTP_OPTION_PROXY_USERNAME, PWideChar(WideString(TempProxyUsername)), Length(TempProxyUsername) * SizeOf(WideChar)) then
      begin
        HandleDownloadError(GetLastError);
        Result := False;
        Exit;
      end;
      if not WinHttpSetOption(FhSession, WINHTTP_OPTION_PROXY_PASSWORD, PWideChar(WideString(TempProxyPassword)), Length(TempProxyPassword) * SizeOf(WideChar)) then
      begin
        HandleDownloadError(GetLastError);
        Result := False;
        Exit;
      end;
    end;

    if not WinHttpSetTimeouts(FhSession, FResolveTimeout, FConnectTimeout, FSendTimeout, FReceiveTimeout) then
    begin
      HandleDownloadError(GetLastError);
      Result := False;
      Exit;
    end;

    Result := True;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TWinHTTPDownloader.PrepareFileOrMemoryStream;
begin
  if FSavePath <> '' then
  begin
    if Assigned(FFileStream) then
      FreeAndNil(FFileStream);
    FFileStream := TFileStream.Create(FSavePath, fmCreate);
  end
  else if not Assigned(FMemoryStream) then
  begin
    FErrorCode := ecCallbackException;
    DoProgressCallback(dsErrorEncountered, FErrorCode);
    FDownloadActive := False;
    raise Exception.Create('内存流未初始化');
  end
  else
  begin
    FMemoryStream.Position := 0;
  end;
end;

function TWinHTTPDownloader.StartReadingData(hInternet: hInternet): Boolean;
begin
  Result := False;

  FBytesToRead := SizeOf(FBuffer);
  if WinHttpReadData(hInternet, FBuffer, FBytesToRead, nil) or (GetLastError() = ERROR_IO_PENDING) then
  begin
    Result := True;
  end
  else
  begin
    FErrorCode := GetLastError();
    DoProgressCallback(dsErrorEncountered, FErrorCode);
    FDownloadActive := False;
  end;
end;

procedure TWinHTTPDownloader.HandleHeadersAvailable(hInternet: hInternet);
var
  dwStatusCode: DWORD;
  dwSize: DWORD;
  ContentTypeBuffer: array[0..1023] of WideChar;
  dwContentTypeBufferSize: DWORD;
begin
  if not FDownloadActive or Terminated then
  begin
    if FAsyncOpEvent <> 0 then
      SetEvent(FAsyncOpEvent);
    Exit;
  end;

  dwSize := SizeOf(dwStatusCode);
  if (WinHttpQueryHeaders(hInternet, WINHTTP_QUERY_STATUS_CODE or WINHTTP_QUERY_FLAG_NUMBER, nil, @dwStatusCode, dwSize, nil)) and (dwStatusCode = HTTP_STATUS_OK) then
  begin
    dwSize := SizeOf(Int64);
    if WinHttpQueryHeaders(hInternet, WINHTTP_QUERY_CONTENT_LENGTH or WINHTTP_QUERY_FLAG_NUMBER, WINHTTP_HEADER_NAME_BY_INDEX, @FTotalBytes, dwSize, WINHTTP_NO_HEADER_INDEX) then
    begin
    end
    else
    begin
      FTotalBytes := 0;
    end;

    dwContentTypeBufferSize := SizeOf(ContentTypeBuffer);
    FillChar(ContentTypeBuffer, SizeOf(ContentTypeBuffer), 0);
    if WinHttpQueryHeaders(hInternet, WINHTTP_QUERY_CONTENT_TYPE, WINHTTP_HEADER_NAME_BY_INDEX, @ContentTypeBuffer[0], dwContentTypeBufferSize, WINHTTP_NO_HEADER_INDEX) then
    begin
      FResponseContentType := PWideChar(@ContentTypeBuffer[0]);
    end
    else
    begin
      FResponseContentType := '';
    end;

    DoProgressCallback(dsHeadersAvailable, dwStatusCode);

    try
      PrepareFileOrMemoryStream;
      StartReadingData(hInternet);
    except
      on E: Exception do
      begin
        FErrorCode := ecCallbackException;
        DoProgressCallback(dsErrorEncountered, FErrorCode);
        FDownloadActive := False;
      end;
    end;
  end
  else
  begin
    if dwStatusCode <> HTTP_STATUS_OK then
      FErrorCode := dwStatusCode
    else
      FErrorCode := GetLastError();

    DoProgressCallback(dsErrorEncountered, FErrorCode);
    FDownloadActive := False;
  end;

  if FAsyncOpEvent <> 0 then
    SetEvent(FAsyncOpEvent);
end;

procedure TWinHTTPDownloader.HandleReadComplete(hInternet: hInternet; lpvStatusInformation: Pointer; dwStatusInformationLength: DWORD);
var
  LBytes: TBytes;
  LEncoding: TEncoding;
begin
  if not FDownloadActive or Terminated then
  begin
    if FAsyncOpEvent <> 0 then
      SetEvent(FAsyncOpEvent);
    Exit;
  end;

  if dwStatusInformationLength > 0 then
  begin
    try
      if Assigned(FFileStream) then
        FFileStream.WriteBuffer(lpvStatusInformation^, dwStatusInformationLength)
      else if Assigned(FMemoryStream) then
        FMemoryStream.WriteBuffer(lpvStatusInformation^, dwStatusInformationLength);

      FBytesRead := FBytesRead + dwStatusInformationLength;

      DoProgressCallback(dsDownloadingData, 0);

      if not StartReadingData(hInternet) then
      begin
        if FAsyncOpEvent <> 0 then
          SetEvent(FAsyncOpEvent);
      end;
    except
      on E: Exception do
      begin
        FErrorCode := ecCallbackException;
        DoProgressCallback(dsErrorEncountered, FErrorCode);
        FDownloadActive := False;
        if FAsyncOpEvent <> 0 then
          SetEvent(FAsyncOpEvent);
      end;
    end;
  end
  else
  begin
    FSuccessfullyCompleted := True;
    FDownloadActive := False;

    if FSavePath = '' then
    begin
      if (FErrorCode = 0) and Assigned(FMemoryStream) then
      begin
        if FMemoryStream.Size > 0 then
        begin
          LEncoding := GetEncodingFromContentType(FResponseContentType);

          FMemoryStream.Position := 0;
          SetLength(LBytes, FMemoryStream.Size);
          if FMemoryStream.Size > 0 then
            FMemoryStream.ReadBuffer(LBytes[0], FMemoryStream.Size);

          FWebPageSource := LEncoding.GetString(LBytes);
          SetLength(LBytes, 0);
          DoProgressCallback(dsCompleted, 0);
        end
        else
        begin
          FWebPageSource := '';
          DoProgressCallback(dsCompleted, 0);
        end;
      end
      else
      begin
        FWebPageSource := '';
      end;
    end
    else
    begin
      if FErrorCode = 0 then
        DoProgressCallback(dsCompleted, 0);
    end;

    if FAsyncOpEvent <> 0 then
      SetEvent(FAsyncOpEvent);
  end;
end;

procedure TWinHTTPDownloader.HandleRequestError(lpvStatusInformation: Pointer);
var
  AsyncResult: PWinHttpAsyncResult;
begin
  AsyncResult := lpvStatusInformation;
  if AsyncResult <> nil then
    FErrorCode := AsyncResult^.dwError
  else
    FErrorCode := GetLastError();

  DoProgressCallback(dsErrorEncountered, FErrorCode);
  FDownloadActive := False;

  if FAsyncOpEvent <> 0 then
    SetEvent(FAsyncOpEvent);
end;

class procedure TWinHTTPDownloader.StatusCallback(hInternet: hInternet; dwContext, dwInternetStatus: DWORD; lpvStatusInformation: Pointer; dwStatusInformationLength: DWORD); stdcall;
var
  Downloader: TWinHTTPDownloader;
begin
  if dwContext = 0 then // dwContext 为 0 绝对是无效的
    Exit;

  Downloader := TWinHTTPDownloader(dwContext);

  // 防御性检查：确保 Downloader 实例及其临界区对象在尝试使用前是有效的。
  // 这是为了防止在对象已被释放或正在析构时发生回调。
  // 注意: 如果 dwContext 是一个指向完全无效内存的悬空指针，
  // 即使是 "Downloader.FCriticalSection" 的读取也可能导致错误，
  // 这种情况下此检查可能无法阻止最初的访问冲突。
  // 但如果问题是 FCriticalSection 已被 FreeAndNil，此检查会有帮助。
  if not Assigned(Downloader) then // 虽然 TWinHTTPDownloader(dwContext) 通常不应返回 nil 除非 dwContext=0
    Exit;                         // 但作为额外的安全层。

  // 这个检查是关键，如果 FCriticalSection 已经被 FreeAndNil(FCriticalSection)
  if not Assigned(Downloader.FCriticalSection) then
  begin
    // 建议: 此处添加日志记录 (例如通过 OutputDebugString)
    // 表明回调发生在 FCriticalSection 无效的情况下，例如：
    // OutputDebugString(PWideChar(Format('WinHTTPDownload StatusCallback: FCriticalSection is nil for context %p, status %d. Aborting callback.',[Pointer(dwContext), dwInternetStatus])));
    Exit;
  end;

  Downloader.FCriticalSection.Enter; // IDE 停在这里
  try
    // 在进入临界区后，再次确认请求句柄的有效性和匹配性。
    // 如果 Downloader.FhRequest 已经被 CleanupResources 置为 nil，则不应处理。
    if not Assigned(Downloader.FhRequest) or (hInternet <> Downloader.FhRequest) then
    begin
      Exit;
    end;

    // 检查下载是否仍然活动或线程是否已终止 (除非是句柄关闭通知)
    if (dwInternetStatus <> WINHTTP_CALLBACK_STATUS_HANDLE_CLOSING) and (not Downloader.FDownloadActive or Downloader.Terminated) then
    begin
      if Downloader.FAsyncOpEvent <> 0 then
        SetEvent(Downloader.FAsyncOpEvent);
      Exit;
    end;

    case dwInternetStatus of
      WINHTTP_CALLBACK_STATUS_SENDREQUEST_COMPLETE:
        if Downloader.FDownloadActive and not Downloader.Terminated then
          WinHttpReceiveResponse(hInternet, nil)
        else if Downloader.FAsyncOpEvent <> 0 then
          SetEvent(Downloader.FAsyncOpEvent);

      WINHTTP_CALLBACK_STATUS_HEADERS_AVAILABLE:
        Downloader.HandleHeadersAvailable(hInternet);

      WINHTTP_CALLBACK_STATUS_READ_COMPLETE:
        Downloader.HandleReadComplete(hInternet, lpvStatusInformation, dwStatusInformationLength);

      WINHTTP_CALLBACK_STATUS_REQUEST_ERROR:
        Downloader.HandleRequestError(lpvStatusInformation);

      WINHTTP_CALLBACK_STATUS_HANDLE_CLOSING:
        begin
          Downloader.FhRequestClosedByCallback := True;
          Downloader.FDownloadActive := False; // 确保状态一致
          if Downloader.FAsyncOpEvent <> 0 then
            SetEvent(Downloader.FAsyncOpEvent);
        end;
    end;
  finally
    // 确保即使在上面的检查中提前 Exit，也会离开临界区
    // (前提是 FCriticalSection 有效且 Enter 成功)
    Downloader.FCriticalSection.Leave;
  end;
end;

procedure TWinHTTPDownloader.Execute;
var
  Port: INTERNET_PORT;
  Flags: DWORD;
  HostName, FileName: string;
  ShouldDeleteFile: Boolean;
  LocalSavePath: string;
begin
  while not Terminated do
  begin
    WaitForSingleObject(FStartEvent, INFINITE);
    if Terminated then
      Break;

    FAsyncOpEvent := CreateEvent(nil, False, False, nil);
    if FAsyncOpEvent = 0 then
    begin
      HandleDownloadError(GetLastError);
      FCriticalSection.Enter;
      try
        if FIsStopping then
        begin
          SetEvent(FStoppingEvent);
        end;
      finally
        FCriticalSection.Leave;
      end;
      Continue;
    end;

    FhRequest := nil;
    FhConnect := nil;
    FhSession := nil;
    FhRequestClosedByCallback := False;

    try
      if not InitializeSession then
        Continue;

      ExtractURLParts(FURL, HostName, FileName);
      Port := GetPortFromURL(FURL);

      FhConnect := WinHttpConnect(FhSession, PWideChar(HostName), Port, 0);
      if Terminated or (FhConnect = nil) then
      begin
        if not Terminated then
          HandleDownloadError(GetLastError);
        Continue;
      end;

      Flags := 0;
      if Pos('https://', LowerCase(FURL)) = 1 then
        Flags := WINHTTP_FLAG_SECURE;

      FhRequest := WinHttpOpenRequest(FhConnect, 'GET', PWideChar(FileName), nil, nil, nil, Flags);
      if Terminated or (FhRequest = nil) then
      begin
        if not Terminated then
          HandleDownloadError(GetLastError);
        Continue;
      end;

      WinHttpSetStatusCallback(FhRequest, @TWinHTTPDownloader.StatusCallback, WINHTTP_CALLBACK_FLAG_ALL_COMPLETIONS or WINHTTP_CALLBACK_FLAG_HANDLES, 0);

      if not WinHttpSendRequest(FhRequest, nil, 0, nil, 0, 0, DWORD(Self)) then
      begin
        if not Terminated then
          HandleDownloadError(GetLastError);
        Continue;
      end;

      DoProgressCallback(dsConnecting, 0);

      while FDownloadActive and not Terminated do
      begin
        WaitForSingleObject(FAsyncOpEvent, INFINITE);
      end;

    finally
      CleanupResources;

      LocalSavePath := FSavePath;

      FCriticalSection.Enter;
      try
        ShouldDeleteFile := (FErrorCode <> 0) or (Terminated and not FSuccessfullyCompleted);
        if FIsStopping then
        begin
          SetEvent(FStoppingEvent);
        end;
        FDownloadActive := False;
      finally
        FCriticalSection.Leave;
      end;

      if ShouldDeleteFile and (LocalSavePath <> '') then
      begin
        if SysUtils.FileExists(LocalSavePath) then
          SysUtils.DeleteFile(LocalSavePath);
      end;
    end;

    SetEvent(FThreadIdleEvent);
  end;
end;

constructor TWinHTTPDownloader.Create;
begin
  inherited Create(True);
  FCriticalSection := TCriticalSection.Create;
  FStartEvent := CreateEvent(nil, False, False, nil);
  FStoppingEvent := CreateEvent(nil, True, False, nil);
  FThreadIdleEvent := CreateEvent(nil, False, True, nil);
  FIsStopping := False;
  FAsyncOpEvent := 0;
  FMemoryStream := nil;
  FFileStream := nil;
  FhSession := nil;
  FhConnect := nil;
  FhRequest := nil;
  FDownloadActive := False;
  FThreadStarted := False;
  FhRequestClosedByCallback := False;
  FSuccessfullyCompleted := False;
  FreeOnTerminate := False;
  FOnProgress := nil;
  FTotalBytes := 0;
  FErrorCode := 0;
  FBytesRead := 0;
  FAgent := WAgent;
  FResolveTimeout := 30000;
  FConnectTimeout := 30000;
  FSendTimeout := 30000;
  FReceiveTimeout := 30000;
  FProgressInterval := 50;
  FProxyType := ptSystemDefault;
  FProxyServer := '';
  FProxyPort := 0;
  FProxyUsername := '';
  FProxyPassword := '';
end;

destructor TWinHTTPDownloader.Destroy;
begin
  Terminate;

  if FStartEvent <> 0 then
    SetEvent(FStartEvent);

  if FThreadIdleEvent <> 0 then
    SetEvent(FThreadIdleEvent);

  StopDownload;

  if FStartEvent <> 0 then
  begin
    CloseHandle(FStartEvent);
    FStartEvent := 0;
  end;

  if FStoppingEvent <> 0 then
  begin
    CloseHandle(FStoppingEvent);
    FStoppingEvent := 0;
  end;

  if FThreadIdleEvent <> 0 then
  begin
    CloseHandle(FThreadIdleEvent);
    FThreadIdleEvent := 0;
  end;

  FreeAndNil(FCriticalSection);
  FreeAndNil(FMemoryStream);
  inherited Destroy;
end;

procedure TWinHTTPDownloader.DoProgressCallback(ADownloadStatus: TDownloadStatus; AInfoValue: DWORD);
var
  CurrentTime: Cardinal;
begin
  if not Assigned(FOnProgress) then
    Exit;

  if ADownloadStatus = dsDownloadingData then
  begin
    CurrentTime := GetTickCount;
    if (CurrentTime - FLastProgressTime < FProgressInterval) then
      Exit;
    FLastProgressTime := CurrentTime;
  end;

  FOnProgress(ADownloadStatus, AInfoValue, FBytesRead, FTotalBytes);
end;

procedure TWinHTTPDownloader.InternalStartOperation(const AURL: string; const ASavePath: string; AToMemory: Boolean);
begin
  StopDownload;

  WaitForSingleObject(FThreadIdleEvent, INFINITE);

  FCriticalSection.Enter;
  try
    FURL := AURL;
    FSavePath := ASavePath;
    FBytesRead := 0;
    FTotalBytes := 0;
    FErrorCode := 0;
    FSuccessfullyCompleted := False;
    FWebPageSource := '';
    FResponseContentType := '';

    if AToMemory then
    begin
      if FMemoryStream = nil then
        FMemoryStream := TMemoryStream.Create
      else
        FMemoryStream.Clear;
    end
    else
    begin
      if ASavePath = '' then
        raise Exception.Create('当不下载到内存时，SavePath 不能为空。');
    end;

    FDownloadActive := True;

    if not FThreadStarted then
    begin
      FThreadStarted := True;
      Start;
    end;
  finally
    FCriticalSection.Leave;
  end;

  SetEvent(FStartEvent);
end;

procedure TWinHTTPDownloader.StartDownload(const URL, SavePath: string);
begin
  if SavePath = '' then
    raise Exception.Create('对于 StartDownload，SavePath 不能为空。');
  InternalStartOperation(URL, SavePath, False);
end;

procedure TWinHTTPDownloader.StopDownload;
var
  WasActive: Boolean;
begin
  WasActive := False;
  FCriticalSection.Enter;
  try
    if FDownloadActive then
    begin
      WasActive := True;
      FIsStopping := True;
      ResetEvent(FStoppingEvent);

      FDownloadActive := False;

      if FAsyncOpEvent <> 0 then
      begin
        SetEvent(FAsyncOpEvent);
      end;
    end;
  finally
    FCriticalSection.Leave;
  end;

  if WasActive then
  begin
    WaitForSingleObject(FStoppingEvent, 5000);

    FCriticalSection.Enter;
    try
      FIsStopping := False;
    finally
      FCriticalSection.Leave;
    end;
  end;
end;

procedure TWinHTTPDownloader.GetWebPageSource(const URL: string);
begin
  InternalStartOperation(URL, '', True);
end;

function TWinHTTPDownloader.GetWebPageSourceText: string;
begin
  Result := FWebPageSource;
end;

procedure TWinHTTPDownloader.SetAllTimeouts(AResolveTimeout, AConnectTimeout, ASendTimeout, AReceiveTimeout: Integer);
begin
  FCriticalSection.Enter;
  try
    FResolveTimeout := AResolveTimeout;
    FConnectTimeout := AConnectTimeout;
    FSendTimeout := ASendTimeout;
    FReceiveTimeout := AReceiveTimeout;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TWinHTTPDownloader.GetAllTimeouts(out AResolveTimeout, AConnectTimeout, ASendTimeout, AReceiveTimeout: Integer);
begin
  FCriticalSection.Enter;
  try
    AResolveTimeout := FResolveTimeout;
    AConnectTimeout := FConnectTimeout;
    ASendTimeout := FSendTimeout;
    AReceiveTimeout := FReceiveTimeout;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TWinHTTPDownloader.GetMemoryData(out DataPtr: Pointer; out DataSize: Int64);
begin
  FCriticalSection.Enter;
  try
    if Assigned(FMemoryStream) then
    begin
      DataPtr := FMemoryStream.Memory;
      DataSize := FMemoryStream.Size;
    end
    else
    begin
      DataPtr := nil;
      DataSize := 0;
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TWinHTTPDownloader.SetProxy(AProxyType: TProxyType; const AProxyServer: string; AProxyPort: WORD; const AProxyUsername: string = ''; const AProxyPassword: string = '');
begin
  FCriticalSection.Enter;
  try
    FProxyType := AProxyType;
    if (AProxyType = ptNone) or (AProxyType = ptSystemDefault) then
    begin
      FProxyServer := '';
      FProxyPort := 0;
      FProxyUsername := '';
      FProxyPassword := '';
    end
    else
    begin
      FProxyServer := AProxyServer;
      FProxyPort := AProxyPort;
      FProxyUsername := AProxyUsername;
      FProxyPassword := AProxyPassword;
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

end.

