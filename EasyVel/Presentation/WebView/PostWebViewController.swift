//
//  PostWebViewController.swift
//  EasyVel
//
//  Created by 이성민 on 11/7/23.
//

import Foundation

import RxCocoa
import RxSwift

final class PostWebViewController: BaseViewController {
    
    // MARK: - Property
    
    private let disposeBag = DisposeBag()
    
    private let webView: PostWebView
    private let viewModel: PostWebViewModel
    
    // MARK: - UI Property
    
    // MARK: - Life Cycle
    
    init(
        _ view: PostWebView,
        _ viewModel: PostWebViewModel
    ) {
        self.webView = view
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindUI()
        self.bind(viewModel: self.viewModel)
    }
    
    // MARK: - Setting
    
    private func bindUI() {
        self.webView.popTrigger
            .drive(with: self) { owner, _ in
                owner.popViewController(withAnimation: true)
            }.disposed(by: self.disposeBag)
    }
    
    private func bind(viewModel: PostWebViewModel) {
        let viewWillAppear = self.rx.viewWillAppear.asObservable()
        let followTrigger = self.webView.followTrigger
        let scrapTrigger = self.webView.scrapTrigger
        
        let input = PostWebViewModel.Input(viewWillAppear, followTrigger, scrapTrigger)
        let output = viewModel.transform(input: input, disposeBag: self.disposeBag)
        
        output.webRequest
            .drive(with: self) { owner, request in
                LoadingView.hideLoading()
                guard let request = request else {
                    self.webView.showExceptionView()
                    return
                }
                owner.webView.load(request: request)
            }.disposed(by: self.disposeBag)
        
        output.isFollowing
            .drive(with: self) { owner, isFollowing in
                self.webView.configureFollowButton(status: isFollowing)
            }.disposed(by: self.disposeBag)
        
        output.isScrapped
            .drive(with: self) { owner, isScrapped in
                self.webView.configureScrapButton(status: isScrapped)
            }.disposed(by: self.disposeBag)
        
        output.followTriggerReceived
            .drive(with: self) { owner, didFollow in
                guard let didFollow = didFollow else { return }
                self.webView.configureFollowButton(status: didFollow)
                self.showToast(
                    toastText: didFollow ? TextLiterals.addSubscriberToastText : TextLiterals.deleteSubscriberToastText,
                    backgroundColor: .gray500)
            }.disposed(by: self.disposeBag)
        
        output.scrapTriggerReceived
            .drive(with: self) { owner, didScrap in
                guard let didScrap = didScrap else { return }
                self.webView.configureScrapButton(status: didScrap)
            }.disposed(by: self.disposeBag)
    }
    
    // MARK: - Action Helper
    
    // MARK: - Custom Method
    
}
