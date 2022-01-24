//
//  CollectionViewCell.swift
//  InfiniteScroll
//
//  Created by 김민창 on 2022/01/24.
//

import UIKit

final class CollectionViewCell: UICollectionViewCell {
    static let identifier = "CollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateView(item: ColorModel) {
        self.backgroundColor = item.color
    }
}
