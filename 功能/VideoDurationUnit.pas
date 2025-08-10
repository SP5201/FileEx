{*******************************************************************************
  视频解码和播放单元
  功能：基于FFmpeg的视频文件解码、播放和音频同步功能
  
  主要功能：
  - 视频文件信息获取（时长、分辨率、编码格式等）
  - 异步视频帧解码和回调
  - 音频解码和播放支持
  - 音视频同步机制
  - 循环播放功能
  - 播放控制（暂停、恢复、停止）
  - 可配置播放速度和时间范围
  
  支持特性：
  - 多线程解码，不阻塞主线程
  - 音视频同步时钟管理
  - 静音和音频播放控制
  - 自定义解码参数（最大帧数、播放速度等）
  - 错误处理和回调机制
  
  技术实现：
  - 基于FFmpeg库（libavformat, libavcodec等）
  - 使用Windows音频API进行音频播放
  - 线程安全的解码和播放控制
  
  Copyright (c) 2025 zotptptp
  Email: zoutp@qq.com
  All rights reserved.
*******************************************************************************}

unit VideoDurationUnit;

interface

uses
  Windows, SysUtils, Classes, SyncObjs, ActiveX,
  libavformat, libavutil, libavutil_mathematics, libavutil_rational, libavutil_error, libavutil_time, FFUtils, libavcodec_codec,
  libswscale, libavcodec, libavcodec_packet, libavcodec_codec_par, libavutil_frame, libavutil_pixfmt, libavutil_mem,
  libavutil_imgutils, libswresample, libavutil_channel_layout, libavutil_samplefmt,libavutil_log, AudioPlayerUnit;

type
  TScalingQuality = (sqFastBilinear, sqBicubic, sqLanczos, sqSpline);

type
    { 视频帧解码回调函数。每成功解码一帧视频时调用。
      AFrameData: 指向解码后的视频帧数据（例如BGRA格式）的指针。
      AWidth: 视频帧的宽度。
      AHeight: 视频帧的高度。
      APtsSec: 该帧的显示时间戳（秒）。
      AUserData: 用户自定义数据指针，通常是发起解码的TVideoFile实例。 }
    TVideoFrameCallback = procedure(const AFrameData: Pointer; AWidth, AHeight: Integer; APtsSec: Double; AUserData: Pointer) of object;
    
    { 音频帧解码回调函数。每成功解码一段音频时调用。
      AFrameData: 指向解码并重采样后的音频数据（例如S16格式）的指针。
      ADataSize: 音频数据的大小（字节）。
      ASampleRate: 音频的采样率（例如44100）。
      AChannels: 音频的声道数（例如2代表立体声）。
      APtsSec: 该段音频的播放时间戳（秒）。
      AUserData: 用户自定义数据指针。 }
    TAudioFrameCallback = procedure(const AFrameData: Pointer; ADataSize: Cardinal; ASampleRate, AChannels: Integer; APtsSec: Double; AUserData: Pointer) of object;
    
    { 解码完成回调函数。当所有帧解码完毕或达到指定结束条件时调用。 }
    TDecodeCompletionCallback = procedure(AUserData: Pointer) of object;
    
    { 解码错误回调函数。当解码过程中发生无法恢复的错误时调用。 }
    TDecodeErrorCallback = procedure(const AErrorMessage: string; AUserData: Pointer) of object;
    
    { 获取外部音频时钟回调函数。用于音视频同步，返回当前音频播放器的时钟时间。
      返回当前音频时钟（秒）。如果不可用，应返回负值。 }
    TGetAudioClockCallback = function: Double of object;
    
    { 循环播放回调函数。当视频播放完成一轮并准备开始下一次循环时调用。 }
    TLoopCallback = procedure of object;
type
  TVideoInfo = record
    Duration: Double;
    Width: Integer;
    Height: Integer;
    Resolution: string;
    FrameRate: string;
    BitRate: Int64;
    CodecName: string;
    FileFormat: string;
    HasVideo: Boolean;
    HasAudio: Boolean;
    AudioSampleRate: Integer;
    AudioBitRate: Integer;
    AudioChannels: Integer;
    ErrorMessage: string;
  end;

  TVideoFile = class
  private
    FFilePath: string;
    FVideoInfo: TVideoInfo;
    FInfoLoaded: Boolean;
    FDecoderThread: TThread;
    FAudioPlayer: TAudioPlayer;
    FAudioPlaybackEnabled: Boolean;
    FMuted: Boolean;
    FLoopPlayback: Boolean;
    FAudioClockBasePts: Double;
    FAudioClockStartTime: Int64;
    FAudioClockInitialized: Boolean;
    FVideoSize: TSize;
    procedure LoadVideoInfo;
    function GetInfo: TVideoInfo;
    procedure HandleAudioFrame(const AFrameData: Pointer; ADataSize: Cardinal; ASampleRate, AChannels: Integer; APtsSec: Double; AUserData: Pointer);
    function GetAudioClock: Double;
    procedure ResetAudioState;
  public
    StartTime: Double;
    EndTime: Double;
    constructor Create(const AFilePath: string);
    destructor Destroy; override;
    procedure DecodeAllFramesAsync(AVideoFrameCallback: TVideoFrameCallback; AUserData: Pointer; ACompletionCallback: TDecodeCompletionCallback = nil; AErrorCallback: TDecodeErrorCallback = nil; MaxFrames: Integer = -1; ASpeed: Double = 1.0);
    procedure Terminate;
    property FilePath: string read FFilePath;
    property Info: TVideoInfo read GetInfo;
    property AudioPlaybackEnabled: Boolean read FAudioPlaybackEnabled write FAudioPlaybackEnabled;
    property Muted: Boolean read FMuted write FMuted;
    property LoopPlayback: Boolean read FLoopPlayback write FLoopPlayback;
    property VideoSize: TSize read FVideoSize write FVideoSize;
    procedure Pause;
    procedure ResumePlay;
    procedure ResetAndDecode(AVideoFrameCallback: TVideoFrameCallback; AUserData: Pointer; 
      ACompletionCallback: TDecodeCompletionCallback = nil; AErrorCallback: TDecodeErrorCallback = nil; 
      MaxFrames: Integer = -1; ASpeed: Double = 1.0);
  end;

