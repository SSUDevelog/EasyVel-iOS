//
//  NewStorageViewController.swift
//  EasyVel
//
//  Created by 이성민 on 10/5/23.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class NewStorageViewController: BaseViewController {
    
    typealias Cell = NewStorageCollectionViewCell
    typealias EmptyCell = EmptyStorageViewCell
    typealias Header = StorageCollectionViewHeader
    typealias DataSource = UICollectionViewDiffableDataSource<Section, StoragePost>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, StoragePost>
    
    enum Section {
        case main
    }
    
    // MARK: - Property
    
    private let viewModel: NewStorageViewModel
    private let disposeBag = DisposeBag()
    
    private let storageView: NewStoragePostView
    private var storageDataSource: DataSource!
    private var storageSnapshot: Snapshot!
    
    var storageFolderName: String
    
    private var changeFolderNameAlert: UIView?
    private var deleteFolderBottomSheet: UIView?
    
    // MARK: - Life Cycle
    
    init(
        view: NewStoragePostView,
        viewModel: NewStorageViewModel,
        folderName: String
    ) {
        self.storageView = view
        self.viewModel = viewModel
        self.storageFolderName = folderName
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = storageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDataSource()
        self.setSnapshot()
        self.bind()
        self.bindViewModel()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Setting
    
    private func bind() {
        self.storageView.backButton.rx.tap
            .subscribe(onNext: {
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: self.disposeBag)
        
        self.storageView.dismissTrigger
            .drive(with: self) { owner, _ in
                self.storageView.dismissDeleteFolderBottomSheet()
            }.disposed(by: self.disposeBag)
    }
    
    private func bindViewModel() {
        let fetchPostTrigger = self.rx.methodInvoked(#selector(self.viewDidAppear(_:)))
            .map { _ in return self.storageFolderName }
            .asDriver(onErrorDriveWith: Driver.empty())
        let deleteFolderTrigger = self.storageView.deleteFolderTrigger
            .map { _ in return self.storageFolderName }
            .asDriver()
        
        let input = NewStorageViewModel.Input(fetchPostTrigger, deleteFolderTrigger)
        let output = self.viewModel.transform(input)
        
        output.storagePosts
            .drive(with: self) { owner, posts in
                if posts.isEmpty { self.storageView.showEmptyView() }
                else { owner.loadSnapshot(with: posts) }
            }.disposed(by: self.disposeBag)
        output.folderDeleted
            .drive(with: self) { owner, _ in
                owner.storageView.dismissDeleteFolderBottomSheet()
                owner.navigationController?.popViewController(animated: true)
            }.disposed(by: self.disposeBag)
    }
    
    private func bindCell(_ cell: Cell) {
        cell.deleteStoragePostTrigger
            .drive(with: self) { owner, url in
                owner.viewModel.deleteRealmStoragePost(of: url)
            }.disposed(by: self.disposeBag)
    }
    
    private func bindHeader(_ header: Header) {
        header.changeNameButtonTrigger
            .drive(with: self) { owner, _ in
                owner.showChageFolderNameAlert()
            }.disposed(by: self.disposeBag)
        
        header.deleteFolderButtonTrigger
            .debug()
            .drive(with: self) { owner, _ in
                owner.storageView.showDeleteFolderBottomSheet()
            }.disposed(by: self.disposeBag)
    }
}

// MARK: - DataSource

extension NewStorageViewController {
    
    private func setDataSource() {
        self.configureDataSource()
        self.configureDataSourceHeader()
    }
    
    private func configureDataSource() {
        let cellRegsitration = UICollectionView.CellRegistration<Cell, StoragePost> { [weak self] cell, _, post in
            cell.loadPost(post)
            self?.bindCell(cell)
        }
        
        self.storageDataSource = DataSource(collectionView: self.storageView.collectionView) { collectionView, indexPath, post in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegsitration,
                for: indexPath,
                item: post
            )
        }
    }
    
    private func configureDataSourceHeader() {
        let headerRegistration = UICollectionView.SupplementaryRegistration<Header>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] header, _, _ in
            self?.bindHeader(header)
        }
        
        self.storageDataSource.supplementaryViewProvider = { _, _, indexPath in
            return self.storageView.collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
        }
    }
}

// MARK: - Snapshot

extension NewStorageViewController {
    
    private func setSnapshot() {
        self.storageSnapshot = Snapshot()
        self.storageSnapshot.appendSections([.main])
        self.storageDataSource.apply(self.storageSnapshot)
    }
    
    // TODO: 실제 동작 확인해보기
    private func loadSnapshot(
        with storagePosts: [StoragePost]
    ) {
        let previousPosts = self.storageSnapshot.itemIdentifiers(inSection: .main)
        self.storageSnapshot.deleteItems(previousPosts)
        self.storageSnapshot.appendItems(storagePosts, toSection: .main)
        self.storageDataSource.apply(self.storageSnapshot, animatingDifferences: true)
    }
}

// MARK: - Alerts

extension NewStorageViewController {
    
    private func showChageFolderNameAlert() {
        
    }
    
}
