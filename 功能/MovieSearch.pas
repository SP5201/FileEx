{*******************************************************************************
  视频文件搜索单元
  功能：提供多线程视频文件搜索和扫描功能
  
  主要功能：
  - 多目录递归搜索视频文件
  - 支持多种文件格式掩码匹配
  - 异步搜索，不阻塞主线程
  - 实时进度更新和回调通知
  - 重复文件检测和去重
  - 可中断和重启的搜索任务
  - 线程安全的搜索操作
  
  搜索特性：
  - 支持通配符文件掩码（*.mp4, *.avi等）
  - 递归搜索子目录
  - 实时统计扫描和匹配文件数量
  - 可配置的进度更新频率
  - 错误处理和异常恢复
  
  线程管理：
  - 单例搜索线程，支持任务队列
  - 线程同步和互斥锁保护
  - 优雅的线程终止机制
  - 内存安全的搜索结果传递
  
  Copyright (c) 2025 zotptptp
  Email: zoutp@qq.com
  All rights reserved.
*******************************************************************************}

unit MovieSearch;

interface

uses
  SysUtils, Classes, System.Generics.Collections, System.Masks, System.IOUtils,
  System.Types, Windows, System.SyncObjs,xcgui;

type
  TSearchResultsData = record
    MatchedCount: Integer;
    ScannedCount: Integer;
    Results: TArray<string>;
    IsComplete: Boolean;
  end;

  PSearchResultsData = ^TSearchResultsData;

  TSearchCompleteProc = function(const AData: Integer): Integer; stdcall;

  PSearchCompleteProc = ^TSearchCompleteProc;

type
  TVideoSearchThread = class(TThread)
  private
    FIsBusy: Boolean;
    FStartEvent: TEvent;
    FStopEvent: TEvent;
    FMutex: TCriticalSection;

    FNextFilePaths: TArray<string>;
    FNextMaskString: string;
    FNextExcludePaths: string;
    FNextOnCompleteCallback: PSearchCompleteProc;
    FTaskAvailable: Boolean;

    FCurrentFilePaths: TArray<string>;
    FCurrentMaskString: string;
    FCurrentExcludePaths: string;
    FCurrentOnCompleteCallback: PSearchCompleteProc;
    FOnComplete: Integer;

    FInternalResults: TArray<string>;
    FMatchedCount: Integer;
    FScannedCount: Integer;
    FIsComplete: Boolean;
    FLastUpdateTime: Cardinal;
    FLastMatchedCount: Integer; // 新增字段，记录上次回调的匹配数

    procedure DoProgressUpdate(IsFinalUpdate: Boolean; CurrentTempList: TList<string>);
    procedure SynchronizeResults;
    procedure SearchDirectoryRecursive(const ADirectoryPath: string; TempList: TList<string>; FoundFilesDict: TDictionary<string, Boolean>; const SearchMasks: TArray<string>; const ExcludeDict: TDictionary<string, Boolean>);
    procedure ProcessFile(const AFilePath: string; TempList: TList<string>; FoundFilesDict: TDictionary<string, Boolean>; const SearchMasks: TArray<string>);
    procedure SetOnComplete(Value: Integer);
  protected
    procedure Execute; override;
  public
    FilePaths: TArray<string>;
    SearchPattern: string;
    ExcludePaths: string;
    constructor Create;
    destructor Destroy; override;

    function Start: Boolean;
    procedure StopSearch;
    procedure RequestTerminate;
    property OnComplete: Integer read FOnComplete write SetOnComplete;
  end;

implementation

constructor TVideoSearchThread.Create;
begin
  inherited Create(False);
  FStartEvent := TEvent.Create(nil, True, False, '');
  FStopEvent := TEvent.Create(nil, True, False, '');
  FMutex := TCriticalSection.Create;
  FTaskAvailable := False;
  FIsBusy := False;
  FMatchedCount := 0;
  FLastMatchedCount := 0; // 初始化
end;

destructor TVideoSearchThread.Destroy;
begin
  RequestTerminate;
  FStartEvent.SetEvent;
  FStopEvent.SetEvent;
  if not Terminated then
  begin
    WaitForSingleObject(Self.Handle, 500);
  end;

  FStartEvent.Free;
  FStopEvent.Free;
  FMutex.Free;
  inherited Destroy;
end;

procedure TVideoSearchThread.DoProgressUpdate(IsFinalUpdate: Boolean; CurrentTempList: TList<string>);
var
  CurrentTime: Cardinal;
  MatchedCount: Integer;
