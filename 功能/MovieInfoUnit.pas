{*******************************************************************************
  影片信息数据单元
  功能：提供影片信息的存储、解析和管理功能
  
  主要功能：
  - 影片基本信息的存储和访问（标题、演员、类型、剧情等）
  - NFO文件格式的XML解析和生成
  - 支持多种影片信息字段（标题、年份、评分、时长等）
  - 数组类型数据的字符串转换（演员、类型、国家等）
  - 临时文件管理和清理
  - 数据格式化和清理功能
  
  支持字段：
  - 标题、原始标题、年份
  - 演员、导演、类型、国家
  - 剧情简介、评分、分级、时长
  - 支持数组和字符串格式互转
  
  文件格式：
  - 基于XML的NFO文件格式
  - 临时文件存储在Data\Temp\Nfo目录
  
  Copyright (c) 2025 zotptptp
  Email: zoutp@qq.com
  All rights reserved.
*******************************************************************************}

unit MovieInfoUnit;

interface

uses
  SysUtils, Classes, IOUtils, NativeXml,
  Generics.Collections, CryptoUtils, System.StrUtils, FileHelpers;

type
  EMovieInfoError = class(Exception);

  TMovieInfo = class
  private
    FXml: TNativeXml;
    FFormatSettings: TFormatSettings;
    FTitle: string;
    FOriginalTitle: string;
    FYear: Integer;
    FGenres: TArray<string>;
    FDirectors: TArray<string>;
    FPlot: string;
    FActors: TArray<string>;
    FRating: Double;
    FMPAA: string;
    FRunTime: string;
    FCountrys: TArray<string>;
    const
      ROOT_NODE = 'movie';
      RATING_PATH = 'ratings/rating/value';

    function GetGenresText: string;
    function GetActorsText: string;
    function GetCountrysText: string;
    function GetDirectorsText: string;
    procedure EnsureDirectory(const FileName: string);
    function SafeStrToFloat(const Value: string): Double;
    procedure ProcessNodesToArray(const Path: string; var TargetArray: TArray<string>);
    function ProcessNode(const Path: string): string; // 处理XML节点

    // XML解析和保存
    procedure ParseFromXml(const FileName: string);
    procedure SaveToXml(const FileName: string);
  public
    constructor Create;
    destructor Destroy; override;

    // 属性
    property Title: string read FTitle write FTitle;
    property OriginalTitle: string read FOriginalTitle write FOriginalTitle;
    property Year: Integer read FYear write FYear;
    property Plot: string read FPlot write FPlot;
    property Actors: TArray<string> read FActors write FActors;
    property Genres: TArray<string> read FGenres write FGenres;
    property Director: TArray<string> read FDirectors write FDirectors;
    property Countrys: TArray<string> read FCountrys write FCountrys;
    property Rating: Double read FRating write FRating;
    property MPAA: string read FMPAA write FMPAA;
    property RunTime: string read FRunTime write FRunTime;
    property GenresText: string read GetGenresText;
    property ActorsText: string read GetActorsText;
    property CountrysText: string read GetCountrysText;
    property DirectorsText: string read GetDirectorsText;

    // 方法
    procedure SetStringToArray(const S: string; Delimiter: Char; var TargetArray: TArray<string>);
    procedure SetGenres(const S: string; Delimiter: Char = '/');
    procedure SetActors(const S: string; Delimiter: Char = '/');
    procedure SetDirectors(const S: string; Delimiter: Char = '/');
    procedure SetCountrys(const S: string; Delimiter: Char = '/');
    function CleanString(const Value: string): string;
    procedure AddGenre(const Genre: string);
    procedure AddActor(const Actor: string);
    function ArrayToString(const Arr: TArray<string>; Delimiter: Char = '/'): string;
    procedure SaveToFile(const FileName: string);
    procedure LoadFromFile(const FileName: string);
    class function CreateFromFile(const FileName: string): TMovieInfo;
  end;



function GetMovieInfo(const FilePath: string): TMovieInfo;
procedure DeleteTempInfo(const FilePath: string);
function TempFileExists(const FilePath: string): Boolean;

implementation

// 不再需要自定义的 TEMP_DIR 常量，使用 FileHelpers 中的常量
// const
//   TEMP_DIR = 'Data\Temp\Nfo';

{ TMovieInfo }

