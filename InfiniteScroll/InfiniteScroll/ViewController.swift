//
//  ViewController.swift
//  InfiniteScroll
//
//  Created by 김민창 on 2022/01/24.
//

import UIKit

class ViewController: UIViewController {
    private let list = [#colorLiteral(red: 0.9882352941, green: 0.8901960784, blue: 0.5411764706, alpha: 1), #colorLiteral(red: 0.5843137255, green: 0.8823529412, blue: 0.8274509804, alpha: 1), #colorLiteral(red: 0.9529411765, green: 0.5058823529, blue: 0.5058823529, alpha: 1)]
    
    private var colorModels = [ColorModel]()
    
    enum Section: Int, CaseIterable {
        case Main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var dataSource: DataSource?
    
    private let serialQueue = DispatchQueue(label: "Serial")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        self.configureCollectionView()
        self.configureDataSource()
        self.configureSnapShot()
    }
    
    private func bindSnapShotApply(section: Section, item: [AnyHashable]) {
        DispatchQueue.global().sync {
            guard var snapShot = self.dataSource?.snapshot() else { return }
            item.forEach {
                snapShot.appendItems([$0], toSection: section)
            }
            self.dataSource?.apply(snapShot, animatingDifferences: true) { [weak self] in
                self?.collectionView.scrollToItem(at: [0, (self?.list.count ?? 1)],
                                                      at: .left,
                                                      animated: false)
            }
        }
    }
    
    private func configureSnapShot() {
        var snapShot = Snapshot()
        snapShot.appendSections([.Main])
        self.dataSource?.apply(snapShot, animatingDifferences: true)
        list.forEach { [weak self] in
            self?.colorModels.append(ColorModel(color: $0))
        }
        var listItem = colorModels
        for i in 0..<6 {
            listItem.append(ColorModel(color: list[i % 3]))
        }
        self.bindSnapShotApply(section: .Main, item: listItem)
    }

    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = self.configureCompositionalLayout()
        
        self.collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
    }

    private func willChangeMainSectionIndex(currentIndex: Int) {
        switch currentIndex {
        case self.colorModels.count - 1:
            self.collectionView.scrollToItem(at: [0, self.colorModels.count * 2 - 1], at: .left, animated: false)
        case self.colorModels.count * 2 + 1:
            self.collectionView.scrollToItem(at: [0, self.colorModels.count], at: .left, animated: false)
        default:
            break
        }
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
    
    private func configureView() {
        self.view.addSubview(self.collectionView)
    
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { (sectionNumber, env) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                                                                heightDimension: .fractionalWidth(0.85)))
            item.contentInsets = .init(top: 5, leading: 7, bottom: 5, trailing: 7)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.93),
                                                                             heightDimension: .fractionalWidth(0.85)),
                                                           subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.contentInsets = .init(top: 15, leading: 0, bottom: 15, trailing: 0)
            
            section.visibleItemsInvalidationHandler = { [weak self] (visibleItems, offset, env) in
                guard let currentIndex = visibleItems.last?.indexPath.row,
                      visibleItems.last?.indexPath.section == 0 else { return }
                
                self?.willChangeMainSectionIndex(currentIndex: currentIndex)
            }
            
            return section
        }
    }
}