begin
  if not Assigned(FCurrentOnCompleteCallback) then
    Exit;

  CurrentTime := GetTickCount();
  MatchedCount := CurrentTempList.Count;

  // 只有有新文件，或者是最终回调，才允许回调
  if (IsFinalUpdate) or
     ((MatchedCount > FLastMatchedCount) and (((CurrentTime - FLastUpdateTime) >= 30) or (FLastUpdateTime = 0))) then
  begin
    FInternalResults := CurrentTempList.ToArray;
    FMatchedCount := MatchedCount;
    FIsComplete := IsFinalUpdate;
    FLastUpdateTime := CurrentTime;
    FLastMatchedCount := MatchedCount; // 记录本次回调的文件数
    SynchronizeResults;
  end;
end;

procedure TVideoSearchThread.SynchronizeResults;
var
  DataToSend: PSearchResultsData;
begin
  New(DataToSend);
  DataToSend.MatchedCount := FMatchedCount;
  DataToSend.ScannedCount := FScannedCount;
  DataToSend.Results := FInternalResults;
  DataToSend.IsComplete := FIsComplete;
  XC_CallUiThread(Integer(FCurrentOnCompleteCallback), Integer(DataToSend));
end;

procedure TVideoSearchThread.SearchDirectoryRecursive(const ADirectoryPath: string; TempList: TList<string>; FoundFilesDict: TDictionary<string, Boolean>; const SearchMasks: TArray<string>; const ExcludeDict: TDictionary<string, Boolean>);
var
  LFile: string;
  LSubDir: string;
  FilesInCurrentDir: TStringDynArray;
  SubDirsInCurrentDir: TStringDynArray;
  IsTerminated: Boolean;
begin
  IsTerminated := Terminated or (FStopEvent.WaitFor(0) = wrSignaled);
  if IsTerminated then
    Exit;

  if not TDirectory.Exists(ADirectoryPath) then
    Exit;

  // 检查当前目录是否在排除列表中
  if ExcludeDict.ContainsKey(IncludeTrailingPathDelimiter(ADirectoryPath)) then
    Exit;

  try
    FilesInCurrentDir := TDirectory.GetFiles(ADirectoryPath, '*', TSearchOption.soTopDirectoryOnly);
  except
    on E: Exception do
      Exit;
  end;

  for LFile in FilesInCurrentDir do
  begin
    IsTerminated := Terminated or (FStopEvent.WaitFor(0) = wrSignaled);
    if IsTerminated then
      Break;
    ProcessFile(LFile, TempList, FoundFilesDict, SearchMasks);
  end;

  IsTerminated := Terminated or (FStopEvent.WaitFor(0) = wrSignaled);
  if IsTerminated then
    Exit;

  try
    SubDirsInCurrentDir := TDirectory.GetDirectories(ADirectoryPath, '*', TSearchOption.soTopDirectoryOnly);
  except
    on E: Exception do
      Exit;
  end;

  for LSubDir in SubDirsInCurrentDir do
  begin
    IsTerminated := Terminated or (FStopEvent.WaitFor(0) = wrSignaled);
    if IsTerminated then
      Break;
    SearchDirectoryRecursive(LSubDir, TempList, FoundFilesDict, SearchMasks, ExcludeDict);
    DoProgressUpdate(False, TempList);
  end;
end;

procedure TVideoSearchThread.ProcessFile(const AFilePath: string; TempList: TList<string>; FoundFilesDict: TDictionary<string, Boolean>; const SearchMasks: TArray<string>);
var
  CurrentFileMask: string;
begin
  if Terminated or (FStopEvent.WaitFor(0) = wrSignaled) then
    Exit;

  Inc(FScannedCount);

  for CurrentFileMask in SearchMasks do
  begin
    if MatchesMask(ExtractFileName(AFilePath), CurrentFileMask) then
    begin
      if not FoundFilesDict.ContainsKey(AFilePath) then
      begin
        TempList.Add(AFilePath);
        FoundFilesDict.Add(AFilePath, True);
        DoProgressUpdate(False, TempList);
      end;
      Break;
    end;
  end;
end;

procedure TVideoSearchThread.RequestTerminate;
begin
  inherited Terminate;
  FStartEvent.SetEvent;
  FStopEvent.SetEvent;
end;

procedure TVideoSearchThread.SetOnComplete(Value: Integer);
begin
  FMutex.Enter;
  try
    FOnComplete :=Value;
  finally
    FMutex.Leave;
  end;
end;

function TVideoSearchThread.Start: Boolean;
begin
  FMutex.Enter;
  try
    if FIsBusy then
    begin
      Result := False;
      Exit;
    end;

    FNextFilePaths := FilePaths;
    FNextMaskString := SearchPattern;
    FNextExcludePaths := ExcludePaths;
    FNextOnCompleteCallback := PSearchCompleteProc(FOnComplete);
    FTaskAvailable := True;
    FIsBusy := True;

    FStopEvent.ResetEvent;
    FStartEvent.SetEvent;
    Result := True;
  finally
    FMutex.Leave;
  end;
