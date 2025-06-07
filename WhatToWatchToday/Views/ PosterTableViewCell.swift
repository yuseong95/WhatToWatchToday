//
//   PosterTableViewCell.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/8/25.
//  포스터 이미지 + 제목을 표시하는 TableView 셀
//

import UIKit

class PosterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        // 포스터 이미지뷰 설정
        posterImageView.contentMode = .scaleAspectFit
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 8
        
        // 제목 라벨 설정
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .label
        
        // 셀 선택 스타일 제거
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = UIImage(systemName: "photo.fill")
        titleLabel.text = ""
    }
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        
        // 포스터 이미지 로딩
        if let posterURL = movie.fullPosterURL {
            ImageCache.shared.loadImage(from: posterURL) { [weak self] image in
                self?.posterImageView.image = image ?? UIImage(systemName: "photo.fill")
            }
        } else {
            posterImageView.image = UIImage(systemName: "photo.fill")
        }
    }
}
