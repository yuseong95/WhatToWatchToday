//
//  MovieCredits.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/7/25.
//  영화 배우 및 제작진 정보를 위한 데이터 모델
//

import Foundation

// 전체 크레딧 응답
struct MovieCredits: Codable {
    let cast: [CastMember]      // 배우들
    let crew: [CrewMember]      // 제작진들
}

// 배우 정보
struct CastMember: Codable {
    let id: Int
    let name: String
    let character: String          // 배역명
    let profilePath: String?       // 프로필 사진 경로
    let order: Int                 // 출연진 순서 (주연/조연 구분)
    let creditId: String
    let adult: Bool
    let gender: Int?               // 1: 여성, 2: 남성
    let knownForDepartment: String // "Acting"
    let originalName: String
    let popularity: Double
    let castId: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, character, order, adult, gender, popularity
        case profilePath = "profile_path"
        case creditId = "credit_id"
        case knownForDepartment = "known_for_department"
        case originalName = "original_name"
        case castId = "cast_id"
    }
}

// 제작진 정보
struct CrewMember: Codable {
    let id: Int
    let name: String
    let job: String                // 직책 (Director, Producer, etc.)
    let department: String         // 부서 (Directing, Production, etc.)
    let profilePath: String?       // 프로필 사진 경로
    let creditId: String
    let adult: Bool
    let gender: Int?
    let knownForDepartment: String
    let originalName: String
    let popularity: Double
    
    enum CodingKeys: String, CodingKey {
        case id, name, job, department, adult, gender, popularity
        case profilePath = "profile_path"
        case creditId = "credit_id"
        case knownForDepartment = "known_for_department"
        case originalName = "original_name"
    }
}

// 편의 기능들
extension CastMember {
    // 프로필 사진 전체 URL
    var fullProfileURL: String? {
        guard let profilePath = profilePath else { return nil }
        return Config.imageBaseURL + profilePath
    }
    
    // 성별 문자열
    var genderString: String {
        switch gender {
        case 1: return "여성"
        case 2: return "남성"
        default: return "정보 없음"
        }
    }
    
    // 주연/조연 구분 (order 기준)
    var actorType: String {
        return order < 5 ? "주연" : "조연"
    }
}

extension CrewMember {
    // 프로필 사진 전체 URL
    var fullProfileURL: String? {
        guard let profilePath = profilePath else { return nil }
        return Config.imageBaseURL + profilePath
    }
    
    // 성별 문자열
    var genderString: String {
        switch gender {
        case 1: return "여성"
        case 2: return "남성"
        default: return "정보 없음"
        }
    }
    
    // 감독인지 확인
    var isDirector: Bool {
        return job.lowercased() == "director"
    }
    
    // 제작자인지 확인
    var isProducer: Bool {
        return job.lowercased().contains("producer")
    }
}

// 샘플 데이터 (테스트용)
extension CastMember {
    static let sampleCast = CastMember(
        id: 1,
        name: "김철수",
        character: "주인공",
        profilePath: "/sample.jpg",
        order: 0,
        creditId: "sample123",
        adult: false,
        gender: 2,
        knownForDepartment: "Acting",
        originalName: "Kim Chul-su",
        popularity: 50.0,
        castId: 1
    )
}

extension CrewMember {
    static let sampleCrew = CrewMember(
        id: 2,
        name: "이영희",
        job: "Director",
        department: "Directing",
        profilePath: "/sample2.jpg",
        creditId: "sample456",
        adult: false,
        gender: 1,
        knownForDepartment: "Directing",
        originalName: "Lee Young-hee",
        popularity: 30.0
    )
}
