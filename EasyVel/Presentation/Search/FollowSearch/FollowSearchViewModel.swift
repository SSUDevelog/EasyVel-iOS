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
    let followButtonDidTap = PublishRelay<Bool>()

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
        
        followButtonDidTap
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe { isSelected in
                guard let name = self.userData?.userName else { return }
                if isSelected {
                    self.addSubscriber(name: name)
                } else {
                    self.deleteSubscriber(name: name)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
}

// MARK: - api

private extension FollowSearchViewModel {
    func searchSubscriber(name: String) -> Observable<SearchSubscriberResponse> {
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
    
    func addSubscriber(name: String)  {
        self.service.addSubscriber(
            fcmToken: "",
            name: name
        ) { result in
            NotificationCenter.default.post(
                name: Notification.Name("updateFollowVC"),
                object: nil
            )
        }
    }
    
    func deleteSubscriber(name: String) {
        self.service.deleteSubscriber(targetName: name) { result in
            NotificationCenter.default.post(
                name: Notification.Name("updateFollowVC"),
                object: nil
            )
        }
    }
    
    
}
