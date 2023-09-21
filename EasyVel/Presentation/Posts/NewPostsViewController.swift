//
//  NewPostsViewController.swift
//  EasyVel
//
//  Created by 이성민 on 2023/08/25.
//

import UIKit

import RxSwift
import RxRelay
import RxCocoa

enum ViewType {
    case trend
    case follow
    case keyword
}

final class NewPostsViewController: RxBaseViewController<NewPostsViewModel> {
    
    typealias PostCell = PostsCollectionViewCell
    typealias DataSource = UICollectionViewDiffableDataSource<Section, PostDTO>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PostDTO>
    
    enum Section {
        case main
    }
    
    // MARK: - Property
    
    private var posts: [PostDTO]?
    //    private var isScrapPostsList: [Bool]?
    private var isNavigationBarHidden: Bool?
    
    // MARK: - UI Property
    
    private let postsView = PostsView()
    private var postsDataSource: DataSource!
    private var postsSnapshot: Snapshot!
    
    // MARK: - Life Cycle
    
    override init(
        viewModel: NewPostsViewModel
    ) {
        super.init(viewModel: viewModel)
        self.view = postsView
    }
    
    init(
        viewModel: NewPostsViewModel,
        posts: [PostDTO],
        isNavigationBarHidden: Bool
    ) {
        super.init(viewModel: viewModel)
        self.posts = posts
        self.isNavigationBarHidden = isNavigationBarHidden
        self.view = postsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBarIsHidden(isNavigationBarHidden ?? true)
    }
    
    // MARK: - Setting
    
    override func bind(viewModel: NewPostsViewModel) {
        self.confiugreDataSource()
        //        let reload = postsView.collectionView.refreshControl?.rx
        //            .controlEvent(.valueChanged)
        //            .asObservable()
        let viewWillAppear = viewModel.viewWillAppear
            .asObservable()
        
        //        let postTrigger = Observable.merge(reload, viewWillAppear)
        
        let input = NewPostsViewModel.Input(viewWillAppear)
        
        let output = viewModel.transform(input: input)
        
        output.postList.drive(onNext: {
            self.loadSnapshotData(with: $0)
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Action Helper
    
    
    
    // MARK: - Custom Method
    
}

// MARK: - DatatSource

extension NewPostsViewController {
    private func confiugreDataSource() {
        self.postsDataSource = createDataSource()
        self.configureSnapshot()
    }
    
    private func createDataSource() -> DataSource {
        let cellRegistration = UICollectionView.CellRegistration<PostCell, PostDTO> { cell, indexPath, post in
            cell.loadPost(post, indexPath)
        }
        
        return DataSource(
            collectionView: postsView.collectionView,
            cellProvider: { collectionView, indexPath, item in
                return collectionView.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: item
                )
            }
        )
    }
}

// MARK: - Snapshot

extension NewPostsViewController {
    func configureSnapshot() {
        self.postsSnapshot = Snapshot()
        self.postsSnapshot.appendSections([.main])
        self.postsDataSource.apply(self.postsSnapshot)
    }
    
    func loadSnapshotData(
        with incomingPosts: [PostDTO]
    ) {
        self.postsSnapshot.appendItems(incomingPosts, toSection: .main)
        self.postsDataSource.apply(self.postsSnapshot)
    }
}

struct PostModel: Identifiable {
    let id: UUID
    let post: PostDTO?
}
