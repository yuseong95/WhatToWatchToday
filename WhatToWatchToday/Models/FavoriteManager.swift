//
//  FavoriteManager.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/8/25.
//  찜하기 기능을 관리하는 매니저 클래스
//

import Foundation

// 찜한 미디어 아이템 (저장용)
struct FavoriteItem: Codable {
    let id: Int
    let title: String
    let mediaType: String  // "movie" 또는 "tv"
    let posterPath: String?
    let releaseDate: String
    let voteAverage: Double
    let overview: String
    let addedDate: Date  // 찜한 날짜
    
    // MediaItem에서 FavoriteItem으로 변환
    init(from mediaItem: MediaItem) {
        self.id = mediaItem.id
        self.title = mediaItem.displayTitle
        self.mediaType = mediaItem.mediaType
        self.posterPath = mediaItem.posterPath
        self.releaseDate = mediaItem.displayDate
        self.voteAverage = mediaItem.voteAverage ?? 0.0
        self.overview = mediaItem.displayOverview
        self.addedDate = Date()
    }
    
    // Movie에서 FavoriteItem으로 변환
    init(from movie: Movie, mediaType: String = "movie") {
        self.id = movie.id
        self.title = movie.title
        self.mediaType = mediaType
        self.posterPath = movie.posterPath
        self.releaseDate = movie.releaseDate
        self.voteAverage = movie.voteAverage
        self.overview = movie.overview
        self.addedDate = Date()
    }
}

// 편의 기능들
extension FavoriteItem {
    // 포스터 이미지 전체 URL
    var fullPosterURL: String? {
        guard let posterPath = posterPath else { return nil }
        return Config.imageBaseURL + posterPath
    }
    
    // 평점 포맷
    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }
    
    // 개봉 연도
    var releaseYear: String {
        String(releaseDate.prefix(4))
    }
    
    // 미디어 타입 한글
    var mediaTypeKorean: String {
        switch mediaType {
        case "movie": return "영화"
        case "tv": return "TV"
        default: return "기타"
        }
    }
    
    // MediaItem으로 변환
    func toMediaItem() -> MediaItem {
        return MediaItem(
            id: id, mediaType: mediaType,
            title: mediaType == "movie" ? title : nil,
            name: mediaType == "tv" ? title : nil,
            overview: overview, releaseDate: mediaType == "movie" ? releaseDate : nil,
            firstAirDate: mediaType == "tv" ? releaseDate : nil,
            posterPath: posterPath, backdropPath: nil,
            voteAverage: voteAverage, voteCount: nil, popularity: nil,
            genreIds: nil, adult: nil, originalLanguage: nil,
            originalTitle: mediaType == "movie" ? title : nil,
            originalName: mediaType == "tv" ? title : nil
        )
    }
}

// 찜하기 매니저 - 싱글톤 패턴
class FavoriteManager {
    static let shared = FavoriteManager()
    private init() {}
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "FavoriteMovies"
    
    // 찜 목록 알림
    static let favoritesDidChange = Notification.Name("FavoritesDidChange")
    
    // 현재 찜 목록 가져오기
    func getFavorites() -> [FavoriteItem] {
        guard let data = userDefaults.data(forKey: favoritesKey) else {
            print("💾 찜 목록 데이터가 없습니다")
            return []
        }
        
        do {
            let favorites = try JSONDecoder().decode([FavoriteItem].self, from: data)
            print("💾 찜 목록 로딩: \(favorites.count)개")
            return favorites.sorted { $0.addedDate > $1.addedDate }  // 최신순 정렬
        } catch {
            print("❌ 찜 목록 디코딩 실패: \(error)")
            return []
        }
    }
    
    // 찜 목록 저장
    private func saveFavorites(_ favorites: [FavoriteItem]) {
        do {
            let data = try JSONEncoder().encode(favorites)
            userDefaults.set(data, forKey: favoritesKey)
            print("💾 찜 목록 저장 완료: \(favorites.count)개")
            
            // 찜 목록 변경 알림
            NotificationCenter.default.post(name: FavoriteManager.favoritesDidChange, object: nil)
        } catch {
            print("❌ 찜 목록 저장 실패: \(error)")
        }
    }
    
    // 찜하기 추가
    func addToFavorites(_ item: FavoriteItem) {
        var favorites = getFavorites()
        
        // 이미 찜한 항목인지 확인
        if !isFavorite(id: item.id, mediaType: item.mediaType) {
            favorites.append(item)
            saveFavorites(favorites)
            print("❤️ 찜 추가: \(item.title)")
        } else {
            print("⚠️ 이미 찜한 항목: \(item.title)")
        }
    }
    
    // 찜하기 제거
    func removeFromFavorites(id: Int, mediaType: String) {
        var favorites = getFavorites()
        favorites.removeAll { $0.id == id && $0.mediaType == mediaType }
        saveFavorites(favorites)
        print("💔 찜 제거: ID \(id), 타입 \(mediaType)")
    }
    
    // 찜 상태 확인
    func isFavorite(id: Int, mediaType: String) -> Bool {
        let favorites = getFavorites()
        return favorites.contains { $0.id == id && $0.mediaType == mediaType }
    }
    
    // 찜하기 토글 (추가/제거)
    func toggleFavorite(for item: FavoriteItem) -> Bool {
        if isFavorite(id: item.id, mediaType: item.mediaType) {
            removeFromFavorites(id: item.id, mediaType: item.mediaType)
            return false  // 제거됨
        } else {
            addToFavorites(item)
            return true   // 추가됨
        }
    }
    
    // 찜 목록 전체 삭제
    func clearAllFavorites() {
        userDefaults.removeObject(forKey: favoritesKey)
        NotificationCenter.default.post(name: FavoriteManager.favoritesDidChange, object: nil)
        print("🗑️ 모든 찜 목록 삭제")
    }
    
    // 찜 목록 개수
    func favoritesCount() -> Int {
        return getFavorites().count
    }
}

// 편의 메서드들
extension FavoriteManager {
    
    // MediaItem으로 찜하기 추가
    func addToFavorites(from mediaItem: MediaItem) {
        let favoriteItem = FavoriteItem(from: mediaItem)
        addToFavorites(favoriteItem)
    }
    
    // Movie로 찜하기 추가
    func addToFavorites(from movie: Movie, mediaType: String = "movie") {
        let favoriteItem = FavoriteItem(from: movie, mediaType: mediaType)
        addToFavorites(favoriteItem)
    }
    
    // MediaItem 찜 상태 확인
    func isFavorite(_ mediaItem: MediaItem) -> Bool {
        return isFavorite(id: mediaItem.id, mediaType: mediaItem.mediaType)
    }
    
    // Movie 찜 상태 확인
    func isFavorite(_ movie: Movie, mediaType: String = "movie") -> Bool {
        return isFavorite(id: movie.id, mediaType: mediaType)
    }
}
