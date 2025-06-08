//
//  CastTableViewCell.swift
//  WhatToWatchToday
//
//  Created by 나유성 on 6/8/25.
//  배우 정보를 CollectionView로 표시하는 TableView 셀
//

import UIKit

class CastTableViewCell: UITableViewCell {
    
    @IBOutlet weak var castCollectionView: UICollectionView!
    
    var castMembers: [CastMember] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    func setupCollectionView() {
        castCollectionView.delegate = self
        castCollectionView.dataSource = self
        
        // 가로 스크롤 설정
        if let layout = castCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 100, height: 150)
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        // 셀 선택 스타일 제거
        selectionStyle = .none
    }
    
    func configure(with castMembers: [CastMember]) {
        self.castMembers = castMembers
        castCollectionView.reloadData()
    }
}

// CollectionView DataSource & Delegate
extension CastTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return castMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as? CastCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let cast = castMembers[indexPath.item]
        cell.configure(with: cast)
        return cell
    }
}
