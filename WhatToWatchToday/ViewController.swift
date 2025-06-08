//
//  ViewController.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/6/25.
//
//  영화 목록을 TableView로 보여주는 홈 화면
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var movieTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!  // 새로 추가된 Storyboard Search Bar
    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!

    var mediaItems: [MediaItem] = []  // 미디어 데이터를 저장할 배열
    var allMediaItems: [MediaItem] = []  // 전체 미디어 목록 (검색용)
    
    enum MediaCategory: Int, CaseIterable {
        case movie = 0    // 🎬 영화 순위
        case tv = 1       // 📺 TV 순위
        case favorites = 2 // ❤️ 내 찜 목록
        
        var title: String {
            switch self {
            case .movie: return "🎬 영화 순위"
            case .tv: return "📺 TV 순위"
            case .favorites: return "❤️ 내 찜 목록"
            }
        }
    }
    
    var currentCategory: MediaCategory = .movie
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupSearchBar()  // Search Bar 설정 추가
        loadDataForCategory(currentCategory)
    }
    
    func setupUI() {
        // 네비게이션 타이틀 설정
        self.title = "오늘은 뭐 보까?"
        
        // 네비게이션 바 스타일
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // 배경색 설정
        view.backgroundColor = .systemBackground
        
        // 카테고리 초기 설정
        categorySegmentedControl.selectedSegmentIndex = currentCategory.rawValue
        print("🏠 초기 카테고리: \(currentCategory.title)")
    }
    
    // TableView 설정
    func setupTableView() {
        // 델리게이트 설정 (데이터 소스와 이벤트 처리)
        movieTableView.delegate = self
        movieTableView.dataSource = self
        
        // 기본 셀 등록 (일단 기본 스타일 사용)
        // movieTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MovieCell")
        
        // TableView 스타일 설정
        movieTableView.separatorStyle = .singleLine
        movieTableView.showsVerticalScrollIndicator = true
        
        // 행 높이 설정
        movieTableView.rowHeight = 120  // 포스터 이미지를 위해 높게 설정
    }
    
    // Search Bar 설정
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "영화나 TV 프로그램을 검색하세요"
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = false
    }
    
    // 검색 기능 (MultiSearch 사용)
    func searchMedia(query: String) {
        if query.isEmpty {
            // 검색어가 비어있으면 전체 목록 표시
            mediaItems = allMediaItems
            movieTableView.reloadData()
            return
        }
        
        print("🔍 통합 검색: \(query)")
        
        TMDBService.shared.searchMulti(query: query) { [weak self] result in
            switch result {
            case .success(let multiSearchResponse):
                print("✅ 검색 결과: \(multiSearchResponse.results.count)개")
                DispatchQueue.main.async {
                    self?.mediaItems = multiSearchResponse.results
                    self?.movieTableView.reloadData()
                }
            case .failure(let error):
                print("❌ 검색 실패: \(error)")
                DispatchQueue.main.async {
                    self?.showErrorAlert(error: error)
                }
            }
        }
    }
    
    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        guard let category = MediaCategory(rawValue: sender.selectedSegmentIndex) else { return }
        
        currentCategory = category
        print("🔄 카테고리 변경: \(category.title)")
        
        // 네비게이션 바 초기화
        if category != .favorites {
            setupFavoritesNavigationBar(count: 0)
        }
        
        // 카테고리별 데이터 로딩
        loadDataForCategory(category)
    }
    
    func loadDataForCategory(_ category: MediaCategory) {
        switch category {
        case .movie:
            loadPopularMovies()
        case .tv:
            loadPopularTV()
        case .favorites:
            loadFavorites()
        }
    }
    
    func loadPopularMovies() {
        print("🎬 인기 영화 로딩...")
        
        TMDBService.shared.fetchPopularMovies { [weak self] result in
            switch result {
            case .success(let movieResponse):
                print("✅ 영화 \(movieResponse.results.count)개 로딩 완료!")
                
                // ✅ 영화 20개 전체 사용
                let mediaItems = movieResponse.results.map { movie in
                    self?.convertMovieToMediaItem(movie) ?? MediaItem(
                        id: movie.id, mediaType: "movie", title: movie.title, name: nil,
                        overview: movie.overview, releaseDate: movie.releaseDate, firstAirDate: nil,
                        posterPath: movie.posterPath, backdropPath: movie.backdropPath,
                        voteAverage: movie.voteAverage, voteCount: movie.voteCount,
                        popularity: movie.popularity, genreIds: movie.genreIds, adult: movie.adult,
                        originalLanguage: movie.originalLanguage, originalTitle: movie.originalTitle, originalName: nil
                    )
                }
                
                DispatchQueue.main.async {
                    self?.allMediaItems = mediaItems
                    self?.mediaItems = mediaItems
                    self?.movieTableView.reloadData()
                }
                
            case .failure(let error):
                print("❌ 영화 로딩 실패: \(error)")
                DispatchQueue.main.async {
                    self?.showErrorAlert(error: error)
                }
            }
        }
    }
    
    func loadPopularTV() {
        print("📺 인기 TV 프로그램 로딩...")
        // TODO: TV 프로그램 로딩 (나중에 구현)
        TMDBService.shared.fetchPopularTV { [weak self] result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self?.mediaItems = response.results
                    self?.movieTableView.reloadData()
                }
            case .failure(let error):
                print("❌ TV 로딩 실패: \(error)")
            }
        }
    }
    
    func loadFavorites() {
        print("❤️ 찜 목록 로딩...")
        
        let favorites = FavoriteManager.shared.getFavorites()
        let mediaItems = favorites.map { $0.toMediaItem() }
        
        DispatchQueue.main.async {
            self.allMediaItems = mediaItems
            self.mediaItems = mediaItems
            self.movieTableView.reloadData()
            
            // 찜목록일 때 네비게이션 바 설정
            self.setupFavoritesNavigationBar(count: mediaItems.count)
            
            print("✅ 찜 목록: \(mediaItems.count)개")
        }
    }
    
    // 찜목록 전용 네비게이션 바 설정
    func setupFavoritesNavigationBar(count: Int) {
        if currentCategory == .favorites {
            if count > 0 {
                // 찜 목록이 있을 때 - 정렬/삭제 버튼 표시
                let sortButton = UIBarButtonItem(
                    image: UIImage(systemName: "arrow.up.arrow.down"),
                    style: .plain,
                    target: self,
                    action: #selector(showSortOptions)
                )
                
                let clearButton = UIBarButtonItem(
                    image: UIImage(systemName: "trash"),
                    style: .plain,
                    target: self,
                    action: #selector(showClearAlert)
                )
                
                navigationItem.rightBarButtonItems = [clearButton, sortButton]
                navigationItem.title = "❤️ 찜목록 (\(count)개)"
            } else {
                // 찜 목록이 비어있을 때
                navigationItem.rightBarButtonItems = nil
                navigationItem.title = "❤️ 찜목록 (비어있음)"
            }
        } else {
            // 다른 탭일 때는 기본 상태
            navigationItem.rightBarButtonItems = nil
            navigationItem.title = "오늘은 뭐 보까?"
        }
    }

    // 정렬 옵션 표시
    @objc func showSortOptions() {
        let alert = UIAlertController(title: "정렬 방식", message: "어떤 방식으로 정렬하시겠습니까?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "최신순", style: .default) { _ in
            self.sortFavorites(by: .newest)
        })
        
        alert.addAction(UIAlertAction(title: "제목순", style: .default) { _ in
            self.sortFavorites(by: .title)
        })
        
        alert.addAction(UIAlertAction(title: "평점순", style: .default) { _ in
            self.sortFavorites(by: .rating)
        })
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        // iPad에서 crash 방지
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItems?.last
        }
        
        present(alert, animated: true)
    }

    // 전체 삭제 확인
    @objc func showClearAlert() {
        clearAllFavorites()
    }

    // 에러 처리
    func showErrorAlert(error: TMDBError) {
        let message: String
        
        switch error {
        case .invalidURL:
            message = "잘못된 요청입니다."
        case .noData:
            message = "데이터를 받을 수 없습니다."
        case .decodingFailed:
            message = "데이터 처리에 실패했습니다."
        case .networkError(let networkError):
            message = "네트워크 오류: \(networkError.localizedDescription)"
        }
        
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "다시 시도", style: .default) { _ in
            self.loadDataForCategory(self.currentCategory)
        })
        
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // Segue 준비 (데이터 전달)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTableMovieDetail",
           let destinationVC = segue.destination as? TableMovieDetailViewController,
           let indexPath = movieTableView.indexPathForSelectedRow {
            
            let selectedMediaItem = mediaItems[indexPath.row]
            
            // MediaItem을 Movie로 변환해서 전달
            let movie = convertMediaItemToMovie(selectedMediaItem)
            destinationVC.movie = movie
            destinationVC.mediaType = selectedMediaItem.mediaType
            print("📤 미디어 데이터 전달: \(selectedMediaItem.displayTitle), 타입: \(selectedMediaItem.mediaType)")
        }
    }
    
    // 헬퍼 메서드들
    
    // 고정 크기의 플레이스홀더 이미지 생성
    func createPlaceholderImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // 배경색 설정
            UIColor.systemGray5.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // 아이콘 그리기
            if let icon = UIImage(systemName: "photo.fill") {
                let iconSize: CGFloat = min(size.width, size.height) * 0.3
                let iconRect = CGRect(
                    x: (size.width - iconSize) / 2,
                    y: (size.height - iconSize) / 2,
                    width: iconSize,
                    height: iconSize
                )
                
                UIColor.systemGray3.setFill()
                icon.draw(in: iconRect)
            }
        }
    }
    
    // Movie를 MediaItem으로 변환하는 헬퍼 메서드
    func convertMovieToMediaItem(_ movie: Movie) -> MediaItem {
        return MediaItem(
            id: movie.id,
            mediaType: "movie",
            title: movie.title,
            name: nil,
            overview: movie.overview,
            releaseDate: movie.releaseDate,
            firstAirDate: nil,
            posterPath: movie.posterPath,
            backdropPath: movie.backdropPath,
            voteAverage: movie.voteAverage,
            voteCount: movie.voteCount,
            popularity: movie.popularity,
            genreIds: movie.genreIds,
            adult: movie.adult,
            originalLanguage: movie.originalLanguage,
            originalTitle: movie.originalTitle,
            originalName: nil
        )
    }
    
    // MediaItem을 Movie로 변환하는 헬퍼 메서드 (상세화면 호환성을 위해)
    func convertMediaItemToMovie(_ mediaItem: MediaItem) -> Movie {
        return Movie(
            id: mediaItem.id,
            title: mediaItem.displayTitle,
            overview: mediaItem.displayOverview,
            releaseDate: mediaItem.displayDate,
            posterPath: mediaItem.posterPath,
            backdropPath: mediaItem.backdropPath,
            voteAverage: mediaItem.voteAverage ?? 0.0,
            voteCount: mediaItem.voteCount ?? 0,
            popularity: mediaItem.popularity ?? 0.0,
            genreIds: mediaItem.genreIds ?? [],
            adult: mediaItem.adult ?? false,
            originalLanguage: mediaItem.originalLanguage ?? "en",
            originalTitle: mediaItem.originalTitle ?? mediaItem.displayTitle
        )
    }
}

// UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    // 행의 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mediaItems.count
    }
    
    // 각 행에 표시할 셀 (포스터 오류 수정됨)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        let mediaItem = mediaItems[indexPath.row]
        
        // 셀 내용 설정
        cell.textLabel?.text = mediaItem.displayTitle
        cell.detailTextLabel?.text = "\(mediaItem.displayYear) ⭐ \(mediaItem.formattedRating) (\(mediaItem.mediaTypeKorean))"
        
        // 셀 스타일 설정
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = .systemGray
        
        // 선택 스타일
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator  // > 화살표 표시
        
        // ✅ 포스터 이미지 로딩 (오류 수정됨)
        if let imageView = cell.imageView {
            // 고정 크기의 플레이스홀더 이미지 생성
            let placeholderSize = CGSize(width: 80, height: 120)
            let placeholder = createPlaceholderImage(size: placeholderSize)
            
            // ✅ 중요: 먼저 플레이스홀더로 초기화 (셀 재사용 문제 해결)
            imageView.image = placeholder
            
            // 이미지뷰 스타일 설정
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 8
            
            // ✅ 이전 다운로드 작업 취소 (중요!)
            if let urlString = mediaItem.fullPosterURL {
                ImageCache.shared.cancelDownload(for: urlString)
            }
            
            // 실제 포스터 이미지 로딩
            ImageCache.shared.loadImage(from: mediaItem.fullPosterURL) { [weak imageView] loadedImage in
                // ✅ imageView가 아직 유효한지 확인 (셀 재사용 대응)
                guard let imageView = imageView else { return }
                
                if let loadedImage = loadedImage {
                    // 로딩된 이미지를 고정 크기로 리사이즈
                    let resizedImage = loadedImage.resized(to: placeholderSize)
                    imageView.image = resizedImage
                } else {
                    imageView.image = placeholder
                }
            }
        }
        
        return cell
    }
}

// UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    // 행을 선택했을 때
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedMediaItem = mediaItems[indexPath.row]
        print("🎯 선택된 미디어: \(selectedMediaItem.displayTitle)")
    }
}

// UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    
    // 검색 버튼을 눌렀을 때
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        searchMedia(query: searchText)
        searchBar.resignFirstResponder()  // 키보드 숨기기
    }
    
    // 검색어가 변경될 때 (실시간 검색 - 선택사항)
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // 검색어가 비어있으면 전체 목록 표시
            mediaItems = allMediaItems
            movieTableView.reloadData()
        } else if searchText.count >= 2 {
            // 2글자 이상일 때 검색 (API 호출 줄이기)
            searchMedia(query: searchText)
        }
    }
    
    // 취소 버튼을 눌렀을 때
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        mediaItems = allMediaItems  // 전체 목록으로 복원
        movieTableView.reloadData()
    }
}

// UIImage Extension (이미지 리사이즈용)
extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

// UITableViewDelegate 확장 (스와이프 삭제)
extension ViewController {
    
    // 스와이프 액션 설정 (iOS 11+)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // 찜목록 탭일 때만 스와이프 삭제 활성화
        guard currentCategory == .favorites else {
            return nil
        }
        
        // 찜 해제 액션 생성
        let deleteAction = UIContextualAction(style: .destructive, title: "찜 해제") { [weak self] (action, view, completionHandler) in
            self?.removeFavoriteItem(at: indexPath)
            completionHandler(true)
        }
        
