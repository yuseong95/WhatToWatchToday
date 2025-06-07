//
//  CastCollectionViewCell.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/7/25.
//  배우 정보를 표시하는 CollectionView 셀
//

import UIKit

class CastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        // 이미지뷰 설정
        profileImageView.layer.cornerRadius = 0  // 둥글지 않게
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        // 라벨 스타일
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.numberOfLines = 2
        nameLabel.textColor = .label
    }
    
    // 셀 재사용 준비
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        nameLabel.text = ""
    }
    
    // 배우 정보로 셀 설정
    func configure(with cast: CastMember) {
        nameLabel.text = cast.name
        
        // 프로필 이미지 로딩
        if let profileURL = cast.fullProfileURL {
            ImageCache.shared.loadImage(from: profileURL) { [weak self] image in
                self?.profileImageView.image = image ?? UIImage(systemName: "person.circle.fill")
            }
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
}
