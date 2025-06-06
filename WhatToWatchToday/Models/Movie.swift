//
//  Movie.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/6/25.
//
// TMDB API에서 받아오는 영화 정보를 담는 데이터 모델

import Foundation

// 영화 목록 응답 (API에서 받아오는 전체 구조)
struct MovieResponse: Codable {
    let page: Int
    let results: [Movie] // 실제 영화 배열
    let totalPages: Int
    let totalResults: Int
    
    // API의 JSON 키와 Swift 변수명이 다를 때 매핑
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// 개별 영화 정보
struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String       // 줄거리
    let releaseDate: String    // 개봉일
    let posterPath: String?    // 포스터 이미지 경로 (nil일 수 있음)
    let backdropPath: String?  // 배경 이미지 경로
    let voteAverage: Double    // 평점
    let voteCount: Int         // 투표 수
    let popularity: Double     // 인기도
    let genreIds: [Int]        // 장르 ID 배열
    let adult: Bool            // 성인 영화 여부
    let originalLanguage: String
    let originalTitle: String

    // API의 JSON 키와 Swift 변수명 매핑
    enum CodingKeys: String, CodingKey {
        case id, title, overview, popularity, adult
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genreIds = "genre_ids"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
    }
}

// 편의 기능들
extension Movie {
    // 포스터 이미지 전체 URL 만들기
    var fullPosterURL: String? {
        guard let posterPath = posterPath else { return nil }
        return Config.imageBaseURL + posterPath
    }
    
    // 배경 이미지 전체 URL 만들기
    var fullBackdropURL: String? {
        guard let backdropPath = backdropPath else { return nil }
        return Config.imageBaseURL + backdropPath
    }
    
    // 개봉 연도만 추출
    var releaseYear: String {
        String(releaseDate.prefix(4))  // "2024-05-15" → "2024"
    }
    
    // 평점을 소수점 한 자리로 표시
    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }
    
    // 개봉일을 한국어 형식으로 변환 (나중에 구현)
    var formattedReleaseDate: String {
        // 일단은 그대로 반환, 나중에 DateFormatter 사용해서 개선
        return releaseDate
    }
}

// 샘플 데이터 (테스트용)
extension Movie {
    // 개발할 때 테스트용으로 사용할 더미 데이터
    static let sampleMovie = Movie(
        id: 1,
        title: "테스트 영화",
        overview: "이것은 테스트용 영화 줄거리입니다.",
        releaseDate: "2024-01-01",
        posterPath: "/sample.jpg",
        backdropPath: "/sample_backdrop.jpg",
        voteAverage: 8.5,
        voteCount: 1000,
        popularity: 100.0,
        genreIds: [28, 12],
        adult: false,
        originalLanguage: "ko",
        originalTitle: "Test Movie"
    )
}