end;

procedure TVideoSearchThread.StopSearch;
begin
  FMutex.Enter;
  try
    FStopEvent.SetEvent;
  finally
    FMutex.Leave;
  end;
end;

procedure TVideoSearchThread.Execute;
var
  MaskList: TStringList;
  ExcludeList: TStringList;
  TempList: TList<string>;
  FoundFilesDict: TDictionary<string, Boolean>;
  ExcludeDict: TDictionary<string, Boolean>;
  CurrentPath: string;
  I: Integer;
  SearchMasks: TArray<string>;
  TrimmedMask: string;
  LocalTaskAvailable: Boolean;
  IsTerminated: Boolean;
begin
  while not Terminated do
  begin
    FStartEvent.WaitFor(INFINITE);
    FStartEvent.ResetEvent;

    IsTerminated := Terminated;
    if IsTerminated then
      Break;

    FMutex.Enter;
    LocalTaskAvailable := FTaskAvailable;
    if LocalTaskAvailable then
    begin
      FCurrentFilePaths := FNextFilePaths;
      FCurrentMaskString := FNextMaskString;
      FCurrentExcludePaths := FNextExcludePaths;
      FCurrentOnCompleteCallback := FNextOnCompleteCallback;
      FTaskAvailable := False;
      FNextFilePaths := Default(TArray<string>);
      FNextMaskString := '';
      FNextExcludePaths := '';
      FNextOnCompleteCallback := nil;
    end;
    FMutex.Leave;

    IsTerminated := Terminated;
    if IsTerminated then
      Break;

    if LocalTaskAvailable then
    begin
      FStopEvent.ResetEvent;
      FLastUpdateTime := 0;
      SetLength(FInternalResults, 0);
      FScannedCount := 0;
      FMatchedCount := 0;
      FIsComplete := False;
      FLastMatchedCount := 0; // 新任务开始时初始化

      TempList := TList<string>.Create;
      MaskList := TStringList.Create;
      FoundFilesDict := TDictionary<string, Boolean>.Create;
      ExcludeList := TStringList.Create;
      ExcludeDict := TDictionary<string, Boolean>.Create;

      try
        // 解析搜索掩码
        MaskList.Delimiter := ';';
        MaskList.StrictDelimiter := True;
        MaskList.DelimitedText := FCurrentMaskString;

        SetLength(SearchMasks, 0);
        if MaskList.Count > 0 then
        begin
          for I := 0 to MaskList.Count - 1 do
          begin
            TrimmedMask := Trim(MaskList[I]);
            if Length(TrimmedMask) > 0 then
            begin
              SetLength(SearchMasks, Length(SearchMasks) + 1);
              SearchMasks[High(SearchMasks)] := TrimmedMask;
            end;
          end;
        end;

        if Length(SearchMasks) = 0 then
        begin
          SetLength(SearchMasks, 1);
          SearchMasks[0] := '*';
        end;
        
        // 解析排除路径
        ExcludeList.Delimiter := ';';
        ExcludeList.StrictDelimiter := True;
        ExcludeList.DelimitedText := FCurrentExcludePaths;
        for TrimmedMask in ExcludeList do
        begin
          if TrimmedMask <> '' then
            ExcludeDict.Add(IncludeTrailingPathDelimiter(TrimmedMask), True);
        end;

        for CurrentPath in FCurrentFilePaths do
        begin
          IsTerminated := Terminated or (FStopEvent.WaitFor(0) = wrSignaled);
          if IsTerminated then
            Break;

          if TFile.Exists(CurrentPath) then
          begin
            ProcessFile(CurrentPath, TempList, FoundFilesDict, SearchMasks);
          end
          else if TDirectory.Exists(CurrentPath) then
          begin
            SearchDirectoryRecursive(CurrentPath, TempList, FoundFilesDict, SearchMasks, ExcludeDict);
            IsTerminated := Terminated or (FStopEvent.WaitFor(0) = wrSignaled);
            if IsTerminated then
              Break;
          end;
        end;

        IsTerminated := Terminated or (FStopEvent.WaitFor(0) = wrSignaled);
      finally
        try
          DoProgressUpdate(not IsTerminated, TempList);
        except
          // 捕获回调中可能抛出的异常，以确保线程状态能被正确重置并且资源得到释放。
          // An exception in the callback is caught here to ensure the thread state is reset correctly and resources are freed.
        end;
        
        FMutex.Enter;
        try
          FIsBusy := False;
        finally
          FMutex.Leave;
        end;

        MaskList.Free;
        TempList.Free;
        FoundFilesDict.Free;
        ExcludeList.Free;
        ExcludeDict.Free;
      end;
    end;
  end;
end;

end.

