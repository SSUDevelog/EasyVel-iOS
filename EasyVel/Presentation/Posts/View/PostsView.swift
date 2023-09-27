//
//  PostsView.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/01.
//

import UIKit

import SnapKit

final class PostsView: BaseUIView {
    
    // MARK: - UI Property
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        view.backgroundColor = .gray100
        view.refreshControl = refreshControl
        return view
    }()
    let keywordsPostsViewExceptionView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.emptyPostsList
        imageView.isHidden = true
        return imageView
    }()
    let refreshControl = UIRefreshControl()
    
    // MARK: - Setting
    
    override func render() {
        self.addSubviews(
            collectionView,
            keywordsPostsViewExceptionView
        )
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        keywordsPostsViewExceptionView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(166)
            $0.width.equalTo(150)
        }
    }
    
    override func configUI() {
        self.backgroundColor = .white
    }
}

extension PostsView {
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(317)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(317)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 20
            section.contentInsets = .init(top: 24, leading: 20, bottom: 24, trailing: 20)
            
            return section
        }
    }
}
