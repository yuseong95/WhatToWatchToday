//
//  MovieDetail.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/7/25.
//  영화 상세 정보를 위한 확장 모델
//

import Foundation

// 장르 정보
struct Genre: Codable {
    let id: Int
    let name: String
}

// 제작 국가
struct ProductionCountry: Codable {
    let iso31661: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case iso31661 = "iso_3166_1"
        case name
    }
}

// 사용 언어
struct SpokenLanguage: Codable {
    let iso6391: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case iso6391 = "iso_639_1"
        case name
    }
}

// 영화 상세 정보
struct MovieDetail: Codable {
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
    let runtime: Int?                    // 상영시간 (분)
    let genres: [Genre]                  // 장르 배열
    let productionCountries: [ProductionCountry]  // 제작국가
    let spokenLanguages: [SpokenLanguage]         // 사용언어
    let budget: Int                      // 제작비
    let revenue: Int                     // 수익
    let homepage: String?                // 홈페이지
    let imdbId: String?                  // IMDB ID
    let status: String                   // 상태 (Released, etc.)
    let tagline: String?                 // 태그라인
    
    enum CodingKeys: String, CodingKey {
        case id, title, overview, popularity, adult, runtime, genres, budget, revenue, homepage, status, tagline
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
extension MovieDetail {
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
    
    // 상영시간 포맷 (예: "2시간 30분")
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
    
    // 장르 문자열 (예: "액션, 모험, SF")
    var genreString: String {
        if genres.isEmpty {
            return "장르 정보 없음"
        }
        return genres.map { $0.name }.joined(separator: ", ")
    }
    
    // 제작국가 문자열
    var countryString: String {
        if productionCountries.isEmpty {
            return "정보 없음"
        }
        return productionCountries.map { $0.name }.joined(separator: ", ")
    }
}
