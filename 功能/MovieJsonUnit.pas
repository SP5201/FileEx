unit MovieJsonUnit;

interface

uses
  System.SysUtils, System.Generics.Collections, SuperObject, System.Types;

type
  // ��Ӱ���ͼ�¼
  TGenre = record
    Id: Integer;       // ����ID
    Name: string;      // ��������
  end;

  // ����ϵ�м�¼
  TBelongsToCollection = record
    Id: Integer;           // ϵ��ID
    Name: string;          // ϵ������
    PosterPath: string;    // ϵ�к���·��
    BackdropPath: string;  // ϵ�б���ͼ·��
  end;

  // ������˾��¼
  TProductionCompany = record
    Id: Integer;          // ��˾ID
    LogoPath: string;     // ��˾Logo·��
    Name: string;         // ��˾����
    OriginCountry: string;// ��˾���ڹ���
  end;

  // �������Ҽ�¼
  TProductionCountry = record
    Iso3166_1: string;    // ISO 3166-1���Ҵ���
    Name: string;         // ��������
  end;

  // ���Լ�¼
  TSpokenLanguage = record
    EnglishName: string;  // Ӣ����������
    Iso639_1: string;     // ISO 639-1���Դ���
    Name: string;         // ��������
  end;

  // ��Ա��¼
  TActor = record
    Id: Integer;         // ��ԱID
    Name: string;        // ��Ա����
    Character: string;   // ���ݽ�ɫ
    ProfilePath: string; // ��Աͷ��·��
  end;

  // ��Ӱ��ϸ��Ϣ��¼
  TMovieDetails = record
    Adult: Boolean;                  // �Ƿ��������
    BackdropPath: string;            // ����ͼ·��
    BelongsToCollection: TBelongsToCollection; // ����ϵ����Ϣ
    Budget: Int64;                   // Ԥ��(��Ԫ)
    Genres: TList<TGenre>;           // ��Ӱ�����б�
    Homepage: string;                // �ٷ���վ
    Id: Integer;                     // ��ӰID
    ImdbId: string;                  // IMDB ID
    OriginCountry: TList<string>;    // ԭ�������б�
    OriginalLanguage: string;        // ԭʼ����
    OriginalTitle: string;           // ԭʼ����
    Plot: string;                // ������
    Popularity: Double;              // �ܻ�ӭ�̶�
    PosterPath: string;              // ����·��
    ProductionCompanies: TList<TProductionCompany>; // ������˾�б�
    ProductionCountries: TList<TProductionCountry>;  // ���������б�
    ReleaseDate: string;             // ��������
    Revenue: Int64;                  // ����(��Ԫ)
    Runtime: Integer;                // Ƭ��(����)
    SpokenLanguages: TList<TSpokenLanguage>; // �����б�
    Status: string;                  // ״̬(����ӳ/δ��ӳ��)
    Tagline: string;                 // ������
    Title: string;                   // ����
    Video: Boolean;                  // �Ƿ�����Ƶ
    VoteAverage: Double;             // ƽ������
    VoteCount: Integer;              // ��������
    Cast: TList<TActor>;        // ��Ա�б�

    // ��ʼ����¼�еĶ�̬����
    procedure Initialize;
    // �ͷż�¼�еĶ�̬����
    procedure Finalize;
  end;

  // ������Ӱ��Ϣ��¼(�����������)
  TMovie = record
  public
    Adult: Boolean;          // �Ƿ��������
    BackdropPath: string;    // ����ͼ·��
    GenreIds: TList<Integer>; // ����ID�б�
    Id: Integer;             // ��ӰID
    OriginalLanguage: string; // ԭʼ����
    OriginalTitle: string;   // ԭʼ����
    Overview: string;        // ������
    Popularity: Double;      // �ܻ�ӭ�̶�
    PosterPath: string;      // ����·��
    ReleaseDate: string;     // ��������
    Title: string;           // ����
    Video: Boolean;          // �Ƿ�����Ƶ
    VoteAverage: Double;     // ƽ������
    VoteCount: Integer;      // ��������
  end;

  // ��Ӱ�������ҳ��
  TMovieSearchPage = class
  public
    Page: Integer;           // ��ǰҳ��
    Results: TList<TMovie>;  // ��Ӱ����б�
    TotalPages: Integer;     // ��ҳ��
    TotalResults: Integer;   // �ܽ����

    constructor Create;
    destructor Destroy; override;

    // ��JSON�ַ��������������ҳ
    class function FromJson(const AJson: string): TMovieSearchPage;
    // ��JSON���󴴽�������Ӱ��¼
    class function MovieFromJson(const AJson: ISuperObject): TMovie;
    // ��JSON�ַ���������Ӱ��ϸ��Ϣ��¼
    class function MovieDetailsFromJson(const AJson: string): TMovieDetails;
  end;

implementation

{ TMovieDetails }