implementation

uses MMSystem;

type
  TVideoDecoderThread = class(TThread)
  private
    FFilePath: string;
    FVideoFrameCallback: TVideoFrameCallback;
    FAudioFrameCallback: TAudioFrameCallback;
    FCompletionCallback: TDecodeCompletionCallback;
    FErrorCallback: TDecodeErrorCallback;
    FUserData: Pointer;
    FMaxFrames: Integer;
    FSpeed: Double;
    FStartTime: Double;
    FEndTime: Double;
    FErrorMessage: string;
    FStopEvent: TEvent;
    FLoopPlayback: Boolean;
    FGetAudioClockCallback: TGetAudioClockCallback;
    FOnLoopCallback: TLoopCallback;
    FPauseEvent: TEvent;
    FResetEvent: TEvent;
    FIsRunning: Boolean;
    FVideoSize: TSize;
    procedure DoFinished;
    procedure DoError;
  protected
    procedure Execute; override;
  public
    constructor Create(const AFilePath: string; AVideoFrameCallback: TVideoFrameCallback; AAudioFrameCallback: TAudioFrameCallback; AUserData: Pointer; ACompletionCallback: TDecodeCompletionCallback; AErrorCallback: TDecodeErrorCallback; AMaxFrames: Integer; ASpeed: Double; AStartTime: Double; AEndTime: Double; ALoopPlayback: Boolean; AGetAudioClockCallback: TGetAudioClockCallback; AOnLoopCallback: TLoopCallback; AVideoSize: TSize);
    destructor Destroy; override;
    procedure Stop;
    procedure Pause;
    procedure ResumePlay;
    function IsRunning: Boolean;
    procedure Reset(const AFilePath: string; AVideoFrameCallback: TVideoFrameCallback; AAudioFrameCallback: TAudioFrameCallback; AUserData: Pointer; ACompletionCallback: TDecodeCompletionCallback; AErrorCallback: TDecodeErrorCallback; AMaxFrames: Integer; ASpeed: Double; AStartTime: Double; AEndTime: Double; ALoopPlayback: Boolean; AGetAudioClockCallback: TGetAudioClockCallback; AOnLoopCallback: TLoopCallback);
  end;

function DecodeInterruptCallback(opaque: Pointer): Integer; cdecl;
begin
  if (opaque <> nil) and (TVideoDecoderThread(opaque).Terminated) then
    Result := 1
  else
    Result := 0;
end;

{ TVideoDecoderThread }

constructor TVideoDecoderThread.Create(const AFilePath: string; AVideoFrameCallback: TVideoFrameCallback; AAudioFrameCallback: TAudioFrameCallback; AUserData: Pointer; ACompletionCallback: TDecodeCompletionCallback; AErrorCallback: TDecodeErrorCallback; AMaxFrames: Integer; ASpeed: Double; AStartTime: Double; AEndTime: Double; ALoopPlayback: Boolean; AGetAudioClockCallback: TGetAudioClockCallback; AOnLoopCallback: TLoopCallback; AVideoSize: TSize);
begin
  inherited Create(True);
  FreeOnTerminate := False;
  FFilePath := AFilePath;
  FVideoFrameCallback := AVideoFrameCallback;
  FAudioFrameCallback := AAudioFrameCallback;
  FUserData := AUserData;
  FCompletionCallback := ACompletionCallback;
  FErrorCallback := AErrorCallback;
  FMaxFrames := AMaxFrames;
  if ASpeed <= 0  then
    FSpeed := 1.0
  else
    FSpeed := ASpeed;
  FStartTime := AStartTime;
  FEndTime := AEndTime;
  FLoopPlayback := ALoopPlayback;
  FStopEvent := TEvent.Create(nil, True, False, '');
  FPauseEvent := TEvent.Create(nil, True, True, ''); // 初始为有信号（不暂停）
  FResetEvent := TEvent.Create(nil, True, False, '');
  FGetAudioClockCallback := AGetAudioClockCallback;
  FOnLoopCallback := AOnLoopCallback;
  FIsRunning := False;
  FVideoSize := AVideoSize;
end;

destructor TVideoDecoderThread.Destroy;
begin
  FStopEvent.Free;
  FPauseEvent.Free;
  FResetEvent.Free;
  inherited;
end;

procedure TVideoDecoderThread.Stop;
begin
  Terminate;
  FStopEvent.SetEvent;
  FPauseEvent.SetEvent; // 确保如果线程处于暂停状态也能退出
end;

procedure TVideoDecoderThread.Pause;
begin
  FPauseEvent.ResetEvent; // 进入暂停
end;

procedure TVideoDecoderThread.ResumePlay;
begin
  FPauseEvent.SetEvent; // 继续
end;

function TVideoDecoderThread.IsRunning: Boolean;
begin
  Result := FIsRunning;
end;

procedure TVideoDecoderThread.Reset(const AFilePath: string; AVideoFrameCallback: TVideoFrameCallback; AAudioFrameCallback: TAudioFrameCallback; AUserData: Pointer; ACompletionCallback: TDecodeCompletionCallback; AErrorCallback: TDecodeErrorCallback; AMaxFrames: Integer; ASpeed: Double; AStartTime: Double; AEndTime: Double; ALoopPlayback: Boolean; AGetAudioClockCallback: TGetAudioClockCallback; AOnLoopCallback: TLoopCallback);
begin
  // 确保线程不在运行中
  if FIsRunning then
  begin
    Stop;
    // 等待线程结束当前解码
    FResetEvent.WaitFor(5000); // 最多等待5秒
    FResetEvent.ResetEvent;
  end;

  // 重置所有参数
  FFilePath := AFilePath;
  FVideoFrameCallback := AVideoFrameCallback;
  FAudioFrameCallback := AAudioFrameCallback;
  FUserData := AUserData;
  FCompletionCallback := ACompletionCallback;
  FErrorCallback := AErrorCallback;
  FMaxFrames := AMaxFrames;
  if ASpeed <= 0 then
    FSpeed := 1.0
  else
    FSpeed := ASpeed;
  FStartTime := AStartTime;
  FEndTime := AEndTime;
  FLoopPlayback := ALoopPlayback;
  FGetAudioClockCallback := AGetAudioClockCallback;
  FOnLoopCallback := AOnLoopCallback;
  
  // 重置事件状态
  FStopEvent.ResetEvent;
  FPauseEvent.SetEvent; // 初始为不暂停
