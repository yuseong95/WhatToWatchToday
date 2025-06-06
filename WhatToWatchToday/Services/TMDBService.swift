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
    
    // 인기 영화 목록 가져오기
    func fetchPopularMovies(page: Int = 1, completion: @escaping (Result<MovieResponse, TMDBError>) -> Void) {
        
        // 1. URL 만들기
        guard let url = createURL(for: .popularMovies, page: page) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // 2. API 요청 보내기
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
    
    // 영화 상세 정보 가져오기
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
}

// 헬퍼 메서드들
private extension TMDBService {
    
    // API 엔드포인트 타입
    enum APIEndpoint {
        case popularMovies
        case searchMovies
        case movieDetails(id: Int)
    }
    
    // URL 생성하기
    func createURL(for endpoint: APIEndpoint, page: Int = 1, query: String? = nil) -> URL? {
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
        }
        
        // 쿼리 파라미터 추가
        var queryItems = [
            URLQueryItem(name: "api_key", value: Config.tmdbAPIKey),
            URLQueryItem(name: "language", value: "ko-KR"),  // 한국어
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
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

// 사용 예시 (주석)
/*
 // 인기 영화 가져오기
 TMDBService.shared.fetchPopularMovies { result in
     switch result {
     case .success(let movieResponse):
         print("영화 \(movieResponse.results.count)개 받아옴")
     case .failure(let error):
         print("에러: \(error)")
     }
 }
 
 // 영화 검색하기
 TMDBService.shared.searchMovies(query: "아바타") { result in
     switch result {
     case .success(let movieResponse):
         print("검색 결과: \(movieResponse.results.count)개")
     case .failure(let error):
         print("검색 에러: \(error)")
     }
 }
*/
