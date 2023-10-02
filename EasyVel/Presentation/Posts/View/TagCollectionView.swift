//
//  TagCollectionView.swift
//  EasyVel
//
//  Created by 이성민 on 10/2/23.
//

import Foundation

import UIKit

import SnapKit

final class TagCollectionView: UICollectionView, UIScrollViewDelegate {
    
    typealias TagDataSource = UICollectionViewDiffableDataSource<Section, TagModel>
    typealias TagSnapshot = NSDiffableDataSourceSnapshot<Section, TagModel>
    typealias TagCell = TagCollectionViewCell
    
    enum Section {
        case main
    }
    
    lazy var tagDataSource: TagDataSource = createDataSource()
    var tagSnapshot: TagSnapshot!
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        self.configUI()
        self.setCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configUI() {
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.isScrollEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.bounces = false
    }
}

extension TagCollectionView {
    
    private func setCollectionView() {
        self.dataSource = self.tagDataSource
        self.collectionViewLayout = createLayout()
        self.configureSnapshot()
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .absolute(28)
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .estimated(100),
                heightDimension: layoutSize.heightDimension
            ),
            subitems: [.init(layoutSize: layoutSize)]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.scrollDirection = .horizontal
        configuration.contentInsetsReference = .none
        
        return UICollectionViewCompositionalLayout(section: section, configuration: configuration)
    }
    
    private func createDataSource() -> TagDataSource {
        let cellRegistration = UICollectionView.CellRegistration<TagCell, TagModel> { cell, _, data in
            cell.loadTag(data)
        }
        
        return TagDataSource(
            collectionView: self
        ) { collectionView, indexPath, tag in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: tag
            )
        }
    }
}

extension TagCollectionView {
    
    private func configureSnapshot() {
        self.tagSnapshot = TagSnapshot()
        self.tagSnapshot.appendSections([.main])
        self.tagDataSource.apply(self.tagSnapshot)
    }
    
    func loadSnapshot(
        with incomingTags: [TagModel]
    ) {
        let previousTags = self.tagSnapshot.itemIdentifiers(inSection: .main)
        self.tagSnapshot.deleteItems(previousTags)
        self.tagSnapshot.appendItems(incomingTags, toSection: .main)
        self.tagDataSource.apply(self.tagSnapshot, animatingDifferences: false)
    }
}