end;

procedure TVideoDecoderThread.Execute;
var
  LFormatCtx: PAVFormatContext;
  LVideoCodecCtx, LAudioCodecCtx: PAVCodecContext;
  LFrame, LFrameRGB: PAVFrame;
  LVideoCodec, LAudioCodec: PAVCodec;
  LVideoStream, LAudioStream: PAVStream;
  LVideoStreamIndex, LAudioStreamIndex: Integer;
  LRet, LVideoFrameCount: Integer;
  LAnsiFilePath: AnsiString;
  LPacket: PAVPacket;
  LSwsCtx: PSwsContext;
  LSwrCtx: PSwrContext;
  LVideoBuffer: Pointer;
  LAudioBuffer: Pointer;
  LVideoWidth, LVideoHeight, LTargetWidth, LTargetHeight: Integer;
  LVideoBufferSize: cardinal;
  LPtsSec: Double;
  LPerfFrequency, LStartTime, LCurrentTime: Int64;
  LFirstPts: Int64;
  LElapsedMs, LExpectedMs: Cardinal;
  LOutSampleRate, LOutChannels, LOutNbSamples, LDestNbSamples: Integer;
  LOutSampleFmt: TAVSampleFormat;
  LOutChLayout: TAVChannelLayout;
  LAudioBufferSize: Cardinal;
  LDecodingDone: Boolean;
  LShouldLoop: Boolean;
  LAudioClock: Double;
  LVideoPts: Double;
  LDelay: Double;
  Handles: array[0..1] of THandle;
  WaitResult: DWORD;
  LanczosParam: Double;
