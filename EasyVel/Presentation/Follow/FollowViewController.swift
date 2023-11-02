//
//  ListViewController.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/04/30.
//

import UIKit

import RxSwift
import RxRelay
import RxCocoa

final class FollowViewController: RxBaseViewController<FollowViewModel> {

    private let rootView = FollowView()
    
    override func render() {
        self.view = rootView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func bind(viewModel: FollowViewModel) {
        super.bind(viewModel: viewModel)
        bindOutput(viewModel)
        
        rootView.postsHeadView.searchButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.searchSubcriberButtonTapped()
            })
            .disposed(by: disposeBag)
        
        rootView.followTableView.rx.modelSelected(FollowListResponse.self).asObservable()
            .subscribe{ data in
                viewModel.followTableViewCellDidTap.accept(data.name)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindOutput(_ viewModel: FollowViewModel) {
        viewModel.followListOutput
            .asDriver(onErrorJustReturn: [])
            .drive(
                rootView.followTableView.rx.items(cellIdentifier: FollowTableViewCell.reuseIdentifier,
                                                   cellType: FollowTableViewCell.self)
            ) { index, data, cell in
                cell.updateUI(data: data)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
        
        viewModel.isFollowEmptyOutput
            .asDriver(onErrorJustReturn: Bool())
            .drive(onNext: { [weak self] isListEmpty in
                if isListEmpty {
                    self?.hiddenListTableView()
                } else {
                    self?.hiddenListExceptionView()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.followUserMainURLOutput
            .asDriver(onErrorJustReturn: String())
            .drive(onNext: { [weak self] followUserMainURL in
                self?.pushSubscriberUserMainViewController(userMainURL: followUserMainURL)
            })
            .disposed(by: disposeBag)
        
        viewModel.presentUnfollowAlertOutput
            .asDriver(onErrorJustReturn: Bool())
            .drive { [weak self] bool in
                guard let self else { return } 
                let alertVC = VelogAlertViewController(alertType: .unsubscribe,
                                                       delegate: self)
                self.present(alertVC, animated: false)
            }
            .disposed(by: disposeBag)
    }

    func searchSubscriberViewWillDisappear() {
        self.viewModel?.refreshFollowList.accept(true)
    }
    
    private func hiddenListExceptionView() {
        rootView.followViewExceptionView.isHidden = true
        rootView.followTableView.isHidden = false
    }
    
    private func hiddenListTableView() {
        rootView.followViewExceptionView.isHidden = false
        rootView.followTableView.isHidden = true
    }
    
    private func searchSubcriberButtonTapped() {
        let viewModel = FollowSearchViewModel(subscriberList: viewModel?.followList,
                                                service: DefaultFollowService.shared)
        let followSearchVC = FollowSearchViewController(viewModel: viewModel)
        navigationController?.pushViewController(followSearchVC, animated: true)
    }
    
    private func pushSubscriberUserMainViewController(
        userMainURL: String
    ) {
        let webViewModel = WebViewModel(
            url: userMainURL,
            service: DefaultFollowService.shared
        )
        let webViewController = WebViewController(viewModel: webViewModel)
        webViewController.isPostWebView = false
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
}

extension FollowViewController: FollowTableViewCellDelegate {
    func unsubscribeButtonDidTap(name: String) {
        viewModel?.unfollowButtonDidTap.accept(name)
    }
}

extension FollowViewController: VelogAlertViewControllerDelegate {
    func yesButtonDidTap(_ alertType: AlertType) {
        viewModel?.deleteFollowEvent.accept(())
    }
}

