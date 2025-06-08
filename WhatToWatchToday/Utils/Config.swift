//
//  Config.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/6/25.
//
// API 키와 기본 설정들을 관리하는 파일

import Foundation

struct Config {
    static let tmdbAPIKey = "8393729c6de676934ea13f753a94afd0"
    
    // TMDB API의 기본 URL들
    static let baseURL = "https://api.themoviedb.org/3"
    static let imageBaseURL = "https://image.tmdb.org/t/p/w500"
    
    // 앱에서 사용할 기본 설정들
    static let itemsPerPage = 20
}

// API Endpoints (나중에 사용할 주소들)
extension Config {
    static let popularMoviesURL = "\(baseURL)/movie/popular"
    static let searchMoviesURL = "\(baseURL)/search/movie"
    static let movieDetailURL = "\(baseURL)/movie"
    static let multiSearchURL = "\(baseURL)/search/multi"
}
