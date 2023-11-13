//
//  UserWebViewModel.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/27.
//

import UIKit

import RxRelay
import RxSwift

final class UserWebViewModel: BaseViewModel {
    
    private let realm = RealmService()
    
    private let user: String
    private let urlString: String
    private let service: FollowService
    
    private var isFollowing: Bool?
    
    // MARK: - Input
    
    let webViewProgressRelay = PublishRelay<Double>()
    let subscribeTrigger = PublishRelay<Void>()
    
    // MARK: - Output
    
    var wasSubscribed = PublishRelay<Bool>()  // viewWillAppear 시 이미 subscribe 되어 있는지 확인
    var didSubscribe = PublishRelay<Bool>()  // subscrbieTrigger 들어왔을 시 이미 subscribe -> 취소 / 아니면 subscribe
    var urlRequestOutput = PublishRelay<URLRequest>()
    var webViewProgressOutput = PublishRelay<Bool>()
    var cannotFoundWebViewURLOutput = PublishRelay<Bool>()
    
    init(
        user: String,
        url: String,
        service: FollowService
    ) {
        self.user = user
        self.service = service
        self.urlString = url
        super.init()
        self.makeOutput()
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
            .flatMapLatest { [weak self] _ -> Observable<[FollowListResponse]> in
                guard let self = self else { return Observable.empty() }
                return self.getSubscriberList()
            }
            .map { subscriberList -> [String] in
                return subscriberList.map { $0.name }
            }
            .subscribe(onNext: { [weak self] subscriberList in
                guard let user = self?.user else { return }
                let isSubscribed = subscriberList.contains(user)
                self?.isFollowing = isSubscribed
                self?.wasSubscribed.accept(isSubscribed)
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
        
        subscribeTrigger
            .debug()
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let isFollowing = self.isFollowing
                else { return }
                
                if isFollowing {
                    self.deleteSubscriber(name: self.user)
                    self.didSubscribe.accept(false)
                } else {
                    self.addSubscriber(name: self.user)
                    self.didSubscribe.accept(true)
                }
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

extension UserWebViewModel {
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
