//
//  NewStorageView.swift
//  EasyVel
//
//  Created by 이성민 on 10/9/23.
//

import UIKit

final class NewStoragePostView: BaseUIView {
    
    // MARK: - Property
    
    // MARK: - UI Property
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.backgroundColor = .gray100
        return collectionView
    }()
    
    // MARK: - Life Cycle
    
    
    
    // MARK: - Setting
    
    override func render() {
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func configUI() {
        self.backgroundColor = .gray200
        self.collectionView.collectionViewLayout = createLayout()
        self.collectionView.register(
            StorageCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: StorageCollectionViewHeader.reuseIdentifier
        )
    }
    
}

extension NewStoragePostView {
    
    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(325)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(325)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 20
            section.boundarySupplementaryItems = [self.createHeader()]
            section.contentInsets = .init(top: 0, leading: 20, bottom: 24, trailing: 20)
            
            return section
        }
    }
    
    func createHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(56)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        return header
    }
}
