//
//  RecommendationManager.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/15/25.
//  찜한 목록 기반 맞춤 추천 기능을 관리하는 매니저
//

import Foundation

// 장르 정보 구조체
struct TMDBGenre {
    let id: Int
    let name: String
    
    // TMDB 주요 장르 목록 (한국어)
    static let genreMap: [Int: String] = [
        28: "액션",
        12: "모험",
        16: "애니메이션",
        35: "코미디",
        80: "범죄",
        99: "다큐멘터리",
        18: "드라마",
        10751: "가족",
        14: "판타지",
        36: "역사",
        27: "공포",
        10402: "음악",
        9648: "미스터리",
        10749: "로맨스",
        878: "SF",
        10770: "TV 영화",
        53: "스릴러",
        10752: "전쟁",
        37: "서부"
    ]
    
    static func name(for genreId: Int) -> String {
        return genreMap[genreId] ?? "기타"
    }
}

// 추천 결과 구조체
struct RecommendationResult {
    let preferredGenres: [TMDBGenre]
    let recommendedMovies: [MediaItem]
    let totalFavorites: Int
    let analysisDate: Date
}

// 맞춤 추천 매니저
class RecommendationManager {
    
    static let shared = RecommendationManager()
    private init() {}
    
    // 찜한 목록 기반 장르 분석
    func analyzeUserPreferences() -> [TMDBGenre] {
        let favorites = FavoriteManager.shared.getFavorites()
        
        // 찜한 영화가 없으면 빈 배열 반환
        guard !favorites.isEmpty else {
            print("찜한 영화가 없어서 선호 장르 분석 불가")
            return []
        }
        
        // 장르 ID별 등장 횟수 계산
        var genreCount: [Int: Int] = [:]
        
        for favorite in favorites {
            // FavoriteItem의 genreIds는 없으니 임시로 추정 로직
            // 실제로는 TMDB API에서 상세 정보를 가져와야 하지만,
            // 간단히 영화 제목이나 다른 정보로 장르를 추정
            let estimatedGenres = estimateGenres(for: favorite)
            
            for genreId in estimatedGenres {
                genreCount[genreId, default: 0] += 1
            }
        }
        
        // 가장 많이 등장한 장르 TOP 3 추출
        let sortedGenres = genreCount.sorted { $0.value > $1.value }
        let topGenres = Array(sortedGenres.prefix(3))
        
        let preferredGenres = topGenres.map { (genreId, count) in
            TMDBGenre(id: genreId, name: TMDBGenre.name(for: genreId))
        }
        
        print("분석된 선호 장르: \(preferredGenres.map { "\($0.name)(\($0.id))" }.joined(separator: ", "))")
        
        return preferredGenres
    }
    
    // 영화 제목/내용 기반 장르 추정 (간단한 키워드 매칭)
    private func estimateGenres(for favorite: FavoriteItem) -> [Int] {
        let title = favorite.title.lowercased()
        let overview = favorite.overview.lowercased()
        let text = "\(title) \(overview)"
        
        var estimatedGenres: [Int] = []
        
        // 키워드 기반 장르 추정
        if text.contains("액션") || text.contains("전투") || text.contains("격투") || text.contains("fight") || text.contains("action") {
            estimatedGenres.append(28) // 액션
        }
        
        if text.contains("코미디") || text.contains("웃음") || text.contains("재미") || text.contains("comedy") || text.contains("funny") {
            estimatedGenres.append(35) // 코미디
        }
        
        if text.contains("로맨스") || text.contains("사랑") || text.contains("연애") || text.contains("romance") || text.contains("love") {
            estimatedGenres.append(10749) // 로맨스
        }
        
        if text.contains("드라마") || text.contains("감동") || text.contains("인생") || text.contains("drama") {
            estimatedGenres.append(18) // 드라마
        }
        
        if text.contains("공포") || text.contains("무서") || text.contains("horror") || text.contains("scary") {
            estimatedGenres.append(27) // 공포
        }
        
        if text.contains("스릴러") || text.contains("긴장") || text.contains("thriller") || text.contains("suspense") {
            estimatedGenres.append(53) // 스릴러
        }
        
        if text.contains("sf") || text.contains("과학") || text.contains("미래") || text.contains("sci-fi") || text.contains("science fiction") {
            estimatedGenres.append(878) // SF
        }
        
        if text.contains("애니메이션") || text.contains("애니") || text.contains("animation") || text.contains("animated") {
            estimatedGenres.append(16) // 애니메이션
        }
        
        if text.contains("범죄") || text.contains("경찰") || text.contains("범인") || text.contains("crime") || text.contains("police") {
            estimatedGenres.append(80) // 범죄
        }
        
        if text.contains("판타지") || text.contains("마법") || text.contains("fantasy") || text.contains("magic") {
            estimatedGenres.append(14) // 판타지
        }
        
        // 장르가 추정되지 않으면 드라마로 기본 설정
        if estimatedGenres.isEmpty {
            estimatedGenres.append(18) // 드라마
        }
        
        return estimatedGenres
    }
    
