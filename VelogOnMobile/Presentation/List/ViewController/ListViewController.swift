//
//  ListViewController.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/04/30.
//

import UIKit

import RxSwift
import RxCocoa

protocol ListViewModelSendData: TagSearchProtocol, SubscriberSearchProtocol {}

final class ListViewController: RxBaseViewController<ListViewModel>, ListViewModelSendData {

    private let listView = ListView()
    private var tagList: [String]?
    private var subscriberList: [String]?
    
    override func render() {
        self.view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
        addButtonTarget()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    func setDelegate() {
        listView.listTableView.dataSource = self
        listView.listTableView.delegate = self
    }
    
    func addButtonTarget() {
        listView.postsHeadView.addButton.addTarget(self, action: #selector(presentActionSheet), for: .touchUpInside)
    }

    override func bind(viewModel: ListViewModel) {
        super.bind(viewModel: viewModel)
        
        // MARK: - fix me
        
        let input = ListViewModel.Input(
            tagDeleteButtonDidTap: self.listView.listTableView.rx.itemSelected
                .filter { indexPath in
                    indexPath.section == 0
                }
                .map { indexPath in
                    if let selectedCell = self.listView.listTableView.cellForRow(at: indexPath) as? ListTableViewCell {
                        return selectedCell.listText.text ?? String()
                    }
                    return String()
                }
                .filter { $0 != nil }
                .map { $0! },
            subscriberDeleteButtonDidTap: self.listView.listTableView.rx.itemSelected
                .filter { indexPath in
                    indexPath.section == 1
                }
                .map { indexPath in
                    if let selectedCell = self.listView.listTableView.cellForRow(at: indexPath) as? ListTableViewCell {
                        return selectedCell.listText.text ?? String()
                    }
                    return String()
                }
                .filter { $0 != nil }
                .map { $0! }
        )
        
        let output = viewModel.transfrom(from: input, disposeBag: self.disposeBag)
        
        output.tagListOutput
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] data in
                self?.tagList = data
                self?.listView.listTableView.reloadData()
            })
            .disposed(by: disposeBag)
        output.subscriberListOutput
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] data in
                self?.subscriberList = data
                self?.listView.listTableView.reloadData()
            })
            .disposed(by: disposeBag)
        output.isListEmptyOutput
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isListEmpty in
                if isListEmpty {
                    self?.hiddenListTableView()
                } else {
                    self?.hiddenListExceptionView()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func searchTagViewWillDisappear(input: [String]) {
        self.tagList = input
        if !input.isEmpty {
            hiddenListExceptionView()
        } else {
            hiddenListTableView()
        }
    }
    
    func searchSubscriberViewWillDisappear(input: [String]) {
        self.subscriberList = input
        if !input.isEmpty {
            hiddenListExceptionView()
        } else {
            hiddenListTableView()
        }
    }
    
    func hiddenListExceptionView() {
        listView.ListViewExceptionView.isHidden = true
        listView.listTableView.isHidden = false
    }
    
    func hiddenListTableView() {
        listView.ListViewExceptionView.isHidden = false
        listView.listTableView.isHidden = true
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // MARK: - fix
        switch section {
        case 0: return tagList?.count ?? 0
        case 1: return subscriberList?.count ?? 0
        default: return Int()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.identifier) as? ListTableViewCell ?? ListTableViewCell()
        cell.selectionStyle = .none
        let section = indexPath.section
        let row = indexPath.row
        switch section {
        case 0: cell.listText.text = tagList?[row]
        case 1: cell.listText.text = subscriberList?[row]
        default: return cell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let selectedCell = tableView.cellForRow(at: indexPath) as! ListTableViewCell
        let section = indexPath.section
        switch section {
        case 0:
            let swipeAction = UIContextualAction(style: .destructive, title: TextLiterals.tableViewDeleteSwipeTitle, handler: { action, view, completionHaldler in
//                if let tag = selectedCell.listText.text {
//                    self.viewModel?.tagDeleteButtonDidTap(tag: tag)
//                }
                
                completionHaldler(true)
            })
            return UISwipeActionsConfiguration(actions: [swipeAction])
        case 1:
            let swipeAction = UIContextualAction(style: .destructive, title: TextLiterals.tableViewDeleteSwipeTitle, handler: { action, view, completionHaldler in
//                if let target = selectedCell.listText.text {
//                    self.viewModel?.subscriberDeleteButtonDidTap(target: target)
//                }
                completionHaldler(true)
            })
            let configuration = UISwipeActionsConfiguration(actions: [swipeAction])
            return configuration
        default:
            let configuration = UISwipeActionsConfiguration()
            return configuration
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return TextLiterals.listKeywordText
        case 1: return TextLiterals.listSubscriberText
        default: return String()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
}

// MARK: - button Action

private extension ListViewController {
    @objc
    func presentActionSheet() {
        let searchKeywordButtonAction = UIAlertAction(title: TextLiterals.listKeywordActionSheetTitleText, style: .default) { [weak self] action in
            self?.addKeywordButtonTap()
        }
        let searchSubscriberButtonAction = UIAlertAction(title: TextLiterals.listSubscriberActionSheetTitleText, style: .default) { [weak self] action in
            self?.addSubscriberButtonTap()
        }
        let cancelAction = UIAlertAction(title: TextLiterals.listActionSheetCancelText, style: .cancel)
        let actionSheet = UIAlertController(title: TextLiterals.listAlertControllerTitleText, message: TextLiterals.listAlertControllerMessageText, preferredStyle: .actionSheet)
        actionSheet.addAction(searchKeywordButtonAction)
        actionSheet.addAction(searchSubscriberButtonAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }
    
    func addKeywordButtonTap() {
        let tagSearchViewModel = TagSearchViewModel()
        tagSearchViewModel.tagSearchDelegate = self
        let tagSearchVC = TagSearchViewController(viewModel: tagSearchViewModel)
        tagSearchVC.modalPresentationStyle = .pageSheet
        if let sheet = tagSearchVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(tagSearchVC, animated: true)
    }
    
    func addSubscriberButtonTap() {
        let viewModel = SubscriberSearchViewModel()
        viewModel.subscriberSearchDelegate = self
        let subscriberSearchVC = SubscriberSearchViewController(viewModel: viewModel)
        subscriberSearchVC.modalPresentationStyle = .pageSheet
        if let sheet = subscriberSearchVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(subscriberSearchVC, animated: true)
    }
}
