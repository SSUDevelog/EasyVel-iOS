//
//  StorageViewController.swift
//  EasyVel
//
//  Created by 이성민 on 10/5/23.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class StorageViewController: BaseViewController {
    
    typealias Cell = StorageCollectionViewCell
    typealias Header = StorageCollectionViewHeader
    typealias DataSource = UICollectionViewDiffableDataSource<Section, StoragePost>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, StoragePost>
    
    enum Section {
        case main
    }
    
    // MARK: - Property
    
    private let viewModel: StorageViewModel
    private let disposeBag = DisposeBag()
    
    private let storageView: StoragePostView
    private var storageDataSource: DataSource!
    private var storageSnapshot: Snapshot!
    
    private var changeFolderNameAlert: UIView?
    private var deleteFolderBottomSheet: UIView?
    
    // MARK: - Life Cycle
    
    init(
        view: StoragePostView,
        viewModel: StorageViewModel
    ) {
        self.storageView = view
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
        self.bind()
        self.bindViewModel()
        self.bindNavigation()
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
        let viewWillAppear = self.rx.viewWillAppear
            .asDriver()
        let deleteFolderTrigger = self.storageView.deleteFolderTrigger
            .asDriver()
        
        let input = StorageViewModel.Input(viewWillAppear, deleteFolderTrigger)
        let output = self.viewModel.transform(input)
        
        output.storagePosts
            .drive(with: self) { owner, posts in
                if posts.isEmpty { self.storageView.showEmptyView() }
                else { owner.loadSnapshot(with: posts) }
            }.disposed(by: self.disposeBag)
        
        output.folderDeleted
            .drive(with: self) { owner, _ in
                owner.storageView.dismissDeleteFolderBottomSheet()
                owner.showToastOnParentViewController(type: .folderDeleted)
            }.disposed(by: self.disposeBag)
    }
    
    private func bindCell(_ cell: Cell) {
        let editStorageStatusTrigger = cell.editPostStatusTrigger
            .asDriver()
        
        let input = StorageViewModel.CellInput(editStorageStatusTrigger)
        let output = self.viewModel.transformCell(input)
        
        output.newPosts.drive(
            with: self,
            onNext: { owner, storagePosts in
                owner.loadSnapshot(with: storagePosts)
                Toast.show(
                    toastText: TextLiterals.postDescrappedToast,
                    toastBackgroundColor: .gray500,
                    controller: self
                )
            }).disposed(by: cell.disposeBag)
    }
    
    private func bindHeader(_ header: Header) {
        let changeNameTrigger = header.changeNameButtonTrigger
            .asDriver()
        
        let input = StorageViewModel.HeaderInput(changeNameTrigger)
        let output = self.viewModel.transformHeader(input)
        
        output.showChangeNameAlert
            .drive(with: self) { owner, folderName in
                owner.showChageFolderNameAlert(folderName: folderName)
            }.disposed(by: self.disposeBag)
    }
    
    private func bindNavigation() {
        self.storageView.collectionView.rx.itemSelected
            .bind(with: self, onNext: { owner, indexPath in
                let collectionView = owner.storageView.collectionView
                guard let postCell = collectionView.cellForItem(at: indexPath) as? Cell,
                      let url = postCell.post?.url
                else { return }
                owner.pushToWebView(url)
            }).disposed(by: self.disposeBag)
    }
}

// MARK: - Custom Method

extension StorageViewController {
    private func pushToWebView(_ url: String) {
        let webViewModel = WebViewModel(url: url, service: DefaultFollowService.shared)
        let webViewController = WebViewController(viewModel: webViewModel)
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    private func showToastOnParentViewController(type: ToastType) {
        guard let parent = self.parent else { return }
        self.navigationController?.popViewController(animated: true)
        self.showToast(of: type, on: parent)
    }
}

// MARK: - DataSource

extension StorageViewController {
    
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

extension StorageViewController {
    
    private func setSnapshot() {
        self.storageSnapshot = Snapshot()
        self.storageSnapshot.appendSections([.main])
        self.storageDataSource.apply(self.storageSnapshot)
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

extension StorageViewController {
    
    private func showChageFolderNameAlert(folderName: String) {
        let vc = FolderAlertViewController(type: .change, folderName: folderName)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        vc.delegate = self
        self.present(vc, animated: false)
    }
    
}

// MARK: - FolderViewControllerDelegate

extension StorageViewController: FolderViewControllerDelegate {
    func folderVCDismiss(newFolderName: String) {
        self.storageView.updateTitle(to: newFolderName)
    }
}
