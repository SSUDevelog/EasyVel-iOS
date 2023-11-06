//
//  WebViewModel.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/27.
//

import UIKit

import RxRelay
import RxSwift

final class WebViewModel: BaseViewModel {
    
    let service: FollowService
    
    private var urlString: String = ""
    private let realm = RealmService()
    
    
    var postWriter: String? 
    var storagePost: StoragePost?
    
    // MARK: - Input
    
    let webViewProgressRelay = PublishRelay<Double>()
    let didSubscribe = PublishRelay<Bool>() //TODO: 23.11.2 VC 쪽에서 삭제함. 이유: 개복잡함
    let didUnScrap = PublishRelay<String>() //TODO: 23.11.2 VC 쪽에서 삭제함. 이유: 개복잡함
    
    // MARK: - Output
    
    var didSubscribeWriter = PublishRelay<Bool>() //TODO: 23.11.2 VC 쪽에서 삭제함. 이유: 개복잡함
    var urlRequestOutput = PublishRelay<URLRequest>()
    var webViewProgressOutput = PublishRelay<Bool>()
    var cannotFoundWebViewURLOutput = PublishRelay<Bool>()
    
    init(
        url: String,
        service: FollowService
    ) {
        self.service = service
        self.urlString = url
        
        super.init()
        
        makeOutput()
    }
    
    private func makeOutput() {
        viewDidLoad
            .subscribe(onNext: { [weak self] in
                guard let webURL = self?.urlString else { return }
                let isWebPageCanLoad = webURL.isValidURL
                if isWebPageCanLoad {
                    guard let encodedStr = webURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
                    if let postURL = URL(string: encodedStr) {
                        self?.urlRequestOutput.accept(URLRequest(url: postURL))
                        return
                    }
                }
                
                // MARK: - web url exception
                LoadingView.hideLoading()
                self?.cannotFoundWebViewURLOutput.accept(true)
            })
            .disposed(by: disposeBag)
        
        viewWillAppear
            .flatMapLatest( { [weak self] _ -> Observable<[FollowListResponse]> in
                guard let self = self else { return Observable.empty() }
                return self.getSubscriberList()
            })
            .map { subscriberList -> [String] in
                return subscriberList.map { $0.name }
            }
            .subscribe(onNext: { [weak self] subscriberNameList in
                guard let didPostWriterSubscribe = self?.didPostWriterSubscribe(
                    subscriberList: Set<String>(subscriberNameList),
                    postWriter: self?.postWriter ?? String()
                ) else { return }
                self?.didSubscribeWriter.accept(didPostWriterSubscribe)
            })
            .disposed(by: disposeBag)
        
        
        webViewProgressRelay
            .subscribe(onNext: { [weak self] progress in
                if progress < 0.8 {
                    self?.webViewProgressOutput.accept(false)
                } else {
                    self?.webViewProgressOutput.accept(true)
                }
            })
            .disposed(by: disposeBag)
        
        didSubscribe //TODO: 23.11.2 VC 쪽에서 삭제함. 이유: 개복잡함
            .subscribe(onNext: { [weak self] response in
                guard let subscriber = self?.postWriter else { return }
                if response {
                    self?.addSubscriber(name: subscriber)
                } else {
                    self?.deleteSubscriber(name: subscriber)
                }
            })
            .disposed(by: disposeBag)
        
        didUnScrap //TODO: 23.11.2 VC 쪽에서 삭제함. 이유: 개복잡함
            .subscribe(onNext: { [weak self] unScrapPostUrl in
                self?.realm.deletePost(url: unScrapPostUrl)
            })
            .disposed(by: disposeBag)
    }
    
    private func didPostWriterSubscribe(
        subscriberList: Set<String>,
        postWriter: String
    ) -> Bool {
        return subscriberList.contains(postWriter)
    }
}

// MARK: - api

extension WebViewModel {
    func addSubscriber(
        name: String
    ) {
        service.addFollow(
            fcmToken: TextLiterals.noneText,
            name: name
        ) { [weak self] result in
            switch result {
            case .success(_): break
            case .requestErr(_):
                self?.serverFailOutput.accept(true)
            default:
                self?.serverFailOutput.accept(true)
            }
        }
    }
    
    func deleteSubscriber(
        name: String
    ) {
        service.deleteFollow(
            targetName: name
        ) { [weak self] result in
            switch result {
            case .success(_): break
            case .requestErr(_):
                self?.serverFailOutput.accept(true)
            default:
                self?.serverFailOutput.accept(true)
            }
        }
    }
    
    func getSubscriberList() -> Observable<[FollowListResponse]> {
        return Observable.create { observer in
            self.service.getFollowList() { [weak self] result in
                switch result {
                case .success(let response):
                    guard let list = response as? [FollowListResponse] else {
                        self?.serverFailOutput.accept(true)
                        observer.onError(NSError(domain: "ParsingError", code: 0, userInfo: nil))
                        return
                    }
                    observer.onNext(list)
                    observer.onCompleted()
                case .requestErr(_):
                    self?.serverFailOutput.accept(true)
                    observer.onError(NSError(domain: "requestErr", code: 0, userInfo: nil))
                default:
                    self?.serverFailOutput.accept(true)
                    observer.onError(NSError(domain: "UnknownError", code: 0, userInfo: nil))
                }
            }
            return Disposables.create()
        }
    }
}
