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

enum PostsViewType {
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
    
    private var postList: [PostDTO]?
    private var isNavigationBarHidden: Bool = false
    private let scrapButtonDidTap = PublishRelay<PostModel>()
    
    // MARK: - UI Property
    
    private let postsViewModel: PostsViewModel
    private let disposeBag = DisposeBag()
    
    private let postsView = PostsView()
    private var postsDataSource: DataSource!
    private var postsSnapshot: Snapshot!
    
    // MARK: - Life Cycle
    
    init(viewModel: PostsViewModel, 
         isNavigationBarHidden: Bool = false) {
        self.postsViewModel = viewModel
        self.isNavigationBarHidden = isNavigationBarHidden
        super.init(nibName: nil, bundle: nil)
        
        
        self.bind()
        self.bindViewModel()
        self.setDataSource()
        self.bindNavigation()
    }
    
    init(viewModel: PostsViewModel, posts: [PostDTO], isNavigationBarHidden: Bool) {
        self.postsViewModel = viewModel
        self.postList = posts
        self.isNavigationBarHidden = isNavigationBarHidden
        super.init(nibName: nil, bundle: nil)
        
        
        self.bind()
        self.bindViewModel()
        self.setDataSource()
        self.bindNavigation()
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isNavigationBarHidden == false {
            navigationController?.navigationBar.isHidden = false
        }
    }
    
    // MARK: - Setting
    
    private func bind() {
        rx.viewDidLoad.bind(onNext: { [weak self] _ in
            guard let snapshot = self?.postsSnapshot else { return }
            self?.postsDataSource.applySnapshotUsingReloadData(snapshot)
        }).disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        
        let input = PostsViewModel.Input(
            viewWillAppearEvent: rx.viewWillAppear.asObservable(),
            refreshEvent: postsView.refreshControl.rx.controlEvent(.valueChanged).asObservable(),
            scrapButtonDidTap: scrapButtonDidTap.asObservable()
        )
        
        let output = postsViewModel.transform(input: input, disposeBag: disposeBag)
        
        output.postList
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] posts in
                self?.postList = posts.map { $0.post }
                self?.loadSnapshot(with: posts, andAnimation: false)
                self?.postsView.collectionView.refreshControl?.endRefreshing()
                LoadingView.hideLoading()
            }).disposed(by: disposeBag)
        
        output.isPostListEmpty
            .asDriver(onErrorJustReturn: true)
            .drive(onNext: { [weak self] isEmpty in
                self?.showEmptyView(when: isEmpty)
                LoadingView.hideLoading()
            }).disposed(by: disposeBag)
        
        output.successScrap
            .asDriver(onErrorJustReturn: StoragePost())
            .drive(with: self) { owner, post in
                NotificationCenter.default.post(name: Notification.Name("ScrapButtonTappedNotification"), object: nil, userInfo: ["data" : post])
            }
            .disposed(by: disposeBag)
    }
    
    private func bind(cell: PostsCollectionViewCell) {
        cell.scrapButtonObservable
            .drive(onNext: { [weak self] post in
                guard let scrappedPost = post else { return }
                self?.scrapButtonDidTap.accept(scrappedPost)
                self?.updateSnapshot(with: scrappedPost)
            }).disposed(by: cell.disposeBag)
    }
    
    private func bindNavigation() {
        self.postsView.collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                self?.pushToWebView(of: indexPath)
            }).disposed(by: disposeBag)
    }
}

// MARK: - Custom Method

extension PostsViewController {
    private func showEmptyView(when isPostEmpty: Bool) {
        self.postsView.keywordsPostsViewExceptionView.isHidden = !isPostEmpty
    }
    
    private func pushToWebView(of indexPath: IndexPath) {
        guard let post = self.postList?[indexPath.item] else { return }
        
        let webView = PostWebView()
        
        let storagePost = post.toStoragePost()
        let service = DefaultFollowService.shared
        let webViewModel = PostWebViewModel(service, storagePost)
        
        let webViewController = PostWebViewController(webView, webViewModel)
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
}

// MARK: - DataSource

extension PostsViewController {
    private func setDataSource() {
        self.postsDataSource = createDataSource()
        self.configureSnapshot()
    }
    
    private func createDataSource() -> DataSource {
        let cellRegistration = UICollectionView.CellRegistration<PostCell, PostModel> { cell, _, post in
            cell.loadPost(post)
            self.bind(cell: cell)
        }
        
        return DataSource(
            collectionView: postsView.collectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
}

// MARK: - Snapshot

extension PostsViewController {
    func configureSnapshot() {
        self.postsSnapshot = Snapshot()
        self.postsSnapshot.appendSections([.main])
        self.postsDataSource.apply(self.postsSnapshot)
    }
    
    func loadSnapshot(
        with incomingPosts: [PostModel],
        andAnimation isAnimated: Bool
    ) {
        let previousPosts = self.postsSnapshot.itemIdentifiers(inSection: .main)
        self.postsSnapshot.deleteItems(previousPosts)
        self.postsSnapshot.appendItems(incomingPosts, toSection: .main)
        self.postsDataSource.apply(self.postsSnapshot, animatingDifferences: isAnimated)
    }
    
    func updateSnapshot(
        with incomingPost: PostModel
    ) {
        let currentPosts = self.postsSnapshot.itemIdentifiers(inSection: .main)
        var newPosts = currentPosts
        guard let index = currentPosts.map({ $0.post }).firstIndex(of: incomingPost.post) else { return }
        newPosts[index] = incomingPost
        self.postsSnapshot.deleteItems(currentPosts)
        self.postsSnapshot.appendItems(newPosts, toSection: .main)
        self.postsDataSource.apply(self.postsSnapshot, animatingDifferences: false)
    }
}

//MARK: - PostScrapButtonDidTapped

extension PostsViewController: PostScrapButtonDidTapped {
    func scrapButtonDidTapped(
        storagePost: StoragePost,
        isScrapped: Bool,
        cellIndex: Int
    ) {
        //        isScrapPostsList?[cellIndex] = isScrapped
        //        // MARK: - fix me, viewModel 주입 방법 수정
        //
        //        let viewModel = PostsViewModel(viewType: .keyword, service: DefaultPostService.shared)
        //        viewModel.cellScrapButtonDidTap.accept((storagePost, isScrapped))
    }
}
