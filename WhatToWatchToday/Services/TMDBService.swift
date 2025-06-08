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
    case invalidURL
    case noData
    case decodingFailed
    case networkError(Error)
}

// TMDB API 서비스 - 정리된 버전
class TMDBService {
    
    // 싱글톤 패턴
    static let shared = TMDBService()
    private init() {}
    
    private let session = URLSession.shared
    
    // 통합된 API 메서드들
    
    /// 인기 영화 목록 가져오기 (한국 지역)
    func fetchPopularMovies(page: Int = 1, completion: @escaping (Result<MovieResponse, TMDBError>) -> Void) {
        let endpoint = APIEndpoint.popularMovies
        guard let url = createURL(for: endpoint, page: page, region: "KR") else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("🎬 인기 영화 로딩 (한국): \(url)")
        performRequest(url: url, responseType: MovieResponse.self, completion: completion)
    }
    
    /// 통합 검색 (영화 + TV)
    func searchMulti(query: String, page: Int = 1, completion: @escaping (Result<MultiSearchResponse, TMDBError>) -> Void) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            completion(.failure(.invalidURL))
            return
        }
        
        let endpoint = APIEndpoint.multiSearch
        guard let url = createURL(for: endpoint, page: page, query: query) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("🔍 MultiSearch URL: \(url)")
        performRequest(url: url, responseType: MultiSearchResponse.self, completion: completion)
    }
    
    /// 영화 상세 정보 + 배우 정보 한 번에 가져오기
    func fetchMovieDetailWithCredits(movieId: Int, completion: @escaping (Result<MovieDetailWithCredits, TMDBError>) -> Void) {
        let endpoint = APIEndpoint.movieDetails(id: movieId)
        guard let url = createURLWithCredits(for: endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("🎬 영화 상세정보 + 배우정보 요청: \(url)")
        performRequest(url: url, responseType: MovieDetailWithCredits.self) { result in
            switch result {
            case .success(let detail):
                print("✅ 통합 정보 로딩 완료: \(detail.title)")
                completion(.success(detail))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// TV 프로그램 상세 정보 + 배우 정보 한 번에 가져오기
    func fetchTVDetailWithCredits(tvId: Int, completion: @escaping (Result<TVDetail, TMDBError>) -> Void) {
        let endpoint = APIEndpoint.tvDetails(id: tvId)
        guard let url = createURLWithCredits(for: endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("📺 TV 상세정보 + 배우정보 요청: \(url)")
        performRequest(url: url, responseType: TVDetail.self) { result in
            switch result {
            case .success(let detail):
                print("✅ TV 통합 정보 로딩 완료: \(detail.name)")
                completion(.success(detail))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// 인기 TV 프로그램 목록 가져오기 (한국 원산지)
    func fetchPopularTV(page: Int = 1, completion: @escaping (Result<MultiSearchResponse, TMDBError>) -> Void) {
        guard let url = createKoreanTVURL(page: page) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("📺 한국 TV 프로그램 로딩: \(url)")
        
        // TV 응답을 받아서 MultiSearchResponse로 변환
        performRequest(url: url, responseType: TVResponse.self) { result in
            switch result {
            case .success(let tvResponse):
                let mediaItems = tvResponse.results.map { tv in
                    MediaItem(
                        id: tv.id, mediaType: "tv", title: nil, name: tv.name,
                        overview: tv.overview, releaseDate: nil, firstAirDate: tv.firstAirDate,
                        posterPath: tv.posterPath, backdropPath: tv.backdropPath,
                        voteAverage: tv.voteAverage, voteCount: tv.voteCount,
                        popularity: tv.popularity, genreIds: tv.genreIds, adult: tv.adult,
                        originalLanguage: tv.originalLanguage, originalTitle: nil, originalName: tv.originalName
                    )
                }
                
                let multiSearchResponse = MultiSearchResponse(
                    page: tvResponse.page, results: mediaItems,
                    totalPages: tvResponse.totalPages, totalResults: tvResponse.totalResults
                )
                
                print("✅ TV 프로그램 \(mediaItems.count)개 로딩 완료!")
                completion(.success(multiSearchResponse))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// Private Helper Methods
private extension TMDBService {
    
    enum APIEndpoint {
        case popularMovies
        case searchMovies
        case movieDetails(id: Int)
        case movieCredits(id: Int)
        case multiSearch
        case popularTV
        case tvDetails(id: Int)
        case tvCredits(id: Int)
        
        var path: String {
            switch self {
            case .popularMovies: return "/3/movie/popular"
            case .searchMovies: return "/3/search/movie"
            case .movieDetails(let id): return "/3/movie/\(id)"
            case .movieCredits(let id): return "/3/movie/\(id)/credits"
            case .multiSearch: return "/3/search/multi"
            case .popularTV: return "/3/tv/popular"
            case .tvDetails(let id): return "/3/tv/\(id)"
            case .tvCredits(let id): return "/3/tv/\(id)/credits"
            }
        }
    }
    
    /// 통합된 URL 생성 메서드
    func createURL(for endpoint: APIEndpoint, page: Int = 1, query: String? = nil, region: String? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = endpoint.path
        
        var queryItems = [
            URLQueryItem(name: "api_key", value: Config.tmdbAPIKey),
            URLQueryItem(name: "language", value: "ko-KR"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        // 추가 파라미터들
        if let region = region {
            queryItems.append(URLQueryItem(name: "region", value: region))
        }
        if let query = query {
            queryItems.append(URLQueryItem(name: "query", value: query))
        }
        
        components.queryItems = queryItems
        return components.url
    }
    
    /// Credits 정보 포함 URL 생성
    func createURLWithCredits(for endpoint: APIEndpoint) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = endpoint.path
        
        var queryItems = [
            URLQueryItem(name: "api_key", value: Config.tmdbAPIKey),
            URLQueryItem(name: "language", value: "ko-KR"),
            URLQueryItem(name: "append_to_response", value: "credits")
        ]
        
        components.queryItems = queryItems
        return components.url
    }
    
    /// 한국 TV 전용 URL 생성
    func createKoreanTVURL(page: Int) -> URL? {
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
    
    /// 통합된 네트워크 요청 메서드 (제네릭)
    func performRequest<T: Codable>(url: URL, responseType: T.Type, completion: @escaping (Result<T, TMDBError>) -> Void) {
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
                
                do {
                    let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    print("❌ 디코딩 에러 (\(T.self)): \(error)")
                    completion(.failure(.decodingFailed))
                }
            }
        }.resume()
    }
}
