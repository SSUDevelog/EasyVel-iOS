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
    
    private var postList: [PostDTO]?
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
        self.postList = posts
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
        
        self.setDataSource()
        self.bind()
        self.bindViewModel()
        self.bindNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if isNavigationBarHidden == false {
                navigationController?.navigationBar.isHidden = false
            }
        }

    // MARK: - Setting
    
    private func bind() {
        let viewWillAppear = self.rx.methodInvoked(#selector(self.viewWillAppear(_:)))
        viewWillAppear.bind(onNext: { [weak self] _ in
            guard let snapshot = self?.postsSnapshot else { return }
            self?.postsDataSource.applySnapshotUsingReloadData(snapshot)
        }).disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        let reload = self.postsView.refreshControl.rx.controlEvent(.valueChanged)
            .asObservable()
        let viewDidLoad = self.rx.methodInvoked(#selector(self.viewDidLoad))
            .map { _ in () }
            .asObservable()
        let postFetchTrigger = Observable.merge(reload, viewDidLoad)
        
        let input = PostsViewModel.Input(postFetchTrigger)
        let output = postsViewModel.transform(input: input)
        
        output.postList.drive(onNext: { [weak self] posts in
            self?.postList = posts.map { $0.post }
            self?.loadSnapshot(with: posts, andAnimation: true)
            self?.postsView.collectionView.refreshControl?.endRefreshing()
            LoadingView.hideLoading()
        }).disposed(by: disposeBag)
        
        output.isPostListEmpty.drive(onNext: { [weak self] isEmpty in
            self?.showEmptyView(when: isEmpty)
            LoadingView.hideLoading()
        }).disposed(by: disposeBag)
    }
    
    private func bind(cell: PostsCollectionViewCell) {
        cell.scrapButtonObservable
            .drive(onNext: { [weak self] post in
                guard let scrappedPost = post else { return }
                self?.postsViewModel.scrapPost(scrappedPost)
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
        guard let postURL = self.postList?[indexPath.item].url else { return }
        let webViewModel = WebViewModel(url: postURL, service: DefaultFollowService.shared)
        let webViewController = WebViewController(viewModel: webViewModel)
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
