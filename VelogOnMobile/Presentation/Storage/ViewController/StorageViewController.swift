//
//  StorageViewController.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/04.
//

import UIKit

final class StorageViewController: BaseViewController {
    
    private let storageView = StorageView()
    private var viewModel: StorageViewModelInputOutput?
    private var storagePosts: [StoragePost]? {
        didSet {
            storageView.listTableView.reloadData()
        }
    }
    
    init(viewModel: StorageViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    override func render() {
        self.view = storageView
    }
    
    override func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func bind() {
        storageView.storageHeadView.deleteButton.addTarget(self, action: #selector(emptySelectedList), for: .touchUpInside)
        storageView.listTableView.dataSource = self
        storageView.listTableView.delegate = self
        viewModel?.storagePosts = { [weak self] posts in
            self?.storagePosts = posts
        }
    }
                                        
    @objc
    private func emptySelectedList() {
        storageView.listTableView.setEditing(true, animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: StorageTableViewCell.identifier, for: indexPath) as? StorageTableViewCell ?? StorageTableViewCell()
        cell.selectionStyle = .none
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
        if storagePosts?[indexPath.section].img ?? String() == "" {
            switch textNum {
            case 0...50: return SizeLiterals.postCellSmall
            case 51...80: return SizeLiterals.postCellMedium
            case 81...100: return SizeLiterals.postCellLarge
            default: return SizeLiterals.postCellLarge
            }
        } else {
            return SizeLiterals.postCellLarge
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! StorageTableViewCell
        let url = selectedCell.url
        let webViewController = WebViewController(url: url)
        navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let selectedCell = tableView.cellForRow(at: indexPath) as! StorageTableViewCell
        let swipeAction = UIContextualAction(style: .destructive, title: "삭제", handler: { action, view, completionHaldler in
            self.viewModel?.deletePostButtonDidTap(url: selectedCell.url)
            completionHaldler(true)
        })
        let configuration = UISwipeActionsConfiguration(actions: [swipeAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // MARK: - delete
            print("삭제")
            let selectedCell = tableView.cellForRow(at: indexPath) as! StorageTableViewCell
            viewModel?.deletePostButtonDidTap(url: selectedCell.url)
        }
    }
}
