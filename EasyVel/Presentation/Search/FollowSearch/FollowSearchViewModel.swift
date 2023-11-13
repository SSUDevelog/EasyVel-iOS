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
    
    private let service: FollowService
    
    private var userData: SearchUserResponse?

    // MARK: - Output
    
    var subscriberAddStatusOutput = PublishRelay<(Bool, String)>()
    var searchUserOutput = PublishRelay<(Bool,SearchUserResponse?)>()
    var pushToUserWeb = PublishRelay<(String, String)>()
    
    // MARK: - Input
    
    let subscriberAddButtonDidTap = PublishRelay<Void>()
    let searchBarDidChange = PublishRelay<String>()
    let userDidTap = PublishRelay<Void>()
    let followButtonDidTap = PublishRelay<Bool>()

    init(
        subscriberList: [FollowListResponse]?,
        service: FollowService
    ) {
        self.service = service
        
        super.init()
        
        makeOutput()
    }
    
    private func makeOutput() {
        
        searchBarDidChange
            .throttle(.milliseconds(500), latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] name in
                guard let self else { return }
                self.searchUser(name: name)
                    .subscribe(onNext: { [weak self] response in
                        guard let self else  {return }
                        self.userData = response
                        self.searchUserOutput.accept((response.validate ?? false, response))
                    },onError: { error in
                        //guard let error = error as? SearchFollowError else { return }
                        self.searchUserOutput.accept((false, nil))
                    })
                    .disposed(by: self.disposeBag)
                
            })
            .disposed(by: disposeBag)
        
        userDidTap
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .subscribe { [weak self] _ in
                guard let self = self,
                      let userData = self.userData,
                      let userName = userData.userName,
                      let userURL = userData.profileURL
                else { return }
                self.pushToUserWeb.accept((userName, userURL))
            }
            .disposed(by: disposeBag)
        
        followButtonDidTap
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe { isSelected in
                guard let name = self.userData?.userName else { return }
                if isSelected {
                    self.addFollow(name: name)
                } else {
                    self.deleteFollow(name: name)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
}

// MARK: - api

private extension FollowSearchViewModel {
    func searchUser(name: String) -> Observable<SearchUserResponse> {
        return Observable.create { observer in
            self.service.searchUser(
                name: name
            ) { [weak self] result in
                switch result {
                case .success(let response):
                    guard let result = response as? SearchUserResponse else {
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
    
    func addFollow(name: String)  {
        self.service.addFollow(
            fcmToken: "",
            name: name
        ) { result in
            NotificationCenter.default.post(
                name: Notification.Name("updateFollowVC"),
                object: nil
            )
        }
    }
    
    func deleteFollow(name: String) {
        self.service.deleteFollow(targetName: name) { result in
            NotificationCenter.default.post(
                name: Notification.Name("updateFollowVC"),
                object: nil
            )
        }
    }
    
    
}
