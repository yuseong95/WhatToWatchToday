//
//  MediaItem.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/8/25.
//  영화와 TV 프로그램을 통합한 미디어 아이템
//

import Foundation

// MultiSearch 응답
struct MultiSearchResponse: Codable {
    let page: Int
    let results: [MediaItem]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// 통합 미디어 아이템 (영화 + TV)
struct MediaItem: Codable {
    let id: Int
    let mediaType: String  // "movie" 또는 "tv"
    let title: String?     // 영화 제목
    let name: String?      // TV 프로그램 이름
    let overview: String?
    let releaseDate: String?    // 영화 개봉일
    let firstAirDate: String?   // TV 첫 방송일
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let voteCount: Int?
    let popularity: Double?
    let genreIds: [Int]?
    let adult: Bool?
    let originalLanguage: String?
    let originalTitle: String?  // 영화 원제
    let originalName: String?   // TV 원제
    
    enum CodingKeys: String, CodingKey {
        case id, overview, popularity, adult
        case mediaType = "media_type"
        case title, name
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genreIds = "genre_ids"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case originalName = "original_name"
    }
}

// 편의 기능들
extension MediaItem {
    // 통합 제목
    var displayTitle: String {
        return title ?? name ?? "제목 없음"
    }
    
    // 통합 개봉일/방송일
    var displayDate: String {
        return releaseDate ?? firstAirDate ?? ""
    }
    
    // 개봉 연도
    var displayYear: String {
        String(displayDate.prefix(4))
    }
    
    // 미디어 타입 한글
    var mediaTypeKorean: String {
        switch mediaType {
        case "movie": return "영화"
        case "tv": return "TV"
        default: return "기타"
        }
    }
    
    // 통합 줄거리
    var displayOverview: String {
        return overview ?? "줄거리 정보가 없습니다."
    }
    
    // 포스터 이미지 전체 URL
    var fullPosterURL: String? {
        guard let posterPath = posterPath else { return nil }
        return Config.imageBaseURL + posterPath
    }
    
    // 배경 이미지 전체 URL
    var fullBackdropURL: String? {
        guard let backdropPath = backdropPath else { return nil }
        return Config.imageBaseURL + backdropPath
    }
    
    // 평점 포맷 (안전하게)
    var formattedRating: String {
        guard let voteAverage = voteAverage else { return "0.0" }
        return String(format: "%.1f", voteAverage)
    }
    
    // 개봉일 포맷
    var formattedReleaseDate: String {
        return displayDate
    }
}
