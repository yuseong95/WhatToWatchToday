//
//  SnackRecommendationManager.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/15/25.
//  간식/야식 랜덤 추천 기능을 관리하는 매니저
//

import Foundation
import UIKit

// 간식 아이템 구조체
struct SnackItem {
    let name: String
    let emoji: String
    let category: SnackCategory
    let description: String
    
    var displayText: String {
        return "\(emoji) \(name)"
    }
}

// 간식 카테고리
enum SnackCategory: String, CaseIterable {
    case sweet = "달콤한 간식"
    case salty = "짭짤한 간식"
    case drink = "음료"
    case meal = "야식"
    case healthy = "건강한 간식"
    
    var emoji: String {
        switch self {
        case .sweet: return "🍭"
        case .salty: return "🍿"
        case .drink: return "🥤"
        case .meal: return "🍜"
        case .healthy: return "🥗"
        }
    }
}

// 간식 추천 매니저
class SnackRecommendationManager {
    
    static let shared = SnackRecommendationManager()
    private init() {}
    
    // 간식 목록
    private let snackDatabase: [SnackItem] = [
        // 달콤한 간식
        SnackItem(name: "팝콘", emoji: "🍿", category: .sweet, description: "영화관의 대표 간식!"),
        SnackItem(name: "초콜릿", emoji: "🍫", category: .sweet, description: "달콤한 행복감을 선사해요"),
        SnackItem(name: "아이스크림", emoji: "🍦", category: .sweet, description: "시원하고 달콤한 디저트"),
        SnackItem(name: "쿠키", emoji: "🍪", category: .sweet, description: "바삭하고 달콤한 간식"),
        SnackItem(name: "케이크", emoji: "🎂", category: .sweet, description: "특별한 날의 달콤함"),
        SnackItem(name: "도넛", emoji: "🍩", category: .sweet, description: "부드럽고 달콤한 간식"),
        SnackItem(name: "젤리", emoji: "🍭", category: .sweet, description: "쫄깃하고 상큼한 간식"),
        
        // 짭짤한 간식
        SnackItem(name: "감자칩", emoji: "🥔", category: .salty, description: "바삭한 식감이 일품"),
        SnackItem(name: "치킨", emoji: "🍗", category: .salty, description: "언제 먹어도 맛있는 치킨"),
        SnackItem(name: "피자", emoji: "🍕", category: .salty, description: "치즈가 가득한 피자"),
        SnackItem(name: "햄버거", emoji: "🍔", category: .salty, description: "든든한 패스트푸드"),
        SnackItem(name: "핫도그", emoji: "🌭", category: .salty, description: "간편하게 즐기는 간식"),
        SnackItem(name: "타코", emoji: "🌮", category: .salty, description: "매콤하고 맛있는 멕시칸 푸드"),
        SnackItem(name: "나초", emoji: "🧀", category: .salty, description: "치즈와 함께하는 바삭함"),
        
        // 음료
        SnackItem(name: "콜라", emoji: "🥤", category: .drink, description: "시원한 탄산음료"),
        SnackItem(name: "커피", emoji: "☕", category: .drink, description: "향긋한 카페인 충전"),
        SnackItem(name: "맥주", emoji: "🍺", category: .drink, description: "시원한 맥주 한 잔"),
        SnackItem(name: "우유", emoji: "🥛", category: .drink, description: "건강한 우유"),
        SnackItem(name: "주스", emoji: "🧃", category: .drink, description: "상큼한 과일 주스"),
        SnackItem(name: "차", emoji: "🍵", category: .drink, description: "따뜻한 차 한 잔"),
        SnackItem(name: "스무디", emoji: "🥤", category: .drink, description: "과일과 야채로 만든 스무디"),
        
        // 야식
        SnackItem(name: "라면", emoji: "🍜", category: .meal, description: "든든한 야식의 대표"),
        SnackItem(name: "떡볶이", emoji: "🌶️", category: .meal, description: "매콤달콤한 간식"),
        SnackItem(name: "만두", emoji: "🥟", category: .meal, description: "쫄깃한 만두"),
        SnackItem(name: "치킨", emoji: "🍗", category: .meal, description: "야식의 왕 치킨"),
        SnackItem(name: "보쌈", emoji: "🥓", category: .meal, description: "든든한  야식"),
        SnackItem(name: "족발", emoji: "🦶", category: .meal, description: "쫄깃한 족발"),
        
        // 건강한 간식
        SnackItem(name: "과일", emoji: "🍎", category: .healthy, description: "비타민이 풍부한 과일"),
        SnackItem(name: "견과류", emoji: "🥜", category: .healthy, description: "영양가 있는 견과류"),
        SnackItem(name: "요거트", emoji: "🍶", category: .healthy, description: "유산균이 풍부한 요거트"),
        SnackItem(name: "샐러드", emoji: "🥗", category: .healthy, description: "신선한 채소 샐러드"),
    ]
    
