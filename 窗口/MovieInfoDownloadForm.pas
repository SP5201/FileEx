{*******************************************************************************
  影片信息下载窗口单元
  功能：从TheMovieDB API获取影片详细信息，支持搜索和详情获取
  
  主要功能：
  - 根据影片标题搜索TheMovieDB数据库
  - 获取影片详细信息（标题、演员、类型、剧情等）
  - 支持HTTP代理设置
  - 异步下载和进度显示
  - 搜索结果列表展示和选择
  
  API接口：TheMovieDB (TMDB)
  支持语言：中文
  
  Copyright (c) 2025 zotptptp
  Email: zoutp@qq.com
  All rights reserved.
*******************************************************************************}

unit MovieInfoDownloadForm;

interface

uses
  Windows, SysUtils, UI_MovieInfoDownloadForm, UI_Form, MovieInfoUnit,
  WinHTTPDownload, {$I XCGuiStyle.inc},  MovieJsonUnit;

type
  TMovieInfoDownloadForm = class(TMovieInfoDownloadFormUI)
  private
    FDownloader: TWinHTTPDownloader;
    FMovieIdForDetails: Integer;
    procedure OnFDownloaderProgress(DownloadStatus: TDownloadStatus; InfoValue: DWORD; BytesRead, TotalBytes: Int64);
  protected
    procedure OnWinProc(AMessage: UINT; wParam: wParam; lParam: lParam; var bHandled: Boolean); override;
    procedure OnListSelect(ListUI: TListUI; iItem: Integer); override;
    procedure BtnCLICK(BtnUI: TSvgBtnUI);
    procedure Init(); override;
  public
    destructor Destroy; override;
  end;

procedure LoadMovieInfoDownloadForm(hParent: integer; MovieTitle: string);

var
  Form: TMovieInfoDownloadForm;

implementation

procedure LoadMovieInfoDownloadForm(hParent: integer; MovieTitle: string);
begin
  Form := TMovieInfoDownloadForm.FromXml('MovieInfoDownloadForm.xml', hParent) as TMovieInfoDownloadForm;
  Form.FWindowTitleUI.Text := '从网络获取影片信息';
  Form.FSearchEditUI.SetText(PChar(MovieTitle));
  XC_SendMessage(Form.Handle, XE_SEARCH_EDIT_RETURN, Integer(PChar(MovieTitle)), 0);
  Form.Show;
end;

procedure TMovieInfoDownloadForm.Init;
begin
  inherited;
  FDownloader := TWinHTTPDownloader.Create;
  FDownloader.OnProgress := OnFDownloaderProgress;
  FDownloader.SetProxy(ptHTTP, '127.0.0.1', 10808);
end;

procedure TMovieInfoDownloadForm.OnFDownloaderProgress(DownloadStatus: TDownloadStatus; InfoValue: DWORD; BytesRead, TotalBytes: Int64);
var
  MovieSearchPage: TMovieSearchPage;
  Index: Integer;
  Movie: TMovie;
  LMovieDetails: TMovieDetails;
  i: Integer;
