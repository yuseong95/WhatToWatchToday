//
//  MovieDetailWithCredits.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/7/25.
//  배우 정보까지 포함한 통합 영화 상세 정보 모델
//

import Foundation

// 통합 영화 상세 정보 (배우 정보 포함)
struct MovieDetailWithCredits: Codable {
    // 기본 영화 정보
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let adult: Bool
    let originalLanguage: String
    let originalTitle: String
    
    // 상세 정보
    let runtime: Int?
    let genres: [Genre]
    let productionCountries: [ProductionCountry]
    let spokenLanguages: [SpokenLanguage]
    let budget: Int
    let revenue: Int
    let homepage: String?
    let imdbId: String?
    let status: String
    let tagline: String?
    
    // 배우 정보 (append_to_response로 포함됨)
    let credits: MovieCredits?
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, popularity, adult, runtime, genres, budget, revenue, homepage, status, tagline, credits
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case productionCountries = "production_countries"
        case spokenLanguages = "spoken_languages"
        case imdbId = "imdb_id"
    }
}

// 편의 기능들
extension MovieDetailWithCredits {
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
    
    // 개봉 연도
    var releaseYear: String {
        String(releaseDate.prefix(4))
    }
    
    // 평점 포맷
    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }
    
    // 상영시간 포맷
    var formattedRuntime: String {
        guard let runtime = runtime, runtime > 0 else { return "정보 없음" }
        let hours = runtime / 60
        let minutes = runtime % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)시간 \(minutes)분"
        } else if hours > 0 {
            return "\(hours)시간"
        } else {
            return "\(minutes)분"
        }
    }
    
    // 장르 문자열
    var genreString: String {
        if genres.isEmpty {
            return "장르 정보 없음"
        }
        return genres.map { $0.name }.joined(separator: ", ")
    }
    
    // 주요 배우들 (상위 6명)
    var mainCast: [CastMember] {
        guard let credits = credits else { return [] }
        return Array(credits.cast.prefix(6))
    }
    
    // 감독 정보
    var directors: [CrewMember] {
        guard let credits = credits else { return [] }
        return credits.crew.filter { $0.isDirector }
    }
    
    // 감독 이름 문자열
    var directorsString: String {
        let directorNames = directors.map { $0.name }
        return directorNames.isEmpty ? "감독 정보 없음" : directorNames.joined(separator: ", ")
    }
}