    // 🎲 랜덤 간식 추천
    func getRandomSnack() -> SnackItem {
        return snackDatabase.randomElement() ?? SnackItem(
            name: "팝콘",
            emoji: "🍿",
            category: .sweet,
            description: "영화관의 대표 간식!"
        )
    }
    
    // 카테고리별 랜덤 추천
    func getRandomSnack(from category: SnackCategory) -> SnackItem {
        let filteredSnacks = snackDatabase.filter { $0.category == category }
        return filteredSnacks.randomElement() ?? getRandomSnack()
    }
    
    // 카테고리별 간식 개수
    func getSnackCount(for category: SnackCategory) -> Int {
        return snackDatabase.filter { $0.category == category }.count
    }
    
    // 전체 간식 목록
    func getAllSnacks() -> [SnackItem] {
        return snackDatabase
    }
    
    // 카테고리별 간식 목록
    func getSnacks(for category: SnackCategory) -> [SnackItem] {
        return snackDatabase.filter { $0.category == category }
    }
    
    // 예쁜 추천 메시지 생성
    func createRecommendationMessage(for snack: SnackItem) -> (title: String, message: String) {
        let titles = [
            "🎬 오늘의 간식 추천!",
            "🍿 완벽한 조합을 찾았어요!",
            "✨ 이건 어떠세요?",
            "🎯 딱 맞는 간식이에요!",
            "🌟 오늘은 이걸로!"
        ]
        
        let randomTitle = titles.randomElement() ?? titles[0]
        let message = """
        \(snack.displayText)
        
        \(snack.description)
        
        카테고리: \(snack.category.emoji) \(snack.category.rawValue)
        """
        
        return (title: randomTitle, message: message)
    }
}

// UIViewController Extension for easy snack recommendation
extension UIViewController {
    
    // 간식 추천 팝업 표시
    func showSnackRecommendation() {
        let snack = SnackRecommendationManager.shared.getRandomSnack()
        let (title, message) = SnackRecommendationManager.shared.createRecommendationMessage(for: snack)
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // 다시 뽑기 버튼
        alert.addAction(UIAlertAction(title: "🎲 다시 뽑기", style: .default) { _ in
            self.showSnackRecommendation()  // 재귀 호출로 다시 뽑기
        })
        
        // 확인 버튼
        alert.addAction(UIAlertAction(title: "👍 좋아요!", style: .cancel))
        
        present(alert, animated: true)
        
        print("🍿 간식 추천: \(snack.displayText)")
    }
    
    // 카테고리별 간식 추천 팝업
    func showCategorySnackRecommendation() {
        let categoryAlert = UIAlertController(
            title: "🍿 어떤 종류의 간식을 원하세요?",
            message: "카테고리를 선택해주세요",
            preferredStyle: .actionSheet
        )
        
        // 각 카테고리별 액션 추가
        for category in SnackCategory.allCases {
            let count = SnackRecommendationManager.shared.getSnackCount(for: category)
            let actionTitle = "\(category.emoji) \(category.rawValue) (\(count)개)"
            
            categoryAlert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in
                let snack = SnackRecommendationManager.shared.getRandomSnack(from: category)
                let (title, message) = SnackRecommendationManager.shared.createRecommendationMessage(for: snack)
                
                let resultAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                resultAlert.addAction(UIAlertAction(title: "🎲 같은 카테고리에서 다시", style: .default) { _ in
                    // 같은 카테고리에서 다시 뽑기
                    let anotherSnack = SnackRecommendationManager.shared.getRandomSnack(from: category)
                    let (newTitle, newMessage) = SnackRecommendationManager.shared.createRecommendationMessage(for: anotherSnack)
                    
                    let anotherAlert = UIAlertController(title: newTitle, message: newMessage, preferredStyle: .alert)
                    anotherAlert.addAction(UIAlertAction(title: "👍 좋아요!", style: .cancel))
                    self.present(anotherAlert, animated: true)
                })
                
                resultAlert.addAction(UIAlertAction(title: "👍 좋아요!", style: .cancel))
                
                self.present(resultAlert, animated: true)
            })
        }
        
        // 랜덤 선택 옵션
        categoryAlert.addAction(UIAlertAction(title: "🎲 완전 랜덤으로!", style: .default) { _ in
            self.showSnackRecommendation()
        })
        
        // 취소 버튼
        categoryAlert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(categoryAlert, animated: true)
    }
}
