unit CryptoUtils;

interface

uses
  Windows, SysUtils, Classes;

// 通过定义 USE_WIDE_CRYPTOAPI 宏来使用 Wide (Unicode) 版本的 CryptoAPI
// 如果不定义 USE_WIDE_CRYPTOAPI，则默认使用 ANSI 版本（通常处理 UTF8 编码的数据）
// 可以在项目选项 Conditional defines 中定义 USE_WIDE_CRYPTOAPI
// 例如: USE_WIDE_CRYPTOAPI

{$IFNDEF USE_WIDE_CRYPTOAPI}
  // 如果没有定义 USE_WIDE_CRYPTOAPI，则定义 USE_ANSI_CRYPTOAPI
  {$DEFINE USE_ANSI_CRYPTOAPI}
{$ENDIF}

function SHA256Hash(const Input: string): string;

implementation

type
  HCRYPTPROV = ULONG_PTR;
  PHCRYPTPROV = ^HCRYPTPROV;
  HCRYPTHASH = ULONG_PTR;
  PHCRYPTHASH = ^HCRYPTHASH;

const
  PROV_RSA_AES        = 24;
  CRYPT_VERIFYCONTEXT = $F0000000;
  CALG_SHA_256        = $0000800C;
  HP_HASHVAL          = 2;

{$IFDEF USE_ANSI_CRYPTOAPI}
const
  // 定义 ANSI 版本函数名称常量
  CryptAcquireContextName = 'CryptAcquireContextA';
  CryptCreateHashName     = 'CryptCreateHash';
  CryptHashDataName       = 'CryptHashData';
  CryptGetHashParamName   = 'CryptGetHashParam';
  CryptDestroyHashName    = 'CryptDestroyHash';
  CryptReleaseContextName = 'CryptReleaseContext';

// 定义 ANSI 版本 CryptAcquireContext 的函数指针类型
type
  TCryptAcquireContextFunc = function(phProv: PHCRYPTPROV; pszContainer: PAnsiChar;
    pszProvider: PAnsiChar; dwProvType: DWORD; dwFlags: DWORD): BOOL; stdcall;

{$ENDIF}

{$IFDEF USE_WIDE_CRYPTOAPI}
const
  // 定义 Wide 版本函数名称常量
  CryptAcquireContextName = 'CryptAcquireContextW';
  // Note: Some CryptoAPI functions do not have 'W' suffix even if they handle Wide chars,
  // or the A/W distinction is only for string parameters like CryptAcquireContext.
  // For Hash functions, the input data (pbData) is PByte and is length-specified,
  // so the function name is the same for A and W contexts, but the *data* you pass
  // must match the context's expectation (bytes for A context, words for W context).
  // However, CryptAcquireContext does have A/W variants. We'll load the base names
  // for the hash operations as they are generic PByte interfaces.
  CryptCreateHashName     = 'CryptCreateHash';
  CryptHashDataName       = 'CryptHashData';
  CryptGetHashParamName   = 'CryptGetHashParam';
  CryptDestroyHashName    = 'CryptDestroyHash';
  CryptReleaseContextName = 'CryptReleaseContext';


// 定义 Wide 版本 CryptAcquireContext 的函数指针类型
type
  TCryptAcquireContextFunc = function(phProv: PHCRYPTPROV; pszContainer: PWideChar;
    pszProvider: PWideChar; dwProvType: DWORD; dwFlags: DWORD): BOOL; stdcall;

{$ENDIF}

// 声明函数指针变量，CryptAcquireContext 使用条件定义的类型
var
  hAdvapi32: HMODULE = 0;

var
  _CryptAcquireContext: TCryptAcquireContextFunc; // 使用条件类型

  // 以下函数的签名对 A/W 上下文是通用（PByte 数据）
  _CryptCreateHash: function(hProv: HCRYPTPROV; Algid: Cardinal; hKey: HCRYPTHASH;
    dwFlags: DWORD; phHash: PHCRYPTHASH): BOOL; stdcall;

  _CryptHashData: function(hHash: HCRYPTHASH; pbData: PByte; dwDataLen: DWORD;
    dwFlags: DWORD): BOOL; stdcall;

  _CryptGetHashParam: function(hHash: HCRYPTHASH; dwParam: DWORD; pbData: PByte;
    pdwDataLen: PDWORD; dwFlags: DWORD): BOOL; stdcall;

  _CryptDestroyHash: function(hHash: HCRYPTHASH): BOOL; stdcall;

  _CryptReleaseContext: function(hProv: HCRYPTPROV; dwFlags: DWORD): BOOL; stdcall;


// 兼容旧版本的错误处理
procedure RaiseCryptoError(const FuncName: string);
var
  LastError: DWORD;
begin
  LastError := GetLastError;
  // 包含失败的函数名称以便调试
  Raise Exception.CreateFmt('CryptoAPI Error in %s: 0x%.8x', [FuncName, LastError]);
