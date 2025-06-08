//
//  TVDetail.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/8/25.
//  TV 프로그램 상세 정보를 위한 데이터 모델
//

import Foundation

// TV 프로그램 상세 정보
struct TVDetail: Codable {
    let id: Int
    let name: String                    // TV는 title 대신 name
    let overview: String?
    let firstAirDate: String?           // TV는 releaseDate 대신 firstAirDate
    let lastAirDate: String?            // 마지막 방송일
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double?
    let voteCount: Int?
    let popularity: Double?
    let adult: Bool?
    let originalLanguage: String?
    let originalName: String?
    
    // TV 특화 정보
    let numberOfEpisodes: Int?          // 총 에피소드 수
    let numberOfSeasons: Int?           // 총 시즌 수
    let episodeRunTime: [Int]?          // 에피소드 길이 (배열)
    let genres: [Genre]?                // 장르
    let productionCountries: [ProductionCountry]?
    let spokenLanguages: [SpokenLanguage]?
    let homepage: String?
    let status: String?                 // "Ended", "Returning Series" 등
    let tagline: String?
    let type: String?                   // "Scripted", "Documentary" 등
    let inProduction: Bool?             // 제작 중인지
    
    // 배우 정보
    let credits: TVCredits?
    
    enum CodingKeys: String, CodingKey {
        case id, name, overview, popularity, adult, genres, homepage, status, tagline, type
        case firstAirDate = "first_air_date"
        case lastAirDate = "last_air_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case originalLanguage = "original_language"
        case originalName = "original_name"
        case numberOfEpisodes = "number_of_episodes"
        case numberOfSeasons = "number_of_seasons"
        case episodeRunTime = "episode_run_time"
        case productionCountries = "production_countries"
        case spokenLanguages = "spoken_languages"
        case inProduction = "in_production"
        case credits
    }
}

// TV 배우 정보 (Movie와 동일하지만 별도 정의)
struct TVCredits: Codable {
    let cast: [CastMember]
    let crew: [CrewMember]
}
