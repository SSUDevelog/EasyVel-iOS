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

final class FollowerViewController: RxBaseViewController<FollowerViewModel> {

    private let listView = FollowerView()
    
    override func render() {
        self.view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNotification()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func bind(viewModel: FollowerViewModel) {
        super.bind(viewModel: viewModel)
        bindOutput(viewModel)
        
        listView.postsHeadView.searchButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.searchSubcriberButtonTapped()
            })
            .disposed(by: disposeBag)
        
        listView.listTableView.rx.modelSelected(SubscriberListResponse.self).asObservable()
            .subscribe{ data in
                viewModel.subscriberTableViewCellDidTap.accept(data.name)
            }
            .disposed(by: disposeBag)
            
            
    }
    
    private func bindOutput(_ viewModel: FollowerViewModel) {
        viewModel.subscriberListOutput
            .asDriver(onErrorJustReturn: [])
            .drive(
                listView.listTableView.rx.items(cellIdentifier: FollowerTableViewCell.reuseIdentifier,
                                                   cellType: FollowerTableViewCell.self)
            ) { index, data, cell in
                cell.updateUI(data: data)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
        
        viewModel.isListEmptyOutput
            .asDriver(onErrorJustReturn: Bool())
            .drive(onNext: { [weak self] isListEmpty in
                if isListEmpty {
                    self?.hiddenListTableView()
                } else {
                    self?.hiddenListExceptionView()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.subscriberUserMainURLOutput
            .asDriver(onErrorJustReturn: String())
            .drive(onNext: { [weak self] subscriberUserMainURL in
                self?.pushSubscriberUserMainViewController(userMainURL: subscriberUserMainURL)
            })
            .disposed(by: disposeBag)
        
        viewModel.presentUnsubscribeAlertOutput
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
        self.viewModel?.refreshSubscriberList.accept(true)
    }
    
    private func hiddenListExceptionView() {
        listView.ListViewExceptionView.isHidden = true
        listView.listTableView.isHidden = false
    }
    
    private func hiddenListTableView() {
        listView.ListViewExceptionView.isHidden = false
        listView.listTableView.isHidden = true
    }
    
    private func searchSubcriberButtonTapped() {
        let viewModel = FollowSearchViewModel(subscriberList: viewModel?.subscriberList,
                                                service: DefaultSubscriberService.shared)
        let followerSearchVC = FollowSearchViewController(viewModel: viewModel)
        viewModel.subscriberSearchDelegate = self
        navigationController?.pushViewController(followerSearchVC, animated: true)
    }
    
    private func pushSubscriberUserMainViewController(
        userMainURL: String
    ) {
        let webViewModel = WebViewModel(
            url: userMainURL,
            service: DefaultSubscriberService.shared
        )
        let webViewController = WebViewController(viewModel: webViewModel)
        webViewController.isPostWebView = false
        self.navigationController?.pushViewController(webViewController, animated: true)
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
        listView.listTableView.setContentOffset( .init(x: 0, y: -20), animated: true)
    }
}

extension FollowerViewController: SubscriberSearchProtocol {
    func searchSubscriberViewWillDisappear(
        subscriberList: [SubscriberListResponse]
    ) {
        self.viewModel?.subscriberList = subscriberList
    }
}

extension FollowerViewController: FollowerTableViewCellDelegate {
    func unsubscribeButtonDidTap(name: String) {
        viewModel?.unsubscriberButtonDidTap.accept(name)
    }
    
    
}

extension FollowerViewController: VelogAlertViewControllerDelegate {
    func yesButtonDidTap(_ alertType: AlertType) {
        viewModel?.deleteSubscribeEvent.accept(())
    }
    
    
}

