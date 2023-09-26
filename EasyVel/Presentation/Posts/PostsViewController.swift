//
//  PostsViewController.swift
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

final class PostsViewController: RxBaseViewController<PostsViewModel> {
    
    typealias PostCell = PostsCollectionViewCell
    typealias DataSource = UICollectionViewDiffableDataSource<Section, PostModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PostModel>
    
    enum Section {
        case main
    }
    
    // MARK: - Property
    
    private var posts: [PostDTO]?
    private var isNavigationBarHidden: Bool?
    
    private var postsViewModel: PostsViewModel?
    
    // MARK: - UI Property
    
    private let postsView = PostsView()
    private var postsDataSource: DataSource!
    private var postsSnapshot: Snapshot!
    
    // MARK: - Life Cycle
    
    override init(
        viewModel: PostsViewModel
    ) {
        super.init(viewModel: viewModel)
        self.postsViewModel = viewModel
        self.view = postsView
    }
    
    init(
        viewModel: PostsViewModel,
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
    
    override func bind(viewModel: PostsViewModel) {
        self.confiugreDataSource()
        
        let reload = postsView.refreshControl.rx
            .controlEvent(.valueChanged)
            .asObservable()
        let viewWillAppear = viewModel.viewWillAppear
            .asObservable()
        let postTrigger = Observable.merge(reload, viewWillAppear)

        let input = PostsViewModel.Input(postTrigger)
        let output = viewModel.transform(input: input)
        
        output.postList.drive(onNext: { [weak self] data in
            LoadingView.hideLoading()
            self?.postsView.refreshControl.endRefreshing()
            self?.loadSnapshotData(with: data)
        }).disposed(by: disposeBag)
        
        output.isPostListEmpty.drive(onNext: { [weak self] isEmpty in
            self?.showEmptyView(when: isEmpty)
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Action Helper
    
    
    
    // MARK: - Custom Method
    
    private func showEmptyView(when isPostEmpty: Bool) {
        self.postsView.keywordsPostsViewExceptionView.isHidden = !isPostEmpty
    }
    
}

// MARK: - DataSource

extension PostsViewController {
    private func confiugreDataSource() {
        self.postsDataSource = createDataSource()
        self.configureSnapshot()
    }
    
    private func createDataSource() -> DataSource {
        let cellRegistration = UICollectionView.CellRegistration<PostCell, PostModel> { [weak self] cell, indexPath, post in
            cell.loadPost(post, indexPath)
            
            self?.bind(cell: cell)
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
    
    private func bind(cell: PostsCollectionViewCell) {
        cell.scrapButtonObservable
            .drive(onNext: { [weak self] postModel in
                guard var postModel = postModel else { return }
                postModel.isScrapped.toggle()
                cell.isScrapped?.toggle()
                self?.postsViewModel?.scrapPost(postModel)
            }).disposed(by: disposeBag)
    }
}

// MARK: - Snapshot

extension PostsViewController {
    func configureSnapshot() {
        self.postsSnapshot = Snapshot()
        self.postsSnapshot.appendSections([.main])
        self.postsDataSource.apply(self.postsSnapshot)
    }
    
    func loadSnapshotData(
        with incomingPosts: [PostModel]
    ) {
        let previousPosts = self.postsSnapshot.itemIdentifiers(inSection: .main)
        self.postsSnapshot.deleteItems(previousPosts)
        self.postsSnapshot.appendItems(incomingPosts, toSection: .main)
        self.postsDataSource.applySnapshotUsingReloadData(self.postsSnapshot)
    }
}
