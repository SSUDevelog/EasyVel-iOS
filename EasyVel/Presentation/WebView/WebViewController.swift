//
//  WebViewController.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/04.
//

import UIKit
import WebKit

import RxCocoa
import RxSwift
import SnapKit

final class WebViewController: RxBaseViewController<WebViewModel> {
    
    // MARK: - Property
    
    var popTrigger: Driver<Void> {
        return self.backButton.rx.tap.asDriver()
    }
    
    var followTrigger: Driver<Void> {
        return self.followButton.rx.tap.asDriver()
    }
    
    var scrapTrigger: Driver<Void> {
        return self.scrapButton.rx.tap.asDriver()
    }
    
    // MARK: - UI Property
    
    private let navigationBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
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
        return button
    }()
    
    private let scrapButton: UIButton = {
        let button = UIButton()
        button.setImage(.bookmark, for: .normal)
        button.setImage(.bookmarkFill, for: .selected)
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
        view = webView
        view.addSubviews(
            webViewExceptionView
        )
        
        webViewExceptionView.snp.makeConstraints {
            $0.height.equalTo(202)
            $0.width.equalTo(182)
            $0.center.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func bind(viewModel: WebViewModel) {
        super.bind(viewModel: viewModel)
        bindOutput(viewModel)
        
        webView.rx.observe(Double.self, "estimatedProgress")
            .compactMap { $0 }
            .distinctUntilChanged()
            .bind(to: viewModel.webViewProgressRelay)
            .disposed(by: disposeBag)
    }
    
    private func bindOutput(_ viewModel: WebViewModel) {
        
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
    }

}