begin
  // 在DEBUG模式下启用详细日志记录，以帮助诊断问题
  {$IFDEF DEBUG}
  av_log_set_level(AV_LOG_VERBOSE);
  {$ELSE}
  av_log_set_level(AV_LOG_QUIET);
  {$ENDIF}
  
  CoInitialize(nil);
  
  repeat
    // 重置所有状态变量
    LFormatCtx := nil;
    LVideoCodecCtx := nil;
    LAudioCodecCtx := nil;
    LFrame := nil;
    LFrameRGB := nil;
    LPacket := nil;
    LSwsCtx := nil;
    LSwrCtx := nil;
    LVideoBuffer := nil;
    LAudioBuffer := nil;
    LVideoCodec := nil;
    LAudioCodec := nil;
    FIsRunning := True;
    LShouldLoop := False;
    LDecodingDone := False;
    LFirstPts := AV_NOPTS_VALUE;
    LVideoStreamIndex := -1;
    LAudioStreamIndex := -1;
    LOutSampleFmt := AV_SAMPLE_FMT_NONE;
    LVideoWidth := 0;
    LVideoHeight := 0;
    LTargetWidth := 0;
    LTargetHeight := 0;
    LVideoBufferSize := 0;
    LOutSampleRate := 0;
    LOutChannels := 0;
    LPtsSec := 0;



    try
      QueryPerformanceFrequency(LPerfFrequency);

      LFormatCtx := avformat_alloc_context();
      if not Assigned(LFormatCtx) then
      begin
        FErrorMessage := '无法分配格式上下文';
        Queue(DoError);
        Break;
      end;

      LFormatCtx.interrupt_callback.callback := @DecodeInterruptCallback;
      LFormatCtx.interrupt_callback.opaque := Self;

      LAnsiFilePath := AnsiString(UTF8Encode(FFilePath));
      if avformat_open_input(@LFormatCtx, PAnsiChar(LAnsiFilePath), nil, nil) < 0 then
      begin
        FErrorMessage := '无法打开文件: ' + FFilePath;
        Queue(DoError);
        Break;
      end;

      try
        if avformat_find_stream_info(LFormatCtx, nil) < 0 then
        begin
          FErrorMessage := '无法获取流信息: ' + FFilePath;
          Queue(DoError);
          Break;
        end;

        // --- Video Setup ---
        if Assigned(FVideoFrameCallback) then
        begin
          LVideoStreamIndex := av_find_best_stream(LFormatCtx, AVMEDIA_TYPE_VIDEO, -1, -1, @LVideoCodec, 0);
          if LVideoStreamIndex >= 0 then
          begin
            LVideoStream := PPtrIdx(LFormatCtx.streams, LVideoStreamIndex);
            if Assigned(LVideoStream) then
            begin
              LVideoCodecCtx := avcodec_alloc_context3(LVideoCodec);
              if Assigned(LVideoCodecCtx) then
              begin
                if avcodec_parameters_to_context(LVideoCodecCtx, LVideoStream.codecpar) >= 0 then
                begin
                  LVideoCodecCtx.thread_count := 0;
                  LVideoCodecCtx.thread_type := FF_THREAD_FRAME or FF_THREAD_SLICE;
                  
                  if avcodec_open2(LVideoCodecCtx, LVideoCodec, nil) >= 0 then
                  begin
                    LVideoWidth := LVideoCodecCtx.width;
                    LVideoHeight := LVideoCodecCtx.height;

                    // 确定缩放后的目标尺寸
                    LTargetWidth := FVideoSize.cx;
                    LTargetHeight := FVideoSize.cy;
                    if (LTargetWidth <= 0) or (LTargetHeight <= 0) then
                    begin
                      LTargetWidth := LVideoWidth;
                      LTargetHeight := LVideoHeight;
                    end;

                    if (LVideoWidth > 0) and (LVideoHeight > 0) then
                    begin
                      LFrameRGB := av_frame_alloc;
                      if Assigned(LFrameRGB) then
                      begin
                        // 使用目标尺寸来分配缓冲区
                        LVideoBufferSize := LTargetWidth * LTargetHeight * 4;
                        LVideoBuffer := av_malloc(LVideoBufferSize);
                        if Assigned(LVideoBuffer) then
                        begin
                          if av_image_fill_arrays(@LFrameRGB.data[0], @LFrameRGB.linesize[0], LVideoBuffer, AV_PIX_FMT_BGRA, LTargetWidth, LTargetHeight, 1) >= 0 then
                          begin
                            // 设置SwsContext进行缩放和格式转换
                            // Lanczos算法的lobe参数，默认是3，增加该值可以提升锐度
                            LanczosParam := 4.0;
                            LSwsCtx := sws_getContext(LVideoWidth, LVideoHeight, LVideoCodecCtx.pix_fmt,
                                                     LTargetWidth, LTargetHeight, AV_PIX_FMT_BGRA,
                                                     sWS_LANCZOS, nil, nil, @LanczosParam);
                            if not Assigned(LSwsCtx) then
                            begin
                              av_frame_free(@LFrameRGB);
                              av_free(LVideoBuffer);
                              LVideoStreamIndex := -1;
                            end;
                          end
                          else
                          begin
                            av_frame_free(@LFrameRGB);
                            av_free(LVideoBuffer);
                            LVideoStreamIndex := -1;
                          end;
                        end
                        else
                        begin
                          av_frame_free(@LFrameRGB);
                          LVideoStreamIndex := -1;
                        end;
                      end
                      else
                        LVideoStreamIndex := -1;
                    end
                    else
                      LVideoStreamIndex := -1;
                  end
                  else
                    LVideoStreamIndex := -1;
                end
                else
                  LVideoStreamIndex := -1;
              end
              else
                LVideoStreamIndex := -1;
            end
            else
              LVideoStreamIndex := -1;
          end;
        end;

        // --- Audio Setup ---
        if Assigned(FAudioFrameCallback) then
        begin
          LAudioStreamIndex := av_find_best_stream(LFormatCtx, AVMEDIA_TYPE_AUDIO, -1, LVideoStreamIndex, @LAudioCodec, 0);
          if LAudioStreamIndex >= 0 then
          begin
            LAudioStream := PPtrIdx(LFormatCtx.streams, LAudioStreamIndex);
            if Assigned(LAudioStream) then
            begin
              LAudioCodecCtx := avcodec_alloc_context3(LAudioCodec);
              if Assigned(LAudioCodecCtx) then
              begin
                if avcodec_parameters_to_context(LAudioCodecCtx, LAudioStream.codecpar) >= 0 then
                begin
                  if avcodec_open2(LAudioCodecCtx, LAudioCodec, nil) >= 0 then
                  begin
                    LOutSampleRate := 44100;
                    LOutSampleFmt := AV_SAMPLE_FMT_S16;
                    
                    FillChar(LOutChLayout, SizeOf(TAVChannelLayout), 0);
                    av_channel_layout_default(@LOutChLayout, 2);
                    LOutChannels := LOutChLayout.nb_channels;

                    try
                      if swr_alloc_set_opts2(@LSwrCtx, @LOutChLayout, LOutSampleFmt, LOutSampleRate, @LAudioCodecCtx.ch_layout, LAudioCodecCtx.sample_fmt, LAudioCodecCtx.sample_rate, 0, nil) < 0 then
                        LAudioStreamIndex := -1
                      else
                      begin
                        if swr_init(LSwrCtx) < 0 then
                          LAudioStreamIndex := -1;
                      end;
                    finally
                       av_channel_layout_uninit(@LOutChLayout);
                    end;
                  end
                  else
                    LAudioStreamIndex := -1;
                end
                else
                  LAudioStreamIndex := -1;
              end
              else
                LAudioStreamIndex := -1;
            end
            else
              LAudioStreamIndex := -1;
          end;
        end;

        if (LVideoStreamIndex < 0) and (LAudioStreamIndex < 0) then
        begin
          FErrorMessage := Format('未找到可解码的视频或音频流: %s (视频流索引: %d, 音频流索引: %d)', [FFilePath, LVideoStreamIndex, LAudioStreamIndex]);
          Queue(DoError);
          Exit;
        end;

        // Seek to start time if specified
        if FStartTime > 0 then
        begin
          if LVideoStreamIndex >= 0 then
            av_seek_frame(LFormatCtx, LVideoStreamIndex, round(FStartTime / av_q2d(PPtrIdx(LFormatCtx.streams, LVideoStreamIndex).time_base)), AVSEEK_FLAG_BACKWARD)
          else if LAudioStreamIndex >= 0 then
            av_seek_frame(LFormatCtx, LAudioStreamIndex, round(FStartTime / av_q2d(PPtrIdx(LFormatCtx.streams, LAudioStreamIndex).time_base)), AVSEEK_FLAG_BACKWARD);

          if (LVideoStreamIndex >= 0) and Assigned(LVideoCodecCtx) then
            avcodec_flush_buffers(LVideoCodecCtx);
          if (LAudioStreamIndex >= 0) and Assigned(LAudioCodecCtx) then
            avcodec_flush_buffers(LAudioCodecCtx);
          if Assigned(LSwrCtx) then
             swr_init(LSwrCtx);
        end;

        LFrame := av_frame_alloc;
        LPacket := av_packet_alloc;

        {$IFDEF DEBUG}
        if not Assigned(LFrame) or not Assigned(LPacket) then
        begin
          FErrorMessage := '分配帧或包失败';
          Queue(DoError);
          Exit;
        end;
        {$ENDIF}

        try
          LVideoFrameCount := 0;

          Handles[0] := FPauseEvent.Handle;
          Handles[1] := FStopEvent.Handle;

          while (not Terminated) and (not LDecodingDone) and (av_read_frame(LFormatCtx, LPacket) >= 0) do
          begin
            WaitResult := WaitForMultipleObjects(2, @Handles, False, INFINITE);
            if (WaitResult = WAIT_OBJECT_0 + 1) or Terminated then
              Break;
            try
              // --- Video Decoding ---
              if (LPacket.stream_index = LVideoStreamIndex) then
              begin
                LRet := avcodec_send_packet(LVideoCodecCtx, LPacket);
                if LRet >= 0 then
                begin
                  while (not Terminated) and (avcodec_receive_frame(LVideoCodecCtx, LFrame) = 0) do
                  begin
                    try
                      if LFirstPts = AV_NOPTS_VALUE then
                      begin
                        LFirstPts := LFrame.pts;
                        QueryPerformanceCounter(LStartTime);
                      end;

                      if (LFrame.pts <> AV_NOPTS_VALUE) and (PPtrIdx(LFormatCtx.streams, LVideoStreamIndex).time_base.den > 0) then
                      begin
                        LAudioClock := -1.0;
                        if Assigned(FGetAudioClockCallback) then
                          LAudioClock := FGetAudioClockCallback;

                        if LAudioClock >= 0 then
                        begin
                          // 使用绝对时间戳进行同步
                          LVideoPts := LFrame.pts * av_q2d(PPtrIdx(LFormatCtx.streams, LVideoStreamIndex).time_base);
                          LDelay := LVideoPts - LAudioClock;
                          if LDelay > 0.001 then
                            FStopEvent.WaitFor(round(LDelay * 1000 / FSpeed));
                        end
                        else
                        begin
                          // 基于性能计数器的手动同步
                          LExpectedMs := round(((LFrame.pts - LFirstPts) * av_q2d(PPtrIdx(LFormatCtx.streams, LVideoStreamIndex).time_base) * 1000) / FSpeed);
                          QueryPerformanceCounter(LCurrentTime);
                          LElapsedMs := round((LCurrentTime - LStartTime) * 1000 / LPerfFrequency);
                          if LExpectedMs > LElapsedMs then
                            FStopEvent.WaitFor(LExpectedMs - LElapsedMs);
                        end;
                      end;

                      if Terminated then Break;

                      if (LSwsCtx = nil) or (LFrameRGB = nil) or (LFrameRGB.data[0] = nil) or (LFrame.data[0] = nil) then
                        Break;

                      if (LFrame.linesize[0] > 0) and (LVideoHeight > 0) then
                      begin
                        sws_scale(LSwsCtx, @LFrame.data, @LFrame.linesize, 0, LVideoHeight, @LFrameRGB.data, @LFrameRGB.linesize);

                        if (LFrame.pts <> AV_NOPTS_VALUE) and (PPtrIdx(LFormatCtx.streams, LVideoStreamIndex).time_base.den > 0) then
                          LPtsSec := LFrame.pts * av_q2d(PPtrIdx(LFormatCtx.streams, LVideoStreamIndex).time_base)
                        else
                          LPtsSec := 0;

                        if Assigned(FVideoFrameCallback) and (LFrameRGB.data[0] <> nil) then
                          FVideoFrameCallback(LFrameRGB.data[0], LTargetWidth, LTargetHeight, LPtsSec, FUserData);
                      end;

                      Inc(LVideoFrameCount);
                      if (FMaxFrames > 0) and (LVideoFrameCount >= FMaxFrames) then
                      begin
                        LDecodingDone := True;
                        Break;
                      end;
                      if (FEndTime > 0) and (LPtsSec >= FEndTime) then
                      begin
                        LDecodingDone := True;
                        Break;
                      end;
                    finally
                      av_frame_unref(LFrame);
                    end;
                  end;
                end;
              end
              // --- Audio Decoding ---
              else if (LPacket.stream_index = LAudioStreamIndex) then
              begin
                LRet := avcodec_send_packet(LAudioCodecCtx, LPacket);
                if LRet >= 0 then
                begin
                  while (not Terminated) and (avcodec_receive_frame(LAudioCodecCtx, LFrame) = 0) do
                  begin
                    try
                      LOutNbSamples := av_rescale_rnd(swr_get_delay(LSwrCtx, LAudioCodecCtx.sample_rate) + LFrame.nb_samples, LOutSampleRate, LAudioCodecCtx.sample_rate, AV_ROUND_UP);
                      LAudioBuffer := nil;
                      av_samples_alloc(@LAudioBuffer, nil, LOutChannels, LOutNbSamples, LOutSampleFmt, 0);

                      try
                        LDestNbSamples := swr_convert(LSwrCtx, @LAudioBuffer, LOutNbSamples, @LFrame.data, LFrame.nb_samples);
                        if LDestNbSamples > 0 then
                        begin
                           if (LFrame.pts <> AV_NOPTS_VALUE) and (PPtrIdx(LFormatCtx.streams, LAudioStreamIndex).time_base.den > 0) then
                            LPtsSec := LFrame.pts * av_q2d(PPtrIdx(LFormatCtx.streams, LAudioStreamIndex).time_base)
                          else
                            LPtsSec := 0;

                          LAudioBufferSize := LDestNbSamples * LOutChannels * av_get_bytes_per_sample(LOutSampleFmt);
                          FAudioFrameCallback(LAudioBuffer, LAudioBufferSize, LOutSampleRate, LOutChannels, LPtsSec, FUserData);
                          if (FEndTime > 0) and (LPtsSec >= FEndTime) then
                          begin
                             LDecodingDone := True;
                             Break;
                          end;
                        end;
                      finally
                        if LAudioBuffer <> nil then
                          av_freep(@LAudioBuffer);
                      end;
                    finally
                      av_frame_unref(LFrame);
                    end;
                  end;
                end;
              end;
            finally
              av_packet_unref(LPacket);
            end;
            if (FMaxFrames > 0) and (LVideoFrameCount >= FMaxFrames) then Break;
            if LDecodingDone then Break;
          end;

          // Flush the decoders
          if (LVideoStreamIndex >= 0) then
          begin
            avcodec_send_packet(LVideoCodecCtx, nil);
            while (not Terminated) and (avcodec_receive_frame(LVideoCodecCtx, LFrame) = 0) do
            begin
              try
                sws_scale(LSwsCtx, @LFrame.data, @LFrame.linesize, 0, LVideoHeight, @LFrameRGB.data, @LFrameRGB.linesize);
                if (LFrame.pts <> AV_NOPTS_VALUE) and (PPtrIdx(LFormatCtx.streams, LVideoStreamIndex).time_base.den > 0) then
                  LPtsSec := LFrame.pts * av_q2d(PPtrIdx(LFormatCtx.streams, LVideoStreamIndex).time_base)
                else
                  LPtsSec := 0;
                FVideoFrameCallback(LFrameRGB.data[0], LTargetWidth, LTargetHeight, LPtsSec, FUserData);
              finally
                av_frame_unref(LFrame);
              end;
            end;
          end;

          if (LAudioStreamIndex >= 0) then
          begin
            avcodec_send_packet(LAudioCodecCtx, nil);
            while (not Terminated) and (avcodec_receive_frame(LAudioCodecCtx, LFrame) = 0) do
            begin
              try
                LOutNbSamples := av_rescale_rnd(swr_get_delay(LSwrCtx, LAudioCodecCtx.sample_rate) + LFrame.nb_samples, LOutSampleRate, LAudioCodecCtx.sample_rate, AV_ROUND_UP);
                LAudioBuffer := nil;
                av_samples_alloc(@LAudioBuffer, nil, LOutChannels, LOutNbSamples, LOutSampleFmt, 0);
                try
                  LDestNbSamples := swr_convert(LSwrCtx, @LAudioBuffer, LOutNbSamples, @LFrame.data, LFrame.nb_samples);
                  if LDestNbSamples > 0 then
                  begin
                    if (LFrame.pts <> AV_NOPTS_VALUE) and (PPtrIdx(LFormatCtx.streams, LAudioStreamIndex).time_base.den > 0) then
                      LPtsSec := LFrame.pts * av_q2d(PPtrIdx(LFormatCtx.streams, LAudioStreamIndex).time_base)
                    else
                      LPtsSec := 0;
                    LAudioBufferSize := LDestNbSamples * LOutChannels * av_get_bytes_per_sample(LOutSampleFmt);
                    FAudioFrameCallback(LAudioBuffer, LAudioBufferSize, LOutSampleRate, LOutChannels, LPtsSec, FUserData);
                  end;
                finally
                  if LAudioBuffer <> nil then
                    av_freep(@LAudioBuffer);
                end;
              finally
                av_frame_unref(LFrame);
              end;
            end;
          end;
          
        finally
          av_frame_free(@LFrame);
          av_packet_free(@LPacket);
        end;
      finally
        if Assigned(LVideoCodecCtx) then avcodec_free_context(@LVideoCodecCtx);
        if Assigned(LSwsCtx) then sws_freeContext(LSwsCtx);
        if Assigned(LVideoBuffer) then av_free(LVideoBuffer);
        if Assigned(LFrameRGB) then av_frame_free(@LFrameRGB);
        if Assigned(LAudioCodecCtx) then avcodec_free_context(@LAudioCodecCtx);
        if Assigned(LSwrCtx) then swr_free(@LSwrCtx);
        avformat_close_input(@LFormatCtx);
      end;
      
      if (not Terminated) and FLoopPlayback then
      begin
        if Assigned(FOnLoopCallback) then
          FOnLoopCallback;
        LShouldLoop := True;
        Sleep(10);
      end
      else
      begin
        Queue(DoFinished);
      end;
      
    except
      on E: Exception do
      begin
        FErrorMessage := '解码错误: ' + E.Message;
        Queue(DoError);
        Exit;
      end;
    end;
    
  until Terminated;
  
  FIsRunning := False;
  FResetEvent.SetEvent;
  CoUninitialize;
