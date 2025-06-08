//
//  TVResponse.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/8/25.
//  TV 프로그램 목록을 위한 데이터 모델
//

import Foundation

// TV 목록 응답 (Popular TV API용)
struct TVResponse: Codable {
    let page: Int
    let results: [TVItem]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// 개별 TV 프로그램 정보 (목록용)
struct TVItem: Codable {
    let id: Int
    let name: String                // TV는 title 대신 name
    let overview: String?
    let firstAirDate: String?       // TV는 releaseDate 대신 firstAirDate
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let voteCount: Int?
    let popularity: Double?
    let genreIds: [Int]?
    let adult: Bool?
    let originalLanguage: String?
    let originalName: String?
    let originCountry: [String]?    // TV 특화 필드
    
    enum CodingKeys: String, CodingKey {
        case id, name, overview, popularity, adult
        case firstAirDate = "first_air_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case genreIds = "genre_ids"
        case originalLanguage = "original_language"
        case originalName = "original_name"
        case originCountry = "origin_country"
    }
}

// 편의 기능들
extension TVItem {
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
    
    // 첫 방송 연도
    var firstAirYear: String {
        guard let firstAirDate = firstAirDate else { return "" }
        return String(firstAirDate.prefix(4))
    }
    
    // 평점 포맷
    var formattedRating: String {
        guard let voteAverage = voteAverage else { return "0.0" }
        return String(format: "%.1f", voteAverage)
    }
}
