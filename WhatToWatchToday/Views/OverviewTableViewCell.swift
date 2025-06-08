//
//  OverviewTableViewCell.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/8/25.
//  줄거리를 표시하는 TableView 셀
//

import UIKit

class OverviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    
    var onTogglePressed: (() -> Void)?  // 버튼 클릭 시 호출될 클로저
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func setupUI() {
        // 줄거리 라벨 설정
        overviewLabel.font = UIFont.systemFont(ofSize: 16)
        overviewLabel.textColor = .label
        overviewLabel.numberOfLines = 0  // 여러 줄 가능
        
        // 토글 버튼 설정
        toggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        toggleButton.setTitleColor(.systemBlue, for: .normal)
        
        // 셀 선택 스타일 제거
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        overviewLabel.text = ""
        toggleButton.setTitle("", for: .normal)
        onTogglePressed = nil
    }
    
    func configure(with text: String, isExpanded: Bool, toggleAction: @escaping () -> Void) {
        overviewLabel.text = text
        overviewLabel.numberOfLines = isExpanded ? 0 : 4
        
        let buttonTitle = isExpanded ? "▲ 접기" : "▼ 더보기"
        toggleButton.setTitle(buttonTitle, for: .normal)
        
        onTogglePressed = toggleAction
    }
    
    @IBAction func toggleButtonTapped(_ sender: UIButton) {
        onTogglePressed?()
    }
}