    // 선호 장르 기반 영화 추천
    func getRecommendations(completion: @escaping (Result<RecommendationResult, TMDBError>) -> Void) {
        let preferredGenres = analyzeUserPreferences()
        
        // 선호 장르가 없으면 인기 영화 추천
        guard !preferredGenres.isEmpty else {
            getPopularMoviesAsRecommendation(completion: completion)
            return
        }
        
        // 첫 번째 선호 장르로 추천 영화 검색
        let primaryGenre = preferredGenres[0]
        
        TMDBService.shared.fetchMoviesByGenre(genreId: primaryGenre.id) { [weak self] result in
            switch result {
            case .success(let movieResponse):
                let mediaItems = movieResponse.results.map { movie in
                    MediaItem(
                        id: movie.id, mediaType: "movie", title: movie.title, name: nil,
                        overview: movie.overview, releaseDate: movie.releaseDate, firstAirDate: nil,
                        posterPath: movie.posterPath, backdropPath: movie.backdropPath,
                        voteAverage: movie.voteAverage, voteCount: movie.voteCount,
                        popularity: movie.popularity, genreIds: movie.genreIds, adult: movie.adult,
                        originalLanguage: movie.originalLanguage, originalTitle: movie.originalTitle, originalName: nil
                    )
                }
                
                // 이미 찜한 영화 제외
                let filteredMovies = self?.filterAlreadyFavorited(mediaItems) ?? mediaItems
                
                let result = RecommendationResult(
                    preferredGenres: preferredGenres,
                    recommendedMovies: Array(filteredMovies.prefix(10)), // 상위 10개만
                    totalFavorites: FavoriteManager.shared.favoritesCount(),
                    analysisDate: Date()
                )
                
                completion(.success(result))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 이미 찜한 영화 제외
    private func filterAlreadyFavorited(_ movies: [MediaItem]) -> [MediaItem] {
        let favorites = FavoriteManager.shared.getFavorites()
        let favoriteIds = Set(favorites.map { $0.id })
        
        return movies.filter { !favoriteIds.contains($0.id) }
    }
    
    // 찜한 영화가 없을 때 인기 영화 추천
    private func getPopularMoviesAsRecommendation(completion: @escaping (Result<RecommendationResult, TMDBError>) -> Void) {
        TMDBService.shared.fetchPopularMovies { result in
            switch result {
            case .success(let movieResponse):
                let mediaItems = movieResponse.results.map { movie in
                    MediaItem(
                        id: movie.id, mediaType: "movie", title: movie.title, name: nil,
                        overview: movie.overview, releaseDate: movie.releaseDate, firstAirDate: nil,
                        posterPath: movie.posterPath, backdropPath: movie.backdropPath,
                        voteAverage: movie.voteAverage, voteCount: movie.voteCount,
                        popularity: movie.popularity, genreIds: movie.genreIds, adult: movie.adult,
                        originalLanguage: movie.originalLanguage, originalTitle: movie.originalTitle, originalName: nil
                    )
                }
                
                let result = RecommendationResult(
                    preferredGenres: [], // 선호 장르 없음
                    recommendedMovies: Array(mediaItems.prefix(10)),
                    totalFavorites: 0,
                    analysisDate: Date()
                )
                
                completion(.success(result))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 추천 품질 점수 계산
    func getRecommendationQuality() -> String {
        let favoritesCount = FavoriteManager.shared.favoritesCount()
        
        switch favoritesCount {
        case 0:
            return "찜한 영화가 없어서 인기 영화를 추천드려요"
        case 1...2:
            return "더 많은 영화를 찜하시면 맞춤 추천이 정확해져요"
        case 3...5:
            return "취향 분석 중... 조금 더 정확한 추천이 가능해요"
        case 6...10:
            return "취향 분석 완료! 맞춤 추천을 제공합니다"
        default:
            return "완벽한 취향 분석! 최고의 맞춤 추천을 제공합니다"
        }
    }
}
