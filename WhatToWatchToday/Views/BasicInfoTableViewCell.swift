//
//  BasicInfoTableViewCell.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/8/25.
//  개봉일과 평점 정보를 표시하는 TableView 셀
//

import UIKit

class BasicInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        // 개봉일 라벨 설정
        releaseDateLabel.font = UIFont.systemFont(ofSize: 16)
        releaseDateLabel.textColor = .label
        releaseDateLabel.numberOfLines = 1
        
        // 평점 라벨 설정
        ratingLabel.font = UIFont.systemFont(ofSize: 16)
        ratingLabel.textColor = .label
        ratingLabel.numberOfLines = 1
        ratingLabel.textAlignment = .right  // 오른쪽 정렬
        
        // 셀 선택 스타일 제거
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        releaseDateLabel.text = ""
        ratingLabel.text = ""
    }
    
    func configure(with movie: Movie) {
        releaseDateLabel.text = "개봉일: \(movie.formattedReleaseDate)"
        ratingLabel.text = "⭐ \(movie.formattedRating) / 10"
    }
}
