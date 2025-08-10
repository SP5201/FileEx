unit MovieJsonUnit;

interface

uses
  System.SysUtils, System.Generics.Collections, SuperObject, System.Types;

type
  // 电影类型记录
  TGenre = record
    Id: Integer;       // 类型ID
    Name: string;      // 类型名称
  end;

  // 所属系列记录
  TBelongsToCollection = record
    Id: Integer;           // 系列ID
    Name: string;          // 系列名称
    PosterPath: string;    // 系列海报路径
    BackdropPath: string;  // 系列背景图路径
  end;

  // 制作公司记录
  TProductionCompany = record
    Id: Integer;          // 公司ID
    LogoPath: string;     // 公司Logo路径
    Name: string;         // 公司名称
    OriginCountry: string;// 公司所在国家
  end;

  // 制作国家记录
  TProductionCountry = record
    Iso3166_1: string;    // ISO 3166-1国家代码
    Name: string;         // 国家名称
  end;

  // 语言记录
  TSpokenLanguage = record
    EnglishName: string;  // 英文语言名称
    Iso639_1: string;     // ISO 639-1语言代码
    Name: string;         // 语言名称
  end;

  // 演员记录
  TActor = record
    Id: Integer;         // 演员ID
    Name: string;        // 演员姓名
    Character: string;   // 饰演角色
    ProfilePath: string; // 演员头像路径
  end;

  // 电影详细信息记录
  TMovieDetails = record
    Adult: Boolean;                  // 是否成人内容
    BackdropPath: string;            // 背景图路径
    BelongsToCollection: TBelongsToCollection; // 所属系列信息
    Budget: Int64;                   // 预算(美元)
    Genres: TList<TGenre>;           // 电影类型列表
    Homepage: string;                // 官方网站
    Id: Integer;                     // 电影ID
    ImdbId: string;                  // IMDB ID
    OriginCountry: TList<string>;    // 原产国家列表
    OriginalLanguage: string;        // 原始语言
    OriginalTitle: string;           // 原始标题
    Plot: string;                // 剧情简介
    Popularity: Double;              // 受欢迎程度
    PosterPath: string;              // 海报路径
    ProductionCompanies: TList<TProductionCompany>; // 制作公司列表
    ProductionCountries: TList<TProductionCountry>;  // 制作国家列表
    ReleaseDate: string;             // 发布日期
    Revenue: Int64;                  // 收入(美元)
    Runtime: Integer;                // 片长(分钟)
    SpokenLanguages: TList<TSpokenLanguage>; // 语言列表
    Status: string;                  // 状态(已上映/未上映等)
    Tagline: string;                 // 宣传语
    Title: string;                   // 标题
    Video: Boolean;                  // 是否有视频
    VoteAverage: Double;             // 平均评分
    VoteCount: Integer;              // 评分人数
    Cast: TList<TActor>;        // 演员列表

    // 初始化记录中的动态数组
    procedure Initialize;
    // 释放记录中的动态数组
    procedure Finalize;
  end;

  // 基础电影信息记录(用于搜索结果)
  TMovie = record
  public
    Adult: Boolean;          // 是否成人内容
    BackdropPath: string;    // 背景图路径
    GenreIds: TList<Integer>; // 类型ID列表
    Id: Integer;             // 电影ID
    OriginalLanguage: string; // 原始语言
    OriginalTitle: string;   // 原始标题
    Overview: string;        // 剧情简介
    Popularity: Double;      // 受欢迎程度
    PosterPath: string;      // 海报路径
    ReleaseDate: string;     // 发布日期
    Title: string;           // 标题
    Video: Boolean;          // 是否有视频
    VoteAverage: Double;     // 平均评分
    VoteCount: Integer;      // 评分人数
  end;

  // 电影搜索结果页类
  TMovieSearchPage = class
  public
    Page: Integer;           // 当前页码
    Results: TList<TMovie>;  // 电影结果列表
    TotalPages: Integer;     // 总页数
    TotalResults: Integer;   // 总结果数

    constructor Create;
    destructor Destroy; override;

    // 从JSON字符串创建搜索结果页
    class function FromJson(const AJson: string): TMovieSearchPage;
    // 从JSON对象创建单个电影记录
    class function MovieFromJson(const AJson: ISuperObject): TMovie;
    // 从JSON字符串创建电影详细信息记录
    class function MovieDetailsFromJson(const AJson: string): TMovieDetails;
  end;

