//
//  TMDBService.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/6/25.
//
// TMDB API와 통신하는 모든 기능들을 관리하는 서비스

import Foundation

// API 에러 타입 정의
enum TMDBError: Error {
    case invalidURL          // 잘못된 URL
    case noData             // 데이터가 없음
    case decodingFailed     // JSON 변환 실패
    case networkError(Error) // 네트워크 오류
}

// TMDB API 서비스
class TMDBService {
    
    // 싱글톤 패턴 - 앱 전체에서 하나의 인스턴스만 사용
    static let shared = TMDBService()
    private init() {}
    
    // URL 세션 (네트워크 통신을 위한 객체)
    private let session = URLSession.shared
    
    // 인기 영화 목록 가져오기 (한국 지역)
    func fetchPopularMovies(page: Int = 1, completion: @escaping (Result<MovieResponse, TMDBError>) -> Void) {
        
        // 한국 지역 파라미터 추가
        guard let url = createURL(for: .popularMovies, page: page, region: "KR") else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("🎬 인기 영화 로딩 (한국): \(url)")
        
        performRequest(url: url, completion: completion)
    }

    
    // 영화 검색하기
    func searchMovies(query: String, page: Int = 1, completion: @escaping (Result<MovieResponse, TMDBError>) -> Void) {
        
        // 검색어가 비어있으면 에러
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 1. URL 만들기 (검색어 포함)
        guard let url = createURL(for: .searchMovies, page: page, query: query) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 2. API 요청 보내기
        performRequest(url: url, completion: completion)
    }
    
