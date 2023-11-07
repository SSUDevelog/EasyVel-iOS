//
//  PostWebView.swift
//  EasyVel
//
//  Created by 이성민 on 11/7/23.
//

import UIKit
import WebKit

import SnapKit
import RxCocoa
import RxSwift

final class PostWebView: BaseUIView {
    
    // MARK: - Property
    
    var popTrigger: Driver<Void> {
        return self.backButton.rx.tap.asDriver()
    }
    
    var followTrigger: Observable<Void> {
        return self.followButton.rx.tap.asObservable()
    }
    
    var scrapTrigger: Observable<Void> {
        return self.scrapButton.rx.tap.asObservable()
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
    
    private let scrapButton: UIButton = {
        let button = UIButton()
        button.setImage(.bookmark, for: .normal)
        button.setImage(.bookmarkFill, for: .selected)
        return button
    }()
    
    lazy var webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    private let exceptionView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiterals.failWeb
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - Life Cycle
    
    // MARK: - Setting
    
    override func render() {
        self.addSubview(navigationBarView)
        navigationBarView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(130)
        }
        
        self.addSubview(navigationLineView)
        navigationLineView.snp.makeConstraints {
            $0.top.equalTo(self.navigationBarView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        navigationBarView.addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.size.equalTo(44)
            $0.leading.equalToSuperview().inset(3)
            $0.bottom.equalToSuperview().inset(18)
        }
        
        navigationBarView.addSubview(scrapButton)
        scrapButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(6)
            $0.centerY.equalTo(self.backButton)
            $0.size.equalTo(44)
        }
        
        navigationBarView.addSubview(followButton)
        followButton.snp.makeConstraints {
            $0.trailing.equalTo(self.scrapButton.snp.leading).offset(-6)
            $0.centerY.equalTo(self.backButton)
            $0.height.equalTo(32)
            $0.width.equalTo(61)
        }
        
        self.addSubview(webView)
        webView.snp.makeConstraints {
            $0.top.equalTo(navigationBarView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        
        webView.addSubview(exceptionView)
        exceptionView.snp.makeConstraints {
            $0.height.equalTo(202)
            $0.width.equalTo(182)
            $0.center.equalToSuperview()
        }
    }
}

// MARK: - Custom Method

extension PostWebView {
    func load(request: URLRequest) {
        self.webView.load(request)
    }
    
    func showExceptionView() {
        self.exceptionView.isHidden = false
    }
    
    func configureFollowButton(status: Bool) {
        self.followButton.isSelected = status
    }
    
    func configureScrapButton(status: Bool) {
        self.scrapButton.isSelected = status
    }
}
