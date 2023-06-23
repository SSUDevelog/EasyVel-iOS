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
    
    var didSubscribe: Bool = false
    var didScrap: Bool = false
    var didScrapClosure: ((Bool) -> Void)?
    var postData: StoragePost? = nil
    
    var realm = RealmService()
    
    private let scrapButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        button.setImage(ImageLiterals.unSaveBookMarkIcon, for: .normal)
        return button
    }()
    
    private let subscriberButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 56, height: 32)
        button.setTitle(TextLiterals.navigationBarSubscribeButtonText, for: .normal)
        button.setTitleColor(UIColor.brandColor, for: .normal)
        button.titleLabel?.font = .body_1_B
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.brandColor.cgColor
        button.layer.cornerRadius = 8
        return button
    }()
    
    lazy var firstButton = UIBarButtonItem(customView: self.scrapButton)
    
    lazy var secondButton = UIBarButtonItem(customView: self.subscriberButton)
    
    lazy var webView : WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    let scrapPopUpView = ScrapPopUpView()
    
    override func render() {
        view = webView
        view.addSubview(scrapPopUpView)
        
        scrapPopUpView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(82)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(83)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func setupNavigationBar() {
        navigationItem.rightBarButtonItems = [firstButton, secondButton]
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
        
        scrapButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.didScrap.toggle()
                if let didScrapClosure = self?.didScrapClosure,
                   let didScrap = self?.didScrap {
                    didScrapClosure(didScrap)
                }
                guard let didScrap = self?.didScrap else { return }
                if didScrap {
                    self?.scrapButton.setImage(ImageLiterals.saveBookMarkIcon, for: .normal)
                    if let postData = self?.postData {
                        self?.realm.addPost(
                            item: postData,
                            folderName: TextLiterals.allPostsScrapFolderText
                        )
                    }
                    self?.scrapButtonTapped()
                } else {
                    self?.scrapButton.setImage(ImageLiterals.unSaveBookMarkIcon, for: .normal)
                    if let postData = self?.postData,
                       let postDataUrl = postData.url {
                        self?.viewModel?.didUnScrap.accept(postDataUrl)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        subscriberButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.didSubscribe.toggle()
                guard let didSubscribe = self?.didSubscribe else { return }
                if didSubscribe {
                    self?.subscriberButton.setTitleColor(UIColor.white, for: .normal)
                    self?.subscriberButton.backgroundColor = .brandColor
                    self?.showSubscibeToast(
                        toastText: TextLiterals.addSubscriberToastText,
                        toastBackgroundColer: .brandColor
                    )
                    self?.viewModel?.didSubscribe.accept(true)
                } else {
                    self?.subscriberButton.setTitleColor(UIColor.brandColor, for: .normal)
                    self?.subscriberButton.backgroundColor = .white
                    self?.showSubscibeToast(
                        toastText: TextLiterals.deleteSubscriberToastText,
                        toastBackgroundColer: .gray300
                    )
                    self?.viewModel?.didSubscribe.accept(false)
                }
            })
            .disposed(by: disposeBag)
        
        scrapPopUpView.addToFolderButton.rx.tap
            .subscribe(onNext: { [weak self] in
                if let postData = self?.postData {
                    self?.folderButtonTapped(scrapPost: postData)
                }
            })
            .disposed(by: disposeBag)
        
        scrapPopUpView.moveToStorageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(
                    name: Notification.Name("MoveToScrapStorage"),
                    object: nil
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOutput(_ viewModel: WebViewModel) {
        viewModel.didSubscribeWriter
            .asDriver(onErrorJustReturn: Bool())
            .drive(onNext: { [weak self] didSubscribed in
                self?.setSubscribeButton(didSubscribe: didSubscribed)
            })
            .disposed(by: disposeBag)
        
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
    }
    
    private func setSubscribeButton(
        didSubscribe: Bool
    ) {
        self.didSubscribe = didSubscribe
        if didSubscribe {
            self.subscriberButton.setTitleColor(UIColor.white, for: .normal)
            self.subscriberButton.backgroundColor = .brandColor
        } else {
            self.subscriberButton.setTitleColor(UIColor.brandColor, for: .normal)
            self.subscriberButton.backgroundColor = .white
        }
    }
    
    func setScrapButton(
        didScrap: Bool
    ) {
        self.didScrap = didScrap
        if didScrap {
            self.scrapButton.setImage(ImageLiterals.saveBookMarkIcon, for: .normal)
        } else {
            self.scrapButton.setImage(ImageLiterals.unSaveBookMarkIcon, for: .normal)
        }
    }
    
    private func scrapButtonTapped() {
        scrapPopUpView.snp.updateConstraints {
            $0.bottom.equalTo(webView.snp.bottom)
        }
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self.scrapPopUpView.snp.updateConstraints {
                    $0.bottom.equalToSuperview().offset(83)
                }
                UIView.animate(withDuration: 0.5) {
                    self.view.layoutIfNeeded()
                }
            })
        }
    }
    
    private func folderButtonTapped(
        scrapPost: StoragePost
    ) {
        let viewModel = ScrapFolderBottomSheetViewModel()
        viewModel.selectedScrapPostAddInFolder.accept(scrapPost)
        let folderViewController = ScrapFolderBottomSheetViewController(viewModel: viewModel)
        folderViewController.modalPresentationStyle = .pageSheet
        self.present(folderViewController, animated: true)
    }
    
    private func showSubscibeToast(
        toastText: String,
        toastBackgroundColer: UIColor
    ) {
        let toastLabel = UILabel()
        toastLabel.text = toastText
        toastLabel.textColor = .white
        toastLabel.font = .body_2_B
        toastLabel.backgroundColor = toastBackgroundColer
        toastLabel.textAlignment = .center
        toastLabel.layer.cornerRadius = 24
        toastLabel.clipsToBounds = true
        toastLabel.alpha = 1.0
        view.addSubview(toastLabel)
        toastLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(36)
            $0.leading.trailing.equalToSuperview().inset(51)
            $0.height.equalTo(48)
        }
        UIView.animate(withDuration: 0, animations: {
            toastLabel.alpha = 1.0
        }, completion: { isCompleted in
            UIView.animate(withDuration: 0.5, delay: 3.0, animations: {
                toastLabel.alpha = 0
            }, completion: { isCompleted in
                toastLabel.removeFromSuperview()
            })
        })
    }
}
