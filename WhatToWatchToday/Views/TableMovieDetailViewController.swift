//
//  TableMovieDetailViewController.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/7/25.
//  TableView 기반 영화 상세 정보 화면
//

import UIKit

class TableMovieDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var movie: Movie?  // 이전 화면에서 전달받을 영화 정보
    var movieDetailWithCredits: MovieDetailWithCredits?
    var tvDetail: TVDetail?
    var mediaType: String = "movie"
    var isOverviewExpanded = false
    var fullOverviewText = ""
    
    // TableView 섹션 정의
    enum Section: Int, CaseIterable {
        case poster = 0      // 포스터 + 제목
        case basicInfo = 1   // 개봉일, 평점
        case detailInfo = 2  // 상영시간, 장르
        case overview = 3    // 줄거리
        case cast = 4        // 배우 정보
        case favorite = 5    // 찜하기 버튼
        
        var title: String {
            switch self {
            case .poster: return ""
            case .basicInfo: return ""
            case .detailInfo: return ""
            case .overview: return "줄거리"
            case .cast: return "주요 배우"
            case .favorite: return ""
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        
        tableView.estimatedRowHeight = 120
        
        displayMovieInfo()
        loadMediaDetail()
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        
        print("🎬 TableMovieDetailViewController 로딩 완료")
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // 섹션 간 간격
        tableView.sectionHeaderHeight = 10
        tableView.sectionFooterHeight = 0
        
        // ❌ 자동 높이 설정 제거 (충돌 방지)
        // tableView.rowHeight = UITableView.automaticDimension
        // tableView.estimatedRowHeight = 400
        
        print("🎬 TableView 설정 완료")
    }
    
    func displayMovieInfo() {
        guard let movie = movie else {
            print("❌ 영화 정보가 없습니다")
            return
        }
        
        navigationItem.title = movie.title
        fullOverviewText = movie.overview.isEmpty ? "줄거리 정보가 없습니다." : movie.overview
        
        tableView.reloadData()
        print("🎬 기본 영화 정보 표시: \(movie.title)")
    }
    
    // 미디어 상세 정보 로딩 (영화 또는 TV 구분)
    func loadMediaDetail() {
        guard let movie = movie else { return }
        
        print("🔍 미디어 상세 정보 로딩 시작: \(movie.title), 타입: \(mediaType)")
        
        if mediaType == "tv" {
            // TV 프로그램 상세 정보 로딩
            TMDBService.shared.fetchTVDetailWithCredits(tvId: movie.id) { [weak self] result in
                switch result {
                case .success(let tvDetail):
                    print("✅ TV 통합 정보 로딩 완료")
                    self?.tvDetail = tvDetail
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    
                case .failure(let error):
                    print("❌ TV 통합 정보 로딩 실패: \(error)")
                }
            }
        } else {
            // 영화 상세 정보 로딩 (기존 코드)
            TMDBService.shared.fetchMovieDetailWithCredits(movieId: movie.id) { [weak self] result in
                switch result {
                case .success(let movieDetailWithCredits):
                    print("✅ 영화 통합 정보 로딩 완료")
                    self?.movieDetailWithCredits = movieDetailWithCredits
                    
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    
                case .failure(let error):
                    print("❌ 영화 통합 정보 로딩 실패: \(error)")
                }
            }
        }
    }
}

// UITableViewDataSource & UITableViewDelegate
extension TableMovieDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1  // 각 섹션에 하나씩
    }
    
    // ✅ Cell 높이 강제 지정 (새로 추가된 메서드)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = Section(rawValue: indexPath.section) else {
            return 44
        }
        
        switch section {
        case .poster:
            return 400  // 포스터 섹션은 무조건 400pt 높이
        case .overview:
            return UITableView.automaticDimension  // 줄거리는 펼침/접힘에 따라
        case .cast:
            return 180  // 배우 정보는 180pt
        default:
            return 60   // 나머지는 60pt
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .poster:
            // ✅ Custom Cell 사용
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PosterCell", for: indexPath) as? PosterTableViewCell else {
                return UITableViewCell()
            }
            
            if let movie = movie {
                cell.configure(with: movie)
            }
            return cell
            
        default:
            // 나머지는 임시로 기본 셀 사용 (일단 UITableViewCell() 으로)
            let cell = UITableViewCell()
            
            // 임시로 기본 셀에 텍스트만 표시
            switch section {
            case .basicInfo:
                // ✅ Custom Cell 사용으로 변경
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "BasicInfoCell", for: indexPath) as? BasicInfoTableViewCell else {
                    return UITableViewCell()
                }
                
                if let movie = movie {
                    cell.configure(with: movie)
                }
                return cell
            case .detailInfo:
                // ✅ Custom Cell 사용으로 변경
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailInfoCell", for: indexPath) as? DetailInfoTableViewCell else {
                    return UITableViewCell()
                }
                
                // ✅ 영화와 TV 구분해서 처리
                if mediaType == "tv", let tvDetail = tvDetail {
                    cell.configureForTV(with: tvDetail)  // TV용 configure 메서드 (나중에 추가)
                } else if let detail = movieDetailWithCredits {
                    cell.configure(with: detail)  // 기존 영화용
                }
                return cell
            case .overview:
                // ✅ Custom Cell 사용으로 변경
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "OverviewCell", for: indexPath) as? OverviewTableViewCell else {
                    return UITableViewCell()
                }
                
                cell.configure(
                    with: fullOverviewText,
                    isExpanded: isOverviewExpanded,
                    toggleAction: { [weak self] in
                        self?.isOverviewExpanded.toggle()
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                )
                return cell
            case .cast:
                // ✅ Custom Cell 사용으로 변경
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "CastCell", for: indexPath) as? CastTableViewCell else {
                    return UITableViewCell()
                }
                
                // ✅ 영화와 TV 구분해서 처리
                if mediaType == "tv", let tvDetail = tvDetail {
                    let mainCast = Array((tvDetail.credits?.cast ?? []).prefix(10))  // TV용 주요 배우
                    cell.configure(with: mainCast)
                } else if let detail = movieDetailWithCredits {
                    cell.configure(with: detail.mainCast)  // 기존 영화용
                }
                return cell
            case .favorite:
                cell.textLabel?.text = "❤️ 찜하기"
                cell.textLabel?.textAlignment = .center
            default:
                break
            }
            
            cell.textLabel?.numberOfLines = 0
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .overview:
            // 줄거리 접기/펼치기
            isOverviewExpanded.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            print("📖 줄거리 상태: \(isOverviewExpanded ? "펼침" : "접음")")
        case .favorite:
            // 찜하기 기능
            print("❤️ 찜하기 버튼 클릭")
        default:
            break
        }
    }
}
