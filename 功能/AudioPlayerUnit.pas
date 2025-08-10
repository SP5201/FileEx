{*******************************************************************************
  音频播放单元
  功能：基于Windows MMSystem的音频播放和时钟管理

  主要功能：
  - PCM音频数据的实时播放
  - 支持多种音频格式（采样率、声道数可配置）
  - 音频时钟获取和同步
  - 音频缓冲区管理
  - 异步音频播放回调处理

  音频特性：
  - 支持16位PCM音频格式
  - 可配置采样率和声道数
  - 自动音频设备管理
  - 音频缓冲区队列管理
  - 线程安全的音频操作

  技术实现：
  - 基于Windows MMSystem API
  - 使用waveOut函数族
  - 异步回调机制
  - 内存管理和资源清理

  应用场景：
  - 视频播放的音频同步
  - 实时音频流播放
  - 音视频同步时钟提供

  Copyright (c) 2025 zotptptp
  Email: zoutp@qq.com
  All rights reserved.
*******************************************************************************}

unit AudioPlayerUnit;

interface

uses
  Windows, MMSystem, SysUtils, Classes, SyncObjs;

type
  TAudioPlayer = class
  private
    FWaveOut: HWAVEOUT;
    FDoneBuffers: TThreadList;
    FWaveFormat: TWaveFormatEx;
    FClockLock: TCriticalSection;
    FTotalBytesPlayed: Int64;
    procedure Cleanup;
    procedure ProcessDoneBuffers;
    procedure FreeWaveHeader(AWaveHdr: PWaveHdr);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Play(const AFrameBytes: TBytes; ASampleRate, AChannels: Integer);
    procedure Reset;
    function GetClock: Double;
  end;

implementation

procedure waveOutProc(hwo: HWAVEOUT; uMsg: UINT; dwInstance: DWORD_PTR; dwParam1: DWORD_PTR; dwParam2: DWORD_PTR); stdcall;
var
  Player: TAudioPlayer;
  WaveHdr: PWaveHdr;
begin
  if (uMsg = WOM_DONE) and (dwInstance <> 0) then
  begin
    Player := TAudioPlayer(TObject(dwInstance));
    WaveHdr := PWaveHdr(dwParam1);
    if Assigned(WaveHdr) then
    begin
      Player.FClockLock.Enter;
      try
        Player.FTotalBytesPlayed := Player.FTotalBytesPlayed + WaveHdr.dwBufferLength;
      finally
        Player.FClockLock.Leave;
      end;
    end;
    Player.FDoneBuffers.Add(Pointer(WaveHdr));
  end;
end;

{ TAudioPlayer }

constructor TAudioPlayer.Create;
begin
  inherited;
  FWaveOut := 0;
  FDoneBuffers := TThreadList.Create;
  FClockLock := TCriticalSection.Create;
  FTotalBytesPlayed := 0;
  FillChar(FWaveFormat, SizeOf(FWaveFormat), 0);
end;

destructor TAudioPlayer.Destroy;
begin
  Cleanup;
  FClockLock.Free;
  FDoneBuffers.Free;
  inherited;
end;

procedure TAudioPlayer.FreeWaveHeader(AWaveHdr: PWaveHdr);
begin
  if FWaveOut = 0 then
  begin
    FreeMem(AWaveHdr.lpData);
    FreeMem(AWaveHdr);
    Exit;
  end;

  if (AWaveHdr.dwFlags and WHDR_PREPARED) = WHDR_PREPARED then
    waveOutUnprepareHeader(FWaveOut, AWaveHdr, SizeOf(TWaveHdr));

  FreeMem(AWaveHdr.lpData);
  FreeMem(AWaveHdr);
end;

procedure TAudioPlayer.ProcessDoneBuffers;
var
  List: TList;
  i: Integer;
begin
  if FWaveOut = 0 then Exit;
  List := FDoneBuffers.LockList;
  try
    for i := 0 to List.Count - 1 do
    begin
      FreeWaveHeader(PWaveHdr(List[i]));
    end;
    List.Clear;
  finally
    FDoneBuffers.UnlockList;
  end;
end;

procedure TAudioPlayer.Cleanup;
begin
  if FWaveOut <> 0 then
  begin
    waveOutReset(FWaveOut);
    ProcessDoneBuffers;
    waveOutClose(FWaveOut);
    FWaveOut := 0;
  end;
  ProcessDoneBuffers;
end;

procedure TAudioPlayer.Play(const AFrameBytes: TBytes; ASampleRate, AChannels: Integer);
var
  WaveHdr: PWaveHdr;
  Buffer: Pointer;
begin
  ProcessDoneBuffers;

  if FWaveOut = 0 then
  begin
    FWaveFormat.wFormatTag := WAVE_FORMAT_PCM;
    FWaveFormat.nChannels := AChannels;
    FWaveFormat.nSamplesPerSec := ASampleRate;
    FWaveFormat.wBitsPerSample := 16;
    FWaveFormat.nBlockAlign := (FWaveFormat.nChannels * FWaveFormat.wBitsPerSample) div 8;
    FWaveFormat.nAvgBytesPerSec := FWaveFormat.nSamplesPerSec * FWaveFormat.nBlockAlign;
    FWaveFormat.cbSize := 0;
    if waveOutOpen(@FWaveOut, WAVE_MAPPER, @FWaveFormat, NativeUInt(@waveOutProc), DWORD_PTR(Self), CALLBACK_FUNCTION) <> MMSYSERR_NOERROR then
    begin
      FWaveOut := 0;
      Exit;
    end;
  end;

  if Length(AFrameBytes) > 0 then
  begin
    GetMem(Buffer, Length(AFrameBytes));
    Move(AFrameBytes[0], Buffer^, Length(AFrameBytes));

    GetMem(WaveHdr, SizeOf(TWaveHdr));
    FillChar(WaveHdr^, SizeOf(TWaveHdr), 0);
    WaveHdr.lpData := Buffer;
    WaveHdr.dwBufferLength := Length(AFrameBytes);

    waveOutPrepareHeader(FWaveOut, WaveHdr, SizeOf(TWaveHdr));
    if waveOutWrite(FWaveOut, WaveHdr, SizeOf(TWaveHdr)) <> MMSYSERR_NOERROR then
    begin
      FreeWaveHeader(WaveHdr);
    end;
  end;
end;

procedure TAudioPlayer.Reset;
begin
  Cleanup;
  FClockLock.Enter;
  try
    FTotalBytesPlayed := 0;
  finally
    FClockLock.Leave;
  end;
end;

function TAudioPlayer.GetClock: Double;
begin
  Result := 0;
  if FWaveFormat.nAvgBytesPerSec > 0 then
  begin
    FClockLock.Enter;
    try
      Result := FTotalBytesPlayed / FWaveFormat.nAvgBytesPerSec;
    finally
      FClockLock.Leave;
    end;
  end;
end;

end.
