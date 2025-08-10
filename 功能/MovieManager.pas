{*******************************************************************************
  影片数据库管理单元
  功能：提供基于SQLite的影片信息数据库管理功能
  
  主要功能：
  - 影片信息的增删改查操作
  - 支持按演员、类型、关键词搜索
  - 影片标题更新和重命名
  - 批量影片导入和管理
  - 关联数据管理（演员、类型表）
  - 数据库索引优化和性能提升
  - 线程安全的数据库操作
  
  数据库结构：
  - MovieCollection：主表（文件路径、标题、剧情、评分等）
  - MovieActors：演员关联表
  - MovieGenres：类型关联表
  
  支持操作状态：
  - 查询、插入、删除、更新等操作状态跟踪
  - 重复记录检测和处理
  - 错误状态管理和回调通知
  
  Copyright (c) 2025 zotptptp
  Email: zoutp@qq.com
  All rights reserved.
*******************************************************************************}

unit MovieManager;

interface

uses
  Windows, SysUtils, System.SyncObjs, System.Generics.Collections,
  Classes, SQLite3, SQLite3Wrap, IOUtils, MovieInfoUnit;

type
  /// <summary>
  /// 电影数据库操作状态
  /// </summary>
  TMovieOperationStatus = (mosQuerySuccess,         // 查询成功
    mosInsertSuccess,        // 插入成功
    mosInsertFailed,         // 插入失败
    mosInsertDuplicate,     // 插入重复（记录已存在）
    mosDeleteSuccess,       // 删除成功
    mosDeleteFailed,        // 删除失败
    mosUpdateTitleSuccess,
    mosUpdateTitleFailed,
    mosDeleteNotFound,      // 删除时记录不存在
    mosActorQuerySuccess,   // 演员查询成功
    mosActorNotFound,       // 演员未找到
    mosGenreQuerySuccess,   // 类型查询成功
    mosGenreNotFound,       // 类型未找到
    mosKeywordQuerySuccess, // 关键字查询成功
    mosKeywordNotFound,     // 关键字未找到
    mosUnknownError         // 未知错误
  );


  TMovieOperationCallback = reference to procedure(const FilePath: string; const MovieTitle: string; Status: TMovieOperationStatus; IsBatchComplete: Boolean);

  TMovieSQLManager = class(TObject)
  private
    FDatabase: TSQLite3Database;
    FDatabaseLock: TCriticalSection;
    FOperationCallback: TMovieOperationCallback;

    // 预编译语句缓存
    FCheckExistsStmt: TSQLite3Statement;
    FInsertStmt: TSQLite3Statement;
    FSelectAllStmt: TSQLite3Statement;
    FDeleteStmt: TSQLite3Statement;
    FSelectActorsStmt: TSQLite3Statement;
    FSelectGenresStmt: TSQLite3Statement;
    FKeywordSearchStmt: TSQLite3Statement;
    FUpdateTitleStmt: TSQLite3Statement;
    FGetMovieIDStmt: TSQLite3Statement;
    FCountStmt: TSQLite3Statement; // 新增：统计影片数量的预编译语句

    function GetMovieInfo(const FilePath: string): TMovieInfo;
    procedure InitializeDatabase;
    procedure PrepareStatements;
    procedure FreeStatements;
    procedure NotifyCallback(const FilePath, Title: string; Status: TMovieOperationStatus; IsComplete: Boolean);
    function RecordExists(const FilePath: string): Boolean;
    function GetMovieID(const FilePath: string): Integer;
    procedure CreateIndexes;
    procedure InsertRelatedData(const TableName, ValueField: string; const MovieID: Integer; Values: TArray<string>);

    // 数据库结构常量
    const
      TABLE_NAME = 'MovieCollection';
      ACTORS_TABLE = 'MovieActors';
      GENRES_TABLE = 'MovieGenres';
      MOVIE_ID_FIELD = 'MovieID';
      FILE_PATH_FIELD = 'FilePath';
      TITLE_FIELD = 'FileTitle';
      PLOT_FIELD = 'Plot';
      RATING_FIELD = 'Rating';
      ADDED_TIME_FIELD = 'AddedTime';
      ACTOR_NAME_FIELD = 'ActorName';
      GENRE_NAME_FIELD = 'GenreName';

  public
    constructor Create(const DatabaseFile: string);
    destructor Destroy; override;

    procedure AddMovie(const FilePath: string);
    procedure AddMovies(const FilePaths: TArray<string>);
    function RemoveMovie(const FilePath: string): Boolean;
    procedure GetAllMovies;
    procedure GetAllMoviesByActor(const ActorName: string);
    procedure GetAllMoviesByGenre(const GenreName: string);
    procedure SearchByKeyword(const Keyword: string);
    procedure UpdateMovieTitle(const FilePath: string; const NewTitle: string);
    procedure SetOperationCallback(Callback: TMovieOperationCallback);
    function GetMovieCount: Integer; // 新增：获取影片总数
  end;