begin
  case DownloadStatus of
    dsConnecting:
      OutputDebugString('FDownloader: 正在连接...');
    dsHeadersAvailable:
      OutputDebugString('FDownloader: 获取到头信息...');
    dsDownloadingData:
      OutputDebugString(PChar(Format('FDownloader: 正在下载: %d/%d 字节', [BytesRead, TotalBytes])));
    dsCompleted:
      begin
        if FDownloader.UsesData = 0 then // Search results from FDownloader
        begin
          OutputDebugString(PChar('搜索完成'));
          MovieSearchPage := TMovieSearchPage.FromJson(FDownloader.GetWebPageSourceText);

          for Movie in MovieSearchPage.Results do
          begin
            Index := FSearchListUI.AddItem(PWideChar(Movie.Title), PWideChar(Movie.ReleaseDate));
            FSearchListUI.SetItemData(Index, 0, Movie.Id);
          end;
          FSearchListUI.SetSelectRow(0);
          FSearchListUI.PostEvent(XE_LIST_SELECT, 0, 0);
          FSearchListUI.Redraw;
        end
        else if FDownloader.UsesData = 1 then // Basic details from FDownloader
        begin
          LMovieDetails := TMovieSearchPage.MovieDetailsFromJson(FDownloader.GetWebPageSourceText);
          try
            OutputDebugString(PChar('--- Movie Details Start ---'));
            OutputDebugString(PChar(Format('ID: %d', [LMovieDetails.Id])));
            OutputDebugString(PChar(Format('Title: %s', [LMovieDetails.Title])));
            FMovieTitleUI.Text := LMovieDetails.Title;
            OutputDebugString(PChar(Format('Original Title: %s', [LMovieDetails.OriginalTitle])));
            OutputDebugString(PChar(Format('Release Date: %s', [LMovieDetails.ReleaseDate])));
            OutputDebugString(PChar(Format('Runtime: %d min', [LMovieDetails.Runtime])));
            OutputDebugString(PChar(Format('Status: %s', [LMovieDetails.Status])));
            OutputDebugString(PChar(Format('Tagline: %s', [LMovieDetails.Tagline])));
            OutputDebugString(PChar(Format('Plot: %s', [LMovieDetails.Plot])));
            OutputDebugString(PChar(Format('Popularity: %f', [LMovieDetails.Popularity])));
            OutputDebugString(PChar(Format('Vote Average: %f', [LMovieDetails.VoteAverage])));
            OutputDebugString(PChar(Format('Vote Count: %d', [LMovieDetails.VoteCount])));
            OutputDebugString(PChar(Format('Budget: %d', [LMovieDetails.Budget])));
            OutputDebugString(PChar(Format('Revenue: %d', [LMovieDetails.Revenue])));
            OutputDebugString(PChar(Format('Homepage: %s', [LMovieDetails.Homepage])));
            OutputDebugString(PChar(Format('IMDB ID: %s', [LMovieDetails.ImdbId])));
            OutputDebugString(PChar(Format('Backdrop Path: %s', [LMovieDetails.BackdropPath])));
            OutputDebugString(PChar(Format('Poster Path: %s', [LMovieDetails.PosterPath])));
            OutputDebugString(PChar(Format('Adult: %s', [BoolToStr(LMovieDetails.Adult, True)])));
            OutputDebugString(PChar(Format('Video: %s', [BoolToStr(LMovieDetails.Video, True)])));
            OutputDebugString(PChar(Format('Original Language: %s', [LMovieDetails.OriginalLanguage])));

            OutputDebugString(PChar('-- Genres --'));

            for i := 0 to LMovieDetails.Genres.Count - 1 do
            begin
              if i > 0 then
                FMovieGenreUI.Text := FMovieGenreUI.Text + ' / ';
              FMovieGenreUI.Text := FMovieGenreUI.Text + LMovieDetails.Genres[i].Name;
            end;

            OutputDebugString(PChar('-- Production Companies --'));
            for i := 0 to LMovieDetails.ProductionCompanies.Count - 1 do
              OutputDebugString(PChar(Format('  Company: %s (ID: %d, Origin: %s)', [LMovieDetails.ProductionCompanies[i].Name, LMovieDetails.ProductionCompanies[i].Id, LMovieDetails.ProductionCompanies[i].OriginCountry])));

            OutputDebugString(PChar('-- Production Countries --'));


            OutputDebugString(PChar('-- Spoken Languages --'));
            for i := 0 to LMovieDetails.SpokenLanguages.Count - 1 do
              OutputDebugString(PChar(Format('  Language: %s (ISO: %s, English Name: %s)', [LMovieDetails.SpokenLanguages[i].Name, LMovieDetails.SpokenLanguages[i].Iso639_1, LMovieDetails.SpokenLanguages[i].EnglishName])));

            OutputDebugString(PChar(Format('-- Cast Members (%d) --', [LMovieDetails.Cast.Count])));

            for i := 0 to LMovieDetails.Cast.Count - 1 do
            begin
              if i > 0 then
                FActorLabelUI.Text := FActorLabelUI.Text + ' / ';
              FActorLabelUI.Text := FActorLabelUI.Text + LMovieDetails.Cast[i].Name;
            end;
          finally
            LMovieDetails.Finalize;
          end;
        end;
      end;
    dsErrorEncountered:
      OutputDebugString(PChar(Format('FDownloader: 下载出错，错误代码: %d', [InfoValue])));
  end;
end;

procedure TMovieInfoDownloadForm.OnListSelect(ListUI: TListUI; iItem: Integer);
begin
  if iItem < 0 then
    Exit;
  Clear;
  FMovieIdForDetails := ListUI.GetItemData(iItem, 0);
  FDownloader.UsesData := 1;
  FDownloader.GetWebPageSource('https://api.themoviedb.org/3/movie/' + IntToStr(FMovieIdForDetails) + '?api_key=7795689c10b41a6458ac17fd20cbae58&language=zh-CN&append_to_response=credits');
  end;

function URLEncode(const AValue: string): string;
var
  Bytes: TBytes;
  B: Byte;
  sBuff: string;
begin
  sBuff := '';
  if AValue = '' then
  begin
    Result := '';
    Exit;
  end;

  Bytes := TEncoding.UTF8.GetBytes(AValue);

  for B in Bytes do
  begin

    if ((B >= Ord('A')) and (B <= Ord('Z'))) or ((B >= Ord('a')) and (B <= Ord('z'))) or ((B >= Ord('0')) and (B <= Ord('9'))) or (B = Ord('*')) or (B = Ord('@')) or (B = Ord('.')) or (B = Ord('_')) or (B = Ord('-')) then
    begin
      sBuff := sBuff + Chr(B);
    end
    else if B = Ord(' ') then
    begin
      sBuff := sBuff + '+';
    end
    else
    begin
      sBuff := sBuff + '%' + IntToHex(B, 2);
    end;
  end;
  Result := sBuff;
end;

procedure TMovieInfoDownloadForm.OnWinProc(AMessage: UINT; wParam: wParam; lParam: lParam; var bHandled: Boolean);
begin
  case AMessage of
    XE_SEARCH_EDIT_RETURN:
      begin
        FSearchListUI.DeleteItemAll;
        FDownloader.UsesData := 0;
    //   FDownloader.StartDownload('http://gips0.baidu.com/it/u=1690853528,2506870245&fm=3028&app=3028&f=JPEG&fmt=auto?w=1024&h=1024','1.jpg');
        FDownloader.GetWebPageSource('https://api.themoviedb.org/3/search/movie?api_key=7795689c10b41a6458ac17fd20cbae58&query=' + URLEncode(FSearchEditUI.GetText_Temp) + '&language=zh-CN');

      end;
  end;
end;

procedure TMovieInfoDownloadForm.BtnCLICK(BtnUI: TSvgBtnUI);
begin
end;

destructor TMovieInfoDownloadForm.Destroy;
begin
  FDownloader.Free;
  inherited;
end;

end.