implementation

{ TMovieDetails }

// 初始化TMovieDetails记录中的动态数组
procedure TMovieDetails.Initialize;
begin
  Genres := TList<TGenre>.Create;
  OriginCountry := TList<string>.Create;
  ProductionCompanies := TList<TProductionCompany>.Create;
  ProductionCountries := TList<TProductionCountry>.Create;
  SpokenLanguages := TList<TSpokenLanguage>.Create;
  Cast := TList<TActor>.Create;

  // 初始化所属系列字段
  BelongsToCollection.Id := 0;
  BelongsToCollection.Name := '';
  BelongsToCollection.PosterPath := '';
  BelongsToCollection.BackdropPath := '';
end;

// 释放TMovieDetails记录中的动态数组
procedure TMovieDetails.Finalize;
begin
  Genres.Free;
  OriginCountry.Free;
  ProductionCompanies.Free;
  ProductionCountries.Free;
  SpokenLanguages.Free;
  Cast.Free;
end;

{ TMovieSearchPage }

// 从JSON对象创建单个电影记录
class function TMovieSearchPage.MovieFromJson(const AJson: ISuperObject): TMovie;
var
  LGenreIdObj: ISuperObject;
  LGenreIdsArrayObj: ISuperObject;
  LBackdropPathObj: ISuperObject;
  i: Integer;
begin
  Result.Adult := AJson.B['adult'];

  // 处理可能为null的backdrop_path字段
  LBackdropPathObj := AJson.O['backdrop_path'];
  if Assigned(LBackdropPathObj) and (LBackdropPathObj.DataType <> stNull) then
    Result.BackdropPath := LBackdropPathObj.AsString
  else
    Result.BackdropPath := '';

  // 初始化并填充类型ID列表
  Result.GenreIds := TList<Integer>.Create;
  LGenreIdsArrayObj := AJson.O['genre_ids'];
  if Assigned(LGenreIdsArrayObj) and (LGenreIdsArrayObj.DataType = stArray) then
  begin
    if Assigned(LGenreIdsArrayObj.AsArray) then
    begin
      for i := 0 to LGenreIdsArrayObj.AsArray.Length - 1 do
      begin
        LGenreIdObj := LGenreIdsArrayObj.AsArray.O[i];
        if Assigned(LGenreIdObj) then
        begin
          Result.GenreIds.Add(LGenreIdObj.AsInteger);
        end;
      end;
    end;
  end;

  // 填充其他基本字段
  Result.Id := AJson.I['id'];
  Result.OriginalLanguage := AJson.S['original_language'];
  Result.OriginalTitle := AJson.S['original_title'];
  Result.Overview := AJson.S['overview'];
  Result.Popularity := AJson.D['popularity'];
  Result.PosterPath := AJson.S['poster_path'];
  Result.ReleaseDate := AJson.S['release_date'];
  Result.Title := AJson.S['title'];
  Result.Video := AJson.B['video'];
  Result.VoteAverage := AJson.D['vote_average'];
  Result.VoteCount := AJson.I['vote_count'];
end;

// 构造函数
constructor TMovieSearchPage.Create;
begin
  Results := TList<TMovie>.Create;
end;

// 析构函数
destructor TMovieSearchPage.Destroy;
begin
  Results.Free;
  inherited;
end;

// 从JSON字符串创建搜索结果页
class function TMovieSearchPage.FromJson(const AJson: string): TMovieSearchPage;
var
  LJsonObj, LMovieJson: ISuperObject;
  LResultsArrayObj: ISuperObject;
  i: Integer;