        // 액션 스타일 설정
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "heart.slash.fill")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true  // 전체 스와이프로 바로 삭제
        
        return configuration
    }
    
    // 찜 아이템 제거 메서드
    func removeFavoriteItem(at indexPath: IndexPath) {
        guard currentCategory == .favorites,
              indexPath.row < mediaItems.count else {
            return
        }
        
        let mediaItem = mediaItems[indexPath.row]
        
        // FavoriteManager에서 찜 해제
        FavoriteManager.shared.removeFromFavorites(id: mediaItem.id, mediaType: mediaItem.mediaType)
        
        // 로컬 배열에서도 제거
        mediaItems.remove(at: indexPath.row)
        allMediaItems = mediaItems
        
        // 테이블뷰에서 애니메이션과 함께 행 삭제
        movieTableView.deleteRows(at: [indexPath], with: .fade)
        
        // 피드백 제공
        showRemoveToast(title: mediaItem.displayTitle)
        
        print("💔 찜 해제: \(mediaItem.displayTitle)")
    }
    
    // 찜 해제 토스트 메시지
    func showRemoveToast(title: String) {
        let message = "'\(title)'이(가) 찜 목록에서 제거되었습니다 💔"
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        
        // 2초 후 자동으로 사라지게
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            alert.dismiss(animated: true)
        }
    }
}

// 추가 편의 기능들
extension ViewController {
    
    // 찜목록 전체 삭제 (옵션)
    func clearAllFavorites() {
        let alert = UIAlertController(
            title: "찜 목록 전체 삭제",
            message: "모든 찜 목록을 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
            FavoriteManager.shared.clearAllFavorites()
            self.loadFavorites()  // 목록 새로고침
        })
        
        present(alert, animated: true)
    }
    
    // 찜목록 정렬 (옵션)
    func sortFavorites(by type: FavoriteSortType) {
        guard currentCategory == .favorites else { return }
        
        let favorites = FavoriteManager.shared.getFavorites()
        let sortedFavorites: [FavoriteItem]
        
        switch type {
        case .newest:
            sortedFavorites = favorites.sorted { $0.addedDate > $1.addedDate }
        case .title:
            sortedFavorites = favorites.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .rating:
            sortedFavorites = favorites.sorted { $0.voteAverage > $1.voteAverage }
        }
        
        let mediaItems = sortedFavorites.map { $0.toMediaItem() }
        
        DispatchQueue.main.async {
            self.allMediaItems = mediaItems
            self.mediaItems = mediaItems
            self.movieTableView.reloadData()
        }
    }
}

// 정렬 타입 열거형
enum FavoriteSortType {
    case newest    // 최신순
    case title     // 제목순
    case rating    // 평점순
}