end;

procedure TVideoDecoderThread.DoFinished;
begin
  if Assigned(FCompletionCallback) then
    FCompletionCallback(FUserData);
end;

procedure TVideoDecoderThread.DoError;
begin
  if Assigned(FErrorCallback) then
    FErrorCallback(FErrorMessage, FUserData);
end;

{ TVideoFile }

constructor TVideoFile.Create(const AFilePath: string);
begin
  inherited Create;
  FFilePath := AFilePath;
  FInfoLoaded := False;
  FDecoderThread := nil;
  StartTime := 0;
  EndTime := 0;
  FAudioPlayer := nil;
  FAudioPlaybackEnabled := False;
  FMuted := False;
  FLoopPlayback := False;
  FAudioClockInitialized := False;
  FVideoSize.cx := 0;
  FVideoSize.cy := 0;
end;

destructor TVideoFile.Destroy;
begin
  Terminate;
  if Assigned(FDecoderThread) then
  begin
    // 在等待线程结束前，必须清除所有回调，特别是那些指向本对象(TVideoFile)
    // 方法的回调。这是为了防止线程在TVideoFile对象销毁过程中调用其方法，
    // 从而避免"使用已释放内存"的竞态条件。
    TVideoDecoderThread(FDecoderThread).FAudioFrameCallback := nil;
    TVideoDecoderThread(FDecoderThread).FGetAudioClockCallback := nil;
    TVideoDecoderThread(FDecoderThread).FOnLoopCallback := nil;
    TVideoDecoderThread(FDecoderThread).FCompletionCallback := nil;
    TVideoDecoderThread(FDecoderThread).FErrorCallback := nil;
    TVideoDecoderThread(FDecoderThread).FVideoFrameCallback := nil;

    TVideoDecoderThread(FDecoderThread).WaitFor;
    FreeAndNil(FDecoderThread);
  end;
  if Assigned(FAudioPlayer) then
    FAudioPlayer.Free;
  inherited;
