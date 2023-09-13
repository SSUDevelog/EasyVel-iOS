//
//  SubscriberSearchViewController.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/04/29.
//

import UIKit

import RxSwift
import RxCocoa

import Kingfisher

final class FollowSearchViewController: RxBaseViewController<FollowSearchViewModel> {
    
    private let searchView = FollowSearchView()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 280, height: 0))
        searchBar.placeholder = TextLiterals.followSearchPlaceholderText
        searchBar.searchTextField.textColor = .gray500
        searchBar.setImage(ImageLiterals.searchGray,
                           for: .search,
                           state: .normal)
        searchBar.delegate = self
        searchBar.searchTextField.returnKeyType = .done
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNaviagtionBar()
    }
    
    override func render() {
        self.view = searchView
        
        navigationItem.titleView = searchBar
    }

    override func bind(viewModel: FollowSearchViewModel) {
        super.bind(viewModel: viewModel)
        bindOutput(viewModel)
        
//        searchView.followButton.rx.tap
//            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.asyncInstance)
//            .subscribe {
//                viewModel.subscriberAddButtonDidTap.accept(<#T##event: String##String#>)
//            }
//            .disposed(by: disposeBag)
    }
    
    private func bindOutput(_ viewModel: FollowSearchViewModel) {
//        viewModel.subscriberAddStatusOutput
//            .asDriver(onErrorJustReturn: (false, ""))
//            .drive(onNext: { [weak self] isSuccess, statusText in
//                switch isSuccess {
//                case true:
//                    //self?.searchView.searchStatusLabel.textColor = .brandColor
//                    self?.searchView.searchStatusLabel.text = statusText
//                    self?.updateStatusLabel(text: statusText)
//                case false:
//                    self?.searchView.searchStatusLabel.textColor = .red
//                    self?.searchView.searchStatusLabel.text = statusText
//                    self?.updateStatusLabel(text: statusText)
//                }
//            })
//            .disposed(by: disposeBag)
        
        viewModel.searchUserOutput
            .asDriver(onErrorJustReturn: (Bool(),nil))
            .drive { [weak self] (isSuccess, response) in
                
                self?.searchView.notFoundImageView.isHidden = isSuccess
                self?.searchView.contentView.isHidden = !isSuccess
                guard isSuccess else { return }
                self?.searchView.nameLabel.text = response?.userName
                self?.searchView.introduceLabel.text = response?.profileURL
                
                if let imageURL = response?.profilePictureURL, !imageURL.isEmpty {
                    let url = URL(string: imageURL)
                    self?.searchView.imageView.kf.setImage(with: url)
                } else {
                    self?.searchView.imageView.image = ImageLiterals.subscriberImage
                }
                
            }.disposed(by: disposeBag)
    }
//
//    private func updateStatusLabel(text: String) {
//        searchView.searchStatusLabel.text = text
//        delayCompletable(1.5)
//            .asDriver(onErrorJustReturn: ())
//            .drive(onCompleted: { [weak self] in
//                self?.searchView.searchStatusLabel.text = TextLiterals.noneText
//            })
//            .disposed(by: disposeBag)
//    }
    
    private func delayCompletable(_ seconds: TimeInterval) -> Observable<Void> {
        return Observable<Void>.just(())
                .delay(.seconds(Int(seconds)), scheduler: MainScheduler.instance)
    }
    
}

private extension FollowSearchViewController {
}

extension FollowSearchViewController: UISearchBarDelegate {
    func setNaviagtionBar() {
        navigationController?.navigationBar.isHidden = false
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.shadowColor = .gray200
        
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.standardAppearance.shadowColor = .gray200
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel?.searchBarDidChange.accept(searchText)
        
    }
}

