//
//  ViewController.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/6/25.
//
//  임시로 API 테스트를 위한 뷰 컨트롤러
//


import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 화면 배경색 설정
        view.backgroundColor = .systemBackground
        
        // 화면에 테스트 버튼들 추가
        setupTestButtons()
        
        // 앱 시작하자마자 인기 영화 테스트
        print("🎬 API 테스트 시작!")
        testPopularMovies()
    }
    
    // 테스트 버튼들 설정
    func setupTestButtons() {
        // 인기 영화 테스트 버튼
        let popularButton = UIButton(type: .system)
        popularButton.setTitle("인기 영화 테스트", for: .normal)
        popularButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        popularButton.backgroundColor = .systemBlue
        popularButton.setTitleColor(.white, for: .normal)
        popularButton.layer.cornerRadius = 8
        popularButton.addTarget(self, action: #selector(testPopularMoviesButtonTapped), for: .touchUpInside)
        
        // 검색 테스트 버튼
        let searchButton = UIButton(type: .system)
        searchButton.setTitle("영화 검색 테스트", for: .normal)
        searchButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        searchButton.backgroundColor = .systemGreen
        searchButton.setTitleColor(.white, for: .normal)
        searchButton.layer.cornerRadius = 8
        searchButton.addTarget(self, action: #selector(testSearchMoviesButtonTapped), for: .touchUpInside)
        
        // 스택뷰로 버튼들 정렬
        let stackView = UIStackView(arrangedSubviews: [popularButton, searchButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        // 오토레이아웃 설정
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            popularButton.heightAnchor.constraint(equalToConstant: 50),
            searchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // 테스트 메서드들
    
    // 인기 영화 목록 테스트
    func testPopularMovies() {
        print("📱 인기 영화 API 호출 시작...")
        
        TMDBService.shared.fetchPopularMovies { result in
            switch result {
            case .success(let movieResponse):
                print("✅ 성공! 영화 \(movieResponse.results.count)개 받아옴")
                print("📄 총 페이지: \(movieResponse.totalPages)")
                
                // 첫 번째 영화 정보 출력
                if let firstMovie = movieResponse.results.first {
                    print("🎬 첫 번째 영화:")
                    print("   제목: \(firstMovie.title)")
                    print("   평점: \(firstMovie.formattedRating)")
                    print("   개봉년도: \(firstMovie.releaseYear)")
                    print("   포스터 URL: \(firstMovie.fullPosterURL ?? "없음")")
                }
                
            case .failure(let error):
                print("❌ 에러 발생: \(error)")
                self.handleAPIError(error)
            }
        }
    }
    
    // 영화 검색 테스트
    func testSearchMovies() {
        print("🔍 영화 검색 API 호출 시작...")
        
        // "아바타"로 검색 테스트
        TMDBService.shared.searchMovies(query: "아바타") { result in
            switch result {
            case .success(let movieResponse):
                print("✅ 검색 성공! 결과 \(movieResponse.results.count)개")
                
                // 검색 결과 출력
                for (index, movie) in movieResponse.results.prefix(3).enumerated() {
                    print("🎯 검색결과 \(index + 1):")
                    print("   제목: \(movie.title)")
                    print("   개봉년도: \(movie.releaseYear)")
                    print("   평점: \(movie.formattedRating)")
                }
                
            case .failure(let error):
                print("❌ 검색 에러: \(error)")
                self.handleAPIError(error)
            }
        }
    }
    
    // 에러 처리 및 안내
    func handleAPIError(_ error: TMDBError) {
        var message = ""
        
        switch error {
        case .invalidURL:
            message = "잘못된 URL입니다."
        case .noData:
            message = "데이터를 받지 못했습니다."
        case .decodingFailed:
            message = "데이터 변환에 실패했습니다."
        case .networkError(let networkError):
            message = "네트워크 오류: \(networkError.localizedDescription)"
        }
        
        print("🚨 에러 상세: \(message)")
        
        // 사용자에게 알림 표시
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "API 오류", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    // 버튼 액션들
    @objc func testPopularMoviesButtonTapped() {
        print("🔄 인기 영화 다시 테스트")
        testPopularMovies()
    }
    
    @objc func testSearchMoviesButtonTapped() {
        print("🔄 영화 검색 다시 테스트")
        testSearchMovies()
    }
}