implementation

{ TMovieSQLManager }

constructor TMovieSQLManager.Create(const DatabaseFile: string);
var
  NeedCreateNew: Boolean;
begin
  FDatabaseLock := TCriticalSection.Create;
  FDatabase := TSQLite3Database.Create;
  try
    NeedCreateNew := not FileExists(DatabaseFile);
    FDatabase.Open(DatabaseFile);
    if NeedCreateNew then
      InitializeDatabase;
    PrepareStatements;
    CreateIndexes;
  except
    FreeStatements;
    FDatabase.Free;
    FDatabaseLock.Free;
    raise;
  end;
end;

destructor TMovieSQLManager.Destroy;
begin
  FDatabaseLock.Acquire;
  try
    FreeStatements;
    FDatabase.Close;
    FDatabase.Free;
  finally
    FDatabaseLock.Release;
    FDatabaseLock.Free;
  end;
  inherited;
end;

procedure TMovieSQLManager.InitializeDatabase;
const
  CREATE_TABLE_SQL = 'CREATE TABLE IF NOT EXISTS %s (' +
    '%s INTEGER PRIMARY KEY AUTOINCREMENT, ' + // MovieID
    '%s TEXT NOT NULL UNIQUE, ' +              // FilePath
    '%s TEXT NOT NULL, ' +                     // FileTitle
    '%s TEXT, ' +                              // Plot
    '%s REAL, ' +                              // Rating
    '%s DATETIME NOT NULL)';                   // AddedTime

  CREATE_ACTORS_TABLE_SQL = 'CREATE TABLE IF NOT EXISTS %s (' +
    '%s INTEGER NOT NULL, ' +                  // MovieID
    '%s TEXT NOT NULL, ' +                     // ActorName
    'PRIMARY KEY (%s, %s), ' +                 // Composite key
    'FOREIGN KEY (%s) REFERENCES %s(%s) ON DELETE CASCADE)';

  CREATE_GENRES_TABLE_SQL = 'CREATE TABLE IF NOT EXISTS %s (' +
    '%s INTEGER NOT NULL, ' +                  // MovieID
    '%s TEXT NOT NULL, ' +                     // GenreName
    'PRIMARY KEY (%s, %s), ' +                 // Composite key
    'FOREIGN KEY (%s) REFERENCES %s(%s) ON DELETE CASCADE)';
begin
  FDatabase.Execute(Format(CREATE_TABLE_SQL, [TABLE_NAME, MOVIE_ID_FIELD, FILE_PATH_FIELD, TITLE_FIELD, PLOT_FIELD, RATING_FIELD, ADDED_TIME_FIELD]));
  FDatabase.Execute(Format(CREATE_ACTORS_TABLE_SQL, [ACTORS_TABLE, MOVIE_ID_FIELD, ACTOR_NAME_FIELD, MOVIE_ID_FIELD, ACTOR_NAME_FIELD, MOVIE_ID_FIELD, TABLE_NAME, MOVIE_ID_FIELD]));
  FDatabase.Execute(Format(CREATE_GENRES_TABLE_SQL, [GENRES_TABLE, MOVIE_ID_FIELD, GENRE_NAME_FIELD, MOVIE_ID_FIELD, GENRE_NAME_FIELD, MOVIE_ID_FIELD, TABLE_NAME, MOVIE_ID_FIELD]));
