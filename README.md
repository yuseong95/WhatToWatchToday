# 오늘은 뭐 보까?
## 무비 큐레이션 & 스낵 추천 iOS 어플리케이션

**2091018 나유성**

---

## 1. 프로젝트 수행 목적

### 1.1 프로젝트 정의
* TMDB API를 활용한 영화/TV 프로그램 추천 및 간식 추천 iOS 어플리케이션

### 1.2 프로젝트 배경
* 하루를 마치고 '오늘은 어떤 걸 볼까?'라는 고민은 누구나 겪는 일상적인 문제이다. 하지만 때로는 너무 많은 선택지 속에서 결정을 내리기 어려울 때가 있다.
* 기존 OTT 플랫폼들은 각각 다른 콘텐츠를 제공하여 사용자가 여러 플랫폼을 확인해야 하는 번거로움이 있다.
* 영화 감상 시 어울리는 간식을 고르는 것 또한 소소한 고민거리 중 하나이다.
* 개인의 취향을 분석하여 맞춤형 추천을 제공하는 서비스의 필요성이 증가하고 있다.

### 1.3 프로젝트 목표
* **통합 검색 시스템**
  * 영화와 TV 프로그램을 한 번에 검색할 수 있는 멀티 미디어 검색 기능 구현
* **개인화된 추천 시스템**
  * 사용자의 찜 목록을 분석하여 선호 장르 기반 맞춤 영화 추천
* **편의성 향상**
  * 직관적인 UI/UX로 빠르고 편리한 콘텐츠 탐색 경험 제공
* **재미 요소 추가**
  * 영화 관람에 어울리는 간식 랜덤 추천으로 소소한 즐거움 제공

---

## 2. 프로젝트 개요

### 2.1 프로젝트 설명
* TMDB(The Movie Database) API를 활용하여 실시간 인기 영화 및 TV 프로그램 정보를 제공한다.
* 사용자가 찜한 콘텐츠의 장르를 분석하여 개인 취향에 맞는 영화를 추천한다.
* 4가지 카테고리(인기 영화, 한국 TV, 찜 목록, 맞춤 추천)로 구분하여 다양한 콘텐츠를 제공한다.
* 간식 추천 시스템을 통해 영화 관람의 재미를 더한다.
  * 카테고리별 간식 분류 (달콤한 간식, 짭짤한 간식, 음료, 야식, 건강한 간식)
  * 랜덤 추천과 카테고리별 추천 기능
  * 플로팅 버튼을 통한 쉬운 접근성

### 2.2 프로젝트 구조
<img width="560" alt="struct" src="https://github.com/user-attachments/assets/4395256d-a51e-467f-8c9b-0183b277c70a" />


### 2.3 결과물

#### 메인 화면
- 4개 카테고리 탭 (🎬 인기 영화, 📺 한국TV, ❤️ 찜목록, 🎯 맞춤추천)
- 실시간 검색 기능
- 무한 스크롤 목록
- 플로팅 간식 추천 버튼
<img width="372" alt="main1" src="https://github.com/user-attachments/assets/3cacb66b-07dd-4a46-b51c-0e7a464c850e" />


#### 상세 정보 화면
- 고해상도 포스터 이미지
- 영화/TV 프로그램 기본 정보 (제목, 개봉일, 평점, 상영시간, 장르)
- 접기/펼치기 가능한 줄거리
- 주요 배우 정보 (가로 스크롤)
- 찜하기/찜 해제 기능
<img width="372" alt="detail1" src="https://github.com/user-attachments/assets/b3f843f5-ee10-4fa1-a048-bc8149518f64" />



#### 찜 목록 관리 화면
- 개인화된 찜 목록 표시
- 정렬 기능 (최신순, 제목순, 평점순)
- 스와이프 삭제
- 일괄 삭제 기능
<img width="372" alt="zzim1" src="https://github.com/user-attachments/assets/8eb02a3f-d994-449f-8760-8f74e66d7ef8" />


#### 간식 추천 화면
- 완전 랜덤 추천
- 카테고리별 추천
- 전체 간식 목록 보기
- 다시 뽑기 기능
<img width="298" alt="snack" src="https://github.com/user-attachments/assets/117776ac-cc4b-4864-8e5e-0dfaf4bc980e" />




