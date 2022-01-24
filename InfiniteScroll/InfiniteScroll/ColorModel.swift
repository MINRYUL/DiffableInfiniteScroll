//
//  ColorModel.swift
//  InfiniteScroll
//
//  Created by 김민창 on 2022/01/24.
//

import Foundation
import UIKit

struct ColorModel: Hashable {
    let identifier = UUID()
    
    let color: UIColor
}


private func configureDataSource() {
    let datasource = DataSource(collectionView: self.collectionView, cellProvider: {(collectionView, indexPath, item) -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell,
              let item = item as? ColorModel else {
                  return UICollectionViewCell()
              }
        
        cell.updateView(item: item)
        return cell
    })
    
    self.dataSource = datasource
    self.collectionView.dataSource = datasource
}
