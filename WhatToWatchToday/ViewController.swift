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
    
    var movies: [Movie] = []  // 영화 데이터를 저장할 배열
    var allMovies: [Movie] = []  // 전체 영화 목록 (검색용)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupSearchBar()  // Search Bar 설정 추가
        loadPopularMovies()
    }
    
    func setupUI() {
        // 네비게이션 타이틀 설정
        self.title = "오늘은 뭐 보까?"
        
        // 네비게이션 바 스타일
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // 배경색 설정
        view.backgroundColor = .systemBackground
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
    
    //ㅍSearch Bar 설정
    func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "영화 제목을 검색하세요"
        searchBar.searchBarStyle = .minimal
        searchBar.showsCancelButton = false
    }
    
    // 데이터 로딩
    func loadPopularMovies() {
        print("🎬 인기 영화 목록 로딩 시작...")
        
        TMDBService.shared.fetchPopularMovies { [weak self] result in
            switch result {
            case .success(let movieResponse):
                print("✅ 영화 \(movieResponse.results.count)개 로딩 완료!")
                
                // 메인 스레드에서 UI 업데이트
                DispatchQueue.main.async {
                    self?.allMovies = movieResponse.results  // 전체 목록 저장
                    self?.movies = movieResponse.results     // 표시용 목록
                    self?.movieTableView.reloadData()
                }
                
            case .failure(let error):
                print("❌ 영화 로딩 실패: \(error)")
                
                // 에러 알림 표시
                DispatchQueue.main.async {
                    self?.showErrorAlert(error: error)
                }
            }
        }
    }
    
    // 검색 기능
    func searchMovies(query: String) {
        if query.isEmpty {
            // 검색어가 비어있으면 전체 목록 표시
            movies = allMovies
            movieTableView.reloadData()
            return
        }
        
        print("🔍 영화 검색: \(query)")
        
        TMDBService.shared.searchMovies(query: query) { [weak self] result in
            switch result {
            case .success(let movieResponse):
                print("✅ 검색 결과: \(movieResponse.results.count)개")
                DispatchQueue.main.async {
                    self?.movies = movieResponse.results
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
            self.loadPopularMovies()
        })
        
        alert.addAction(UIAlertAction(title: "확인", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // Segue 준비 (데이터 전달)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMovieDetail",
           let destinationVC = segue.destination as? MovieDetailViewController,
           let indexPath = movieTableView.indexPathForSelectedRow {
            
            let selectedMovie = movies[indexPath.row]
            destinationVC.movie = selectedMovie
            print("📤 영화 데이터 전달: \(selectedMovie.title)")
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
}

// UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    // 행의 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    // 각 행에 표시할 셀 (포스터 오류 수정됨)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        let movie = movies[indexPath.row]
        
        // 셀 내용 설정
        cell.textLabel?.text = movie.title
        cell.detailTextLabel?.text = "\(movie.releaseYear) ⭐ \(movie.formattedRating)"
        
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
            if let urlString = movie.fullPosterURL {
                ImageCache.shared.cancelDownload(for: urlString)
            }
            
            // 실제 포스터 이미지 로딩
            ImageCache.shared.loadImage(from: movie.fullPosterURL) { [weak imageView] loadedImage in
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
        tableView.deselectRow(at: indexPath, animated: true)  // 선택 효과 제거
        
        let selectedMovie = movies[indexPath.row]
        print("🎯 선택된 영화: \(selectedMovie.title)")
    }
}

// UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    
    // 검색 버튼을 눌렀을 때
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        searchMovies(query: searchText)
        searchBar.resignFirstResponder()  // 키보드 숨기기
    }
    
    // 검색어가 변경될 때 (실시간 검색 - 선택사항)
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            // 검색어가 비어있으면 전체 목록 표시
            movies = allMovies
            movieTableView.reloadData()
        } else if searchText.count >= 2 {
            // 2글자 이상일 때 검색 (API 호출 줄이기)
            searchMovies(query: searchText)
        }
    }
    
    // 취소 버튼을 눌렀을 때
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        movies = allMovies  // 전체 목록으로 복원
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