### 2.4 기대효과
* **콘텐츠 탐색의 효율성 증대**: 여러 플랫폼을 돌아다니지 않고 한 곳에서 다양한 콘텐츠 정보를 확인할 수 있다.
* **개인화된 추천 경험**: 사용자의 취향을 분석하여 맞춤형 콘텐츠를 추천함으로써 만족도를 높일 수 있다.
* **의사결정 시간 단축**: 명확한 카테고리 분류와 직관적인 인터페이스로 빠른 콘텐츠 선택이 가능하다.
* **사용자 참여도 향상**: 간식 추천과 같은 재미 요소로 앱 사용의 즐거움을 증가시킬 수 있다.
* **지속적인 사용 유도**: 찜 목록 관리와 맞춤 추천 기능으로 지속적인 앱 사용을 유도할 수 있다.

### 2.5 관련 기술

| 구분 | 설명 |
|------|------|
| **RESTful API** | TMDB에서 제공하는 REST API를 통해 영화 및 TV 프로그램 데이터를 실시간으로 가져오는 기술. JSON 형태의 응답 데이터를 파싱하여 앱에서 활용한다. |
| **이미지 캐싱** | NSCache를 활용한 메모리 기반 이미지 캐싱 시스템으로, 네트워크 요청을 최소화하고 사용자 경험을 향상시키는 기술이다. |
| **데이터 지속성** | UserDefaults를 활용하여 사용자의 찜 목록을 디바이스에 영구 저장하는 기술로, 앱 재실행 후에도 데이터가 유지된다. |
| **페이지네이션** | 대용량 데이터를 페이지 단위로 나누어 로딩하는 기술로, 메모리 사용량을 최적화하고 무한 스크롤 기능을 구현한다. |
| **추천 알고리즘** | 사용자의 찜 목록에서 장르 패턴을 분석하여 선호도를 계산하고, 이를 기반으로 맞춤형 콘텐츠를 추천하는 기계학습 기반 알고리즘이다. |

### 2.6 개발 도구

| 구분 | 설명 |
|------|------|
| **Xcode** | Apple에서 개발한 iOS 개발을 위한 통합 개발 환경(IDE)으로, Swift 언어를 사용하여 네이티브 iOS 앱을 개발할 수 있다. Interface Builder를 통한 UI 설계와 Simulator를 통한 테스트가 가능하다. |
| **Swift** | Apple에서 개발한 현대적인 프로그래밍 언어로, 안전성과 성능을 모두 갖춘 iOS 앱 개발의 표준 언어이다. 타입 안정성과 메모리 관리의 자동화가 특징이다. |
| **UIKit** | iOS 앱의 사용자 인터페이스를 구축하기 위한 Apple의 프레임워크로, View Controller, Table View, Navigation 등 UI 컴포넌트들을 제공한다. |
| **Foundation** | Swift의 기본 데이터 타입과 컬렉션, 네트워킹, 파일 시스템 접근 등 핵심 기능을 제공하는 Apple의 기본 프레임워크이다. |
| **URLSession** | HTTP/HTTPS 네트워크 통신을 위한 Apple의 네트워킹 API로, 비동기 데이터 전송과 다운로드, 업로드 기능을 제공한다. |
| **TMDB API** | The Movie Database에서 제공하는 영화 및 TV 프로그램 정보 API로, 실시간 데이터 조회, 검색, 상세 정보 제공 등의 기능을 제공한다. |

### 2.7 핵심 기능 구현

#### 2.7.1 TMDB API 연동
```swift
class TMDBService {
    static let shared = TMDBService()
    
    func fetchPopularMovies(completion: @escaping (Result<MovieResponse, TMDBError>) -> Void) {
        // API 호출 및 데이터 파싱
    }
    
    func searchMulti(query: String, completion: @escaping (Result<MultiSearchResponse, TMDBError>) -> Void) {
        // 통합 검색 기능
    }
}
```

#### 2.7.2 이미지 캐싱 시스템
```swift
class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    func loadImage(from urlString: String?, completion: @escaping (UIImage?) -> Void) {
        // 캐시 확인 → 네트워크 다운로드 → 캐시 저장
    }
}
```

#### 2.7.3 맞춤 추천 알고리즘
```swift
class RecommendationManager {
    func analyzeUserPreferences() -> [TMDBGenre] {
        // 찜한 목록 분석 → 장르 추출 → 선호도 계산
    }
    
    func getRecommendations(completion: @escaping (Result<RecommendationResult, TMDBError>) -> Void) {
        // 선호 장르 기반 영화 추천
    }
}
```
---

## 3. 시연 및 발표 연상
[![오늘은 뭐 보까? - 시연 영상](https://img.youtube.com/vi/hlOYoiA3COM/maxresdefault.jpg)](https://youtu.be/hlOYoiA3COM)

화면 클릭시 유튜브 영상으로 이동합니다.