// ��ʼ��TMovieDetails��¼�еĶ�̬����
procedure TMovieDetails.Initialize;
begin
  Genres := TList<TGenre>.Create;
  OriginCountry := TList<string>.Create;
  ProductionCompanies := TList<TProductionCompany>.Create;
  ProductionCountries := TList<TProductionCountry>.Create;
  SpokenLanguages := TList<TSpokenLanguage>.Create;
  Cast := TList<TActor>.Create;

  // ��ʼ������ϵ���ֶ�
  BelongsToCollection.Id := 0;
  BelongsToCollection.Name := '';
  BelongsToCollection.PosterPath := '';
  BelongsToCollection.BackdropPath := '';
end;

// �ͷ�TMovieDetails��¼�еĶ�̬����
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

// ��JSON���󴴽�������Ӱ��¼
class function TMovieSearchPage.MovieFromJson(const AJson: ISuperObject): TMovie;
var
  LGenreIdObj: ISuperObject;
  LGenreIdsArrayObj: ISuperObject;
  LBackdropPathObj: ISuperObject;
  i: Integer;
begin
  Result.Adult := AJson.B['adult'];

  // �������Ϊnull��backdrop_path�ֶ�
  LBackdropPathObj := AJson.O['backdrop_path'];
  if Assigned(LBackdropPathObj) and (LBackdropPathObj.DataType <> stNull) then
    Result.BackdropPath := LBackdropPathObj.AsString
  else
    Result.BackdropPath := '';

  // ��ʼ�����������ID�б�
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

  // ������������ֶ�
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

// ���캯��
constructor TMovieSearchPage.Create;
begin
  Results := TList<TMovie>.Create;
end;

// ��������
destructor TMovieSearchPage.Destroy;
begin
  Results.Free;
  inherited;
end;

// ��JSON�ַ��������������ҳ
class function TMovieSearchPage.FromJson(const AJson: string): TMovieSearchPage;
var
  LJsonObj, LMovieJson: ISuperObject;
  LResultsArrayObj: ISuperObject;
  i: Integer;
begin
  Result := TMovieSearchPage.Create;
  LJsonObj := SO(AJson);

  // ���JSON�����Ƿ���Ч
  if not Assigned(LJsonObj) or not ObjectIsType(LJsonObj, stObject) then
    Exit;

  // ����ҳ��Ϣ
  Result.Page := LJsonObj.I['page'];
  Result.TotalPages := LJsonObj.I['total_pages'];
  Result.TotalResults := LJsonObj.I['total_results'];

  // �����Ӱ�������
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

// ��JSON�ַ���������Ӱ��ϸ��Ϣ��¼
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
  Result.Initialize; // ��ʼ�����ж�̬����

  LJsonObj := SO(AJson);

  // ���JSON�����Ƿ���Ч
  if not Assigned(LJsonObj) or not ObjectIsType(LJsonObj, stObject) then
    Exit;

  // ��������Ϣ
  Result.Adult := LJsonObj.B['adult'];

  // �������Ϊnull��backdrop_path
  LSubObj := LJsonObj.O['backdrop_path'];
  if Assigned(LSubObj) and (LSubObj.DataType <> stNull) then
    Result.BackdropPath := LSubObj.AsString
  else
    Result.BackdropPath := '';

  // ��������ϵ����Ϣ
  LSubObj := LJsonObj.O['belongs_to_collection'];
  if Assigned(LSubObj) and (LSubObj.DataType = stObject) then
  begin
    Result.BelongsToCollection.Id := LSubObj.I['id'];
    Result.BelongsToCollection.Name := LSubObj.S['name'];
    Result.BelongsToCollection.PosterPath := LSubObj.S['poster_path'];
    Result.BelongsToCollection.BackdropPath := LSubObj.S['backdrop_path'];
  end;

  Result.Budget := LJsonObj.I['budget'];

  // �����Ӱ��������
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

  // �������������Ϣ
  Result.Homepage := LJsonObj.S['homepage'];
  Result.Id := LJsonObj.I['id'];

  // �������Ϊnull��imdb_id
  LSubObj := LJsonObj.O['imdb_id'];
  if Assigned(LSubObj) and (LSubObj.DataType <> stNull) then
    Result.ImdbId := LSubObj.AsString
  else
    Result.ImdbId := '';

  // ����ԭ����������
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

  // �������������Ϣ
  Result.OriginalLanguage := LJsonObj.S['original_language'];
  Result.OriginalTitle := LJsonObj.S['original_title'];
  Result.Plot := LJsonObj.S['overview'];
  Result.Popularity := LJsonObj.D['popularity'];
  Result.PosterPath := LJsonObj.S['poster_path'];

  // ����������˾����
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

  // ����������������
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

  // �������������Ϣ
  Result.ReleaseDate := LJsonObj.S['release_date'];
  Result.Revenue := LJsonObj.I['revenue'];
  Result.Runtime := LJsonObj.I['runtime'];

  // ������������
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

  // �������������Ϣ
  Result.Status := LJsonObj.S['status'];
  Result.Tagline := LJsonObj.S['tagline'];
  Result.Title := LJsonObj.S['title'];
  Result.Video := LJsonObj.B['video'];
  Result.VoteAverage := LJsonObj.D['vote_average'];
  Result.VoteCount := LJsonObj.I['vote_count'];

  // ������Ա����Ϣ
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
            LSubObj := LItemObj.O['profile_path']; // profile_path����Ϊnull
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