end;

procedure TMovieSQLManager.CreateIndexes;
begin
  // 为关联表创建索引以提高查询性能
  FDatabase.Execute(Format('CREATE INDEX IF NOT EXISTS idx_%s_%s ON %s(%s)', [ACTORS_TABLE, MOVIE_ID_FIELD, ACTORS_TABLE, MOVIE_ID_FIELD]));
  FDatabase.Execute(Format('CREATE INDEX IF NOT EXISTS idx_%s_%s ON %s(%s)', [GENRES_TABLE, MOVIE_ID_FIELD, GENRES_TABLE, MOVIE_ID_FIELD]));
  FDatabase.Execute(Format('CREATE INDEX IF NOT EXISTS idx_actors_name ON %s(%s)', [ACTORS_TABLE, ACTOR_NAME_FIELD]));
  FDatabase.Execute(Format('CREATE INDEX IF NOT EXISTS idx_genres_name ON %s(%s)', [GENRES_TABLE, GENRE_NAME_FIELD]));
  FDatabase.Execute(Format('CREATE INDEX IF NOT EXISTS idx_movie_title ON %s(%s)', [TABLE_NAME, TITLE_FIELD]));
  FDatabase.Execute(Format('CREATE INDEX IF NOT EXISTS idx_movie_path ON %s(%s)', [TABLE_NAME, FILE_PATH_FIELD]));
end;

procedure TMovieSQLManager.PrepareStatements;
begin
  FCheckExistsStmt := FDatabase.Prepare(Format('SELECT 1 FROM %s WHERE %s = ? LIMIT 1', [TABLE_NAME, FILE_PATH_FIELD]));
  FInsertStmt := FDatabase.Prepare(Format('INSERT INTO %s (%s, %s, %s, %s, %s) VALUES (?, ?, ?, ?, ?)', [TABLE_NAME, FILE_PATH_FIELD, TITLE_FIELD, PLOT_FIELD, RATING_FIELD, ADDED_TIME_FIELD]));
  FSelectAllStmt := FDatabase.Prepare(Format('SELECT %s, %s, %s, %s, %s FROM %s', [MOVIE_ID_FIELD, FILE_PATH_FIELD, TITLE_FIELD, PLOT_FIELD, RATING_FIELD, TABLE_NAME]));
  FDeleteStmt := FDatabase.Prepare(Format('DELETE FROM %s WHERE %s = ?', [TABLE_NAME, FILE_PATH_FIELD]));
  FSelectActorsStmt := FDatabase.Prepare(Format('SELECT %s FROM %s WHERE %s = ?', [ACTOR_NAME_FIELD, ACTORS_TABLE, MOVIE_ID_FIELD]));
  FSelectGenresStmt := FDatabase.Prepare(Format('SELECT %s FROM %s WHERE %s = ?', [GENRE_NAME_FIELD, GENRES_TABLE, MOVIE_ID_FIELD]));
  FKeywordSearchStmt := FDatabase.Prepare('SELECT DISTINCT m.' + MOVIE_ID_FIELD + ', m.' + FILE_PATH_FIELD + ', m.' + TITLE_FIELD + ' ' +
    'FROM ' + TABLE_NAME + ' m ' +
    'LEFT JOIN ' + ACTORS_TABLE + ' a ON m.' + MOVIE_ID_FIELD + ' = a.' + MOVIE_ID_FIELD + ' ' +
    'WHERE m.' + FILE_PATH_FIELD + ' LIKE ? OR ' +
    'm.' + TITLE_FIELD + ' LIKE ? OR ' +
    'a.' + ACTOR_NAME_FIELD + ' LIKE ? ' +
    'ORDER BY m.' + TITLE_FIELD);
  FUpdateTitleStmt := FDatabase.Prepare(Format('UPDATE %s SET %s = ? WHERE %s = ?', [TABLE_NAME, TITLE_FIELD, FILE_PATH_FIELD]));
  FGetMovieIDStmt := FDatabase.Prepare(Format('SELECT %s FROM %s WHERE %s = ?', [MOVIE_ID_FIELD, TABLE_NAME, FILE_PATH_FIELD]));
  FCountStmt := FDatabase.Prepare(Format('SELECT COUNT(*) FROM %s', [TABLE_NAME]));
