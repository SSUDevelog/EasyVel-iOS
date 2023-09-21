//
//  KeywordsView.swift
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
        return view
    }()
    let keywordsPostsViewExceptionView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.emptyPostsList
        imageView.isHidden = true
        return imageView
    }()
    
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
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
}
