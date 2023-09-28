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

final class PostsViewController: BaseViewController {
    
    typealias PostCell = PostsCollectionViewCell
    typealias DataSource = UICollectionViewDiffableDataSource<Section, PostModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PostModel>
    
    enum Section {
        case main
    }
    
    // MARK: - Property
    
    private var posts: [PostDTO]?
    private var isNavigationBarHidden: Bool = false
    
    // MARK: - UI Property
    
    private let postsViewModel: PostsViewModel
    private let disposeBag = DisposeBag()
    
    private let postsView = PostsView()
    private var postsDataSource: DataSource!
    private var postsSnapshot: Snapshot!
    
    // MARK: - Life Cycle
    
    init(viewModel: PostsViewModel) {
        self.postsViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    init(viewModel: PostsViewModel, isNavigationBarHidden: Bool) {
        self.postsViewModel = viewModel
        self.isNavigationBarHidden = isNavigationBarHidden
        super.init(nibName: nil, bundle: nil)
    }
    
    init(viewModel: PostsViewModel, posts: [PostDTO], isNavigationBarHidden: Bool) {
        self.postsViewModel = viewModel
        self.posts = posts
        self.isNavigationBarHidden = isNavigationBarHidden
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = postsView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBarIsHidden(self.isNavigationBarHidden)
        self.setDataSource()
        self.bindViewModel()
    }
    
    // MARK: - Setting
    
    func bindViewModel() {
        let reload = postsView.refreshControl.rx.controlEvent(.valueChanged)
            .asObservable()
        let viewWillAppear = self.rx.methodInvoked(#selector(self.viewWillAppear(_:)))
            .map { _ in () }
            .asObservable()
        let postTrigger = Observable.merge(reload, viewWillAppear)
        
        let input = PostsViewModel.Input(postTrigger)
        let output = self.postsViewModel.transform(input: input)
        
        output.postList.drive(onNext: { [weak self] posts in
            self?.loadSnapshotData(with: posts)
            self?.postsView.collectionView.refreshControl?.endRefreshing()
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
    
    private func bind(cell: PostsCollectionViewCell) {
        cell.scrapButtonObservable
            .drive(onNext: { [weak self] post in
                guard let post = post else { return }
                self?.postsViewModel.scrapPost(post)
            }).disposed(by: cell.disposeBag)
    }
}

// MARK: - DatatSource

extension PostsViewController {
    private func setDataSource() {
        self.postsDataSource = createDataSource()
        self.configureSnapshot()
    }
    
    private func createDataSource() -> DataSource {
        let cellRegistration = UICollectionView.CellRegistration<PostCell, PostModel> { cell, indexPath, post in
            cell.loadPost(post)
            self.bind(cell: cell)
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
        self.postsDataSource.apply(self.postsSnapshot)
    }
}