end;

function TVideoFile.GetInfo: TVideoInfo;
begin
  if not FInfoLoaded then
    LoadVideoInfo;
  Result := FVideoInfo;
end;

procedure TVideoFile.Terminate;
begin
  if Assigned(FDecoderThread) then
  begin
    TVideoDecoderThread(FDecoderThread).Stop;
    // Don't nil FDecoderThread here, OnTerminate event will handle it.
  end;
  if Assigned(FAudioPlayer) then
    FAudioPlayer.Reset;
end;

procedure TVideoFile.LoadVideoInfo;
var
  AnsiFilePath: AnsiString;
  FormatCtx: PAVFormatContext;
  VideoCodec: PAVCodec;
  VideoStreamIndex: Integer;
  VideoStream: PAVStream;
  AudioStreamIndex: Integer;
  AudioStream: PAVStream;
  formatStr: string;
  formatList: TStringList;
  fileExt: string;
  preferredFormats: TStringList;
  i: Integer;
  bestFormat: string;
begin
  FillChar(FVideoInfo, SizeOf(FVideoInfo), 0);
  FVideoInfo.ErrorMessage := '';

  AnsiFilePath := AnsiString(UTF8Encode(FFilePath));
  FormatCtx := nil;
  // 分配 FormatContext
  FormatCtx := avformat_alloc_context();
  if not Assigned(FormatCtx) then
  begin
    FVideoInfo.ErrorMessage := '无法分配格式上下文';
    Exit;
  end;
  if avformat_open_input(@FormatCtx, PAnsiChar(AnsiFilePath), nil, nil) < 0 then
  begin
    avformat_free_context(FormatCtx);
    FVideoInfo.ErrorMessage := '无法打开文件: ' + FFilePath;
    Exit;
  end;
  try
    if avformat_find_stream_info(FormatCtx, nil) < 0 then
    begin
      FVideoInfo.ErrorMessage := '无法获取流信息';
      Exit;
    end;
    // 获取视频流
    VideoCodec := nil;
    VideoStreamIndex := av_find_best_stream(FormatCtx, AVMEDIA_TYPE_VIDEO, -1, -1, @VideoCodec, 0);
    FVideoInfo.HasVideo := VideoStreamIndex >= 0;
    if FVideoInfo.HasVideo then
    begin
      VideoStream := PPtrIdx(FormatCtx.streams, VideoStreamIndex);
      FVideoInfo.Width := VideoStream.codecpar.width;
      FVideoInfo.Height := VideoStream.codecpar.height;
      if (FVideoInfo.Width > 0) and (FVideoInfo.Height > 0) then
        FVideoInfo.Resolution := IntToStr(FVideoInfo.Width) + 'x' + IntToStr(FVideoInfo.Height)
      else
        FVideoInfo.Resolution := 'N/A';
      if Assigned(VideoCodec) then
        FVideoInfo.CodecName := string(VideoCodec.name)
      else
        FVideoInfo.CodecName := 'unknown';
      if VideoStream.avg_frame_rate.den > 0 then
        FVideoInfo.FrameRate := FormatFloat('0.##', VideoStream.avg_frame_rate.num / VideoStream.avg_frame_rate.den)
      else
        FVideoInfo.FrameRate := 'N/A';
    end
    else
    begin
      FVideoInfo.Width := 0;
      FVideoInfo.Height := 0;
      FVideoInfo.Resolution := 'N/A';
      FVideoInfo.CodecName := 'unknown';
      FVideoInfo.FrameRate := 'N/A';
    end;
    // 获取音频流
    AudioStreamIndex := av_find_best_stream(FormatCtx, AVMEDIA_TYPE_AUDIO, -1, -1, nil, 0);
    FVideoInfo.HasAudio := AudioStreamIndex >= 0;
    if FVideoInfo.HasAudio then
    begin
      AudioStream := PPtrIdx(FormatCtx.streams, AudioStreamIndex);
      FVideoInfo.AudioSampleRate := AudioStream.codecpar.sample_rate;
      FVideoInfo.AudioBitRate := AudioStream.codecpar.bit_rate;
      FVideoInfo.AudioChannels := AudioStream.codecpar.ch_layout.nb_channels;
    end
    else
    begin
      FVideoInfo.AudioSampleRate := 0;
      FVideoInfo.AudioBitRate := 0;
      FVideoInfo.AudioChannels := 0;
    end;
    // 获取时长和比特率
    if FormatCtx.duration <> AV_NOPTS_VALUE then
      FVideoInfo.Duration := FormatCtx.duration / AV_TIME_BASE
    else
      FVideoInfo.Duration := 0.0;
    FVideoInfo.BitRate := FormatCtx.bit_rate;
    // 获取文件格式
    if Assigned(FormatCtx.iformat) then
    begin
      formatStr := '';
      if Assigned(FormatCtx.iformat.extensions) then
        formatStr := string(FormatCtx.iformat.extensions);
      if Assigned(FormatCtx.iformat.name) then
      begin
        if formatStr <> '' then formatStr := formatStr + ',';
        formatStr := formatStr + string(FormatCtx.iformat.name);
      end;
      FVideoInfo.FileFormat := '';
      if formatStr <> '' then
      begin
        formatList := TStringList.Create;
        try
          formatList.Delimiter := ',';
          formatList.DelimitedText := LowerCase(formatStr);
          fileExt := LowerCase(Copy(ExtractFileExt(FFilePath), 2, MaxInt));
          if formatList.IndexOf(fileExt) > -1 then
            FVideoInfo.FileFormat := fileExt
          else if (fileExt = 'mkv') and (formatList.IndexOf('matroska') > -1) then
            FVideoInfo.FileFormat := 'mkv'
          else if (fileExt = 'wmv') and (formatList.IndexOf('asf') > -1) then
            FVideoInfo.FileFormat := 'wmv'
          else if (fileExt = 'mpg') and (formatList.IndexOf('mpeg') > -1) then
            FVideoInfo.FileFormat := 'mpg'
          else
          begin
            preferredFormats := TStringList.Create;
            try
              preferredFormats.Add('mp4');
              preferredFormats.Add('mkv');
              preferredFormats.Add('webm');
              preferredFormats.Add('avi');
              preferredFormats.Add('wmv');
              preferredFormats.Add('flv');
              preferredFormats.Add('mov');
              preferredFormats.Add('mpg');
              preferredFormats.Add('ts');
              for i := 0 to preferredFormats.Count - 1 do
              begin
                bestFormat := preferredFormats[i];
                if formatList.IndexOf(bestFormat) > -1 then
                begin
                  FVideoInfo.FileFormat := bestFormat;
                  Break;
                end;
              end;
            finally
              preferredFormats.Free;
            end;
          end;
        finally
          formatList.Free;
        end;
      end;
    end
    else
      FVideoInfo.FileFormat := '';
  finally
    avformat_close_input(@FormatCtx);
    FInfoLoaded := True;
  end;
