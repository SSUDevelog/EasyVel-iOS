//
//  PostsDataSource.swift
//  EasyVel
//
//  Created by 이성민 on 2023/08/14.
//

import UIKit

final class PostsDataSource {
    
    typealias PostCell = PostsCollectionViewCell
    typealias DataSource = UICollectionViewDiffableDataSource
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PostDTO.ID>
    
    // MARK: - Property
    
    enum Section {
        case main
    }
    
    private var dataSource: DataSource<Section, PostDTO.ID>!
    private let collectionView: UICollectionView
    private let postsList: [PostDTO]
    
    // MARK: - UI Property
    
    init(
        collectionView: UICollectionView,
        posts: [PostDTO]
    ) {
        self.collectionView = collectionView
        self.postsList = .init()
        
        setCellRegistration()
        setDataSource()
    }
    
    // MARK: - Life Cycle
    
    
    
    // MARK: - Setting
    
    private func setCellRegistration() {
        self.collectionView.register(cell: PostCell.self)
    }
    
    private func setDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<PostCell, PostDTO> { cell, indexPath, post in
            // FIXME: Cell configuration
        }
        
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, id in
            let post = self.postsList[indexPath.item]
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration,
                                                                for: indexPath,
                                                                item: post)
        })
    }
    
    // MARK: - Custom Method
    
    func loadPosts(
        _ incomingPosts: [PostDTO]
    ) {
        let postIDs = incomingPosts.map { $0.id }
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(postIDs, toSection: .main)
        dataSource.applySnapshotUsingReloadData(snapshot)
    }
    
}
