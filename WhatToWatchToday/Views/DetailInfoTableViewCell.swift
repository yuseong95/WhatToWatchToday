//
//  DetailInfoTableViewCell.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/8/25.
//  상영시간과 장르 정보를 표시하는 TableView 셀
//

import UIKit

class DetailInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        // 상영시간 라벨 설정
        runtimeLabel.font = UIFont.systemFont(ofSize: 16)
        runtimeLabel.textColor = .label
        runtimeLabel.numberOfLines = 1
        runtimeLabel.textAlignment = .center
        
        // 장르 라벨 설정
        genreLabel.font = UIFont.systemFont(ofSize: 16)
        genreLabel.textColor = .label
        genreLabel.numberOfLines = 2  // 장르가 길 수 있으니 2줄
        genreLabel.textAlignment = .center
        
        // 셀 선택 스타일 제거
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        runtimeLabel.text = ""
        genreLabel.text = ""
    }
    
    func configure(with movieDetail: MovieDetailWithCredits) {
        runtimeLabel.text = "🕒 \(movieDetail.formattedRuntime)"
        genreLabel.text = "장르: \(movieDetail.genreString)"
    }
    
    // TV 프로그램용 configure 메서드
    func configureForTV(with tvDetail: TVDetail) {
        // 에피소드 길이 계산
        let episodeRuntime = tvDetail.episodeRunTime?.first ?? 0
        let runtimeText = episodeRuntime > 0 ? "🕒 \(episodeRuntime)분/회" : "🕒 정보 없음"
        
        runtimeLabel.text = runtimeText
        
        // 장르 정보
        let genreText = tvDetail.genres?.map { $0.name }.joined(separator: ", ") ?? "장르 정보 없음"
        genreLabel.text = "장르: \(genreText)"
    }
}
