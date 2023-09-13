//
//  SubscriberSearchViewModel.swift
//  VelogOnMobile
//
//  Created by 홍준혁 on 2023/05/03.
//

import UIKit

import RxRelay
import RxSwift

enum SearchFollowError: Error {
    case notFoundUser
}

final class FollowSearchViewModel: BaseViewModel {
    
    private let service: SubscriberService
    
    var subscriberSearchDelegate: SubscriberSearchProtocol?
    private var subscriberList: [SubscriberListResponse]?
    private var userData: SearchSubscriberResponse?

    // MARK: - Output
    
    var subscriberAddStatusOutput = PublishRelay<(Bool, String)>()
    var searchUserOutput = PublishRelay<(Bool,SearchSubscriberResponse?)>()
    var pushToUserWeb = PublishRelay<String?>()
    
    // MARK: - Input
    
    let subscriberAddButtonDidTap = PublishRelay<Void>()
    let searchBarDidChange = PublishRelay<String>()
    let userDidTap = PublishRelay<Void>()

    init(
        subscriberList: [SubscriberListResponse]?,
        service: SubscriberService
    ) {
        self.service = service
        self.subscriberList = subscriberList
        
        super.init()
        
        makeOutput()
    }
    
    private func makeOutput() {
        viewWillDisappear
            .subscribe(onNext: { [weak self] in
                guard let subscriberList = self?.subscriberList else { return }
                self?.subscriberSearchDelegate?.searchSubscriberViewWillDisappear(subscriberList: subscriberList)
            })
            .disposed(by: disposeBag)
        
        
        searchBarDidChange
            .throttle(.milliseconds(500), latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] name in
                guard let self else { return }
                self.searchSubscriber(name: name)
                    .subscribe(onNext: { [weak self] response in
                        guard let self else  {return }
                        self.userData = response
                        self.searchUserOutput.accept((response.validate ?? false, response))
                    },onError: { error in
                        //guard let error = error as? SearchFollowError else { return }
                        self.searchUserOutput.accept((false, nil))
                    })
                    .disposed(by: disposeBag)
                
            })
            .disposed(by: disposeBag)
        
        userDidTap
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .subscribe { [weak self] _ in
                self?.pushToUserWeb.accept(self?.userData?.profileURL)
            }
            .disposed(by: disposeBag)
        
//
//
//
//                if response.validate == false {
//
//                    searchUserOutput.accept((false, nil))
//
//                    return Observable.just(false)
//                } else {
//                    searchUserOutput
//                    if let searchSubscriberName = response.userName,
//                       let searchSubscriberImageURL = response.profilePictureURL {
//                        self.searchSubscriberName = searchSubscriberName
//                        self.searchSubscriberImageURL = searchSubscriberImageURL
//                    }
//                    return self.addSubscriber(name: response.userName ?? String())
//                }
//            }
//            .subscribe(onNext: { [weak self] response in
//                guard let self = self else { return }
//                if response {
//                    self.subscriberAddStatusOutput.accept((response, TextLiterals.addSubsriberSuccessText))
//                    guard let searchSubscriberName = self.searchSubscriberName else { return }
//                    guard let searchSubscriberImageURL = self.searchSubscriberImageURL else { return }
//                    self.addNewSubscriber(
//                        searchSubscriberName: searchSubscriberName,
//                        searchSubscriberImageURL: searchSubscriberImageURL
//                    )
//                }
//            })
//            .disposed(by: disposeBag)
        
//        subscriberAddButtonDidTap
//            .flatMapLatest { [weak self] name -> Observable<SearchSubscriberResponse> in
//                guard let self = self else { return Observable.empty() }
//                return self.searchSubscriber(name: name)
//            }
//            .flatMapLatest { [weak self] response -> Observable<Bool> in
//                guard let self = self else { return Observable.empty() }
//                if response.validate == false {
//                    let text = TextLiterals.searchSubscriberIsNotValidText
//                    self.subscriberAddStatusOutput.accept((false, text))
//                    return Observable.just(false)
//                } else {
//                    if let searchSubscriberName = response.userName,
//                       let searchSubscriberImageURL = response.profilePictureURL {
//                        self.searchSubscriberName = searchSubscriberName
//                        self.searchSubscriberImageURL = searchSubscriberImageURL
//                    }
//                    return self.addSubscriber(name: response.userName ?? String())
//                }
//            }
//            .subscribe(onNext: { [weak self] response in
//                guard let self = self else { return }
//                if response {
//                    self.subscriberAddStatusOutput.accept((response, TextLiterals.addSubsriberSuccessText))
//                    guard let searchSubscriberName = self.searchSubscriberName else { return }
//                    guard let searchSubscriberImageURL = self.searchSubscriberImageURL else { return }
//                    self.addNewSubscriber(
//                        searchSubscriberName: searchSubscriberName,
//                        searchSubscriberImageURL: searchSubscriberImageURL
//                    )
//                }
//            })
//            .disposed(by: disposeBag)
    }
    
    private func addNewSubscriber(
        searchSubscriberName: String,
        searchSubscriberImageURL: String
    ) {
        let newSubscriber = SubscriberListResponse(
            img: searchSubscriberImageURL,
            name: searchSubscriberName
        )
        self.subscriberList?.insert(newSubscriber, at: 0)
    }
}

// MARK: - api

private extension FollowSearchViewModel {
    func searchSubscriber(
        name: String
    ) -> Observable<SearchSubscriberResponse> {
        return Observable.create { observer in
            self.service.searchSubscriber(
                name: name
            ) { [weak self] result in
                switch result {
                case .success(let response):
                    guard let result = response as? SearchSubscriberResponse else {
                        self?.serverFailOutput.accept(true)
                        observer.onCompleted()
                        return
                    }
                    observer.onNext(result)
                    observer.onCompleted()
                case .requestErr(_):
                    observer.onError(SearchFollowError.notFoundUser)
                    observer.onCompleted()
                default:
                    self?.serverFailOutput.accept(true)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func addSubscriber(
        name: String
    ) -> Observable<Bool> {
        return Observable.create { observer in
            self.service.addSubscriber(
                fcmToken: "",
                name: name
            ) { [weak self] result in
                switch result {
                case .success(_):
                    observer.onNext(true)
                    observer.onCompleted()
                case .requestErr(_):
                    self?.subscriberAddStatusOutput.accept((false, TextLiterals.addSubscriberRequestErrText))
                    observer.onNext(false)
                    observer.onCompleted()
                default:
                    self?.subscriberAddStatusOutput.accept((false, TextLiterals.addSubscriberRequestErrText))
                    observer.onError(NSError(domain: "UnknownError", code: 0, userInfo: nil))
                }
            }
            return Disposables.create()
        }
    }
}
