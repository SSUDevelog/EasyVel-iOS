//
//  ListViewController.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/04/30.
//

import UIKit

import RxSwift
import RxCocoa

final class ListViewController: RxBaseViewController<ListViewModel>, SubscriberSearchProtocol {

    private let listView = ListView()
    private var subscriberList: [String]? {
        didSet {
            self.listView.listTableView.reloadData()
        }
    }
    
    override func render() {
        self.view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    func setDelegate() {
        listView.listTableView.dataSource = self
    }

    override func bind(viewModel: ListViewModel) {
        super.bind(viewModel: viewModel)
        bindOutput(viewModel)
        
        listView.postsHeadView.searchSubscriberButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.searchSubcriberButtonTapped()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOutput(_ viewModel: ListViewModel) {
        viewModel.subscriberListOutput
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] data in
                self?.subscriberList = data
            })
            .disposed(by: disposeBag)
        
        viewModel.isListEmptyOutput
            .subscribe(onNext: { [weak self] isListEmpty in
                if isListEmpty {
                    self?.hiddenListTableView()
                } else {
                    self?.hiddenListExceptionView()
                }
            })
            .disposed(by: disposeBag)
    }

    func searchSubscriberViewWillDisappear(
        input: [String]
    ) {
        self.subscriberList = input
        if input.isEmpty == false {
            hiddenListExceptionView()
        } else {
            hiddenListTableView()
        }
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
        let viewModel = SubscriberSearchViewModel()
        let searchSubcriberViewController = SubscriberSearchViewController(viewModel: viewModel)
        searchSubcriberViewController.modalPresentationStyle = .pageSheet
        self.present(searchSubcriberViewController, animated: true)
    }
    
    private func presentUnSubscriberAlert(
        unSubscriberName: String
    ) {
        let alertController = UIAlertController(
            title: TextLiterals.unSubscriberAlertTitle,
            message: TextLiterals.unSubscriberAlertMessage,
            preferredStyle: .alert
        )
        let actionDefault = UIAlertAction(
            title: TextLiterals.unSubscriberAlertOkActionText,
            style: .destructive,
            handler: { [weak self] _ in
                self?.viewModel?.subscriberDeleteButtonDidTap.accept(unSubscriberName)
            })
        let actionCancel = UIAlertAction(
            title: TextLiterals.unSubscriberAlertCancelActionText,
            style: .cancel
        )
        alertController.addAction(actionDefault)
        alertController.addAction(actionCancel)
        self.present(alertController, animated: true)
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscriberList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.identifier) as? ListTableViewCell ?? ListTableViewCell()
        let row = indexPath.row
        cell.selectionStyle = .none
        cell.listText.text = subscriberList?[row]
        cell.unSubscribeButtonDidTap = { [weak self] subscriberName in
            self?.presentUnSubscriberAlert(unSubscriberName: subscriberName)
        }
        return cell
    }
}