end;

procedure TMovieSQLManager.FreeStatements;
begin
  FreeAndNil(FCheckExistsStmt);
  FreeAndNil(FInsertStmt);
  FreeAndNil(FSelectAllStmt);
  FreeAndNil(FDeleteStmt);
  FreeAndNil(FSelectActorsStmt);
  FreeAndNil(FSelectGenresStmt);
  FreeAndNil(FUpdateTitleStmt);
  FreeAndNil(FGetMovieIDStmt);
  FreeAndNil(FCountStmt);
end;

function TMovieSQLManager.GetMovieID(const FilePath: string): Integer;
begin
  Result := -1;
  FDatabaseLock.Acquire;
  try
    FGetMovieIDStmt.Reset;
    FGetMovieIDStmt.BindText(1, FilePath);
    if FGetMovieIDStmt.Step = SQLITE_ROW then
      Result := FGetMovieIDStmt.ColumnInt(0);
    FGetMovieIDStmt.Reset;
  finally
    FDatabaseLock.Release;
  end;
end;

function TMovieSQLManager.GetMovieInfo(const FilePath: string): TMovieInfo;
var
  MovieInfo: TMovieInfo;
  Actors, Genres: TStringList;
  Stmt: TSQLite3Statement;
  HasSQLData: Boolean;
  MovieID: Integer;
begin
  MovieInfo := TMovieInfo.Create;
  FDatabaseLock.Acquire;
  try
    MovieID := GetMovieID(FilePath);
    if MovieID = -1 then
    begin
      FreeAndNil(MovieInfo);
      MovieInfo := MovieInfoUnit.GetMovieInfo(FilePath);
      Result := MovieInfo;
      Exit;
    end;
    // First try to get data from SQL database
    Stmt := FDatabase.Prepare(Format('SELECT %s, %s, %s FROM %s WHERE %s = ?', [TITLE_FIELD, PLOT_FIELD, RATING_FIELD, TABLE_NAME, FILE_PATH_FIELD]));
    try
      Stmt.BindText(1, FilePath);
      if Stmt.Step = SQLITE_ROW then
      begin
        MovieInfo.Title := Stmt.ColumnText(0);
        MovieInfo.Plot := Stmt.ColumnText(1);
        MovieInfo.Rating := Stmt.ColumnDouble(2);

        // Get actors and set ActorsText
        FSelectActorsStmt.BindInt(1, MovieID);
        Actors := TStringList.Create;
        try
          while FSelectActorsStmt.Step = SQLITE_ROW do
            Actors.Add(FSelectActorsStmt.ColumnText(0));
          MovieInfo.Actors := Actors.ToStringArray;
          FSelectActorsStmt.Reset;
        finally
          Actors.Free;
        end;

        // Get genres and set GenresText
        FSelectGenresStmt.BindInt(1, MovieID);
        Genres := TStringList.Create;
        try
          while FSelectGenresStmt.Step = SQLITE_ROW do
            Genres.Add(FSelectGenresStmt.ColumnText(0));
          MovieInfo.Genres := Genres.ToStringArray;
          FSelectGenresStmt.Reset;
        finally
          Genres.Free;
        end;
      end;
    finally
      Stmt.Free;
    end;

    // Check if all required fields are empty in SQL data
    HasSQLData := (MovieInfo.Title <> '') and (MovieInfo.Plot <> '') and (MovieInfo.Rating <> 0) and (Length(MovieInfo.Actors) > 0) and (Length(MovieInfo.Genres) > 0);

    // If no complete data found in SQL, fall back to MovieInfoUnit
    if not HasSQLData then
    begin
      FreeAndNil(MovieInfo);
      MovieInfo := MovieInfoUnit.GetMovieInfo(FilePath);
    end;

    Result := MovieInfo;
  finally
    FDatabaseLock.Release;
  end;
