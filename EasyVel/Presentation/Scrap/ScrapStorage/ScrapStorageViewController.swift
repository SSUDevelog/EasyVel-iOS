//
//  ScrapStorageViewController.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/29.
//

import UIKit

import SnapKit
import RxSwift
import RxRelay

final class ScrapStorageViewController: RxBaseViewController<ScrapStorageViewModel>, FolderViewControllerDelegate {
    
    
    let scrapView = ScrapStorageView()
    private lazy var dataSource = ScrapStorageCollectionViewDataSource(collectionView: scrapView.scrapCollectionView)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNotification()
    }
    
    override func render() {
        view = scrapView
    }

    func folderVCDismiss(newFolderName: String) {

        if let viewModel = self.viewModel {
            viewModel.yesDidTap.accept(true)
            bindOutput(viewModel)
        }
    }
    
    override func bind(viewModel: ScrapStorageViewModel) {
        super.bind(viewModel: viewModel)
        bindOutput(viewModel)
        
        scrapView.scrapCollectionView.rx.itemSelected
            .subscribe { [weak self] indexPath in
                let cell = self?.scrapView.scrapCollectionView.cellForItem(at: indexPath) as? ScrapStorageCollectionViewCell
                let storageViewModel = StorageViewModel()
                let storageViewController = StorageViewController(viewModel: storageViewModel)
                if let folderName = cell?.folderNameLabel.text {
                    storageViewModel.folderName = folderName
                    storageViewController.setStorageHeadView(
                        headTitle: folderName
                    )
                }
                self?.navigationController?.pushViewController(storageViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        scrapView.addFolderButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let vc = FolderAlertViewController(type: .create)
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.delegate = self
                self?.present(vc, animated: false)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func bindOutput(_ viewModel: ScrapStorageViewModel) {
    
        viewModel.storageListOutput
            .asDriver(onErrorJustReturn: ([StorageDTO](), [String](), [Int]()))
            .drive(onNext: { [weak self] folderData, folderImageList, folderPostsCount in
                self?.dataSource.update(
                    folderData: folderData,
                    folderImageList: folderImageList,
                    folderPostsCount: folderPostsCount
                )
            })
            .disposed(by: disposeBag)
    }

    private func setNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrollToTop),
            name: Notification.Name("scrollToTop"),
            object: nil
        )
    }
    
    @objc
    private func scrollToTop() {
        let topIndexPath = IndexPath(item: 0, section: 0)
        scrapView.scrapCollectionView.scrollToItem(at: topIndexPath, at: .top, animated: true)
    }
}
