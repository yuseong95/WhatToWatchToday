//
//  MovieDetailViewController.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/7/25.
//
//  영화 상세 정보를 보여주는 화면
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    // @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    var movie: Movie?  // 이전 화면에서 전달받을 영화 정보
    var movieDetail: MovieDetail?
    var isOverviewExpanded = false
    var fullOverviewText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        displayMovieInfo()
        loadMovieDetail()
    }
    
    func setupUI() {
        // 배경색 설정
        view.backgroundColor = .systemBackground
        
        // 네비게이션 바 설정
        navigationItem.largeTitleDisplayMode = .never
        
        print("🎬 MovieDetailViewController 로딩 완료")
    }
    
    func displayMovieInfo() {
        print("🔍 displayMovieInfo 호출됨")
        print("🔍 movie 객체 상태: \(movie == nil ? "nil" : "있음")")
        
        // ✅ IBOutlet 연결 상태 체크
        print("🔗 titleLabel 연결 상태: \(titleLabel == nil ? "nil" : "연결됨")")
        print("🔗 releaseDateLabel 연결 상태: \(releaseDateLabel == nil ? "nil" : "연결됨")")
        print("🔗 ratingLabel 연결 상태: \(ratingLabel == nil ? "nil" : "연결됨")")
        //print("🔗 overviewTextView 연결 상태: \(overviewTextView == nil ? "nil" : "연결됨")")
        
        guard let movie = movie else {
            print("❌ 영화 정보가 없습니다")
            return
        }
        
        // 제목 설정
        titleLabel.text = movie.title
        navigationItem.title = movie.title
        
        // 개봉일 설정
        releaseDateLabel.text = "개봉일: \(movie.formattedReleaseDate)"
        
        // 평점 설정
        ratingLabel.text = "⭐ \(movie.formattedRating) / 10"
        
        // 줄거리 설정
        //overviewTextView.text = movie.overview.isEmpty ? "줄거리 정보가 없습니다." : movie.overview
        fullOverviewText = movie.overview.isEmpty ? "줄거리 정보가 없습니다." : movie.overview
        setupOverviewDisplay()
        
        // 포스터 이미지 로딩
        loadPosterImage()
        
        print("🎬 영화 상세 정보 표시: \(movie.title)")
    }
    
    func displayDetailInfo() {
        guard let movieDetail = movieDetail else { return }
        
        print("🎬 상세 정보 UI 업데이트:")
        print("   상영시간: \(movieDetail.formattedRuntime)")
        print("   장르: \(movieDetail.genreString)")
        
        // 상영시간 표시
        runtimeLabel.text = "🕒 \(movieDetail.formattedRuntime)"
        
        // 장르 표시
        genreLabel.text = "장르: \(movieDetail.genreString)"
    }
    
    // 줄거리 접기/펼치기 기능
    func setupOverviewDisplay() {
        updateOverviewDisplay()
    }
    
    func updateOverviewDisplay() {
        if isOverviewExpanded {
            // 펼친 상태: 전체 텍스트 표시
            overviewLabel.text = fullOverviewText
            overviewLabel.numberOfLines = 0
            toggleButton.setTitle("▲ 접기", for: .normal)
        } else {
            // 접힌 상태: 4줄까지만 표시
            overviewLabel.text = fullOverviewText
            overviewLabel.numberOfLines = 4
            toggleButton.setTitle("▼ 더보기", for: .normal)
        }
    }
    
    func loadPosterImage() {
        guard let movie = movie else { return }
        
        // 기본 이미지 설정
        posterImageView.image = UIImage(systemName: "photo.fill")
        
        // 실제 포스터 이미지 로딩
        ImageCache.shared.loadImage(from: movie.fullPosterURL) { [weak self] loadedImage in
            if let loadedImage = loadedImage {
                self?.posterImageView.image = loadedImage
            }
        }
    }
    
    // 상세 정보 로딩
    func loadMovieDetail() {
        guard let movie = movie else { return }
        
        print("🔍 영화 상세 정보 로딩 시작: \(movie.title)")
        
        TMDBService.shared.fetchMovieDetail(movieId: movie.id) { [weak self] result in
            switch result {
            case .success(let movieDetail):
                print("✅ 상세 정보 로딩 완료")
                print("   상영시간: \(movieDetail.formattedRuntime)")
                print("   장르: \(movieDetail.genreString)")
                
                self?.movieDetail = movieDetail
                
                // UI 업데이트 추가
                DispatchQueue.main.async {
                    self?.displayDetailInfo()
                }
                
            case .failure(let error):
                print("❌ 상세 정보 로딩 실패: \(error)")
            }
        }
    }
    
    // 찜하기 기능 (임시)
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        guard let movie = movie else { return }
        
        print("❤️ 찜하기 버튼 클릭: \(movie.title)")
        
        // 나중에 FavoriteManager로 구현 예정
        let alert = UIAlertController(title: "찜하기", message: "\(movie.title)을(를) 찜했습니다!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func toggleOverviewTapped(_ sender: UIButton) {
        isOverviewExpanded.toggle()  // true ↔ false 전환
        
        UIView.animate(withDuration: 0.3) {
            self.updateOverviewDisplay()
            self.view.layoutIfNeeded()  // 애니메이션 효과
        }
        
        print("📖 줄거리 상태: \(isOverviewExpanded ? "펼침" : "접음")")
    }
}