end;

procedure TMovieSQLManager.InsertRelatedData(const TableName, ValueField: string; const MovieID: Integer; Values: TArray<string>);
var
  Stmt: TSQLite3Statement;
  Value: string;
begin
  FDatabaseLock.Acquire;
  try
    Stmt := FDatabase.Prepare(Format('INSERT OR IGNORE INTO %s (%s, %s) VALUES (?, ?)', [TableName, MOVIE_ID_FIELD, ValueField]));
    try
      for Value in Values do
      begin
        Stmt.BindInt(1, MovieID);
        Stmt.BindText(2, Value);
        Stmt.StepAndReset;
      end;
    finally
      Stmt.Free;
    end;
  finally
    FDatabaseLock.Release;
  end;
end;

function TMovieSQLManager.RecordExists(const FilePath: string): Boolean;
begin
  FDatabaseLock.Acquire;
  try
    FCheckExistsStmt.Reset;
    FCheckExistsStmt.BindText(1, FilePath);
    Result := (FCheckExistsStmt.Step = SQLITE_ROW);
    FCheckExistsStmt.Reset;
  finally
    FDatabaseLock.Release;
  end;
end;

procedure TMovieSQLManager.AddMovie(const FilePath: string);
var
  MovieTitle, Plot: string;
  Status: TMovieOperationStatus;
  MovieInfo: TMovieInfo;
  Rating: Double;
begin
  FDatabaseLock.Acquire;
  try
    if RecordExists(FilePath) then
    begin
      Status := mosInsertDuplicate;
      MovieTitle := TPath.GetFileNameWithoutExtension(FilePath);
      // MovieID := GetMovieID(FilePath); // 删除未用赋值
    end
    else
    begin
      MovieInfo := GetMovieInfo(FilePath);
      try
        if Assigned(MovieInfo) then
        begin
          MovieTitle := MovieInfo.Title;
          Plot := MovieInfo.Plot;
          Rating := MovieInfo.Rating;
        end
        else
        begin
          MovieTitle := '';
          Plot := '';
          Rating := 0.0;
        end;

        FInsertStmt.BindText(1, FilePath);
        FInsertStmt.BindText(2, MovieTitle);
        FInsertStmt.BindText(3, Plot);
        FInsertStmt.BindDouble(4, Rating);
        FInsertStmt.BindDouble(5, Now);
        FInsertStmt.StepAndReset;
        Status := mosInsertSuccess;
        // MovieID := GetMovieID(FilePath); // 只在InsertRelatedData时用到即可

        if Assigned(MovieInfo) then
        begin
          InsertRelatedData(ACTORS_TABLE, ACTOR_NAME_FIELD, GetMovieID(FilePath), MovieInfo.Actors);
          InsertRelatedData(GENRES_TABLE, GENRE_NAME_FIELD, GetMovieID(FilePath), MovieInfo.Genres);
        end;
      except
        Status := mosInsertFailed;
        // MovieID := -1;
      end;
      FreeAndNil(MovieInfo);
    end;

    if MovieTitle = '' then
      MovieTitle := TPath.GetFileNameWithoutExtension(FilePath);
    NotifyCallback(FilePath, MovieTitle, Status, True);
  finally
    FDatabaseLock.Release;
  end;
end;

procedure TMovieSQLManager.AddMovies(const FilePaths: TArray<string>);
var
  FilePath: string;
begin
  FDatabaseLock.Acquire;
  try
    FDatabase.Execute('BEGIN TRANSACTION');
    try
      for FilePath in FilePaths do
        AddMovie(FilePath);
      FDatabase.Execute('COMMIT');
    except
      FDatabase.Execute('ROLLBACK');
      raise;
    end;
  finally
    FDatabaseLock.Release;
  end;
