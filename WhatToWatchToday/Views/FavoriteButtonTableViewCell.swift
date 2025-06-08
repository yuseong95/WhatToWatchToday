//
//  FavoriteButtonTableViewCell.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/8/25.
//  찜하기 버튼을 표시하는 TableView 셀
//

import UIKit

class FavoriteButtonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    var onFavoritePressed: (() -> Void)?  // 버튼 클릭 시 호출될 클로저
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        // 찜하기 버튼 설정
        favoriteButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        favoriteButton.layer.cornerRadius = 12
        favoriteButton.layer.borderWidth = 2
        
        // 셀 선택 스타일 제거
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onFavoritePressed = nil
    }
    
    func configure(isFavorite: Bool, onPressed: @escaping () -> Void) {
        onFavoritePressed = onPressed
        updateButtonAppearance(isFavorite: isFavorite)
    }
    
    private func updateButtonAppearance(isFavorite: Bool) {
        if isFavorite {
            // 찜한 상태
            favoriteButton.setTitle("❤️ 찜 해제", for: .normal)
            favoriteButton.setTitleColor(.systemRed, for: .normal)
            favoriteButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            favoriteButton.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            // 찜하지 않은 상태
            favoriteButton.setTitle("🤍 찜하기", for: .normal)
            favoriteButton.setTitleColor(.systemBlue, for: .normal)
            favoriteButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
            favoriteButton.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        // 버튼 애니메이션
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = CGAffineTransform.identity
            }
        }
        
        onFavoritePressed?()
    }
}