end;

procedure InitCryptoAPI;
begin
  if hAdvapi32 = 0 then
  begin
    hAdvapi32 := LoadLibrary('advapi32.dll');
    if hAdvapi32 = 0 then RaiseCryptoError('LoadLibrary(advapi32.dll)');

    // 使用条件编译定义的函数名称常量加载函数地址
    @_CryptAcquireContext := GetProcAddress(hAdvapi32, CryptAcquireContextName);
    @_CryptCreateHash := GetProcAddress(hAdvapi32, CryptCreateHashName);
    @_CryptHashData := GetProcAddress(hAdvapi32, CryptHashDataName);
    @_CryptGetHashParam := GetProcAddress(hAdvapi32, CryptGetHashParamName);
    @_CryptDestroyHash := GetProcAddress(hAdvapi32, CryptDestroyHashName);
    @_CryptReleaseContext := GetProcAddress(hAdvapi32, CryptReleaseContextName);

    // 检查所有必要的函数是否成功加载
    if not Assigned(_CryptAcquireContext) or
       not Assigned(_CryptCreateHash) or
       not Assigned(_CryptHashData) or
       not Assigned(_CryptGetHashParam) or
       not Assigned(_CryptDestroyHash) or
       not Assigned(_CryptReleaseContext) then
    begin
       // 查找哪个函数加载失败并报告更详细的错误
       if not Assigned(_CryptAcquireContext) then RaiseCryptoError(CryptAcquireContextName);
       if not Assigned(_CryptCreateHash) then RaiseCryptoError(CryptCreateHashName);
       if not Assigned(_CryptHashData) then RaiseCryptoError(CryptHashDataName);
       if not Assigned(_CryptGetHashParam) then RaiseCryptoError(CryptGetHashParamName);
       if not Assigned(_CryptDestroyHash) then RaiseCryptoError(CryptDestroyHashName);
       if not Assigned(_CryptReleaseContext) then RaiseCryptoError(CryptReleaseContextName);
    end;
  end;
end;

function SHA256Hash(const Input: string): string;
var
  hProv: HCRYPTPROV;
  hHash: HCRYPTHASH;
{$IFDEF USE_ANSI_CRYPTOAPI}
  // 在 ANSI 模式下，通常传入 UTF-8 编码的字节序列
  Data: UTF8String;
{$ENDIF}
{$IFDEF USE_WIDE_CRYPTOAPI}
  // 在 Wide 模式下，传入 UTF-16 编码的字节序列（Delphi 的 string）
  Data: string;
{$ENDIF}
  DataPointer: PByte;
  DataLength: DWORD;
  Hash: array[0..31] of Byte;
  HashSize: DWORD;
  i: Integer;
begin
  Result := '';
  InitCryptoAPI;

{$IFDEF USE_ANSI_CRYPTOAPI}
  // 将输入字符串转换为 UTF-8 编码的字节序列
  Data := UTF8Encode(Input);
  DataPointer := PByte(Data);
  DataLength := Length(Data); // Length of AnsiString/UTF8String is byte count
{$ENDIF}

{$IFDEF USE_WIDE_CRYPTOAPI}
  // 直接使用输入字符串（UTF-16），获取其字节指针和字节长度
  Data := Input;
  DataPointer := PByte(Data);
  DataLength := Length(Data) * SizeOf(WideChar); // Length of string/WideString is char count, need byte count
{$ENDIF}

  // CryptAcquireContext 参数 pszContainer 和 pszProvider 在此处传入 nil
  // 这适用于 ANSI 和 Wide 版本
  if not _CryptAcquireContext(@hProv, nil, nil, PROV_RSA_AES, CRYPT_VERIFYCONTEXT) then
    RaiseCryptoError(CryptAcquireContextName);

  try
    if not _CryptCreateHash(hProv, CALG_SHA_256, 0, 0, @hHash) then
      RaiseCryptoError(CryptCreateHashName);

    try
      // 使用条件处理后的 DataPointer 和 DataLength
      if not _CryptHashData(hHash, DataPointer, DataLength, 0) then
        RaiseCryptoError(CryptHashDataName);

      HashSize := SizeOf(Hash);
      if not _CryptGetHashParam(hHash, HP_HASHVAL, @Hash[0], @HashSize, 0) then
        RaiseCryptoError(CryptGetHashParamName);

      // 将哈希结果格式化为十六进制字符串
      for i := 0 to High(Hash) do
        Result := Result + Format('%.2x', [Hash[i]]);
    finally
      _CryptDestroyHash(hHash);
    end;
  finally
    _CryptReleaseContext(hProv, 0);
  end;
end;

initialization
  hAdvapi32 := 0;

finalization
  if hAdvapi32 <> 0 then
    FreeLibrary(hAdvapi32);

end.