begin
  Result := TMovieSearchPage.Create;
  LJsonObj := SO(AJson);

  // 检查JSON对象是否有效
  if not Assigned(LJsonObj) or not ObjectIsType(LJsonObj, stObject) then
    Exit;

  // 填充分页信息
  Result.Page := LJsonObj.I['page'];
  Result.TotalPages := LJsonObj.I['total_pages'];
  Result.TotalResults := LJsonObj.I['total_results'];

  // 处理电影结果数组
  LResultsArrayObj := LJsonObj.O['results'];
  if Assigned(LResultsArrayObj) and (LResultsArrayObj.DataType = stArray) then
  begin
    if Assigned(LResultsArrayObj.AsArray) then
    begin
      for i := 0 to LResultsArrayObj.AsArray.Length - 1 do
      begin
        LMovieJson := LResultsArrayObj.AsArray.O[i];
        if Assigned(LMovieJson) then
          Result.Results.Add(TMovieSearchPage.MovieFromJson(LMovieJson));
      end;
    end;
  end;
end;

// 从JSON字符串创建电影详细信息记录
class function TMovieSearchPage.MovieDetailsFromJson(const AJson: string): TMovieDetails;
var
  LJsonObj, LSubObj, LItemObj: ISuperObject;
  LArrayObj: ISuperObject;
  i: Integer;
  LGenre: TGenre;
  LProdCompany: TProductionCompany;
  LProdCountry: TProductionCountry;
  LSpokenLang: TSpokenLanguage;
  LActor: TActor;
  LCreditsObj, LCastArrayObj: ISuperObject;