end;

function TMovieSQLManager.RemoveMovie(const FilePath: string): Boolean;
var
  Status: TMovieOperationStatus;
begin
  Result := False;
  FDatabaseLock.Acquire;
  try
    if not RecordExists(FilePath) then
      Status := mosDeleteNotFound
    else
    begin
      try
        FDeleteStmt.BindText(1, FilePath);
        FDeleteStmt.StepAndReset;
        Status := mosDeleteSuccess;
        Result := True;
      except
        Status := mosDeleteFailed;
        Result := False;
      end;
    end;
    NotifyCallback(FilePath, '', Status, True);
  finally
    FDatabaseLock.Release;
  end;
end;

procedure TMovieSQLManager.GetAllMovies;
var
  Title, FilePath: string;
begin
  FDatabaseLock.Acquire;
  try
    while FSelectAllStmt.Step = SQLITE_ROW do
    begin
      FilePath := FSelectAllStmt.ColumnText(1);
      Title := FSelectAllStmt.ColumnText(2);
      if Title = '' then
      begin
        Title := TPath.GetFileNameWithoutExtension(FilePath);
      end;
      NotifyCallback(FilePath, Title, mosQuerySuccess, False);
    end;
    FSelectAllStmt.Reset;
    NotifyCallback('', '', mosQuerySuccess, True);
  finally
    FDatabaseLock.Release;
  end;
end;

procedure TMovieSQLManager.GetAllMoviesByActor(const ActorName: string);
var
  Stmt: TSQLite3Statement;
  FilePath, Title: string;
  ErrorMessage: string;
begin
  FDatabaseLock.Acquire;
  try
    try
      Stmt := FDatabase.Prepare(Format('SELECT m.%s, m.%s, m.%s FROM %s m ' +
        'JOIN %s a ON m.%s = a.%s ' +
        'WHERE a.%s = ?', [MOVIE_ID_FIELD, FILE_PATH_FIELD, TITLE_FIELD, TABLE_NAME, ACTORS_TABLE, MOVIE_ID_FIELD, MOVIE_ID_FIELD, ACTOR_NAME_FIELD]));
      try
        Stmt.BindText(1, ActorName);
        while Stmt.Step = SQLITE_ROW do
        begin
          FilePath := Stmt.ColumnText(1);
          Title := Stmt.ColumnText(2);
          if Title = '' then
            Title := TPath.GetFileNameWithoutExtension(FilePath);
          NotifyCallback(FilePath, Title, mosActorQuerySuccess, False);
        end;
        
        // 设置标志指示检索完成
        NotifyCallback('', '', mosActorNotFound, True);
      finally
        Stmt.Free;
      end;
    except
      on E: Exception do
      begin
        ErrorMessage := Format('演员查询错误: [%s] %s 在单元: %s', 
          [E.ClassName, E.Message, 'MovieManager.GetAllMoviesByActor']);
        // 使用标题字段传递错误信息
        NotifyCallback('ERROR', ErrorMessage, mosUnknownError, True);
        // 在后台线程中不应重新引发异常，因为它会导致应用程序崩溃
        // raise Exception.Create(ErrorMessage);
      end;
    end;
  finally
    FDatabaseLock.Release;
  end;
end;

procedure TMovieSQLManager.GetAllMoviesByGenre(const GenreName: string);
var
  Stmt: TSQLite3Statement;
  FilePath, Title: string;
