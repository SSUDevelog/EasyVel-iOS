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
        searchBar.autocapitalizationType = .none
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
        
        searchView.tapGesture.rx.event.bind { recognizer in
            viewModel.userDidTap.accept(Void())
        }
        .disposed(by: disposeBag)
        
        searchView.followButton.rx.tap
            .bind { [weak self] _ in
                guard let self else { return }
                self.searchView.followButton.isSelected.toggle()
                viewModel.followButtonDidTap.accept(self.searchView.followButton.isSelected)
            }
            .disposed(by: disposeBag)
        
        bindOutput(viewModel)
        
    }
    
    private func bindOutput(_ viewModel: FollowSearchViewModel) {
        
        viewModel.searchUserOutput
            .asDriver(onErrorJustReturn: (Bool(),nil))
            .drive { [weak self] (isSuccess, response) in
                self?.searchView.followButton.isSelected = false //TODO: 서버가 response에 follow여부 알려주면 해당값으로 치환
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
                
            }
            .disposed(by: disposeBag)
        
        viewModel.pushToUserWeb
            .asDriver(onErrorJustReturn: nil)
            .drive { [weak self] url in
                guard let url else {
                    self?.showToast(toastText: "주소가 올바르지 않습니다.", backgroundColor: .red)
                    return }
                let webViewModel = WebViewModel(url: url,
                                                service: DefaultSubscriberService.shared)
                let webViewController = WebViewController(viewModel: webViewModel)
                webViewController.isPostWebView = false
                self?.navigationController?.pushViewController(webViewController, animated: true)
            }
            .disposed(by: disposeBag)
            

        
        
    }
    
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
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchView.notFoundImageView.isHidden = true
        }
        viewModel?.searchBarDidChange.accept(searchText)
        
    }
}

