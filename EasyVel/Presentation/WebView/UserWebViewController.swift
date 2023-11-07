//
//  UserWebViewController.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/04.
//

import UIKit
import WebKit

import RxCocoa
import RxSwift
import SnapKit

final class UserWebViewController: RxBaseViewController<UserWebViewModel> {
    
    // MARK: - Property
    
    var popTrigger: Driver<Void> {
        return self.backButton.rx.tap.asDriver()
    }
    
    var followTrigger: Observable<Void> {
        return self.followButton.rx.tap.asObservable()
    }
    
    // MARK: - UI Property
    
    private let navigationBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let navigationLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray200
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(ImageLiterals.viewPopButtonIcon, for: .normal)
        return button
    }()
    
    private let followButton: UIButton = {
        let button = UIButton()
        button.makeRoundBorder(cornerRadius: 8, borderWidth: 2, borderColor: .brandColor)
        button.setTitle(TextLiterals.navigationBarSubscribeButtonText, for: .normal)
        button.titleLabel?.font = .body_1_B
        
        button.setTitleColor(.brandColor, for: .normal)
        button.setBackgroundColor(.white, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.setBackgroundColor(.brandColor, for: .selected)
        return button
    }()
    
    lazy var webView : WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    private let webViewExceptionView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.failWeb
        imageView.isHidden = true
        return imageView
    }()
    
    override func render() {
        view.addSubviews(
            navigationBarView,
            navigationLineView,
            webView,
            webViewExceptionView
        )
        
        navigationBarView.addSubviews(
            backButton,
            followButton
        )
        
        navigationBarView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(130)
        }
        
        navigationLineView.snp.makeConstraints {
            $0.top.equalTo(self.navigationBarView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        backButton.snp.makeConstraints {
            $0.size.equalTo(44)
            $0.leading.equalToSuperview().inset(3)
            $0.bottom.equalToSuperview().inset(18)
        }
        
        followButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(self.backButton)
            $0.height.equalTo(32)
            $0.width.equalTo(61)
        }
        
        webView.snp.makeConstraints {
            $0.top.equalTo(self.navigationLineView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        webViewExceptionView.snp.makeConstraints {
            $0.height.equalTo(202)
            $0.width.equalTo(182)
            $0.center.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func bind(viewModel: UserWebViewModel) {
        super.bind(viewModel: viewModel)
        bindOutput(viewModel)
        
        webView.rx.observe(Double.self, "estimatedProgress")
            .compactMap { $0 }
            .distinctUntilChanged()
            .bind(to: viewModel.webViewProgressRelay)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.popViewController(withAnimation: true)
            }
            .disposed(by: self.disposeBag)
        
        followButton.rx.tap
            .debug()
            .bind(to: viewModel.subscribeTrigger)
            .disposed(by: self.disposeBag)
    }
    
    private func bindOutput(_ viewModel: UserWebViewModel) {
        
        viewModel.urlRequestOutput
            .asDriver(onErrorJustReturn: URLRequest(url: URL(fileURLWithPath: "")))
            .drive(onNext: { [weak self] url in
                self?.webView.load(url)
            })
            .disposed(by: disposeBag)
        
        viewModel.webViewProgressOutput
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { isProgressComplete in
                if isProgressComplete {
                    LoadingView.hideLoading()
                } else {
                    LoadingView.showLoading()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.cannotFoundWebViewURLOutput
            .asDriver(onErrorJustReturn: Bool())
            .drive(onNext: { [weak self] isWrongWebURL in
                if isWrongWebURL {
                    self?.webViewExceptionView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.wasSubscribed
            .asDriver(onErrorJustReturn: false)
            .drive(
                with: self,
                onNext: { owner, wasSubscribed in
                    owner.configureFollowButton(status: wasSubscribed)
                }
            )
            .disposed(by: self.disposeBag)
        
        viewModel.didSubscribe
            .debug()
            .subscribe(
                with: self,
                onNext: { owner, didSubscribe in
                    owner.configureFollowButton(status: didSubscribe)
                    owner.showToast(
                        toastText: didSubscribe ? TextLiterals.addSubscriberToastText : TextLiterals.deleteSubscriberToastText,
                        backgroundColor: .gray500)
                },
                onError: { owner, error  in
                    
                }
            )
            .disposed(by: self.disposeBag)
    }

}

extension UserWebViewController {
    func configureFollowButton(status: Bool) {
        self.followButton.isSelected = status
    }
}