begin
  FDatabaseLock.Acquire;
  try
    Stmt := FDatabase.Prepare(Format('SELECT m.%s, m.%s, m.%s FROM %s m ' +
      'JOIN %s g ON m.%s = g.%s ' +
      'WHERE g.%s = ?', [MOVIE_ID_FIELD, FILE_PATH_FIELD, TITLE_FIELD, TABLE_NAME, GENRES_TABLE, MOVIE_ID_FIELD, MOVIE_ID_FIELD, GENRE_NAME_FIELD]));
    try
      Stmt.BindText(1, GenreName);
      while Stmt.Step = SQLITE_ROW do
      begin
        FilePath := Stmt.ColumnText(1);
        Title := Stmt.ColumnText(2);
        if Title = '' then
          Title := TPath.GetFileNameWithoutExtension(FilePath);
        NotifyCallback(FilePath, Title, mosGenreQuerySuccess, False);
      end;
      NotifyCallback('', '', mosGenreNotFound, True);
    finally
      Stmt.Free;
    end;
  finally
    FDatabaseLock.Release;
  end;
end;

procedure TMovieSQLManager.SearchByKeyword(const Keyword: string);
var
  SearchPattern: string;
  FilePath, Title: string;
  Found: Boolean;
begin
  FDatabaseLock.Acquire;
  try
    // 准备搜索模式 (前后添加通配符)
    SearchPattern := '%' + Keyword + '%';

    FKeywordSearchStmt.BindText(1, SearchPattern); // 路径匹配
    FKeywordSearchStmt.BindText(2, SearchPattern); // 标题匹配
    FKeywordSearchStmt.BindText(3, SearchPattern); // 演员名匹配

    Found := False;
    while FKeywordSearchStmt.Step = SQLITE_ROW do
    begin
      FilePath := FKeywordSearchStmt.ColumnText(1);
      Title := FKeywordSearchStmt.ColumnText(2);
      if Title = '' then
        Title := TPath.GetFileNameWithoutExtension(FilePath);
      NotifyCallback(FilePath, Title, mosKeywordQuerySuccess, False);
      Found := True;
    end;

    FKeywordSearchStmt.Reset;

    if not Found then
      NotifyCallback('', '', mosKeywordNotFound, True)
    else
      NotifyCallback('', '', mosKeywordQuerySuccess, True);
  finally
    FDatabaseLock.Release;
  end;
end;

procedure TMovieSQLManager.SetOperationCallback(Callback: TMovieOperationCallback);
begin
  FOperationCallback := Callback;
end;

procedure TMovieSQLManager.UpdateMovieTitle(const FilePath, NewTitle: string);
var
  Status: TMovieOperationStatus;
begin
  FDatabaseLock.Acquire;
  try
    FUpdateTitleStmt.Reset;  // 确保语句重置
    try
      FUpdateTitleStmt.BindText(1, NewTitle);
      FUpdateTitleStmt.BindText(2, FilePath);

      if (FUpdateTitleStmt.Step = SQLITE_DONE) and (sqlite3_changes(FDatabase.Handle) > 0) then
        Status := mosUpdateTitleSuccess
      else
        Status := mosUpdateTitleFailed;

      FUpdateTitleStmt.Reset;
    except
      on E: Exception do
      begin
        if Assigned(FUpdateTitleStmt) then
          FUpdateTitleStmt.Reset;
        Status := mosUpdateTitleFailed;
        NotifyCallback(FilePath, NewTitle, Status, True);
        raise;
      end;
    end;

    NotifyCallback(FilePath, NewTitle, Status, True);
  finally
    FDatabaseLock.Release;
  end;
end;

procedure TMovieSQLManager.NotifyCallback(const FilePath, Title: string; Status: TMovieOperationStatus; IsComplete: Boolean);
var
  LFilePath, LTitle: string;
begin
  if Assigned(FOperationCallback) then
  begin
    // 将数据复制到局部变量，以安全地传递给匿名方法
    // 因为原始参数在方法退出后可能失效
    LFilePath := FilePath;
    LTitle := Title;
        FOperationCallback(LFilePath, LTitle, Status, IsComplete);
  end;
end;

function TMovieSQLManager.GetMovieCount: Integer;
begin
  FDatabaseLock.Acquire;
  try
    FCountStmt.Reset;
    if FCountStmt.Step = SQLITE_ROW then
      Result := FCountStmt.ColumnInt(0)
    else
      Result := 0;
  finally
    FDatabaseLock.Release;
  end;
end;

end.