constructor TMovieInfo.Create;
begin
  inherited;
  FXml := TNativeXml.Create(nil);
  FXml.WriteOnDefault := True; // 强制写入所有字段，即使它们是默认值
  FXml.ExternalEncoding := seUTF8; // 使用UTF-8编码
  FXml.PreserveWhiteSpace := False;
  FXml.XmlFormat := xfReadable; // 设置XML格式为可读格式
  FFormatSettings := TFormatSettings.Create;
  FFormatSettings.DecimalSeparator := '.';
  FFormatSettings.ThousandSeparator := #0;
  FRating := -1;  // 初始化评分为-1，表示未评分
end;

destructor TMovieInfo.Destroy;
begin
  FXml.Free;
  inherited;
end;

procedure TMovieInfo.AddGenre(const Genre: string);
var
  Len: Integer;
begin
  Len := Length(FGenres);
  SetLength(FGenres, Len + 1);
  FGenres[Len] := Genre;
end;

procedure TMovieInfo.AddActor(const Actor: string);
var
  Len: Integer;
begin
  Len := Length(FActors);
  SetLength(FActors, Len + 1);
  FActors[Len] := Actor;
end;

function TMovieInfo.ArrayToString(const Arr: TArray<string>; Delimiter: Char = '/'): string;
var
  SL: TStringList;
  S: string;
begin
  SL := TStringList.Create;
  try
    SL.StrictDelimiter := True;
    SL.Delimiter := Delimiter;
    for S in Arr do
      SL.Add(S);
    Result := SL.DelimitedText;
  finally
    SL.Free;
  end;
end;

procedure TMovieInfo.EnsureDirectory(const FileName: string);
begin
  ForceDirectories(ExtractFilePath(FileName));
end;

function TMovieInfo.SafeStrToFloat(const Value: string): Double;
begin
  if Value = '' then
    Result := -1  // 节点不存在时返回-1
  else
    Result := StrToFloatDef(StringReplace(Value, ',', '.', [rfReplaceAll]), -1, FFormatSettings);
end;

 function TMovieInfo.ProcessNode(const Path: string): string;
var
  PathParts: TArray<string>;
  CurrentNode: TXmlNode;
  SL: TStringList;
  i: Integer;
begin
  Result := '';
  if not Assigned(FXml) or not Assigned(FXml.Root) then
    Exit;

  // 分割路径
  SL := TStringList.Create;
  try
    SL.Delimiter := '/';
    SL.StrictDelimiter := True;
    SL.DelimitedText := Path;
    SetLength(PathParts, SL.Count);
    for i := 0 to SL.Count - 1 do
      PathParts[i] := SL[i];
  finally
    SL.Free;
  end;

  if Length(PathParts) = 0 then Exit;

  // 遍历根节点
  CurrentNode := FXml.Root;
  for i := 0 to High(PathParts) do
  begin
    CurrentNode := CurrentNode.NodeByName(UTF8String(PathParts[i]));
    if not Assigned(CurrentNode) then
      Exit; // 未找到直接返回空
  end;

  // 返回节点值
  Result := CleanString(CurrentNode.ValueUnicode);
end;

procedure TMovieInfo.ProcessNodesToArray(const Path: string; var TargetArray: TArray<string>);
var
  ParentNodes, ChildNodes: TsdNodeList;
  i, j: Integer;
  PathParts: TArray<string>;
  CurrentNode: TXmlNode;
  SL: TStringList;
  Child: TXmlNode;
begin
  // 针对actor/name特殊处理
  if Path = 'actor/name' then
  begin
    ParentNodes := TsdNodeList.Create;
    try
      FXml.Root.FindNodes('actor', ParentNodes);
      for i := 0 to ParentNodes.Count - 1 do
      begin
        CurrentNode := ParentNodes[i] as TXmlNode;
        for j := 0 to CurrentNode.NodeCount - 1 do
        begin
          Child := CurrentNode.Nodes[j];
          if SameText(string(Child.NameUnicode), 'name') then
          begin
            SetLength(TargetArray, Length(TargetArray) + 1);
            TargetArray[High(TargetArray)] := CleanString(Child.ValueUnicode);
          end;
        end;
      end;
    finally
      ParentNodes.Free;
    end;
    Exit;
  end;
  // 其他路径保持原逻辑
  ParentNodes := TsdNodeList.Create;
  ChildNodes := TsdNodeList.Create;
  try
    SL := TStringList.Create;
    try
      SL.Delimiter := '/';
      SL.StrictDelimiter := True;
      SL.DelimitedText := Path;
      SetLength(PathParts, SL.Count);
      for i := 0 to SL.Count - 1 do
        PathParts[i] := SL[i];
    finally
      SL.Free;
    end;

    if Length(PathParts) = 0 then Exit;
    FXml.Root.FindNodes(UTF8String(PathParts[0]), ParentNodes);
    for i := 0 to ParentNodes.Count - 1 do
    begin
      CurrentNode := ParentNodes[i] as TXmlNode;
      if Length(PathParts) > 1 then
      begin
        for j := 1 to High(PathParts) do
        begin
          ChildNodes.Clear;
          CurrentNode.FindNodes(UTF8String(PathParts[j]), ChildNodes);
          if ChildNodes.Count > 0 then
            CurrentNode := ChildNodes[0] as TXmlNode
          else
          begin
            CurrentNode := nil;
            Break;
          end;
        end;
      end;
      if Assigned(CurrentNode) then
      begin
        SetLength(TargetArray, Length(TargetArray) + 1);
        TargetArray[High(TargetArray)] := CleanString(CurrentNode.ValueUnicode);
      end;
    end;
  finally
    ParentNodes.Free;
    ChildNodes.Free;
  end;