    // 통합 검색 (영화 + TV)
    func searchMulti(query: String, page: Int = 1, completion: @escaping (Result<MultiSearchResponse, TMDBError>) -> Void) {
        
        // 검색어가 비어있으면 에러
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 1. URL 만들기
        guard let url = createURL(for: .multiSearch, page: page, query: query) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("🔍 MultiSearch URL: \(url)")
        
        // 2. API 요청 보내기
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                // 에러 체크
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                // 데이터 체크
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                // JSON 변환
                do {
                    let multiSearchResponse = try JSONDecoder().decode(MultiSearchResponse.self, from: data)
                    print("✅ MultiSearch 결과: \(multiSearchResponse.results.count)개")
                    completion(.success(multiSearchResponse))
                } catch {
                    print("❌ MultiSearch 디코딩 에러: \(error)")
                    completion(.failure(.decodingFailed))
                }
            }
        }.resume()
    }
    
    // 영화 상세 정보 가져오기 (기본 Movie 타입)
    func fetchMovieDetails(movieId: Int, completion: @escaping (Result<Movie, TMDBError>) -> Void) {
        
        // 1. URL 만들기
        guard let url = createURL(for: .movieDetails(id: movieId)) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 2. API 요청 보내기 (단일 영화 정보)
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                // 에러 체크
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                // 데이터 체크
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                // JSON 변환
                do {
                    let movie = try JSONDecoder().decode(Movie.self, from: data)
                    completion(.success(movie))
                } catch {
                    completion(.failure(.decodingFailed))
                }
            }
        }.resume()
    }
    
    // 영화 상세 정보 가져오기 (확장된 MovieDetail 타입)
    func fetchMovieDetail(movieId: Int, completion: @escaping (Result<MovieDetail, TMDBError>) -> Void) {
        
        // 1. URL 만들기
        guard let url = createURL(for: .movieDetails(id: movieId)) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 2. API 요청 보내기 (MovieDetail 타입으로)
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                // 에러 체크
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                // 데이터 체크
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                // JSON 변환 (MovieDetail로)
                do {
                    let movieDetail = try JSONDecoder().decode(MovieDetail.self, from: data)
                    completion(.success(movieDetail))
                } catch {
                    print("MovieDetail 디코딩 에러: \(error)")
                    completion(.failure(.decodingFailed))
                }
            }
        }.resume()
    }
    
    // 영화 배우 정보 가져오기
    func fetchMovieCredits(movieId: Int, completion: @escaping (Result<MovieCredits, TMDBError>) -> Void) {
        
        // 1. URL 만들기
        guard let url = createURL(for: .movieCredits(id: movieId)) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("🎭 배우 정보 요청 URL: \(url)")
        
        // 2. API 요청 보내기
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                // 에러 체크
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                // 데이터 체크
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                // JSON 변환
                do {
                    let movieCredits = try JSONDecoder().decode(MovieCredits.self, from: data)
                    print("✅ 배우 정보 로딩 완료: 배우 \(movieCredits.cast.count)명, 제작진 \(movieCredits.crew.count)명")
                    completion(.success(movieCredits))
                } catch {
                    print("❌ MovieCredits 디코딩 에러: \(error)")
                    completion(.failure(.decodingFailed))
                }
            }
        }.resume()
    }
    
    // 영화 상세 정보 + 배우 정보 한 번에 가져오기
    func fetchMovieDetailWithCredits(movieId: Int, completion: @escaping (Result<MovieDetailWithCredits, TMDBError>) -> Void) {
        
        // 1. URL 만들기 (credits 정보 포함)
        guard let url = createURLWithCredits(for: .movieDetails(id: movieId)) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("🎬 영화 상세정보 + 배우정보 요청 URL: \(url)")
        
        // 2. API 요청 보내기
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                // 에러 체크
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                // 데이터 체크
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                // JSON 변환
                do {
                    let movieDetailWithCredits = try JSONDecoder().decode(MovieDetailWithCredits.self, from: data)
                    print("✅ 통합 정보 로딩 완료:")
                    print("   제목: \(movieDetailWithCredits.title)")
                    print("   상영시간: \(movieDetailWithCredits.formattedRuntime)")
                    print("   장르: \(movieDetailWithCredits.genreString)")
                    print("   주요 배우: \(movieDetailWithCredits.mainCast.count)명")
                    print("   감독: \(movieDetailWithCredits.directorsString)")
                    
                    completion(.success(movieDetailWithCredits))
                } catch {
                    print("❌ MovieDetailWithCredits 디코딩 에러: \(error)")
                    completion(.failure(.decodingFailed))
                }
            }
        }.resume()
    }
    
    // TV 프로그램 상세 정보 + 배우 정보 한 번에 가져오기
    func fetchTVDetailWithCredits(tvId: Int, completion: @escaping (Result<TVDetail, TMDBError>) -> Void) {
        
        // 1. URL 만들기 (credits 정보 포함)
        guard let url = createURLWithCredits(for: .tvDetails(id: tvId)) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("📺 TV 상세정보 + 배우정보 요청 URL: \(url)")
        
        // 2. API 요청 보내기
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                // 에러 체크
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                // 데이터 체크
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                // JSON 변환
                do {
                    let tvDetail = try JSONDecoder().decode(TVDetail.self, from: data)
                    print("✅ TV 통합 정보 로딩 완료:")
                    print("   제목: \(tvDetail.name)")
                    print("   시즌 수: \(tvDetail.numberOfSeasons ?? 0)")
                    print("   에피소드 수: \(tvDetail.numberOfEpisodes ?? 0)")
                    print("   주요 배우: \(tvDetail.credits?.cast.count ?? 0)명")
                    
                    completion(.success(tvDetail))
                } catch {
                    print("❌ TVDetail 디코딩 에러: \(error)")
                    completion(.failure(.decodingFailed))
                }
            }
        }.resume()
    }

    // 인기 TV 프로그램 목록 가져오기 (한국 원산지)
    func fetchPopularTV(page: Int = 1, completion: @escaping (Result<MultiSearchResponse, TMDBError>) -> Void) {
        
        // 1. Discover TV API로 변경 + 한국 원산지 필터
        guard let url = createKoreanTVURL(page: page) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("📺 한국 TV 프로그램 로딩 (원산지 필터): \(url)")
        
        // 2. API 요청 보내기
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                // TV 응답을 MultiSearchResponse로 변환
                do {
                    let tvResponse = try JSONDecoder().decode(TVResponse.self, from: data)
                    
                    // TV를 MediaItem으로 변환
                    let mediaItems = tvResponse.results.map { tv in
                        MediaItem(
                            id: tv.id,
                            mediaType: "tv",
                            title: nil,
                            name: tv.name,
                            overview: tv.overview,
                            releaseDate: nil,
                            firstAirDate: tv.firstAirDate,
                            posterPath: tv.posterPath,
                            backdropPath: tv.backdropPath,
                            voteAverage: tv.voteAverage,
                            voteCount: tv.voteCount,
                            popularity: tv.popularity,
                            genreIds: tv.genreIds,
                            adult: tv.adult,
                            originalLanguage: tv.originalLanguage,
                            originalTitle: nil,
                            originalName: tv.originalName
                        )
                    }
                    
                    let multiSearchResponse = MultiSearchResponse(
                        page: tvResponse.page,
                        results: mediaItems,
                        totalPages: tvResponse.totalPages,
                        totalResults: tvResponse.totalResults
                    )
                    
                    print("✅ TV 프로그램 \(mediaItems.count)개 로딩 완료!")
                    completion(.success(multiSearchResponse))
                    
                } catch {
                    print("❌ TV 응답 디코딩 에러: \(error)")
                    completion(.failure(.decodingFailed))
                }
            }
        }.resume()
    }
    
    // 한국 TV 전용 URL 생성
    private func createKoreanTVURL(page: Int) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = "/3/discover/tv"
        
        let queryItems = [
            URLQueryItem(name: "api_key", value: Config.tmdbAPIKey),
            URLQueryItem(name: "language", value: "ko-KR"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "with_origin_country", value: "KR")
        ]
        
        components.queryItems = queryItems
        return components.url
    }
    
    private func createURLWithCredits(for endpoint: APIEndpoint, page: Int = 1, query: String? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        
        // 엔드포인트별 경로 설정
        switch endpoint {
        case .popularMovies:
            components.path = "/3/movie/popular"
        case .searchMovies:
            components.path = "/3/search/movie"
        case .movieDetails(let id):
            components.path = "/3/movie/\(id)"
        case .movieCredits(let id):
            components.path = "/3/movie/\(id)/credits"
        case .multiSearch:
            components.path = "/3/search/multi"
        case .popularTV:
            components.path = "/3/tv/popular"
        case .tvDetails(let id):
            components.path = "/3/tv/\(id)"
        case .tvCredits(let id):
            components.path = "/3/tv/\(id)/credits"
        }
        
        // 쿼리 파라미터 추가
        var queryItems = [
            URLQueryItem(name: "api_key", value: Config.tmdbAPIKey),
            URLQueryItem(name: "language", value: "ko-KR"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        // 🎭 영화 상세정보일 때 credits 정보도 함께 요청
        if case .movieDetails = endpoint {
            queryItems.append(URLQueryItem(name: "append_to_response", value: "credits"))
        }
        
        if case .tvDetails = endpoint {
            queryItems.append(URLQueryItem(name: "append_to_response", value: "credits"))
        }
        
        // 검색어가 있으면 추가
        if let query = query {
            queryItems.append(URLQueryItem(name: "query", value: query))
        }
        
        components.queryItems = queryItems
        return components.url
    }
}

// 헬퍼 메서드들
private extension TMDBService {
    
    // API 엔드포인트 타입
    enum APIEndpoint {
        case popularMovies
        case searchMovies
        case movieDetails(id: Int)
        case movieCredits(id: Int)
        case multiSearch
        case popularTV
        case tvDetails(id: Int)
        case tvCredits(id: Int)
    }
    
    // URL 생성하기
    func createURL(for endpoint: APIEndpoint, page: Int = 1, query: String? = nil, region: String? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        
        // 엔드포인트별 경로 설정
        switch endpoint {
        case .popularMovies:
            components.path = "/3/movie/popular"
        case .searchMovies:
            components.path = "/3/search/movie"
        case .movieDetails(let id):
            components.path = "/3/movie/\(id)"
        case .movieCredits(let id):
            components.path = "/3/movie/\(id)/credits"
        case .multiSearch:
            components.path = "/3/search/multi"
        case .popularTV:
            components.path = "/3/tv/popular"
        case .tvDetails(let id):
            components.path = "/3/tv/\(id)"
        case .tvCredits(let id):
            components.path = "/3/tv/\(id)/credits"
        }
        
        // 쿼리 파라미터 추가
        var queryItems = [
            URLQueryItem(name: "api_key", value: Config.tmdbAPIKey),
            URLQueryItem(name: "language", value: "ko-KR"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        // 지역 파라미터 추가 (인기 목록용)
        if let region = region {
            queryItems.append(URLQueryItem(name: "region", value: region))
        }
        
        // 검색어가 있으면 추가
        if let query = query {
            queryItems.append(URLQueryItem(name: "query", value: query))
        }
        
        components.queryItems = queryItems
        return components.url
    }
    
    // 실제 네트워크 요청 수행 (공통 로직)
    func performRequest(url: URL, completion: @escaping (Result<MovieResponse, TMDBError>) -> Void) {
        
        session.dataTask(with: url) { data, response, error in
            // 메인 스레드에서 결과 처리 (UI 업데이트를 위해)
            DispatchQueue.main.async {
                
                // 1. 에러 체크
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                // 2. 데이터 체크
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                // 3. JSON 변환
                do {
                    let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                    completion(.success(movieResponse))
                } catch {
                    print("디코딩 에러: \(error)") // 디버깅용
                    completion(.failure(.decodingFailed))
                }
            }
        }.resume() // 요청 시작!
    }
}
