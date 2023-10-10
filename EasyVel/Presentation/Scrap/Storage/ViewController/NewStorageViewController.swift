//
//  NewStorageViewController.swift
//  EasyVel
//
//  Created by 이성민 on 10/5/23.
//

import UIKit

import RxSwift
import RxCocoa

final class NewStorageViewController: BaseViewController {
    
    typealias Cell = NewStorageCollectionViewCell
    typealias Header = StorageCollectionViewHeader
    typealias DataSource = UICollectionViewDiffableDataSource<Section, StoragePost>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, StoragePost>
    
    enum Section {
        case main
    }
    
    // MARK: - Property
    
    private let viewModel: NewStorageViewModel
    private let disposeBag = DisposeBag()
    
    private let storageView = NewStoragePostView()
    private var storageDataSource: DataSource!
    private var storageSnapshot: Snapshot!
    
//    private var storageFolder: String?
    
    private var changeNameAlert: UIAlertController?
    private var deleteFolrderAlert: UIAlertController?
    
    // MARK: - Life Cycle
    
    init(viewModel: NewStorageViewModel) {
        self.viewModel = viewModel
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
    }
    
    // MARK: - Setting
    
    private func bindViewModel() {
        let fetchPostTrigger = self.rx.methodInvoked(#selector(self.viewWillAppear(_:)))
            .asDriver(onErrorDriveWith: Driver.empty())
        
    }
    
    private func bindHeader(_ header: UICollectionReusableView) {
        guard let header = header as? StorageCollectionViewHeader else { return }
        header.changeNameButtonTrigger
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.showRenameFolderAlert()
            }).disposed(by: self.disposeBag)
    }
    
    private func bindCell(_ cell: UICollectionViewCell) {
        
    }
    
}

// MARK: - DataSource

extension NewStorageViewController {
    
    private func setDataSource() {
        self.storageDataSource = createDataSource()
        self.storageDataSource.supplementaryViewProvider = { [weak self] collectionView, _, indexPath in
            return self?.createHeader(
                collectionView: collectionView,
                indexPath: indexPath
            )
        }
    }
    
    private func createDataSource() -> DataSource {
        let cellRegsitration = UICollectionView.CellRegistration<Cell, StoragePost> { [weak self] cell, _, post in
            cell.loadPost(post)
            self?.bindCell(cell)
        }
        
        return DataSource(
            collectionView: self.storageView.collectionView
        ) { collectionView, indexPath, post in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegsitration,
                for: indexPath,
                item: post
            )
        }
    }
    
    private func createHeader(
        collectionView: UICollectionView,
        indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: StorageCollectionViewHeader.reuseIdentifier,
            for: indexPath
        ) as? StorageCollectionViewHeader else { return UICollectionReusableView() }
        self.bindHeader(header)
        return header
    }
}

// MARK: - Snapshot

extension NewStorageViewController {
    
    private func setSnapshot() {
        self.storageSnapshot = Snapshot()
    }
    
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
    
    private func showRenameFolderAlert() {
        self.changeNameAlert = UIAlertController(
            title: TextLiterals.folderNameChangeToastTitle,
            message: nil,
            preferredStyle: .alert
        )
        changeNameAlert?.addTextField()
    }
    
    private func showDeleteFolderAlert() {
        self.deleteFolrderAlert = UIAlertController(
            title: TextLiterals.deleteFolderActionSheetTitle,
            message: TextLiterals.deleteFolderActionSheetMessage,
            preferredStyle: .actionSheet
        )
    }
}
