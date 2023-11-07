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
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
    }
    
    override func bind(viewModel: WebViewModel) {
        super.bind(viewModel: viewModel)
        bindOutput(viewModel)
        
        webView.rx.observe(Double.self, "estimatedProgress")
            .compactMap { $0 }
            .distinctUntilChanged()
            .bind(to: viewModel.webViewProgressRelay)
            .disposed(by: disposeBag)

        
//         scrapButton.rx.tap
//             .subscribe(onNext: { [weak self] in
//                 self?.didScrap.toggle()
//                 if let didScrapClosure = self?.didScrapClosure,
//                    let didScrap = self?.didScrap {
//                     didScrapClosure(didScrap)
//                 }
//                 guard let didScrap = self?.didScrap else { return }
//                 if didScrap {
//                     self?.scrapButton.setImage(ImageLiterals.bookMarkFill, for: .normal)
//                     if let postData = self?.postData {
//                         self?.realm.addPost(
//                             item: postData,
//                             folderName: TextLiterals.allPostsScrapFolderText
//                         )
//                     }
//                     self?.scrapButtonTapped()
//                 } else {
//                     self?.scrapButton.setImage(ImageLiterals.bookMark, for: .normal)
//                     if let postData = self?.postData,
//                        let postDataUrl = postData.url {
//                         self?.viewModel?.didUnScrap.accept(postDataUrl)
//                     }
//                 }
//             })
//             .disposed(by: disposeBag)
        
//         subscriberButton.rx.tap
//             .subscribe(onNext: { [weak self] in
//                 self?.didSubscribe.toggle()
//                 guard let didSubscribe = self?.didSubscribe else { return }
//                 if didSubscribe {
//                     self?.subscriberButton.setTitleColor(UIColor.white, for: .normal)
//                     self?.subscriberButton.backgroundColor = .brandColor
//                     self?.showToast(
//                         toastText: TextLiterals.addSubscriberToastText,
//                         backgroundColor: .gray500
//                     )
//                     self?.viewModel?.didSubscribe.accept(true)
//                 } else {
//                     self?.subscriberButton.setTitleColor(UIColor.brandColor, for: .normal)
//                     self?.subscriberButton.backgroundColor = .white
//                     self?.showToast(
//                         toastText: TextLiterals.deleteSubscriberToastText,
//                         backgroundColor: .gray500
//                     )
//                     self?.viewModel?.didSubscribe.accept(false)
//                 }
//             })
//             .disposed(by: disposeBag)
        
//         scrapPopUpView.addToFolderButton.rx.tap
//             .subscribe(onNext: { [weak self] in
//                 if let postData = self?.postData {
//                     self?.folderButtonTapped(scrapPost: postData)
//                 }
//             })
//             .disposed(by: disposeBag)
        
//         scrapPopUpView.moveToStorageButton.rx.tap
//             .subscribe(onNext: { [weak self] in
//                 self?.navigationController?.popViewController(animated: true)
//                 NotificationCenter.default.post(
//                     name: Notification.Name("MoveToScrapStorage"),
//                     object: nil
//                 )
//             })
//             .disposed(by: disposeBag)

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