begin
  Result.Initialize; // 初始化所有动态数组

  LJsonObj := SO(AJson);

  // 检查JSON对象是否有效
  if not Assigned(LJsonObj) or not ObjectIsType(LJsonObj, stObject) then
    Exit;

  // 填充基本信息
  Result.Adult := LJsonObj.B['adult'];

  // 处理可能为null的backdrop_path
  LSubObj := LJsonObj.O['backdrop_path'];
  if Assigned(LSubObj) and (LSubObj.DataType <> stNull) then
    Result.BackdropPath := LSubObj.AsString
  else
    Result.BackdropPath := '';

  // 处理所属系列信息
  LSubObj := LJsonObj.O['belongs_to_collection'];
  if Assigned(LSubObj) and (LSubObj.DataType = stObject) then
  begin
    Result.BelongsToCollection.Id := LSubObj.I['id'];
    Result.BelongsToCollection.Name := LSubObj.S['name'];
    Result.BelongsToCollection.PosterPath := LSubObj.S['poster_path'];
    Result.BelongsToCollection.BackdropPath := LSubObj.S['backdrop_path'];
  end;

  Result.Budget := LJsonObj.I['budget'];

  // 处理电影类型数组
  LArrayObj := LJsonObj.O['genres'];
  if Assigned(LArrayObj) and (LArrayObj.DataType = stArray) then
  begin
    if Assigned(LArrayObj.AsArray) then
    begin
      for i := 0 to LArrayObj.AsArray.Length - 1 do
      begin
        LItemObj := LArrayObj.AsArray.O[i];
        if Assigned(LItemObj) then
        begin
          LGenre.Id := LItemObj.I['id'];
          LGenre.Name := LItemObj.S['name'];
          Result.Genres.Add(LGenre);
        end;
      end;
    end;
  end;

  // 填充其他基本信息
  Result.Homepage := LJsonObj.S['homepage'];
  Result.Id := LJsonObj.I['id'];

  // 处理可能为null的imdb_id
  LSubObj := LJsonObj.O['imdb_id'];
  if Assigned(LSubObj) and (LSubObj.DataType <> stNull) then
    Result.ImdbId := LSubObj.AsString
  else
    Result.ImdbId := '';

  // 处理原产国家数组
  LArrayObj := LJsonObj.O['origin_country'];
  if Assigned(LArrayObj) and (LArrayObj.DataType = stArray) then
  begin
    if Assigned(LArrayObj.AsArray) then
    begin
      for i := 0 to LArrayObj.AsArray.Length - 1 do
      begin
        LItemObj := LArrayObj.AsArray.O[i];
        if Assigned(LItemObj) then
        begin
          Result.OriginCountry.Add(LItemObj.AsString);
        end;
      end;
    end;
  end;

  // 填充其他基本信息
  Result.OriginalLanguage := LJsonObj.S['original_language'];
  Result.OriginalTitle := LJsonObj.S['original_title'];
  Result.Plot := LJsonObj.S['overview'];
  Result.Popularity := LJsonObj.D['popularity'];
  Result.PosterPath := LJsonObj.S['poster_path'];

  // 处理制作公司数组
  LArrayObj := LJsonObj.O['production_companies'];
  if Assigned(LArrayObj) and (LArrayObj.DataType = stArray) then
  begin
    if Assigned(LArrayObj.AsArray) then
    begin
      for i := 0 to LArrayObj.AsArray.Length - 1 do
      begin
        LItemObj := LArrayObj.AsArray.O[i];
        if Assigned(LItemObj) then
        begin
          LProdCompany.Id := LItemObj.I['id'];
          LProdCompany.LogoPath := LItemObj.S['logo_path'];
          LProdCompany.Name := LItemObj.S['name'];
          LProdCompany.OriginCountry := LItemObj.S['origin_country'];
          Result.ProductionCompanies.Add(LProdCompany);
        end;
      end;
    end;
  end;

  // 处理制作国家数组
  LArrayObj := LJsonObj.O['production_countries'];
  if Assigned(LArrayObj) and (LArrayObj.DataType = stArray) then
  begin
    if Assigned(LArrayObj.AsArray) then
    begin
      for i := 0 to LArrayObj.AsArray.Length - 1 do
      begin
        LItemObj := LArrayObj.AsArray.O[i];
        if Assigned(LItemObj) then
        begin
          LProdCountry.Iso3166_1 := LItemObj.S['iso_3166_1'];
          LProdCountry.Name := LItemObj.S['name'];
          Result.ProductionCountries.Add(LProdCountry);
        end;
      end;
    end;
  end;

  // 填充其他基本信息
  Result.ReleaseDate := LJsonObj.S['release_date'];
  Result.Revenue := LJsonObj.I['revenue'];
  Result.Runtime := LJsonObj.I['runtime'];

  // 处理语言数组
  LArrayObj := LJsonObj.O['spoken_languages'];
  if Assigned(LArrayObj) and (LArrayObj.DataType = stArray) then
  begin
    if Assigned(LArrayObj.AsArray) then
    begin
      for i := 0 to LArrayObj.AsArray.Length - 1 do
      begin
        LItemObj := LArrayObj.AsArray.O[i];
        if Assigned(LItemObj) then
        begin
          LSpokenLang.EnglishName := LItemObj.S['english_name'];
          LSpokenLang.Iso639_1 := LItemObj.S['iso_639_1'];
          LSpokenLang.Name := LItemObj.S['name'];
          Result.SpokenLanguages.Add(LSpokenLang);
        end;
      end;
    end;
  end;

  // 填充其他基本信息
  Result.Status := LJsonObj.S['status'];
  Result.Tagline := LJsonObj.S['tagline'];
  Result.Title := LJsonObj.S['title'];
  Result.Video := LJsonObj.B['video'];
  Result.VoteAverage := LJsonObj.D['vote_average'];
  Result.VoteCount := LJsonObj.I['vote_count'];

  // 处理演员表信息
  LCreditsObj := LJsonObj.O['credits'];
  if Assigned(LCreditsObj) and (LCreditsObj.DataType = stObject) then
  begin
    LCastArrayObj := LCreditsObj.O['cast'];
    if Assigned(LCastArrayObj) and (LCastArrayObj.DataType = stArray) then
    begin
      if Assigned(LCastArrayObj.AsArray) then
      begin
        for i := 0 to LCastArrayObj.AsArray.Length - 1 do
        begin
          LItemObj := LCastArrayObj.AsArray.O[i];
          if Assigned(LItemObj) then
          begin
            LActor.Id := LItemObj.I['id'];
            LActor.Name := LItemObj.S['name'];
            LActor.Character := LItemObj.S['character'];
            LSubObj := LItemObj.O['profile_path']; // profile_path可能为null
            if Assigned(LSubObj) and (LSubObj.DataType <> stNull) then
              LActor.ProfilePath := LSubObj.AsString
            else
              LActor.ProfilePath := '';
            Result.Cast.Add(LActor);
          end;
        end;
      end;
    end;
  end;
end;

end.

