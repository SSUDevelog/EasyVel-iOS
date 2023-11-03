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

final class ScrapStorageViewController: RxBaseViewController<ScrapStorageViewModel> {
    
    let scrapView = ScrapStorageView()
    private lazy var dataSource = ScrapStorageCollectionViewDataSource(collectionView: scrapView.scrapCollectionView)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNotification()
    }
    
    override func render() {
        view = scrapView
    }

    override func bind(viewModel: ScrapStorageViewModel) {
        super.bind(viewModel: viewModel)
        bindOutput(viewModel)
        
        scrapView.scrapCollectionView.rx.itemSelected
            .subscribe { [weak self] indexPath in
                let cell = self?.scrapView.scrapCollectionView.cellForItem(at: indexPath) as? ScrapStorageCollectionViewCell
                let folderName = cell?.folderNameLabel.text ?? TextLiterals.allPostsScrapFolderText
                let storageView = NewStoragePostView(title: folderName)
                let storageViewModel = NewStorageViewModel()
                let storageViewController = NewStorageViewController(
                    view: storageView,
                    viewModel: storageViewModel,
                    folderName: folderName
                )
                self?.navigationController?.pushViewController(storageViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        scrapView.addFolderButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.addFolderAlert()
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
        
        viewModel.alreadyHaveFolderNameRelay
            .asDriver(onErrorJustReturn: Bool())
            .drive(onNext: { [weak self] alreadyHaveFolderName in
                if alreadyHaveFolderName {
                    self?.showToast(
                        toastText: TextLiterals.alreadyHaveFolderToastText,
                        backgroundColor: .gray300
                    )
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func addFolderAlert() {
        let alertController = UIAlertController(
            title: TextLiterals.addFolderAlertTitle,
            message: nil,
            preferredStyle: .alert
        )
        alertController.addTextField()
        let okAction = UIAlertAction(
            title: TextLiterals.addFolderAlertOkActionTitle,
            style: .default
        ) { [weak self] action in
            if let folderTextField = alertController.textFields?.first,
               let addFolderName = folderTextField.text {
                self?.viewModel?.addFolderInput.accept(addFolderName)
            }
        }
        let cancelAction = UIAlertAction(
            title: TextLiterals.addFolderAlertCancelActionTitle,
            style: .cancel
        )
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true)
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