end;

procedure TMovieInfo.SetStringToArray(const S: string; Delimiter: Char; var TargetArray: TArray<string>);
var
  SL: TStringList;
  i: Integer;
begin
  if S = '' then
  begin
    SetLength(TargetArray, 0);
    Exit;
  end;

  SL := TStringList.Create;
  try
    SL.StrictDelimiter := True;
    SL.Delimiter := Delimiter;
    SL.DelimitedText := S;
    SetLength(TargetArray, SL.Count);
    for i := 0 to SL.Count - 1 do
      TargetArray[i] := Trim(SL[i]);
  finally
    SL.Free;
  end;
end;

procedure TMovieInfo.SetGenres(const S: string; Delimiter: Char);
begin
  SetStringToArray(S, Delimiter, FGenres);
end;

procedure TMovieInfo.SetActors(const S: string; Delimiter: Char);
begin
  SetStringToArray(S, Delimiter, FActors);
end;

procedure TMovieInfo.SetDirectors(const S: string; Delimiter: Char);
begin
  SetStringToArray(S, Delimiter, FDirectors);
end;

procedure TMovieInfo.SetCountrys(const S: string; Delimiter: Char);
begin
  SetStringToArray(S, Delimiter, FCountrys);
end;

function TMovieInfo.CleanString(const Value: string): string;
begin
  Result := StringReplace(Value, #13, '', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
end;

procedure TMovieInfo.ParseFromXml(const FileName: string);
begin
  FXml.LoadFromFile(FileName);

  if not SameText(FXml.Root.NameUnicode, ROOT_NODE) then
    raise EMovieInfoError.Create('Invalid XML structure');

  FTitle := CleanString(FXml.Root.ReadUnicodeString('title'));
  FOriginalTitle := CleanString(FXml.Root.ReadUnicodeString('originaltitle'));
  FYear := FXml.Root.ReadInteger('year');
  FPlot := CleanString(FXml.Root.ReadUnicodeString('plot'));
  FRating := SafeStrToFloat(ProcessNode(RATING_PATH));
  FMPAA := FXml.Root.ReadUnicodeString('mpaa');
  FRunTime := FXml.Root.ReadUnicodeString('runtime');

  // 初始化数组
  SetLength(FDirectors, 0);
  SetLength(FGenres, 0);
  SetLength(FActors, 0);
  SetLength(FCountrys, 0);

  ProcessNodesToArray('director', FDirectors);
  ProcessNodesToArray('genre', FGenres);
  ProcessNodesToArray('actor/name', FActors);
  ProcessNodesToArray('country', FCountrys);
end;

procedure TMovieInfo.SaveToXml(const FileName: string);
var
  i: Integer;
  RootNode: TXmlNode;
begin
  FXml.Clear;
  if not Assigned(FXml.Root) then
    raise EMovieInfoError.Create('XML根节点丢失，无法保存');

  FXml.Root.Name := ROOT_NODE;
  RootNode := FXml.Root;

  with RootNode do
  begin
    // 标题是必需的，如果没有标题则使用文件名
    if FTitle = '' then
      FTitle := 'Unknown Title';
    WriteUnicodeString('title', FTitle);
    
    // 其他字段可选保存
    if FOriginalTitle <> '' then
      WriteUnicodeString('originaltitle', FOriginalTitle);
    
    // 只有当年份有效时才保存
    if FYear > 0 then
      WriteInteger('year', FYear);
      
    if FPlot <> '' then
      WriteUnicodeString('plot', FPlot);
    
    // 只有当评分有效时才创建评分结构
    if FRating >= 0 then
    begin
      with NodeNew('ratings') do
        with NodeNew('rating') do
        begin
          AttributeAdd('default', 'false');
          AttributeAdd('max', '10');
          AttributeAdd('name', 'themoviedb');
          WriteUnicodeString('value', FloatToStr(FRating, FFormatSettings));
          WriteUnicodeString('votes', '0');
        end;
    end;

    if FMPAA <> '' then
      WriteUnicodeString('mpaa', FMPAA);
      
    if FRunTime <> '' then
      WriteUnicodeString('runtime', FRunTime);

    // 只有当数组不为空时才保存
    for i := 0 to High(FDirectors) do
      WriteUnicodeString('director', FDirectors[i]);

    for i := 0 to High(FGenres) do
      NodeNew('genre').ValueUnicode := FGenres[i];

    for i := 0 to High(FActors) do
      with NodeNew('actor') do
        WriteUnicodeString('name', FActors[i]);

    for i := 0 to High(FCountrys) do
      NodeNew('country').ValueUnicode := FCountrys[i];
  end;

  EnsureDirectory(FileName);
  FXml.SaveToFile(FileName);
end;

procedure TMovieInfo.LoadFromFile(const FileName: string);
begin
  try
    ParseFromXml(FileName);
  except
    on E: Exception do
      raise EMovieInfoError.CreateFmt('解析失败 [%s]: %s',
        [ExtractFileName(FileName), E.Message]);
  end;
end;

class function TMovieInfo.CreateFromFile(const FileName: string): TMovieInfo;
begin
  Result := TMovieInfo.Create;
  try
    Result.LoadFromFile(FileName);
  except
    FreeAndNil(Result);
    raise;
  end;
end;

procedure TMovieInfo.SaveToFile(const FileName: string);
begin
  try
    SaveToXml(FileName);
  except
    on E: Exception do
      raise EMovieInfoError.CreateFmt('保存失败 [%s]: %s',
        [ExtractFileName(FileName), E.Message]);
  end;
end;

function TMovieInfo.GetGenresText: string;
begin
  Result := ArrayToString(FGenres);
end;

function TMovieInfo.GetActorsText: string;
begin
  Result := ArrayToString(FActors);
end;

function TMovieInfo.GetCountrysText: string;
begin
  Result := ArrayToString(FCountrys);
end;

function TMovieInfo.GetDirectorsText: string;
begin
  Result := ArrayToString(FDirectors);
end;

function GetMovieInfo(const FilePath: string): TMovieInfo;
var
  TempFile, SourceFile: string;
begin
  Result := TMovieInfo.Create;

  // 使用 FileHelpers 中的统一函数获取临时 NFO 路径
  TempFile := GetTempNfoPath(FilePath);
  if TempFileExists(FilePath) then
  begin
    try
      Result.LoadFromFile(TempFile);
      Exit;
    except
      // 临时文件损坏，尝试源文件
      Result.FRating := -1;  // 临时文件损坏时评分为-1
    end;
  end;

  // 读取原始文件
  SourceFile := ChangeFileExt(FilePath, '.nfo');
  if FileExists(SourceFile) then
  begin
    try
      // 直接复制原始nfo文件到临时目录，保留所有数据
      if not DirectoryExists(ExtractFilePath(TempFile)) then
        ForceDirectories(ExtractFilePath(TempFile));
      TFile.Copy(SourceFile, TempFile, True);
      
      // 解析文件以获取基本信息
      Result.LoadFromFile(SourceFile);
    except
      on E: Exception do
      begin
        if Result.Title = '' then
          Result.Title := TPath.GetFileNameWithoutExtension(FilePath);
        Result.FRating := -1;  // 解析失败时评分为-1
      end;
    end;
  end
  else
  begin
    Result.Title := TPath.GetFileNameWithoutExtension(FilePath);
    Result.FRating := -1;  // 确保没有nfo文件时评分为-1
  end;
end;

// 使用 FileHelpers 中的统一函数检查临时文件是否存在
function TempFileExists(const FilePath: string): Boolean;
begin
  Result := FileExists(GetTempNfoPath(FilePath));
end;

// 使用 FileHelpers 中的统一函数删除临时文件
procedure DeleteTempInfo(const FilePath: string);
begin
  DeleteFile(GetTempNfoPath(FilePath));
end;


end.