end;

procedure TVideoFile.HandleAudioFrame(const AFrameData: Pointer; ADataSize: Cardinal; ASampleRate, AChannels: Integer; APtsSec: Double; AUserData: Pointer);
var
  FrameBytes: TBytes;
begin
  if not Assigned(FAudioPlayer) then
    FAudioPlayer := TAudioPlayer.Create;

  if not FAudioClockInitialized and (APtsSec > 0) then
  begin
    FAudioClockBasePts := APtsSec;
    QueryPerformanceCounter(FAudioClockStartTime);
    FAudioClockInitialized := True;
  end;

  if ADataSize > 0 then
  begin
    SetLength(FrameBytes, ADataSize);
    if not FMuted and (AFrameData <> nil) then
      Move(AFrameData^, FrameBytes[0], ADataSize)
    else
      FillChar(FrameBytes[0], ADataSize, 0);

    FAudioPlayer.Play(FrameBytes, ASampleRate, AChannels);
  end;
end;

function TVideoFile.GetAudioClock: Double;
var
  LCurrentTime, LPerfFrequency: Int64;
  LElapsed: Double;
begin
  Result := -1;
  if FAudioClockInitialized then
  begin
    QueryPerformanceCounter(LCurrentTime);
    QueryPerformanceFrequency(LPerfFrequency);
    if LPerfFrequency > 0 then
    begin
      LElapsed := (LCurrentTime - FAudioClockStartTime) / LPerfFrequency;
      Result := FAudioClockBasePts + LElapsed;
    end;
  end;
