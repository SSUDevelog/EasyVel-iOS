//
//  StorageViewController.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/04.
//

import UIKit

import RxSwift
import RxCocoa

import SnapKit

final class StorageViewController: RxBaseViewController<StorageViewModel>, FolderViewControllerDelegate {
    
    
    private let storageView = StorageView()
    private var storagePosts: [StoragePost]?
    private var storageTableViewDidScroll = false
    var folderName: String?

    override func render() {
        self.view = storageView
    }
  
    override func bind(viewModel: StorageViewModel) {
        super.bind(viewModel: viewModel)
        bindOutput(viewModel)
        setDelegate()
        
        storageView.storageHeadView.deleteFolderButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.presentDeleteFolderActionSheet()
            })
            .disposed(by: disposeBag)
        
        storageView.storageHeadView.changeFolderNameButton.rx.tap
            .subscribe(onNext: { [weak self] in
                
                let vc = FolderAlertViewController(type: .change, folderName: self?.folderName ?? "")
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.delegate = self
                self?.present(vc, animated: false)
            })
            .disposed(by: disposeBag)
        
        storageView.listTableView.rx.contentOffset
            .subscribe(onNext: { [weak self] contentOffset in
                let scrollY = contentOffset.y
                let isAllScrapFolder = self?.viewModel?.folderName == TextLiterals.allPostsScrapFolderText ? true : false
                if scrollY > 5 && self?.storageTableViewDidScroll == false {
                    self?.storageView.storageTableViewStartScroll()
                    self?.storageTableViewDidScroll.toggle()
                } else if scrollY < 2 && self?.storageTableViewDidScroll == true {
                    self?.storageView.storageTableViewEndScroll(
                        isAllpostFolder: isAllScrapFolder
                    )
                    self?.storageTableViewDidScroll.toggle()
                }
            })
            .disposed(by: disposeBag)
        
        storageView.storageHeadView.viewPopButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOutput(_ viewModel: StorageViewModel) {
        viewModel.storagePostsOutput
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] post in
                self?.storagePosts = post
                self?.storageView.listTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.isPostsEmptyOutput
            .asDriver(onErrorJustReturn: Bool())
            .drive(onNext: { [weak self] isPostsEmpty in
                if isPostsEmpty {
                    self?.storageView.storageViewExceptionView.isHidden = false
                } else {
                    self?.storageView.storageViewExceptionView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.folderNameOutput
            .asDriver(onErrorJustReturn: String())
            .drive(onNext: { [weak self] folderName in
                self?.folderName = folderName
                if folderName == TextLiterals.allPostsScrapFolderText {
                    self?.storageView.storageHeadView.deleteFolderButton.isHidden = true
                    self?.storageView.storageHeadView.changeFolderNameButton.isHidden = true
                } else {
                    self?.storageView.storageHeadView.deleteFolderButton.isHidden = false
                    self?.storageView.storageHeadView.changeFolderNameButton.isHidden = false
                }
            })
            .disposed(by: disposeBag)

    }
    
    func folderVCDismiss(newFolderName:String) {
        self.folderName = newFolderName
        self.storageView.storageHeadView.titleLabel.text = newFolderName
    }
    
    
    func setStorageHeadView(
        headTitle: String
    ) {
        storageView.storageHeadView.titleLabel.text = headTitle
    }
    
    private func setDelegate() {
        storageView.listTableView.dataSource = self
        storageView.listTableView.delegate = self
    }
    
    private func presentDeleteFolderActionSheet() {
        let actionSheetController = UIAlertController(
            title: TextLiterals.deleteFolderActionSheetTitle,
            message: TextLiterals.deleteFolderActionSheetMessage,
            preferredStyle: .actionSheet
        )
        let actionDefault = UIAlertAction(
            title: TextLiterals.deleteFolderActionSheetOkActionText,
            style: .destructive,
            handler: { [weak self] _ in
                self?.viewModel?.deleteFolderButtonDidTap.accept(true)
                self?.navigationController?.popViewController(animated: true)
            })
        let actionCancel = UIAlertAction(
            title: TextLiterals.deleteFolderActionSheetCancelActionText,
            style: .cancel
        )
        actionSheetController.addAction(actionDefault)
        actionSheetController.addAction(actionCancel)
        self.present(actionSheetController, animated: true)
    }

}

extension StorageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return storagePosts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StorageTableViewCell.identifier, for: indexPath) as? StorageTableViewCell else {
            return StorageTableViewCell()
        }
        cell.selectionStyle = .none
        cell.deleteButtonTappedClosure = { [weak self] url in
            self?.viewModel?.deletePostButtonDidTap.accept(url)
        }
        let index = indexPath.section
        if let data = storagePosts?[index] {
            cell.binding(model: data)
            return cell
        }
        return cell
    }
}

extension StorageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let textNum = storagePosts?[indexPath.section].summary?.count ?? 0
        if storagePosts?[indexPath.section].img ?? String() == TextLiterals.noneText {
            switch textNum {
            case 0...50: return SizeLiterals.postCellSmall
            case 51...80: return SizeLiterals.postCellMedium
            case 81...100: return SizeLiterals.postCellLarge
            default: return SizeLiterals.postCellLarge
            }
        } else {
            return SizeLiterals.postCellXLarge
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as? StorageTableViewCell
        guard let url = selectedCell?.url else { return }
        let webViewModel = WebViewModel(url: url, service: DefaultFollowService.shared)
        let webViewController = WebViewController(viewModel: webViewModel)
        navigationController?.pushViewController(webViewController, animated: true)
    }
}