end;

procedure TVideoFile.ResetAudioState;
begin
  FAudioClockInitialized := False;
  if Assigned(FAudioPlayer) then
    FAudioPlayer.Reset;
end;

procedure TVideoFile.DecodeAllFramesAsync(AVideoFrameCallback: TVideoFrameCallback; AUserData: Pointer; ACompletionCallback: TDecodeCompletionCallback = nil; AErrorCallback: TDecodeErrorCallback = nil; MaxFrames: Integer = -1; ASpeed: Double = 1.0);
var
  AudioCallback: TAudioFrameCallback;
  GetAudioClockCallback: TGetAudioClockCallback;
  OnLoopCallback: TLoopCallback;
begin
  // An instance of TVideoFile should only handle one decoding task.
  if Assigned(FDecoderThread) then
  begin
    // 如果已经有解码线程在运行，我们将终止它并启动新的解码任务
    // 这比抛出异常更实用，允许用户在不创建新的TVideoFile实例的情况下切换视频
    ResetAndDecode(AVideoFrameCallback, AUserData, ACompletionCallback, AErrorCallback, MaxFrames, ASpeed);
    Exit;
  end;

  if FAudioPlaybackEnabled then
  begin
    AudioCallback := HandleAudioFrame;
    GetAudioClockCallback := GetAudioClock;
  end
  else
  begin
    AudioCallback := nil;
    GetAudioClockCallback := nil;
  end;

  if FLoopPlayback then
    OnLoopCallback := ResetAudioState
  else
    OnLoopCallback := nil;

  // Create and start a new thread for this decoding task.
  FDecoderThread := TVideoDecoderThread.Create(FFilePath, AVideoFrameCallback, AudioCallback, AUserData, ACompletionCallback, AErrorCallback, MaxFrames, ASpeed, StartTime, EndTime, FLoopPlayback, GetAudioClockCallback, OnLoopCallback, FVideoSize);
  TVideoDecoderThread(FDecoderThread).Start;
end;

procedure TVideoFile.Pause;
begin
  if Assigned(FDecoderThread) then
    TVideoDecoderThread(FDecoderThread).Pause;
end;

procedure TVideoFile.ResumePlay;
begin
  if Assigned(FDecoderThread) then
    TVideoDecoderThread(FDecoderThread).ResumePlay;
end;

procedure TVideoFile.ResetAndDecode(AVideoFrameCallback: TVideoFrameCallback; AUserData: Pointer;
  ACompletionCallback: TDecodeCompletionCallback = nil; AErrorCallback: TDecodeErrorCallback = nil;
  MaxFrames: Integer = -1; ASpeed: Double = 1.0);
var
  WaitStartTime: Cardinal;
  MaxWaitTime: Cardinal;
  ThreadTerminated: Boolean;
begin
  // 如果存在旧的解码线程，先终止它
  if Assigned(FDecoderThread) then
  begin
    // 停止线程
    TVideoDecoderThread(FDecoderThread).Stop;
    
    // 等待线程终止，但最多等待500毫秒
    WaitStartTime := GetTickCount;
    MaxWaitTime := 500; // 最多等待500毫秒
    ThreadTerminated := False;
    
    while (GetTickCount - WaitStartTime < MaxWaitTime) and (not ThreadTerminated) do
    begin
      ThreadTerminated := not TVideoDecoderThread(FDecoderThread).IsRunning;
      if not ThreadTerminated then
        Sleep(10); // 短暂等待，避免CPU占用
    end;
    
    // 如果线程仍未终止，强制释放（不推荐，但在超时情况下必要）
    if not ThreadTerminated then
    begin
      // 清除回调以避免在对象释放后调用
      TVideoDecoderThread(FDecoderThread).FAudioFrameCallback := nil;
      TVideoDecoderThread(FDecoderThread).FGetAudioClockCallback := nil;
      TVideoDecoderThread(FDecoderThread).FOnLoopCallback := nil;
      TVideoDecoderThread(FDecoderThread).FCompletionCallback := nil;
      TVideoDecoderThread(FDecoderThread).FErrorCallback := nil;
      TVideoDecoderThread(FDecoderThread).FVideoFrameCallback := nil;
    end;
    
    // 释放线程对象
    FreeAndNil(FDecoderThread);
  end;
  
  // 重置音频状态
  ResetAudioState;
  
  // 启动新的解码任务
  DecodeAllFramesAsync(AVideoFrameCallback, AUserData, ACompletionCallback, AErrorCallback, MaxFrames, ASpeed);
end;

end.

